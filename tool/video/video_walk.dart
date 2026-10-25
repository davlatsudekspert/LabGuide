// Video qo‘llanmalar uchun kadrlar (docs/video/PLAN.md): har kadr — ilovaning
// haqiqiy ekrani (widget test render), keyingi bosiladigan joy (tap) bilan.
// Chiqish: tool/video/out/frames/<til>/<mavzu>/<kadr>.png + frames.json.
// Video tool/video/compose.py bilan yig‘iladi (ovozsiz, subtitrli).
//
// tool/screenshots/tutorial_helper.dart (TutorialWalk) asosida; farqi —
// kadr nomi storyboarddagi id ga teng (tartib raqamisiz), rasmlar har
// kadrdan oldin dekodlanadi, telefon 390×844 @2x (fayllar kichikroq).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';

/// Ilovani video uchun ishga tushiradi (haqiqiy kontent, serversiz).
Future<AppServices> startVideo(
  WidgetTester tester, {
  required AppLanguage lang,
  AppRole role = AppRole.lab,
}) async {
  final s = await makeServices(tester, language: lang, role: role);
  PaintingBinding.instance.imageCache
    ..maximumSize = 4000
    ..maximumSizeBytes = 1 << 30;
  await pumpApp(tester, s, ratio: 2);
  return s;
}

class VideoWalk {
  VideoWalk(this.tester, this.lang, this.topic);

  final WidgetTester tester;
  final String lang;
  final String topic;
  final List<Map<String, Object?>> _frames = [];

  /// Oxirgi kadrdan beri ekran surildimi (unda tap belgisi qo‘yilmaydi).
  bool _moved = false;

  String get _dir => 'out/frames/$lang/$topic';

  Finder get _scrollable => find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable()
      .last;

  /// Ekrandagi barcha rasmlarni dekodlaydi (testda rasm faqat real async'da
  /// yuklanadi; aks holda kadrda bo‘sh joy qoladi).
  Future<void> precache() async {
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        await precacheImage((e.widget as Image).image, e);
      }
      for (final e in find.byType(DecoratedBox).evaluate()) {
        final d = (e.widget as DecoratedBox).decoration;
        if (d is BoxDecoration && d.image != null) {
          await precacheImage(d.image!.image, e);
        }
      }
      for (final e in find.byType(Ink).evaluate()) {
        final d = (e.widget as Ink).decoration;
        if (d is BoxDecoration && d.image != null) {
          await precacheImage(d.image!.image, e);
        }
      }
    });
    await tester.pumpAndSettle();
  }

  /// Kadr: [id] — storyboarddagi kadr nomi.
  Future<void> snap(String id) async {
    assert(!_frames.any((f) => f['id'] == id), 'takror kadr: $id');
    await precache();
    final view = tester.view;
    _frames.add({
      'id': id,
      'file': '$id.png',
      'w': view.physicalSize.width / view.devicePixelRatio,
      'h': view.physicalSize.height / view.devicePixelRatio,
      'tap': null,
    });
    _moved = false;
    await expectLater(
      find.byType(LabGuideApp),
      matchesGoldenFile('$_dir/$id.png'),
    );
  }

  /// [f] ko‘rinmasa — topilguncha suradi (pastga, so‘ng tepaga).
  Future<void> show(Finder f, {double step = 250}) async {
    if (f.hitTestable().evaluate().isNotEmpty) return;
    final above = f.evaluate().isNotEmpty && tester.getTopLeft(f.first).dy < 120;
    try {
      await tester.scrollUntilVisible(
        f.hitTestable(),
        above ? -step : step,
        scrollable: _scrollable,
        maxScrolls: 60,
      );
    } on StateError {
      await tester.scrollUntilVisible(
        f.hitTestable(),
        above ? step : -step,
        scrollable: _scrollable,
        maxScrolls: 60,
      );
    }
    await tester.pumpAndSettle();
    // Pastki menyu ostida qolmasin: ekran o‘rtasiga yaqinlashtiriladi.
    final y = tester.getCenter(f.hitTestable().first).dy;
    final h = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    if (y > h - 150) await scroll(y - h / 2);
    _moved = true;
  }

  /// Bosadi; oxirgi kadrdan beri ekran surilmagan bo‘lsa — kadrga tap
  /// belgisi qo‘yiladi (videoda “shu yerni bosing” doirasi).
  Future<void> press(Finder f, {bool settle = true}) async {
    await show(f);
    final target = f.hitTestable().first;
    final at = tester.getCenter(target);
    if (!_moved && _frames.isNotEmpty) _frames.last['tap'] = [at.dx, at.dy];
    await tester.tap(target);
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 300));
    }
    _moved = true;
  }

  Future<void> pressText(String text) => press(find.text(text));

  Future<void> pressKey(String key) => press(find.byKey(ValueKey(key)));

  /// Matn maydoniga yozadi (ekran o‘zgaradi — keyingi tap belgisi oldingi
  /// kadrga qo‘yilmaydi).
  Future<void> type(Finder f, String text) async {
    await tester.enterText(f, text);
    await tester.pumpAndSettle();
    _moved = true;
  }

  Future<void> scroll(double dy) async {
    await tester.drag(_scrollable, Offset(0, -dy));
    await tester.pumpAndSettle();
    _moved = true;
  }

  Future<void> go(String location) async {
    await goTo(tester, location);
    _moved = true;
  }

  /// frames.json (kadrlar tartibi, o‘lchami, tap nuqtalari).
  void save() {
    final dir = Directory('tool/video/$_dir')..createSync(recursive: true);
    File('${dir.path}/frames.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'lang': lang,
        'topic': topic,
        'frames': _frames,
      }),
    );
  }
}
