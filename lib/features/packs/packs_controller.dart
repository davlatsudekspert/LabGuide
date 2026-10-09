import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../core/storage/kv_store.dart';
import '../content/content_pack.dart';
import 'pack_catalog.dart';
import 'pack_downloader.dart';

enum CatalogState { idle, loading, ready, failed }

/// Qurilmada o'rnatilgan (yuklab olingan) paket — diskdan qayta
/// tekshirilgan holda.
@immutable
class InstalledPack {
  const InstalledPack({
    required this.version,
    required this.size,
    required this.cards,
    required this.sources,
  });

  final String version;
  final int size;
  final int cards;
  final int sources;
}

/// Davom etayotgan yoki to'xtagan yuklash.
@immutable
class PackJob {
  const PackJob.downloading(this.received, this.total) : failure = null;
  const PackJob.failed(PackDownloadFailure this.failure)
    : received = 0,
      total = 0;

  final int received;
  final int total;
  final PackDownloadFailure? failure;

  bool get isRunning => failure == null;

  double? get fraction => total <= 0 ? null : (received / total).clamp(0, 1);
}

/// Yuklab olinadigan paketlar: katalog, yuklash (progress, bekor qilish,
/// qayta urinish), o'rnatish va yangilash.
///
/// Katalog oxirgi muvaffaqiyatli nusxasi qurilmada saqlanadi — internet
/// bo'lmasa ham o'rnatilgan paketlar va ularning holati ko'rinadi.
class PacksController extends ChangeNotifier {
  PacksController({
    required this._store,
    required this._downloader,
    required this.indexUri,
    required this._root,
  });

  final KeyValueStore _store;
  final PackDownloader _downloader;
  final Future<Directory> Function() _root;

  /// `packs/index.json` manzili.
  final Uri indexUri;

  PackInstaller? _installer;
  PackCatalog? _catalog;
  CatalogState _catalogState = CatalogState.idle;
  PackDownloadFailure? _catalogError;
  bool _catalogFromCache = false;
  final Map<String, InstalledPack> _installed = {};
  final Map<String, PackJob> _jobs = {};
  final Map<String, PackCancelToken> _tokens = {};

  PackCatalog? get catalog => _catalog;
  CatalogState get catalogState => _catalogState;
  PackDownloadFailure? get catalogError => _catalogError;

  /// Katalog tarmoqdan emas, oxirgi saqlangan nusxadan ko'rsatilmoqda.
  bool get catalogFromCache => _catalogFromCache;

  InstalledPack? installed(String packId) => _installed[packId];
  PackJob? job(String packId) => _jobs[packId];

  bool updateAvailable(PackCatalogEntry e) {
    final have = _installed[e.packId];
    return have != null && have.version != e.version;
  }

  Future<PackInstaller> _getInstaller() async =>
      _installer ??= PackInstaller(await _root());

  /// Ekran ochilganda: saqlangan katalog va o'rnatilganlar, keyin tarmoq.
  Future<void> open() async {
    if (_catalog == null) {
      final cached = _store.getString(StoreKeys.packsCatalog);
      if (cached != null) {
        try {
          _catalog = PackCatalog.parse(
            Uint8List.fromList(utf8.encode(cached)),
            indexUri,
          );
          _catalogFromCache = true;
        } on Object {
          await _store.remove(StoreKeys.packsCatalog);
        }
      }
      await _scanInstalled();
      notifyListeners();
    }
    if (_catalogState != CatalogState.loading) await refresh();
  }

  Future<void> refresh() async {
    _catalogState = CatalogState.loading;
    _catalogError = null;
    notifyListeners();
    try {
      final bytes = await _downloader.fetchCatalog(indexUri);
      final parsed = PackCatalog.parse(bytes, indexUri);
      _catalog = parsed;
      _catalogFromCache = false;
      _catalogState = CatalogState.ready;
      await _store.setString(StoreKeys.packsCatalog, utf8.decode(bytes));
      await _scanInstalled();
    } on PackDownloadException catch (e) {
      _catalogState = CatalogState.failed;
      _catalogError = e.failure;
    } on Object {
      // Buzuq katalog: tarmoq ishlagan, lekin javob noto'g'ri.
      _catalogState = CatalogState.failed;
      _catalogError = PackDownloadFailure.integrity;
    }
    notifyListeners();
  }

  Future<void> _scanInstalled() async {
    final entries = _catalog?.entries ?? const [];
    _installed.clear();
    // Hali hech narsa yuklanmagan — diskka murojaat shart emas.
    if (!(await _root()).existsSync()) return;
    final installer = await _getInstaller();
    for (final e in entries) {
      final active = await installer.loadActive(e.packId);
      if (active != null) {
        _installed[e.packId] = InstalledPack(
          version: active.manifest.version,
          size: active.manifest.totalSize,
          cards: active.pack.analytes.length,
          sources: active.pack.sources.length,
        );
      }
    }
  }

  /// Yuklab o'rnatadi (yoki yangilaydi). Xato bo'lsa avvalgi o'rnatilgan
  /// versiya o'zgarmaydi; “Qayta urinish” shu metodni yana chaqiradi.
  Future<void> install(PackCatalogEntry entry) async {
    if (_jobs[entry.packId]?.isRunning ?? false) return;
    final token = PackCancelToken();
    _tokens[entry.packId] = token;
    _jobs[entry.packId] = PackJob.downloading(0, entry.size);
    notifyListeners();
    try {
      final downloaded = await _downloader.download(
        entry,
        cancel: token,
        onProgress: (received, total) {
          if (token.isCancelled) return;
          _jobs[entry.packId] = PackJob.downloading(received, total);
          notifyListeners();
        },
      );
      if (token.isCancelled) {
        throw const PackDownloadException(PackDownloadFailure.cancelled);
      }
      final installer = await _getInstaller();
      final VerifiedPack verified;
      try {
        verified = await installer.install(
          packId: entry.packId,
          manifestBytes: downloaded.manifestBytes,
          files: downloaded.files,
        );
      } on Object catch (e) {
        throw installFailure(e);
      }
      _installed[entry.packId] = InstalledPack(
        version: verified.manifest.version,
        size: verified.manifest.totalSize,
        cards: verified.pack.analytes.length,
        sources: verified.pack.sources.length,
      );
      _jobs.remove(entry.packId);
    } on PackDownloadException catch (e) {
      if (e.failure == PackDownloadFailure.cancelled) {
        _jobs.remove(entry.packId);
      } else {
        _jobs[entry.packId] = PackJob.failed(e.failure);
        debugPrint('Pack ${entry.packId} failed: $e');
      }
    } finally {
      _tokens.remove(entry.packId);
      notifyListeners();
    }
  }

  void cancel(String packId) => _tokens[packId]?.cancel();

  /// Xato xabarini yopish (qayta urinmasdan).
  void dismissFailure(String packId) {
    if (_jobs[packId]?.failure != null) {
      _jobs.remove(packId);
      notifyListeners();
    }
  }

  Future<void> remove(String packId) async {
    cancel(packId);
    await (await _getInstaller()).remove(packId);
    _installed.remove(packId);
    _jobs.remove(packId);
    notifyListeners();
  }

  /// “Lokal ma'lumotlarni o'chirish”: yuklangan barcha paketlar ham.
  Future<void> removeAll() async {
    for (final t in _tokens.values) {
      t.cancel();
    }
    final root = await _root();
    if (root.existsSync()) await root.delete(recursive: true);
    _installer = null;
    _installed.clear();
    _jobs.clear();
    _catalog = null;
    _catalogState = CatalogState.idle;
    notifyListeners();
  }
}
