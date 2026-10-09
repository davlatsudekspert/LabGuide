import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/microscopy/microscopy_atlas.dart';
import 'package:labguide/features/microscopy/microscopy_controller.dart';
import 'package:labguide/features/microscopy/microscopy_quiz.dart';

Map<String, Object?> _raw() =>
    (jsonDecode(File('assets/microscopy/atlas.json').readAsStringSync()) as Map)
        .cast<String, Object?>();

/// Birinchi rasm yozuvini o'zgartirib, atlasni qayta o'qish.
MicroAtlas _patched(void Function(Map<String, Object?> image) patch) {
  final raw = _raw();
  final images = raw['images']! as List;
  patch((images.first as Map).cast<String, Object?>());
  return MicroAtlas.fromJson(raw);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MicroAtlas atlas;

  setUpAll(() => atlas = MicroAtlas.fromJson(_raw()));

  group('atlas fayli va validator', () {
    test(
      'bo‘limlar: siydik, qon surtmasi, parazitlar — talab qilingan turlar',
      () {
        expect(atlas.sections.map((s) => s.id), [
          'urine',
          'blood',
          'parasites',
        ]);
        final ids = {for (final e in atlas.entities) e.id};
        expect(
          ids,
          containsAll([
            'urine-rbc',
            'urine-wbc',
            'urine-rte',
            'cast-hyaline',
            'crystal-caox',
            'neutrophil',
            'lymphocyte',
            'monocyte',
            'eosinophil',
            'basophil',
            'acanthocyte',
            'malaria-thin',
            'malaria-thick',
          ]),
        );
        for (final s in atlas.sections) {
          expect(atlas.imagesInSection(s.id), isNotEmpty, reason: s.id);
        }
      },
    );

    test('har rasm: ruxsat etilgan litsenziya, muallif, manba, asl izoh', () {
      for (final i in atlas.images) {
        expect(microLicenses[i.license], i.licenseUrl, reason: i.id);
        expect(i.license, isNot(contains('NC')));
        expect(i.license, isNot(contains('ND')));
        expect(i.author.trim(), isNotEmpty, reason: i.id);
        expect(i.sourcePage, startsWith('https://'), reason: i.id);
        expect(i.caption.text.trim(), isNotEmpty, reason: i.id);
        if (i.provider == MicroProvider.cdcPhil) {
          expect(i.author, startsWith('CDC'), reason: i.id);
          expect(i.termsQuote, contains('credit CDC'), reason: i.id);
        }
      }
    });

    test('fayllar mavjud, sha256 va o‘lcham JSON bilan mos; jami ≤ 6 MB', () {
      expect(atlas.missingAssets((p) => File(p).existsSync()), isEmpty);
      final raw = _raw();
      var total = 0;
      for (final r in raw['images']! as List) {
        final m = r as Map;
        final bytes = File(m['asset'] as String).readAsBytesSync();
        expect(sha256.convert(bytes).toString(), m['sha256'], reason: '$m');
        expect(bytes.length, m['bytes']);
        total += bytes.length;
      }
      expect(total, lessThan(6300000));
      for (final i in atlas.images) {
        expect(math.max(i.width, i.height), lessThanOrEqualTo(atlas.maxSide));
      }
    });

    test('pubspec atlas papkalarini e’lon qilgan', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('- assets/microscopy/'));
      expect(pubspec, contains('- assets/microscopy/img/'));
    });

    test('rasmsiz tur “hali yo‘q” sababi bilan, rasmlisi sababsiz', () {
      final gaps = [
        for (final e in atlas.entities)
          if (e.gap != null) e.id,
      ];
      expect(gaps, contains('urine-squamous'));
      for (final id in gaps) {
        expect(atlas.imagesOf(id), isEmpty);
        expect(atlas.entity(id)!.quiz, isFalse);
      }
    });

    test('NC litsenziya rad etiladi', () {
      expect(
        () => _patched((i) {
          i['license'] = 'CC BY-NC 4.0';
          i['license_url'] = 'https://creativecommons.org/licenses/by-nc/4.0/';
        }),
        throwsFormatException,
      );
    });

    test('litsenziya havolasi mos kelmasa rad etiladi', () {
      expect(
        () => _patched((i) => i['license_url'] = 'https://example.com/'),
        throwsFormatException,
      );
    });

    test('muallif bo‘sh bo‘lsa rad etiladi', () {
      expect(() => _patched((i) => i['author'] = ' '), throwsFormatException);
    });

    test('kesilgan (nisbati o‘zgargan) rasm rad etiladi', () {
      expect(
        () => _patched((i) => i['size'] = [1600, 900]),
        throwsFormatException,
      );
    });

    test('CDC yozuvi shartlarsiz rad etiladi', () {
      final raw = _raw();
      final cdc = (raw['images']! as List)
          .cast<Map<String, Object?>>()
          .firstWhere((i) => i['provider'] == 'cdc_phil');
      cdc.remove('terms_quote');
      expect(() => MicroAtlas.fromJson(raw), throwsFormatException);
    });

    test('Commons rasmida muallif havolasi bor (https)', () {
      for (final i in atlas.images) {
        if (i.provider == MicroProvider.commons) {
          expect(i.authorUrl, startsWith('https://'), reason: i.id);
        }
      }
      expect(
        () => _patched((i) => i.remove('author_url')),
        throwsFormatException,
      );
    });

    test('audit 2026-10-09: “manba izohi bo‘yicha” rasmlar mashqda yo‘q', () {
      final bySource = {
        for (final i in atlas.images)
          if (i.labelNote != null) i.id,
      };
      expect(bySource, {'u-rte-1', 'u-cryst-caox-1', 'b-eos-1'});
      for (final id in bySource) {
        expect(atlas.image(id)!.quizCue, isNull, reason: id);
        expect(atlas.image(id)!.labelNote!.of('uz'), contains('manba'));
      }
      final quiz = atlas.quizImages().map((i) => i.id);
      expect(quiz, isNot(contains('b-eos-1')));
      final raw = _raw();
      final eos = (raw['images']! as List)
          .cast<Map<String, Object?>>()
          .firstWhere((i) => i['id'] == 'b-eos-1');
      eos['quiz'] = 'arrowhead';
      expect(() => MicroAtlas.fromJson(raw), throwsFormatException);
    });

    test('mashqqa yaroqsiz turga mashq rasmi bo‘lmaydi', () {
      final raw = _raw();
      final epi = (raw['images']! as List)
          .cast<Map<String, Object?>>()
          .firstWhere((i) => i['entity'] == 'urine-epi-mixed');
      epi['quiz'] = 'field';
      expect(() => MicroAtlas.fromJson(raw), throwsFormatException);
    });
  });

  group('qidiruv (uz/ru/en)', () {
    List<String> ids(String q) => [for (final e in atlas.search(q)) e.id];

    test('uch tilda va lotin/kirillda topadi', () {
      expect(ids('neytrofil').first, 'neutrophil');
      expect(ids('нейтрофил').first, 'neutrophil');
      expect(ids('Neutrophil').first, 'neutrophil');
      expect(ids('оксалат'), contains('crystal-caox'));
      expect(ids('bezgak'), containsAll(['malaria-thin', 'malaria-thick']));
      expect(ids('qalin surtma').first, 'malaria-thick');
    });

    test('rasmsiz turlar ham chiqadi (halol “hali yo‘q”)', () {
      expect(ids('squamous'), ['urine-squamous']);
      expect(ids('yassi'), contains('urine-squamous'));
    });

    test('apostrof va registr farqi e’tiborsiz', () {
      expect(ids("cho'kma"), isNotEmpty);
      expect(ids('CHO‘KMA'), ids("cho'kma"));
    });

    test('bo‘sh yoki mos kelmaydigan so‘rov', () {
      expect(atlas.search('  '), isEmpty);
      expect(atlas.search('zzzz'), isEmpty);
    });
  });

  group('“Bu nima?” mashqi', () {
    test(
      'har savol: 4 xil variant, to‘g‘ri javob ichida, faqat atlas nomlari',
      () {
        final rnd = math.Random(7);
        final quizIds = {
          for (final e in atlas.entities)
            if (e.quiz) e.id,
        };
        for (final img in atlas.quizImages()) {
          final q = buildMicroQuestion(atlas, img, rnd);
          expect(q.options.length, 4);
          expect(q.options.map((e) => e.id).toSet().length, 4);
          expect(q.answer.id, img.entityId);
          for (final o in q.options) {
            expect(quizIds, contains(o.id));
          }
        }
      },
    );

    test('chalg‘ituvchilar avval shu bo‘limdan', () {
      final img = atlas.image('u-cryst-uric-1')!;
      final q = buildMicroQuestion(atlas, img, math.Random(1));
      for (final o in q.options) {
        expect(atlas.sectionOf(o).id, 'urine');
      }
    });

    test('aralash maydon va jurnal paneli mashqqa kirmaydi', () {
      final quiz = atlas.quizImages().map((i) => i.id);
      expect(quiz, isNot(contains('u-epi-1')));
      expect(quiz, isNot(contains('u-cast-panel-1')));
    });

    test('raund: javob bir marta, seriya, xatolar, tugash', () {
      final s = MicroQuizSession.build(
        atlas,
        sectionId: 'blood',
        random: math.Random(3),
      );
      expect(s.questions.length, atlas.quizImages(sectionId: 'blood').length);
      expect(s.questions.length, lessThanOrEqualTo(10));
      s.next(); // javobsiz o'tib bo'lmaydi
      expect(s.index, 0);
      expect(s.answer(s.current.correctIndex), isTrue);
      expect(s.answer((s.current.correctIndex + 1) % 4), isFalse);
      expect(s.streak, 1);
      s.next();
      s.answer(s.current.correctIndex);
      expect(s.streak, 2);
      s.next();
      final wrong = (s.current.correctIndex + 1) % 4;
      s.answer(wrong);
      expect(s.streak, 0);
      expect(s.bestStreak, 2);
      expect(s.mistakes.single.$2, s.current.options[wrong]);
      while (!s.finished) {
        if (!s.answered) s.answer(s.current.correctIndex);
        s.next();
      }
      expect(s.correctCount, s.questions.length - 1);
    });

    test('xatolarni qayta ishlash — faqat berilgan rasmlar', () {
      final s = MicroQuizSession.build(
        atlas,
        only: ['b-baso-1', 'p-mal-thick-1'],
        random: math.Random(2),
      );
      expect(s.questions.map((q) => q.image.id).toSet(), {
        'b-baso-1',
        'p-mal-thick-1',
      });
    });

    test('bir xil seed — bir xil savollar (takrorlanadi)', () {
      List<String> run(int seed) => [
        for (final q in MicroQuizSession.build(
          atlas,
          random: math.Random(seed),
        ).questions)
          '${q.image.id}:${q.options.map((e) => e.id).join(',')}',
      ];
      expect(run(11), run(11));
    });
  });

  group('MicroscopyController', () {
    test(
      'atlas yuklanadi; eng yaxshi natija saqlanadi va qayta o‘qiladi',
      () async {
        final store = MemoryKeyValueStore();
        final c = MicroscopyController(store, bundle: rootBundle);
        await c.ensureAtlas();
        expect(c.state, AtlasLoadState.ready);
        expect(await c.recordResult('blood', 5, 8), isTrue);
        expect(await c.recordResult('blood', 4, 8), isFalse);
        expect(await c.recordResult('blood', 8, 8), isTrue);
        final again = MicroscopyController(store, bundle: rootBundle);
        expect(again.best('blood')!.correct, 8);
        expect(again.best('urine'), isNull);
        again.resetInMemory();
        expect(again.best('blood'), isNull);
      },
    );

    test('buzilgan atlas — xato holati (ko‘rsatilmaydi)', () async {
      final c = MicroscopyController(
        MemoryKeyValueStore(),
        bundle: _BrokenBundle(),
      );
      await c.ensureAtlas();
      expect(c.state, AtlasLoadState.failed);
      expect(c.atlas, isNull);
    });

    test('buzilgan natija yozuvi atlasni buzmaydi', () {
      final c = MicroscopyController(
        MemoryKeyValueStore({StoreKeys.microscopyQuiz: '{oops'}),
        bundle: rootBundle,
      );
      expect(c.best('all'), isNull);
    });
  });
}

class _BrokenBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(
    Uint8List.fromList(utf8.encode('{"schema_version": 1}')),
  );
}
