import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/learn/learn_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';
import 'package:labguide/features/toifa/toifa_controller.dart';
import 'package:labguide/features/toifa/toifa_screens.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));
final ru = lookupAppLocalizations(const Locale('ru'));

const _tall = Size(390, 2400);

const _routes = [
  '/learn/toifa',
  '/learn/toifa/test',
  '/learn/toifa/practice',
  '/learn/toifa/practice/hemostasis',
  '/learn/toifa/practice/mixed',
  '/learn/toifa/oral',
  '/learn/toifa/oral/q/kdl-o-001',
  '/learn/toifa/oral/q/kdl-o-207',
  '/learn/toifa/mistakes',
  '/learn/toifa/progress',
];

Future<ToifaBank> _bank() async {
  final c = ToifaController(MemoryKeyValueStore(), bundle: rootBundle);
  await c.ensureLoaded();
  return c.bank!;
}

void main() {
  setUpAll(loadAppFonts);

  group('ko‘rinish qoidasi', () {
    test('til uz yoki mintaqa UZ', () {
      expect(toifaAvailable(AppLanguage.uz, const [Locale('en', 'US')]), true);
      expect(toifaAvailable(AppLanguage.ru, const [Locale('ru', 'UZ')]), true);
      expect(toifaAvailable(AppLanguage.en, const [Locale('uz', 'UZ')]), true);
      expect(toifaAvailable(AppLanguage.ru, const [Locale('ru', 'RU')]), false);
      expect(toifaAvailable(AppLanguage.en, const [Locale('en', 'US')]), false);
      expect(toifaAvailable(AppLanguage.ru, const [Locale('ru')]), false);
    });

    for (final (lang, locale, visible) in [
      (AppLanguage.uz, const Locale('en', 'US'), true),
      (AppLanguage.ru, const Locale('ru', 'UZ'), true),
      (AppLanguage.ru, const Locale('ru', 'RU'), false),
      (AppLanguage.en, const Locale('en', 'US'), false),
    ]) {
      testWidgets('${lang.name} + ${locale.toLanguageTag()} → '
          '${visible ? 'ko‘rinadi' : 'yashirin'}', (tester) async {
        final s = await makeServices(tester, language: lang);
        tester.platformDispatcher.localesTestValue = [locale];
        await pumpApp(tester, s, size: _tall);
        // Laborant bosh sahifasi — tezkor amal.
        expect(find.byType(ToifaEntryCard), visible ? findsOne : findsNothing);
        await goTo(tester, '/learn');
        expect(find.byType(ToifaEntryCard), visible ? findsOne : findsNothing);
        // To'g'ridan-to'g'ri manzil ham faqat ko'rinadiganlarga ochiladi.
        await goTo(tester, '/learn/toifa');
        expect(find.byType(ToifaHubScreen), visible ? findsOne : findsNothing);
        if (!visible) expect(find.byType(LearnScreen), findsOne);
        // ru interfeys — savollar o'zbekcha ekani aytiladi.
        if (visible && lang == AppLanguage.ru) {
          expect(find.text(ru.toifaUzbekOnly), findsWidgets);
        }
        // Boshqa rolda bosh sahifada karta yo'q.
        await s.settings.setRole(AppRole.doctor);
        await goTo(tester, '/home');
        expect(find.byType(ToifaEntryCard), findsNothing);
      });
    }
  });

  group('bank', () {
    test('asset to‘liq va kalitlar to‘g‘ri', () async {
      final bank = await _bank();
      expect(bank.tests.length, 488);
      expect(bank.scorable.length, bank.tests.length - bank.keyless);
      for (final q in bank.scorable) {
        expect(q.key.length, 1, reason: q.id);
        expect(q.key.first, lessThan(q.optionCount), reason: q.id);
      }
      expect(bank.verdictCount(KeyVerdict.disputed), greaterThan(0));
      for (final c in ToifaCategory.values) {
        expect(bank.oralFor(c).length, greaterThanOrEqualTo(100));
      }
      // Asl matnlar va javoblar fayllari belgilari ilovaga kirmaydi.
      final raw = await rootBundle.loadString(ToifaController.testsAsset);
      final oral = await rootBundle.loadString(ToifaController.oralAsset);
      for (final f in ['q_orig', 'options_orig', 'source_answers', 'src']) {
        expect(raw.contains('"$f"'), false, reason: f);
        expect(oral.contains('"$f"'), false, reason: f);
      }
      expect(jsonDecode(raw), isA<Map<String, Object?>>());
    });
  });

  testWidgets('test: 50 savol, variantlar ro‘yxat tartibida, natija', (
    tester,
  ) async {
    final s = await makeServices(tester);
    s.exams.random = Random(3);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/toifa/test');
    await tapScroll(tester, uz.toifaTestStart);
    final session = s.exams.active!;
    expect(session.length, ToifaFormat.testSize);
    expect(session.sourceId, ToifaQuestionSource.sourceId);
    expect(session.limit, isNull, reason: 'sukut — vaqtsiz');
    expect(session.passPercent, isNull);
    final bank = s.toifa.bank!;
    expect(session.items.map((i) => i.questionId).toSet().length, 50);
    for (final item in session.items) {
      final q = bank.test(item.questionId)!;
      expect(q.scorable, true);
      expect(item.order, List.generate(q.optionCount, (i) => i));
    }
    // Yechish ekrani ochilgan (to'liq ekran).
    expect(find.text(uz.toifaTestTitle), findsWidgets);
    // Hammasiga rasmiy kalit bo'yicha javob → 100%.
    for (var i = 0; i < session.length; i++) {
      session
        ..goTo(i)
        ..choose(session.items[i].correct.first);
    }
    await s.exams.save(session);
    await tapScroll(tester, uz.examFinish);
    await tester.tap(find.text(uz.examFinish).hitTestable().last);
    await tester.pumpAndSettle();
    expect(s.exams.history.first.percent, 100);
    expect(find.text('50 / 50'), findsOne);
    // Javoblar mashq tarixiga ham yozildi.
    expect(s.quizProgress.mastered(session.items.map((i) => i.questionId)), 50);
  });

  testWidgets('vaqt va o‘tish chegarasi sozlanadi va saqlanadi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/toifa/test');
    await enterField(tester, uz.toifaTimeLabel, '500');
    await tapScroll(tester, uz.toifaTestStart);
    expect(find.text(uz.toifaTimeError), findsOne);
    expect(s.exams.active, isNull);
    await enterField(tester, uz.toifaTimeLabel, '60');
    await tapScroll(tester, '70%');
    await tapScroll(tester, uz.toifaTestStart);
    final session = s.exams.active!;
    expect(session.limit, const Duration(minutes: 60));
    expect(session.passPercent, 70);
    expect(s.toifa.testMinutes, 60);
    expect(s.toifa.testPass, 70);
  });

  testWidgets('bahsli kalit: rasmiy kalit + LabGuide izohi, ball rasmiy '
      'bo‘yicha', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _tall);
    final bank = s.toifa.bank!;
    final disputed = bank.test('kdl-t-121')!;
    expect(disputed.keyCheck.verdict, KeyVerdict.disputed);
    expect(disputed.keyCheck.suggested, isNotEmpty);
    final session = ExamSession.build(
      id: 'd1',
      mode: ExamMode.exam,
      questions: [disputed],
      random: Random(1),
      startedAt: s.exams.now(),
      sourceId: ToifaQuestionSource.sourceId,
      shuffleOptions: false,
      passPercent: 60,
    );
    // LabGuide taklif qilgan variant tanlanadi — rasmiy kalitga mos emas.
    session.choose(disputed.keyCheck.suggested.first);
    await s.exams.start(session);
    await s.exams.finishActive();
    expect(session.correctCount, 0);
    expect(session.passed, false);
    await goTo(tester, '/learn/toifa/test/result/d1');
    expect(find.text(uz.examPassMissed(60)), findsOne);
    expect(
      find.textContaining(uz.toifaOfficialKey, findRichText: true),
      findsWidgets,
    );
    expect(find.text(uz.toifaVerdictDisputed), findsOne);
    expect(find.text(uz.toifaLabGuideNote), findsOne);
    expect(find.textContaining(uz.toifaScoredByOfficial), findsOne);
    expect(find.text(uz.toifaListSource), findsOne);
  });

  testWidgets('mavzu bo‘yicha mashq: javobdan keyin kalit, xato yoziladi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/toifa/practice/hemostasis');
    final bank = s.toifa.bank!;
    final prompt = bank.scorable
        .where((q) => q.topic == 'hemostasis')
        .firstWhere((q) => find.text(q.text).evaluate().isNotEmpty);
    final wrong = List.generate(
      prompt.optionCount,
      (i) => i,
    ).firstWhere((i) => !prompt.key.contains(i));
    await tapScroll(tester, prompt.options[wrong]);
    expect(find.text(uz.toifaPracticeWrong), findsOne);
    expect(s.quizProgress.statFor(prompt.id)!.lastCorrect, false);
    await goTo(tester, '/learn/toifa/mistakes');
    expect(find.text(uz.toifaMistakesTests(1)), findsOne);
  });

  testWidgets('og‘zaki bilet: 5 savol, baholar saqlanadi', (tester) async {
    final store = MemoryKeyValueStore();
    final s = await makeServices(tester, store: store);
    s.toifa.random = Random(7);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/toifa/oral');
    // Toifa tanlanmaguncha bilet olinmaydi.
    expect(find.text(uz.toifaPickCategoryFirst), findsOne);
    await tapScroll(tester, uz.toifaCatHighest);
    await tapScroll(tester, uz.toifaDrawTicket);
    final ticket = s.toifa.ticket!;
    expect(ticket.ids.length, 5);
    expect(ticket.ids.toSet().length, 5);
    final pool = s.toifa.bank!.oralFor(ToifaCategory.highest).map((q) => q.id);
    expect(pool.toSet().containsAll(ticket.ids), true);
    await tapScroll(tester, uz.toifaShowPlans);
    final ratings = [
      OralRating.knew,
      OralRating.unknown,
      OralRating.partial,
      OralRating.knew,
      OralRating.unknown,
    ];
    for (final r in ratings) {
      await tapScroll(tester, uz.toifaShowPlan);
      expect(find.text(uz.toifaPlanPending), findsOne);
      await tapScroll(tester, r.label(uz));
    }
    expect(find.text(uz.toifaTicketDone), findsOne);
    expect(s.toifa.ticket!.done, true);

    // Qurilmada saqlangan: yangi controller xuddi shu holatni o'qiydi.
    final again = ToifaController(store, bundle: rootBundle);
    expect(again.category, ToifaCategory.highest);
    expect(again.ticket!.ids, ticket.ids);
    for (final (i, id) in ticket.ids.indexed) {
      expect(again.mark(id)!.rating, ratings[i]);
    }
    expect(again.oralWith(OralRating.unknown).length, 2);

    // “Bilmadim” xatolar ro'yxatida.
    await goTo(tester, '/learn/toifa/mistakes');
    expect(find.text(uz.toifaMistakesOralUnknown(2)), findsOne);

    // Lokal ma'lumotlarni o'chirish — hammasi tozalanadi.
    await s.deleteLocalData(const [Locale('uz')]);
    expect(s.toifa.ticket, isNull);
    expect(s.toifa.marks, isEmpty);
    expect(s.toifa.category, isNull);
  });

  // 320 px: uz yorug' va ru interfeys + UZ mintaqa, qorong'i, katta shrift.
  for (final (lang, locale, scale, theme) in [
    (AppLanguage.uz, const Locale('uz', 'UZ'), 1.0, ThemeMode.light),
    (AppLanguage.uz, const Locale('uz', 'UZ'), 2.0, ThemeMode.light),
    (AppLanguage.ru, const Locale('ru', 'UZ'), 1.35, ThemeMode.dark),
    (AppLanguage.ru, const Locale('ru', 'UZ'), 2.0, ThemeMode.dark),
    (AppLanguage.en, const Locale('en', 'UZ'), 1.35, ThemeMode.light),
  ]) {
    testWidgets('layout 320 px: ${lang.name} ×$scale ${theme.name}', (
      tester,
    ) async {
      final s = await makeServices(tester, language: lang, themeMode: theme);
      tester.platformDispatcher.localesTestValue = [locale];
      await s.toifa.setCategory(ToifaCategory.first);
      await pumpApp(
        tester,
        s,
        size: const Size(320, 4000),
        textScale: scale,
        platformBrightness: theme == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light,
      );
      expect(tester.takeException(), isNull, reason: 'home');
      for (final route in _routes) {
        await goTo(tester, route);
        expect(tester.takeException(), isNull, reason: route);
      }
      // Bilet holatlari: tayyorlanish, reja ochilgan, yakun.
      await s.toifa.drawTicket(ToifaCategory.first);
      await goTo(tester, '/learn/toifa/oral');
      expect(tester.takeException(), isNull, reason: 'prep');
      await s.toifa.startReview();
      await s.toifa.reveal();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'review');
      for (var i = 0; i < 5; i++) {
        await s.toifa.rateCurrent(OralRating.values[i % 3]);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'summary');
      // Test natijasi (bahsli savol bilan).
      final bank = s.toifa.bank!;
      final session = ExamSession.build(
        id: 'r1',
        mode: ExamMode.exam,
        questions: [bank.test('kdl-t-121')!, bank.test('kdl-t-005')!],
        random: Random(1),
        startedAt: s.exams.now(),
        sourceId: ToifaQuestionSource.sourceId,
        shuffleOptions: false,
        passPercent: 70,
      );
      await s.exams.start(session);
      await goTo(tester, '/learn/toifa/test/run');
      expect(tester.takeException(), isNull, reason: 'run');
      await s.exams.finishActive();
      // Yechish ekranida LgPage yo'q — router Scaffold orqali olinadi.
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .go('/learn/toifa/test/result/r1');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'result');
      await goTo(tester, '/learn/toifa/progress');
      expect(tester.takeException(), isNull, reason: 'progress');
    });
  }
}
