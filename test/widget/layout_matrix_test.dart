import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

/// Har bir ekranni turli o'lcham/til/mavzu/shrift masshtabida ochib,
/// layout xatosi (RenderFlex overflow va h.k.) yo'qligini tekshiradi.
/// Ekran balandligi katta olinadi — ro'yxatning barcha elementlari
/// quriladi va tekshiriladi (dangasa ro'yxat yashirib qo'ymaydi).
const onboardingRoutes = ['/welcome', '/welcome/auth', '/welcome/role'];

const appRoutes = [
  '/home',
  '/tests',
  '/tests/analyte/glucose-plasma-fasting',
  '/tests/analyte/glucose-plasma-fasting/units',
  '/tests/analyte/bilirubin-direct',
  '/tests/analyte/urine-acr',
  '/tests/analyte/urine-chemistry',
  '/tests/analyte/egfr',
  '/tests/analyte/vitamin-b12',
  '/tests/analyte/lactate/units',
  '/tests/analyte/creatinine/quiz',
  '/tests/analyte/hemoglobin',
  '/tests/analyte/platelets',
  '/tests/analyte/coagulation-factors',
  '/tests/analyte/hba1c',
  '/tests/conditions',
  '/tests/conditions/type-2-diabetes',
  '/tests/conditions/venous-thromboembolism',
  '/tests/conditions/hepatitis-b',
  '/tests/conditions/prostate-psa',
  '/home/conditions/hypothyroidism/analyte/tsh',
  '/tests/analyte/tsh',
  '/tests/analyte/fsh',
  '/tests/analyte/anti-tpo',
  // Uzun nomli sifat test: musbat/manfiy natija bo'limlari bilan.
  '/tests/analyte/anti-ccp',
  '/lab',
  '/lab/calibration',
  '/lab/calibration?model=human-humalyzer-4000&analyte=glucose-plasma-fasting',
  '/lab/calibration/log',
  '/lab/qc',
  '/lab/qc/new',
  '/lab/qc/rejected',
  '/lab/qc/eqa',
  '/lab/qc/critical',
  '/lab/preanalytics',
  '/lab/instruments',
  '/lab/instruments/c/chemistry',
  '/lab/instruments/c/hematology/human',
  '/lab/instruments/m/human-humalyzer-4000',
  '/lab/instruments/m/roche-cobas-u-411',
  '/lab/microscopy',
  '/lab/microscopy/s/urine',
  '/lab/microscopy/s/blood',
  '/lab/microscopy/s/parasites',
  '/lab/microscopy/i/b-neut-1',
  '/lab/microscopy/i/b-baso-1',
  '/lab/microscopy/i/u-cryst-cystine-1',
  '/lab/microscopy/i/u-cast-panel-1',
  '/lab/microscopy/quiz',
  '/lab/microscopy/quiz?section=parasites',
  '/lab/microscopy/credits',
  '/lab/partners/partner-test-1',
  '/lab/calculators',
  '/lab/calculators/dilution',
  '/lab/calculators/units',
  '/lab/calculators/egfr',
  '/lab/calculators/acr',
  '/lab/calculators/anion-gap',
  '/lab/calculators/calcium',
  '/lab/calculators/ldl',
  '/lab/calculators/osmolality',
  '/lab/calculators/hba1c',
  '/lab/calculators/chamber',
  '/lab/calculators/differential',
  '/lab/calculators/reticulocytes',
  '/lab/calculators/light',
  '/lab/calculators/colour-index',
  '/library',
  '/library/saved',
  '/library/packs',
  '/library/books',
  '/library/books?search=1',
  '/library/books/item/lib-openstax-biology-2e',
  '/library/books/item/lib-lexuz-kdl-mehnat-muhofazasi-2059',
  '/library/books/item/lib-sammu-kld-lelevich',
  '/library/books/item/lib-openstax-biology-2e/read',
  '/library/intake',
  '/library/sources',
  '/library/research',
  '/library/review',
  '/learn',
  '/learn/quiz',
  '/learn/exam',
  '/learn/exam/run',
  '/learn/exam/result/missing',
  // Toifa bo'limi: uz da ochiladi, ru/en (mintaqa UZ emas) — /learn ga
  // qaytariladi.
  '/learn/toifa',
  '/learn/toifa/test',
  '/learn/toifa/test/result/missing',
  '/learn/toifa/practice',
  '/learn/toifa/practice/hemostasis',
  '/learn/toifa/oral',
  '/learn/toifa/oral/q/kdl-o-001',
  '/learn/toifa/mistakes',
  '/learn/toifa/progress',
  '/learn/classes',
  '/learn/classes/new',
  '/learn/classes/join',
  '/learn/classes/g/x',
  '/learn/classes/g/x/assign',
  '/learn/classes/g/x/a/y',
  '/learn/classes/g/x/a/y/s/z',
  '/learn/lesson',
  '/profile',
  '/profile/role',
  '/profile/purchase',
  '/profile/privacy',
  '/profile/support',
  '/profile/admin',
  '/profile/admin/partners',
  '/profile/admin/partners/new',
  '/profile/admin/partner-requests',
  '/profile/partnership',
  '/profile/auth',
  '/terms',
];

typedef Config = ({
  double width,
  double textScale,
  AppLanguage lang,
  ThemeMode theme,
});

List<Config> configs() {
  final out = <Config>[];
  for (final lang in AppLanguage.values) {
    for (final width in [320.0, 390.0, 430.0, 820.0]) {
      for (final scale in [1.0, 1.35]) {
        out.add((
          width: width,
          textScale: scale,
          lang: lang,
          theme: ThemeMode.light,
        ));
      }
    }
    // Eng og'ir holat: tor ekran + juda katta shrift.
    out.add((width: 320, textScale: 2.0, lang: lang, theme: ThemeMode.light));
    out.add((width: 390, textScale: 1.0, lang: lang, theme: ThemeMode.dark));
  }
  return out;
}

void main() {
  setUpAll(loadAppFonts);

  for (final c in configs()) {
    final name =
        '${c.lang.name} ${c.width.toInt()}px ×${c.textScale} ${c.theme.name}';

    testWidgets('no layout errors: $name', (tester) async {
      Future<void> visitAll(List<String> routes) async {
        for (final route in routes) {
          await goTo(tester, route);
          final error = tester.takeException();
          expect(error, isNull, reason: '$route → $error');
        }
      }

      final size = Size(c.width, 3200);
      // Onboarding ekranlari.
      final fresh = await makeServices(
        tester,
        language: c.lang,
        themeMode: c.theme,
        onboarded: false,
        role: null,
      );
      await pumpApp(tester, fresh, size: size, textScale: c.textScale);
      await visitAll(onboardingRoutes);
      // OTP ekrani (demo kod so'ralgan holat).
      await tester.runAsync(
        () => fresh.auth.requestCode('student@example.com'),
      );
      await visitAll(['/welcome/auth/otp']);
      await tester.pumpWidget(const SizedBox());

      // Asosiy ekranlar — har bir rolning bosh sahifasi bilan.
      final s = await makeServices(
        tester,
        language: c.lang,
        themeMode: c.theme,
      );
      await s.bookmarks.toggle('glucose-plasma-fasting');
      await pumpApp(tester, s, size: size, textScale: c.textScale);
      for (final role in AppRole.values) {
        await s.settings.setRole(role);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'home $role');
      }
      await visitAll(appRoutes);
    });
  }

  // Past ekran: landshaft telefon va kichik telefon + juda katta shrift.
  // Sarlavha joyni egallab, ro'yxat 0 px bo'lib qolmasligi kerak.
  for (final (w, h, scale) in [
    (844.0, 390.0, 1.0),
    (844.0, 390.0, 2.0),
    (320.0, 568.0, 2.0),
  ]) {
    testWidgets('short screen keeps content reachable: '
        '${w.toInt()}×${h.toInt()} ×$scale', (tester) async {
      for (final lang in AppLanguage.values) {
        final s = await makeServices(tester, language: lang);
        await pumpApp(tester, s, size: Size(w, h), textScale: scale);
        for (final route in [
          '/home',
          '/tests',
          '/tests/conditions',
          '/tests/conditions/type-2-diabetes',
          '/tests/analyte/urine-chemistry',
          '/tests/analyte/glucose-plasma-fasting/units',
          '/lab/calculators/units',
          '/lab/qc',
          '/lab/instruments/m/human-humalyzer-4000',
          '/lab/calibration',
          '/profile',
        ]) {
          await goTo(tester, route);
          expect(tester.takeException(), isNull, reason: '$lang $route');
          final list = find.byType(ListView).last;
          expect(
            tester.getSize(list).height,
            greaterThanOrEqualTo(h * 0.3),
            reason: '$lang $route: list area',
          );
        }
        await tester.pumpWidget(const SizedBox());
      }
    });
  }

  testWidgets('tab labels fit on one line at 320 px in every language', (
    tester,
  ) async {
    for (final lang in AppLanguage.values) {
      for (final scale in [1.0, 1.15, 2.0]) {
        final s = await makeServices(tester, language: lang);
        await pumpApp(tester, s, size: const Size(320, 640), textScale: scale);
        // Tab nomlari bir qatorda va qirqilmagan (fade qo'llanmagan).
        // Faqat tab nomlari bir qatorli va softWrap: false.
        final labels = find.byWidgetPredicate(
          (w) => w is Text && w.maxLines == 1 && w.softWrap == false,
        );
        expect(labels, findsNWidgets(5), reason: '$lang ×$scale');
        for (final e in labels.evaluate()) {
          final paragraph = e.renderObject! as RenderParagraph;
          final needed = paragraph.getMaxIntrinsicWidth(double.infinity);
          expect(
            needed,
            lessThanOrEqualTo(paragraph.size.width + 0.5),
            reason: '${(e.widget as Text).data} $lang ×$scale',
          );
          final style = (e.widget as Text).style!;
          expect(style.fontSize, greaterThanOrEqualTo(11));
        }
        await tester.pumpWidget(const SizedBox());
      }
    }
  });
}
