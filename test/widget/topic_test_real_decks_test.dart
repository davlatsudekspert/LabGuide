// Mavzu testi (mustaqil mashq) HAQIQIY decklar bilan, iPhone (390×844, iOS
// fizikasi): deck matnidan olingan savollar ko'p (d040), toifa savollari
// ko'p (d118), paket savollari ko'p (d048) — har biri boshqa tilda.
//
// Har savolga javob → natija → har xato uchun tahlil kartasi va “Slaydni
// ko'rish” → xatolarni takrorlash → ilova qayta ochilgach (yangi servislar,
// o'sha ombor) natija va ro'yxatdagi belgi saqlanadi. Hech qayerda “savol
// to'plamda yo'q” chiqmaydi. Shuningdek 360×640, ×1.3 — toshib ketmaydi.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/topic_test.dart';
import 'package:labguide/features/classroom/topic_test_screens.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/harness.dart';

const _iphone = Size(390, 844);

Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _answer(
  WidgetTester tester,
  AppServices s,
  String deck, {
  required bool correct,
}) async {
  final item = s.topicTests.draft(deck)!.current;
  final want = correct
      ? item.correct.single
      : item.order.firstWhere((o) => !item.correct.contains(o));
  await _tapKey(tester, 'topic-option-${item.order.indexOf(want)}');
}

void _noMissing(AppLocalizations l) =>
    expect(find.text(l.examQuestionMissing), findsNothing);

void main() {
  setUpAll(loadAppFonts);

  for (final (deck, lang) in [
    ('d040', AppLanguage.uz), // deck matnidan olingan savollar
    ('d118', AppLanguage.ru), // toifa savollari
    ('d048', AppLanguage.en), // paket savollari ko'p
  ]) {
    testWidgets('$deck (${lang.name}), iPhone: hammasiga javob → natija → '
        'tahlil va slayd → xatolar → qayta ochilganda saqlangan', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      installDiffFakes();
      final l = lookupAppLocalizations(lang.locale);
      final code = lang.locale.languageCode;
      final store = MemoryKeyValueStore();
      final s = await makeServices(
        tester,
        store: store,
        role: AppRole.student,
        language: lang,
      );
      await pumpApp(tester, s, size: _iphone);
      final c = (await tester.runAsync(() => DeckCatalog.load(rootBundle)))!;
      final entry = c.byId(deck)!;
      // Deck fayli oldindan (soxta vaqtda asset yuklanishi tugamaydi).
      await tester.runAsync(
        () => DeckCatalog.loadDeck(rootBundle, entry, entry.resolveLang(code)),
      );

      await goTo(tester, '/learn/lecture/test/$deck');
      expect(find.byKey(const ValueKey('topic-test-intro')), findsOneWidget);
      await _tapKey(tester, 'topic-test-start');
      final draft = s.topicTests.draft(deck)!;
      expect(draft.length, kTopicTestSize);

      // Har savol: matn va variantlar ko'rinadi; juftlari to'g'ri.
      for (var i = 0; i < draft.length; i++) {
        _noMissing(l);
        final q = topicQuestion(
          tester.element(find.byKey(const ValueKey('topic-test-question'))),
          draft.current.questionId,
        )!;
        expect(find.text(q.prompt(code)), findsOneWidget, reason: q.id);
        await _answer(tester, s, deck, correct: i.isEven);
        expect(
          find.text(i.isEven ? l.quizCorrect : l.quizIncorrect),
          findsWidgets,
        );
        await _tapKey(tester, 'topic-test-next');
      }

      // Natija: 5/10, har xato uchun tahlil kartasi va slayd havolasi.
      expect(find.byKey(const ValueKey('topic-test-result')), findsOneWidget);
      final last = s.topicTests.last(deck)!;
      expect(last.correctCount, 5);
      expect(last.mistakeIndexes, hasLength(5));
      _noMissing(l);
      final ctx = tester.element(
        find.byKey(const ValueKey('topic-test-result')),
      );
      for (final i in last.mistakeIndexes) {
        final q = topicQuestion(ctx, last.items[i].questionId)!;
        final card = find.byKey(ValueKey('topic-review-$i'));
        await tester.ensureVisible(card);
        expect(card, findsOneWidget);
        expect(find.byKey(ValueKey('slide-link-${q.id}')), findsOneWidget);
      }
      // Bitta havola: deck kutilgan slaydda ochiladi.
      final q = topicQuestion(
        ctx,
        last.items[last.mistakeIndexes.first].questionId,
      )!;
      final want = matchSlide(
        q,
        entry,
        code,
        analyteNames: packAnalyteNames(s.content.pack),
      );
      final slides = entry.slides(code);
      await _tapKey(tester, 'slide-link-${q.id}');
      expect(
        find.text(l.lectureCounter((want ?? 0) + 1, slides)),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip(l.lectureClose));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('topic-test-result')), findsOneWidget);

      // Xatolarni takrorlash: faqat xatolar; hammasi to'g'ri.
      await _tapKey(tester, 'topic-test-rework');
      final rework = s.topicTests.draft(deck)!;
      expect(rework.mode, ExamMode.rework);
      expect(rework.length, 5);
      expect(rework.items.map((e) => e.questionId).toSet(), {
        for (final i in last.mistakeIndexes) last.items[i].questionId,
      });
      for (var i = 0; i < rework.length; i++) {
        _noMissing(l);
        await _answer(tester, s, deck, correct: true);
        await _tapKey(tester, 'topic-test-next');
      }
      expect(find.byKey(const ValueKey('topic-test-rework')), findsNothing);
      expect(s.topicTests.best(deck)!.correct, 5);

      // “Ilova qayta ochildi”: yangi servislar, o'sha ombor.
      await tester.pumpWidget(const SizedBox());
      final s2 = await makeServices(
        tester,
        store: store,
        role: AppRole.student,
        language: lang,
      );
      await pumpApp(tester, s2, size: _iphone);
      expect(s2.topicTests.best(deck)!.correct, 5);
      expect(s2.topicTests.history(deck), hasLength(2));
      await goTo(tester, '/learn/lecture/test/$deck');
      expect(find.byKey(const ValueKey('topic-test-result')), findsOneWidget);
      expect(find.text(l.topicTestBest(5, kTopicTestSize)), findsWidgets);
      _noMissing(l);
      await goTo(tester, '/learn/lecture');
      final badge = find.byKey(ValueKey('deck-test-score-$deck'));
      await tester.scrollUntilVisible(
        badge,
        400,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      expect(tester.widget<Text>(badge).data, '5/$kTopicTestSize');
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });
  }

  for (final deck in ['d040', 'd118', 'd048']) {
    for (final lang in AppLanguage.values) {
      testWidgets('360×640 ×1.3: $deck (${lang.name}) — savol, natija, '
          'tahlil sig‘adi', (tester) async {
        installDiffFakes();
        final s = await makeServices(
          tester,
          role: AppRole.student,
          language: lang,
        );
        await pumpApp(tester, s, size: const Size(360, 640), textScale: 1.3);
        await goTo(tester, '/learn/lecture/test/$deck');
        expect(tester.takeException(), isNull);
        await _tapKey(tester, 'topic-test-start');
        final n = s.topicTests.draft(deck)!.length;
        for (var i = 0; i < n; i++) {
          await _answer(tester, s, deck, correct: i < 3);
          expect(tester.takeException(), isNull, reason: 'savol $i');
          await _tapKey(tester, 'topic-test-next');
        }
        expect(find.byKey(const ValueKey('topic-test-result')), findsOneWidget);
        // Natija oxirigacha (tahlil kartalari) o'tiladi.
        await tester.fling(
          find.byType(Scrollable).hitTestable().first,
          const Offset(0, -4000),
          3000,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.text(lookupAppLocalizations(lang.locale).examQuestionMissing),
          findsNothing,
        );
      });
    }
  }
}
