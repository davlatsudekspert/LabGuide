import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/coagulogram/coag_content.dart';
import 'package:labguide/features/coagulogram/coag_logic.dart';

/// Mustaqil ta'rif (Toh 2016, Iba 2019 jadvallari) — mantiq bilan
/// solishtirish uchun.
int _expected(double plt, CgFrm frm, double pt, double fib) {
  final p = plt < 50 ? 2 : (plt < 100 ? 1 : 0);
  final f = {CgFrm.none: 0, CgFrm.moderate: 2, CgFrm.strong: 3}[frm]!;
  final t = pt >= 6 ? 2 : (pt >= 3 ? 1 : 0);
  final g = fib < 1 ? 1 : 0;
  return p + f + t + g;
}

void main() {
  group('ISTH DIC bali: chegaralar', () {
    test('trombotsit: 100 → 0, 99.9 → 1, 50 → 1, 49.9 → 2, 0 → 2', () {
      expect(dicPlateletPoints(250), 0);
      expect(dicPlateletPoints(100), 0);
      expect(dicPlateletPoints(99.9), 1);
      expect(dicPlateletPoints(50), 1);
      expect(dicPlateletPoints(49.9), 2);
      expect(dicPlateletPoints(0), 2);
    });

    test('fibrin bilan bog‘liq marker: 0 / 2 / 3', () {
      expect(dicFrmPoints(CgFrm.none), 0);
      expect(dicFrmPoints(CgFrm.moderate), 2);
      expect(dicFrmPoints(CgFrm.strong), 3);
    });

    test('PT uzayishi: 2.99 → 0, 3 → 1, 5.99 → 1, 6 → 2', () {
      expect(dicPtPoints(0), 0);
      expect(dicPtPoints(2.99), 0);
      expect(dicPtPoints(3), 1);
      expect(dicPtPoints(5.99), 1);
      expect(dicPtPoints(6), 2);
      expect(dicPtPoints(20), 2);
    });

    test('fibrinogen: 1.0 → 0, 0.99 → 1', () {
      expect(dicFibrinogenPoints(3), 0);
      expect(dicFibrinogenPoints(1), 0);
      expect(dicFibrinogenPoints(0.99), 1);
      expect(dicFibrinogenPoints(0), 1);
    });
  });

  group('ISTH DIC bali: jami va talqin', () {
    test('minimal 0, maksimal 8', () {
      final min = dicScore(
        plateletsE9: 300,
        frm: CgFrm.none,
        ptProlongationSeconds: 0,
        fibrinogenGPerL: 3,
      )!;
      expect(min.total, 0);
      expect(min.compatibleWithOvert, false);
      final max = dicScore(
        plateletsE9: 10,
        frm: CgFrm.strong,
        ptProlongationSeconds: 10,
        fibrinogenGPerL: 0.5,
      )!;
      expect(max.total, 8);
      expect(max.compatibleWithOvert, true);
    });

    test('5 — ochiq DIC bilan mos (≥ 5), 4 — mos emas', () {
      // 1 (trombotsit 80) + 2 (o'rtacha) + 1 (PT 3 s) + 1 (fibrinogen 0,9) = 5.
      final five = dicScore(
        plateletsE9: 80,
        frm: CgFrm.moderate,
        ptProlongationSeconds: 3,
        fibrinogenGPerL: 0.9,
      )!;
      expect(five.total, 5);
      expect(five.compatibleWithOvert, true);
      // Xuddi shu, fibrinogen 1,0 → 4.
      final four = dicScore(
        plateletsE9: 80,
        frm: CgFrm.moderate,
        ptProlongationSeconds: 3,
        fibrinogenGPerL: 1.0,
      )!;
      expect(four.total, 4);
      expect(four.compatibleWithOvert, false);
      expect(dicOvertCutoff, 5);
    });

    test('noto‘g‘ri kiritma → null', () {
      expect(
        dicScore(
          plateletsE9: null,
          frm: CgFrm.none,
          ptProlongationSeconds: 0,
          fibrinogenGPerL: 1,
        ),
        isNull,
      );
      expect(
        dicScore(
          plateletsE9: 100,
          frm: null,
          ptProlongationSeconds: 0,
          fibrinogenGPerL: 1,
        ),
        isNull,
      );
      expect(
        dicScore(
          plateletsE9: -1,
          frm: CgFrm.none,
          ptProlongationSeconds: 0,
          fibrinogenGPerL: 1,
        ),
        isNull,
      );
      expect(
        dicScore(
          plateletsE9: 100,
          frm: CgFrm.none,
          ptProlongationSeconds: double.nan,
          fibrinogenGPerL: 1,
        ),
        isNull,
      );
      expect(
        dicScore(
          plateletsE9: 100,
          frm: CgFrm.none,
          ptProlongationSeconds: 0,
          fibrinogenGPerL: double.infinity,
        ),
        isNull,
      );
    });

    test('to‘r bo‘yicha mustaqil ta’rifga mos', () {
      const plts = <double>[0, 20, 49.9, 50, 75, 99.9, 100, 150];
      const pts = <double>[0, 1, 2.99, 3, 4.5, 5.99, 6, 12];
      const fibs = <double>[0, 0.5, 0.99, 1, 1.5, 4];
      for (final plt in plts) {
        for (final frm in CgFrm.values) {
          for (final pt in pts) {
            for (final fib in fibs) {
              final s = dicScore(
                plateletsE9: plt,
                frm: frm,
                ptProlongationSeconds: pt,
                fibrinogenGPerL: fib,
              )!;
              final e = _expected(plt, frm, pt, fib);
              expect(s.total, e, reason: '$plt $frm $pt $fib');
              expect(s.compatibleWithOvert, e >= 5);
            }
          }
        }
      }
    });
  });

  group('PT/APTT birikmasi', () {
    test('to‘rt holat', () {
      expect(
        cgPattern(ptProlonged: true, apttProlonged: false),
        CgPattern.ptOnly,
      );
      expect(
        cgPattern(ptProlonged: false, apttProlonged: true),
        CgPattern.apttOnly,
      );
      expect(cgPattern(ptProlonged: true, apttProlonged: true), CgPattern.both);
      expect(
        cgPattern(ptProlonged: false, apttProlonged: false),
        CgPattern.normal,
      );
    });
  });

  group('sitrat (gematokrit > 55 %)', () {
    test('manbadagi misol: Ht 70 %, 4,5 ml → ≈ 0,25 ml', () {
      final c = citrateVolumeMl(hctPercent: 70, bloodMl: 4.5)!;
      expect(c, closeTo(0.24975, 1e-9));
      expect(c.toStringAsFixed(2), '0.25');
    });

    test('Ht 45 % → 0,5 ml (9:1 ga yaqin)', () {
      expect(
        citrateVolumeMl(hctPercent: 45, bloodMl: 4.5),
        closeTo(0.457875, 1e-9),
      );
    });

    test('chegaradan tashqari → null', () {
      expect(citrateVolumeMl(hctPercent: 0, bloodMl: 4.5), isNull);
      expect(citrateVolumeMl(hctPercent: 100, bloodMl: 4.5), isNull);
      expect(citrateVolumeMl(hctPercent: 60, bloodMl: 0), isNull);
      expect(citrateVolumeMl(hctPercent: double.nan, bloodMl: 4.5), isNull);
      expect(citrateHctThreshold, 55);
    });
  });

  test('son kiritish: vergul va nuqta', () {
    expect(cgParse('4,5'), 4.5);
    expect(cgParse(' 70 '), 70);
    expect(cgParse(''), isNull);
    expect(cgParse('abc'), isNull);
  });
}
