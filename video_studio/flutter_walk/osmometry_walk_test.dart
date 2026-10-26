// LabGuide video studio — REAL app frames for the topic video "Osmometry"
// (docs/video/osmometry/): Lab → Instruments and methods → Clinical
// biochemistry → "Osmometer (urine / serum osmolality)" card
// (`a3-bio-osmometer`, source: one NCBI Bookshelf page) with the app's
// original schematic, numbered parts, specimens, limitations and errors;
// then Lab → Calculators → Calculated osmolality with ILLUSTRATIVE inputs
// (storyboard data.calc) typed into the app's own form — the app computes
// the calculated osmolality and the osmolal gap on screen.
//
//   cd /home/user/wt-audit
//   flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
//     /home/user/wt-video/video_studio/flutter_walk/osmometry_walk_test.dart --update-goldens
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

const _sb = '/home/user/wt-video/docs/video/osmometry/storyboard.json';

void main() {
  setUpAll(loadAppFonts);
  final catalog = jsonDecode(File('assets/instruments/catalog.json').readAsStringSync()) as Map;
  final cards = (catalog['lab_cards'] as List).cast<Map>();
  final card = cards.firstWhere((c) => c['id'] == 'a3-bio-osmometer');
  final calc = ((jsonDecode(File(_sb).readAsStringSync()) as Map)['data'] as Map)['calc'] as Map;
  String v(String k) => (calc[k] as num).toString();
  for (final lang in AppLanguage.values) {
    testWidgets('osmometry walk ${lang.name}', (tester) async {
      final code = lang.name;
      final l = lookupAppLocalizations(lang.locale);
      final s = await makeServices(tester, language: lang, role: walkRole);
      await pumpApp(tester, s, ratio: 2);
      final w = Walk(tester, code, 'osmometry', source: 'video_studio/flutter_walk/osmometry_walk_test.dart');

      // 1. The reference card (shared kit).
      await labCardWalk(tester, w, l,
          cardId: 'a3-bio-osmometer',
          cardName: (card['name'] as Map)[code] as String,
          direction: 'biochemistry',
          schematicKey: 'osmometer',
          prefix: 'o',
          fields: {
            'o_specimens': l.labDirSpecimens,
            'o_limits': l.labDirLimitations,
            'o_errors': l.labDirErrors,
          });

      // 2. Lab → Calculators: the list with the osmolality row.
      await goTo(tester, '/lab/calculators');
      final row = find.text(l.calcOsmo);
      await w.bring(row, at: 470);
      await w.snap('c_list', tapOn: row, marks: {'row': row});

      // 3. The calculator: illustrative inputs typed in a tall view (every
      // field built), Calculate tapped, then back to the phone size.
      await goTo(tester, '/lab/calculators/osmolality');
      tester.view.physicalSize = const Size(390, 2600) * 2;
      await tester.pumpAndSettle();
      final f = find.byType(TextField);
      await tester.enterText(f.at(0), v('sodium'));
      await tester.enterText(f.at(1), v('glucose'));
      await tester.enterText(f.at(2), v('urea'));
      await tester.enterText(f.at(3), v('measured'));
      await tester.pumpAndSettle();
      final calculate = find.byType(LgButton).last;
      await tester.ensureVisible(calculate);
      await tester.pumpAndSettle();
      await tester.tap(calculate);
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(390, 844) * 2;
      await tester.pumpAndSettle();

      // The field label carries the unit ("Sodium (Na⁺), mmol/L").
      await w.bring(find.textContaining(l.fieldSodium).first, at: 250);
      await w.snap('c_form', marks: {'first': find.byType(TextField).first});
      Rect? all;
      for (final el in find.byType(TextField).evaluate()) {
        final box = el.renderObject as RenderBox?;
        if (box == null || !box.hasSize || !box.attached) continue;
        final r = box.localToGlobal(Offset.zero) & box.size;
        if (r.bottom < 0 || r.top > 844) continue;
        all = all == null ? r : all.expandToInclude(r);
      }
      if (all != null) {
        (w.frames.last['marks']! as Map)['fields'] = [all.left - 6, all.top - 40, all.width + 12, all.height + 48];
      }

      // The screen title is the same words: find the result panel itself.
      final panel = find.byType(LgPanel).first;
      await w.bring(panel, at: 360);
      await w.snap('c_result', marks: {
        'result': panel,
        'title': find.descendant(of: panel, matching: find.text(l.resOsmCalc)),
      });
      w.record['cards'] = ['a3-bio-osmometer'];
      w.record['calculator'] = {'route': '/lab/calculators/osmolality', 'inputs': calc, 'units': 'mmol/L (SI default), measured mOsm/kg'};
      w.record['shown'] = w.visibleTexts();
      w.save();
      expect(tester.takeException(), isNull);
    });
  }
}
