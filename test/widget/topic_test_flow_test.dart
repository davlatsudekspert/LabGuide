// Mavzu testi (taqdimot oxirida): deckdan boshlash, javob va darhol izoh,
// chiqib qaytib davom ettirish, yakun, xatolar tahlili, “Slaydni ko'rish”,
// qayta topshirish, xatolarni takrorlash, ro'yxatdagi natija belgisi —
// uz/ru/en; “savollar tayyorlanmoqda”; 320 px / 1.3x.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/lecture_decks.dart';
import 'package:labguide/features/classroom/topic_test.dart';
import 'package:labguide/features/classroom/topic_test_screens.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/harness.dart';

const _tall = Size(390, 2600);
const _deck = 'd013';

Future<DeckCatalog> _catalog(WidgetTester tester) async =>
    (await tester.runAsync(() => DeckCatalog.load(rootBundle)))!;

Future<LectureDeck> _preload(
  WidgetTester tester,
  String id,
  String lang,
) async {
  final c = await _catalog(tester);
  final e = c.byId(id)!;
  return (await tester.runAsync(
    () => DeckCatalog.loadDeck(rootBundle, e, e.resolveLang(lang)),
  ))!;
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Joriy savolga to'g'ri yoki noto'g'ri javob (ekrandagi variant kaliti).
Future<void> _answer(
  WidgetTester tester,
  AppServices s, {
  required bool correct,
}) async {
  final session = s.topicTests.draft(_deck)!;
  final item = session.current;
  final want = correct
      ? item.correct.single
      : item.order.firstWhere((o) => !item.correct.contains(o));
  await _tapKey(tester, 'topic-option-${item.order.indexOf(want)}');
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets(
      'talaba: deckdan test → davom ettirish → natija → slayd ($lang)',
      (tester) async {
        installDiffFakes();
        final l = lookupAppLocalizations(lang.locale);
        final code = lang.locale.languageCode;
        final c = await _catalog(tester);
        final entry = c.byId(_deck)!;
        final slides = (await _preload(tester, _deck, code)).slides.length;
        final s = await makeServices(
          tester,
          role: AppRole.student,
          language: lang,
        );
        await pumpApp(tester, s, size: _tall);

        // 1. Deckning oxirgi slaydi — “Mavzu testi”.
        await goTo(tester, '/learn/lecture/deck/$_deck?s=${slides - 1}');
        expect(find.text(l.lectureCounter(slides, slides)), findsOneWidget);
        await _tapKey(tester, 'lecture-topic-test');
        expect(find.byKey(const ValueKey('topic-test-intro')), findsOneWidget);
        expect(find.text(l.topicTestIntro(kTopicTestSize)), findsOneWidget);
        // Talabada “Guruhga topshirish” yo'q.
        expect(find.text(l.topicTestAssign), findsNothing);
        await _tapKey(tester, 'topic-test-start');

        // 2. Bitta savol: progress, javob — darhol izoh, qulflanadi.
        final draft = s.topicTests.draft(_deck)!;
        expect(draft.length, kTopicTestSize);
        expect(
          find.text(l.quizProgress(1, kTopicTestSize).toUpperCase()),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('topic-test-next')), findsNothing);
        await _answer(tester, s, correct: true);
        expect(find.text(l.quizCorrect), findsWidgets);
        // Ikkinchi bosish javobni o'zgartirmaydi.
        await _answer(tester, s, correct: false);
        expect(draft.isCorrect(0), isTrue);
        await _tapKey(tester, 'topic-test-next');
        expect(
          find.text(l.quizProgress(2, kTopicTestSize).toUpperCase()),
          findsOneWidget,
        );
        await _answer(tester, s, correct: false);
        expect(find.text(l.quizIncorrect), findsWidgets);
        expect(find.textContaining(l.quizCorrectAnswer), findsWidgets);
        await _tapKey(tester, 'topic-test-next');

        // 3. Chiqib ketish — qoralama qoladi; qaytganda shu joydan davom.
        await goTo(tester, '/learn');
        expect(s.topicTests.draft(_deck)!.index, 2);
        await goTo(tester, '/learn/lecture/test/$_deck');
        expect(
          find.text(l.quizProgress(3, kTopicTestSize).toUpperCase()),
          findsOneWidget,
        );
        for (var i = 2; i < kTopicTestSize; i++) {
          await _answer(tester, s, correct: i.isEven);
          await _tapKey(tester, 'topic-test-next');
        }

        // 4. Natija: ball, xatolar tahlili, tarix va eng yaxshi natija.
        expect(find.byKey(const ValueKey('topic-test-result')), findsOneWidget);
        final last = s.topicTests.last(_deck)!;
        expect(last.correctCount, 5);
        expect(s.topicTests.best(_deck)!.correct, 5);
        expect(s.topicTests.draft(_deck), isNull);
        expect(find.text(l.topicTestBest(5, kTopicTestSize)), findsOneWidget);
        expect(find.text(l.examAnalysis), findsOneWidget);
        expect(
          find.byKey(ValueKey('topic-review-${last.mistakeIndexes.first}')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('topic-test-next-topic')),
          findsOneWidget,
        );

        // 5. “Slaydni ko'rish” — deck mos slaydda ochiladi.
        final miss = last.mistakeIndexes.first;
        final q = topicQuestion(
          tester.element(find.byKey(const ValueKey('topic-test-result'))),
          last.items[miss].questionId,
        )!;
        final want = matchSlide(
          q,
          entry,
          code,
          analyteNames: packAnalyteNames(s.content.pack),
        );
        await _tapKey(tester, 'slide-link-${q.id}');
        expect(
          find.text(l.lectureCounter((want ?? 0) + 1, slides)),
          findsOneWidget,
        );
        await tester.tap(find.byTooltip(l.lectureClose));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('topic-test-result')), findsOneWidget);

        // 6. Xatolarni takrorlash — faqat xato savollar (mavjud mexanizm).
        final wrong = s.quizProgress.mistakes([
          for (final i in last.items) i.questionId,
        ]).length;
        expect(wrong, 5);
        expect(find.text(l.topicTestReworkMistakes(wrong)), findsOneWidget);
        await _tapKey(tester, 'topic-test-rework');
        final rework = s.topicTests.draft(_deck)!;
        expect(rework.mode, ExamMode.rework);
        expect(rework.length, wrong);
        expect(find.text(l.examReworkTitle), findsWidgets);
        for (var i = 0; i < rework.length; i++) {
          await _answer(tester, s, correct: true);
          await _tapKey(tester, 'topic-test-next');
        }
        // Takrorlash eng yaxshi natijani o'zgartirmaydi; xatolar tozalandi.
        expect(s.topicTests.best(_deck)!.correct, 5);
        expect(find.byKey(const ValueKey('topic-test-rework')), findsNothing);

        // 7. Qayta topshirish — yangi test.
        await _tapKey(tester, 'topic-test-retake');
        expect(s.topicTests.draft(_deck)!.mode, ExamMode.exam);
        expect(
          find.text(l.quizProgress(1, kTopicTestSize).toUpperCase()),
          findsOneWidget,
        );

        // 8. Ro'yxatda natija belgisi (5/10).
        await goTo(tester, '/learn/lecture');
        final badge = find.byKey(const ValueKey('deck-test-score-$_deck'));
        await tester.ensureVisible(badge);
        expect(tester.widget<Text>(badge).data, '5/$kTopicTestSize');
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('savol yetmasa — “tayyorlanmoqda”; protokolda tugma yo‘q', (
    tester,
  ) async {
    installDiffFakes();
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await makeServices(tester, role: AppRole.student);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/lecture');
    final row = find.byKey(const ValueKey('deck-d001'));
    await tester.ensureVisible(row);
    expect(
      find.descendant(
        of: row,
        matching: find.textContaining(l.topicTestPreparingShort),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('deck-test-d001')), findsNothing);
    expect(find.byKey(const ValueKey('deck-test-d013')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('deck-test-kapillyar-qon-olish')),
      findsNothing,
    );
    await goTo(tester, '/learn/lecture/test/d001');
    expect(find.byKey(const ValueKey('topic-test-preparing')), findsOneWidget);
    expect(find.text(l.topicTestPreparing), findsOneWidget);

    // Deck oxirida ham halol izoh, “Oldinga” o'chiq.
    final slides = (await _preload(tester, 'd001', 'uz')).slides.length;
    await goTo(tester, '/learn/lecture/deck/d001?s=${slides - 1}');
    expect(
      find.byKey(const ValueKey('lecture-test-preparing')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('lecture-topic-test')), findsNothing);
    // Protokol decki: na tugma, na menyu.
    final p = (await _preload(
      tester,
      'kapillyar-qon-olish',
      'uz',
    )).slides.length;
    await goTo(tester, '/learn/lecture/deck/kapillyar-qon-olish?s=${p - 1}');
    expect(find.byKey(const ValueKey('lecture-topic-test')), findsNothing);
    expect(find.byKey(const ValueKey('lecture-test-menu')), findsNothing);
  });

  testWidgets('ustoz «Mavzu testi»ni bossa — avval talabalarga topshirish', (
    tester,
  ) async {
    installDiffFakes();
    final s = await makeServices(tester, role: AppRole.teacher);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/lecture');
    final badge = find.byKey(const ValueKey('deck-test-$_deck'));
    await tester.ensureVisible(badge);
    await tester.pumpAndSettle();
    await tester.tap(badge);
    await tester.pumpAndSettle();
    final assign = find.byKey(const ValueKey('deck-test-choice-assign'));
    final self = find.byKey(const ValueKey('deck-test-choice-self'));
    expect(assign, findsOneWidget);
    expect(self, findsOneWidget);
    expect(tester.getTopLeft(assign).dy, lessThan(tester.getTopLeft(self).dy));
    await tester.tap(self);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('topic-test-intro')), findsOneWidget);
  });

  testWidgets('ro‘yxatda uzoq bosish — amallar; menyudan test', (tester) async {
    installDiffFakes();
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await makeServices(tester, role: AppRole.teacher);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/lecture');
    final row = find.byKey(const ValueKey('deck-$_deck'));
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.longPress(row);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('deck-action-test')), findsOneWidget);
    expect(find.byKey(const ValueKey('deck-action-assign')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('deck-action-test')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('topic-test-intro')), findsOneWidget);
    expect(find.byKey(const ValueKey('topic-test-assign')), findsOneWidget);
    // Pleyer menyusi.
    await _preload(tester, _deck, 'uz');
    await goTo(tester, '/learn/lecture/deck/$_deck');
    await _tapKey(tester, 'lecture-test-menu');
    expect(find.text(l.topicTestAssign), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('lecture-menu-test')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('topic-test-intro')), findsOneWidget);
  });

  for (final lang in AppLanguage.values) {
    testWidgets('320 px, 1.3x: savol va natija sig‘adi ($lang)', (
      tester,
    ) async {
      installDiffFakes();
      final s = await makeServices(
        tester,
        role: AppRole.student,
        language: lang,
      );
      await pumpApp(tester, s, size: const Size(320, 640), textScale: 1.3);
      await goTo(tester, '/learn/lecture/test/$_deck');
      expect(tester.takeException(), isNull);
      await _tapKey(tester, 'topic-test-start');
      for (var i = 0; i < kTopicTestSize; i++) {
        await _answer(tester, s, correct: i < 3);
        expect(tester.takeException(), isNull, reason: 'savol $i');
        await _tapKey(tester, 'topic-test-next');
      }
      expect(find.byKey(const ValueKey('topic-test-result')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await goTo(tester, '/learn/lecture');
      expect(tester.takeException(), isNull);
    });
  }
}
