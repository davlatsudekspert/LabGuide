// Lipidlar: “Davolash maqsadi” paneli, sutkalik siydik misol qiymatlari va
// kelib chiqish paneli (agent tekshiruvi ≠ mutaxassis tasdig'i) —
// foydalanuvchi sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_lipid_goals_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

Future<void> scrollToFind(WidgetTester tester, Finder finder) async {
  await tester.dragUntilVisible(
    finder,
    find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .hitTestable()
        .first,
    const Offset(0, -300),
    maxIteration: 200,
  );
  await tester.pumpAndSettle();
}

/// [finder] ni ekranning yuqori qismiga keltiradi.
Future<void> showAtTop(WidgetTester tester, Finder finder) async {
  await scrollToFind(tester, finder);
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.05);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('LDL-C maqsadlari (uz, yorug‘)', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await start(tester);
    String name(String id) => s.content.pack!.analyte(id)!.names.of('uz');
    final w = Walk(tester, 'lipid_goals_uz');
    await goTo(tester, '/tests');
    await w.snap('tahlillar');
    final lipids = s.content.pack!.group('lipids')!.names.of('uz');
    await tester.dragUntilVisible(
      find.text(lipids),
      find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.right,
          )
          .first,
      const Offset(-250, 0),
    );
    await tester.pumpAndSettle();
    await w.tapText(lipids);
    await w.snap('lipidlar');
    await w.tapText(name('ldl-c'));
    await w.snap('ldl_tepa');
    await showAtTop(tester, find.text(l.analyteRefIntervals));
    await w.snap('ldl_referens');
    await showAtTop(tester, find.text(l.analyteTreatmentGoals));
    await w.snap('ldl_maqsad_1');
    for (var i = 2; i <= 5; i++) {
      await w.scroll(650);
      await w.snap('ldl_maqsad_$i');
    }
    await showAtTop(tester, find.text(l.analyteReview));
    await w.snap('ldl_kelib_chiqish');
    await goTo(tester, '/tests');
    await goTo(tester, '/tests/analyte/urine-24h');
    await showAtTop(tester, find.text(l.sectionResults));
    await w.snap('siydik24_natija_1');
    await w.scroll(650);
    await w.snap('siydik24_natija_2');
    await showAtTop(tester, find.text(l.analyteRefIntervals));
    await w.snap('siydik24_referens');
  });

  testWidgets('LDL-C maqsadlari (ru, qorong‘i, katta shrift)', (tester) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    final s = await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.6,
    );
    final w = Walk(tester, 'lipid_goals_ru_dark_large');
    await goTo(tester, '/tests/analyte/ldl-c');
    await w.snap('ldl_tepa');
    await showAtTop(tester, find.text(l.analyteTreatmentGoals));
    await w.snap('ldl_maqsad_1');
    for (var i = 2; i <= 9; i++) {
      await w.scroll(650);
      await w.snap('ldl_maqsad_$i');
    }
    await showAtTop(tester, find.text(l.analyteReview));
    await w.snap('ldl_kelib_chiqish');
    await goTo(tester, '/tests');
    await goTo(tester, '/tests/analyte/non-hdl-c');
    await showAtTop(tester, find.text(l.analyteTreatmentGoals));
    await w.snap('nonhdl_maqsad_1');
    await w.scroll(650);
    await w.snap('nonhdl_maqsad_2');
    await w.scroll(650);
    await w.snap('nonhdl_maqsad_3');
    expect(s.content.pack!.analyte('ldl-c')!.treatmentGoals, isNotEmpty);
  });

  testWidgets('LDL-C goals (en, 320 px, ×2)', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    await start(
      tester,
      lang: AppLanguage.en,
      textScale: 2,
      size: const Size(320, 640),
    );
    final w = Walk(tester, 'lipid_goals_en_320');
    await goTo(tester, '/tests/analyte/ldl-c');
    await showAtTop(tester, find.text(l.analyteTreatmentGoals));
    await w.snap('ldl_goals_1');
    for (var i = 2; i <= 4; i++) {
      await w.scroll(500);
      await w.snap('ldl_goals_$i');
    }
  });
}
