import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../content/content_model.dart';
import '../content/content_pack.dart';
import 'pack_catalog.dart';

/// Yuklash nima sababdan to'xtagani — foydalanuvchiga tushunarli xabar
/// shu bo'yicha tanlanadi.
enum PackDownloadFailure {
  /// Internet yo'q, ulanish uzildi yoki javob kelmadi.
  network,

  /// Server xato qaytardi (masalan, 404 yoki 500).
  server,

  /// Fayl manifestda e'lon qilinganidan katta yoki kalta, yoki hash mos
  /// emas — buzilgan yoki almashtirilgan paket.
  integrity,

  /// Paket bu ilova versiyasi o'qiy olmaydigan sxemada.
  incompatible,

  /// Diskka yozib bo'lmadi.
  storage,

  cancelled,
}

class PackDownloadException implements Exception {
  const PackDownloadException(this.failure, [this.detail]);

  final PackDownloadFailure failure;

  /// Faqat log uchun.
  final String? detail;

  @override
  String toString() => 'PackDownloadException(${failure.name}: $detail)';
}

/// Yuklashni bekor qilish belgisi (UI dagi “Bekor qilish” tugmasi).
class PackCancelToken {
  final _cancelled = Completer<void>();

  bool get isCancelled => _cancelled.isCompleted;

  /// Bekor qilinganda yakunlanadi — kutilayotgan oqim darhol to'xtaydi.
  Future<void> get whenCancelled => _cancelled.future;

  void cancel() {
    if (!_cancelled.isCompleted) _cancelled.complete();
  }
}

/// Yuklangan, lekin hali o'rnatilmagan paket (o'rnatuvchi uni yana
/// tekshiradi).
class DownloadedPack {
  const DownloadedPack(this.manifestBytes, this.files);

  final Uint8List manifestBytes;
  final Map<String, Uint8List> files;
}

/// Katalogdagi paketni HTTP orqali yuklaydi: manifest → fayllar.
///
/// Har fayl manifestdagi hajm bilan cheklanadi (ortiqcha bayt kelsa darhol
/// to'xtaydi), hash esa [PackInstaller] da tekshiriladi. Progress — bayt
/// bo'yicha, manifestdagi umumiy hajmga nisbatan.
class PackDownloader {
  PackDownloader(
    this._client, {
    this.requestTimeout = const Duration(seconds: 30),
    this.idleTimeout = const Duration(seconds: 30),
  });

  final http.Client _client;
  final Duration requestTimeout;
  final Duration idleTimeout;

  static const _maxManifestBytes = 64 * 1024;

  Future<Uint8List> fetchCatalog(Uri uri, {PackCancelToken? cancel}) =>
      _get(uri, maxBytes: PackCatalog.maxBytes, cancel: cancel);

  Future<DownloadedPack> download(
    PackCatalogEntry entry, {
    void Function(int received, int total)? onProgress,
    PackCancelToken? cancel,
  }) async {
    if (entry.minSchema > kSupportedContentSchema) {
      throw const PackDownloadException(PackDownloadFailure.incompatible);
    }
    final manifestBytes = await _get(
      entry.manifestUri,
      maxBytes: _maxManifestBytes,
      cancel: cancel,
    );
    final PackManifest manifest;
    try {
      manifest = PackManifest.fromJson(
        (jsonDecode(utf8.decode(manifestBytes)) as Map).cast<String, Object?>(),
      );
    } on Object catch (e) {
      throw PackDownloadException(PackDownloadFailure.integrity, '$e');
    }
    if (manifest.packId != entry.packId ||
        manifest.version != entry.version ||
        manifest.totalSize != entry.size) {
      // Katalog va manifest bir-biriga mos emas — eskirgan kesh yoki
      // almashtirilgan fayl. Yuklash boshlanmaydi.
      throw const PackDownloadException(
        PackDownloadFailure.integrity,
        'catalog and manifest disagree',
      );
    }
    if (manifest.minSchema > kSupportedContentSchema) {
      throw const PackDownloadException(PackDownloadFailure.incompatible);
    }
    final total = manifest.totalSize;
    var done = 0;
    onProgress?.call(0, total);
    final files = <String, Uint8List>{};
    for (final f in manifest.files) {
      final bytes = await _get(
        entry.manifestUri.resolve(f.path),
        maxBytes: f.size,
        cancel: cancel,
        onChunk: (n) {
          done += n;
          onProgress?.call(done, total);
        },
      );
      if (bytes.length != f.size) {
        throw PackDownloadException(
          PackDownloadFailure.integrity,
          '${f.path}: ${bytes.length} != ${f.size}',
        );
      }
      files[f.path] = bytes;
    }
    return DownloadedPack(manifestBytes, files);
  }

  /// GET, [maxBytes] dan oshsa to'xtaydi. Bekor qilish va jim qolgan
  /// ulanish (idle timeout) darhol uziladi.
  Future<Uint8List> _get(
    Uri uri, {
    required int maxBytes,
    PackCancelToken? cancel,
    void Function(int bytes)? onChunk,
  }) async {
    if (cancel?.isCancelled ?? false) {
      throw const PackDownloadException(PackDownloadFailure.cancelled);
    }
    final http.StreamedResponse response;
    try {
      final send = _client.send(http.Request('GET', uri));
      response = await Future.any([
        send,
        if (cancel != null)
          cancel.whenCancelled.then<http.StreamedResponse>(
            (_) => throw const PackDownloadException(
              PackDownloadFailure.cancelled,
            ),
          ),
      ]).timeout(requestTimeout);
    } on PackDownloadException {
      rethrow;
    } on Object catch (e) {
      throw PackDownloadException(PackDownloadFailure.network, '$e');
    }
    if (response.statusCode != 200) {
      unawaited(response.stream.listen(null).cancel());
      throw PackDownloadException(
        PackDownloadFailure.server,
        'HTTP ${response.statusCode} $uri',
      );
    }
    final declared = response.contentLength;
    if (declared != null && declared > maxBytes) {
      unawaited(response.stream.listen(null).cancel());
      throw PackDownloadException(
        PackDownloadFailure.integrity,
        'declared $declared > $maxBytes',
      );
    }
    final builder = BytesBuilder(copy: false);
    final done = Completer<Uint8List>();
    late final StreamSubscription<List<int>> sub;
    Timer? idle;
    void fail(PackDownloadException e) {
      idle?.cancel();
      if (done.isCompleted) return;
      unawaited(sub.cancel());
      done.completeError(e);
    }

    // Jim qolgan ulanish: har bo'lak kelganda qayta boshlanadigan taymer
    // (Stream.timeout o'rniga — u soxta vaqtli testlarda oqim oxirini
    // yetkazmaydi).
    void armIdle() {
      idle?.cancel();
      idle = Timer(
        idleTimeout,
        () => fail(
          const PackDownloadException(PackDownloadFailure.network, 'idle'),
        ),
      );
    }

    armIdle();
    sub = response.stream.listen(
      (chunk) {
        if (builder.length + chunk.length > maxBytes) {
          fail(
            PackDownloadException(
              PackDownloadFailure.integrity,
              'more than $maxBytes bytes from $uri',
            ),
          );
          return;
        }
        armIdle();
        builder.add(chunk);
        onChunk?.call(chunk.length);
      },
      onError: (Object e) => fail(
        e is PackDownloadException
            ? e
            : PackDownloadException(PackDownloadFailure.network, '$e'),
      ),
      onDone: () {
        idle?.cancel();
        if (!done.isCompleted) done.complete(builder.takeBytes());
      },
      cancelOnError: true,
    );
    if (cancel != null) {
      unawaited(
        cancel.whenCancelled.then(
          (_) =>
              fail(const PackDownloadException(PackDownloadFailure.cancelled)),
        ),
      );
    }
    return done.future;
  }
}

/// O'rnatuvchi xatosini yuklash xatosi turiga aylantiradi.
PackDownloadException installFailure(Object e) => switch (e) {
  PackDownloadException() => e,
  PackRejected(:final reason) when reason.contains('schema') =>
    PackDownloadException(PackDownloadFailure.incompatible, reason),
  PackRejected(:final reason) => PackDownloadException(
    PackDownloadFailure.integrity,
    reason,
  ),
  FileSystemException() => PackDownloadException(
    PackDownloadFailure.storage,
    '$e',
  ),
  _ => PackDownloadException(PackDownloadFailure.storage, '$e'),
};
