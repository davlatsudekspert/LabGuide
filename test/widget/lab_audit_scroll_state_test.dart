// Lab tabi auditi (2026-10-18): Lab tabidagi har bir statik sahifa iPhone
// o'lchamida (390×844, DPR 3, notch, iOS fizikasi) — scroll qo'yib
// yuborilgan joyda qoladi (snap-back yo'q), ro'yxat oxiridagi bounce oxirgi
// joyga qaytaradi, oxirgi kontent suzuvchi pastki menyu ostida qolmaydi; tab
// almashganda kiritilgan qiymatlar yo'qolmaydi.
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import 'lab_audit_routes.dart';

const _iphone = Size(390, 844);

Finder _list() => find
    .descendant(
      of: find.byType(LgPage).hitTestable().first,
      matching: find.byType(Scrollable),
    )
    .first;

ScrollPosition _pos(WidgetTester tester) =>
    tester.state<ScrollableState>(_list()).position;

Future<double> _drag(WidgetTester tester, double dy, {int steps = 20}) async {
  final g = await tester.startGesture(tester.getCenter(_list()));
  for (var i = 0; i < steps; i++) {
    await g.moveBy(Offset(0, dy / steps));
    await tester.pump(const Duration(milliseconds: 16));
  }
  final atRelease = _pos(tester).pixels;
  await g.up();
  return atRelease;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  // Faqat scroll qilinadigan (ekrandan uzun) sahifalar; hisoblagich kabi
  // to'liq ekranli sahifalar (eyes-free) LgPage'siz — o'tkazib yuboriladi.
  testWidgets('Lab sahifalari: scroll joyida, bounce oxirga, menyu ustida', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final s = await makeServices(tester, language: AppLanguage.uz);
    await pumpApp(tester, s, size: _iphone);
    final failures = <String>[];
    for (final route in labStaticRoutes) {
      await goTo(tester, route);
      if (find.byType(LgPage).hitTestable().evaluate().isEmpty) continue;
      final pos = _pos(tester);
      if (pos.maxScrollExtent < 200) continue;
      expect(pos.physics, isA<BouncingScrollPhysics>(), reason: route);
      // 1) O'rtada: sekin tortib qo'yib yuborish — joy saqlanadi.
      for (final dy in [-120.0, 60.0, -90.0]) {
        final released = await _drag(tester, dy, steps: 12);
        await _settle(tester);
        final want = released.clamp(pos.minScrollExtent, pos.maxScrollExtent);
        if ((_pos(tester).pixels - want).abs() > 1) {
          failures.add('$route: drag $dy → ${_pos(tester).pixels} ≠ $want');
        }
      }
      // 2) Oxirigacha va overscroll: bounce oxirgi joyga qaytaradi.
      // Dangasa ro'yxatda maxScrollExtent taxminiy — haqiqiy oxirgacha.
      for (var i = 0; i < 40; i++) {
        final max = _pos(tester).maxScrollExtent;
        _pos(tester).jumpTo(max);
        await _settle(tester);
        if ((_pos(tester).maxScrollExtent - max).abs() < 0.5) break;
      }
      for (var i = 0; i < 2; i++) {
        await _drag(tester, -150);
        await _settle(tester);
        final p = _pos(tester);
        if ((p.pixels - p.maxScrollExtent).abs() > 1) {
          failures.add('$route: bounce → ${p.pixels} ≠ ${p.maxScrollExtent}');
        }
      }
      // 3) Oxirgi kontent pastki menyu (Lab tugmasi) ustida.
      final page = tester.widget<LgPage>(
        find.byType(LgPage).hitTestable().first,
      );
      final last = find.byWidget(page.children.last);
      if (last.evaluate().isNotEmpty) {
        final navTop = tester
            .getTopLeft(find.byKey(const ValueKey('nav-pill')))
            .dy;
        final labTop = tester
            .getTopLeft(find.byKey(const ValueKey('nav-lab-circle')))
            .dy;
        final limit = labTop < navTop ? labTop : navTop;
        final bottom = tester.getRect(last).bottom;
        if (bottom > limit + 0.5) {
          failures.add('$route: oxirgi element $bottom > menyu $limit');
        }
      }
      expect(tester.takeException(), isNull, reason: route);
    }
    debugDefaultTargetPlatformOverride = null;
    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  // Tab almashganda kiritilgan qiymat saqlanadi (StatefulShellRoute).
  for (final (route, key, prep) in [
    ('/lab/coagulogram/sample', 'coag-citrate-hct', null),
    ('/lab/coagulogram/dic', 'coag-dic-plt', 'coag-dic-under-yes'),
  ]) {
    testWidgets('tab almashganda qiymat saqlanadi: $route', (tester) async {
      final s = await makeServices(tester, language: AppLanguage.ru);
      await pumpApp(tester, s, size: const Size(360, 640), textScale: 1.3);
      await goTo(tester, route);
      Future<void> reveal(Finder f) async {
        if (f.evaluate().isEmpty) {
          await tester.scrollUntilVisible(f, 200, scrollable: _list());
        }
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
      }

      if (prep != null) {
        await reveal(find.byKey(ValueKey(prep)));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey(prep)));
        await tester.pumpAndSettle();
      }
      final field = find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(TextField),
      );
      await reveal(field);
      await tester.enterText(field, '61,5');
      await tester.pumpAndSettle();
      await tapNavTab(tester, 0);
      await tapNavTab(tester, 4);
      await tapNavTab(tester, 2);
      expect(routerOf(tester).state.matchedLocation, route);
      expect(tester.widget<TextField>(field).controller!.text, '61,5');
    });
  }

  testWidgets('tab almashganda leykoformula sanog‘i saqlanadi', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, platformBrightness: Brightness.dark);
    await goTo(tester, '/lab/differential/count');
    final diff = s.differential;
    final before = diff.total;
    final key = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('diff-count-'),
    );
    expect(key, findsWidgets);
    await tester.tap(key.first);
    await tester.tap(key.first);
    await tester.pumpAndSettle();
    expect(diff.total, before + 2);
    await tapNavTab(tester, 1);
    await tapNavTab(tester, 2);
    expect(routerOf(tester).state.matchedLocation, '/lab/differential/count');
    expect(diff.total, before + 2);
  });
}
