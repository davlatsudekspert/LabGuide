import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/content/content_pack.dart';
import 'package:labguide/features/packs/pack_catalog.dart';
import 'package:labguide/features/packs/pack_downloader.dart';
import 'package:labguide/features/packs/packs_controller.dart';

final indexUri = Uri.parse('https://packs.test/packs/index.json');

/// Repo ichidagi `packs/` papkasini HTTP orqali xizmat qiladi (raw.github
/// o'rniga) — testlar aynan nashr qilinadigan fayllarni yuklaydi.
http.Client repoServer({
  Map<String, Uint8List Function(Uint8List)>? tamper,
  Set<String> fail = const {},
}) => MockClient((req) async {
  final path = req.url.path.replaceFirst('/', '');
  if (fail.contains(path)) return http.Response('boom', 500);
  final file = File(path);
  if (!file.existsSync()) return http.Response('not found', 404);
  var bytes = file.readAsBytesSync();
  final t = tamper?[path];
  if (t != null) bytes = t(bytes);
  return http.Response.bytes(bytes, 200);
});

Future<PackCatalogEntry> sampleEntry(http.Client client) async {
  final bytes = await PackDownloader(client).fetchCatalog(indexUri);
  return PackCatalog.parse(bytes, indexUri).entries.single;
}

void main() {
  group('published catalog (packs/)', () {
    test('index and the sample pack verify exactly like the app does', () {
      final index = File('packs/index.json').readAsBytesSync();
      final catalog = PackCatalog.parse(index, indexUri);
      final e = catalog.entries.single;
      expect(e.packId, 'sample-test');
      // Sinov paketi hech qachon tasdiqlangan deb e'lon qilinmaydi.
      expect(e.status, PackStatus.test);
      final dir = 'packs/${e.packId}/${e.version}';
      final verified = verifyPack(
        manifestBytes: File('$dir/manifest.json').readAsBytesSync(),
        files: {'pack.json': File('$dir/pack.json').readAsBytesSync()},
        expectedPackId: e.packId,
      );
      expect(verified.manifest.totalSize, e.size);
      expect(verified.manifest.licence, contains('TEST PACK'));
      expect(verified.pack.analytes.single.isReviewerApproved, isFalse);
    });

    test('catalog rejects the core pack, http and duplicates', () {
      Uint8List cat(List<Map<String, Object?>> packs) => Uint8List.fromList(
        utf8.encode(jsonEncode({'catalog_version': 1, 'packs': packs})),
      );
      final index = jsonDecode(
        File('packs/index.json').readAsStringSync(),
      ) as Map<String, Object?>;
      final base = (index['packs']! as List).first as Map<String, Object?>;
      for (final bad in [
        [
          {...base, 'pack_id': 'core'},
        ],
        [
          {...base, 'manifest': 'http://evil.test/m.json'},
        ],
        [base, base],
        [
          {...base, 'status': 'approved'},
        ],
        [
          {...base, 'size': 0},
        ],
      ]) {
        expect(
          () => PackCatalog.parse(cat(bad), indexUri),
          throwsFormatException,
          reason: '$bad',
        );
      }
    });
  });

  group('PackDownloader', () {
    test(
      'downloads with byte progress; installer verifies and installs',
      () async {
        final client = repoServer();
        final entry = await sampleEntry(client);
        final progress = <(int, int)>[];
        final pack = await PackDownloader(client)
            .download(entry, onProgress: (r, t) => progress.add((r, t)));
        expect(progress.first, (0, entry.size));
        expect(progress.last, (entry.size, entry.size));
        final root = Directory.systemTemp.createTempSync('packs');
        addTearDown(() => root.deleteSync(recursive: true));
        final v = await PackInstaller(root).install(
          packId: entry.packId,
          manifestBytes: pack.manifestBytes,
          files: pack.files,
        );
        expect(v.manifest.version, entry.version);
      },
    );

    test(
      'tampered bytes are rejected by SHA-256 and nothing installs',
      () async {
        final entry = await sampleEntry(repoServer());
        final dir = 'packs/${entry.packId}/${entry.version}';
        // Bir bayt almashtirilgan, hajm o'zgarmagan — faqat hash ushlaydi.
        final client = repoServer(
          tamper: {
            '$dir/pack.json': (b) => Uint8List.fromList(b)..[10] ^= 0x01,
          },
        );
        final pack = await PackDownloader(client).download(entry);
        final root = Directory.systemTemp.createTempSync('packs');
        addTearDown(() => root.deleteSync(recursive: true));
        final installer = PackInstaller(root);
        Object? error;
        try {
          await installer.install(
            packId: entry.packId,
            manifestBytes: pack.manifestBytes,
            files: pack.files,
          );
        } on Object catch (e) {
          error = e;
        }
        expect(error, isA<PackRejected>());
        expect(installFailure(error!).failure, PackDownloadFailure.integrity);
        expect(await installer.activeVersion(entry.packId), isNull);
      },
    );

    test('more bytes than the manifest declares stop the download', () async {
      final entry = await sampleEntry(repoServer());
      final dir = 'packs/${entry.packId}/${entry.version}';
      final client = repoServer(
        tamper: {
          '$dir/pack.json': (b) => Uint8List.fromList([...b, 32, 32]),
        },
      );
      await expectLater(
        PackDownloader(client).download(entry),
        throwsA(
          isA<PackDownloadException>().having(
            (e) => e.failure,
            'failure',
            PackDownloadFailure.integrity,
          ),
        ),
      );
    });

    test(
      'server errors and a catalog/manifest mismatch are reported',
      () async {
        final entry = await sampleEntry(repoServer());
        final dir = 'packs/${entry.packId}/${entry.version}';
        await expectLater(
          PackDownloader(repoServer(fail: {'$dir/pack.json'})).download(entry),
          throwsA(
            isA<PackDownloadException>().having(
              (e) => e.failure,
              'f',
              PackDownloadFailure.server,
            ),
          ),
        );
        final stale = PackCatalogEntry(
          packId: entry.packId,
          status: entry.status,
          version: 'other',
          manifestUri: entry.manifestUri,
          size: entry.size,
          languages: entry.languages,
          minSchema: entry.minSchema,
          title: entry.title,
          summary: entry.summary,
        );
        await expectLater(
          PackDownloader(repoServer()).download(stale),
          throwsA(
            isA<PackDownloadException>().having(
              (e) => e.failure,
              'f',
              PackDownloadFailure.integrity,
            ),
          ),
        );
      },
    );

    test('network errors map to "network"', () async {
      final entry = await sampleEntry(repoServer());
      final offline = MockClient(
        (_) => throw const SocketException('no route'),
      );
      await expectLater(
        PackDownloader(offline).download(entry),
        throwsA(
          isA<PackDownloadException>().having(
            (e) => e.failure,
            'f',
            PackDownloadFailure.network,
          ),
        ),
      );
    });

    test('cancel stops a slow download immediately', () async {
      final entry = await sampleEntry(repoServer());
      final release = Completer<void>();
      final slow = MockClient.streaming((req, _) async {
        final path = req.url.path.replaceFirst('/', '');
        final bytes = File(path).readAsBytesSync();
        if (!path.endsWith('pack.json')) {
          return http.StreamedResponse(Stream.value(bytes), 200);
        }
        Stream<List<int>> body() async* {
          yield bytes.sublist(0, 100);
          await release.future; // hech qachon kelmaydi — faqat bekor qilish
          yield bytes.sublist(100);
        }

        return http.StreamedResponse(body(), 200);
      });
      final token = PackCancelToken();
      final future = PackDownloader(slow).download(
        entry,
        cancel: token,
        onProgress: (r, _) {
          if (r >= 100) token.cancel();
        },
      );
      await expectLater(
        future,
        throwsA(
          isA<PackDownloadException>().having(
            (e) => e.failure,
            'f',
            PackDownloadFailure.cancelled,
          ),
        ),
      );
    });
  });

  group('PacksController', () {
    late Directory root;
    setUp(() => root = Directory.systemTemp.createTempSync('packs'));
    tearDown(() => root.deleteSync(recursive: true));

    PacksController make(http.Client client, KeyValueStore store) =>
        PacksController(
          store: store,
          downloader: PackDownloader(client),
          indexUri: indexUri,
          root: () async => root,
        );

    test(
      'install, survive restart offline from the saved catalog, remove',
      () async {
        final store = MemoryKeyValueStore();
        final c = make(repoServer(), store);
        await c.open();
        expect(c.catalogState, CatalogState.ready);
        final e = c.catalog!.entries.single;
        await c.install(e);
        expect(c.job(e.packId), isNull);
        expect(c.installed(e.packId)!.version, e.version);
        expect(c.installed(e.packId)!.cards, 1);
        expect(c.updateAvailable(e), isFalse);

        // Ilova qayta ochildi, internet yo'q: katalog saqlangan nusxadan,
        // o'rnatilgan paket diskdan qayta tekshirilib ko'rinadi.
        final offline = make(
          MockClient((_) => throw const SocketException('offline')),
          store,
        );
        await offline.open();
        expect(offline.catalogState, CatalogState.failed);
        expect(offline.catalogError, PackDownloadFailure.network);
        expect(offline.catalogFromCache, isTrue);
        expect(offline.installed(e.packId)!.version, e.version);

        await offline.remove(e.packId);
        expect(offline.installed(e.packId), isNull);
        expect(await PackInstaller(root).activeVersion(e.packId), isNull);
      },
    );

    test(
      'a failed update keeps the installed version; retry succeeds',
      () async {
        final store = MemoryKeyValueStore();
        final c = make(repoServer(), store);
        await c.open();
        final e = c.catalog!.entries.single;
        await c.install(e);
        // Katalogda yangi versiya: pack.json ichidagi content_version ham
        // yangi, manifest undan hisoblangan.
        final nextVersion = '${e.version}-next';
        final dir = 'packs/${e.packId}/${e.version}';
        final json = jsonDecode(
          File('$dir/pack.json').readAsStringSync(),
        ) as Map<String, Object?>;
        final pack = Uint8List.fromList(
          utf8.encode(jsonEncode({...json, 'content_version': nextVersion})),
        );
        final manifest = jsonDecode(
          File('$dir/manifest.json').readAsStringSync(),
        ) as Map<String, Object?>;
        final nextManifest = jsonEncode({
          ...manifest,
          'version': nextVersion,
          'files': [
            {
              'path': 'pack.json',
              'size': pack.length,
              'sha256': sha256.convert(pack).toString(),
            },
          ],
        });
        final next = PackCatalogEntry(
          packId: e.packId,
          status: e.status,
          version: nextVersion,
          manifestUri: Uri.parse('https://packs.test/next/manifest.json'),
          size: pack.length,
          languages: e.languages,
          minSchema: e.minSchema,
          title: e.title,
          summary: e.summary,
        );
        expect(c.updateAvailable(next), isTrue);
        var broken = true;
        final server = MockClient((req) async {
          if (req.url.path == '/next/manifest.json') {
            return http.Response.bytes(utf8.encode(nextManifest), 200);
          }
          if (req.url.path == '/next/pack.json') {
            return http.Response.bytes(
              broken ? (Uint8List.fromList(pack)..[5] ^= 1) : pack,
              200,
            );
          }
          return http.Response('nf', 404);
        });
        final c2 = PacksController(
          store: store,
          downloader: PackDownloader(server),
          indexUri: indexUri,
          root: () async => root,
        );
        await c2.install(next);
        expect(c2.job(e.packId)!.failure, PackDownloadFailure.integrity);
        // Buzuq yangilanish avvalgi o'rnatilgan versiyaga tegmadi.
        expect(await PackInstaller(root).activeVersion(e.packId), e.version);
        broken = false;
        await c2.install(next);
        expect(c2.job(e.packId), isNull);
        expect(await PackInstaller(root).activeVersion(e.packId), nextVersion);
        expect(c2.installed(e.packId)!.version, nextVersion);
      },
    );
  });
}
