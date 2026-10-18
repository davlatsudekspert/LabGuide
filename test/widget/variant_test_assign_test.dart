// Variantli test (D-66): “Har bir talabaga boshqa savollar”. Ustoz
// taqdimotdan topshiradi — rejim hovuz ≥ 2 × N bo'lsa standart yoqiq, aks
// holda o'chiq va tushuntirish bilan; har talaba o'z to'plamini yechadi
// (talabaga alohida belgi yo'q); ustoz natijasida “Variantli test” va har
// savol bo'yicha “n ta talabaga tushdi”.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/classroom/topic_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));
const _tall = Size(390, 2400);
const _deck = 'd013';

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

SwitchListTile _toggle(WidgetTester tester) =>
    tester.widget<SwitchListTile>(find.byKey(const ValueKey('assign-variant')));

String _note(WidgetTester tester) => tester
    .widget<Text>(find.byKey(const ValueKey('assign-variant-note')))
    .data!;

Future<void> _count(WidgetTester tester, String n) async {
  final field = find.byType(TextField).first;
  await tester.ensureVisible(field);
  await tester.enterText(field, n);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'variant rejimi: standart yoqiq, hovuz kichik — o‘chiq; 3 talaba — 3 xil '
    'to‘plam; ustoz natijasida yorliq va “n ta talabaga tushdi”',
    (tester) async {
      installDiffFakes();
      final b = FakeLabBackend();
      final s = await makeServices(tester, backend: b, role: AppRole.teacher);
      await pumpApp(tester, s, size: _tall);
      await _signIn(tester, s, 'teacher@example.com');
      await b.registerTeacher();
      final g = await b.createGroup('Gematologiya V');
      final c = (await tester.runAsync(() => DeckCatalog.load(rootBundle)))!;
      final pool = deckQuestionPool(
        c.byId(_deck)!,
        s.curriculum.curriculum,
        s.content.pack,
        s.toifa.bank,
      );
      final poolIds = {for (final q in pool) q.id};
      final cut = poolIds.length > 60 ? 60 : poolIds.length;
      expect(cut, greaterThanOrEqualTo(10), reason: 'd013 hovuzi kichik');

      await goTo(tester, '/learn/lecture/test/$_deck/assign');
      // N = 5, hovuz ≥ 10 — standart yoqiq, bir qatorlik tushuntirish.
      await _count(tester, '5');
      expect(_toggle(tester).value, isTrue);
      expect(_toggle(tester).onChanged, isNotNull);
      expect(_note(tester), uz.variantOnBody(cut, 5));
      expect(find.byKey(const ValueKey('assign-variant-pool')), findsOneWidget);

      // N katta (2N > hovuz) — o'chiq va bosib bo'lmaydi, sababi bilan.
      final big = cut ~/ 2 + 1;
      await _count(tester, '$big');
      expect(_toggle(tester).value, isFalse);
      expect(_toggle(tester).onChanged, isNull);
      expect(_note(tester), uz.variantDisabledBody(cut, big * 2));
      expect(find.byKey(const ValueKey('assign-variant-pool')), findsNothing);

      // Qaytib 5 — yana yoqiq; ustoz o'chirib-yoqishi mumkin.
      await _count(tester, '5');
      expect(_toggle(tester).value, isTrue);
      await _tapKey(tester, 'assign-variant');
      expect(_toggle(tester).value, isFalse);
      expect(_note(tester), uz.variantOffBody);
      await _tapKey(tester, 'assign-variant');
      expect(_toggle(tester).value, isTrue);

      // Bitta guruh — avtomatik tanlangan.
      await _tapKey(tester, 'assign-send');
      expect(find.text(uz.topicTestSent(1)), findsOneWidget);
      final a = (await b.assignments(g.id)).single;
      expect(a.isVariant, isTrue);
      expect(a.perStudent, 5);
      expect(a.questionCount, 5);
      expect(a.questionIds.length, cut);
      expect(poolIds.containsAll(a.questionIds), isTrue);
      expect(a.poolTopics, hasLength(cut));
      final key = await b.assignmentKey(a.id);
      expect(key, hasLength(cut));

      // 3 talaba: har biriga o'z to'plami (server = ilova hisobi).
      final sets = <String, List<String>>{};
      for (final email in ['v1@example.com', 'v2@example.com']) {
        await _signIn(tester, s, email);
        await b.joinGroup(g.joinCode!);
        final st = await b.startAssignment(a.id);
        final mine = a.questionIdsFor(b.userId);
        expect(st.questionIds, mine);
        sets[b.userId!] = mine;
        // Begona savol bilan topshirish — rad.
        final foreign = a.questionIds.firstWhere((q) => !mine.contains(q));
        await expectLater(
          b.submitAssignment(
            a.id,
            List.filled(5, 0),
            questionIds: [...mine.take(4), foreign],
          ),
          throwsA(isA<BackendException>()),
        );
        // 1-talaba — hammasi to'g'ri; 2-chi — hammasi xato.
        final right = email.startsWith('v1');
        final answers = [
          for (final q in mine)
            right
                ? key[a.questionIds.indexOf(q)]
                : (key[a.questionIds.indexOf(q)] + 1) % 2,
        ];
        final sub = await b.submitAssignment(a.id, answers, questionIds: mine);
        expect(sub.total, 5);
        expect(sub.score, right ? 5 : 0);
      }

      // 3-talaba ilovada yechadi: “Variantli” belgisi yo'q, 5 ta savol.
      await _signIn(tester, s, 'v3@example.com');
      await b.joinGroup(g.joinCode!);
      await s.settings.setRole(AppRole.student);
      await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
      expect(find.text(uz.variantLabel), findsNothing);
      expect(find.text('5'), findsWidgets);
      await tapScroll(tester, uz.classesStart);
      final run = s.exams.assignmentSession(a.id, b.userId)!;
      final mine3 = a.questionIdsFor(b.userId);
      sets[b.userId!] = mine3;
      expect({for (final i in run.items) i.questionId}, mine3.toSet());
      expect(run.submissionQuestionIds(), mine3);
      for (var i = 0; i < run.length; i++) {
        final item = run.current;
        final q = ClassQuestionSource.of(
          s.content.pack!,
          s.toifa.bank,
        ).question(item.questionId)!;
        await tapScroll(tester, q.option(item.correct.single, 'uz'));
        if (i < run.length - 1) await tapScroll(tester, uz.examNext);
      }
      await tapScroll(tester, uz.examFinish);
      await tester.tap(find.text(uz.examFinish).hitTestable().last);
      await tester.pumpAndSettle();
      final mySub = (await b.submissions(a.id)).single;
      expect(mySub.score, 5);
      expect(mySub.questionIds, mine3);
      expect(find.text(uz.variantLabel), findsNothing);

      // Uch talabaning to'plamlari har xil.
      expect(
        {
          for (final x in sets.values) ([...x]..sort()).join(','),
        }.length,
        3,
      );

      // Ustoz natijasi: “Variantli test” yorlig'i, har savol — tushganlar.
      await _signIn(tester, s, 'teacher@example.com');
      await s.settings.setRole(AppRole.teacher);
      await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
      expect(find.byKey(const ValueKey('assignment-variant')), findsOneWidget);
      expect(find.text(uz.variantLabel), findsOneWidget);
      expect(find.text(uz.variantPerStudent(5, cut)), findsOneWidget);
      final subs = await b.submissions(a.id);
      final tally = tallyQuestions(a, subs, key);
      expect(tally.fold<int>(0, (n, t) => n + t.received), 15);
      // Eng qiyin: faqat 2-talabaga tushgan (yoki u bilan) savollar.
      final hard = hardestTallies(tally);
      expect(hard, isNotEmpty);
      final v2 = sets.entries.elementAt(1).value;
      for (final t in hard) {
        expect(v2, contains(t.questionId));
      }
      final top = hard.first;
      final card = find.byKey(ValueKey('hardest-${top.index}'));
      await tester.scrollUntilVisible(
        card,
        300,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      expect(
        find.descendant(
          of: card,
          matching: find.text(uz.variantReceived(top.received)),
        ),
        findsOneWidget,
      );
      // Savol bo'yicha ro'yxatda — faqat kimgadir tushgan savollar.
      for (final t in tally) {
        expect(
          find.byKey(ValueKey('received-${t.index}'), skipOffstage: false),
          t.received > 0 ? findsOneWidget : findsNothing,
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('server qo‘llamasa — o‘chiq, tushuntirish; oddiy test ketadi', (
    tester,
  ) async {
    installDiffFakes();
    final b = FakeLabBackend()..variantTests = false;
    final s = await makeServices(tester, backend: b, role: AppRole.teacher);
    await pumpApp(tester, s, size: _tall);
    await _signIn(tester, s, 'teacher@example.com');
    await b.registerTeacher();
    final g = await b.createGroup('Gematologiya O');
    await goTo(tester, '/learn/lecture/test/$_deck/assign');
    await _count(tester, '5');
    expect(_toggle(tester).value, isFalse);
    expect(_toggle(tester).onChanged, isNull);
    expect(_note(tester), uz.variantUnsupported);
    await _tapKey(tester, 'assign-send');
    final a = (await b.assignments(g.id)).single;
    expect(a.isVariant, isFalse);
    expect(a.questionIds, hasLength(5));

    // Oddiy test natijasida “Variantli test” yorlig'i yo'q.
    await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
    expect(find.byKey(const ValueKey('assignment-variant')), findsNothing);
  });
}
