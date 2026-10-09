// Nechiporenko, Kakovskiy–Addis, Zimnitskiy — MDH klassik usullari
// (Lyubina 1984, 16–17, 42–44-betlar; Aripova 2007, 98–100-betlar).
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/tools/calc_info.dart';
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
  group('Nechiporenko', () {
    test('Aripova misoli: 100 katta kvadrat, 1 ml cho‘kma, 10 ml → A × 250 '
        '(1 ml siydikda, “1 litr” emas)', () {
      final r = ok(
        nechiporenko(
          counts: {ManualField.urineLeuko: 8, ManualField.urineEry: 2},
          chamberVolume: 0.4,
          sedimentMl: 1,
          urineMl: 10,
        ),
      );
      expect(r.values[ManualField.urineLeuko], closeTo(2000, 1e-9));
      expect(r.values[ManualField.urineEry], closeTo(500, 1e-9));
      expect(r.perMicroLitre[ManualField.urineLeuko], closeTo(20, 1e-9));
    });

    test('Lyubina: x = A ÷ 0,9; N = x × 500 ÷ V', () {
      final r = ok(
        nechiporenko(
          counts: {ManualField.urineLeuko: 9},
          chamberVolume: 0.9,
          sedimentMl: 0.5,
          urineMl: 10,
        ),
      );
      expect(r.values[ManualField.urineLeuko], closeTo(500, 1e-9));
    });

    test('xatolar: bo‘sh, kasr, cho‘kma ≥ siydik', () {
      expect(
        fail(
          nechiporenko(
            counts: const {},
            chamberVolume: 0.9,
            sedimentMl: 1,
            urineMl: 10,
          ),
        ).issue,
        ManualIssue.missing,
      );
      expect(
        fail(
          nechiporenko(
            counts: {ManualField.urineEry: 2.5},
            chamberVolume: 0.9,
            sedimentMl: 1,
            urineMl: 10,
          ),
        ).field,
        ManualField.urineEry,
      );
      final f = fail(
        nechiporenko(
          counts: {ManualField.urineLeuko: 3},
          chamberVolume: 0.9,
          sedimentMl: 1,
          urineMl: 1,
        ),
      );
      expect(f.issue, ManualIssue.inconsistent);
      expect(f.field, ManualField.urineCentrifuged);
    });
  });

  group('Kakovskiy–Addis', () {
    test('0,5 ml cho‘kma → x × 60 000; 1 ml → x × 120 000', () {
      final half = ok(
        addisKakovsky(
          counts: {ManualField.urineLeuko: 9},
          chamberVolume: 0.9,
          sedimentMl: 0.5,
        ),
      );
      expect(half.values[ManualField.urineLeuko], closeTo(600000, 1e-6));
      expect(half.portionMl, isNull);
      final one = ok(
        addisKakovsky(
          counts: {ManualField.urineCasts: 9},
          chamberVolume: 0.9,
          sedimentMl: 1,
        ),
      );
      expect(one.values[ManualField.urineCasts], closeTo(1200000, 1e-6));
    });

    test('12 daqiqalik hajm: v ÷ (t × 5)', () {
      expect(ok(addisPortion(collectedMl: 600, hours: 10)), closeTo(12, 1e-9));
      final r = ok(
        addisKakovsky(
          counts: {ManualField.urineEry: 1},
          chamberVolume: 3.2,
          sedimentMl: 1,
          collectedMl: 720,
          hours: 12,
        ),
      );
      expect(r.portionMl, closeTo(12, 1e-9));
      // Faqat vaqt berilsa — hajm so'raladi.
      expect(
        fail(
          addisKakovsky(
            counts: {ManualField.urineEry: 1},
            chamberVolume: 0.9,
            sedimentMl: 1,
            hours: 12,
          ),
        ).field,
        ManualField.collectedVolume,
      );
    });
  });

  group('Zimnitskiy', () {
    // Lyubina 1984, 2-jadval, 1-misol (kunduzgi 760 ml).
    const volumes = <double?>[265, 230, 150, 115, 115, 35, 60, 40];
    const sgs = <double?>[1014, 1012, 1015, 1018, 1023, 1021, 1018, 1020];

    test('kunduzgi / tungi / sutkalik, zichlik amplitudasi', () {
      final r = ok(zimnitsky(volumes: volumes, sgs: sgs, intake: 1400));
      expect(r.day, 760);
      expect(r.night, 250);
      expect(r.total, 1010);
      expect(r.dayNightRatio, closeTo(3.04, 1e-9));
      expect(r.intakePercent, closeTo(72.142857, 1e-5));
      expect(r.sgMinValue, closeTo(1.012, 1e-12));
      expect(r.sgMaxValue, closeTo(1.023, 1e-12));
      expect(r.sgAmplitude, closeTo(0.011, 1e-12));
      expect(r.sgCount, 8);
    });

    test('“1,015” va “1015” bir xil; bo‘sh porsiya (0 ml) zichliksiz', () {
      final a = ok(zimnitsky(volumes: volumes, sgs: sgs));
      final b = ok(
        zimnitsky(volumes: volumes, sgs: [for (final s in sgs) s! / 1000]),
      );
      expect(a.sgAmplitude, closeTo(b.sgAmplitude, 1e-12));
      expect(a.intakePercent, isNull);
      final c = ok(
        zimnitsky(
          volumes: [...volumes.take(7), 0],
          sgs: [...sgs.take(7), null],
        ),
      );
      expect(c.sgCount, 7);
      expect(c.night, 210);
    });

    test('xatolar: zichlik shkaladan tashqari, hajm yo‘q, hammasi 0', () {
      expect(
        fail(zimnitsky(volumes: volumes, sgs: [1.2, ...sgs.skip(1)])).field,
        ManualField.sg1,
      );
      expect(
        fail(zimnitsky(volumes: [null, ...volumes.skip(1)], sgs: sgs)).field,
        ManualField.portion1,
      );
      expect(
        fail(zimnitsky(volumes: List.filled(8, 0), sgs: List.filled(8, null)))
            .issue,
        ManualIssue.inconsistent,
      );
    });
  });

  test('klassik usullar: belgilangan, manbali, oraliqlar uch tilda', () {
    for (final c in classicManualCalcs) {
      final info = manualCalcInfo[c]!;
      expect(
        info.refs.map((r) => r.source.id),
        contains(CalcSources.lyubina1984.id),
      );
      expect(
        info.refs.map((r) => r.source.id),
        contains(CalcSources.aripova2007.id),
      );
      final ranges = classicRanges[c]!;
      expect(ranges, isNotEmpty);
      for (final r in ranges) {
        // Oraliq manbasi kalkulyator manbalari ro'yxatida.
        expect(
          info.refs.any((x) => x.source.id == r.ref.source.id),
          isTrue,
          reason: c.name,
        );
        for (final lang in ['uz', 'ru', 'en']) {
          expect(r.label.of(lang), isNotEmpty);
          expect(r.value.of(lang), isNotEmpty);
        }
        expect(r.label.of('uz').contains("'"), isFalse);
        expect(r.value.of('uz').contains("'"), isFalse);
      }
    }
    // Birlik xatosi tuzatilgani cheklovlarda aytilgan.
    expect(
      manualCalcInfo[ManualCalc.nechiporenko]!.limitations.any(
        (x) => x.of('en').contains('per litre'),
      ),
      isTrue,
    );
  });
}
