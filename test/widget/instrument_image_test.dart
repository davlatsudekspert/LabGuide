import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/design/theme.dart';
import 'package:labguide/features/instruments/instrument_catalog.dart';
import 'package:labguide/features/instruments/instrument_image.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

/// Model kartasidagi rasm bloki (D-36a): aynan shu model fotosi; foto yo'q
/// bo'lsa — apparat turining sxematik chizmasi va “aniq model emas” izohi
/// (uz/ru/en); buzilgan asset sahifani buzmaydi; to'liq ekran kattalashtirish.

// Testda “foto” sifatida istalgan mavjud asset (ilova katalogida emas).
const _existing = 'assets/instruments/img/chemistry.png';

InstrumentModel _model({
  Map<String, Object?>? image,
  String category = 'urinalysis',
  String? schematic,
}) => InstrumentModel.fromJson({
  'id': 'roche-cobas-u-411',
  'maker': 'roche',
  'model': 'cobas u 411',
  'category': category,
  'schematic': ?schematic,
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
      // Foto bor: sxematik chizma va uning izohi ko'rsatilmaydi.
      expect(find.byKey(const ValueKey('instrument-schematic')), findsNothing);
      expect(find.text(l.instSchematicCaption), findsNothing);

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

  for (final (lang, caption) in [
    ('uz', 'Sxematik tasvir — aniq model emas'),
    ('ru', 'Схематичное изображение — не фото конкретной модели'),
    ('en', 'Schematic illustration — not a photo of this exact model'),
  ]) {
    testWidgets('rasm yo‘q model: sxematik chizma va izoh ($lang)', (
      tester,
    ) async {
      final l = lookupAppLocalizations(Locale(lang));
      await _pump(tester, _model(), lang: lang);
      // Izoh ko'rinib turadi va talab qilingan matnga aynan teng.
      expect(l.instSchematicCaption, caption);
      expect(find.text(caption), findsOneWidget);
      // Urinalysis'ning standart chizmasi (karta kichik nusxasi).
      final img = tester.widget<Image>(find.byType(Image));
      expect(
        img.image,
        const AssetImage('assets/instruments/schematic/urine_strip_480.png'),
      );
      expect(img.fit, BoxFit.contain);
      expect(
        find.byKey(const ValueKey('instrument-schematic')),
        findsOneWidget,
      );
      // Eski neytral belgi, foto muallifi/litsenziyasi va “Huquq tekshirilgan”
      // yo'q — bu foto emas.
      expect(find.byIcon(Icons.image_not_supported_outlined), findsNothing);
      expect(find.text(l.instImageMissing), findsNothing);
      expect(find.textContaining('Test Author'), findsNothing);
      expect(find.textContaining('CC BY'), findsNothing);
      expect(find.byKey(const ValueKey('instrument-photo')), findsNothing);
      // Rasmiy sahifa havolasi va unga yo'naltiruvchi izoh joyida.
      expect(find.text(l.instImageMissingSub), findsOneWidget);
      expect(find.text(l.instMakerSource), findsOneWidget);
    });
  }

  testWidgets('sxematik chizma: bosilsa katta nusxa va izoh', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    await _pump(
      tester,
      _model(category: 'hematology', schematic: 'hematology3'),
    );
    expect(
      tester.widget<Image>(find.byType(Image)).image,
      const AssetImage('assets/instruments/schematic/hematology3_480.png'),
    );
    await tester.tap(find.byKey(const ValueKey('instrument-schematic')));
    await tester.pumpAndSettle();
    expect(find.byType(InstrumentSchematicViewer), findsOneWidget);
    expect(find.byType(InstrumentImageViewer), findsNothing);
    final big = tester.widget<Image>(
      find.descendant(
        of: find.byType(InteractiveViewer),
        matching: find.byType(Image),
      ),
    );
    expect(
      big.image,
      const AssetImage('assets/instruments/schematic/hematology3_1200.png'),
    );
    expect(find.text(l.instSchematicCaption), findsOneWidget);
    await tester.tap(find.byTooltip(l.micClose));
    await tester.pumpAndSettle();
    expect(find.byType(InstrumentSchematicViewer), findsNothing);
  });

  testWidgets('foto bor bo‘lsa sxematik chizma o‘rnini foto egallaydi', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final withPhoto = _model(
      image: _image(_existing),
      schematic: 'urine_strip',
    );
    expect(withPhoto.image, isNotNull);
    await _pump(tester, withPhoto);
    expect(
      tester.widget<Image>(find.byType(Image)).image,
      const AssetImage(_existing),
    );
    expect(find.text(l.instSchematicCaption), findsNothing);
  });

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

  group('sxematik chizmalar katalogi', () {
    Map<String, Object?> raw() => (jsonDecode(
      File('assets/instruments/catalog.json').readAsStringSync(),
    ) as Map).cast<String, Object?>();

    test('har yo‘nalish va har tur uchun 480 va 1200 px fayl mavjud', () async {
      final categories = <InstrumentCategory>{};
      for (final sch in InstrumentSchematic.values) {
        categories.add(sch.category);
        for (final (asset, width) in [
          (sch.asset, 480),
          (sch.assetLarge, 1200),
        ]) {
          final bytes = (await rootBundle.load(asset)).buffer.asUint8List();
          // PNG imzosi va IHDR eni.
          expect(bytes.sublist(1, 4), 'PNG'.codeUnits, reason: asset);
          final w = ByteData.sublistView(bytes).getUint32(16);
          expect(w, width, reason: asset);
        }
      }
      expect(categories, InstrumentCategory.values.toSet());
      for (final c in InstrumentCategory.values) {
        expect(InstrumentSchematic.defaultFor(c).category, c);
      }
    });

    test('katalogdagi har model o‘z yo‘nalishiga mos chizmaga ega', () async {
      final models = [
        for (final m in raw()['models']! as List)
          InstrumentModel.fromJson((m as Map).cast<String, Object?>()),
      ];
      expect(models, isNotEmpty);
      for (final m in models) {
        expect(m.schematic.category, m.category, reason: m.id);
        // Katalogda tur aniq yozilgan (standartga tushmagan).
        expect(
          (raw()['models']! as List).cast<Map<String, Object?>>().firstWhere(
            (j) => j['id'] == m.id,
          )['schematic'],
          m.schematic.key,
          reason: m.id,
        );
        await rootBundle.load(m.schematic.asset);
        await rootBundle.load(m.schematic.assetLarge);
      }
      // Turlar to'g'ri tanlangan: 3 qismli, fotometr, siydik tizimi.
      String of(String id) =>
          models.firstWhere((m) => m.id == id).schematic.key;
      expect(of('mindray-bc-30s'), 'hematology3');
      expect(of('mindray-bc-5390'), 'hematology5');
      expect(of('human-humalyzer-4000'), 'photometer');
      expect(of('roche-cobas-6500'), 'urine_system');
      expect(of('roche-cobas-u-411'), 'urine_strip');
    });

    test(
      'turi yo‘q bo‘lsa — yo‘nalishning standarti; noto‘g‘ri tur rad etiladi',
      () {
        expect(
          _model(category: 'hematology').schematic,
          InstrumentSchematic.hematology5,
        );
        expect(
          () => _model(category: 'hematology', schematic: 'urine_strip'),
          throwsFormatException,
        );
        expect(() => _model(schematic: 'coagulation'), throwsFormatException);
      },
    );
  });

  for (final brightness in Brightness.values) {
    for (final scale in [1.3, 2.0]) {
      testWidgets(
        '320 px, shrift $scale, ${brightness.name}: overflow yo‘q, izoh sig‘adi',
        (tester) async {
          for (final lang in ['uz', 'ru', 'en']) {
            for (final image in [null, _image(_existing)]) {
              await _pump(
                tester,
                _model(image: image),
                brightness: brightness,
                size: const Size(320, 640),
                textScale: scale,
                lang: lang,
              );
              expect(tester.takeException(), isNull);
              if (image == null) {
                final cap = find.text(
                  lookupAppLocalizations(Locale(lang)).instSchematicCaption,
                );
                expect(cap, findsOneWidget);
                final r = tester.getRect(cap);
                expect(r.left, greaterThanOrEqualTo(0));
                expect(r.right, lessThanOrEqualTo(320));
              }
            }
          }
        },
      );
    }
  }
}
