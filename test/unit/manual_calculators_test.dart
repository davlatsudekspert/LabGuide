import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/tools/manual_calc_info.dart';
import 'package:labguide/features/tools/manual_calculators.dart';

T ok<T>(ManualOutcome<T> o) => switch (o) {
  ManualOk(:final value) => value,
  ManualFail(:final issue, :final field) => throw TestFailure(
    'kutilmagan xato: $issue $field',
  ),
};

ManualFail<T> fail<T>(ManualOutcome<T> o) => switch (o) {
  final ManualFail<T> f => f,
  ManualOk() => throw TestFailure('xato kutilgan edi'),
};

void main() {
  group('hisob kamerasi', () {
    test('WHO misoli: 188 leykotsit, 4 × 1 mm², 0,1 mm, 1:20 → 9,4×10⁹/L', () {
      final r = ok(
        chamberCount(
          cells: 188,
          squares: 4,
          squareArea: 1,
          depth: 0.1,
          dilution: 20,
        ),
      );
      expect(r.perMicroLitre, closeTo(9400, 1e-9));
      expect(r.gigaPerLitre, closeTo(9.4, 1e-12));
      expect(r.volume, closeTo(0.4, 1e-12));
    });

    test('WHO: 1:40 suyultirishda ko‘paytuvchi 0,1 (×10⁹/L)', () {
      final r = ok(
        chamberCount(
          cells: 100,
          squares: 4,
          squareArea: 1,
          depth: 0.1,
          dilution: 40,
        ),
      );
      expect(r.gigaPerLitre, closeTo(10, 1e-9));
    });

    test('Fuchs–Rosenthal: suyultirilmagan, 5 mm², 0,2 mm', () {
      // 5 × 0,2 = 1 µL → sanalgan son = hujayra/µL (WHO 8.3.3).
      final r = ok(
        chamberCount(
          cells: 7,
          squares: 5,
          squareArea: 1,
          depth: 0.2,
          dilution: 1,
        ),
      );
      expect(r.perMicroLitre, closeTo(7, 1e-12));
    });

    test('noto‘g‘ri kirishlar', () {
      expect(
        fail(
          chamberCount(
            cells: null,
            squares: 4,
            squareArea: 1,
            depth: 0.1,
            dilution: 20,
          ),
        ).issue,
        ManualIssue.missing,
      );
      expect(
        fail(
          chamberCount(
            cells: 10.5,
            squares: 4,
            squareArea: 1,
            depth: 0.1,
            dilution: 20,
          ),
        ).field,
        ManualField.cells,
      );
      expect(
        fail(
          chamberCount(
            cells: 10,
            squares: 0,
            squareArea: 1,
            depth: 0.1,
            dilution: 20,
          ),
        ).field,
        ManualField.squares,
      );
      expect(
        fail(
          chamberCount(
            cells: 10,
            squares: 4,
            squareArea: 1,
            depth: 0.1,
            dilution: 0.5,
          ),
        ).field,
        ManualField.dilution,
      );
      expect(
        fail(
          chamberCount(
            cells: double.nan,
            squares: 4,
            squareArea: 1,
            depth: 0.1,
            dilution: 20,
          ),
        ).issue,
        ManualIssue.implausible,
      );
    });
  });

  group('leykoformula', () {
    const p = {
      ManualField.neutrophilsSeg: 56.0,
      ManualField.lymphocytes: 25.0,
      ManualField.eosinophils: 12.0,
      ManualField.monocytes: 6.0,
      ManualField.basophils: 1.0,
    };

    test('mutlaq son = ulush × WBC (WHO 9.13.3)', () {
      final r = ok(differentialAbsolute(wbc: 5, percents: p));
      expect(r.absolute[ManualField.neutrophilsSeg], closeTo(2.8, 1e-12));
      expect(r.absolute[ManualField.basophils], closeTo(0.05, 1e-12));
      expect(r.corrected, isFalse);
      expect(r.wbcUsed, 5);
    });

    test('WHO misoli: 50 NRBC, WBC 16 → NRBC 5,3; tuzatilgan 10,7', () {
      final r = ok(differentialAbsolute(wbc: 16, percents: p, nrbcPer100: 50));
      expect(r.nrbcAbsolute, closeTo(5.333, 1e-3));
      expect(r.wbcUsed, closeTo(10.667, 1e-3));
      // Mutlaq sonlar tuzatilgan WBC dan.
      expect(
        r.absolute[ManualField.lymphocytes],
        closeTo(0.25 * 10.6667, 1e-3),
      );
    });

    test('yig‘indi 100 emas → inconsistent', () {
      final f = fail(
        differentialAbsolute(
          wbc: 5,
          percents: {...p, ManualField.lymphocytes: 30},
        ),
      );
      expect(f.issue, ManualIssue.inconsistent);
      expect(f.sum, 105);
    });

    test('yarim foiz yaxlitlash qabul qilinadi', () {
      ok(
        differentialAbsolute(
          wbc: 5,
          percents: {...p, ManualField.lymphocytes: 25.5},
        ),
      );
    });

    test('WBC nol yoki bo‘sh → xato', () {
      expect(
        fail(differentialAbsolute(wbc: 0, percents: p)).field,
        ManualField.wbc,
      );
      expect(
        fail(differentialAbsolute(wbc: null, percents: p)).issue,
        ManualIssue.missing,
      );
      expect(
        fail(differentialAbsolute(wbc: 5, percents: const {})).issue,
        ManualIssue.missing,
      );
    });
  });

  group('retikulotsitlar', () {
    test('WHO misoli: 500 da 6, RBC 4,5 → 1,2 % va 54×10⁹/L', () {
      final r = ok(
        reticulocytes(counted: 6, examined: 500, hematocrit: 45, rbc: 4.5),
      );
      expect(r.percent, closeTo(1.2, 1e-12));
      expect(r.absolute, closeTo(54, 1e-9));
      expect(r.corrected, closeTo(1.2, 1e-12));
      expect(r.maturation, 1.0);
      expect(r.rpi, closeTo(1.2, 1e-12));
    });

    test('tuzatish va RPI: 6 %, Ht 25 → 3,33 %, koeff. 2,0 → 1,67', () {
      final r = ok(reticulocytes(counted: 60, examined: 1000, hematocrit: 25));
      expect(r.corrected, closeTo(6 * 25 / 45, 1e-12));
      expect(r.maturation, 2.0);
      expect(r.maturationSuggested, isTrue);
      expect(r.rpi, closeTo(6 * 25 / 45 / 2, 1e-12));
      expect(r.absolute, isNull);
    });

    test('tanlangan koeffitsiyent ustuvor', () {
      final r = ok(
        reticulocytes(
          counted: 60,
          examined: 1000,
          hematocrit: 25,
          maturation: 2.5,
        ),
      );
      expect(r.maturation, 2.5);
      expect(r.maturationSuggested, isFalse);
    });

    test('eng yaqin jadval nuqtasi; tenglikda kattasi', () {
      expect(suggestedMaturation(44), 1.0);
      expect(suggestedMaturation(40), 1.5); // 45 va 35 dan teng — kattasi
      expect(suggestedMaturation(36), 1.5);
      expect(suggestedMaturation(30), 2.0);
      expect(suggestedMaturation(22.5), 2.5);
      expect(suggestedMaturation(12), 2.5);
      expect(suggestedMaturation(52), 1.0);
    });

    test('noto‘g‘ri kirishlar', () {
      expect(
        fail(reticulocytes(counted: 600, examined: 500, hematocrit: 40)).issue,
        ManualIssue.inconsistent,
      );
      expect(
        fail(reticulocytes(counted: 6, examined: 50, hematocrit: 40)).field,
        ManualField.rbcExamined,
      );
      expect(
        fail(reticulocytes(counted: 6, examined: 500, hematocrit: 0.4)).field,
        ManualField.hematocrit,
      );
      expect(
        fail(
          reticulocytes(counted: 6, examined: 500, hematocrit: 40, rbc: 4500),
        ).field,
        ManualField.rbcCount,
      );
    });
  });

  group('Light mezonlari', () {
    test('oqsil nisbati > 0,5 → ekssudat', () {
      final r = ok(
        lightCriteria(
          pfProtein: 40,
          serumProtein: 70,
          pfLdh: 100,
          serumLdh: 300,
        ),
      );
      expect(r.proteinMet, isTrue);
      expect(r.ldhRatioMet, isFalse);
      expect(r.verdict, LightVerdict.exudate);
    });

    test('chegaraviy 0,5 va 0,6 — bajarilmagan (qat’iy “>”)', () {
      final r = ok(
        lightCriteria(
          pfProtein: 35,
          serumProtein: 70,
          pfLdh: 120,
          serumLdh: 200,
          ldhUln: 300,
        ),
      );
      expect(r.proteinMet, isFalse);
      expect(r.ldhRatioMet, isFalse);
      expect(r.ldhUlnMet, isFalse); // 120/300 = 0,4
      expect(r.verdict, LightVerdict.transudate);
    });

    test('ULN yo‘q va ikki mezon bajarilmagan → to‘liq emas', () {
      final r = ok(
        lightCriteria(
          pfProtein: 20,
          serumProtein: 70,
          pfLdh: 80,
          serumLdh: 200,
        ),
      );
      expect(r.ldhUlnMet, isNull);
      expect(r.verdict, LightVerdict.incomplete);
    });

    test('faqat uchinchi mezon → ekssudat', () {
      final r = ok(
        lightCriteria(
          pfProtein: 20,
          serumProtein: 70,
          pfLdh: 210,
          serumLdh: 400,
          ldhUln: 300,
        ),
      );
      expect(r.ldhUlnMet, isTrue);
      expect(r.verdict, LightVerdict.exudate);
    });

    test('zardob qiymati nol → xato', () {
      expect(
        fail(
          lightCriteria(
            pfProtein: 20,
            serumProtein: 0,
            pfLdh: 80,
            serumLdh: 200,
          ),
        ).field,
        ManualField.serumProtein,
      );
    });
  });

  test('har kalkulyatorda formula va manba bor', () {
    for (final c in ManualCalc.values) {
      final info = manualCalcInfo[c]!;
      expect(info.formula, isNotEmpty, reason: c.name);
      expect(info.refs, isNotEmpty, reason: c.name);
      for (final x in [...info.formula, ...info.limitations]) {
        for (final lang in ['uz', 'ru', 'en']) {
          expect(x.of(lang), isNotEmpty, reason: '${c.name} $lang');
        }
      }
    }
  });
}
