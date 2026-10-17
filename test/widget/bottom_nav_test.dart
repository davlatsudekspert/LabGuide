import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/design/tokens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations_en.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

final en = AppLocalizationsEn();

const _pill = ValueKey('nav-pill');
const _labCircle = ValueKey('nav-lab-circle');

/// Pastki menyu: yarim shaffof (frosted glass), scroll bilan ixchamlashadi,
/// o'rtadagi Lab tugmasi ko'tarilgan, kontent menyu ostida qolmaydi.
void main() {
  setUpAll(loadAppFonts);

  Finder tab(int i) => find.byKey(ValueKey('nav-tab-$i'));
  double pillHeight(WidgetTester t) => t.getSize(find.byKey(_pill)).height;
  Rect pillRect(WidgetTester t) => t.getRect(find.byKey(_pill));
  Rect labRect(WidgetTester t) => t.getRect(find.byKey(_labCircle));

  Finder navIcon(int i, IconData icon) => find.descendant(
    // Lab: ikonka doira ichida (tab kaliti uning ustidagi teginish qatlamida).
    of: i == 2 ? find.byKey(_labCircle) : tab(i),
    matching: find.byIcon(icon),
  );

  /// Nom ixcham holatda yashirin: shaffof va qirqib tashlangan.
  bool labelHidden(WidgetTester t, String label) {
    final text = find.text(label);
    final opacity = t.widget<Opacity>(
      find.ancestor(of: text, matching: find.byType(Opacity)).first,
    );
    final clip = t.getSize(
      find.ancestor(of: text, matching: find.byType(ClipRect)).first,
    );
    return opacity.opacity == 0 && clip.height == 0;
  }

  Finder pageScrollable() => find
      .descendant(
        of: find.byType(LgPage).last,
        matching: find.byType(Scrollable),
      )
      .first;

  Future<void> scrollBy(WidgetTester t, double dy, {bool settle = true}) async {
    await t.drag(pageScrollable(), Offset(0, dy));
    if (settle) await t.pumpAndSettle();
  }

  Future<void> boot(
    WidgetTester t, {
    Size size = const Size(390, 844),
    double textScale = 1,
    bool reduceMotion = false,
    ThemeMode theme = ThemeMode.light,
    String route = '/home',
  }) async {
    final s = await makeServices(t, language: AppLanguage.en, themeMode: theme);
    await pumpApp(
      t,
      s,
      size: size,
      textScale: textScale,
      reduceMotion: reduceMotion,
    );
    if (route != '/home') await goTo(t, route);
  }

  // ---------------------------------------------------------------- shisha
  double luminance(Color c) => c.computeLuminance();
  double contrast(Color a, Color b) {
    final la = luminance(a), lb = luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// Shisha sirti [backdrop] ustida qanday ko'rinadi (alfa-aralashtirish).
  Color over(Color surface, Color backdrop) =>
      Color.alphaBlend(surface, backdrop);

  for (final (name, p, brightness) in [
    ('light', LgPalette.light, Brightness.light),
    ('dark', LgPalette.dark, Brightness.dark),
  ]) {
    test(
      'glass keeps ≥ 4.5:1 text/icon contrast over any backdrop ($name)',
      () {
        final surface = LgGlass.surface(p, brightness);
        expect(surface.a, lessThan(1), reason: 'translucent');
        // Eng yomon fonlar: sof qora va sof oq kontent (xiralashtirishdan keyin
        // ham o'rtacha rang shu oraliqda).
        for (final backdrop in [Colors.black, Colors.white]) {
          final glass = over(surface, backdrop);
          for (final (label, fg) in [
            ('unselected (ink)', p.ink),
            ('selected (brand)', p.brand),
          ]) {
            expect(
              contrast(fg, glass),
              greaterThanOrEqualTo(4.5),
              reason: '$name $label over $backdrop',
            );
          }
        }
        // Tanlangan tabdagi yumshoq fon ustida ham.
        expect(contrast(p.brand, p.soft), greaterThanOrEqualTo(4.5));
        // Lab: brend doira ustida ikonka.
        expect(contrast(p.onBrand, p.brand), greaterThanOrEqualTo(4.5));
      },
    );
  }

  testWidgets('frosted glass: blur, translucent fill, thin border', (
    tester,
  ) async {
    await boot(tester);
    final blur = tester.widget<BackdropFilter>(
      find.descendant(
        of: find.byKey(_pill),
        matching: find.byType(BackdropFilter),
      ),
    );
    expect(blur.enabled, isTrue);
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byKey(_pill),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final deco = box.decoration as BoxDecoration;
    expect(deco.color!.a, lessThan(1));
    expect(deco.border, isNotNull);
  });

  testWidgets('content scrolls underneath the bar (body extends behind it)', (
    tester,
  ) async {
    await boot(tester);
    // Ro'yxat ko'rinish oynasi ekranning pastigacha cho'zilgan.
    final list = tester.getRect(find.byType(ListView).last);
    expect(list.bottom, closeTo(844, 0.5));
    expect(pillRect(tester).bottom, lessThan(844));
  });

  testWidgets('high contrast / no transparency: solid surface, no blur', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(highContrast: true);
    await pumpApp(tester, s);
    final blur = tester.widget<BackdropFilter>(
      find.descendant(
        of: find.byKey(_pill),
        matching: find.byType(BackdropFilter),
      ),
    );
    expect(blur.enabled, isFalse);
    final deco =
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byKey(_pill),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;
    expect(deco.color!.a, 1);
  });

  // --------------------------------------------------------------- ixchamlik
  testWidgets('expanded at the top; compact on scroll down; expands on up', (
    tester,
  ) async {
    await boot(tester);
    final expanded = pillHeight(tester);
    expect(expanded, greaterThanOrEqualTo(60));
    expect(find.text(en.navHome), findsOneWidget);
    expect(labelHidden(tester, en.navHome), isFalse);

    await scrollBy(tester, -500);
    final compact = pillHeight(tester);
    expect(compact, lessThan(expanded));
    expect(compact, greaterThanOrEqualTo(44));
    // Nomlar yashirin (balandligi 0), ikonkalar qoladi.
    expect(labelHidden(tester, en.navTests), isTrue);
    expect(navIcon(1, Icons.biotech_outlined), findsOneWidget);

    await scrollBy(tester, 120);
    expect(pillHeight(tester), expanded, reason: 'scroll up expands');
    expect(labelHidden(tester, en.navTests), isFalse);

    // Eng tepaga qaytganda ham kengaygan.
    await scrollBy(tester, -500);
    expect(pillHeight(tester), compact);
    await scrollBy(tester, 3000);
    expect(pillHeight(tester), expanded, reason: 'at the top');
  });

  testWidgets('hysteresis: small moves and wobble do not flip the bar', (
    tester,
  ) async {
    await boot(tester);
    final expanded = pillHeight(tester);
    // Birinchi navbatda ro'yxatni biroz pastga (tepadan chiqish).
    await scrollBy(tester, -30);
    expect(pillHeight(tester), expanded, reason: '< threshold');
    // Barmoq bilan 7 px pastga/7 px yuqoriga tebranish — holat o'zgarmaydi.
    for (var i = 0; i < 4; i++) {
      await scrollBy(tester, -7);
      await scrollBy(tester, 7);
    }
    expect(pillHeight(tester), expanded);
    // Aniq pastga surish — ixcham.
    await scrollBy(tester, -200);
    final compact = pillHeight(tester);
    expect(compact, lessThan(expanded));
    // Ixcham holatda mayda teskari harakat qaytarmaydi.
    await scrollBy(tester, 8);
    expect(pillHeight(tester), compact);
    await scrollBy(tester, -8);
    expect(pillHeight(tester), compact);
  });

  testWidgets('animated by default, instant under reduced motion', (
    tester,
  ) async {
    await boot(tester);
    final expanded = pillHeight(tester);
    await tester.drag(pageScrollable(), const Offset(0, -500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final mid = pillHeight(tester);
    expect(mid, lessThan(expanded));
    expect(mid, greaterThan(48), reason: 'still animating');
    await tester.pumpAndSettle();
    expect(pillHeight(tester), 48);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reduced motion: state is correct without any animation', (
    tester,
  ) async {
    await boot(tester, reduceMotion: true);
    final expanded = pillHeight(tester);
    await tester.drag(pageScrollable(), const Offset(0, -500));
    // Bir kadr — animatsiyasiz darhol ixcham.
    await tester.pump();
    expect(pillHeight(tester), 48);
    expect(labelHidden(tester, en.navHome), isTrue);
    await tester.drag(pageScrollable(), const Offset(0, 120));
    await tester.pump();
    expect(pillHeight(tester), expanded);
  });

  testWidgets('switching tab or re-tapping the active tab expands the bar', (
    tester,
  ) async {
    await boot(tester, route: '/tests');
    final expanded = pillHeight(tester);
    await scrollBy(tester, -500);
    expect(pillHeight(tester), lessThan(expanded));
    // Faol tabni qayta bosish: tepaga qaytadi va panel kengayadi.
    await tester.tap(tab(1));
    await tester.pumpAndSettle();
    expect(pillHeight(tester), expanded);

    await scrollBy(tester, -500);
    expect(pillHeight(tester), lessThan(expanded));
    await tester.tap(tab(3));
    await tester.pumpAndSettle();
    expect(pillHeight(tester), expanded, reason: 'new tab starts expanded');
  });

  // ------------------------------------------------------------------ Lab
  testWidgets('Lab is a raised round brand button and a normal tab', (
    tester,
  ) async {
    await boot(tester);
    final circle = labRect(tester);
    final pill = pillRect(tester);
    expect(circle.width, inInclusiveRange(56, 60));
    expect(circle.height, circle.width);
    final protrusion = pill.top - circle.top;
    expect(protrusion, inInclusiveRange(12, 16));
    expect(circle.center.dx, closeTo(pill.center.dx, 0.5));
    final decoration =
        tester
                .widget<AnimatedContainer>(
                  find.descendant(
                    of: find.byKey(_labCircle),
                    matching: find.byType(AnimatedContainer),
                  ),
                )
                .decoration!
            as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.color, LgPalette.light.brand);
    // Nomi doira ostida, panel ichida.
    final label = tester.getRect(find.text(en.navLab));
    expect(label.top, greaterThanOrEqualTo(circle.bottom - 1));
    expect(label.bottom, lessThanOrEqualTo(pill.bottom + 0.5));
    expect(navIcon(2, Icons.science_outlined), findsOneWidget);

    // Doiraning yuqori qismini (panel ustidagi chiqib turgan joy) bosish ham
    // Lab'ni ochadi.
    await tester.tapAt(Offset(circle.center.dx, circle.top + 4));
    await tester.pumpAndSettle();
    expect(routerOf(tester).state.matchedLocation, '/lab');
    expect(navIcon(2, Icons.science_rounded), findsOneWidget);
    expect(navIcon(2, Icons.science_outlined), findsNothing);
    // Nomi orqali ham bosiladi (kengaygan holatda).
    await tester.tap(tab(0));
    await tester.pumpAndSettle();
    // (Teginish qatlami matn ustida turadi — shuning uchun warnIfMissed.)
    await tester.tap(find.text(en.navLab), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(routerOf(tester).state.matchedLocation, '/lab');
  });

  testWidgets('Lab stays visible, slightly raised and tappable when compact', (
    tester,
  ) async {
    await boot(tester);
    await scrollBy(tester, -500);
    final circle = labRect(tester);
    final pill = pillRect(tester);
    expect(pill.height, 48);
    expect(pill.top - circle.top, inInclusiveRange(6, 10));
    expect(circle.width, greaterThanOrEqualTo(48));
    expect(circle.bottom, lessThanOrEqualTo(pill.bottom));
    await tester.tapAt(Offset(circle.center.dx, circle.top + 3));
    await tester.pumpAndSettle();
    expect(routerOf(tester).state.matchedLocation, '/lab');
  });

  testWidgets('selected state is obvious in expanded and compact modes', (
    tester,
  ) async {
    await boot(tester, route: '/tests');
    for (final compact in [false, true]) {
      if (compact) await scrollBy(tester, -500);
      // Tanlangan: to'ldirilgan ikonka; qolganlar — kontur.
      expect(navIcon(1, Icons.biotech_rounded), findsOneWidget);
      expect(navIcon(1, Icons.biotech_outlined), findsNothing);
      expect(navIcon(0, Icons.home_outlined), findsOneWidget);
      // Rang + yumshoq fon.
      final icon = tester.widget<Icon>(navIcon(1, Icons.biotech_rounded));
      expect(icon.color, LgPalette.light.brand);
      final other = tester.widget<Icon>(navIcon(0, Icons.home_outlined));
      expect(other.color, LgPalette.light.ink);
      final soft = find.descendant(
        of: tab(1),
        matching: find.byWidgetPredicate(
          (w) =>
              w is AnimatedContainer &&
              (w.decoration as BoxDecoration?)?.color == LgPalette.light.soft,
        ),
      );
      expect(soft, findsOneWidget, reason: 'compact=$compact');
    }
  });

  // -------------------------------------------------------------- a11y
  testWidgets('tap targets ≥ 44 px and semantics labels in both states', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await boot(tester);
    for (final compact in [false, true]) {
      if (compact) await scrollBy(tester, -500);
      for (var i = 0; i < 5; i++) {
        final size = tester.getSize(tab(i));
        expect(size.width, greaterThanOrEqualTo(44), reason: 'tab $i w');
        expect(size.height, greaterThanOrEqualTo(44), reason: 'tab $i h');
      }
      for (final label in [
        en.navHome,
        en.navTests,
        en.navLab,
        en.navLibrary,
        en.navLearn,
      ]) {
        expect(
          find.semantics.byLabel(label),
          findsOne,
          reason: '$label compact=$compact',
        );
      }
      expect(
        tester.getSemantics(find.bySemanticsLabel(en.navLab).first),
        isSemantics(label: en.navLab, isButton: true, hasTapAction: true),
      );
    }
    // Ixcham holatda ham TalkBack orqali tab almashadi.
    tester.semantics.tap(find.semantics.byLabel(en.navLibrary));
    await tester.pumpAndSettle();
    expect(routerOf(tester).state.matchedLocation, '/library');
    expect(tester.getSemantics(tab(3)), isSemantics(isSelected: true));
    handle.dispose();
  });

  testWidgets(
    'transparent area above the compact pill passes touches through',
    (tester) async {
      await boot(tester);
      await scrollBy(tester, -500);
      final pill = pillRect(tester);
      // Panel ustidagi ajratilgan (shaffof) joy — kontent bosiladi.
      final hit = tester.hitTestOnBinding(Offset(30, pill.top - 20));
      final names = hit.path.map((e) => e.target.runtimeType.toString());
      expect(names.any((n) => n.contains('InkResponse')), isFalse);
      expect(hit.path.any((e) => e.target is RenderBackdropFilter), isFalse);
    },
  );

  testWidgets('keyboard open: bar leaves the way', (tester) async {
    await boot(tester, route: '/tests');
    expect(find.byKey(_pill), findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 3);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(find.byKey(_pill), findsNothing);
    final list = tester.getRect(find.byType(ListView).last);
    expect(list.bottom, lessThanOrEqualTo(844 - 300 + 0.5));
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(find.byKey(_pill), findsOneWidget);
  });

  // ------------------------------------------------- kontent yopilmaydi
  for (final (route, size, scale) in [
    ('/home', const Size(390, 844), 1.0),
    ('/lab', const Size(390, 844), 1.0),
    ('/library', const Size(390, 844), 1.0),
    ('/tests', const Size(390, 844), 1.0),
    ('/learn', const Size(390, 844), 1.0),
    ('/home', const Size(320, 640), 2.0),
    ('/library', const Size(320, 640), 2.0),
    ('/lab', const Size(844, 390), 1.0),
  ]) {
    testWidgets('last card is not covered: $route ${size.width.toInt()}x'
        '${size.height.toInt()} ×$scale', (tester) async {
      await boot(tester, size: size, textScale: scale, route: route);
      final scrollable = pageScrollable();
      final position = tester.state<ScrollableState>(scrollable).position;
      // Ro'yxat dangasa: maxScrollExtent taxminiy — barqarorlashguncha.
      for (var i = 0; i < 8; i++) {
        position.jumpTo(position.maxScrollExtent);
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      final sliver = tester.renderObject<RenderSliverMultiBoxAdaptor>(
        find
            .descendant(of: scrollable, matching: find.byType(SliverList))
            .first,
      );
      final last = sliver.lastChild!;
      final rect = MatrixUtils.transformRect(
        last.getTransformTo(null),
        Offset.zero & last.size,
      );
      // Eng yuqori nuqta: panel yoki ko'tarilgan Lab tugmasi.
      final barTop = math.min(pillRect(tester).top, labRect(tester).top);
      expect(
        rect.bottom,
        lessThanOrEqualTo(barTop + 0.5),
        reason: 'last item bottom ${rect.bottom} vs bar top $barTop',
      );
      // Ixcham holatda ham (panel pastroq, joy yetarli).
      await scrollBy(tester, -20);
      await scrollBy(tester, 20);
      expect(tester.takeException(), isNull);
    });
  }

  // --------------------------------------------- tor ekran va katta shrift
  for (final (width, scale, theme) in [
    (320.0, 1.0, ThemeMode.light),
    (320.0, 1.3, ThemeMode.light),
    (320.0, 2.0, ThemeMode.light),
    (390.0, 2.0, ThemeMode.dark),
    (820.0, 1.0, ThemeMode.light),
  ]) {
    testWidgets(
      'bar fits without overflow: ${width.toInt()} px ×$scale ${theme.name}',
      (tester) async {
        await boot(
          tester,
          size: Size(width, 700),
          textScale: scale,
          theme: theme,
        );
        for (final compact in [false, true]) {
          if (compact) await scrollBy(tester, -500);
          expect(tester.takeException(), isNull);
          final pill = pillRect(tester);
          expect(pill.left, greaterThanOrEqualTo(0));
          expect(pill.right, lessThanOrEqualTo(width));
          for (var i = 0; i < 5; i++) {
            final r = tester.getRect(tab(i));
            expect(r.width, greaterThanOrEqualTo(44), reason: 'tab $i');
            expect(r.height, greaterThanOrEqualTo(44), reason: 'tab $i');
            expect(r.left, greaterThanOrEqualTo(pill.left - 0.5));
            expect(r.right, lessThanOrEqualTo(pill.right + 0.5));
          }
          // Lab doim markazda.
          expect(labRect(tester).center.dx, closeTo(pill.center.dx, 0.5));
        }
        // Menyu matni ≤ 1.2 masshtabda (boshqa chrome kabi).
        final ctx = tester.element(tab(1));
        expect(
          MediaQuery.textScalerOf(ctx).scale(100),
          lessThanOrEqualTo(120.0001),
        );
        // Nomlar 11 px dan kichik emas.
        await scrollBy(tester, 500);
        final labels = find.byWidgetPredicate(
          (w) => w is Text && w.maxLines == 1 && w.softWrap == false,
        );
        expect(labels, findsNWidgets(5));
        for (final e in labels.evaluate()) {
          expect((e.widget as Text).style!.fontSize, greaterThanOrEqualTo(11));
        }
      },
    );
  }

  testWidgets('landscape phone: compact bar, list stays usable', (
    tester,
  ) async {
    await boot(tester, size: const Size(844, 390), route: '/tests');
    expect(pillHeight(tester), 48, reason: 'short screens are always compact');
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(ListView).last).height,
      greaterThan(390 * 0.3),
    );
  });
}
