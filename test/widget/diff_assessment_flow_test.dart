import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/differential/diff_assessment.dart';
import 'package:labguide/features/differential/diff_assessment_screens.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('baho: past/yuqori belgisi, Talqin topilmasi (${lang.name})', (
      tester,
    ) async {
      final s = await makeServices(tester, language: lang);
      final l = lookupAppLocalizations(Locale(lang.name));
      // 20 neytrofil, 80 limfotsit, WBC 10 → neytrofil 2,0 (me'yor),
      // limfotsit 8,0 (yuqori) — limfotsitoz.
      for (var i = 0; i < 20; i++) {
        s.differential.tap(DiffCell.segmented);
      }
      for (var i = 0; i < 80; i++) {
        s.differential.tap(DiffCell.lymphocyte);
      }
      s.differential.setWbc(10);
      await pumpApp(tester, s, size: const Size(390, 4000));
      await goTo(tester, '/lab/differential/count');
      expect(find.byType(DiffAssessmentPanel), findsOne);
      expect(find.text(l.diffAssessTitle), findsOne);
      expect(find.text(l.diffFlagHigh), findsOne);
      final lympho = diffFindings.firstWhere((f) => f.id == 'lymphocytosis');
      expect(
        find.text(l.diffAssessMaySuggest(findingLabel(lympho, lang.name))),
        findsOne,
      );
      expect(
        find.byKey(const ValueKey('diff-assess-all-normal')),
        findsNothing,
      );
      expect(find.text(l.diffAssessReferBody), findsNothing);
      expect(tester.takeException(), isNull);

      // Blanka me'yorlari sahifasi.
      await tester.ensureVisible(find.text(l.diffLimitsTitle));
      await tester.tap(find.text(l.diffLimitsTitle));
      await tester.pumpAndSettle();
      expect(find.byType(DiffLimitsScreen), findsOne);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tugallanmagan sanash: baho yo‘q, izoh bor (audit #3)', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.ru);
    final l = lookupAppLocalizations(const Locale('ru'));
    // Bitta tayoqcha bosildi — ilgari "Повышено / сдвиг влево" chiqardi.
    s.differential.tap(DiffCell.band);
    s.differential.setWbc(6);
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '/lab/differential/count');
    expect(find.text(l.diffAssessIncomplete(1, 100)), findsOne);
    expect(find.text(l.diffFlagHigh), findsNothing);
    expect(find.text(l.diffFlagLow), findsNothing);
    expect(find.byKey(const ValueKey('diff-assess-all-normal')), findsNothing);
    expect(find.byKey(const ValueKey('diff-assess-refer')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('blast bilan: yo‘llash bor, “hammasi me’yorda” yo‘q (audit #4)', (
    tester,
  ) async {
    final s = await makeServices(tester);
    const counts = {
      DiffCell.segmented: 58,
      DiffCell.band: 2,
      DiffCell.lymphocyte: 30,
      DiffCell.monocyte: 5,
      DiffCell.eosinophil: 3,
      DiffCell.basophil: 1,
      DiffCell.other: 1,
    };
    for (final e in counts.entries) {
      for (var i = 0; i < e.value; i++) {
        s.differential.tap(e.key);
      }
    }
    s.differential.setWbc(6);
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '/lab/differential/count');
    expect(find.byKey(const ValueKey('diff-assess-refer')), findsOne);
    expect(find.byKey(const ValueKey('diff-assess-all-normal')), findsNothing);
    expect(find.byKey(const ValueKey('diff-assess-incomplete')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('rus tilida topilma bosh kelishikda, kichik harf bilan (audit #15)', () {
    final ru = lookupAppLocalizations(const Locale('ru'));
    final neutropenia = diffFindings.firstWhere((f) => f.id == 'neutropenia');
    expect(
      ru.diffAssessMaySuggest(findingLabel(neutropenia, 'ru')),
      'Возможная трактовка: нейтропения',
    );
    expect(findingLabel(neutropenia, 'en'), 'Neutropenia');
  });

  testWidgets('me’yorni o‘zgartirish bahoni o‘zgartiradi, qaytarish', (
    tester,
  ) async {
    final s = await makeServices(tester);
    final l = lookupAppLocalizations(const Locale('uz'));
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '/lab/differential/limits');
    final fields = find.byType(TextField);
    // 2-indeks — limfotsitlar pastki chegarasi (neytrofillar 2 ta maydon).
    await tester.enterText(fields.at(2), '9');
    await tester.pumpAndSettle();
    expect(find.text(l.diffLimitsInvalid), findsOne);
    expect(
      s.differential.limits[DiffMeasure.lymphocytes],
      diffDefaultLimits[DiffMeasure.lymphocytes],
    );
    await tester.enterText(fields.at(2), '');
    await tester.pumpAndSettle();
    expect(s.differential.limits[DiffMeasure.lymphocytes]!.low, isNull);
    await tester.ensureVisible(find.text(l.diffLimitsReset));
    await tester.tap(find.text(l.diffLimitsReset));
    await tester.pumpAndSettle();
    expect(s.differential.limits, diffDefaultLimits);
    expect(tester.takeException(), isNull);
  });
}
