// “Qanday foydalaniladi?” videolari: ro‘yxat tekshiruvchisi (videos.json),
// til bo‘yicha tanlash (boshqa tilga jim o‘tilmaydi), tarmoq tekshiruvi
// (internet yo‘q / fayl yo‘q / hajm boshqa) va make_manifest.py namunasi.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labguide/features/howto/howto_registry.dart';
import 'package:labguide/features/howto/howto_videos.dart';

const _host = 'https://videos.labguide-test.uz/howto/v1';
final _sha = 'ab' * 32;

Map<String, Object?> _entry({
  String section = 'qc',
  String lang = 'uz',
  Object? url,
  Object? bytes = 1256116,
  Object? seconds = 46.0,
  Object? sha256,
  Object? start,
  bool dropBytes = false,
  bool dropSha = false,
}) => {
  'section': section,
  'lang': lang,
  'url': url ?? '$_host/02_sifat_nazorati_$lang.0e953a65.mp4',
  if (!dropBytes) 'bytes': bytes,
  'seconds': seconds,
  if (!dropSha) 'sha256': sha256 ?? _sha,
  'start_seconds': ?start,
};

String _doc(List<Map<String, Object?>> videos, {Object? approval = 'D-99'}) =>
    jsonEncode({
      'schema_version': 1,
      'owner_approval': approval,
      'videos': videos,
    });

void _rejects(String json, Pattern reason) => expect(
  () => HowToVideoCatalog.parse(json),
  throwsA(
    isA<FormatException>().having((e) => e.message, 'message', contains(reason)),
  ),
);

HowToVideo _video({int bytes = 1000, String url = '$_host/a_uz.mp4'}) =>
    HowToVideo(url: Uri.parse(url), bytes: bytes, seconds: 40, sha256: _sha);

/// Faqat [kHowToVideosAsset] ni beradigan bundle.
class _OneFileBundle extends CachingAssetBundle {
  _OneFileBundle(this.text);

  final String? text;

  @override
  Future<ByteData> load(String key) async {
    if (key != kHowToVideosAsset || text == null) {
      throw StateError('no asset $key');
    }
    return ByteData.sublistView(utf8.encode(text!));
  }
}

void main() {
  group('ilova bilan keladigan videos.json', () {
    test('sxemaga mos va hozircha bo‘sh — hech bir bo‘limda video yo‘q', () {
      final c = HowToVideoCatalog.parse(
        File(kHowToVideosAsset).readAsStringSync(),
      );
      expect(c.isEmpty, isTrue);
      expect(c.ownerApproval, isNull);
      for (final s in HowToSection.values) {
        expect(c.forSection(s), isEmpty, reason: s.id);
      }
    });
  });

  group('tekshiruvchi qabul qiladi', () {
    test('uch til, umumiy video va start_seconds', () {
      final c = HowToVideoCatalog.parse(
        _doc([
          for (final l in ['uz', 'ru', 'en']) _entry(lang: l),
          for (final s in ['cytology', 'histology'])
            _entry(
              section: s,
              url: '$_host/10_boshqa_funksiyalar_uz.40df0dc7.mp4',
              bytes: 1810045,
              seconds: 56,
              start: s == 'cytology' ? 18.0 : 32,
            ),
        ]),
      );
      expect(c.length, 5);
      expect(c.ownerApproval, 'D-99');
      final qc = c.forSection(HowToSection.qc);
      expect(qc.keys, unorderedEquals(['uz', 'ru', 'en']));
      expect(qc['ru']!.url.toString(), contains('_ru.'));
      expect(qc['uz']!.bytes, 1256116);
      expect(qc['uz']!.seconds, 46.0);
      expect(qc['uz']!.startSeconds, isNull);
      expect(c.forSection(HowToSection.histology)['uz']!.startSeconds, 32.0);
      expect(c.forSection(HowToSection.calibration), isEmpty);
    });

    test('bo‘sh ro‘yxat qarorsiz ham to‘g‘ri', () {
      expect(HowToVideoCatalog.parse(_doc([], approval: null)).isEmpty, isTrue);
    });
  });

  group('tekshiruvchi rad etadi', () {
    test('noma’lum bo‘lim id', () {
      _rejects(_doc([_entry(section: 'pro')]), 'unknown section');
      _rejects(_doc([_entry(section: 'QC')]), 'unknown section');
      _rejects(_doc([_entry(section: 'testlar')]), 'unknown section');
    });

    test('https bo‘lmagan yoki yaroqsiz manzil', () {
      for (final url in [
        'http://videos.labguide-test.uz/qc_uz.mp4',
        'ftp://videos.labguide-test.uz/qc_uz.mp4',
        'file:///sdcard/qc_uz.mp4',
        '//videos.labguide-test.uz/qc_uz.mp4',
        'qc_uz.mp4',
        'https://user:pw@videos.labguide-test.uz/qc_uz.mp4',
        'https://videos.labguide-test.uz/qc_uz.mp4#t=10',
        42,
      ]) {
        _rejects(_doc([_entry(url: url)]), 'https');
      }
    });

    test('joy egallovchi (haqiqiy bo‘lmagan) domen', () {
      for (final host in [
        'NEEDS-OWNER-HOST.invalid',
        'example.com',
        'cdn.example.org',
        'localhost',
        'videos.test',
      ]) {
        _rejects(
          _doc([_entry(url: 'https://$host/qc_uz.mp4')]),
          'placeholder host',
        );
      }
    });

    test('til fayli hajmi yoki sha256 yo‘q / noto‘g‘ri', () {
      _rejects(_doc([_entry(dropBytes: true)]), 'bytes');
      _rejects(_doc([_entry(bytes: 0)]), 'bytes');
      _rejects(_doc([_entry(bytes: '1256116')]), 'bytes');
      _rejects(_doc([_entry(bytes: 1.5)]), 'bytes');
      _rejects(_doc([_entry(dropSha: true)]), 'sha256');
      _rejects(_doc([_entry(sha256: 'AB' * 32)]), 'sha256');
      _rejects(_doc([_entry(sha256: 'ab' * 31)]), 'sha256');
      _rejects(_doc([_entry(seconds: 0)]), 'seconds');
      _rejects(_doc([_entry(seconds: null)]), 'seconds');
      _rejects(_doc([_entry(start: 46.0)]), 'start_seconds');
      _rejects(_doc([_entry(start: -1)]), 'start_seconds');
    });

    test('takrorlangan bo‘lim/til', () {
      _rejects(_doc([_entry(), _entry()]), 'duplicate qc/uz');
    });

    test('bitta fayl turli hajm/hash bilan', () {
      _rejects(
        _doc([
          _entry(section: 'cytology', url: '$_host/x.mp4'),
          _entry(section: 'histology', url: '$_host/x.mp4', bytes: 7),
        ]),
        'other size/hash',
      );
    });

    test('noma’lum til, noma’lum maydon, sxema versiyasi, JSON emas', () {
      _rejects(_doc([_entry(lang: 'kk')]), 'unknown lang');
      _rejects(_doc([_entry()..['title'] = 'x']), 'unknown field title');
      _rejects(
        jsonEncode({'schema_version': 2, 'owner_approval': null, 'videos': []}),
        'schema_version',
      );
      _rejects(
        jsonEncode({
          'schema_version': 1,
          'owner_approval': null,
          'videos': [],
          'base_url': 'x',
        }),
        'unknown field base_url',
      );
      _rejects('{', 'not JSON');
      _rejects('[]', 'not an object');
    });

    test('egasi qarorisiz video yo‘q (owner_approval = D-NN)', () {
      _rejects(_doc([_entry()], approval: null), 'owner_approval');
      _rejects(_doc([_entry()], approval: 'yes'), 'owner_approval');
      _rejects(_doc([_entry()], approval: ''), 'owner_approval');
    });
  });

  group('til bo‘yicha tanlash', () {
    final qc = HowToRegistry.of(HowToSection.qc);

    test('ilova tilidagi video tanlanadi', () {
      final c = qc.withVideos({
        'uz': _video(url: '$_host/uz.mp4'),
        'ru': _video(url: '$_host/ru.mp4'),
        'en': _video(url: '$_host/en.mp4'),
      });
      for (final l in ['uz', 'ru', 'en']) {
        expect(c.videoFor(l)!.url.path, endsWith('/$l.mp4'));
      }
    });

    test('ilova tilida yo‘q — boshqa tilga jim o‘tilmaydi', () {
      final c = qc.withVideos({'uz': _video()});
      expect(c.videoFor('uz'), isNotNull);
      expect(c.videoFor('ru'), isNull);
      expect(c.videoFor('en'), isNull);
    });

    test('video umuman yo‘q — null; matn o‘zgarmaydi', () {
      expect(qc.videoFor('uz'), isNull);
      final c = qc.withVideos({'uz': _video()});
      expect(c.steps, same(qc.steps));
      expect(c.routes, same(qc.routes));
    });
  });

  group('HowToVideoService', () {
    HowToVideoService service(http.Client client, {String? json}) =>
        HowToVideoService(
          bundle: _OneFileBundle(json ?? _doc([], approval: null)),
          client: client,
          timeout: const Duration(milliseconds: 200),
        );

    test('ro‘yxat yuklanadi va bo‘limga qo‘shiladi', () async {
      final s = service(
        MockClient((_) async => http.Response('', 500)),
        json: _doc([_entry()]),
      );
      expect(s.catalog.isEmpty, isTrue);
      await s.ensureLoaded();
      expect(s.contentFor(HowToSection.qc).videoFor('uz'), isNotNull);
      expect(s.contentFor(HowToSection.qc).videoFor('ru'), isNull);
      expect(s.contentFor(HowToSection.cytology).videos, isEmpty);
    });

    test('buzuq yoki yo‘q fayl — bo‘sh ro‘yxat, xato chiqmaydi', () async {
      for (final json in ['{', _doc([_entry()], approval: null)]) {
        final s = service(MockClient((_) async => http.Response('', 200)),
            json: json);
        expect((await s.ensureLoaded()).isEmpty, isTrue);
        expect(s.contentFor(HowToSection.qc).videos, isEmpty);
      }
      final missing = HowToVideoService(
        bundle: _OneFileBundle(null),
        client: MockClient((_) async => http.Response('', 200)),
      );
      expect((await missing.ensureLoaded()).isEmpty, isTrue);
    });

    test('probe: HEAD, hajm mos — ok', () async {
      final seen = <String>[];
      final s = service(
        MockClient((req) async {
          seen.add('${req.method} ${req.url}');
          return http.Response('', 200, headers: {'content-length': '1000'});
        }),
      );
      expect(await s.probe(_video()), HowToVideoReach.ok);
      expect(seen, ['HEAD $_host/a_uz.mp4']);
    });

    test('probe: server hajmni aytmasa ham ok', () async {
      final s = service(MockClient((_) async => http.Response('', 204)));
      expect(await s.probe(_video()), HowToVideoReach.ok);
    });

    test('probe: internet yo‘q / uzildi / javob yo‘q — offline', () async {
      final failures = <Future<http.Response> Function()>[
        () => throw const SocketException('Failed host lookup'),
        () => throw http.ClientException('Connection closed'),
        () => Completer<http.Response>().future,
      ];
      for (final f in failures) {
        final s = service(MockClient((_) => f()));
        expect(await s.probe(_video()), HowToVideoReach.offline);
      }
    });

    test('probe: 404 / 500 yoki hajm boshqa — unavailable', () async {
      for (final r in [
        http.Response('', 404),
        http.Response('', 503),
        http.Response('', 200, headers: {'content-length': '999'}),
      ]) {
        final s = service(MockClient((_) async => r));
        expect(await s.probe(_video()), HowToVideoReach.unavailable);
      }
    });
  });

  group('tool/video/make_manifest.py namunasi (docs/video)', () {
    final sample = File('docs/video/videos.sample.json');

    test('16 bo‘lim × uz/ru/en, umumiy videoda start_seconds', () {
      final json = jsonDecode(sample.readAsStringSync()) as Map;
      final videos = (json['videos'] as List).cast<Map<String, Object?>>();
      expect(videos, hasLength(HowToSection.values.length * 3));
      expect(json['owner_approval'], isNull);
      for (final s in HowToSection.values) {
        final langs = [
          for (final v in videos)
            if (v['section'] == s.id) v['lang'],
        ];
        expect(langs, ['uz', 'ru', 'en'], reason: s.id);
      }
      for (final v in videos) {
        final url = v['url'] as String;
        expect(url, contains('_${v['lang']}.'), reason: url);
        final shared = url.contains('10_boshqa_funksiyalar');
        expect(v.containsKey('start_seconds'), shared, reason: url);
      }
    });

    test('joy egallovchi manzil bilan ilovaga tushmaydi; haqiqiy hosting '
        'va qaror bilan — sxemaga to‘liq mos', () {
      final text = sample.readAsStringSync();
      _rejects(text, 'owner_approval');
      final json = jsonDecode(text) as Map<String, Object?>;
      _rejects(jsonEncode({...json, 'owner_approval': 'D-99'}), 'placeholder');
      final hosted = text.replaceAll(
        'https://NEEDS-OWNER-HOST.invalid/labguide/howto/v1',
        _host,
      );
      final c = HowToVideoCatalog.parse(
        jsonEncode({
          ...(jsonDecode(hosted) as Map<String, Object?>),
          'owner_approval': 'D-99',
        }),
      );
      expect(c.length, 48);
      for (final s in HowToSection.values) {
        for (final l in ['uz', 'ru', 'en']) {
          final v = c.forSection(s)[l]!;
          expect(v.bytes, inInclusiveRange(500000, 3000000), reason: '$s $l');
          expect(v.seconds, inInclusiveRange(20, 90), reason: '$s $l');
        }
      }
    });
  });
}
