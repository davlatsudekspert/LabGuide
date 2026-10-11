// UX: QC — test yaratish, seriyalar, Westgard natijasi (3 til).
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

void main() {
  setUpAll(loadAppFonts);
  for (final lang in AppLanguage.values) {
    testWidgets('qc ${lang.name}', (tester) async {
      await start(tester, role: AppRole.lab, lang: lang);
      final w = Walk(tester, 'ux_qc_${lang.name}');
      await goTo(tester, '/lab/qc');
      final t = l10n(tester, AppLocalizations.of);
      await w.tapText(t.qcAddSet);
      final f = find.byType(TextField);
      Future<void> put(int n, String v) async {
        await tester.ensureVisible(f.at(n));
        await tester.pumpAndSettle();
        await tester.enterText(f.at(n), v);
      }
      tester.view.physicalSize = const Size(390, 3600) * 3;
      await tester.pumpAndSettle();
      await put(0, 'Glucose');
      await put(1, 'mmol/L');
      await put(4, '5,0');
      await put(5, '0,2');
      await put(8, '15');
      await put(9, '0,5');
      tester.view.physicalSize = const Size(390, 844) * 3;
      await tester.pumpAndSettle();
      await w.snap('form_filled');
      tester.view.physicalSize = const Size(390, 3600) * 3;
      await tester.pumpAndSettle();
      await w.tapText(t.qcSave);
      tester.view.physicalSize = const Size(390, 844) * 3;
      await tester.pumpAndSettle();
      await w.snap('set_empty');
      final lf = find.byType(TextField);
      Future<void> size(double h) async {
        tester.view.physicalSize = Size(390, h) * 3;
        await tester.pumpAndSettle();
      }
      var i = 0;
      for (final v in [['5,1', '15,1'], ['5,5', '15,1'], ['5,7', '15,2'], ['5,7', '16,2']]) {
        await size(3600);
        await tester.enterText(lf.first, v[0]);
        await tester.enterText(lf.at(1), v[1]);
        await w.tapText(t.qcSaveRun);
        i++;
        if (i >= 2) {
          await size(844);
          await w.snap('run$i');
        }
      }
      await w.scroll(500);
      await w.snap('run_past');
      await w.scroll(900);
      await w.snap('run_past2');
    });
  }
}
