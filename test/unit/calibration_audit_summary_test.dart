// Kalibrlash tarixi qatori ilova tilida ko'rinadi: saqlangan matn
// (`InstrumentsController._summary`) inglizcha enum nomlarini o'z ichiga oladi,
// ko'rsatishda ular tilga o'giriladi (video QA, 2026-10-25).
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/instruments/calibration_screens.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';

void main() {
  const stored = 'GLU · LOT42 · pending · training · QC notRun';
  const edited =
      'GLU · LOT42 · pending · training · QC notRun -> '
      'GLU · LOT42 · accepted · lab · QC pass';

  for (final code in ['uz', 'ru', 'en']) {
    test('$code: enum nomlari ko‘rinmaydi, tahlil kodi va lot saqlanadi', () {
      final l = lookupAppLocalizations(Locale(code));
      final one = localizedAuditSummary(stored, l);
      for (final raw in ['pending', 'training', 'notRun']) {
        expect(one, isNot(contains(raw)), reason: one);
      }
      expect(one, isNot(contains('QC QC')), reason: one);
      expect(one, contains('GLU · LOT42'));
      expect(one, contains(l.calOutcomePending));
      expect(one, contains(l.calSafeKindTraining));
      expect(one, contains(l.calSafeQcNotRun));
      final two = localizedAuditSummary(edited, l);
      expect(RegExp(r'QC pass\b').hasMatch(two), isFalse, reason: two);
      for (final raw in ['accepted', ' lab ', '->']) {
        expect(two, isNot(contains(raw)), reason: two);
      }
      expect(two, contains(l.calOutcomeAccepted));
      expect(two, contains(l.calSafeKindLab));
      expect(two, contains(l.calSafeQcPass));
    });
  }

  test('tahlil kodi nomga o‘tadi; noma’lum kod o‘z holicha qoladi', () {
    final l = lookupAppLocalizations(const Locale('ru'));
    String? names(String id) =>
        id == 'glucose-plasma-fasting' ? 'Глюкоза' : null;
    final a = localizedAuditSummary(
      'glucose-plasma-fasting · LOT1 · pending · lab · QC pass -> '
      'unknown-id · LOT1 · accepted · lab · QC pass',
      l,
      analyteName: names,
    );
    expect(a, startsWith('Глюкоза · LOT1 · '));
    expect(a, contains('unknown-id · LOT1'));
    expect(a, isNot(contains('glucose-plasma-fasting')));
  });

  test('noma’lum matn o‘zgarishsiz qoladi', () {
    final l = lookupAppLocalizations(const Locale('uz'));
    expect(localizedAuditSummary('eski yozuv', l), 'eski yozuv');
  });
}
