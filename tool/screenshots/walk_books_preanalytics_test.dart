// Kitoblardan kelgan bilim: preanalitika bloklari, siydik bo'yicha qo'lda
// usullar (Nechiporenko, Kakovskiy–Addis, Zimnitskiy), siydik va qon
// bo'lmagan namunalar kartalari, kutubxona katalogi (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_books_preanalytics_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/tools/manual_calc_screens.dart';
import 'package:labguide/features/tools/manual_calculators.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

Future<void> back(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back_rounded).hitTestable().last);
  await tester.pumpAndSettle();
}

Finder _scrollable() => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .hitTestable()
    .first;

Future<void> fill(
  WidgetTester tester,
  AppLocalizations l,
  List<(ManualField, String)> values,
) async {
  await tester.drag(_scrollable(), const Offset(0, 8000));
  await tester.pumpAndSettle();
  for (final (field, v) in values) {
    final name = manualFieldName(field, l);
    final f = find.byWidgetPredicate(
      (w) => w is LgField && w.label.startsWith(name),
    );
    await tester.scrollUntilVisible(f, 150, scrollable: _scrollable());
    await tester.enterText(
      find.descendant(of: f, matching: find.byType(TextField)),
      v,
    );
  }
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}

Future<void> open(Walk w, String text) async {
  final f = find.text(text);
  for (var i = 0; i < 40 && f.evaluate().isEmpty; i++) {
    await w.scroll(250);
  }
  await w.tap(f.last);
}

/// Matn ko'ringuncha pastga suradi.
Future<void> scrollTo(Walk w, String text) async {
  final f = find.text(text);
  for (var i = 0; i < 60 && f.hitTestable().evaluate().isEmpty; i++) {
    await w.scroll(300);
  }
  await w.tester.ensureVisible(f.first);
  await w.tester.pumpAndSettle();
}

Future<void> walkLab(
  WidgetTester tester,
  Walk w,
  AppLocalizations l,
  String dec,
) async {
  await w.tapText(l.navLab);
  await open(w, l.labPreanalytics);
  await w.snap('preanalitika_bosh');
  await scrollTo(w, l.prePatientTitle);
  await w.snap('bemor_tayyorgarligi');
  await scrollTo(w, l.preMixTitle);
  await w.snap('aralashtirish');
  await scrollTo(w, l.preTubeForTestTitle);
  await w.snap('qaysi_probirka');
  await w.scroll(600);
  await w.snap('qaysi_probirka_davomi');
  await scrollTo(w, l.preStabilityTitle);
  await w.snap('barqarorlik');
  await w.scroll(700);
  await w.snap('barqarorlik_davomi');
  await scrollTo(w, l.preUrgentTitle);
  await w.snap('darhol_tekshiriladi');
  await scrollTo(w, l.calcSources);
  await w.snap('manbalar');
  await w.scroll(800);
  await w.snap('manbalar_davomi');
  await back(tester);

  await open(w, l.featureCalculators);
  await w.scroll(900);
  await w.snap('kalkulyatorlar_royxati');

  // Nechiporenko.
  await open(w, l.mcNechiporenko);
  await w.snap('nechiporenko_bosh');
  await fill(tester, l, [
    (ManualField.urineLeuko, '8'),
    (ManualField.urineEry, '2'),
  ]);
  await open(w, l.mfGoryaev100);
  await open(w, '1 ml');
  await open(w, l.dilCalculate);
  await w.snap('nechiporenko_natija');
  await scrollTo(w, l.mcClassicTitle);
  await w.snap('nechiporenko_klassik_oraliq');
  await w.scroll(700);
  await w.snap('nechiporenko_cheklov_manba');
  await back(tester);

  // Kakovskiy–Addis.
  await open(w, l.mcAddis);
  await fill(tester, l, [
    (ManualField.collectedVolume, '600'),
    (ManualField.collectionHours, '10'),
    (ManualField.urineLeuko, '9'),
    (ManualField.urineCasts, '1'),
  ]);
  await open(w, l.dilCalculate);
  await w.snap('addis_natija');
  await back(tester);

  // Zimnitskiy (Lyubina 1984, 1-misol).
  await open(w, l.mcZimnitsky);
  await w.snap('zimnitskiy_bosh');
  const v = ['265', '230', '150', '115', '115', '35', '60', '40'];
  const g = ['1014', '1012', '1015', '1018', '1023', '1021', '1018', '1020'];
  await fill(tester, l, [
    for (var i = 0; i < 8; i++) ...[
      (zimnitskyVolumeFields[i], v[i]),
      (zimnitskySgFields[i], i.isEven ? g[i] : '1$dec${g[i].substring(1)}'),
    ],
    (ManualField.fluidIntake, '1400'),
  ]);
  await open(w, l.dilCalculate);
  await w.snap('zimnitskiy_natija');
  await w.scroll(500);
  await w.snap('zimnitskiy_natija_davomi');
  await scrollTo(w, l.mcClassicTitle);
  await w.snap('zimnitskiy_klassik_oraliq');
  await back(tester);
}

Future<void> walkCards(WidgetTester tester, Walk w, AppLocalizations l) async {
  await goTo(tester, '/tests/analyte/urine-chemistry');
  await w.snap('siydik_kimyo_bosh');
  await w.scroll(2200);
  await w.snap('siydik_kimyo_preanalitika');
  await w.scroll(900);
  await w.snap('siydik_kimyo_xalaqit');
  await scrollTo(w, l.analyteSources);
  await w.scroll(400);
  await w.snap('siydik_kimyo_manbalar');
  await goTo(tester, '/tests/analyte/urine-microscopy');
  await w.scroll(2200);
  await w.snap('siydik_mikroskopiya');
  await goTo(tester, '/tests/analyte/fecal-occult-blood');
  await w.scroll(1500);
  await w.snap('yashirin_qon_fit');
  await goTo(tester, '/tests/analyte/urine-culture');
  await w.scroll(1500);
  await w.snap('siydik_ekma');
  await goTo(tester, '/library/books');
  await tester.enterText(find.byType(TextField).first, 'Aripova');
  await tester.pumpAndSettle();
  await w.snap('kutubxona_qidiruv');
  await open(w, 'Klinik va biokimyoviy tekshiruv usullari');
  await w.snap('kutubxona_aripova');
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('laborant: kitoblardan preanalitika va qo‘lda usullar (uz)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    await start(tester);
    final w = Walk(tester, 'books_preanalytics_uz');
    await walkLab(tester, w, l, ',');
    await walkCards(tester, w, l);
  });

  testWidgets('laborant: ru, qorong‘i, katta shrift', (tester) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
    );
    final w = Walk(tester, 'books_preanalytics_ru_dark_large');
    await walkLab(tester, w, l, ',');
    await walkCards(tester, w, l);
  });

  testWidgets('shifokor: en, 320 px', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    await start(
      tester,
      lang: AppLanguage.en,
      role: AppRole.doctor,
      size: const Size(320, 640),
    );
    final w = Walk(tester, 'books_preanalytics_en_320');
    await walkLab(tester, w, l, '.');
    await walkCards(tester, w, l);
  });
}
