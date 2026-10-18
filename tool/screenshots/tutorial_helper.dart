// Qo'llanma videolari uchun kadrlar (docs/TUTORIAL_VIDEOS.md): har qadam —
// ekran rasmi (tool/screenshots/out/tutorial/<nom>/NN_<qadam>.png) va keyingi
// bosiladigan joy (tap) koordinatasi — frames.json. Video
// tool/screenshots/tutorial_compose.py bilan yig'iladi.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app.dart';
import 'package:material_ui/material_ui.dart';

class TutorialWalk {
  TutorialWalk(this.tester, this.name);

  final WidgetTester tester;
  final String name;
  final List<Map<String, Object?>> _frames = [];

  String get _dir => 'out/tutorial/$name';

  /// Ekran rasmi. [settle] = false — cheksiz animatsiyali ekranlar uchun.
  Future<void> snap(String step, {bool settle = true}) async {
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 400));
    }
    final file = '${(_frames.length + 1).toString().padLeft(2, '0')}_$step.png';
    final view = tester.view;
    _frames.add({
      'file': file,
      'step': step,
      'w': view.physicalSize.width / view.devicePixelRatio,
      'h': view.physicalSize.height / view.devicePixelRatio,
      'dpr': view.devicePixelRatio,
      'tap': null,
    });
    await expectLater(
      find.byType(LabGuideApp),
      matchesGoldenFile('$_dir/$file'),
    );
  }

  /// Oxirgi kadrga "shu yerni bosing" belgisi (mantiqiy px).
  void markTap(Offset at) {
    if (_frames.isNotEmpty) _frames.last['tap'] = [at.dx, at.dy];
  }

  /// [f] ni ko'rinadigan qilib, oxirgi kadrga belgilab, bosadi. Agar
  /// ko'rinadigan qilish uchun scroll kerak bo'lsa — avval scroll kadri.
  Future<void> tap(
    Finder f, {
    bool settle = true,
    String? scrolledStep = 'scroll',
  }) async {
    var lazy = false;
    if (f.evaluate().isEmpty) {
      // Dangasa ro'yxat: element hali qurilmagan — pastga suriladi.
      lazy = true;
      await tester.scrollUntilVisible(
        f,
        250,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .hitTestable()
            .first,
      );
    }
    final before = lazy ? Offset.infinite : tester.getCenter(f.first);
    // Ekranda va bosiladigan bo'lsa — surilmaydi (kadr sakramasin).
    if (lazy || f.first.hitTestable().evaluate().isEmpty) {
      await tester.ensureVisible(f.first);
      await tester.pumpAndSettle();
    }
    final at = tester.getCenter(f.first);
    if (scrolledStep != null && (lazy || (at - before).distance > 4)) {
      await snap(scrolledStep);
    }
    markTap(at);
    await tester.tap(f.first);
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  Future<void> tapText(String text, {String scrolledStep = 'scroll'}) {
    final visible = find.text(text).hitTestable();
    return tap(
      visible.evaluate().isNotEmpty
          ? visible
          : find.text(text, skipOffstage: false),
      scrolledStep: scrolledStep,
    );
  }

  Future<void> tapKey(String key, {String scrolledStep = 'scroll'}) =>
      tap(find.byKey(ValueKey(key)), scrolledStep: scrolledStep);

  Future<void> scroll(double dy) async {
    await tester.drag(
      find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .hitTestable()
          .first,
      Offset(0, -dy),
    );
    await tester.pumpAndSettle();
  }

  /// frames.json (kadrlar tartibi, o'lchami, tap nuqtalari).
  void save() {
    final dir = Directory('tool/screenshots/$_dir')
      ..createSync(recursive: true);
    File('${dir.path}/frames.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({'frames': _frames}),
    );
  }
}
