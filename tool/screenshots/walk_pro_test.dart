// Pro huquqlari: Obuna ekranining halol holati va imtihon tarixi (bepul
// rejimda oxirgi 3 ta + "N ta eski natija saqlangan") — foydalanuvchi
// sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_pro_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import '../../test/helpers/learn_helpers.dart';
import 'walk_helper.dart';

Future<void> _quickExam(WidgetTester tester, AppLocalizations l) async {
  await goTo(tester, '/learn/exam');
  await enterField(tester, l.examCount, '3');
  await enterField(tester, l.examTime, '10');
  await tapScroll(tester, l.examStart);
  await tapScroll(tester, l.examFinish);
  await tester.tap(find.text(l.examFinish).hitTestable().last);
  await tester.pumpAndSettle();
}

Future<void> _history(Walk w, AppLocalizations l, {required int hidden}) async {
  await goTo(w.tester, '/learn/exam');
  final f = hidden > 0
      ? find.text(l.examHistoryHidden(hidden, 3))
      : find.text(l.examHistoryClear);
  await w.tester.scrollUntilVisible(
    f,
    250,
    scrollable: find
        .byWidgetPredicate(
          (x) => x is Scrollable && x.axisDirection == AxisDirection.down,
        )
        .hitTestable()
        .first,
  );
  await w.tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('pro uz: TestFlight/debug — hammasi ochiq', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    await start(tester);
    final w = Walk(tester, 'pro_uz_testflight');
    await goTo(tester, '/profile');
    await tapScroll(tester, l.profilePurchase);
    await w.snap('purchase');
    await w.scroll(400);
    await w.snap('purchase_bottom');
    for (var i = 0; i < 4; i++) {
      await _quickExam(tester, l);
    }
    await _history(w, l, hidden: 0);
    await w.snap('history_all');
  });

  testWidgets('pro ru: do‘kon build, qorong‘i, shrift 1.35', (tester) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
      allFeaturesOpen: false,
    );
    final w = Walk(tester, 'pro_ru_store');
    await goTo(tester, '/profile');
    await tapScroll(tester, l.profilePurchase);
    await w.snap('purchase');
    await w.scroll(500);
    await w.snap('purchase_bottom');
    for (var i = 0; i < 5; i++) {
      await _quickExam(tester, l);
    }
    await _history(w, l, hidden: 2);
    await w.snap('history_free');
  });

  testWidgets('pro en: store build', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    await start(tester, lang: AppLanguage.en, allFeaturesOpen: false);
    final w = Walk(tester, 'pro_en_store');
    await goTo(tester, '/profile');
    await tapScroll(tester, l.profilePurchase);
    await w.snap('purchase');
    for (var i = 0; i < 4; i++) {
      await _quickExam(tester, l);
    }
    await _history(w, l, hidden: 1);
    await w.snap('history_free');
  });
}
