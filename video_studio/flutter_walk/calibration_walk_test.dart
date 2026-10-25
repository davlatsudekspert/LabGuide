// LabGuide video studio — REAL app frames for the flagship "Calibration" video.
//
// Every frame is the real app (widget-test render of LabGuideApp: real content
// pack, no server, guest, role = lab, Classic light theme, phone 390x844 @2x).
// Nothing is mocked inside the calibration feature: the acceptance rule
// (approver + passing post-calibration QC) is the app's own
// `validateCalibrationAcceptance`, the log and history are the app's own
// screens.
//
// This file lives OUTSIDE the Flutter checkout on purpose (the checkout used
// for walking is read-only). Run it from the Flutter project root so that
// `package:labguide` and the asset paths resolve:
//
//   cd /home/user/wt-audit
//   flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
//     /home/user/wt-video/video_studio/flutter_walk/calibration_walk_test.dart \
//     --update-goldens
//
// Output (gitignored): video_studio/public/frames/<lang>/calibration/<id>.png
// + frames.json (id, size, tap point). Third-party brand names must never be
// on screen: a neutral custom instrument ("Demo") is used instead of a
// catalogue model, and frames are taken where the brand-example notice
// (calBrandWarning) is not visible.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/instruments/instrument_catalog.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'file:///home/user/wt-audit/test/helpers/harness.dart';

const _outRoot = '/home/user/wt-video/video_studio/public/frames';

/// Sample (illustrative) inputs — never patient or laboratory data.
const _approver = {
  'en': 'Lab manager',
  'ru': 'Зав. лабораторией',
  'uz': 'Laboratoriya mudiri',
};
const _model = {'en': 'Photometer A', 'ru': 'Фотометр A', 'uz': 'Fotometr A'};

class _Walk {
  _Walk(this.tester, this.lang);

  final WidgetTester tester;
  final String lang;
  final List<Map<String, Object?>> frames = [];

  Finder get _scrollable => find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable()
      .last;

  Future<void> precache() async {
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        await precacheImage((e.widget as Image).image, e);
      }
    });
    await tester.pumpAndSettle();
  }

  /// [marks] — named on-screen rectangles (logical px) that the video may
  /// highlight; measured here so the video never guesses UI positions.
  Future<void> snap(
    String id, {
    Finder? tap,
    Map<String, Finder> marks = const {},
  }) async {
    // No caret / selection handles in the frame.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    // Brand rule: the catalogue notice that names two manufacturers
    // (calBrandWarning) must never be on screen. If any part of it is inside
    // the viewport, push it below the bottom edge.
    final brand = find.text(lookupAppLocalizations(Locale(lang)).calBrandWarning);
    for (var i = 0; i < 3 && brand.evaluate().isNotEmpty; i++) {
      final r = tester.getRect(brand.first);
      if (r.bottom <= 0 || r.top >= 844) break;
      final dy = r.center.dy < 422 ? -(r.bottom + 12) : 844 - r.top + 24;
      await tester.drag(_scrollable, Offset(0, dy));
      await tester.pumpAndSettle();
    }
    if (brand.evaluate().isNotEmpty) {
      final r = tester.getRect(brand.first);
      expect(r.bottom <= 0 || r.top >= 844, isTrue, reason: 'brand notice visible in $id');
    }
    await precache();
    Offset? at;
    if (tap != null && tap.hitTestable().evaluate().isNotEmpty) {
      at = tester.getCenter(tap.hitTestable().first);
    }
    final rects = <String, List<double>>{};
    for (final e in marks.entries) {
      final f = e.value.hitTestable();
      if (f.evaluate().isEmpty) continue;
      final r = tester.getRect(f.first);
      rects[e.key] = [r.left, r.top, r.width, r.height];
    }
    frames.add({
      'id': id,
      'file': '$id.png',
      'w': 390,
      'h': 844,
      'tap': at == null ? null : [at.dx, at.dy],
      'marks': rects,
    });
    await expectLater(
      find.byType(LabGuideApp),
      matchesGoldenFile('../public/frames/$lang/calibration/$id.png'),
    );
  }

  /// Scrolls until [f] is visible, then brings it to screen y = [at].
  Future<void> bring(Finder f, {double at = 420}) async {
    // Laid out but off screen: jump straight to it (works above or below).
    for (var i = 0; i < 6 && f.evaluate().isNotEmpty; i++) {
      if (f.hitTestable().evaluate().isNotEmpty) break;
      final y0 = tester.getCenter(f.first).dy;
      await tester.drag(_scrollable, Offset(0, -(y0 - at)));
      await tester.pumpAndSettle();
    }
    if (f.hitTestable().evaluate().isEmpty) {
      try {
        await tester.scrollUntilVisible(
          f.hitTestable(),
          250,
          scrollable: _scrollable,
          maxScrolls: 80,
        );
      } on StateError {
        await tester.scrollUntilVisible(
          f.hitTestable(),
          -250,
          scrollable: _scrollable,
          maxScrolls: 80,
        );
      }
      await tester.pumpAndSettle();
    }
    final y = tester.getCenter(f.hitTestable().first).dy;
    await tester.drag(_scrollable, Offset(0, -(y - at)));
    await tester.pumpAndSettle();
  }

  Future<void> tapText(String text) async {
    final f = find.text(text);
    await tester.ensureVisible(f.last);
    await tester.pumpAndSettle();
    await bring(f.last);
    if (f.hitTestable().evaluate().isEmpty) {
      // ignore: avoid_print
      print('tapText: "$text" not hit-testable at ${tester.getRect(f.last)}');
    }
    await tester.tap(f.last, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  Future<void> field(String label, String value) async {
    await bring(find.text(label).last);
    final f = find.descendant(
      of: find
          .ancestor(of: find.text(label).last, matching: find.byType(Column))
          .first,
      matching: find.byType(TextField),
    );
    await tester.enterText(f.first, value);
    await tester.pumpAndSettle();
  }

  void save() {
    final dir = Directory('$_outRoot/$lang/calibration')
      ..createSync(recursive: true);
    File('${dir.path}/frames.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'lang': lang,
        'video': 'calibration',
        'source': 'video_studio/flutter_walk/calibration_walk_test.dart',
        'device': '390x844 @2x, Classic light, role lab, no server',
        'frames': frames,
      }),
    );
  }
}

void main() {
  setUpAll(loadAppFonts);
  for (final lang in AppLanguage.values) {
    testWidgets('calibration walk ${lang.name}', (tester) async {
      final code = lang.name;
      final l = lookupAppLocalizations(lang.locale);
      final s = await makeServices(tester, language: lang, role: AppRole.lab);
      PaintingBinding.instance.imageCache
        ..maximumSize = 4000
        ..maximumSizeBytes = 1 << 30;
      final mine = await tester.runAsync(
        () => s.instruments.addCustom(
          maker: 'Demo',
          model: _model[code]!,
          category: InstrumentCategory.chemistry,
        ),
      );
      await pumpApp(tester, s, ratio: 2);
      final w = _Walk(tester, code);

      // 1. The calibration path with instrument + analyte chosen.
      await goTo(
        tester,
        '/lab/calibration?mine=${mine!.id}&analyte=glucose-plasma-fasting',
      );
      await w.bring(find.text(l.calStepInstrument), at: 200);
      await w.snap('cal_path', marks: {'instrument': find.text(l.calStepInstrument), 'analyte': find.text(l.calStepAnalyte)});

      // 2. Reagent REF + IFU revision (sample values) -> "Show guide".
      await w.field(l.calReagentRef, '10121');
      await w.field(l.calIfuRevision, '2024-01');
      // Low enough that the brand-example notice below stays off screen.
      await w.bring(find.text(l.calShowGuide), at: 690);
      await w.snap('cal_reagent', tap: find.text(l.calShowGuide), marks: {'ref': find.text(l.calReagentRef), 'ifu': find.text(l.calIfuRevision), 'button': find.text(l.calShowGuide)});
      await w.tapText(l.calShowGuide);

      // 3. No verified guide for a custom instrument: the app does not guess
      //    parameters and lists where they come from (IFU, value sheet, QC).
      await w.bring(find.text(l.calGuideNoneTitle), at: 260);
      await w.snap('cal_guide', marks: {'notice': find.text(l.calGuideNoneTitle), 'step3': find.text(l.calGuide3), 'step5': find.text(l.calGuide5)});

      // 4. Record form: calibrator lot, level value and unit (sample values).
      await w.tapText(l.calRecordCreate);
      await w.field(l.calCalibratorLot, 'L-77');
      await w.field(l.calLevelValue, code == 'en' ? '5.55' : '5,55');
      await w.field(l.calLevelUnit, 'mmol/L');
      await w.bring(find.text(l.calRecordTitle), at: 180);
      await w.snap('cal_record', marks: {'title': find.text(l.calRecordTitle), 'lot': find.text(l.calCalibratorLot), 'levels': find.text(l.calLevels), 'sheet': find.text(l.calValuesFromSheet)});

      // 5. Rule 1: "Accepted" cannot be chosen while QC after calibration has
      //    not passed (default = QC not run).
      await w.tapText(l.calOutcomeAccepted);
      await w.bring(find.text(l.calSafeQcAfter), at: 300);
      await w.snap('cal_rule_qc', marks: {'qc': find.text(l.calSafeQcAfter), 'warn': find.text(l.calSafeQcNotRunWarn), 'accepted': find.text(l.calOutcomeAccepted)});
      await w.bring(find.text(l.calSafeQcPassRequired), at: 600);
      await w.snap('cal_rule_qc_err', marks: {'error': find.text(l.calSafeQcPassRequired)});

      // 6. Rule 2: QC passed + Accepted, but no approver -> save refused.
      await w.tapText(l.calSafeQcPass);
      await w.tapText(l.calOutcomeAccepted);
      await w.tapText(l.calRecordSave);
      await w.bring(find.text(l.calSafeApproverRequired), at: 600);
      await w.snap('cal_rule_approver', marks: {'error': find.text(l.calSafeApproverRequired), 'approver': find.text(l.calSafeApprovedBy), 'qcpass': find.text(l.calSafeQcPass)});
      expect(s.instruments.records, isEmpty);

      // 7. Authorised approver entered -> the record can be saved.
      await w.field(l.calSafeApprovedBy, _approver[code]!);
      await w.bring(find.text(l.calSafeQcAfter), at: 260);
      await w.snap('cal_ready', tap: find.text(l.calRecordSave), marks: {'qcpass': find.text(l.calSafeQcPass), 'accepted': find.text(l.calOutcomeAccepted), 'approver': find.text(_approver[code]!), 'save': find.text(l.calRecordSave)});
      await w.tapText(l.calRecordSave);
      await tester.pump(const Duration(milliseconds: 400));
      // Back to the top of the page (the snackbar stays): keeps the
      // brand-example notice far below the viewport.
      await tester.drag(w._scrollable, const Offset(0, 4000));
      await tester.pumpAndSettle();
      await w.snap('cal_saved', marks: {'snack': find.text(l.calRecordSaved)});
      final r = s.instruments.records.single;
      expect(r.approvedBy, _approver[code]);

      // 8. Log + history, then the record itself.
      await goTo(tester, '/lab/calibration/log');
      await w.snap('cal_log', marks: {'history': find.text(l.calSafeHistory)});
      await goTo(tester, '/lab/calibration/log/${r.id}');
      await w.snap('cal_detail', marks: {'qc': find.text(l.calSafeQcAfter), 'approver': find.text(l.calSafeApprovedBy)});
      await w.bring(find.text(l.calSafeHistory), at: 360);
      await w.snap('cal_history', marks: {'history': find.text(l.calSafeHistory), 'note': find.text(l.calSafeHistoryNote)});
      w.save();
      expect(tester.takeException(), isNull);
    });
  }
}
