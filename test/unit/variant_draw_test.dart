// Variantli test (D-66): Dart tanlovi Worker (cloudflare/src/variants.ts)
// bilan aynan bir xil — umumiy vektorlar cloudflare/test/variant_vectors.json.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/backend/variant_draw.dart';

import '../helpers/fake_backend.dart';

void main() {
  final vectors = jsonDecode(
    File('cloudflare/test/variant_vectors.json').readAsStringSync(),
  ) as Map<String, Object?>;

  test('SHA-256 hex — Worker bilan bir xil', () {
    for (final v in (vectors['sha256']! as List).cast<Map<String, Object?>>()) {
      expect(
        sha256.convert(utf8.encode(v['input']! as String)).toString(),
        v['hex'],
      );
    }
  });

  test('umumiy vektorlar: har holatda kutilgan to‘plam', () {
    final cases = (vectors['cases']! as List).cast<Map<String, Object?>>();
    expect(cases, isNotEmpty);
    for (final c in cases) {
      final got = drawVariant(
        assignmentId: c['assignment_id']! as String,
        userId: c['user_id']! as String,
        pool: (c['pool']! as List).cast<String>(),
        poolTopics: (c['pool_topics'] as List?)?.cast<String?>(),
        count: c['count']! as int,
      );
      expect(
        got,
        (c['expected']! as List).cast<String>(),
        reason: '${c['name']}',
      );
    }
  });

  test('qattiq kodlangan nazorat (Worker testidagi bilan bir xil)', () {
    expect(
      drawVariant(
        assignmentId: '3f2b8c1e-5d4a-4e6f-9a7b-1c2d3e4f5a6b',
        userId: 'u-alpha',
        pool: [for (var i = 1; i <= 10; i++) 'q${'$i'.padLeft(2, '0')}'],
        count: 3,
      ),
      ['q10', 'q03', 'q08'],
    );
  });

  test('mavzular bo‘yicha muvozanat va talabalar orasida farq', () {
    final pool = [for (var i = 0; i < 30; i++) 'p$i'];
    final topics = [
      for (var i = 0; i < 30; i++) i < 18 ? 'big' : (i < 26 ? 'mid' : 'small'),
    ];
    final seen = <String>{};
    for (var u = 0; u < 10; u++) {
      final got = drawVariant(
        assignmentId: 'B',
        userId: 'u$u',
        pool: pool,
        poolTopics: topics,
        count: 9,
      );
      int n(String t) => got.where((q) => topics[pool.indexOf(q)] == t).length;
      expect([n('big'), n('mid'), n('small')], [3, 3, 3]);
      expect(got.toSet(), hasLength(9));
      seen.add((got.toList()..sort()).join(','));
    }
    expect(seen.length, greaterThan(5));
  });

  test('variantAllowed: hovuz ≥ 2 × N; variantTopic — server qoidasi', () {
    expect(variantAllowed(20, 10), isTrue);
    expect(variantAllowed(19, 10), isFalse);
    expect(variantAllowed(5, 0), isFalse);
    expect(variantTopic(['d013-L', 'x']), 'd013-L');
    expect(variantTopic(['bad topic']), isNull);
    expect(variantTopic(const []), isNull);
  });

  group('model va yig‘ma', () {
    final a = GroupAssignment(
      id: 'A1',
      groupId: 'g',
      title: 'Variantli',
      questionIds: [for (var i = 0; i < 8; i++) 'q$i'],
      dueAt: null,
      timeLimitMinutes: null,
      createdAt: DateTime.utc(2026),
      perStudent: 3,
    );

    test('questionIdsFor = drawVariant; questionCount = perStudent', () {
      expect(a.isVariant, isTrue);
      expect(a.questionCount, 3);
      expect(
        a.questionIdsFor('u1'),
        drawVariant(
          assignmentId: 'A1',
          userId: 'u1',
          pool: a.questionIds,
          count: 3,
        ),
      );
    });

    test('tallyQuestions: har savol — faqat u tushgan talabalar orasida', () {
      final key = [for (var i = 0; i < 8; i++) i % 3];
      GroupSubmission sub(String uid, {required bool right}) {
        final ids = a.questionIdsFor(uid);
        return GroupSubmission(
          assignmentId: 'A1',
          userId: uid,
          score: right ? 3 : 0,
          total: 3,
          submittedAt: DateTime.utc(2026),
          answers: [for (final _ in ids) 0],
          correct: [for (final _ in ids) right],
          questionIds: ids,
        );
      }

      final subs = [sub('u1', right: true), sub('u2', right: false)];
      final t = tallyQuestions(a, subs, key);
      expect(t.fold<int>(0, (n, x) => n + x.received), 6);
      for (final x in t) {
        final holders = subs.where(
          (s) => s.questionIds!.contains(x.questionId),
        );
        expect(x.received, holders.length);
        expect(x.wrong, holders.where((s) => s.userId == 'u2').length);
      }
      final hard = hardestTallies(t);
      expect(
        hard.every((x) => a.questionIdsFor('u2').contains(x.questionId)),
        isTrue,
      );
      // Ulush bo'yicha: 1/1 xato 1/2 xatodan oldin.
      for (var i = 1; i < hard.length; i++) {
        expect(hard[i - 1].rate, lessThanOrEqualTo(hard[i].rate));
      }
    });
  });

  test(
    'soxta server: begona id rad, o‘z to‘plami istalgan tartibda qabul',
    () async {
      final b = FakeLabBackend();
      await b.requestCode('t@example.com');
      await b.verifyCode('t@example.com', FakeLabBackend.otpCode);
      await b.registerTeacher();
      final g = await b.createGroup('Variant guruh');
      final pool = [for (var i = 0; i < 10; i++) 'q$i'];
      final key = [for (var i = 0; i < 10; i++) i % 4];
      await expectLater(
        b.createAssignment(
          groupId: g.id,
          title: 'Variantli',
          questionIds: pool,
          correctIndexes: key,
          perStudent: 6,
        ),
        throwsA(isA<BackendException>()),
      );
      final aid = await b.createAssignment(
        groupId: g.id,
        title: 'Variantli',
        questionIds: pool,
        correctIndexes: key,
        perStudent: 4,
      );
      await b.requestCode('s@example.com');
      await b.verifyCode('s@example.com', FakeLabBackend.otpCode);
      await b.joinGroup(g.joinCode!);
      final a = (await b.assignments(g.id)).single;
      final mine = a.questionIdsFor(b.userId);
      await b.startAssignment(aid);
      final foreign = pool.firstWhere((q) => !mine.contains(q));
      await expectLater(
        b.submitAssignment(
          aid,
          [0, 0, 0, 0],
          questionIds: [...mine.take(3), foreign],
        ),
        throwsA(isA<BackendException>()),
      );
      await expectLater(
        b.submitAssignment(aid, [0, 0, 0, 0]),
        throwsA(isA<BackendException>()),
      );
      final rev = mine.reversed.toList();
      final sub = await b.submitAssignment(aid, [
        for (final q in rev) key[pool.indexOf(q)],
      ], questionIds: rev);
      expect(sub.score, 4);
      expect(sub.questionIds, mine);
    },
  );
}
