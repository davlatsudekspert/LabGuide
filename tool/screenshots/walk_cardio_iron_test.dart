// Yurak markerlari, temir va vitaminlar — foydalanuvchi sifatida
// (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_cardio_iron_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

/// Sahifa tepasidagi “orqaga” tugmasini bosadi.
Future<void> back(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back_rounded).hitTestable().first);
  await tester.pumpAndSettle();
}

/// Guruh chiplari qatorini (gorizontal) chip ko'ringuncha suradi —
/// foydalanuvchi barmog'i bilan suradi.
Future<void> swipeToChip(WidgetTester tester, String label) async {
  await tester.dragUntilVisible(
    find.text(label),
    find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.right,
        )
        .first,
    const Offset(-250, 0),
  );
  await tester.pumpAndSettle();
}

/// Sahifani (vertikal) [finder] ko'ringuncha pastga suradi — ro'yxat
/// dangasa quriladi, pastdagi element oldindan mavjud emas.
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
    maxIteration: 100,
  );
  await tester.pumpAndSettle();
}

/// [finder] ni ekranning yuqori qismiga keltiradi (panel to'liq ko'rinsin).
Future<void> showAtTop(WidgetTester tester, Finder finder) async {
  await scrollToFind(tester, finder);
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.1);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('yurak va temir — shifokor (uz, yorug‘)', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await start(tester, role: AppRole.doctor);
    String name(String id) => s.content.pack!.analyte(id)!.names.of('uz');
    final w = Walk(tester, 'cardio_iron_uz');
    await goTo(tester, '/tests');
    await w.snap('tahlillar');
    await swipeToChip(tester, 'Yurak markerlari');
    await w.snap('chiplar_surildi');
    await w.tapText('Yurak markerlari');
    await w.snap('yurak_guruhi');
    await w.tapText(name('troponin'));
    await w.snap('troponin_tepa');
    await w.scroll(600);
    await w.snap('troponin_maqsad');
    await w.scroll(700);
    await w.snap('troponin_yuqori');
    await w.scroll(700);
    await w.snap('troponin_cheklovlar');
    await w.scroll(700);
    await w.snap('troponin_boglik');
    await scrollToFind(tester, find.text(name('ck-mb')));
    await w.snap('troponin_boglik_tahlillar');
    await w.tap(find.text(name('ck-mb')));
    await w.snap('ckmb_tepa');
    await back(tester);
    await w.snap('troponin_qaytish');
    await back(tester);
    await w.snap('ruyxatga_qaytish');
    await swipeToChip(tester, 'Temir va vitaminlar');
    await w.tapText('Temir va vitaminlar');
    await w.snap('temir_guruhi');
    await w.tapText(name('ferritin'));
    await w.snap('ferritin_tepa');
    await w.scroll(1400);
    await w.snap('ferritin_orta');
    await w.scroll(1400);
    await w.snap('ferritin_chegaralar');
    await w.scroll(600);
    await w.snap('ferritin_boglik');
    await scrollToFind(tester, find.text(name('transferrin-tibc')));
    await w.tap(find.text(name('transferrin-tibc')));
    await w.snap('tibc_tepa');
    await w.scroll(900);
    await w.snap('tibc_formula');
    await showAtTop(tester, find.text(l.analyteDecisionLimits));
    await w.snap('tibc_chegara');
    await scrollToFind(tester, find.text(l.analytePractice));
    await w.tap(find.text(l.analytePractice));
    await w.snap('tibc_savol');
    await w.tapText('12,5%');
    await w.snap('tibc_javob');
  });

  testWidgets('qidiruv va B12 — ru, qorong‘i, katta shrift', (tester) async {
    final s = await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
    );
    final ru = lookupAppLocalizations(const Locale('ru'));
    String name(String id) => s.content.pack!.analyte(id)!.names.of('ru');
    final w = Walk(tester, 'cardio_iron_ru_dark_large');
    await goTo(tester, '/tests');
    await tester.enterText(find.byType(TextField).first, 'тропонин');
    await w.snap('qidiruv_troponin');
    await tester.enterText(find.byType(TextField).first, 'ОЖСС');
    await w.snap('qidiruv_ojss');
    await tester.enterText(find.byType(TextField).first, 'B12');
    await w.snap('qidiruv_b12');
    await w.tapText(name('vitamin-b12'));
    await w.snap('b12_tepa');
    await w.scroll(2400);
    await w.snap('b12_orta');
    await showAtTop(tester, find.text(ru.analyteDecisionLimits));
    await w.snap('b12_chegaralar');
    await w.scroll(500);
    await w.snap('b12_chegaralar_2');
    await goTo(tester, '/tests');
    await goTo(tester, '/tests/analyte/natriuretic-peptides');
    await w.snap('bnp_tepa');
    await w.scroll(4200);
    await w.snap('bnp_cheklovlar');
  });

  testWidgets('laktat, Lp(a), E vitamini — talaba (en)', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    await start(tester, lang: AppLanguage.en, role: AppRole.student);
    final w = Walk(tester, 'cardio_iron_en');
    await goTo(tester, '/tests');
    await w.tapText('Carbohydrate metabolism');
    await w.snap('carbohydrate_group');
    await w.tapText('Lactate (lactic acid)');
    await w.snap('lactate_top');
    await scrollToFind(tester, find.text(l.analyteConvertUnits));
    await w.snap('lactate_bottom');
    await w.tap(find.text(l.analyteConvertUnits));
    await w.snap('lactate_units');
    await scrollToFind(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField).first, '18');
    await scrollToFind(tester, find.text(l.ucConvert));
    await w.snap('lactate_value_entered');
    await w.tap(find.text(l.ucConvert));
    await w.snap('lactate_converted');
    await goTo(tester, '/tests');
    await goTo(tester, '/tests/analyte/lipoprotein-a');
    await w.snap('lpa_top');
    await w.scroll(1800);
    await w.snap('lpa_middle');
    await goTo(tester, '/tests');
    await goTo(tester, '/tests/analyte/vitamin-e');
    await w.snap('vitamin_e_top');
    await goTo(tester, '/tests');
    await goTo(tester, '/tests/analyte/homocysteine');
    await scrollToFind(tester, find.text(l.sectionLimitations));
    await w.scroll(200);
    await w.snap('homocysteine_limitations');
  });
}
