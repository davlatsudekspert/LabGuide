// LabGuide video studio — shared helpers for the REAL-app frame walks of the
// topic videos (photometry, qc, gcms, qpcr, osmometry, calculators …).
// Generalised from the leukocyte flagship walk: one `Walk` per language,
// golden PNGs into video_studio/public/frames/<lang>/<video>/ plus a
// frames.json with measured highlight rectangles, and a brand check that
// fails the walk if a deny-listed third-party name is visible.
//
// Imported by the per-video walk tests with a relative import; those tests
// are run FROM the read-only Flutter checkout so `package:labguide`
// resolves:
//   cd /home/user/wt-audit
//   flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
//     /home/user/wt-video/video_studio/flutter_walk/<id>_walk_test.dart --update-goldens
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app.dart';
import 'package:material_ui/material_ui.dart';

const outRoot = '/home/user/wt-video/video_studio/public/frames';

/// Words that must never be on screen (manufacturers, analysers, kit makers,
/// publishers used as brands). Bibliographic sources stay in the app, off
/// camera.
const denyBrands = [
  'Sysmex', 'CellaVision', 'Mindray', 'Roche', 'Abbott', 'Beckman', 'Siemens',
  'Horiba', 'Bio-Rad', 'Biorad', 'MSD', 'Merck', 'McGraw', 'Harrison',
  'MedlinePlus', 'SPINREACT', 'Spinreact', 'Hospitex', 'Screen Master',
  'HumaLyzer', 'Humalyzer', 'HumaStar', 'cobas', 'Cobas', 'Architect',
  'Alinity', 'Cepheid', 'GeneXpert', 'Xpert', 'BACTEC', 'VITEK', 'bioMérieux',
  'Truenat', 'Molbio', 'Geenius', 'Luminex', 'Erba', 'BioSystems', 'Randox',
  'Thermo Fisher', 'Agilent', 'Shimadzu', 'Applied Biosystems', 'QIAGEN',
  'Qiagen', 'Bio-Techne', 'Advanced Instruments', 'Wescor', 'Vitros',
  'Ortho Clinical', 'Diasys', 'DiaSys', 'Human GmbH', 'Excel', 'Google Sheets',
  'Telegram', 'WhatsApp', 'YouTube',
];

class Walk {
  Walk(this.tester, this.lang, this.video, {this.source = ''});

  final WidgetTester tester;
  final String lang;
  final String video;
  final String source;
  final List<Map<String, Object?>> frames = [];
  final Map<String, Object?> record = {};

  /// Logical view size (portrait phone 390x844, or landscape 844x390).
  Size get view => tester.view.physicalSize / tester.view.devicePixelRatio;

  Finder get scrollable => find
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
      for (final d in denyBrands) {
        if (!s.contains(d)) continue;
        final box = e.renderObject as RenderBox?;
        if (box == null || !box.attached || !box.hasSize) continue;
        final r = box.localToGlobal(Offset.zero) & box.size;
        final visible = r.bottom > 0 &&
            r.top < view.height &&
            r.right > 0 &&
            r.left < view.width;
        expect(visible, isFalse, reason: 'brand word "$d" visible in $id: "$s"');
      }
    }
  }

  Rect? rectOf(Finder f) {
    final h = f.hitTestable();
    if (h.evaluate().isNotEmpty) return tester.getRect(h.first);
    if (f.evaluate().isEmpty) return null;
    final r = tester.getRect(f.first);
    final inView = r.bottom > 0 && r.top < view.height;
    return inView ? r : null;
  }

  /// Visible texts (for the claims table: what the app itself says).
  List<String> visibleTexts() {
    final out = <String>[];
    for (final e in find.byType(RichText).evaluate()) {
      final box = e.renderObject as RenderBox?;
      if (box == null || !box.attached || !box.hasSize) continue;
      final r = box.localToGlobal(Offset.zero) & box.size;
      if (r.bottom <= 0 || r.top >= view.height) continue;
      final s = (e.widget as RichText).text.toPlainText().trim();
      if (s.isNotEmpty) out.add(s);
    }
    return out;
  }

  /// [marks] — named on-screen rectangles (logical px) that the video may
  /// highlight; measured here so the video never guesses UI positions.
  Future<void> snap(
    String id, {
    Offset? tap,
    Finder? tapOn,
    Map<String, Finder> marks = const {},
    bool settle = true,
    bool texts = false,
  }) async {
    if (settle) {
      FocusManager.instance.primaryFocus?.unfocus();
      await precache();
    }
    brandCheck(id);
    final rects = <String, List<double>>{};
    for (final e in marks.entries) {
      final r = rectOf(e.value);
      if (r == null) continue;
      rects[e.key] = [r.left, r.top, r.width, r.height];
    }
    Offset? at = tap;
    if (at == null && tapOn != null) {
      final r = rectOf(tapOn);
      if (r != null) at = r.center;
    }
    frames.add({
      'id': id,
      'file': '$id.png',
      'w': view.width,
      'h': view.height,
      'tap': at == null ? null : [at.dx, at.dy],
      'marks': rects,
      if (texts) 'texts': visibleTexts(),
    });
    await expectLater(
      find.byType(LabGuideApp),
      matchesGoldenFile('$outRoot/$lang/$video/$id.png'),
    );
  }

  Future<void> toTop() async {
    await tester.drag(scrollable, const Offset(0, 6000));
    await tester.pumpAndSettle();
  }

  /// Scrolls until [f] is built and visible, then brings it to screen y = [at].
  Future<void> bring(Finder f, {double at = 420}) async {
    bool has() {
      try {
        return f.evaluate().isNotEmpty;
      } on StateError {
        return false;
      } on RangeError {
        return false;
      }
    }

    // Lazy lists: drag until the widget is built (down, then up).
    for (final dy in [-250.0, 250.0]) {
      for (var i = 0; i < 80 && !has(); i++) {
        await tester.drag(scrollable, Offset(0, dy));
        await tester.pumpAndSettle();
      }
      if (has()) break;
    }
    if (f.hitTestable().evaluate().isEmpty) {
      await tester.ensureVisible(f.first);
      await tester.pumpAndSettle();
    }
    final y = tester.getCenter(f.first).dy;
    // A drag shorter than the touch slop is a TAP (it opened a list row once).
    if ((y - at).abs() > 24) {
      await tester.drag(scrollable, Offset(0, -(y - at)));
      await tester.pumpAndSettle();
    }
  }

  /// Text field identified by its label text (LgField: label above the field).
  Future<void> field(String label, String value, {int which = 0}) async {
    await bring(find.text(label).at(which));
    final f = find.descendant(
      of: find
          .ancestor(of: find.text(label).at(which), matching: find.byType(Column))
          .first,
      matching: find.byType(TextField),
    );
    await tester.enterText(f.first, value);
    await tester.pumpAndSettle();
  }

  Future<void> tap(Finder f) async {
    await bring(f);
    await tester.tap(f.hitTestable().first);
    await tester.pumpAndSettle();
  }

  void save([Map<String, Object?> extra = const {}]) {
    final dir = Directory('$outRoot/$lang/$video')..createSync(recursive: true);
    File('${dir.path}/frames.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'lang': lang,
        'video': video,
        'source': source,
        'device': '390x844 @2x, Classic light, no server',
        ...extra,
        if (record.isNotEmpty) 'record': record,
        'frames': frames,
      }),
    );
  }
}
