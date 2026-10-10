import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/tools/calc_info.dart';

/// Kalkulyator izohlarida "≈ SI (konv.)" juftlari: SI birinchi, konvensional
/// qavsda; juftlik koeffitsienti ilovadagi molyar massaga mos.
void main() {
  final pair = RegExp(
    r'≈ (\d+[.,]?\d*) (?:mmol/L|ммоль/л) \((\d+[.,]?\d*) (?:mg/dL|мг/дл)\)',
  );
  double parse(String s) => double.parse(s.replaceAll(',', '.'));

  test('SI-first pairs match analyte factors; none in old order', () {
    final all = [
      for (final i in calcInfo.values) ...[...i.formula, ...i.limitations],
    ];
    final seen = <String, int>{};
    for (final t in all) {
      for (final lang in ['uz', 'ru', 'en']) {
        final text = t.of(lang);
        // Eski tartib: "400 mg/dL (≈ 4,5 mmol/L)" — qolmasligi kerak.
        expect(
          RegExp(r'\d (?:mg/dL|мг/дл) \(≈').hasMatch(text),
          isFalse,
          reason: text,
        );
        for (final m in pair.allMatches(text)) {
          final f = parse(m[2]!) / parse(m[1]!);
          // TG: mg/dL = mmol/L × 88,545 (triolein 885,45 g/mol);
          // eAG (glyukoza): × 18,016. Yaxlitlash chegarasida.
          final isTg = text.contains('TG') || text.contains('ТГ');
          final expected = isTg ? 88.545 : 18.016;
          expect((f - expected).abs() / expected, lessThan(0.01), reason: text);
          seen[lang] = (seen[lang] ?? 0) + 1;
        }
      }
    }
    // Friedewald 400, Sampson 800, eAG 15,7 — har tilda 3 juftlik.
    expect(seen, {'uz': 3, 'ru': 3, 'en': 3});
  });
}
