// Xalqaro foydalanuvchi: birliklar tizimi sozlamasi (SI / konvensional),
// kalkulyatorlarning boshlang'ich birligi, LDL-C maqsadlarining SI qatori va
// son formati locale bo'yicha.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/content/ui/analyte_screen.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/tools/clinical_calculators.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

/// Maqsadning SI qatori (bo'linmas bo'shliq oddiy bo'shliqqa tenglashtiriladi).
Finder _goalSi(String text) => find.byWidgetPredicate(
  (w) =>
      w is Text &&
      w.key == const ValueKey('goal-si') &&
      (w.data ?? '')
          .replaceAll('\u00A0', ' ')
          .replaceAll('\u2060', '')
          .contains(text),
);

void main() {
  setUpAll(loadAppFonts);

  test('UnitSystem: default from device region, US → conventional', () {
    expect(
      UnitSystem.fromSystem([const Locale('en', 'US')]),
      UnitSystem.conventional,
    );
    expect(UnitSystem.fromSystem([const Locale('en', 'GB')]), UnitSystem.si);
    expect(UnitSystem.fromSystem([const Locale('ru')]), UnitSystem.si);
    expect(UnitSystem.fromSystem(const []), UnitSystem.si);
    expect(UnitSystem.tryParse('conventional'), UnitSystem.conventional);
    expect(UnitSystem.tryParse('x'), isNull);
  });

  test('defaultUnitFor: conventional picks mg/dL or g/dL, SI the first', () {
    expect(
      defaultUnitFor([Units.creatUmolL, Units.creatMgDl], true).label,
      'mg/dL',
    );
    expect(
      defaultUnitFor([Units.creatUmolL, Units.creatMgDl], false).label,
      'µmol/L',
    );
    expect(defaultUnitFor([Units.albGL, Units.albGDl], true).label, 'g/dL');
    expect(defaultUnitFor([Units.ngsp, Units.ifcc], true).label, '%');
  });

  test('formatNumber follows the locale decimal separator', () {
    expect(formatNumber(5.55, 'ru'), '5,55');
    expect(formatNumber(5.55, 'en'), '5.55');
    expect(formatNumber(100, 'en'), '100');
  });

  testWidgets('setting persists and survives a new controller', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    expect(s.settings.unitSystem, UnitSystem.si);
    await s.settings.setUnitSystem(UnitSystem.conventional);
    expect(s.settings.unitSystem, UnitSystem.conventional);
  });

  testWidgets('LDL-C goals: SI line for mg/dL-only goals (en, SI)', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 12000));
    await goTo(tester, '/tests/analyte/ldl-c');
    final si = find.byKey(const ValueKey('goal-si'));
    expect(si, findsWidgets);
    // 100 mg/dL ≈ 2.6 mmol/L (LDL-C: 386.65 g/mol).
    expect(_goalSi('2.6 mmol/L'), findsWidgets);

    await s.settings.setUnitSystem(UnitSystem.conventional);
    await tester.pumpAndSettle();
    expect(si, findsNothing);
  });

  testWidgets('LDL-C goals: SI line uses a decimal comma in ru', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.ru);
    await pumpApp(tester, s, size: const Size(390, 12000));
    await goTo(tester, '/tests/analyte/ldl-c');
    expect(_goalSi('2,6 mmol/L'), findsWidgets);
  });

  testWidgets('LDL calculator starts in mg/dL for conventional users', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await s.settings.setUnitSystem(UnitSystem.conventional);
    await pumpApp(tester, s, size: const Size(390, 3200));
    await goTo(tester, '/lab/calculators/ldl');
    final chips = tester.widgetList<LgChoiceChip>(find.byType(LgChoiceChip));
    final selected = [
      for (final c in chips)
        if (c.selected) c.label,
    ];
    expect(selected, isNotEmpty);
    expect(selected.every((l) => l == 'mg/dL'), isTrue, reason: '$selected');
  });
}
