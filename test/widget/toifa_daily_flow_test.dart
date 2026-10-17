import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/daily/daily_reminder.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';
import 'package:labguide/features/toifa/toifa_controller.dart';
import 'package:labguide/features/toifa/toifa_daily.dart';
import 'package:labguide/features/toifa/toifa_screens.dart';
import 'package:labguide/features/toifa/toifa_today.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/daily_fakes.dart';
import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));

const _tall = Size(390, 2400);

/// Mashq testidagi joriy savolga to'g'ri yoki noto'g'ri javob (ekrandagi
/// matn bo'yicha).
Future<void> _answerDrill(
  WidgetTester tester,
  ToifaController toifa, {
  required bool correct,
}) async {
  final d = toifa.activeDrill!;
  final q = toifa.bank!.test(d.ids[d.index])!;
  final key = d.keys[d.index];
  final idx = correct
      ? key
      : List.generate(q.optionCount, (i) => i).firstWhere((i) => i != key);
  await tapScroll(tester, q.options[idx]);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('mashq rejimi: javobdan keyin darhol to‘g‘ri/xato, kalit; '
      'ilova yopilsa davom', (tester) async {
    final store = MemoryKeyValueStore();
    final s = await makeServices(tester, store: store);
    s.toifa.random = Random(4);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/toifa/test');
    // Rejim aniq tanlanadi.
    expect(find.text(uz.toifaModeExam), findsOne);
    expect(find.text(uz.toifaModePractice), findsOne);
    await tester.tap(find.byKey(const ValueKey('toifa-mode-practice')));
    await tester.pumpAndSettle();
    expect(s.toifa.testMode, ToifaTestMode.practice);
    // Mashq rejimida vaqt maydoni yo'q.
    expect(find.text(uz.toifaTimeLabel), findsNothing);
    await tapScroll(tester, uz.toifaDrillStart);
    expect(find.byType(ToifaDrillScreen), findsOne);
    final d = s.toifa.activeDrill!;
    expect(d.length, ToifaFormat.testSize);
    expect(s.exams.active, isNull, reason: 'imtihon emas');

    // Xato javob — darhol ko'rinadi.
    expect(find.text(uz.toifaPracticeWrong), findsNothing);
    final firstId = d.ids[0];
    await _answerDrill(tester, s.toifa, correct: false);
    expect(find.text(uz.toifaPracticeWrong), findsOne);
    expect(find.text(uz.quizIncorrect), findsOne);
    expect(find.text(uz.quizYourAnswer), findsOne);
    expect(s.quizProgress.statFor(firstId)!.lastCorrect, false);
    expect(s.toifa.todayStats, const ToifaDay(answered: 1));
    await tapScroll(tester, uz.quizNext);

    // To'g'ri javob.
    await _answerDrill(tester, s.toifa, correct: true);
    expect(find.text(uz.toifaPracticeRight), findsOne);
    expect(find.text(uz.quizCorrect), findsOne);
    expect(s.toifa.todayStats, const ToifaDay(answered: 2, correct: 1));

    // Ilova "yopildi": yangi servislar shu ombordan — shu joydan davom.
    final again = await makeServices(tester, store: store);
    expect(again.toifa.activeDrill!.answeredCount, 2);
    await pumpApp(tester, again, size: _tall);
    await goTo(tester, '/learn/toifa/test');
    expect(find.text(uz.toifaDrillActive(2, 50)), findsOne);
    await tapScroll(tester, uz.examResume);
    expect(find.text(uz.toifaPracticeRight), findsOne);
    // Bugun kartasi "Davom ettirish" ham shu yerga olib boradi.
    expect(toifaContinueLocation(again), '$toifaBase/test/practice');
  });

  testWidgets('imtihon rejimi: javobdan keyin to‘g‘ri/xato ko‘rinmaydi; '
      'natijada xatolar va kunlik hisob', (tester) async {
    final s = await makeServices(tester);
    s.exams.random = Random(3);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/toifa/test');
    expect(s.toifa.testMode, ToifaTestMode.exam);
    await tapScroll(tester, uz.toifaTestStart);
    final session = s.exams.active!;
    final bank = s.toifa.bank!;
    final q = bank.test(session.current.questionId)!;
    final wrong = List.generate(
      q.optionCount,
      (i) => i,
    ).firstWhere((i) => !q.key.contains(i));
    await tapScroll(tester, q.options[wrong]);
    expect(session.answerAt(0), [wrong]);
    // Imtihonda natija faqat oxirida.
    expect(find.text(uz.toifaPracticeWrong), findsNothing);
    expect(find.text(uz.quizIncorrect), findsNothing);
    expect(find.text(uz.quizCorrectAnswer), findsNothing);
    // Qolganlariga to'g'ri javob → yakun.
    for (var i = 1; i < session.length; i++) {
      session
        ..goTo(i)
        ..choose(session.items[i].correct.first);
    }
    await s.exams.save(session);
    await tapScroll(tester, uz.examFinish);
    await tester.tap(find.text(uz.examFinish).hitTestable().last);
    await tester.pumpAndSettle();
    expect(find.text('49 / 50'), findsOne);
    expect(find.text(uz.examReworkMistakes(1)), findsOne);
    expect(s.quizProgress.statFor(q.id)!.lastCorrect, false);
    // Kunlik hisob: 50 savol — maqsad bajarildi, taklif ko'rinadi.
    expect(s.toifa.todayStats, const ToifaDay(answered: 50, correct: 49));
    expect(s.toifa.todayGoalMet, true);
    expect(find.byKey(const ValueKey('toifa-reminder-offer')), findsOne);
  });

  testWidgets('mashq natijasi: chegara, xatolar ro‘yxati, faqat xatolar '
      'raundi; maqsaddan keyin eslatma taklifi', (tester) async {
    final reminders = FakeReminderScheduler();
    final s = await makeServices(
      tester,
      reminderScheduler: reminders,
      clock: () => DateTime(2026, 10, 17, 9),
    );
    await s.toifa.setGoal(20);
    final bank = s.toifa.bank!;
    final qs = bank.scorable.take(20).toList();
    final d = (await s.toifa.startDrill(qs, pass: 80))!;
    for (var i = 0; i < d.length; i++) {
      // 3 ta xato.
      final ok = i >= 3;
      await s.toifa.answerDrill(
        ok ? d.keys[i] : (d.keys[i] + 1) % qs[i].optionCount,
      );
      await s.toifa.drillNext();
    }
    expect(s.toifa.drill!.finished, true);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/toifa/test/practice');
    expect(find.text('17 / 20'), findsOne);
    expect(find.text(uz.examPassMet(80)), findsOne);
    expect(find.text(uz.quizMistakes), findsOne);
    expect(find.text(uz.toifaPracticeWrong), findsNothing);

    // Kunlik maqsad (20) bajarildi — "Ertaga davom etamizmi?".
    expect(find.text(uz.toifaOfferTitle), findsOne);
    expect(s.reminders.toifaEnabled, false, reason: 'standart o‘chiq');
    await tester.ensureVisible(
      find.byKey(const ValueKey('toifa-offer-switch')),
    );
    await tester.tap(find.byKey(const ValueKey('toifa-offer-switch')));
    await tester.pumpAndSettle();
    expect(s.reminders.toifaEnabled, true);
    expect(reminders.permissionRequests, 1);
    // Bugun bajarildi — birinchi eslatma ertaga 20:00 da.
    expect(
      reminders.plans[ReminderSlot.toifa]!.first,
      DateTime(2026, 10, 18, 20),
    );
    expect(find.text(uz.toifaOfferOn('20:00')), findsOne);

    // Faqat xatolar raundi.
    await tapScroll(tester, uz.examReworkMistakes(3));
    final rework = s.toifa.activeDrill!;
    expect(rework.rework, true);
    expect(rework.ids, [for (final q in qs.take(3)) q.id]);
    expect(find.text(qs[rework.index].text), findsOne);
    expect(find.text(uz.toifaDrillScore(0, 0)), findsOne);
  });

  testWidgets('hub va bosh sahifada “Bugun” kartasi: maqsad, seriya, '
      '7 kun, maqsadni o‘zgartirish', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _tall);
    // Hali ochilmagan — bosh sahifada kirish kartasi.
    expect(find.byType(ToifaEntryCard), findsOne);
    expect(find.byType(ToifaTodayCard), findsNothing);
    await goTo(tester, '/learn/toifa');
    expect(find.byType(ToifaTodayCard), findsOne);
    expect(find.text(uz.toifaTodayGoal(50)), findsOne);
    expect(find.text(uz.toifaTodayNone), findsOne);
    expect(s.toifa.opened, true);
    await s.toifa.recordAnswers(answered: 20, correct: 15);
    await tester.pumpAndSettle();
    expect(find.textContaining(uz.toifaTodayProgress(20, 50)), findsOne);
    expect(find.textContaining(uz.toifaTodayCorrect(75)), findsOne);
    // Maqsad 20 savol — bajarildi, seriya 1.
    await tapScroll(tester, uz.toifaGoalOption(20));
    expect(s.toifa.goalQuestions, 20);
    expect(find.text(uz.toifaTodayDone), findsOne);
    expect(find.text(uz.toifaStreakDays(1)), findsOne);
    expect(find.byType(ToifaWeekStrip), findsOne);
    // Bosh sahifa: endi "Bugun" kartasi.
    await goTo(tester, '/home');
    expect(find.byType(ToifaTodayCard), findsOne);
    expect(find.byType(ToifaEntryCard), findsNothing);
    final cont = find.descendant(
      of: find.byType(ToifaTodayCard),
      matching: find.text(uz.toifaContinue),
    );
    await tester.ensureVisible(cont);
    await tester.tap(cont);
    await tester.pumpAndSettle();
    // Bosh sahifadan — toifa bo'limi (davom etayotgan ish yo'q).
    expect(find.byType(ToifaHubScreen), findsOne);
    // Ustoz ham bo'limni ochgan bo'lsa — karta ko'rinadi; shifokorga yo'q.
    await s.settings.setRole(AppRole.teacher);
    await goTo(tester, '/home');
    expect(find.byType(ToifaTodayCard), findsOne);
    await s.settings.setRole(AppRole.doctor);
    await goTo(tester, '/home');
    expect(find.byType(ToifaTodayCard), findsNothing);
  });

  testWidgets('og‘zaki bilet: o‘ylash taymeri, reja, asosiy so‘zlar, baho, '
      'yakunda takrorlash ro‘yxati', (tester) async {
    final s = await makeServices(tester);
    s.toifa.random = Random(11);
    await s.toifa.setCategory(ToifaCategory.second);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/toifa/oral');
    await tapScroll(tester, uz.toifaDrawTicket);
    // Yozish shart emas — tayyorlanish matni.
    expect(find.text(uz.toifaPrepHint), findsOne);
    await tapScroll(tester, uz.toifaShowPlans);
    final ratings = [
      OralRating.knew,
      OralRating.unknown,
      OralRating.partial,
      OralRating.knew,
      OralRating.knew,
    ];
    for (final (i, r) in ratings.indexed) {
      expect(find.text(uz.toifaThinkHint), findsOne);
      expect(find.text(uz.toifaPlanPending), findsNothing, reason: 'yopiq');
      if (i == 0) {
        // Ixtiyoriy 3 daqiqalik taymer — to'xtatsa bo'ladi.
        await tester.tap(find.byKey(const ValueKey('toifa-think-start')));
        await tester.pump();
        expect(find.textContaining(uz.toifaThinkLeft('')), findsOne);
        await tester.pump(const Duration(seconds: 2));
        await tester.tap(find.byKey(const ValueKey('toifa-think-stop')));
        await tester.pumpAndSettle();
        expect(find.text(uz.toifaThinkTimer(3)), findsOne);
      }
      await tapScroll(tester, uz.toifaShowPlan);
      expect(find.text(uz.toifaPlanPending), findsOne);
      if (i == 0) {
        // Asosiy so'zlar ro'yxati (faqat reja/faktlar matnidan).
        await tester.ensureVisible(
          find.byKey(const ValueKey('toifa-checklist-switch')),
        );
        await tester.tap(find.byKey(const ValueKey('toifa-checklist-switch')));
        await tester.pumpAndSettle();
        expect(s.toifa.checklist, true);
        final q = s.toifa.bank!.oralQuestion(s.toifa.ticket!.currentId)!;
        final items = q.plan.length + q.reference.length + q.cutoffs.length;
        if (items > 0) {
          expect(find.text(uz.toifaChecklistCount(0, items)), findsOne);
          await tester.ensureVisible(find.byType(Checkbox).first);
          await tester.tap(find.byType(Checkbox).first);
          await tester.pumpAndSettle();
          expect(find.text(uz.toifaChecklistCount(1, items)), findsOne);
        }
      }
      await tapScroll(tester, r.label(uz));
    }
    final t = s.toifa.ticket!;
    expect(t.done, true);
    expect(find.text(uz.toifaTicketDone), findsOne);
    // Takrorlash: "Bilmadim" va "Qisman" — keyingi biletlarda birinchi.
    expect(find.text(uz.toifaRepeatTitle), findsOne);
    expect(find.text(uz.toifaRepeatNote), findsOne);
    expect(t.toRepeat.length, 2);
    // Bilet — kunlik maqsad; taklif ko'rinadi.
    expect(s.toifa.todayStats.tickets, 1);
    expect(find.text(uz.toifaOfferTitle), findsOne);
    // Keyingi biletda "Bilmadim" savoli bor.
    final unknown = t.ids.firstWhere(
      (id) => t.ratings[id] == OralRating.unknown,
    );
    await s.toifa.drawTicket(ToifaCategory.second);
    expect(s.toifa.ticket!.ids, contains(unknown));
  });

  // 320 px, katta shrift (×1.3): uz / ru / en — yangi ekranlar.
  for (final (lang, locale) in [
    (AppLanguage.uz, const Locale('uz', 'UZ')),
    (AppLanguage.ru, const Locale('ru', 'UZ')),
    (AppLanguage.en, const Locale('en', 'UZ')),
  ]) {
    testWidgets('layout 320 px ×1.3: ${lang.name} — bugun, rejimlar, mashq, '
        'eslatma, og‘zaki', (tester) async {
      final s = await makeServices(tester, language: lang);
      tester.platformDispatcher.localesTestValue = [locale];
      s.toifa.random = Random(1);
      await s.toifa.setCategory(ToifaCategory.first);
      await s.toifa.recordAnswers(answered: 50, correct: 41);
      await pumpApp(tester, s, size: const Size(320, 4000), textScale: 1.3);
      expect(tester.takeException(), isNull, reason: 'home');
      expect(find.byType(ToifaTodayCard), findsOne);
      await goTo(tester, '/learn/toifa');
      expect(tester.takeException(), isNull, reason: 'hub');
      await s.reminders.enableToifa();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'hub reminder');
      await s.toifa.setTestMode(ToifaTestMode.practice);
      await goTo(tester, '/learn/toifa/test');
      expect(tester.takeException(), isNull, reason: 'test practice');
      await s.toifa.setTestMode(ToifaTestMode.exam);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'test exam');
      // Mashq: savol, javob (xato), natija.
      final bank = s.toifa.bank!;
      final d = (await s.toifa.startDrill(
        bank.scorable.take(3).toList(),
        pass: 70,
      ))!;
      await goTo(tester, '/learn/toifa/test/practice');
      expect(tester.takeException(), isNull, reason: 'drill');
      await s.toifa.answerDrill((d.keys[0] + 1) % 3);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'drill answered');
      await s.toifa.finishDrill();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'drill result');
      // Og'zaki: savol (taymer), reja + asosiy so'zlar, yakun.
      await s.toifa.drawTicket(ToifaCategory.first);
      await s.toifa.startReview();
      await goTo(tester, '/learn/toifa/oral');
      expect(tester.takeException(), isNull, reason: 'oral question');
      await tester.ensureVisible(
        find.byKey(const ValueKey('toifa-think-start')),
      );
      await tester.tap(find.byKey(const ValueKey('toifa-think-start')));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'think timer');
      await tester.tap(find.byKey(const ValueKey('toifa-think-stop')));
      await tester.pumpAndSettle();
      await s.toifa.setChecklist(true);
      await s.toifa.reveal();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'oral plan');
      for (var i = 0; i < 5; i++) {
        await s.toifa.rateCurrent(OralRating.values[i % 3]);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'oral summary');
      // Imtihon natijasi (toifa) — eslatma taklifi bilan.
      final session = ExamSession.build(
        id: 'r1',
        mode: ExamMode.exam,
        questions: [bank.test('kdl-t-005')!],
        random: Random(1),
        startedAt: s.exams.now(),
        sourceId: ToifaQuestionSource.sourceId,
        shuffleOptions: false,
        passPercent: 70,
      );
      await s.exams.start(session);
      await s.exams.finishActive();
      await goTo(tester, '/learn/toifa/test/result/r1');
      expect(find.byKey(const ValueKey('toifa-reminder-offer')), findsOne);
      expect(tester.takeException(), isNull, reason: 'exam result');
    });
  }
}
