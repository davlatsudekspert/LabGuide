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
        find.text(l.diffAssessMaySuggest(lympho.title.of(lang.name))),
        findsOne,
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
