import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/learn/exam_controller.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/learn/exam_session.dart';

/// Tashqi bankni taqlid qiluvchi savol (masalan, toifa imtihoni banki):
/// bir yoki bir nechta to'g'ri javob, mavzular.
class _Q implements ExamQuestion {
  _Q(this.id, this.correct, {this.options = 4, this.topicIds = const []});

  @override
  final String id;
  @override
  final Set<int> correct;
  final int options;
  @override
  final List<String> topicIds;

  @override
  String prompt(String lang) => 'Savol $id';
  @override
  int get optionCount => options;
  @override
  String option(int index, String lang) => '$id-$index';
  @override
  String? explanation(int index, String lang) => null;
  @override
  String? basis(String lang) => null;
  @override
  bool get isDraft => true;
  @override
  List<SourceRef> get refs => const [];
}

ExamSession _session(
  List<ExamQuestion> qs, {
  int seed = 1,
  Duration? limit,
  DateTime? start,
  DateTime? hardDeadline,
}) => ExamSession.build(
  id: 's',
  mode: ExamMode.exam,
  questions: qs,
  random: Random(seed),
  startedAt: start ?? DateTime.utc(2026, 10, 9, 9),
  limit: limit,
  hardDeadline: hardDeadline,
);

/// Ekrandagi qaysi variant berilgan asl variantga mos.
int _display(ExamSession s, int original) => s.current.order.indexOf(original);

ContentPack _pack() => ContentPack.fromJson(
  (jsonDecode(File('assets/content/core/pack.json').readAsStringSync()) as Map)
      .cast<String, Object?>(),
);

void main() {
  group('ExamSession', () {
    final qs = [
      for (var i = 0; i < 6; i++) _Q('q$i', {i % 4}, topicIds: ['t${i % 2}']),
    ];

    test('savollar va variantlar aralashadi, hammasi saqlanadi', () {
      final a = _session(qs, seed: 1);
      final b = _session(qs, seed: 2);
      expect(
        a.items.map((i) => i.questionId).toSet(),
        qs.map((q) => q.id).toSet(),
      );
      expect([
        for (final i in a.items) i.questionId,
      ], isNot([for (final i in b.items) i.questionId]));
      for (final item in a.items) {
        expect(item.order.toSet(), {0, 1, 2, 3}, reason: 'permutatsiya');
      }
      // Kamida bitta savolda variant tartibi o'zgargan.
      expect(
        a.items.any((i) => !const [0, 1, 2, 3].every((k) => i.order[k] == k)),
        isTrue,
      );
      // Berilgan tartib (topshiriq uchun) saqlanadi.
      expect(a.items.map((i) => i.position).toSet(), {0, 1, 2, 3, 4, 5});
    });

    test('ball asl variant bo‘yicha: aralashtirilgan tartibda ham to‘g‘ri', () {
      final s = _session(qs);
      // 1-savol to'g'ri, 2-savol xato, 3-savol javob o'zgartirildi → to'g'ri,
      // qolganlari javobsiz.
      s.choose(_display(s, s.current.correct.single));
      s.next();
      s.choose(_display(s, (s.current.correct.single + 1) % 4));
      s.next();
      s.choose(_display(s, (s.current.correct.single + 1) % 4));
      s.choose(_display(s, s.current.correct.single));
      expect(s.answeredCount, 3);
      expect(s.correctCount, 2);
      expect(s.wrongCount, 1);
      expect(s.unansweredCount, 3);
      expect(s.percent, 33);
      expect(s.mistakeIndexes, [1, 3, 4, 5]);
      expect(s.isSelected(2, _display(s, s.items[2].correct.single)), isTrue);
    });

    test('ko‘p to‘g‘ri javobli savol: faqat to‘liq mos kelsa to‘g‘ri', () {
      final s = _session([
        _Q('m', {0, 2}, options: 5),
      ]);
      expect(s.current.multi, isTrue);
      s.choose(_display(s, 0));
      expect(s.isCorrect(0), isFalse, reason: 'bittasi yetmaydi');
      s.choose(_display(s, 2));
      expect(s.isCorrect(0), isTrue);
      s.choose(_display(s, 4));
      expect(s.isCorrect(0), isFalse, reason: 'ortiqcha variant');
      s.choose(_display(s, 4));
      expect(s.answerAt(0), [0, 2]);
      s.choose(_display(s, 0));
      s.choose(_display(s, 2));
      expect(s.isAnswered(0), isFalse, reason: 'hammasi olib tashlandi');
    });

    test('mavzu bo‘yicha natija: eng zaif mavzu birinchi', () {
      final s = _session(qs);
      for (var i = 0; i < s.length; i++) {
        s.goTo(i);
        final item = s.current;
        // t0 mavzusi — hammasi to'g'ri, t1 — hammasi xato.
        final right = item.topicIds.contains('t0');
        s.choose(
          _display(
            s,
            right ? item.correct.single : (item.correct.single + 1) % 4,
          ),
        );
      }
      final b = s.topicBreakdown();
      expect([for (final t in b) t.topicId], ['t1', 't0']);
      expect((b.first.correct, b.first.total, b.first.percent), (0, 3, 0));
      expect((b.last.correct, b.last.total, b.last.percent), (3, 3, 100));
    });

    test('taymer: qolgan vaqt, muddat, avtomatik yakunda vaqt oshmaydi', () {
      final start = DateTime.utc(2026, 10, 9, 9);
      final s = _session(qs, limit: const Duration(minutes: 10), start: start);
      expect(
        s.remaining(start.add(const Duration(minutes: 3))),
        const Duration(minutes: 7),
      );
      expect(s.expired(start.add(const Duration(minutes: 9))), isFalse);
      final late = start.add(const Duration(hours: 2));
      expect(s.expired(late), isTrue);
      expect(s.remaining(late), Duration.zero);
      s.finish(late, timedOut: true);
      expect(s.timedOut, isTrue);
      expect(s.spent(late), const Duration(minutes: 10));
      // Yakunlangach javob o'zgarmaydi.
      s.choose(0);
      expect(s.answeredCount, 0);
    });

    test('topshiriq muddati vaqt chegarasidan oldin bo‘lsa — u hal qiladi', () {
      final start = DateTime.utc(2026, 10, 9, 9);
      final s = _session(
        qs,
        limit: const Duration(minutes: 30),
        start: start,
        hardDeadline: start.add(const Duration(minutes: 5)),
      );
      expect(s.deadline, start.add(const Duration(minutes: 5)));
      expect(_session(qs).deadline, isNull, reason: 'vaqtsiz');
    });

    test('serverga javoblar berilgan tartibda, javobsiz — -1', () {
      final s = _session(qs);
      final first = s.current;
      s.choose(_display(s, 3));
      final out = s.submissionAnswers();
      expect(out.length, qs.length);
      expect(out[first.position], 3);
      expect(out.where((a) => a == -1).length, qs.length - 1);
    });

    test('JSON: to‘liq tiklanadi (eski bitta-javob formati ham o‘qiladi)', () {
      final s = _session(qs, limit: const Duration(minutes: 5));
      s.choose(_display(s, 1));
      s.toggleFlag();
      s.goTo(2);
      final back = ExamSession.fromJson(
        (jsonDecode(jsonEncode(s.toJson())) as Map).cast<String, Object?>(),
      );
      expect(back.index, 2);
      expect(back.answerAt(0), [1], reason: 'asl variant 1 tanlangan');
      expect(back.isFlagged(0), isTrue);
      expect(back.deadline, s.deadline);
      expect(back.items[3].topicIds, s.items[3].topicIds);
      expect(back.sourceId, PackQuestionSource.sourceId);

      final legacy = s.toJson()
        ..['answers'] = [2, null, null, null, null, null]
        ..['items'] = [
          for (final i in s.items) {...i.toJson(), 'c': i.correct.single},
        ];
      final old = ExamSession.fromJson(
        (jsonDecode(jsonEncode(legacy)) as Map).cast<String, Object?>(),
      );
      expect(old.answerAt(0), [2]);
      expect(old.items.first.correct, s.items.first.correct);
    });
  });

  group('PackQuestionSource', () {
    test('mavzular: umumiy hisoblar va analit guruhlari', () {
      final pack = _pack();
      final src = PackQuestionSource.of(pack);
      expect(src.questions.length, pack.quiz.length);
      final general = src.topics.firstWhere(
        (t) => t.id == PackQuestionSource.generalTopic,
      );
      expect(
        general.questions.every((q) => q.topicIds.contains('general')),
        isTrue,
      );
      final kidney = src.topics.firstWhere((t) => t.id == 'kidney');
      expect(kidney.questions, isNotEmpty);
      for (final q in kidney.questions) {
        expect(q.topicIds, contains('kidney'));
        expect(q.correct.length, 1);
      }
      // Tanlangan mavzular savollari takrorlanmaydi.
      final pool = examPool(src, {'kidney', 'general'});
      expect(pool.map((q) => q.id).toSet().length, pool.length);
      expect(examPool(src, const {}).length, pack.quiz.length);
      // Draft holati saqlanadi (hech biri “tasdiqlangan” deb ko'rsatilmaydi).
      expect(
        src.questions.where((q) => q.isDraft).length,
        pack.quiz.where((q) => q.isDraft).length,
      );
    });
  });

  group('ExamController', () {
    ExamSession timed(ExamController c, {int minutes = 10}) =>
        ExamSession.build(
          id: c.newId(),
          mode: ExamMode.exam,
          questions: [
            for (var i = 0; i < 3; i++) _Q('q$i', {0}),
          ],
          random: c.random,
          startedAt: c.now(),
          limit: Duration(minutes: minutes),
        );

    test('imtihon holati qurilmada: qayta ochilganda davom etadi', () async {
      final store = MemoryKeyValueStore();
      var now = DateTime.utc(2026, 10, 9, 9);
      final c = ExamController(store, clock: () => now, random: Random(3));
      final s = timed(c);
      await c.start(s);
      s.choose(0);
      s.toggleFlag();
      s.next();
      await c.save(s);

      now = now.add(const Duration(minutes: 4));
      final reopened = ExamController(store, clock: () => now);
      final r = reopened.active!;
      expect(r.id, s.id);
      expect(r.index, 1);
      expect(r.answerAt(0), s.answerAt(0));
      expect(r.isFlagged(0), isTrue);
      expect(r.remaining(now), const Duration(minutes: 6));
      expect(await reopened.settleExpired(), isNull);
    });

    test('ilova yopiq paytda vaqt tugasa — halol yakun va tarix', () async {
      final store = MemoryKeyValueStore();
      var now = DateTime.utc(2026, 10, 9, 9);
      final c = ExamController(store, clock: () => now);
      final s = timed(c, minutes: 5);
      await c.start(s);
      s.choose(s.current.order.indexOf(0));
      await c.save(s);

      now = now.add(const Duration(hours: 3));
      final reopened = ExamController(store, clock: () => now);
      final done = await reopened.settleExpired();
      expect(done, isNotNull);
      expect(done!.timedOut, isTrue);
      expect(done.finishedAt, s.deadline, reason: 'vaqt oshib ketmaydi');
      expect(done.correctCount, 1);
      expect(reopened.active, isNull);
      expect(reopened.history.single.id, s.id);
      // Tarix ham saqlangan.
      expect(ExamController(store).history.single.timedOut, isTrue);
    });

    test('tarix cheklangan, eng yangisi birinchi; tozalash', () async {
      final c = ExamController(MemoryKeyValueStore());
      for (var i = 0; i < ExamController.historyLimit + 3; i++) {
        await c.start(timed(c));
        await c.finishActive();
      }
      expect(c.history.length, ExamController.historyLimit);
      await c.clearHistory();
      expect(c.history, isEmpty);
    });

    test('topshiriq sessiyasi faqat o‘sha hisobga ko‘rinadi', () async {
      final c = ExamController(MemoryKeyValueStore());
      final s = ExamSession.build(
        id: 'a',
        mode: ExamMode.assignment,
        questions: [
          _Q('q', {1}),
        ],
        random: Random(1),
        startedAt: c.now(),
        assignmentId: 'asg-1',
        userId: 'user-a',
      );
      await c.startAssignment(s);
      expect(c.assignmentSession('asg-1', 'user-a'), isNotNull);
      expect(c.assignmentSession('asg-1', 'user-b'), isNull);
      await c.removeAssignment('asg-1');
      expect(c.assignmentSession('asg-1', 'user-a'), isNull);
    });

    test('buzilgan yozuv ilovani yiqitmaydi', () async {
      final store = MemoryKeyValueStore();
      await store.setString(StoreKeys.examActive, '{not json');
      await store.setString(StoreKeys.examHistory, '[{"id": 1}]');
      final c = ExamController(store);
      expect(c.active, isNull);
      expect(c.history, isEmpty);
    });
  });
}
