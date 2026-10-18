// Ustoz–talaba testi HAQIQIY decklar bilan (soxta paket emas): deck matnidan
// olingan savollar ko'p (d040), toifa savollari ko'p (d118) va paket
// savollari ko'p (d048) decklar; oddiy va variantli rejim.
//
// Har deck/rejimda: ustoz ilovada topshiradi → “Talaba ko'rinishida sinash”
// (har savol ko'rinadi, ball) → talaba ilovada yechadi (server balli) →
// ustoz natijalari va “Katta ekran”da “eng qiyin savollar” matni — hech
// qayerda “Bu savol joriy kontent to'plamida yo'q” yoki “… savol ilovangizdagi
// to'plamda yo'q” chiqmaydi.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/features/classroom/board_screen.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/classroom/topic_test.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/learn/exam_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));
const _tall = Size(390, 2400);
const _n = 6;

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.signOut();
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// “Savol to'plamda yo'q” matnlarining hech biri ko'rinmaydi.
void _noMissing(int count) {
  expect(find.text(uz.examQuestionMissing), findsNothing);
  expect(find.textContaining(uz.classesOutdatedPack(count)), findsNothing);
}

Map<String, Object?> _file(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

List<ExamQuestion> _pool(AppServices s, DeckCatalog c, String deck) =>
    deckQuestionPool(
      c.byId(deck)!,
      s.curriculum.curriculum,
      s.content.pack,
      s.toifa.bank,
    );

void main() {
  setUpAll(loadAppFonts);

  for (final (deck, kind) in [
    ('d040', 'derived'),
    ('d118', 'toifa'),
    ('d048', 'paket'),
  ]) {
    for (final variant in [false, true]) {
      testWidgets(
        '$deck ($kind), ${variant ? 'variantli' : 'oddiy'}: topshirish → '
        'sinash → talaba → natijalar → katta ekran',
        (tester) async {
          installDiffFakes();
          final b = FakeLabBackend();
          final s = await makeServices(
            tester,
            backend: b,
            role: AppRole.teacher,
          );
          await pumpApp(tester, s, size: _tall);
          await _signIn(tester, s, 'teacher@example.com');
          await b.registerTeacher();
          final g = await b.createGroup('Real $deck');
          final c = (await tester.runAsync(
            () => DeckCatalog.load(rootBundle),
          ))!;
          final pool = _pool(s, c, deck);
          final byId = classQuestionIndex(s.content.pack, s.toifa.bank);
          expect(pool.length, greaterThanOrEqualTo(2 * _n));
          final kinds = {
            'derived': pool
                .where((q) => q is PackExamQuestion && q.quiz.isDerived)
                .length,
            'toifa': pool.whereType<OfficialKeyQuestion>().length,
          };
          if (kind != 'paket') {
            expect(kinds[kind], greaterThanOrEqualTo(pool.length * 0.6));
          }

          // 1. Ustoz: taqdimotdan topshirish (ilova UI).
          await goTo(tester, '/learn/lecture/test/$deck/assign');
          final field = find.byType(TextField).first;
          await tester.ensureVisible(field);
          await tester.enterText(field, '$_n');
          await tester.pumpAndSettle();
          final toggle = tester.widget<SwitchListTile>(
            find.byKey(const ValueKey('assign-variant')),
          );
          if (toggle.value != variant) await _tapKey(tester, 'assign-variant');
          await _tapKey(tester, 'assign-send');
          expect(find.text(uz.topicTestSent(1)), findsOneWidget);
          final a = (await b.assignments(g.id)).single;
          expect(a.isVariant, variant);
          expect(a.questionCount, _n);
          final key = await b.assignmentKey(a.id);
          for (final (i, id) in a.questionIds.indexed) {
            expect(byId[id], isNotNull, reason: id);
            expect(key[i], byId[id]!.correct.single, reason: id);
          }

          // 2. “Talaba ko'rinishida sinash”: har savol ko'rinadi.
          await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
          _noMissing(a.questionCount);
          await _tapKey(tester, 'assignment-preview');
          final run = tester.widget<ExamRunner>(
            find.byKey(const ValueKey('assignment-preview-run')),
          );
          final ps = run.session;
          expect(ps.length, _n);
          for (var i = 0; i < ps.length; i++) {
            _noMissing(a.questionCount);
            final q = byId[ps.current.questionId]!;
            expect(find.text(q.prompt('uz')), findsWidgets);
            ps.choose(ps.current.order.indexOf(ps.current.correct.single));
            if (i < ps.length - 1) await tapScroll(tester, uz.examNext);
          }
          await tapScroll(tester, uz.examFinish);
          await tester.tap(find.text(uz.examFinish).hitTestable().last);
          await tester.pumpAndSettle();
          expect(find.text(uz.classesPreviewResult(_n, _n)), findsOneWidget);
          // Sinov serverga yuborilmaydi.
          expect(await b.submissions(a.id), isEmpty);

          // 3. Talaba ilovada yechadi (hammasi to'g'ri).
          await goTo(tester, '/learn');
          await _signIn(tester, s, 'good@example.com');
          await b.joinGroup(g.joinCode!, displayName: 'Lola');
          await s.settings.setRole(AppRole.student);
          await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
          _noMissing(a.questionCount);
          await tapScroll(tester, uz.classesStart);
          final st = s.exams.assignmentSession(a.id, b.userId)!;
          expect({
            for (final it in st.items) it.questionId,
          }, a.questionIdsFor(b.userId).toSet());
          for (var i = 0; i < st.length; i++) {
            _noMissing(a.questionCount);
            final it = st.current;
            final q = byId[it.questionId]!;
            await tapScroll(tester, q.option(it.correct.single, 'uz'));
            expect(st.isCorrect(st.index), isTrue, reason: q.id);
            if (i < st.length - 1) await tapScroll(tester, uz.examNext);
          }
          await tapScroll(tester, uz.examFinish);
          await tester.tap(find.text(uz.examFinish).hitTestable().last);
          await tester.pumpAndSettle();
          final mine = (await b.submissions(a.id)).single;
          expect(mine.score, _n, reason: 'server balli = ilova kaliti');
          expect(mine.total, _n);
          _noMissing(a.questionCount);

          // 4. Ikkinchi talaba hammasini xato qiladi (server orqali).
          await b.actAs('bad@example.com', () async {
            await b.joinGroup(g.joinCode!, displayName: 'Bobur');
            final start = await b.startAssignment(a.id);
            final ids = start.questionIds ?? a.questionIds;
            final sub = await b.submitAssignment(a.id, [
              for (final id in ids)
                (key[a.questionIds.indexOf(id)] + 1) % byId[id]!.optionCount,
            ], questionIds: variant ? ids : null);
            expect(sub.score, 0);
          });

          // 5. Ustoz: natijalar va yakunlash.
          await goTo(tester, '/learn');
          await _signIn(tester, s, 'teacher@example.com');
          await s.settings.setRole(AppRole.teacher);
          await b.closeAssignment(a.id);
          await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
          _noMissing(a.questionCount);
          final hard = hardestTallies(
            tallyQuestions(a, await b.submissions(a.id), key),
          );
          expect(hard, isNotEmpty);
          final top = find.byKey(ValueKey('hardest-${hard.first.index}'));
          await tester.scrollUntilVisible(
            top,
            300,
            scrollable: find.byType(Scrollable).hitTestable().first,
          );
          expect(
            find.descendant(
              of: top,
              matching: find.text(byId[hard.first.questionId]!.prompt('uz')),
            ),
            findsOneWidget,
          );

          // 6. Katta ekran: eng qiyin savollar matni bilan.
          await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}/board');
          if (find
              .byKey(const ValueKey('lecture-rotate-no'))
              .evaluate()
              .isNotEmpty) {
            await tester.tap(find.byKey(const ValueKey('lecture-rotate-no')));
            await tester.pumpAndSettle();
          }
          expect(find.byType(AssignmentBoardScreen), findsOneWidget);
          _noMissing(a.questionCount);
          for (final t in hard.take(3)) {
            final card = find.byKey(ValueKey('board-hardest-${t.index}'));
            expect(card, findsOneWidget);
            expect(
              find.descendant(
                of: card,
                matching: find.text(byId[t.questionId]!.prompt('uz')),
              ),
              findsOneWidget,
            );
          }
          await tester.tap(find.byKey(const ValueKey('board-exit')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final lang in AppLanguage.values) {
    testWidgets('360×640 ×1.3 (${lang.name}): topshirish, sinash, talaba '
        'testi va natija sig‘adi (d040, deck matnidan olingan)', (
      tester,
    ) async {
      installDiffFakes();
      final l = lookupAppLocalizations(lang.locale);
      final b = FakeLabBackend();
      final s = await makeServices(
        tester,
        backend: b,
        role: AppRole.teacher,
        language: lang,
      );
      await pumpApp(tester, s, size: const Size(360, 640), textScale: 1.3);
      await _signIn(tester, s, 'teacher@example.com');
      await b.registerTeacher();
      final g = await b.createGroup('Kichik ekran');
      await goTo(tester, '/learn/lecture/test/d040/assign');
      expect(tester.takeException(), isNull);
      await _tapKey(tester, 'assign-send');
      expect(tester.takeException(), isNull);
      final a = (await b.assignments(g.id)).single;
      await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
      expect(tester.takeException(), isNull);
      await _tapKey(tester, 'assignment-preview');
      final ps = tester
          .widget<ExamRunner>(
            find.byKey(const ValueKey('assignment-preview-run')),
          )
          .session;
      for (var i = 0; i < ps.length; i++) {
        expect(find.text(l.examQuestionMissing), findsNothing);
        expect(tester.takeException(), isNull, reason: 'savol $i');
        if (i < ps.length - 1) await tapScroll(tester, l.examNext);
      }
      // Chiqish yo'li bor (boshi berk ko'cha emas).
      await tapScroll(tester, l.examFinish);
      await tester.tap(find.text(l.examFinish).hitTestable().last);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('assignment-preview-run')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);

      await goTo(tester, '/learn');
      await _signIn(tester, s, 'st@example.com');
      await b.joinGroup(g.joinCode!, displayName: 'Lola');
      await s.settings.setRole(AppRole.student);
      await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
      expect(tester.takeException(), isNull);
      await tapScroll(tester, l.classesStart);
      final st = s.exams.assignmentSession(a.id, b.userId)!;
      for (var i = 0; i < st.length; i++) {
        expect(find.text(l.examQuestionMissing), findsNothing);
        expect(tester.takeException(), isNull, reason: 'talaba $i');
        if (i < st.length - 1) await tapScroll(tester, l.examNext);
      }
      await tapScroll(tester, l.examFinish);
      await tester.tap(find.text(l.examFinish).hitTestable().last);
      await tester.pumpAndSettle();
      expect(await b.submissions(a.id), hasLength(1));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('katta ekran ilova tiklanganda to‘g‘ridan-to‘g‘ri ochilsa '
      '(toifa banki hali yuklanmagan) — savol matnlari baribir chiqadi', (
    tester,
  ) async {
    installDiffFakes();
    final b = FakeLabBackend();
    final s = await makeServices(
      tester,
      backend: b,
      role: AppRole.teacher,
      loadToifa: false,
    );
    expect(s.toifa.bank, isNull);
    await pumpApp(tester, s, size: const Size(1280, 720));
    await _signIn(tester, s, 'teacher@example.com');
    await b.registerTeacher();
    final g = await b.createGroup('Tiklash');
    // d118: faqat toifa savollari. Bank servisga yuklanmaydi — test uchun
    // alohida fayldan o'qiladi.
    final c = (await tester.runAsync(() => DeckCatalog.load(rootBundle)))!;
    final bank = ToifaBank.fromJson(
      _file('assets/toifa/kdl_tests.json'),
      _file('assets/toifa/kdl_oral.json'),
    );
    final pool = deckQuestionPool(
      c.byId('d118')!,
      s.curriculum.curriculum,
      s.content.pack,
      bank,
    ).take(4).toList();
    expect(pool.every((q) => q is OfficialKeyQuestion), isTrue);
    final ids = [for (final q in pool) q.id];
    final key = [for (final q in pool) q.correct.single];
    expect(s.toifa.bank, isNull);
    final aid = await b.createAssignment(
      groupId: g.id,
      title: 'Toifa testi',
      questionIds: ids,
      correctIndexes: key,
      deckId: 'd118',
    );
    await b.actAs('bad@example.com', () async {
      await b.joinGroup(g.joinCode!, displayName: 'Bobur');
      await b.startAssignment(aid);
      await b.submitAssignment(aid, [for (final k in key) (k + 1) % 4]);
    });
    await b.closeAssignment(aid);

    await goTo(tester, '/learn/classes/g/${g.id}/a/$aid/board');
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(find.byType(AssignmentBoardScreen), findsOneWidget);
    expect(s.toifa.bank, isNotNull);
    expect(find.text(uz.examQuestionMissing), findsNothing);
    expect(find.text(pool.first.prompt('uz')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('board-exit')));
    await tester.pumpAndSettle();
  });
}
