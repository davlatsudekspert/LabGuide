// Video kadrlari yozuvchisi: haqiqiy ilova vidjetlaridan 1080x1920 PNG va
// bosiladigan vidjet to'rtburchagi (logik 360x640) JSON'da.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app.dart';
import 'package:material_ui/material_ui.dart';

import '../screenshots/walk_helper.dart';

const framesRoot = '/home/user/labguide-videos/work/frames';

/// Vidjet navigatsiya paneli va sarlavhadan uzoqda (ekran o'rtasida) bo'lsin.
Future<void> centerOn(
  WidgetTester tester,
  Finder f, {
  double alignment = 0.4,
  bool force = false,
}) async {
  final r = tester.getRect(f);
  if (force || ((r.top < 100 || r.bottom > 500) && r.height < 300)) {
    if (Scrollable.maybeOf(tester.element(f)) == null) return;
    await Scrollable.ensureVisible(
      tester.element(f),
      alignment: alignment,
      duration: Duration.zero,
    );
    await tester.pumpAndSettle();
  }
}

class Rec extends Walk {
  Rec(WidgetTester tester, String video) : super(tester, video) {
    dir = Directory('$framesRoot/$video')..createSync(recursive: true);
    for (final f in dir.listSync()) {
      f.deleteSync();
    }
  }

  late final Directory dir;
  final List<Map<String, Object?>> frames = [];
  bool on = true;

  /// Kadr: [id] — Python'dagi sarlavha kaliti. [target] — keyingi bosiladigan
  /// vidjet (ajratib ko'rsatiladi), [kind] 'tap' | 'type' | 'none'.
  Future<void> shot(
    String id, {
    Finder? target,
    String kind = 'tap',
    bool scrollTo = true,
  }) async {
    if (!on) return;
    Future<void> settle() async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 120)),
      );
      await tester.pumpAndSettle();
    }

    await settle();
    List<double>? rect;
    if (target != null) {
      var f = target.first;
      if (scrollTo) {
        await centerOn(tester, f);
        await settle();
        f = target.first;
      }
      // Matn bo'lsa — uni o'rab turgan tugma/qator to'rtburchagi.
      final up = find.ancestor(
        of: f,
        matching: find.byWidgetPredicate(
          (w) => const {
            'LgPressable',
            'LgButton',
            'InkWell',
            'CheckboxListTile',
            'ListTile',
          }.contains(w.runtimeType.toString()),
        ),
      );
      if (up.evaluate().isNotEmpty) f = up.first;
      final r = tester.getRect(f);
      rect = [r.left, r.top, r.width, r.height];
    }
    final file = '${(frames.length + 1).toString().padLeft(2, '0')}_$id.png';
    await expectLater(
      find.byType(LabGuideApp),
      matchesGoldenFile('$framesRoot/${dir.uri.pathSegments.where((s) => s.isNotEmpty).last}/$file'),
    );
    // ignore: avoid_print
    print('SHOT $id');
    frames.add({'id': id, 'file': file, 'rect': rect, 'kind': target == null ? 'none' : kind});
    save();
  }

  void save() {
    File('${dir.path}/frames.json').writeAsStringSync(
      const JsonEncoder.withIndent(' ').convert(frames),
    );
  }
}
