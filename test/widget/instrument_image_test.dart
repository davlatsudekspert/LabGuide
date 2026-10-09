import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/design/theme.dart';
import 'package:labguide/features/instruments/instrument_catalog.dart';
import 'package:labguide/features/instruments/instrument_image.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

/// Model kartasidagi rasm bloki (D-36a): aynan shu model fotosi yoki neytral
/// belgi; buzilgan asset sahifani buzmaydi; to'liq ekran kattalashtirish.

// Testda “foto” sifatida istalgan mavjud asset (ilova katalogida emas).
const _existing = 'assets/instruments/img/chemistry.png';

InstrumentModel _model({Map<String, Object?>? image}) =>
    InstrumentModel.fromJson({
      'id': 'roche-cobas-u-411',
      'maker': 'roche',
      'model': 'cobas u 411',
      'category': 'urinalysis',
      'kind': {'uz': 'a', 'ru': 'b', 'en': 'c'},
      'facts': <Object>[],
      'manual': {
        'access': 'not_public',
        'note': {'uz': 'a', 'ru': 'b', 'en': 'c'},
      },
      'reagent_system': {'kind': 'unknown', 'quote': null},
      'image': image,
      'status': 'device_info',
    });

Map<String, Object?> _image(String asset) => {
  'asset': asset,
  'asset_large': asset,
  'manufacturer': 'Roche Diagnostics',
  'model': 'cobas u 411',
  'source_url': 'https://commons.wikimedia.org/wiki/File:Example.jpg',
  'license': 'CC BY-SA 4.0',
  'license_url': 'https://creativecommons.org/licenses/by-sa/4.0/',
  'rights': 'CC BY-SA 4.0 — https://creativecommons.org/licenses/by-sa/4.0/',
  'checked_at': '2026-10-09',
  'author': 'Test Author',
  'caption': {'uz': 'Izoh', 'ru': 'Подпись', 'en': 'Caption'},
};

const _page = CatalogSource(
  id: 'ro-u411',
  title: 'Roche — cobas u 411 urine analyzer',
  url: 'https://diagnostics.roche.com/se/en/products/instruments/cobas-u-411-ins-2009.html',
  accessed: '2026-10-09',
);

Future<void> _pump(
  WidgetTester tester,
  InstrumentModel model, {
  String lang = 'uz',
  Brightness brightness = Brightness.light,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLgTheme(brightness),
      locale: Locale(lang),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [InstrumentImageBlock(model: model, officialPage: _page)],
        ),
      ),
    ),
  );
  // Asset'ni haqiqiy async'da yuklash (muvaffaqiyat yoki xato).
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'rasm bor model: contain, muallif, huquq, manba, kattalashtirish',
    (tester) async {
      final l = lookupAppLocalizations(const Locale('uz'));
      await _pump(tester, _model(image: _image(_existing)));
      final img = tester.widget<Image>(find.byType(Image).first);
      expect(img.fit, BoxFit.contain);
      expect(img.image, const AssetImage(_existing));
      expect(find.text('Izoh'), findsOneWidget);
      expect(
        find.text(l.instImageCredit('Test Author', 'CC BY-SA 4.0')),
        findsOneWidget,
      );
      expect(find.text(l.instImageRightsChecked('2026-10-09')), findsOneWidget);
      expect(find.text(l.instMakerSource), findsOneWidget);
      expect(find.text(l.instImageMissing), findsNothing);

      // Bosilganda — to'liq ekran, InteractiveViewer, katta nusxa.
      await tester.tap(find.byKey(const ValueKey('instrument-photo')));
      await tester.pumpAndSettle();
      expect(find.byType(InstrumentImageViewer), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(InteractiveViewer),
          matching: find.byType(Image),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Test Author'), findsWidgets);
      await tester.tap(find.byTooltip(l.micClose));
      await tester.pumpAndSettle();
      expect(find.byType(InstrumentImageViewer), findsNothing);
    },
  );

  for (final (lang, text) in [
    ('uz', 'Model rasmi hozircha mavjud emas'),
    ('ru', 'Изображение модели пока недоступно'),
    ('en', 'Model image not available yet'),
  ]) {
    testWidgets('rasm yo‘q model: neytral belgi va matn ($lang)', (
      tester,
    ) async {
      await _pump(tester, _model(), lang: lang);
      expect(find.text(text), findsOneWidget);
      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      // Hech qanday rasm (chizma ham) ko'rsatilmaydi.
      expect(find.byType(Image), findsNothing);
      expect(
        find.text(lookupAppLocalizations(Locale(lang)).instMakerSource),
        findsOneWidget,
      );
    });
  }

  testWidgets('buzilgan asset: errorBuilder, sahifa buzilmaydi', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    await _pump(
      tester,
      _model(image: _image('assets/instruments/img/models/missing.jpg')),
    );
    expect(tester.takeException(), isNull);
    expect(find.text(l.instImageMissing), findsOneWidget);
    // Muallif va manba havolalari joyida.
    expect(find.text(l.instMakerSource), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('320 px, shrift 2.0, ${brightness.name}: overflow yo‘q', (
      tester,
    ) async {
      for (final image in [null, _image(_existing)]) {
        await _pump(
          tester,
          _model(image: image),
          brightness: brightness,
          size: const Size(320, 640),
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
      }
    });
  }
}
