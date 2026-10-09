import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/daily/daily_reminder.dart';
import 'package:labguide/features/daily/daily_screens.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/share/result_share.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/daily_fakes.dart';
import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final en = lookupAppLocalizations(const Locale('en'));
final uz = lookupAppLocalizations(const Locale('uz'));

/// Bugungi 5 savolning hammasiga birinchi variant bilan javob.
Future<void> answerAll(WidgetTester tester, AppLocalizations l) async {
  for (var i = 0; i < 5; i++) {
    await tapScroll(tester, 'A');
    await tapScroll(tester, i == 4 ? l.dailyShowResult : l.quizNext);
  }
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('en talaba: kartadan 5 savol, natija, eslatma, ulashish', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    final reminders = FakeReminderScheduler();
    final sharer = FakeResultSharer();
    final s = await makeServices(
      tester,
      language: AppLanguage.en,
      role: AppRole.student,
      reminderScheduler: reminders,
      sharer: sharer,
    );
    await pumpApp(tester, s, size: const Size(390, 1400));
    // Bosh sahifadagi karta.
    expect(find.text(en.dailyCardStart), findsOneWidget);
    await tapScroll(tester, en.dailyStart);
    expect(find.text(en.dailyTitle), findsWidgets);
    final set = s.daily.todaySet!;
    expect(set.sourceId, PackQuestionSource.sourceId);
    expect(set.ids, hasLength(5));
    // Faqat manbasi bor savollar.
    final source = PackQuestionSource.of(s.content.pack!);
    for (final id in set.ids) {
      expect(source.question(id)!.refs, isNotEmpty);
    }

    // Birinchi javob: izoh va manba ko'rinadi, savol almashmaydi.
    await tapScroll(tester, 'A');
    expect(s.daily.todaySet!.answeredCount, 1);
    expect(
      find.textContaining(en.quizSources).evaluate().isNotEmpty ||
          find.text(en.examNoSource).evaluate().isNotEmpty,
      isTrue,
    );
    await tapScroll(tester, en.quizNext);
    for (var i = 1; i < 5; i++) {
      await tapScroll(tester, 'A');
      await tapScroll(tester, i == 4 ? en.dailyShowResult : en.quizNext);
    }
    expect(s.daily.streak.current, 1);
    expect(find.text(en.dailyStreakTitle), findsOneWidget);
    // Birinchi kundan keyin muloyim taklif; standart o'chiq.
    expect(s.reminders.enabled, isFalse);
    expect(find.text(en.dailyOfferTitle), findsOneWidget);
    await tapScroll(tester, en.dailyOfferYes);
    expect(s.reminders.enabled, isTrue);
    expect(reminders.permissionRequests, 1);
    // Bugun bajarilgan — eslatma ertadan.
    expect(reminders.scheduled.first.day, isNot(s.daily.now().day));
    expect(find.text(en.dailyOfferTitle), findsNothing);

    // Ulashish: kartochka ko'rinishi, so'ng tizim oynasi (soxta).
    await tapScroll(tester, en.shareResult);
    expect(find.text(en.shareSheetTitle), findsOneWidget);
    expect(find.byType(ShareCard), findsOneWidget);
    final shareButton = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text(en.shareResult),
    );
    await tester.ensureVisible(shareButton);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(shareButton);
      for (var i = 0; i < 20 && sharer.shared.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();
    expect(sharer.shared, hasLength(1));
    final (png, text) = sharer.shared.single;
    // PNG imzosi.
    expect(png.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    expect(text, contains('LabGuide'));
    expect(text, contains('/5'));
    expect(find.text(en.shareSheetTitle), findsNothing);

    // Bosh sahifadagi karta — bajarilgan holat.
    await goTo(tester, '/home');
    expect(
      find.text(en.dailyCardDone(s.daily.todaySet!.correctCount, 5)),
      findsOneWidget,
    );
  });

  testWidgets('uz laborant: savollar toifa bankidan (faqat tekshirilgan)', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('uz', 'UZ')];
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 1400));
    await goTo(tester, kDailyLocation);
    final set = s.daily.todaySet!;
    expect(set.sourceId, ToifaQuestionSource.sourceId);
    final bank = s.toifa.bank!;
    for (final id in set.ids) {
      final q = bank.test(id)!;
      expect(q.scorable, isTrue);
      expect(q.keyCheck.verdict, KeyVerdict.ok);
      expect(q.keyCheck.unverified, isFalse);
    }
    expect(find.text(uz.dailySourceToifa), findsOneWidget);
    await answerAll(tester, uz);
    expect(find.text(uz.dailyStreakTitle), findsOneWidget);
    // Ilova qayta ochilganda ham — o'sha to'plam va natija.
    final again = await makeServices(
      tester,
      store: s.store as MemoryKeyValueStore,
    );
    expect(again.daily.todaySet!.ids, set.ids);
    expect(again.daily.streak.current, 1);
  });

  testWidgets('uz shifokor: toifa emas, kontent paketi savollari', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('uz', 'UZ')];
    final s = await makeServices(tester, role: AppRole.doctor);
    await pumpApp(tester, s, size: const Size(390, 1400));
    await goTo(tester, kDailyLocation);
    expect(s.daily.todaySet!.sourceId, isNot(ToifaQuestionSource.sourceId));
    expect(find.text(uz.dailySourceToifa), findsNothing);
  });

  testWidgets('ruxsat rad etilsa — halol xabar, eslatma o‘chiq', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    final s = await makeServices(
      tester,
      language: AppLanguage.en,
      reminderScheduler: FakeReminderScheduler(
        permission: ReminderPermission.denied,
      ),
    );
    await pumpApp(tester, s, size: const Size(390, 1400));
    await goTo(tester, kDailyLocation);
    await answerAll(tester, en);
    await tapScroll(tester, en.dailyOfferYes);
    expect(s.reminders.enabled, isFalse);
    expect(find.text(en.dailyReminderDenied), findsOneWidget);
    await tapScroll(tester, en.dailyOfferNo);
    expect(find.text(en.dailyOfferTitle), findsNothing);
    expect(s.reminders.enabled, isFalse);
  });

  testWidgets('bildirishnoma bosilsa — kunlik savol ochiladi', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    final reminders = FakeReminderScheduler();
    final s = await makeServices(
      tester,
      language: AppLanguage.en,
      reminderScheduler: reminders,
    );
    await pumpApp(tester, s);
    reminders.tap();
    await tester.pumpAndSettle();
    expect(find.byType(DailyScreen), findsOneWidget);
  });

  testWidgets('toifa natijasi kartochkasida “Rasmiy emas” yozuvi', (
    tester,
  ) async {
    await pumpApp(
      tester,
      await makeServices(tester),
      size: const Size(390, 900),
    );
    final context = tester.element(find.byType(Scaffold).first);
    unawaited(
      showShareSheet(
        context,
        ShareData(
          kind: ShareKind.toifa,
          correct: 41,
          total: 50,
          date: DateTime(2026, 10, 9),
          topic: uz.toifaTestTitle,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(uz.shareToifaNote), findsOneWidget);
    expect(find.text('41/50'), findsOneWidget);
    expect(
      ShareData(
        kind: ShareKind.toifa,
        correct: 41,
        total: 50,
        date: DateTime(2026, 10, 9),
      ).text(uz),
      contains(uz.shareToifaNote),
    );
  });

  // Tor ekran, juda katta shrift, tungi mavzu — har tilda overflow yo'q
  // (to'liq matritsa: layout_matrix_*_test.dart, `/learn/daily` qo'shilgan).
  for (final lang in AppLanguage.values) {
    testWidgets('layout: $lang 320px ×2.0 va tungi', (tester) async {
      tester.platformDispatcher.localesTestValue = [
        Locale(lang.name, lang == AppLanguage.uz ? 'UZ' : 'US'),
      ];
      for (final (scale, theme) in [
        (2.0, ThemeMode.light),
        (1.35, ThemeMode.dark),
      ]) {
        final s = await makeServices(tester, language: lang, themeMode: theme);
        await pumpApp(tester, s, size: const Size(320, 3200), textScale: scale);
        await goTo(tester, kDailyLocation);
        expect(tester.takeException(), isNull);
        final l = lookupAppLocalizations(Locale(lang.name));
        await answerAll(tester, l);
        expect(tester.takeException(), isNull);
        await tapScroll(tester, l.shareResult);
        expect(tester.takeException(), isNull);
        await tester.tapAt(const Offset(10, 60));
        await tester.pumpAndSettle();
        for (final route in ['/home', '/learn']) {
          await goTo(tester, route);
          expect(tester.takeException(), isNull, reason: route);
        }
        await tester.pumpWidget(const SizedBox());
      }
    });
  }
}
