// Dizayn yangilanishi (docs/DESIGN_REVIEW_2026-10-17.md): welcome
// afzalliklari, bosh sahifa kartalaridagi ma'noli izohlar, holat
// illyustratsiyasi va skeleton, suzuvchi panel ustidagi bo'sh joy.
// Tor ekran (320 px) va katta shrift (1.3x) — uz/ru/en, overflow yo'q.
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/design/theme.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/home/home_screen.dart';
import 'package:labguide/features/toifa/toifa_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

const _narrow = Size(320, 640);

AppLocalizations _l(AppLanguage lang) =>
    lookupAppLocalizations(Locale(lang.name));

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('welcome: 3 afzallik, 320 px · 1.3x (${lang.name})', (
      tester,
    ) async {
      final s = await makeServices(
        tester,
        onboarded: false,
        role: null,
        language: lang,
      );
      await pumpApp(tester, s, size: _narrow, textScale: 1.3);
      final l = _l(lang);
      for (final t in [
        l.welcomeBenefitDoctorTitle,
        l.welcomeBenefitLabTitle,
        l.welcomeBenefitLearnTitle,
      ]) {
        await tester.scrollUntilVisible(find.text(t), 80);
        expect(find.text(t), findsOneWidget);
      }
      await tester.scrollUntilVisible(find.text(l.welcomeGetStarted), 80);
      expect(find.text(l.welcomeGetStarted), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('bosh sahifa: har kartada ma’noli izoh (${lang.name})', (
      tester,
    ) async {
      final l = _l(lang);
      for (final role in AppRole.values) {
        final s = await makeServices(tester, role: role, language: lang);
        await pumpApp(tester, s, size: _narrow, textScale: 1.3);
        final tiles = tester
            .widgetList<LgTile>(find.byType(LgTile, skipOffstage: false))
            .toList();
        final actions = RoleHome.of(role, l).actions;
        expect(tiles, hasLength(actions.length), reason: role.name);
        for (final t in tiles) {
          expect(
            t.caption,
            isNot(l.actionOpen),
            reason: '${role.name} ${t.title}',
          );
          expect(t.caption.trim(), isNotEmpty);
        }
        // Izohlar bir-biridan farq qiladi (hammasi bir xil "Ochish" emas).
        expect(tiles.map((t) => t.caption).toSet(), hasLength(tiles.length));
        expect(tester.takeException(), isNull, reason: role.name);
        // Keyingi rol uchun toza daraxt.
        await tester.pumpWidget(const SizedBox());
      }
    });
  }

  testWidgets('tor katakda uzun sarlavha harfma-harf bo‘linmaydi', (
    tester,
  ) async {
    final s = await makeServices(tester, role: AppRole.doctor);
    await pumpApp(tester, s, size: _narrow);
    final l = _l(AppLanguage.uz);
    final title = find.descendant(
      of: find.byType(LgTile),
      matching: find.text(l.featureCalculators),
    );
    expect(title, findsOneWidget);
    // Bir qatorga sig'adi: balandligi bitta qator balandligidan oshmaydi.
    final para = tester.renderObject<RenderParagraph>(title);
    final lineHeight = para.text.style!.fontSize! * 1.6;
    expect(para.size.height, lessThan(lineHeight));
  });

  testWidgets('holat bloki: bo‘sh — illyustratsiya; yuklanish — skeleton', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLgTheme(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                LgStateView(kind: StateKind.empty, title: 'Bo‘sh'),
                LgStateView(kind: StateKind.loading, title: ''),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LgStateArt), findsOneWidget);
    expect(find.byType(LgSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      find.bySemanticsLabel(_l(AppLanguage.en).stateLoading),
      findsOneWidget,
    );
  });

  for (final role in [AppRole.teacher, AppRole.lab]) {
    testWidgets('ro‘yxat oxiri suzuvchi panel ustida (${role.name})', (
      tester,
    ) async {
      final s = await makeServices(tester, role: role);
      await pumpApp(tester, s);
      for (final tab in ['/home', '/tests', '/lab', '/library', '/learn']) {
        await goTo(tester, tab);
        final page = find.byType(LgPage).hitTestable().first;
        final list = find
            .descendant(of: page, matching: find.byType(ListView))
            .first;
        final scrollable = tester.state<ScrollableState>(
          find.descendant(of: list, matching: find.byType(Scrollable)).first,
        );
        final pos = scrollable.position;
        pos.jumpTo(pos.maxScrollExtent);
        await tester.pumpAndSettle();
        // Panel egallagan joy (Lab tugmasi bilan) — sahifa MediaQuery'sidagi
        // pastki padding.
        final inset = MediaQuery.paddingOf(tester.element(page)).bottom;
        final viewport = tester.getRect(list);
        final navTop = viewport.bottom - inset;
        // Ro'yxatning oxirgi bolasi.
        final sliver = tester.renderObject<RenderSliverList>(
          find.descendant(of: list, matching: find.byType(SliverList)).first,
        );
        final last = sliver.lastChild!;
        final lastBottom = last.localToGlobal(Offset(0, last.size.height)).dy;
        expect(
          lastBottom,
          lessThanOrEqualTo(navTop - 16),
          reason: '$tab: oxirgi element panel ostida qolmasin',
        );
      }
    });
  }

  // Taklif 6: Toifa kartasi Kunlik savol kartasi uslubida — qattiq chegara
  // yo'q, yumshoq soya (LgShadow); tunda soya o'rniga juda xira chet.
  for (final dark in [false, true]) {
    testWidgets(
      'toifa kirish kartasi: chegarasiz, soya (${dark ? 'tun' : 'kun'})',
      (tester) async {
        final s = await makeServices(
          tester,
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        );
        tester.platformDispatcher.localesTestValue = [const Locale('uz')];
        await pumpApp(tester, s, size: const Size(390, 2400));
        final box = find
            .descendant(
              of: find.byType(ToifaEntryCard),
              matching: find.byType(DecoratedBox),
            )
            .first;
        final d = tester.widget<DecoratedBox>(box).decoration as BoxDecoration;
        if (dark) {
          expect(d.boxShadow ?? const [], isEmpty);
          expect(d.border, isNotNull);
        } else {
          expect(d.border, isNull);
          expect(d.boxShadow, isNotEmpty);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  // Taklif 7: sarlavhali yuklanish (sinflar) — spinner o'rniga kontur, sarlavha
  // kichik izoh va screen reader yorlig'i sifatida.
  testWidgets('sarlavhali yuklanish — skeleton (izoh bilan)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLgTheme(Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: LgSkeleton(caption: _l(AppLanguage.en).classesLoading),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(_l(AppLanguage.en).classesLoading), findsOneWidget);
    expect(
      find.bySemanticsLabel(_l(AppLanguage.en).classesLoading),
      findsOneWidget,
    );
  });
}
