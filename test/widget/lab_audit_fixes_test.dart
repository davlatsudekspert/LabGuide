// Lab tabi auditi (2026-10-18, docs/AUDIT_2026-10-18_LAB.md): topilgan
// xatolarning regressiya testlari.
//
// #1 Koagulogramma sitrat hisoblagichi: "Infinity"/"NaN"/1e400 kiritilsa
//    maydon xato ko'rsatmay, natija jimgina yo'qolardi.
// #2 Sitrat hisoblagichining standart hajmi uz/ru da "4.5" (nuqta) edi —
//    natija va boshqa maydonlar vergul bilan.
// #3 Kalibrlash yozuvi: cheksiz (1e400) yoki manfiy qiymat qabul qilinardi;
//    cheksiz son JSON ga yozilmay, ekranda xom texnik xato ("Converting
//    object to an encodable object failed: Infinity") chiqardi.
// #4 Apparat/kalibrlash yozuvini saqlash xatosi xom matn ('$e') bo'lib
//    ko'rsatilardi — endi tushunarli, tarjima qilingan xabar.
// #5 Koprologiya: Kurbonova (2023) manbasining bet raqami ru/en da ham
//    o'zbekcha "46-b." bo'lib qolardi — endi interfeys tilida.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/coagulogram/coag_content.dart';
import 'package:labguide/features/coagulogram/coag_logic.dart';
import 'package:labguide/features/coagulogram/coag_screens.dart' show coagBase;
import 'package:labguide/features/coprology/copro_content.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/tools/calc_info.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

Finder _field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextField),
);

/// Kalibrlash jurnaliga yozishda xato beradigan ombor (disk to'la va h.k.).
class _FailingCalibrationStore extends MemoryKeyValueStore {
  @override
  Future<void> setString(String key, String value) async {
    if (key == StoreKeys.calibrationLog) {
      throw StateError('disk full');
    }
    return super.setString(key, value);
  }
}

Future<void> _seek(WidgetTester tester, Finder f) async {
  if (f.evaluate().isNotEmpty) {
    await tester.ensureVisible(f.last);
    await tester.pumpAndSettle();
    return;
  }
  await tester.scrollUntilVisible(
    f,
    200,
    scrollable: find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .hitTestable()
        .first,
  );
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await _seek(tester, find.text(text));
  await tester.ensureVisible(find.text(text).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

Future<void> _enterField(
  WidgetTester tester,
  String label,
  String value,
) async {
  await _seek(tester, find.text(label));
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

/// Kalibrlash sahifasi: saqlangan apparat, glyukoza, reagent va IFU
/// kiritilgan; yozuv shakli ochiq, lot kiritilgan.
Future<AppLocalizations> _openRecordForm(
  WidgetTester tester, {
  KeyValueStore? store,
}) async {
  final l = lookupAppLocalizations(const Locale('uz'));
  final s = await makeServices(tester, store: store as MemoryKeyValueStore?);
  final mine = await tester.runAsync(
    () => s.instruments.addFromCatalog('human-humalyzer-4000'),
  );
  await pumpApp(tester, s);
  await goTo(
    tester,
    '/lab/calibration?mine=${mine!.id}&analyte=glucose-plasma-fasting',
  );
  await _enterField(tester, l.calReagentRef, '10121');
  await _enterField(tester, l.calIfuRevision, '2024-01');
  await _tapText(tester, l.calShowGuide);
  await _tapText(tester, l.calRecordCreate);
  await _enterField(tester, l.calCalibratorLot, 'L-77');
  await _enterField(tester, l.calLevelUnit, 'mmol/L');
  return l;
}

void main() {
  setUpAll(loadAppFonts);

  group('#1 sitrat: chekli bo‘lmagan son — xato ko‘rsatiladi', () {
    test('cgParse: NaN, Infinity, 1e400 → null', () {
      for (final bad in ['NaN', 'Infinity', '-Infinity', '1e400', '1,5,5']) {
        expect(cgParse(bad), isNull, reason: bad);
      }
      expect(cgParse('1e2'), 100);
      expect(cgParse('4,5'), 4.5);
    });

    for (final bad in ['Infinity', 'NaN', '1e400']) {
      testWidgets('Ht = "$bad" → "noto‘g‘ri son", natija yo‘q', (tester) async {
        final s = await makeServices(tester);
        await pumpApp(tester, s, size: const Size(390, 4000));
        await goTo(tester, '$coagBase/sample');
        await tester.enterText(_field('coag-citrate-hct'), bad);
        await tester.pumpAndSettle();
        expect(find.text(CgL.invalidNumber.of('uz')), findsOne);
        expect(find.byKey(const ValueKey('coag-citrate-result')), findsNothing);
      });
    }

    testWidgets('hajm = "1e400" → "noto‘g‘ri son"', (tester) async {
      final s = await makeServices(tester);
      await pumpApp(tester, s, size: const Size(390, 4000));
      await goTo(tester, '$coagBase/sample');
      await tester.enterText(_field('coag-citrate-hct'), '70');
      await tester.enterText(_field('coag-citrate-vol'), '1e400');
      await tester.pumpAndSettle();
      expect(find.text(CgL.invalidNumber.of('uz')), findsOne);
      expect(find.byKey(const ValueKey('coag-citrate-result')), findsNothing);
    });
  });

  group('#2 sitrat: standart hajm interfeys tilining o‘nlik belgisida', () {
    for (final (lang, want, result) in [
      (AppLanguage.uz, '4,5', '0,25'),
      (AppLanguage.ru, '4,5', '0,25'),
      (AppLanguage.en, '4.5', '0.25'),
    ]) {
      testWidgets('${lang.name}: "$want"', (tester) async {
        final s = await makeServices(tester, language: lang);
        await pumpApp(tester, s, size: const Size(390, 4000));
        await goTo(tester, '$coagBase/sample');
        final vol = tester.widget<TextField>(_field('coag-citrate-vol'));
        expect(vol.controller!.text, want);
        await tester.enterText(_field('coag-citrate-hct'), '70');
        await tester.pumpAndSettle();
        expect(
          find.text('${CgL.citrateResult.of(lang.name)}: $result'),
          findsOne,
        );
      });
    }
  });

  group('#3 kalibrlash: cheksiz yoki manfiy qiymat — kiritish xatosi', () {
    for (final bad in ['1e400', '-1']) {
      testWidgets('qiymat "$bad" → calLevelInvalid, yozuv saqlanmaydi', (
        tester,
      ) async {
        final l = await _openRecordForm(tester);
        await _enterField(tester, l.calLevelValue, bad);
        await _tapText(tester, l.calRecordSave);
        await _seek(tester, find.text(l.calLevelInvalid));
        expect(find.textContaining('Converting object'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('0 qabul qilinadi (nol kalibrator)', (tester) async {
      final l = await _openRecordForm(tester);
      await _enterField(tester, l.calLevelValue, '0');
      await _tapText(tester, l.calRecordSave);
      expect(find.text(l.calRecordSaved), findsOneWidget);
    });
  });

  testWidgets('#4 saqlash xatosi — tarjima qilingan xabar, xom matn emas', (
    tester,
  ) async {
    final l = await _openRecordForm(tester, store: _FailingCalibrationStore());
    await _enterField(tester, l.calLevelValue, '5,55');
    await _tapText(tester, l.calRecordSave);
    await _seek(tester, find.text(l.instSaveFailed));
    expect(find.textContaining('disk full'), findsNothing);
    expect(find.textContaining('Bad state'), findsNothing);
  });

  test('#5 koprologiya: Kurbonova bet raqami interfeys tilida', () {
    final refs = [for (final f in cpAllFacts) ...f.refs, ...cpLeadRefs];
    expect(refs, isNotEmpty);
    String uz(String p) => '$p-bet';
    String ru(String p) => 'с. $p';
    String en(String p) => 'p. $p';
    final kurbonova = refs.where(
      (r) => r.source.id == CpSources.kurbonova2023.id && r.locator.isNotEmpty,
    );
    expect(kurbonova, isNotEmpty);
    for (final r in kurbonova) {
      expect(r.locator, isNot(contains('-b.')), reason: r.locator);
      expect(localizePages(r.locator, uz), contains('-bet'));
      expect(localizePages(r.locator, ru), contains('с. '));
      expect(localizePages(r.locator, en), contains('p. '));
    }
  });
}
