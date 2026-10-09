import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/instruments/instruments_controller.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

/// Laboratoriya mutaxassisi sifatida: yo'nalish → ishlab chiqaruvchi →
/// model → karta → “Mening apparatim” → kalibrlash → yozuv → jurnal →
/// qayta ochish.
Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) =>
    _tap(tester, find.text(text).last);

Future<void> _enterField(
  WidgetTester tester,
  String label,
  String value,
) async {
  final field = find.descendant(
    of: find
        .ancestor(of: find.text(label).last, matching: find.byType(Column))
        .first,
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field.first);
  await tester.enterText(field.first, value);
  await tester.pumpAndSettle();
}

Future<void> _seek(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    200,
    // Ko'rinib turgan sahifaning vertikal ro'yxati (boshqa tablar emas).
    scrollable: find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .hitTestable()
        .first,
  );
  await tester.pumpAndSettle();
}

Future<void> _loadCatalog(WidgetTester tester, AppServices s) async {
  await tester.runAsync(s.instruments.ensureCatalog);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('yo‘nalish → ishlab chiqaruvchi → model → karta', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final services = await makeServices(tester);
    await _loadCatalog(tester, services);
    await pumpApp(tester, services);
    await goTo(tester, '/lab');
    await _tapText(tester, l.labInstruments);
    expect(find.text(l.instDirections), findsOneWidget);
    await _tapText(tester, 'Gematologiya');
    expect(find.text(l.instChooseMaker), findsOneWidget);
    expect(find.text('Roche Diagnostics'), findsNothing);
    await _tapText(tester, 'HUMAN');
    expect(find.text('HumaCount 5D'), findsOneWidget);
    await _tapText(tester, 'HumaCount 5D');
    // Karta: yo'nalishning sxematik chizmasi (aniq model emas deb yozilgan),
    // holat zinapoyasi, vazifa va rasmiy matn, yopiq reagent tizimi, parvarish.
    expect(find.text(l.instIllustration), findsOneWidget);
    expect(
      tester.widgetList<Image>(find.byType(Image)).map((i) => i.image),
      contains(const AssetImage('assets/instruments/img/hematology.png')),
    );
    expect(find.text(l.instStatusDevice), findsOneWidget);
    expect(
      find.text('${l.instStatusIfu} — ${l.instStatusNotYet}'),
      findsOneWidget,
    );
    expect(
      find.text('${l.instStatusExpert} — ${l.instStatusNotYet}'),
      findsOneWidget,
    );
    await _seek(
      tester,
      find.text('“Outstanding 5-part diff hematology system”'),
    );
    await _seek(tester, find.text(l.instReagentClosed));
    await _seek(tester, find.text(l.instMaintenanceNone));
    await _seek(tester, find.text('HUMAN target value sheets'));
    // Orqaga — model ro'yxatiga.
    routerOf(tester).pop();
    await tester.pumpAndSettle();
    expect(find.text('HumaCount 30TS'), findsOneWidget);
  });

  testWidgets('siydik apparati kartasida o‘z chizmamiz, foto emas', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final services = await makeServices(tester);
    await _loadCatalog(tester, services);
    await pumpApp(tester, services);
    await goTo(tester, '/lab/instruments/m/roche-cobas-u-411');
    expect(
      tester.widgetList<Image>(find.byType(Image)).map((i) => i.image),
      contains(const AssetImage('assets/instruments/img/urinalysis.png')),
    );
    expect(find.text(l.instIllustration), findsOneWidget);
    expect(find.textContaining('CC BY-SA'), findsNothing);
  });

  for (final (lang, query, expected) in [
    (AppLanguage.uz, 'siydik', 'cobas u 411'),
    (AppLanguage.ru, 'моча', 'cobas u 411'),
    (AppLanguage.en, 'urine', 'cobas u 411'),
    (AppLanguage.ru, 'биохим humalyzer', 'HumaLyzer 4000'),
  ]) {
    testWidgets('qidiruv ($lang): “$query”', (tester) async {
      final services = await makeServices(tester, language: lang);
      await _loadCatalog(tester, services);
      await pumpApp(tester, services);
      await goTo(tester, '/lab/instruments');
      await tester.enterText(find.byType(TextField).first, query);
      await tester.pumpAndSettle();
      expect(find.textContaining(expected), findsWidgets);
    });
  }

  testWidgets('topilmasa — qo‘lda qo‘shish taklif qilinadi', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final services = await makeServices(tester);
    await _loadCatalog(tester, services);
    await pumpApp(tester, services);
    await goTo(tester, '/lab/instruments');
    await tester.enterText(find.byType(TextField).first, 'Dirui CS-T240');
    await tester.pumpAndSettle();
    expect(find.text(l.instNoResultsTitle), findsOneWidget);
    await _tapText(tester, l.instAddCustom);
    await _enterField(tester, l.instMaker, 'Dirui');
    await _enterField(tester, l.instModel, 'CS-T240');
    await _tapText(tester, l.instSave);
    final m = services.instruments.mine.single;
    expect(m.isCustom, isTrue);
    expect(m.customModel, 'CS-T240');
  });

  testWidgets(
    'saqlash → kalibrlash (lotsiz yo‘riqnoma) → yozuv → jurnal → qayta ochish',
    (tester) async {
      final l = lookupAppLocalizations(const Locale('uz'));
      final services = await makeServices(tester);
      await _loadCatalog(tester, services);
      await pumpApp(tester, services);

      // 1. Kartadan “Mening apparatim”.
      await goTo(tester, '/lab/instruments/m/human-humalyzer-4000');
      await _tapText(tester, l.instSaveMine);
      await _enterField(tester, l.instLabel, '1-xona');
      await _enterField(tester, l.instManualVersion, 'v2.1');
      await _tapText(tester, l.instSave);
      expect(find.text(l.instSaved), findsOneWidget);
      expect(find.text(l.instSavedCount(1)), findsOneWidget);
      final mine = services.instruments.mine.single;
      expect(mine.label, '1-xona');

      // 2. Kalibrlash: apparat oldindan tanlangan.
      await _tapText(tester, l.instCalibrate);
      expect(find.text('HUMAN HumaLyzer 4000 · 1-xona'), findsOneWidget);
      // Analit qidiruvi.
      await tester.enterText(find.byType(TextField).first, 'glyukoza');
      await tester.pumpAndSettle();
      final glucose = services.content.pack!
          .analyte('glucose-plasma-fasting')!
          .names
          .of('uz');
      await _tapText(tester, glucose);
      expect(find.text(glucose), findsOneWidget);

      // Reagent: apparat ishlab chiqaruvchisi (HUMAN) — flayerdagi REF'lar.
      await _seek(
        tester,
        find.textContaining('GLUCOSE liquicolor — REF 10121, 10260'),
      );
      await _enterField(tester, l.calReagentRef, '10121');
      await _seek(tester, find.text(l.calRefListed));
      await _enterField(tester, l.calReagentRef, '99999');
      await _seek(tester, find.text(l.calRefNotListed));
      await _enterField(tester, l.calReagentRef, '10121');

      // IFU versiyasisiz — yo'riqnoma ko'rsatilmaydi.
      await _tapText(tester, l.calShowGuide);
      await _seek(tester, find.text(l.calGuideNeeds));
      await _enterField(tester, l.calIfuRevision, '2024-01');
      // Lot kiritilmagan — yo'riqnoma baribir ochiladi.
      await _tapText(tester, l.calShowGuide);
      await _seek(tester, find.text(l.calGuideNoneTitle));
      await _seek(tester, find.text(l.calGuide3));
      await _seek(tester, find.text('HUMAN target value sheets'));
      // Tanlov apparatga yozildi.
      expect(
        services
            .instruments
            .mine
            .single
            .reagents['glucose-plasma-fasting']!
            .ref,
        '10121',
      );

      // 3. Kalibrlash yozuvi: lot va qiymat endi so'raladi.
      await _tapText(tester, l.calRecordCreate);
      await _tapText(tester, l.calRecordSave);
      await _seek(tester, find.text(l.calLotRequired));
      await _enterField(tester, l.calCalibratorLot, 'L-77');
      await _tapText(tester, l.calRecordSave);
      await _seek(tester, find.text(l.calLevelInvalid));
      await _enterField(tester, l.calLevelValue, '5,55');
      await _enterField(tester, l.calLevelUnit, 'mmol/L');
      await _tapText(tester, l.calRecordSave);
      expect(find.text(l.calRecordSaved), findsOneWidget);
      final record = services.instruments.records.single;
      expect(record.calibratorLot, 'L-77');
      expect(record.levels.single.value, 5.55);
      expect(record.manualVersion, 'v2.1');
      expect(record.reagent.ifuVersion, '2024-01');

      // 4. Jurnal → yozuv.
      // “Saqlandi” xabaridagi tugma jurnalni ochadi.
      await _tap(tester, find.widgetWithText(SnackBarAction, l.calLog));
      expect(find.textContaining('L-77'), findsOneWidget);
      await _tap(tester, find.textContaining('L-77'));
      expect(find.text('5,55 mmol/L'), findsOneWidget);
      await _seek(tester, find.text(l.calUserEntered));

      // 5. Qayta ochish: apparat va reagent qayta kiritilmaydi.
      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, services);
      await goTo(
        tester,
        '/lab/calibration?mine=${mine.id}&analyte=glucose-plasma-fasting',
      );
      expect(find.text('HUMAN HumaLyzer 4000 · 1-xona'), findsOneWidget);
      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .map((f) => f.controller?.text)
          .toList();
      expect(fields, containsAll(['10121', '2024-01']));
    },
  );

  testWidgets('boshqa reagent ishlab chiqaruvchisi — moslik ogohlantirishi', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final services = await makeServices(tester);
    await _loadCatalog(tester, services);
    await pumpApp(tester, services);
    await goTo(
      tester,
      '/lab/calibration?model=roche-cobas-c-311&analyte=creatinine',
    );
    expect(find.text('Roche Diagnostics cobas c 311'), findsOneWidget);
    await _tapText(tester, l.calManufacturerOther);
    await _seek(tester, find.text(l.calDifferentMaker));
    await _enterField(tester, l.calReagentMakerName, 'Randox');
    await _enterField(tester, l.calReagentRef, 'CR510');
    await _enterField(tester, l.calIfuRevision, '1');
    await _tapText(tester, l.calShowGuide);
    await _seek(tester, find.text(l.calGuideNoneTitle));
    // Apparat ishlab chiqaruvchisining hujjat portali.
    await _seek(tester, find.text('Roche eLabDoc'));
    // Katalog modeli yozuv yaratilmaguncha avtomatik saqlanmaydi.
    expect(services.instruments.mine, isEmpty);
  });

  testWidgets('lokal ma’lumotni o‘chirish apparat va jurnalni tozalaydi', (
    tester,
  ) async {
    final services = await makeServices(tester);
    final m = await services.instruments.addFromCatalog('mindray-bs-240');
    await services.instruments.addRecord(
      instrument: m,
      instrumentName: 'Mindray BS-240',
      analyteId: 'urea',
      reagent: const ReagentChoice(maker: 'Mindray', ref: 'R', ifuVersion: '1'),
      calibratorLot: 'L',
      levels: const [CalibratorLevel(name: '1', value: 1, unit: 'mmol/L')],
      performedOn: DateTime(2026, 10, 9),
      outcome: CalibrationOutcome.accepted,
    );
    await tester.runAsync(() => services.deleteLocalData(const [Locale('uz')]));
    expect(services.instruments.mine, isEmpty);
    expect(services.instruments.records, isEmpty);
  });
}
