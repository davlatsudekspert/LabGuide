// LabGuide video studio — REAL app frames for flagship 2 "Leukocyte
// differential count".
//
// Every frame is the real app (widget-test render of LabGuideApp: real content
// pack, no server, guest, role = lab, Classic light theme, phone 390x844 @2x).
// Nothing inside the differential feature is mocked: the taps go through the
// app's own DiffCounterScreen / DiffEyesFreeScreen buttons and zones, and the
// percentages, absolute counts, assessment and copied text are the app's own.
// Only device plugins are faked (sound player, wake lock: the same fakes the
// app's own tests use) and the clipboard channel is recorded.
//
// The tapped sequence is read from the video's storyboard
// (docs/video/leukocyte/storyboard.json -> data.sequence), so the video's
// computed numbers and the app's numbers come from ONE illustrative tally.
//
// This file lives OUTSIDE the Flutter checkout on purpose (the checkout used
// for walking is read-only). Run it from the Flutter project root:
//
//   cd /home/user/wt-audit
//   flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
//     /home/user/wt-video/video_studio/flutter_walk/leukocyte_walk_test.dart \
//     --update-goldens
//
// Output (gitignored): video_studio/public/frames/<lang>/leukocyte/<id>.png
// + frames.json (id, size, tap point, measured highlight rectangles, copied
// text). Brand rule: no third-party brand or product name may be visible in
// any frame — the walk checks every visible text against a deny list and
// fails otherwise.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/differential/differential_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'file:///home/user/wt-audit/test/helpers/diff_device_fakes.dart';
import 'file:///home/user/wt-audit/test/helpers/harness.dart';

const _outRoot = '/home/user/wt-video/video_studio/public/frames';
const _storyboard = '/home/user/wt-video/docs/video/leukocyte/storyboard.json';
const _video = 'leukocyte';

/// Words that must never be on screen (manufacturers, analysers, publishers
/// used as brands). Bibliographic sources stay inside the app, off camera.
const _deny = [
  'Sysmex',
  'CellaVision',
  'Mindray',
  'Roche',
  'Abbott',
  'Beckman',
  'Siemens',
  'Horiba',
  'Bio-Rad',
  'MSD',
  'Merck',
  'McGraw',
  'Harrison',
  'MedlinePlus',
];

class _Walk {
  _Walk(this.tester, this.lang);

  final WidgetTester tester;
  final String lang;
  final List<Map<String, Object?>> frames = [];
  String? copied;

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

  /// Fails if a deny-listed brand word is inside the viewport.
  void brandCheck(String id) {
    for (final e in find.byType(RichText).evaluate()) {
      final w = e.widget as RichText;
      final s = w.text.toPlainText();
      for (final d in _deny) {
        if (!s.contains(d)) continue;
        final box = e.renderObject as RenderBox?;
        if (box == null || !box.attached || !box.hasSize) continue;
        final r = box.localToGlobal(Offset.zero) & box.size;
        final visible = r.bottom > 0 && r.top < 844 && r.right > 0 && r.left < 390;
        expect(visible, isFalse, reason: 'brand word "$d" visible in $id: "$s"');
      }
    }
  }

  Rect? _rect(Finder f) {
    final h = f.hitTestable();
    if (h.evaluate().isNotEmpty) return tester.getRect(h.first);
    if (f.evaluate().isEmpty) return null;
    final r = tester.getRect(f.first);
    final inView = r.bottom > 0 && r.top < 844;
    return inView ? r : null;
  }

  /// [marks] — named on-screen rectangles (logical px) that the video may
  /// highlight; measured here so the video never guesses UI positions.
  Future<void> snap(
    String id, {
    Offset? tap,
    Map<String, Finder> marks = const {},
    bool settle = true,
  }) async {
    if (settle) {
      FocusManager.instance.primaryFocus?.unfocus();
      await precache();
    }
    brandCheck(id);
    final rects = <String, List<double>>{};
    for (final e in marks.entries) {
      final r = _rect(e.value);
      if (r == null) continue;
      rects[e.key] = [r.left, r.top, r.width, r.height];
    }
    frames.add({
      'id': id,
      'file': '$id.png',
      'w': 390,
      'h': 844,
      'tap': tap == null ? null : [tap.dx, tap.dy],
      'marks': rects,
    });
    await expectLater(
      find.byType(LabGuideApp),
      matchesGoldenFile('../public/frames/$lang/$_video/$id.png'),
    );
  }

  Future<void> toTop() async {
    final s = _scrollable;
    await tester.drag(s, const Offset(0, 6000));
    await tester.pumpAndSettle();
  }

  /// Scrolls until [f] is visible, then brings it to screen y = [at].
  Future<void> bring(Finder f, {double at = 420}) async {
    if (f.evaluate().isEmpty) {
      // Not built yet (lazy list): scroll down, then up, until it exists.
      try {
        await tester.scrollUntilVisible(f, 250, scrollable: _scrollable, maxScrolls: 80);
      } on StateError {
        await tester.scrollUntilVisible(f, -250, scrollable: _scrollable, maxScrolls: 80);
      }
      await tester.pumpAndSettle();
    }
    if (f.hitTestable().evaluate().isEmpty) {
      await tester.ensureVisible(f.first);
      await tester.pumpAndSettle();
    }
    final y = tester.getCenter(f.first).dy;
    await tester.drag(_scrollable, Offset(0, -(y - at)));
    await tester.pumpAndSettle();
  }

  Future<void> field(String label, String value) async {
    await bring(find.text(label));
    final f = find.descendant(
      of: find
          .ancestor(of: find.text(label).last, matching: find.byType(Column))
          .first,
      matching: find.byType(TextField),
    );
    await tester.enterText(f.first, value);
    await tester.pumpAndSettle();
  }

  void save(Map<String, Object?> extra) {
    final dir = Directory('$_outRoot/$lang/$_video')..createSync(recursive: true);
    File('${dir.path}/frames.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'lang': lang,
        'video': _video,
        'source': 'video_studio/flutter_walk/leukocyte_walk_test.dart',
        'device': '390x844 @2x, Classic light, role lab, no server',
        ...extra,
        'frames': frames,
      }),
    );
  }
}

Finder _btn(DiffCell c) => find.byKey(ValueKey('diff-count-${c.name}'));
Finder _zone(DiffCell c) => find.byKey(ValueKey('ef-zone-${c.name}'));

void main() {
  setUpAll(loadAppFonts);
  final sb = jsonDecode(File(_storyboard).readAsStringSync()) as Map;
  final data = (sb['data'] as Map).cast<String, Object?>();
  final seq = [
    for (final n in (data['sequence']! as List).cast<String>())
      DiffCell.values.byName(n),
  ];
  final firstTaps = data['firstTaps']! as int;
  final midAt = data['midAt']! as int;
  final wbc = (data['wbc']! as num).toDouble();
  final label = data['label']! as String;
  final declared = (data['counts']! as Map).cast<String, Object?>();

  for (final lang in AppLanguage.values) {
    testWidgets('leukocyte walk ${lang.name}', (tester) async {
      final code = lang.name;
      final l = lookupAppLocalizations(lang.locale);
      installDiffFakes();
      final s = await makeServices(
        tester,
        language: lang,
        role: AppRole.lab,
        clock: () => DateTime(2026, 10, 25, 10, 30),
      );
      PaintingBinding.instance.imageCache
        ..maximumSize = 4000
        ..maximumSizeBytes = 1 << 30;
      final w = _Walk(tester, code);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            w.copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      await pumpApp(tester, s, ratio: 2);

      // 0. Lab tab: the differential card is the first item.
      await goTo(tester, '/lab');
      await w.snap('d_lab', marks: {'card': find.text(l.diffTitle)});

      // 1. Empty counter: one big button per cell class.
      await goTo(tester, '/lab/differential/count');
      final btnMarks = {
        for (final c in DiffCell.values) 'btn_${c.name}': _btn(c),
      };
      final total = find.textContaining('/ ${s.differential.target}');
      await w.snap('d_count0', marks: {...btnMarks, 'target': find.text('100')});

      // 2. First taps, one frame per tap. `tap` = the button that produced
      //    this frame (the video draws the ripple there, then cross-fades).
      for (var i = 0; i < firstTaps; i++) {
        final c = seq[i];
        final at = tester.getCenter(_btn(c).hitTestable().first);
        await tester.tap(_btn(c).hitTestable().first);
        await tester.pumpAndSettle();
        await w.snap(
          'd_tap${i + 1}',
          tap: at,
          marks: {...btnMarks, 'btn': _btn(c), 'total': total},
        );
      }
      expect(s.differential.total, firstTaps);

      // 3. Up to the middle of the count.
      Future<void> tapUntil(int n) async {
        while (s.differential.total < n) {
          final c = seq[s.differential.total];
          final f = _btn(c);
          if (f.hitTestable().evaluate().isEmpty) {
            await tester.ensureVisible(f);
            await tester.pumpAndSettle();
          }
          await tester.tap(f.hitTestable().first);
          await tester.pump(const Duration(milliseconds: 10));
        }
        await tester.pumpAndSettle();
        await w.toTop();
      }

      await tapUntil(midAt);
      await w.snap('d_half', marks: {'total': total, 'target': find.text('100')});

      // 4. Microscope mode (eyes-free): settings, zones, one zone tap.
      await w.bring(find.byKey(const ValueKey('diff-eyes-free')), at: 600);
      await tester.tap(find.byKey(const ValueKey('diff-eyes-free')));
      await tester.pumpAndSettle();
      await w.snap('ef_settings', marks: {'how': find.text(l.diffEfHowBody)});
      await w.bring(find.text(l.diffEfPatternsTitle), at: 230);
      await w.snap('ef_patterns', marks: {'patterns': find.text(l.diffEfPatternsTitle)});
      await w.bring(find.byKey(const ValueKey('eyes-free-start')), at: 600);
      await tester.tap(find.byKey(const ValueKey('eyes-free-start')));
      await tester.pumpAndSettle();
      final zoneMarks = {for (final c in DiffCell.values) 'zone_${c.name}': _zone(c)};
      await w.snap('ef_run', marks: {...zoneMarks, 'zones': _zone(DiffCell.lymphocyte)});
      final c51 = seq[midAt];
      final zAt = tester.getCenter(_zone(c51));
      await tester.tap(_zone(c51));
      await tester.pump(const Duration(milliseconds: 40));
      await w.snap('ef_tap', tap: zAt, marks: {...zoneMarks, 'zone': _zone(c51)}, settle: false);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(s.differential.total, midAt + 1);
      expect(s.differential.count(c51), seq.take(midAt + 1).where((x) => x == c51).length);
      await goTo(tester, '/lab/differential/count');

      // 5. To the target: counting stops; an extra tap is refused.
      await tapUntil(seq.length);
      await w.snap('d_done', marks: {'notice': find.text(l.diffDoneBody), 'total': total});
      for (final e in declared.entries) {
        expect(s.differential.count(DiffCell.values.byName(e.key)), e.value, reason: e.key);
      }
      await tester.tap(_btn(DiffCell.segmented).hitTestable().first);
      await tester.pumpAndSettle();
      expect(s.differential.total, seq.length);
      await w.snap('d_blocked', marks: {'snack': find.text(l.diffBlocked), 'total': total});
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();

      // 6. Result table: first without WBC, then with WBC (absolute column).
      await w.bring(find.text(l.diffResultTitle), at: 150);
      await w.snap('d_result', marks: {
        'table': find.byType(DiffResultTable),
        'need': find.text(l.diffAbsNeedWbc),
      });
      await w.field(l.diffWbcLabel, code == 'en' ? '8' : '8');
      expect(s.differential.wbc, wbc);
      await w.bring(find.text(l.diffWbcLabel), at: 250);
      await w.snap('d_wbc', marks: {
        'table': find.byType(DiffResultTable),
        'abs': find.text(l.diffColAbs),
        'wbc': find.text(l.diffWbcLabel),
      });

      // 7. Assessment ("not a diagnosis") and the report reference ranges.
      await w.bring(find.text(l.diffAssessNote), at: 560);
      await w.snap('d_assess', marks: {
        'title': find.text(l.diffAssessTitle),
        'note': find.text(l.diffAssessNote),
        'normal': find.text(l.diffAssessAllNormal),
      });
      await goTo(tester, '/lab/differential/limits');
      await w.snap('d_limits', marks: {'sub': find.text(l.diffLimitsSub)});

      // 8. Save (on this device) and copy as text.
      await goTo(tester, '/lab/differential/count');
      await w.field(l.diffLabelField, label);
      await w.bring(find.text(l.diffSave), at: 560);
      await tester.tap(find.text(l.diffSave));
      await tester.pumpAndSettle();
      await w.snap('d_saved', marks: {'snack': find.text(l.diffSaved), 'save': find.text(l.diffSave)});
      expect(s.differential.history, hasLength(1));
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.diffCopy));
      await tester.pumpAndSettle();
      await w.snap('d_copied', marks: {'snack': find.text(l.diffCopied), 'copy': find.text(l.diffCopy)});
      expect(w.copied, isNotNull);

      // 9. History list.
      await goTo(tester, '/lab/differential/history');
      await w.snap('d_history', marks: {'row': find.textContaining(label)});

      final r = s.differential.history.single;
      w.save({
        'copied': w.copied,
        'record': {
          'total': r.total,
          'wbc': r.wbc,
          'counts': {for (final c in DiffCell.values) c.name: r.count(c)},
          'percent': {for (final c in DiffCell.values) c.name: r.percent(c)},
          'absolute': {for (final c in DiffCell.values) c.name: r.absolute(c)},
        },
      });
      expect(tester.takeException(), isNull);
    });
  }
}
