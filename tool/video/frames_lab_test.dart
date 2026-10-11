// 8–10-videolar: laborant uchun leykoformula, QC, kalibrovka/preanalitika.
//   flutter test tool/video/frames_lab_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/diff_device_fakes.dart';
import '../../test/helpers/harness.dart';
import '../screenshots/walk_helper.dart';
import 'common.dart';
import 'rec.dart';

Finder cellBtn(DiffCell c) => find.byKey(ValueKey('diff-count-${c.name}'));
Finder zone(DiffCell c) => find.byKey(ValueKey('ef-zone-${c.name}'));

Future<void> tapMany(WidgetTester tester, Map<DiffCell, int> plan) async {
  for (final MapEntry(key: c, value: n) in plan.entries) {
    await reveal(tester, cellBtn(c), center: false);
    await tester.ensureVisible(cellBtn(c));
    await tester.pumpAndSettle();
    for (var i = 0; i < n; i++) {
      await tester.tap(cellBtn(c));
      await tester.pump(const Duration(milliseconds: 20));
    }
  }
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);
  final l = lookupAppLocalizations(const Locale('uz'));

  testWidgets('v8 leykoformula', (tester) async {
    installDiffFakes();
    recordHaptics(tester);
    final s = await start(tester, role: AppRole.lab, size: phone);
    final r = Rec(tester, 'v8');
    await r.shot('home', target: vis(l.navLab));
    await r.tapText(l.navLab);
    await r.shot('lab', target: find.text(l.diffTitle).last);
    await tester.tap(find.text(l.diffTitle).last);
    await tester.pumpAndSettle();
    await r.shot('diff_home', target: find.text(l.diffStartCount).first);
    await tester.tap(find.text(l.diffStartCount).first);
    await tester.pumpAndSettle();
    final sound = find.byKey(const ValueKey('diff-fb-sound'));
    await r.shot('counter', target: find.text('200'));
    await r.shot('counter_sound', target: sound);
    await tester.tap(sound);
    await tester.pumpAndSettle();
    await r.shot('counter_sound_on', target: find.byKey(const ValueKey('diff-fb-haptics')));
    await tester.tap(cellBtn(DiffCell.segmented));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.tap(cellBtn(DiffCell.segmented));
    await tester.pumpAndSettle();
    await r.shot('tap', target: cellBtn(DiffCell.segmented));
    await tapMany(tester, {
      DiffCell.segmented: 28,
      DiffCell.lymphocyte: 12,
      DiffCell.band: 3,
    });
    await tester.drag(vertical(), const Offset(0, 3000));
    await tester.pumpAndSettle();
    await r.shot('count45', target: cellBtn(DiffCell.band), kind: 'tap');
    await tester.longPress(cellBtn(DiffCell.band));
    await tester.pumpAndSettle();
    await r.shot('longpress');
    await tapMany(tester, {
      DiffCell.segmented: 28,
      DiffCell.lymphocyte: 18,
      DiffCell.monocyte: 6,
      DiffCell.eosinophil: 3,
      DiffCell.basophil: 1,
    });
    await tester.drag(vertical(), const Offset(0, 3000));
    await tester.pumpAndSettle();
    await r.shot('done');
    expect(s.differential.total, 100);
    await tester.scrollUntilVisible(find.text(l.diffResultTitle), 200, scrollable: vertical());
    await centerOn(tester, find.text(l.diffResultTitle), alignment: 0.1, force: true);
    await tester.pump(const Duration(seconds: 5));
    await r.shot('result');
    // Mikroskop rejimi (ko'rmasdan sanash).
    s.differential.reset();
    await goTo(tester, '/lab/differential/count');
    final entry = find.text(l.diffEfEntry);
    await tester.scrollUntilVisible(entry, 200, scrollable: vertical());
    await centerOn(tester, entry, alignment: 0.4, force: true);
    await r.shot('ef_entry', target: entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();
    await r.shot('ef_settings', target: find.byKey(const ValueKey('eyes-free-start')));
    await tester.tap(find.byKey(const ValueKey('eyes-free-start')));
    await tester.pumpAndSettle();
    await r.shot('ef_run', target: zone(DiffCell.segmented));
    for (var i = 0; i < 6; i++) {
      await tester.tap(zone(DiffCell.segmented));
      await tester.pump(const Duration(milliseconds: 20));
    }
    for (var i = 0; i < 3; i++) {
      await tester.tap(zone(DiffCell.lymphocyte));
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
    await r.shot('ef_run9', target: zone(DiffCell.lymphocyte));
    for (final (c, n) in [
      (DiffCell.segmented, 52),
      (DiffCell.lymphocyte, 27),
      (DiffCell.monocyte, 6),
      (DiffCell.eosinophil, 3),
      (DiffCell.band, 3),
    ]) {
      for (var i = 0; i < n; i++) {
        await tester.tap(zone(c));
        await tester.pump(const Duration(milliseconds: 20));
      }
    }
    await tester.pumpAndSettle();
    await r.shot('ef_done', target: find.byKey(const ValueKey('ef-show-result')));
    await tester.tap(find.byKey(const ValueKey('ef-show-result')));
    await tester.pumpAndSettle();
    final rt = find.text(l.diffResultTitle);
    await tester.scrollUntilVisible(rt, 200, scrollable: vertical());
    await centerOn(tester, rt, alignment: 0.1, force: true);
    await r.shot('ef_result');
    r.save();
  });

  testWidgets('v9 qc', (tester) async {
    await start(tester, role: AppRole.lab, size: phone);
    final r = Rec(tester, 'v9');
    await r.tapText(l.navLab);
    final qc = find.text(l.featureQc);
    await r.shot('lab', target: await reveal(tester, qc));
    await tester.tap(qc.hitTestable().last);
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await r.shot(
      'qc_empty',
      target: await reveal(tester, find.text(l.qcAddSet), center: false),
      scrollTo: false,
    );
    await tapR(tester, find.text(l.qcAddSet));
    await r.shot('form');
    final f = find.byType(TextField);
    Future<void> put(int n, String v) async {
      await tester.ensureVisible(f.at(n));
      await tester.pumpAndSettle();
      await tester.enterText(f.at(n), v);
    }

    await setH(tester, 3600);
    await put(0, 'Glyukoza');
    await put(1, 'mmol/L');
    await put(4, '5,0');
    await put(5, '0,2');
    await put(8, '15');
    await put(9, '0,5');
    await setH(tester, 640);
    await tester.drag(vertical(), const Offset(0, 6000));
    await tester.pumpAndSettle();
    await r.shot('form_filled');
    await r.scroll(450);
    await r.shot('form_levels');
    await setH(tester, 3600);
    await tester.tap(find.text(l.qcSave).hitTestable().last);
    await tester.pumpAndSettle();
    await setH(tester, 640);
    await r.shot('set_empty', target: find.text(l.qcJumpToAddRun), scrollTo: false);
    Future<void> run(String a, String b) async {
      await setH(tester, 3600);
      await tester.enterText(f.first, a);
      await tester.enterText(f.at(1), b);
      await tester.tap(find.text(l.qcSaveRun).hitTestable().last);
      await tester.pumpAndSettle();
      await setH(tester, 640);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.drag(vertical(), const Offset(0, 6000));
      await tester.pumpAndSettle();
    }

    await run('5,1', '15,2');
    await r.shot('run1');
    for (final v in [
      ['4,9', '14,8'],
      ['5,2', '15,3'],
      ['5,0', '15,1'],
      ['4,8', '14,7'],
    ]) {
      await run(v[0], v[1]);
    }
    await r.shot('runs5');
    await run('5,5', '15,6');
    await r.shot('warn');
    await run('5,5', '15,2');
    await r.shot('reject22');
    await r.scroll(450);
    await r.shot('reject22_low');
    await run('5,7', '15,0');
    await r.shot('reject13');
    await r.scroll(450);
    await r.shot('reject13_low');
    // Yo'riqnomalar.
    await goTo(tester, '/lab/qc');
    final guide = find.text('QC rad etilsa nima qilish');
    await r.shot('guides', target: await reveal(tester, guide));
    await tester.tap(guide.hitTestable().last);
    await tester.pumpAndSettle();
    await r.shot('guide');
    await r.scroll(450);
    await r.shot('guide_low');
    r.save();
  });

  testWidgets('v10 kalibrovka', (tester) async {
    final s = await start(tester, role: AppRole.lab, size: phone);
    final r = Rec(tester, 'v10');
    await r.tapText(l.navLab);
    final inst = find.text(l.labInstruments);
    await r.shot('lab', target: await reveal(tester, inst));
    await tester.tap(inst.hitTestable().last);
    await tester.pumpAndSettle();
    await r.shot('inst_home', target: find.byType(TextField).first, kind: 'type');
    await tester.enterText(find.byType(TextField).first, 'humalyzer');
    await tester.pumpAndSettle();
    final model = find.textContaining('HumaLyzer 4000').first;
    await r.shot('inst_search', target: model);
    await tester.tap(model);
    await tester.pumpAndSettle();
    await r.shot('inst_card', target: find.text(l.instSaveMine));
    await tapR(tester, find.text(l.instSaveMine));
    await enterField(tester, l.instLabel, '1-xona');
    await enterField(tester, l.instManualVersion, 'v2.1');
    await r.shot('inst_save_form', target: await reveal(tester, find.text(l.instSave)));
    await tapR(tester, find.text(l.instSave));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await r.shot('inst_saved', target: await reveal(tester, find.text(l.instCalibrate)));
    await tapR(tester, find.text(l.instCalibrate));
    await r.shot('cal_start', target: find.byType(TextField).first, kind: 'type');
    await tester.enterText(find.byType(TextField).first, 'glyukoza');
    await tester.pumpAndSettle();
    final gname = s.content.pack!.analyte('glucose-plasma-fasting')!.names.of('uz');
    await r.shot('cal_analyte', target: find.text(gname).first);
    await tester.tap(find.text(gname).first);
    await tester.pumpAndSettle();
    await r.shot('cal_reagent');
    await enterField(tester, l.calReagentRef, '10121');
    await r.shot('cal_ref_ok', target: fieldOf(l.calReagentRef));
    await enterField(tester, l.calIfuRevision, '2024-01');
    await r.shot('cal_ifu', target: await reveal(tester, find.text(l.calShowGuide)));
    await tapR(tester, find.text(l.calShowGuide));
    await r.shot('cal_guide');
    await r.scroll(450);
    await r.shot('cal_guide_low');
    // Preanalitika: probirkalar tartibi.
    await goTo(tester, '/lab');
    final pre = find.text(l.labPreanalytics);
    await r.shot('lab2', target: await reveal(tester, pre));
    await tester.tap(pre.hitTestable().last);
    await tester.pumpAndSettle();
    await r.shot('pre_top');
    Future<void> sec(String id, String text, {double a = 0.1}) async {
      await tester.scrollUntilVisible(
        find.text(text).hitTestable(),
        200,
        scrollable: vertical(),
        maxScrolls: 60,
      );
      await centerOn(tester, find.text(text).hitTestable().last,
          alignment: a, force: true);
      await r.shot(id);
    }

    await sec('pre_order', l.preOrderTitle);
    await r.scroll(420);
    await r.shot('pre_order_low');
    await sec('pre_haemolysis', l.preHaemolysisTitle);
    r.save();
  });
}
