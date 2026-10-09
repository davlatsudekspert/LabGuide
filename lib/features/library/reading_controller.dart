import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/storage/kv_store.dart';
import '../content/content_model.dart';

/// Sahifa xatcho'pi. Nomi bo'sh bo'lsa ekranda “N-sahifa” ko'rsatiladi.
@immutable
class ReadingBookmark {
  const ReadingBookmark({
    required this.page,
    required this.name,
    required this.createdAt,
  });

  factory ReadingBookmark.fromJson(Map<String, Object?> json) =>
      ReadingBookmark(
        page: json['page']! as int,
        name: json['name'] as String? ?? '',
        createdAt: json['at'] as String? ?? '',
      );

  final int page;
  final String name;
  final String createdAt;

  Map<String, Object> toJson() => {'page': page, 'name': name, 'at': createdAt};
}

/// Bitta fayl bo'yicha o'qish holati (shu qurilmada).
@immutable
class ReadingState {
  const ReadingState({
    required this.fileSha,
    required this.lastPage,
    required this.updatedAt,
    this.pageCount,
    this.bookmarks = const [],
  });

  factory ReadingState.fromJson(Map<String, Object?> json) => ReadingState(
    fileSha: json['sha']! as String,
    lastPage: json['page']! as int,
    pageCount: json['pages'] as int?,
    updatedAt: json['at'] as String? ?? '',
    bookmarks: [
      for (final b in (json['bookmarks'] as List?) ?? const [])
        ReadingBookmark.fromJson((b as Map).cast<String, Object?>()),
    ],
  );

  /// Qaysi fayl uchun (yangi nashr kelsa eski sahifa/xatcho'plar
  /// qo'llanmaydi).
  final String fileSha;
  final int lastPage;
  final int? pageCount;
  final String updatedAt;

  /// Sahifa bo'yicha tartiblangan.
  final List<ReadingBookmark> bookmarks;

  ReadingBookmark? bookmarkAt(int page) =>
      bookmarks.where((b) => b.page == page).firstOrNull;

  ReadingState copyWith({
    int? lastPage,
    int? pageCount,
    String? updatedAt,
    List<ReadingBookmark>? bookmarks,
  }) => ReadingState(
    fileSha: fileSha,
    lastPage: lastPage ?? this.lastPage,
    pageCount: pageCount ?? this.pageCount,
    updatedAt: updatedAt ?? this.updatedAt,
    bookmarks: bookmarks ?? this.bookmarks,
  );

  Map<String, Object> toJson() => {
    'sha': fileSha,
    'page': lastPage,
    'pages': ?pageCount,
    'at': updatedAt,
    'bookmarks': [for (final b in bookmarks) b.toJson()],
  };
}

enum LibraryFileFailure { missing, corrupted }

class LibraryFileException implements Exception {
  const LibraryFileException(this.failure, [this.detail]);

  final LibraryFileFailure failure;

  /// Faqat log uchun.
  final String? detail;

  @override
  String toString() => 'LibraryFileException(${failure.name}: $detail)';
}

/// Kutubxonadagi PDF lar uchun o'qish holati (oxirgi sahifa, xatcho'plar)
/// va ilova ichidagi fayllarni tekshirib yuklash.
///
/// Holat faqat shu qurilmada saqlanadi ([StoreKeys.libraryReading]) va
/// “Lokal ma'lumotlarni o'chirish” bilan tozalanadi.
class ReadingController extends ChangeNotifier {
  ReadingController(this._store, {required this._bundle})
    : _states = _read(_store);

  final KeyValueStore _store;
  final AssetBundle _bundle;
  Map<String, ReadingState> _states;

  static const maxBookmarkName = 60;

  static Map<String, ReadingState> _read(KeyValueStore store) {
    final raw = store.getString(StoreKeys.libraryReading);
    if (raw == null) return {};
    try {
      final json = (jsonDecode(raw) as Map).cast<String, Object?>();
      final docs = (json['docs']! as Map).cast<String, Object?>();
      return {
        for (final e in docs.entries)
          e.key: ReadingState.fromJson(
            (e.value! as Map).cast<String, Object?>(),
          ),
      };
    } on Object catch (e) {
      // Buzuq yozuv ilovani yiqitmaydi — o'qish holati boshidan.
      debugPrint('reading state unreadable: $e');
      return {};
    }
  }

  Future<void> _write() => _store.setString(
    StoreKeys.libraryReading,
    jsonEncode({
      'v': 1,
      'docs': {for (final e in _states.entries) e.key: e.value.toJson()},
    }),
  );

  static String _now() => DateTime.now().toUtc().toIso8601String();

  /// [itemId] uchun holat — faqat aynan shu fayl ([fileSha]) bo'yicha.
  ReadingState? stateOf(String itemId, String fileSha) {
    final s = _states[itemId];
    return s != null && s.fileSha == fileSha ? s : null;
  }

  /// O'qilgan materiallar — eng oxirgisi birinchi (bosh sahifadagi
  /// “Davom ettirish” uchun).
  List<MapEntry<String, ReadingState>> get recent =>
      _states.entries.toList()
        ..sort((a, b) => b.value.updatedAt.compareTo(a.value.updatedAt));

  MapEntry<String, ReadingState>? get lastRead => recent.firstOrNull;

  ReadingState _base(String itemId, String fileSha) =>
      stateOf(itemId, fileSha) ??
      ReadingState(fileSha: fileSha, lastPage: 1, updatedAt: _now());

  /// Joriy sahifani yozadi (o'quvchi har sahifa almashganda chaqiradi).
  Future<void> setLastPage(
    String itemId,
    String fileSha,
    int page, {
    int? pageCount,
  }) async {
    final current = _base(itemId, fileSha);
    final clamped = _clamp(page, pageCount ?? current.pageCount);
    if (stateOf(itemId, fileSha) != null &&
        current.lastPage == clamped &&
        (pageCount == null || current.pageCount == pageCount)) {
      return;
    }
    _states[itemId] = current.copyWith(
      lastPage: clamped,
      pageCount: pageCount,
      updatedAt: _now(),
    );
    notifyListeners();
    await _write();
  }

  /// Sahifaga xatcho'p qo'yadi; shu sahifada bo'lsa nomini yangilaydi.
  Future<ReadingBookmark> addBookmark(
    String itemId,
    String fileSha,
    int page, {
    String name = '',
  }) async {
    final current = _base(itemId, fileSha);
    var clean = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.length > maxBookmarkName) {
      clean = clean.substring(0, maxBookmarkName).trimRight();
    }
    final bookmark = ReadingBookmark(
      page: _clamp(page, current.pageCount),
      name: clean,
      createdAt: _now(),
    );
    final list = [
      for (final b in current.bookmarks)
        if (b.page != bookmark.page) b,
      bookmark,
    ]..sort((a, b) => a.page.compareTo(b.page));
    _states[itemId] = current.copyWith(bookmarks: list, updatedAt: _now());
    notifyListeners();
    await _write();
    return bookmark;
  }

  Future<void> removeBookmark(String itemId, String fileSha, int page) async {
    final current = stateOf(itemId, fileSha);
    if (current == null || current.bookmarkAt(page) == null) return;
    _states[itemId] = current.copyWith(
      bookmarks: [
        for (final b in current.bookmarks)
          if (b.page != page) b,
      ],
    );
    notifyListeners();
    await _write();
  }

  static int _clamp(int page, int? pageCount) {
    if (page < 1) return 1;
    if (pageCount != null && pageCount > 0 && page > pageCount) {
      return pageCount;
    }
    return page;
  }

  /// Ilova ichidagi faylni yuklaydi va katalogdagi hajm + sha256 bilan
  /// solishtiradi. Mos kelmasa — ochilmaydi.
  Future<Uint8List> loadFile(LibraryFileRef ref) async {
    final ByteData data;
    try {
      data = await _bundle.load(ref.path);
    } on Object catch (e) {
      throw LibraryFileException(LibraryFileFailure.missing, '$e');
    }
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    if (bytes.length != ref.size) {
      throw LibraryFileException(
        LibraryFileFailure.corrupted,
        'size ${bytes.length} != ${ref.size}',
      );
    }
    final digest = sha256.convert(bytes).toString();
    if (digest != ref.sha256.toLowerCase()) {
      throw const LibraryFileException(
        LibraryFileFailure.corrupted,
        'sha256 mismatch',
      );
    }
    return bytes;
  }

  /// “Lokal ma'lumotlarni o'chirish”dan keyin (ombor allaqachon tozalangan).
  void resetInMemory() {
    _states = {};
    notifyListeners();
  }
}
