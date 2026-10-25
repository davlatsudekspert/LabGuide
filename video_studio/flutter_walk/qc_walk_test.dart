// LabGuide video studio — REAL app frames for the topic video "Quality
// control: Levey–Jennings and Westgard rules" (docs/video/qc/).
//
// Every frame is the real app (widget-test render of LabGuideApp: real
// assets, no server, guest, role = lab, Classic light theme, 390x844 @2x).
// The control test is CREATED through the app's own form (name, unit, two
// levels with lot / mean / SD, target source = our laboratory's data); the
// illustrative runs from docs/video/qc/storyboard.json (data.runs, value =
// mean + z·SD) are then recorded with the app's own QcController.addRun at
// fixed daily times, so every verdict, Levey–Jennings point, rule text and
// statistic on screen is computed by the app itself. The app's verdicts are
// written to frames.json → record.verdicts and compared with the video's
// port of the rule engine in MATH_APPENDIX.md.
//
//   cd /home/user/wt-audit
//   flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
//     /home/user/wt-video/video_studio/flutter_walk/qc_walk_test.dart --update-goldens
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/qc/levey_jennings_chart.dart';
import 'package:labguide/features/qc/qc_guides.dart';
import 'package:labguide/features/qc/qc_guides_info.dart';
import 'package:labguide/features/qc/qc_rules.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'file:///home/user/wt-audit/test/helpers/harness.dart';
import 'walk_kit.dart';

const _video = 'qc';
const _storyboard = '/home/user/wt-video/docs/video/qc/storyboard.json';

double _round(double v, int d) {
  final p = math.pow(10, d);
  return (v * p).round() / p;
}

String _fmt(double v, String lang) => lang == 'en' ? '$v' : '$v'.replaceAll('.', ',');

void main() {
  setUpAll(loadAppFonts);
  final sb = jsonDecode(File(_storyboard).readAsStringSync()) as Map;
  final data = (sb['data'] as Map).cast<String, Object?>();
  final levels = (data['levels']! as List).cast<Map>();
  final runs = (data['runs']! as List).cast<Map>();

  for (final lang in AppLanguage.values) {
    testWidgets('qc walk ${lang.name}', (tester) async {
      final code = lang.name;
      final l = lookupAppLocalizations(lang.locale);
      final s = await makeServices(tester, language: lang, role: AppRole.lab);
      String? clip;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clip = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      await pumpApp(tester, s, ratio: 2);
      final w = Walk(tester, code, _video, source: 'video_studio/flutter_walk/qc_walk_test.dart');

      // 1. New control test through the app's own form.
      await goTo(tester, '/lab/qc/new');
      // Tall view while typing so every field of the lazy form is built
      // (the app's own QC test does the same), then back to the phone.
      tester.view.physicalSize = const Size(390, 2200) * 2;
      await tester.pumpAndSettle();
      final f = find.byType(TextField);
      await tester.enterText(f.at(0), (data['setName']! as Map)[code] as String);
      await tester.enterText(f.at(1), data['unit']! as String);
      for (final (i, lv) in levels.indexed) {
        await tester.enterText(f.at(2 + i * 4), (lv['label'] as Map)[code] as String);
        await tester.enterText(f.at(3 + i * 4), lv['lot'] as String);
        await tester.enterText(f.at(4 + i * 4), _fmt((lv['mean'] as num).toDouble(), code));
        await tester.enterText(f.at(5 + i * 4), _fmt((lv['sd'] as num).toDouble(), code));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.qcSourceLab).first);
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(390, 844) * 2;
      await tester.pumpAndSettle();
      await w.bring(find.text(l.qcTargetSource), at: 300);
      await w.snap('qc_new', marks: {
        'source': find.text(l.qcTargetSource),
        'lab': find.text(l.qcSourceLab),
        'mean': find.text(l.qcMean).first,
      });
      tester.view.physicalSize = const Size(390, 2200) * 2;
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.qcSave).last);
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(390, 844) * 2;
      await tester.pumpAndSettle();
      final set = s.qc.data.sets.single;

      // 2. Illustrative runs, one a day, recorded with the app's controller.
      Future<void> addRuns(int from, int to) async {
        for (var n = from; n <= to; n++) {
          final z = ((runs[n - 1]['z'] as List).cast<num>());
          final values = <String, double>{
            for (final (k, lv) in levels.indexed)
              lv['id'] as String: _round(
                ((lv["mean"] as num) + z[k] * (lv["sd"] as num)).toDouble(),
                lv['decimals'] as int,
              ),
          };
          await tester.runAsync(() => s.qc.addRun(set.id, values, at: DateTime(2026, 10, n, 8, 30)));
        }
        await tester.pumpAndSettle();
      }

      Finder rule(QcRule r) => find.textContaining(qcRuleText[r]!.of(code));

      await addRuns(1, data['hookRun']! as int);
      await goTo(tester, '/lab/qc/set/${set.id}');
      await w.bring(find.text(l.qcLatestRun), at: 200);
      await w.snap('qc_warn', marks: {'rule': rule(QcRule.r12s), 'verdict': find.text(l.qcWarning).first});

      await addRuns((data['hookRun']! as int) + 1, data['shiftRun']! as int);
      await goTo(tester, '/lab/qc');
      await goTo(tester, '/lab/qc/set/${set.id}');
      await w.bring(find.text(l.qcLatestRun), at: 200);
      await w.snap('qc_reject41', marks: {'rule': rule(QcRule.r41s), 'verdict': find.text(l.qcReject).first});

      await addRuns((data['shiftRun']! as int) + 1, runs.length);
      await goTo(tester, '/lab/qc');
      await goTo(tester, '/lab/qc/set/${set.id}');
      await w.bring(find.text(l.qcLatestRun), at: 200);
      await w.snap('qc_reject_r4s', marks: {'rule': rule(QcRule.rR4s), 'verdict': find.text(l.qcReject).first});

      // 3. Levey–Jennings charts (one per level), drawn by the app.
      final chart = find.byType(LeveyJenningsChart);
      await w.bring(chart, at: 330);
      await w.snap('qc_chart', marks: {'chart': chart, 'legend': find.text(l.qcChartLegend)});
      final first = tester.getRect(chart.first);
      await tester.drag(w.scrollable, Offset(0, -(first.height + 120)));
      await tester.pumpAndSettle();
      await w.snap('qc_chart2', marks: {'chart': chart});

      // 4. Observed statistics and the excluded (rejected) run in history.
      final stats = find.textContaining('${l.qcStats}: n = ');
      await w.toTop();
      await w.bring(stats, at: 380);
      await w.snap('qc_stats', marks: {'stats': stats, 'chart': chart});
      final excluded = find.text(l.qcRejectedExcluded);
      await w.bring(excluded, at: 470);
      await w.snap('qc_excluded', marks: {'excluded': excluded});

      // 5. Copy runs as CSV (the app's own export to the clipboard).
      // The app's snackbar after copying names two spreadsheet products, so
      // the frame is taken just before the tap (brand rule); the copied CSV
      // is recorded.
      await w.bring(find.text(l.qcCopyCsv), at: 560);
      await w.snap('qc_csv', tapOn: find.text(l.qcCopyCsv), marks: {'button': find.text(l.qcCopyCsv)});
      await tester.tap(find.text(l.qcCopyCsv));
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // 6. QC guides (explanations only: EQA, rejected samples, critical values).
      await goTo(tester, '/lab/qc');
      await w.bring(find.text(l.qcGuidesTitle), at: 360);
      await w.snap('qc_guides', marks: {
        'guides': find.text(l.qcGuidesTitle),
        'eqa': find.text(qcGuideTitle(QcGuide.eqa, l)),
      });

      final results = evaluateRuns(set, s.qc.data.runsOf(set.id));
      w.record.addAll({
        'setId': set.id,
        'verdicts': [
          for (final r in results)
            {'verdict': r.verdict.name, 'rules': [for (final v in r.violations) v.rule.code]},
        ],
        'values': [for (final r in s.qc.data.runsOf(set.id)) r.values],
        'statsText': [for (final e in stats.evaluate()) ((e.widget as Text).data ?? '')],
        'csv': clip,
      });
      w.save();
      expect(tester.takeException(), isNull);
    });
  }
}
