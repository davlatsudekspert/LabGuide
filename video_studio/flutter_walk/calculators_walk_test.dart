// LabGuide video studio — REAL app frames for the topic video "Laboratory
// calculators" (docs/video/calculators/): Lab → Calculators (17: clinical
// formulas, manual methods, laboratory), the eGFR (CKD-EPI 2021) calculator
// with ILLUSTRATIVE inputs (storyboard data.egfr) — empty form, the "choose
// sex" check, the result with its KDIGO category and the entered values,
// formula + limitations, the under-18 refusal — the osmolality calculator's
// unit check (glucose 90 "mmol/L"), and the Profile units switch.
//
//   cd /home/user/wt-audit
//   flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
//     /home/user/wt-video/video_studio/flutter_walk/calculators_walk_test.dart --update-goldens
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'file:///home/user/wt-audit/test/helpers/harness.dart';
import 'labcard_kit.dart';
import 'walk_kit.dart';

const _sb = '/home/user/wt-video/docs/video/calculators/storyboard.json';

Rect? _rectOf(WidgetTester tester, Finder f) {
  final els = f.evaluate();
  if (els.isEmpty) return null;
  final box = els.first.renderObject as RenderBox?;
  if (box == null || !box.hasSize || !box.attached) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

void main() {
  setUpAll(loadAppFonts);
  final data = (jsonDecode(File(_sb).readAsStringSync()) as Map)['data'] as Map;
  final egfr = data['egfr'] as Map;
  final unitCheck = data['unitCheck'] as Map;
  String s(Object v) => (v as num).toString();
  for (final lang in AppLanguage.values) {
    testWidgets('calculators walk ${lang.name}', (tester) async {
      final code = lang.name;
      final l = lookupAppLocalizations(lang.locale);
      final sv = await makeServices(tester, language: lang, role: walkRole);
      await pumpApp(tester, sv, ratio: 2);
      final w = Walk(tester, code, 'calculators', source: 'video_studio/flutter_walk/calculators_walk_test.dart');
      Future<void> tall() async {
        tester.view.physicalSize = const Size(390, 2600) * 2;
        await tester.pumpAndSettle();
      }

      Future<void> phone() async {
        tester.view.physicalSize = const Size(390, 844) * 2;
        await tester.pumpAndSettle();
      }

      Future<void> calculate() async {
        final b = find.byType(LgButton).last;
        await tester.ensureVisible(b);
        await tester.pumpAndSettle();
        await tester.tap(b);
        await tester.pumpAndSettle();
      }

      // 1. Lab tab: the Calculators row.
      await goTo(tester, '/lab');
      final row = find.text(l.featureCalculators);
      await w.bring(row, at: 470);
      await w.snap('l_lab', tapOn: row, marks: {'row': row});

      // 2. The list: clinical formulas, then manual methods + laboratory.
      await goTo(tester, '/lab/calculators');
      await w.snap('c_list', marks: {'section': find.text(l.calcSectionClinical), 'egfr': find.text(l.calcEgfr)});
      // "How to use?" — the app's own steps.
      await tester.tap(find.text(l.howToButton).first);
      await tester.pumpAndSettle();
      await w.snap('c_howto', marks: {'steps': find.text(l.howToStepsTitle)});
      // Close the sheet (it sits on the root navigator, above every route).
      Navigator.of(tester.element(find.text(l.howToStepsTitle).first)).pop();
      await tester.pumpAndSettle();
      await goTo(tester, '/lab');
      await goTo(tester, '/lab/calculators');
      await w.bring(find.text(l.calcSectionManual), at: 160);
      await w.snap('c_list2', marks: {'manual': find.text(l.calcSectionManual), 'lab': find.text(l.calcSectionLab)});

      // 3. eGFR: empty form.
      await goTo(tester, '/lab/calculators/egfr');
      await w.snap('e_empty', marks: {'first': find.byType(TextField).first});
      // 4. Values typed, Calculate without sex -> the app asks for it.
      await tall();
      final f = find.byType(TextField);
      await tester.enterText(f.at(0), s(egfr['creatinine']!));
      await tester.enterText(f.at(1), s(egfr['age']!));
      await tester.pumpAndSettle();
      await calculate();
      await phone();
      final sexErr = find.text(l.errSexMissing);
      await w.bring(sexErr, at: 420);
      await w.snap('e_sex', marks: {'error': sexErr});
      // 5. Sex chosen -> result with KDIGO category and the entered values.
      await tall();
      await tester.tap(find.text(l.sexMale).first);
      await tester.pumpAndSettle();
      await calculate();
      await phone();
      final panel = find.byType(LgPanel).first;
      await w.bring(panel, at: 380);
      await w.snap('e_result', marks: {'result': panel});
      // 6. Formula + limitations (sources below stay outside the crop).
      final ft = find.text(l.calcFormula);
      await w.bring(ft, at: 160);
      await w.snap('e_formula', marks: {'title': ft});
      final top = _rectOf(tester, ft);
      final src = _rectOf(tester, find.text(l.calcSources));
      if (top != null) {
        final bottom = (src?.top ?? 780).clamp(top.bottom + 40, 780.0);
        (w.frames.last['marks']! as Map)['refs'] = [16.0, top.top - 8, 358.0, bottom - top.top + 2];
      }
      // 7. Under 18: refused with the reason.
      await tall();
      await tester.enterText(find.byType(TextField).at(1), s(egfr['childAge']!));
      await tester.pumpAndSettle();
      await calculate();
      await phone();
      final ageErr = find.text(l.errEgfrAge);
      await w.bring(ageErr, at: 420);
      await w.snap('e_child', marks: {'error': ageErr});

      // 8. Osmolality: a glucose of 90 "mmol/L" gets a unit check.
      await goTo(tester, '/lab/calculators/osmolality');
      await tall();
      final g = find.byType(TextField);
      await tester.enterText(g.at(0), s(unitCheck['sodium']!));
      await tester.enterText(g.at(1), s(unitCheck['glucose']!));
      await tester.enterText(g.at(2), s(unitCheck['urea']!));
      await tester.pumpAndSettle();
      await calculate();
      await phone();
      final chk = find.textContaining(l.calcUnitCheck(l.fieldGlucose, s(unitCheck['glucose']!), 'mmol/L'));
      await w.bring(chk, at: 420);
      await w.snap('o_unit', marks: {'check': chk});

      // 9. Dilution (laboratory tools): C1·V1 = C2·V2 from typed values.
      await goTo(tester, '/lab/calculators/dilution');
      final dl = data['dilution'] as Map;
      final e = find.byType(EditableText);
      await tester.enterText(e.at(0), s(dl['c1']!));
      await tester.enterText(e.at(1), s(dl['c2']!));
      await tester.enterText(e.at(2), s(dl['v2']!));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.dilCalculate).last);
      await tester.pumpAndSettle();
      // .last: the screen subtitle "C₁V₁ = C₂V₂" also contains "V₁ =".
      final dr = find.textContaining('V₁ = ').last;
      await w.bring(dr, at: 420);
      await w.snap('d_result', marks: {'result': dr});

      // 10. Profile: SI or conventional units.
      await goTo(tester, '/profile');
      final units = find.text(l.profileUnits);
      await w.bring(units, at: 300);
      await w.snap('p_units', marks: {'title': units});
      final ur = _rectOf(tester, units);
      if (ur != null) {
        (w.frames.last['marks']! as Map)['units'] = [16.0, ur.top - 8, 358.0, 150.0];
      }

      w.record['inputs'] = {'egfr': egfr, 'unitCheck': unitCheck};
      w.record['shown'] = w.visibleTexts();
      w.save();
      expect(tester.takeException(), isNull);
    });
  }
}
