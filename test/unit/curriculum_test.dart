import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/classroom/classroom_local.dart';
import 'package:labguide/features/classroom/curriculum.dart';
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';

const fixturePath = 'test/fixtures/curriculum_sample.json';

/// Faqat berilgan fayllarni “asset” sifatida beradi.
class _MapBundle extends CachingAssetBundle {
  _MapBundle(this.files);

  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    final f = files[key];
    if (f == null) throw StateError('missing $key');
    return ByteData.sublistView(utf8.encode(f));
  }
}

Map<String, Object?> _json(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('curriculum.json o‘quvchisi', () {
    final cur = Curriculum.parse(File(fixturePath).readAsStringSync());

    test('modul → mavzu; bo‘sh modul tashlanadi; kun tartibi', () {
      expect(cur.name.of('uz'), 'Namuna dastur (test)');
      expect(cur.modules.map((m) => m.id), ['M2', 'M4']);
      expect(cur.topics.map((t) => t.id), ['d008-L', 'd008-P', 'd027-L']);
      expect(cur.modules.first.title.of('ru'), 'Почки и моча');
      expect(cur.modules.first.title.of('en'), 'Buyrak va siydik');
      expect(cur.modules.last.title.of('en'), 'Urinalysis');
    });

    test('mavzu maydonlari va havolalar', () {
      final t = cur.topic('d008-L')!;
      expect(t.order, 8);
      expect(t.week, 2);
      expect(t.hours, 2);
      expect(t.type, CurriculumTopicType.lecture);
      expect(t.title.of('en'), 'Laboratory markers of kidney disease');
      expect(t.title.of('ru'), t.title.of('uz'), reason: 'tarjima yo‘q');
      expect(t.date, isNull);
      expect(t.links.analytes, contains('creatinine'));
      expect(t.links.conditions, ['chronic-kidney-disease']);
      expect(t.links.tools, [
        '/lab/calculators/egfr',
      ], reason: 'tashqi havola olib tashlanadi');
      expect(t.links.toifaTopic, 'kidney_nitrogen');
      expect(t.oralCandidates, ['kdl-o-042', 'kdl-o-043']);
      expect(t.testCandidates, ['kdl-t-031', 'kdl-t-063']);
      expect(t.packQuizCandidates, ['creatinine-q1', 'urea-q1']);
      expect(cur.moduleOf(t)!.id, 'M2');

      final p = cur.topic('d008-P')!;
      expect(p.date, DateTime(2026, 1, 14));
      expect(p.goals, ['Kreatinin va eGFR ni talqin qilish']);
      expect(p.keyPoints, hasLength(1));
      expect(p.testCandidates, isEmpty);
      expect(cur.topic('d027-L')!.links.gap, isTrue);
      expect(cur.topic('d027-L')!.links.microscopy, ['urine']);
    });

    test('takror mavzu id si — xato; modullar yo‘q — xato', () {
      expect(
        () => Curriculum.fromJson({
          'modules': [
            {
              'id': 'M1',
              'topics': [
                {'id': 'a', 'n': 1},
                {'id': 'a', 'n': 2},
              ],
            },
          ],
        }),
        throwsFormatException,
      );
      expect(() => Curriculum.fromJson({}), throwsFormatException);
    });

    test('sana bo‘lmasa — tartib raqami', () {
      final c = Curriculum.fromJson({
        'modules': [
          {
            'id': 'M1',
            'title_uz': 'X',
            'topics': [
              {'id': 'a', 'title_uz': 'A'},
              {'id': 'b', 'title_uz': 'B'},
            ],
          },
        ],
      });
      expect(c.topics.map((t) => t.order), [1, 2]);
    });
  });

  test('kun tartibi → sana: yakshanba o‘tkaziladi', () {
    final mon = DateTime(2026, 1, 5); // dushanba
    expect(studyDayDate(mon, 1), DateTime(2026, 1, 5));
    expect(studyDayDate(mon, 6), DateTime(2026, 1, 10)); // shanba
    expect(studyDayDate(mon, 7), DateTime(2026, 1, 12)); // dushanba
    expect(studyDayDate(DateTime(2026, 1, 4), 1), DateTime(2026, 1, 5));
  });

  group('yuklovchi', () {
    test('asset yo‘q — null, controller “missing”', () async {
      final bundle = _MapBundle({});
      expect(await CurriculumLoader.load(bundle), isNull);
      final c = CurriculumController(bundle: bundle);
      await c.ensureLoaded();
      expect(c.state, CurriculumState.missing);
      expect(c.curriculum, isNull);
      final none = CurriculumController();
      await none.ensureLoaded();
      expect(none.state, CurriculumState.missing);
    });

    test('asset bor — o‘qiladi; buzilgan — error', () async {
      final ok = CurriculumController(
        bundle: _MapBundle({
          CurriculumLoader.assetPath: File(fixturePath).readAsStringSync(),
        }),
      );
      await ok.ensureLoaded();
      expect(ok.state, CurriculumState.ready);
      expect(ok.curriculum!.topics, hasLength(3));
      final bad = CurriculumController(
        bundle: _MapBundle({CurriculumLoader.assetPath: '{"modules": 1}'}),
      );
      await bad.ensureLoaded();
      expect(bad.state, CurriculumState.error);
    });
  });

  group('nomzod savollar', () {
    final pack = ContentPack.fromJson(_json('assets/content/core/pack.json'));
    final bank = ToifaBank.fromJson(
      _json('assets/toifa/kdl_tests.json'),
      _json('assets/toifa/kdl_oral.json'),
    );
    final cur = Curriculum.parse(File(fixturePath).readAsStringSync());

    test('test: curriculum ro‘yxati (toifa + paket), bitta kalitli', () {
      final qs = testCandidates(cur.topic('d008-L')!, pack, bank);
      expect(qs.map((q) => q.id), [
        'kdl-t-031',
        'kdl-t-063',
        'creatinine-q1',
        'urea-q1',
      ]);
      expect(qs.every((q) => q.correct.length == 1), isTrue);
    });

    test('ro‘yxat bo‘lmasa — havolalar bo‘yicha', () {
      final qs = testCandidates(cur.topic('d008-P')!, pack, bank);
      expect(qs, isNotEmpty);
      expect(
        qs.where((q) => q.id.startsWith('kdl-t-')),
        everyElement(
          isA<ToifaTestQuestion>().having(
            (q) => q.topic,
            'topic',
            'kidney_nitrogen',
          ),
        ),
      );
      expect(qs.map((q) => q.id), contains('creatinine-q1'));
    });

    test('og‘zaki: ro‘yxat yoki toifa mavzusi', () {
      expect(oralCandidates(cur.topic('d008-L')!, bank).map((q) => q.id), [
        'kdl-o-042',
        'kdl-o-043',
      ]);
      final byTopic = oralCandidates(cur.topic('d027-L')!, bank);
      expect(byTopic, isNotEmpty);
      expect(byTopic.every((q) => q.topic == 'urinalysis'), isTrue);
      expect(oralCandidates(cur.topic('d008-L')!, null), isEmpty);
    });

    test('aralash bank: paket va toifa savoli bitta manbada', () {
      final s = ClassQuestionSource.of(pack, bank);
      expect(s.question('kdl-t-031'), isNotNull);
      expect(s.question('creatinine-q1'), isNotNull);
      expect(identical(ClassQuestionSource.of(pack, bank), s), isTrue);
    });
  });

  test('ustoz qurilmasidagi ma’lumot saqlanadi va tiklanadi', () async {
    final store = MemoryKeyValueStore();
    final a = ClassroomLocal(store);
    await a.setStartDate('g1', DateTime(2026, 1, 5, 13));
    await a.setLocalName('g1', 'u1', '  Aliyev Anvar ');
    await a.setAsked('g1', 'd008-L', 'kdl-o-042', value: true);
    await a.setGrade('g1', 'd008-L', 'kdl-o-042', 'u1', OralGrade.partial);
    final b = ClassroomLocal(store);
    expect(b.startDate('g1'), DateTime(2026, 1, 5));
    expect(b.localName('g1', 'u1'), 'Aliyev Anvar');
    expect(b.asked('g1', 'd008-L', 'kdl-o-042'), isTrue);
    expect(b.askedCount('g1', 'd008-L'), 1);
    expect(b.grade('g1', 'd008-L', 'kdl-o-042', 'u1'), OralGrade.partial);
    await b.setLocalName('g1', 'u1', '');
    await b.setGrade('g1', 'd008-L', 'kdl-o-042', 'u1', null);
    expect(ClassroomLocal(store).localName('g1', 'u1'), isNull);
    expect(ClassroomLocal(store).grades('g1', 'd008-L', 'kdl-o-042'), isEmpty);
    expect(StoreKeys.all, contains(StoreKeys.classroomLocal));
  });
}
