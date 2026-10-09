// Kunlik savol, ketma-ketlik, eslatma va natijani ulashish — foydalanuvchi
// sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_daily_test.dart --update-goldens
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/daily/daily_screens.dart';
import 'package:labguide/features/daily/daily_streak.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import '../../test/helpers/learn_helpers.dart';
import 'walk_helper.dart';

/// Bugungi savollarga javob: juft savollarga “A”, toqlarga “B”.
Future<void> answerAll(Walk w, AppLocalizations l, {int snapAt = -1}) async {
  for (var i = 0; i < 5; i++) {
    await tapScroll(w.tester, i.isEven ? 'A' : 'B');
    if (i == snapAt) {
      await w.snap('javob_izoh');
      await w.scroll(500);
      await w.snap('javob_manba');
    }
    await tapScroll(w.tester, i == 4 ? l.dailyShowResult : l.quizNext);
  }
}

/// Kunlik kartani ekranga olib kelish.
Future<void> showCard(WidgetTester tester) async {
  final scrollable = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable()
      .first;
  await tester.drag(scrollable, const Offset(0, 3000));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.byType(DailyCard),
    200,
    scrollable: scrollable,
  );
  await tester.drag(scrollable, const Offset(0, 260));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('kunlik savol — laborant (uz, yorug‘)', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    tester.platformDispatcher.localesTestValue = const [Locale('uz', 'UZ')];
    final s = await start(tester);
    final w = Walk(tester, 'daily_uz');
    await w.snap('bosh_sahifa');
    await showCard(tester);
    await w.snap('bosh_sahifa_karta');
    await tapScroll(tester, l.dailyStart);
    await w.snap('savol1');
    await answerAll(w, l, snapAt: 0);
    await w.snap('natija');
    await w.scroll(450);
    await w.snap('natija_seriya');
    await w.scroll(450);
    await w.snap('natija_taklif');
    await tapScroll(tester, l.dailyOfferYes);
    await w.snap('eslatma_yoqildi');
    await tapScroll(tester, l.dailyReminderTime);
    await w.snap('vaqt_tanlash');
    await tapScroll(tester, 'OK');
    await w.scroll(-5000);
    await tapScroll(tester, l.shareResult);
    await w.snap('ulashish_kartochka');
    await tester.tapAt(const Offset(20, 80));
    await tester.pumpAndSettle();
    // O'rganish tabidagi karta (bajarilgan holat).
    await goTo(tester, '/learn');
    await w.snap('organish_karta');
    // Qayta ochish: natija saqlangan.
    await goTo(tester, '/learn/daily');
    await w.snap('qayta_ochish');
    expect(s.daily.streak.current, 1);
  });

  testWidgets('kunlik savol — shifokor (ru, qorong‘i, katta shrift)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    tester.platformDispatcher.localesTestValue = const [Locale('ru', 'RU')];
    // Oldingi kunlar: 3 kun oldin va 2 kun oldin bajarilgan, kecha
    // o'tkazilgan — muzlatish seriyani saqlaydi.
    final today = dayOf(DateTime.now());
    final store = MemoryKeyValueStore({
      StoreKeys.dailyStreak: jsonEncode({
        'seed': 12345,
        'best': 6,
        'days': [today - 3, today - 2],
      }),
    });
    final s = await makeServices(
      tester,
      store: store,
      language: AppLanguage.ru,
      themeMode: ThemeMode.dark,
      role: AppRole.doctor,
    );
    await pumpApp(tester, s, textScale: 1.35);
    final w = Walk(tester, 'daily_ru_dark');
    await goTo(tester, '/learn');
    await w.snap('organish_karta');
    await tapScroll(tester, l.dailyStart);
    await w.snap('savol1');
    await answerAll(w, l, snapAt: 1);
    await w.snap('natija');
    await w.scroll(500);
    await w.snap('natija_seriya_muzlatish');
    await w.scroll(500);
    await w.snap('natija_taklif');
    await tapScroll(tester, l.dailyOfferNo);
    await w.snap('taklif_yopildi');
    await w.scroll(-5000);
    await tapScroll(tester, l.shareResult);
    await w.snap('ulashish_kartochka');
    expect(s.daily.streak.current, 3);
  });

  testWidgets('kunlik savol — talaba (en)', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    final s = await start(
      tester,
      lang: AppLanguage.en,
      role: AppRole.student,
      size: const Size(320, 640),
    );
    final w = Walk(tester, 'daily_en_320');
    await w.snap('home');
    await showCard(tester);
    await w.snap('home_card');
    await tapScroll(tester, l.dailyStart);
    await w.snap('q1');
    await tapScroll(tester, 'A');
    await w.snap('q1_answered');
    await tapScroll(tester, l.quizNext);
    // Yarim yo'lda chiqib, bosh sahifaga qaytish — karta davom etishni
    // taklif qiladi.
    await goTo(tester, '/home');
    await showCard(tester);
    await w.snap('home_card_progress');
    await tapScroll(tester, l.dailyContinue);
    await w.snap('q2_continue');
    for (var i = 1; i < 5; i++) {
      await tapScroll(tester, 'A');
      await tapScroll(tester, i == 4 ? l.dailyShowResult : l.quizNext);
    }
    await w.snap('result');
    await tapScroll(tester, l.shareResult);
    await w.snap('share_card');
    expect(s.daily.todaySet!.done, isTrue);
  });
}
