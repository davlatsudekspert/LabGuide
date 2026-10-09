import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));
final en = lookupAppLocalizations(const Locale('en'));

const _tall = Size(390, 1400);

/// Imtihonni UI orqali boshlash: mavzu (bo'lsa), soni va daqiqasi.
Future<ExamSession> _startExam(
  WidgetTester tester,
  AppServices s,
  AppLocalizations l, {
  String? topic,
  required int count,
  required int minutes,
}) async {
  await goTo(tester, '/learn/exam');
  if (topic != null) await tapScroll(tester, topic);
  await enterField(tester, l.examCount, '$count');
  await enterField(tester, l.examTime, '$minutes');
  await tapScroll(tester, l.examStart);
  return s.exams.active!;
}

Future<void> _finishViaDialog(WidgetTester tester, AppLocalizations l) async {
  await tapScroll(tester, l.examFinish);
  await tester.tap(find.text(l.examFinish).hitTestable().last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('mehmon, internetsiz: mavzu → imtihon → natija → xatolar', (
    tester,
  ) async {
    final s = await makeServices(tester);
    s.exams.random = Random(5);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/exam');
    await tester.scrollUntilVisible(
      find.text(uz.examHistoryEmpty),
      400,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.scrollUntilVisible(
      find.text(uz.examTopics),
      -400,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );

    // Noto'g'ri son — imtihon boshlanmaydi, xato aniq aytiladi.
    await tapScroll(tester, 'Buyrak funksiyasi · 8');
    await enterField(tester, uz.examCount, '0');
    await tapScroll(tester, uz.examStart);
    expect(find.text(uz.examCountError(8)), findsOneWidget);
    expect(s.exams.active, isNull);
    // Raqam maydoni — raqamli klaviatura.
    final countField = tester.widget<TextField>(
      find
          .descendant(
            of: find
                .ancestor(
                  of: find.text(uz.examCount).last,
                  matching: find.byType(Column),
                )
                .first,
            matching: find.byType(TextField),
          )
          .first,
    );
    expect(countField.keyboardType, TextInputType.number);

    await enterField(tester, uz.examCount, '3');
    await tapScroll(tester, uz.examMinutes(10));
    await tapScroll(tester, uz.examStart);
    final exam = s.exams.active!;
    expect(exam.length, 3);
    expect(exam.limit, const Duration(minutes: 10));
    expect(exam.topicIds, ['kidney']);
    expect(exam.items.every((i) => i.topicIds.contains('kidney')), isTrue);
    // Hamma savol qoralama — belgisi ko'rinadi.
    expect(find.text(uz.quizDraftTag), findsOneWidget);
    expect(find.text(uz.examAnsweredOf(0, 3)), findsOneWidget);

    await answerCurrent(tester, s, exam, correct: true);
    await tapScroll(tester, uz.examFlag);
    expect(exam.isFlagged(0), isTrue);
    // Tugma va xarita izohida.
    expect(find.text(uz.examFlagged), findsNWidgets(2));
    await tapScroll(tester, uz.examNext);
    await answerCurrent(tester, s, exam, correct: false);
    // Orqaga — javob saqlangan; xarita orqali uchinchi savolga.
    await tapScroll(tester, uz.examPrev);
    expect(exam.index, 0);
    expect(exam.isAnswered(0), isTrue);
    await tester.tap(find.bySemanticsLabel(RegExp('^${uz.examQuestionN(3)}')));
    await tester.pumpAndSettle();
    expect(exam.index, 2);
    expect(find.text(uz.examFinish), findsWidgets);

    await tester.tap(find.text(uz.examFinish).hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text(uz.examFinishBody(1, 1)), findsOneWidget);
    await tester.tap(find.text(uz.examFinish).hitTestable().last);
    await tester.pumpAndSettle();

    // Natija: foiz, to'g'ri/xato, xatolar tahlili (to'g'ri javob va izoh).
    expect(find.text(uz.examResultTitle), findsWidgets);
    expect(find.text(uz.quizScore(1, 3)), findsOneWidget);
    expect(find.text('33%'), findsOneWidget);
    expect(s.exams.active, isNull);
    final done = s.exams.history.single;
    expect(done.correctCount, 1);
    expect(done.mistakeIndexes.length, 2);
    final source = PackQuestionSource.of(s.content.pack!);
    final wrong = source.question(done.items[1].questionId)!;
    await tester.scrollUntilVisible(
      find.text(wrong.prompt('uz')),
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(
      find.text(wrong.explanation(done.items[1].correct.single, 'uz')!),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text(uz.examNoAnswer),
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    // Mashq tarixiga ham yozildi (“xatolarim ustida ishlash”).
    expect(s.quizProgress.mistakes([wrong.id]), [wrong.id]);

    // Xatolarni qayta ishlash — faqat xato/javobsiz savollar, vaqtsiz.
    await tapScroll(tester, uz.examReworkMistakes(2));
    final rework = s.exams.active!;
    expect(rework.mode, ExamMode.rework);
    expect(rework.length, 2);
    expect(rework.limit, isNull);
    expect(find.text(uz.examReworkTitle), findsOneWidget);
  });

  testWidgets('vaqt tugasa imtihon o‘zi yakunlanadi', (tester) async {
    final s = await makeServices(tester);
    var now = DateTime(2026, 10, 9, 9);
    s.exams.now = () => now;
    await pumpApp(tester, s, size: _tall);
    final exam = await _startExam(tester, s, uz, count: 4, minutes: 5);
    await answerCurrent(tester, s, exam, correct: true);
    expect(find.text('5:00'.padLeft(5, '0')), findsOneWidget);

    now = now.add(const Duration(minutes: 4, seconds: 30));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:30'), findsOneWidget);

    now = now.add(const Duration(minutes: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text(uz.examTimedOut), findsOneWidget);
    final done = s.exams.history.single;
    expect(done.timedOut, isTrue);
    expect(done.finishedAt, exam.deadline);
    expect(done.correctCount, 1);
  });

  testWidgets('ilova qayta ochilsa — imtihon davom etadi yoki halol yakun', (
    tester,
  ) async {
    final store = MemoryKeyValueStore();
    final start = DateTime(2026, 10, 9, 9);
    var s = await makeServices(tester, store: store, language: AppLanguage.en);
    s.exams.now = () => start;
    await pumpApp(tester, s, size: _tall);
    final exam = await _startExam(tester, s, en, count: 5, minutes: 20);
    await answerCurrent(tester, s, exam, correct: true, lang: 'en');
    await tapScroll(tester, en.examNext);
    final firstAnswer = exam.answerAt(0);

    // Tizim ilovani yopdi; 5 daqiqadan keyin qayta ochildi.
    await tester.pumpWidget(const SizedBox());
    s = await makeServices(tester, store: store, language: AppLanguage.en);
    s.exams.now = () => start.add(const Duration(minutes: 5));
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn');
    expect(find.text(en.examActiveBody(1, 5, '15:00')), findsOneWidget);
    await goTo(tester, '/learn/exam');
    expect(find.text(en.examActiveTitle.toUpperCase()), findsOneWidget);
    await tapScroll(tester, en.examResume);
    final resumed = s.exams.active!;
    expect(resumed.index, 1);
    expect(resumed.answerAt(0), firstAnswer);
    expect(find.text('15:00'), findsOneWidget);
    expect(find.text(en.examAnsweredOf(1, 5)), findsWidgets);

    // Yana yopildi va vaqt tugagach ochildi: halol “vaqt tugadi”.
    await tester.pumpWidget(const SizedBox());
    s = await makeServices(tester, store: store, language: AppLanguage.en);
    s.exams.now = () => start.add(const Duration(hours: 2));
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/exam');
    await tester.pumpAndSettle();
    expect(find.text(en.examSettled), findsOneWidget);
    expect(s.exams.active, isNull);
    final done = s.exams.history.single;
    expect(done.timedOut, isTrue);
    expect(done.spent(start), const Duration(minutes: 20));
    await tester.tap(find.text(en.examOpenResult));
    await tester.pumpAndSettle();
    expect(find.text(en.examTimedOut), findsOneWidget);
    expect(find.text(en.quizScore(1, 5)), findsOneWidget);
  });

  testWidgets('ochiq imtihon sahifasi tizim tiklashidan keyin qaytadi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _tall);
    final exam = await _startExam(tester, s, uz, count: 3, minutes: 10);
    await answerCurrent(tester, s, exam, correct: false);
    await tester.restartAndRestore();
    await tester.pumpAndSettle();
    expect(find.text(uz.examAnsweredOf(1, 3)), findsOneWidget);
    expect(find.text(uz.examPrev), findsOneWidget);
  });

  testWidgets('aralash mavzular: mavzu bo‘yicha tahlil, tarix va progress', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    s.exams.random = Random(11);
    await pumpApp(tester, s, size: _tall);
    for (var round = 0; round < 2; round++) {
      final exam = await _startExam(tester, s, en, count: 12, minutes: 15);
      for (var i = 0; i < exam.length; i++) {
        await answerCurrent(tester, s, exam, correct: i.isEven, lang: 'en');
        if (i < exam.length - 1) await tapScroll(tester, en.examNext);
      }
      await _finishViaDialog(tester, en);
    }
    expect(find.text(en.examByTopic), findsOneWidget);
    expect(s.exams.history.length, 2);
    expect(find.text(en.examDeltaSame), findsOneWidget);
    await goTo(tester, '/learn/exam');
    await tester.scrollUntilVisible(
      find.text(en.examHistoryStats(2, 50, 50)),
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.text('50%'), findsNWidgets(2));
  });

  testWidgets('imtihon ekranlari: bosiladigan maydonlar ≥ 44 px', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s);
    await _startExam(tester, s, uz, count: 3, minutes: 10);
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await _finishViaDialog(tester, uz);
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  });

  // Imtihon ekranlari (faol imtihon va natija bilan) — tor ekran, katta
  // shrift, qorong'i mavzu: layout xatosi bo'lmasligi kerak.
  for (final lang in AppLanguage.values) {
    for (final (width, scale, theme) in [
      (320.0, 2.0, ThemeMode.light),
      (390.0, 1.0, ThemeMode.dark),
      (430.0, 1.35, ThemeMode.light),
    ]) {
      testWidgets('exam layout: ${lang.name} ${width.toInt()} ×$scale '
          '${theme.name}', (tester) async {
        final l = lookupAppLocalizations(lang.locale);
        final s = await makeServices(tester, language: lang, themeMode: theme);
        await pumpApp(tester, s, size: Size(width, 3200), textScale: scale);
        final exam = await _startExam(tester, s, l, count: 4, minutes: 10);
        expect(tester.takeException(), isNull);
        await answerCurrent(tester, s, exam, correct: false, lang: lang.name);
        // Tor ekranda tugma faqat belgi bilan — nomi semantikada.
        await tester.tap(find.bySemanticsLabel(l.examFlag));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await _finishViaDialog(tester, l);
        expect(tester.takeException(), isNull, reason: 'result');
        await tapScroll(tester, l.examFilterAll(4));
        expect(tester.takeException(), isNull, reason: 'all answers');
        await goTo(tester, '/learn/exam');
        expect(tester.takeException(), isNull, reason: 'setup + history');
      });
    }
  }
}
