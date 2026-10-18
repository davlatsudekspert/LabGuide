// iPhone xatosi (2026-10-18, docs/BUGS_2026-10-18_IPHONE.md): "yuqoriga
// surganda pastga qaytib tushadi".
//
// Sabab: ro'yxat oxiridagi iOS bounce (overscroll va undan qaytish)
// [CollapseHysteresis] ga foydalanuvchining teskari scroll'i bo'lib
// borardi → katta sarlavha kengayib, viewport kichrayardi va ballistik
// simulyatsiya qayta boshlanib, kontent foydalanuvchi qo'yib yuborgan
// joydan PASTGA "tushib" ketardi. Ro'yxat oxiriga yaqin sarlavha
// yig'ilishi ham pozitsiyani chegaradan tashqariga chiqarib, xuddi shu
// qaytishni keltirib chiqarardi.
//
// Haqiqiy iPhone o'lchamlari: 390×844, DPR 3, notch (47/34), iOS fizikasi
// (BouncingScrollPhysics).
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';

const _iphone = Size(390, 844);

/// Ko'rinib turgan LgPage ro'yxati.
Finder _list() => find
    .descendant(
      of: find.byType(LgPage).hitTestable().first,
      matching: find.byType(Scrollable),
    )
    .first;

ScrollPosition _pos(WidgetTester tester) =>
    tester.state<ScrollableState>(_list()).position;

/// Barmoq bilan sekin tortish ([dy] < 0 — kontent yuqoriga, ro'yxat
/// oxiriga qarab), so'ng qo'yib yuborish. Qo'yib yuborilgan paytdagi
/// offset qaytariladi.
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

/// Bounce va animatsiyalar tugaguncha; keyin yana 1 s — hech narsa
/// "o'zi" siljimasligi kerak.
Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

/// Sahifa uchun umumiy tekshiruvlar.
Future<void> _checkPage(WidgetTester tester) async {
  final pos = _pos(tester);
  expect(pos.physics, isA<BouncingScrollPhysics>(), reason: 'iOS fizikasi');

  // 1) Sekin, mayda qadamlarda ostona (14 px) atrofida pastga-yuqoriga:
  // qo'yib yuborilgan joy saqlanadi (ro'yxat ichida — fling yo'q).
  // (Har biri touch slop (18 px) dan katta — aks holda bu bosish bo'lib,
  // kartani ochib yuborardi.)
  for (final dy in [-40.0, 32.0, -34.0, 36.0, -60.0, 30.0]) {
    final released = await _drag(tester, dy, steps: 12);
    await _settle(tester);
    expect(
      _pos(tester).pixels,
      moreOrLessEquals(
        released.clamp(pos.minScrollExtent, pos.maxScrollExtent),
        epsilon: 1,
      ),
      reason: 'offset o\'zi siljimadi (drag $dy)',
    );
  }

  // 2) Ro'yxat oxirigacha va undan ham o'tib (overscroll) qayta-qayta:
  // bounce faqat oxirgi joyga qaytaradi, pastroqqa "tushib" ketmaydi.
  for (
    var i = 0;
    i < 15 && _pos(tester).pixels < _pos(tester).maxScrollExtent;
    i++
  ) {
    await _drag(tester, -400);
    await _settle(tester);
  }
  final end = _pos(tester).maxScrollExtent;
  expect(_pos(tester).pixels, moreOrLessEquals(end, epsilon: 1));
  final viewport = _pos(tester).viewportDimension;
  for (var i = 0; i < 4; i++) {
    final released = await _drag(tester, -150);
    expect(released, greaterThan(end), reason: 'overscroll bo\'ldi');
    await _settle(tester);
    expect(
      _pos(tester).pixels,
      moreOrLessEquals(_pos(tester).maxScrollExtent, epsilon: 1),
      reason: 'bounce oxirgi joyga qaytardi (pastga tushmadi), urinish $i',
    );
    expect(
      _pos(tester).viewportDimension,
      viewport,
      reason: 'bounce sarlavhani almashtirmadi (layout sakramadi)',
    );
  }

  // 3) Oxirida tez (fling) yuqoriga — natija yana oxirgi joy.
  await tester.fling(_list(), const Offset(0, -500), 3000);
  await _settle(tester);
  expect(
    _pos(tester).pixels,
    moreOrLessEquals(_pos(tester).maxScrollExtent, epsilon: 1),
  );

  // 4) Kontent suzuvchi panel ustigacha to'liq ko'rinadi: oxirgi element
  // pastki menyu (Lab tugmasi bilan) ustida.
  final page = tester.widget<LgPage>(find.byType(LgPage).hitTestable().first);
  final last = find.byWidget(page.children.last);
  final navTop = tester.getTopLeft(find.byKey(const ValueKey('nav-pill'))).dy;
  final labTop = tester
      .getTopLeft(find.byKey(const ValueKey('nav-lab-circle')))
      .dy;
  expect(
    tester.getRect(last).bottom,
    lessThanOrEqualTo(labTop < navTop ? labTop : navTop),
    reason: 'oxirgi kontent panel ostida qolmaydi',
  );
}

Future<AppServices> _app(WidgetTester tester, {FakeLabBackend? backend}) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  addTearDown(() => debugDefaultTargetPlatformOverride = null);
  final s = await makeServices(
    tester,
    language: AppLanguage.uz,
    backend: backend,
  );
  await pumpApp(tester, s, size: _iphone);
  return s;
}

void main() {
  setUpAll(loadAppFonts);

  for (final tab in ['/lab', '/home', '/learn']) {
    testWidgets('$tab: scroll qo‘yilgan joyda qoladi (iPhone)', (tester) async {
      await _app(tester);
      await goTo(tester, tab);
      await _checkPage(tester);
      debugDefaultTargetPlatformOverride = null;
    });
  }

  testWidgets('guruh sahifasi (ustoz, QR taklif): scroll qo‘yilgan joyda', (
    tester,
  ) async {
    final b = FakeLabBackend();
    final s = await _app(tester, backend: b);
    await s.auth.requestCode('teacher@example.com');
    await s.auth.verifyCode(FakeLabBackend.otpCode);
    await b.registerTeacher();
    final g = await b.createGroup('Ali');
    final qs = s.content.pack!.quiz.take(3).toList();
    for (var i = 0; i < 4; i++) {
      await b.createAssignment(
        groupId: g.id,
        title: 'Topshiriq ${i + 1}',
        questionIds: [for (final q in qs) q.id],
        correctIndexes: [for (final q in qs) q.correctIndex],
      );
    }
    await goTo(tester, '/learn/classes/g/${g.id}');
    await tester.pumpAndSettle();
    expect(find.text('Ali'), findsWidgets);
    await _checkPage(tester);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('bir tortishda oxirigacha: sarlavha bounce bilan '
      'almashib, kontent tushib ketmaydi', (tester) async {
    await _app(tester);
    await goTo(tester, '/lab');
    // Bitta uzun tortish: sarlavha yo'lda yig'iladi, oxirida overscroll.
    // Avval bounce sarlavhani qayta kengaytirib, viewportni o'zgartirardi.
    final pos = _pos(tester);
    final released = await _drag(tester, -(pos.maxScrollExtent + 60));
    await _settle(tester);
    final settled = _pos(tester).pixels;
    expect(settled, lessThanOrEqualTo(_pos(tester).maxScrollExtent + 0.5));
    expect(settled, greaterThan(0));
    expect(released, greaterThanOrEqualTo(settled));
    // Yana bir marta: holat barqaror.
    final vp = _pos(tester).viewportDimension;
    await _drag(tester, -80);
    await _settle(tester);
    expect(_pos(tester).viewportDimension, vp);
    expect(
      _pos(tester).pixels,
      moreOrLessEquals(_pos(tester).maxScrollExtent, epsilon: 1),
    );
    debugDefaultTargetPlatformOverride = null;
  });
}
