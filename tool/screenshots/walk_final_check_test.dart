// Yakuniy vizual tekshiruv: birlik sozlamasi (SI/konvensional), kutubxona
// (ru/en), qo'sh birlikli kunlik savol (ogtt-q2) va tor ekran (320 px, shrift
// 1.35). Rasmlar: tool/screenshots/out/walk/final_*/NN_<qadam>.png
//
//   flutter test tool/screenshots/walk_final_check_test.dart --update-goldens
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/daily/daily_streak.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import '../../test/helpers/learn_helpers.dart';
import 'walk_helper.dart';

const _cards = <(String, String)>[
  ('glyukoza', '/tests/analyte/glucose-plasma-fasting'),
  ('ldl', '/tests/analyte/ldl-c'),
  ('calc_ldl', '/lab/calculators/ldl'),
];

Future<void> _units(
  WidgetTester tester,
  AppLanguage lang,
  UnitSystem unit,
) async {
  // Birlik sozlamasi sahifalar ochilganda o'qiladi: har tizim uchun alohida
  // ishga tushirish (ochiq qolgan sahifa boshlang'ich birligini saqlaydi).
  await start(
    tester,
    lang: lang,
    store: MemoryKeyValueStore({StoreKeys.unitSystem: unit.name}),
  );
  final w = Walk(tester, 'final_units_${lang.name}_${unit.name}');
  final l = lookupAppLocalizations(Locale(lang.name));
  for (final (name, path, target) in [
    (
      'glyukoza',
      '/tests/analyte/glucose-plasma-fasting',
      l.analyteDecisionLimits,
    ),
    ('ldl', '/tests/analyte/ldl-c', l.analyteTreatmentGoals),
  ]) {
    await goTo(tester, path);
    await w.snap(name);
    await tapScroll(tester, target);
    await w.scroll(250);
    await w.snap('${name}_chegaralar');
  }
  await goTo(tester, '/lab/calculators/ldl');
  await w.snap('calc_ldl');
}

/// Profil -> Birliklar: SI dan konvensionalga almashtirish, so'ng kartalar.
Future<void> _toggle(WidgetTester tester, AppLanguage lang) async {
  final l = lookupAppLocalizations(Locale(lang.name));
  await start(tester, lang: lang);
  final w = Walk(tester, 'final_toggle_${lang.name}');
  await goTo(tester, '/profile');
  await w.scroll(500);
  await w.snap('si');
  await tapScroll(tester, l.profileUnitsConventional);
  await w.snap('konvensional');
  for (final (name, path) in _cards) {
    await goTo(tester, path);
    await w.snap(name);
  }
}

Future<void> _library(WidgetTester tester, AppLanguage lang) async {
  await start(tester, lang: lang);
  final w = Walk(tester, 'final_library_${lang.name}');
  await goTo(tester, '/library');
  await w.snap('royxat');
  await w.scroll(700);
  await w.snap('royxat_past');
  await w.scroll(900);
  await w.snap('royxat_oxiri');
}

Future<void> _daily(
  WidgetTester tester,
  AppLanguage lang, {
  Size size = const Size(390, 844),
  double textScale = 1,
  String tag = '',
}) async {
  final store = MemoryKeyValueStore({
    StoreKeys.dailyToday: jsonEncode({
      'day': dayOf(DateTime.now()),
      'src': 'pack',
      'ids': ['ogtt-q2', 'ldl-c-q2', 'hemoglobin-q1', 'sodium-q1', 'mcv-q1'],
      'ans': <String, Object>{},
    }),
  });
  await start(
    tester,
    lang: lang,
    size: size,
    textScale: textScale,
    store: store,
    role: AppRole.doctor,
  );
  final w = Walk(tester, 'final_daily_${lang.name}$tag');
  await goTo(tester, '/learn/daily');
  await w.snap('savol');
  await w.scroll(400);
  await w.snap('savol_past');
  await tapScroll(tester, 'A');
  await w.snap('javob');
  await w.scroll(600);
  await w.snap('javob_past');
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    for (final u in UnitSystem.values) {
      testWidgets(
        'birliklar (${lang.name}, ${u.name})',
        (t) => _units(t, lang, u),
      );
    }
    testWidgets('birlik almashtirish (${lang.name})', (t) => _toggle(t, lang));
    testWidgets('kunlik ogtt-q2 (${lang.name})', (t) => _daily(t, lang));
  }
  for (final lang in [AppLanguage.ru, AppLanguage.en]) {
    testWidgets('kutubxona (${lang.name})', (t) => _library(t, lang));
  }

  testWidgets('tor ekran 320 px, shrift 1.35 (ru)', (tester) async {
    const size = Size(320, 640);
    final s = await start(
      tester,
      lang: AppLanguage.ru,
      size: size,
      textScale: 1.35,
    );
    await s.settings.setUnitSystem(UnitSystem.conventional);
    final w = Walk(tester, 'final_tor_ru');
    for (final (name, path) in [
      ('bosh', '/home'),
      ('tests', '/tests'),
      ('lab', '/lab'),
      ('library', '/library'),
      ('learn', '/learn'),
      ('profile', '/profile'),
      ('glyukoza', '/tests/analyte/glucose-plasma-fasting'),
      ('ldl', '/tests/analyte/ldl-c'),
      ('calc_ldl', '/lab/calculators/ldl'),
      ('units', '/lab/calculators/units'),
    ]) {
      await goTo(tester, path);
      await w.snap(name);
      await w.scroll(700);
      await w.snap('${name}_past');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('tor ekran kunlik savol (uz, en)', (tester) async {
    await _daily(
      tester,
      AppLanguage.uz,
      size: const Size(320, 640),
      textScale: 1.35,
      tag: '_tor',
    );
  });
}
