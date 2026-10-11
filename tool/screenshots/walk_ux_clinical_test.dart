// UX: shifokor va laborant ekranlari (3 til). Rasmlar: out/walk/ux_<rol>_<til>/
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

const _doctor = [
  '/home',
  '/tests',
  '/tests/analyte/glucose-plasma-fasting',
  '/tests/analyte/egfr',
  '/tests/conditions',
  '/lab/calculators',
  '/lab/calculators/egfr',
  '/lab/calculators/anion-gap',
  '/lab/calculators/units',
  '/library',
  '/library/saved',
  '/library/packs',
  '/learn',
  '/profile',
  '/profile/role',
];
const _lab = [
  '/home',
  '/lab',
  '/lab/qc',
  '/lab/qc/new',
  '/lab/qc/rejected',
  '/lab/qc/eqa',
  '/lab/qc/critical',
  '/lab/calibration',
  '/lab/instruments',
  '/lab/preanalytics',
  '/lab/microscopy',
  '/lab/differential',
  '/lab/calculators/dilution',
  '/library/packs',
];

void main() {
  setUpAll(loadAppFonts);
  for (final lang in AppLanguage.values) {
    for (final role in [AppRole.doctor, AppRole.lab]) {
      testWidgets('${role.name} ${lang.name}', (tester) async {
        await start(tester, role: role, lang: lang);
        final w = Walk(tester, 'ux_${role.name}_${lang.name}');
        for (final r in (role == AppRole.doctor ? _doctor : _lab)) {
          await goTo(tester, r);
          await w.snap(r.substring(1).replaceAll('/', '_'));
        }
      });
    }
  }
}
