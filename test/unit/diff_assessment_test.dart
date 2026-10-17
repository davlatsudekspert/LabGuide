import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/differential/diff_assessment.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/differential/differential_controller.dart';
import 'package:labguide/features/differential/differential_sources.dart';

DiffRecord _rec(Map<DiffCell, int> counts, {double? wbc}) => DiffRecord(
  id: 'x',
  savedAt: DateTime.utc(2026, 10, 17),
  target: 100,
  counts: counts,
  wbc: wbc,
);

DiffMeasureResult _of(DiffAssessment a, DiffMeasure m) =>
    a.results.firstWhere((r) => r.measure == m);

void main() {
  const normal = {
    DiffCell.segmented: 58,
    DiffCell.band: 2,
    DiffCell.lymphocyte: 30,
    DiffCell.monocyte: 6,
    DiffCell.eosinophil: 3,
    DiffCell.basophil: 1,
  };

  test('me’yordagi natija: belgi yo‘q, yo‘llash yo‘q', () {
    final a = assessDifferential(_rec(normal, wbc: 6));
    expect(a.flagged, isEmpty);
    expect(a.refer, isFalse);
    expect(a.needsWbc, isFalse);
    expect(a.results, hasLength(DiffMeasure.values.length));
    // Neytrofillar jami = segment + tayoqcha: 60 % × 6 = 3,6.
    expect(_of(a, DiffMeasure.neutrophils).value, closeTo(3.6, 1e-9));
  });

  test('foiz emas, mutlaq son: WBC 0,5 da 90 % neytrofil — neytropeniya', () {
    final a = assessDifferential(
      _rec({DiffCell.segmented: 90, DiffCell.lymphocyte: 10}, wbc: 0.5),
    );
    final n = _of(a, DiffMeasure.neutrophils);
    expect(n.flag, DiffFlag.low);
    expect(n.findingId, 'neutropenia');
    expect(n.finding, isNotNull);
    // 0,45 < 0,5 — og'ir neytropeniya: yo'llash.
    expect(a.refer, isTrue);
    expect(_of(a, DiffMeasure.lymphocytes).flag, DiffFlag.low);
  });

  test('WBC yo‘q: faqat tayoqchalar foizi baholanadi', () {
    final a = assessDifferential(
      _rec({DiffCell.segmented: 80, DiffCell.band: 20}),
    );
    expect(a.needsWbc, isTrue);
    expect(a.results.single.measure, DiffMeasure.bandsPercent);
    expect(a.results.single.findingId, 'left-shift');
  });

  test('“boshqa” hujayra va yaqqol eozinofiliya — yo‘llash', () {
    expect(
      assessDifferential(_rec({...normal, DiffCell.other: 1})).refer,
      isTrue,
    );
    final eo = assessDifferential(
      _rec({
        DiffCell.segmented: 60,
        DiffCell.eosinophil: 20,
        DiffCell.lymphocyte: 20,
      }, wbc: 10),
    );
    expect(_of(eo, DiffMeasure.eosinophils).findingId, 'eosinophilia');
    expect(eo.refer, isTrue);
  });

  test('chegara: ekranda ko‘rinadigan yaxlitlangan qiymat bo‘yicha', () {
    // 7,25 aynan yuqori chegara — me'yorda.
    final a = assessDifferential(
      _rec({DiffCell.segmented: 725, DiffCell.lymphocyte: 275}, wbc: 10),
    );
    expect(_of(a, DiffMeasure.neutrophils).flag, isNull);
  });

  test('tugallanmagan sanash baholanmaydi (audit #3)', () {
    // Bitta "tayoqcha" bosilgan: 100 % tayoqcha — lekin sanash tugamagan.
    final one = assessDifferential(_rec({DiffCell.band: 1}, wbc: 6));
    expect(one.incomplete, isTrue);
    expect(one.results, isEmpty);
    expect(one.flagged, isEmpty);
    expect(one.refer, isFalse);
    expect(one.allNormal, isFalse);
    expect((one.counted, one.target), (1, 100));
    // 99 / 100 — hali ham baho yo'q.
    final almost = assessDifferential(
      _rec({DiffCell.segmented: 60, DiffCell.lymphocyte: 39}, wbc: 6),
    );
    expect(almost.incomplete, isTrue);
    expect(almost.results, isEmpty);
    // Blast ulushga bog'liq emas: tugallanmagan sanashda ham yo'llash.
    final blast = assessDifferential(
      _rec({DiffCell.segmented: 4, DiffCell.other: 1}),
    );
    expect(blast.incomplete, isTrue);
    expect(blast.refer, isTrue);
    // 200 lik maqsad: 100 ta sanalganda hali tugallanmagan.
    final r200 = DiffRecord(
      id: 'x',
      savedAt: DateTime.utc(2026, 10, 17),
      target: 200,
      counts: normal,
      wbc: 6,
    );
    expect(assessDifferential(r200).incomplete, isTrue);
    // Aynan maqsadga yetganda — baho bor.
    expect(assessDifferential(_rec(normal, wbc: 6)).incomplete, isFalse);
  });

  test('yo‘llash va “hammasi me’yorda” birga chiqmaydi (audit #4)', () {
    final a = assessDifferential(_rec({...normal, DiffCell.other: 1}, wbc: 6));
    expect(a.refer, isTrue);
    expect(a.flagged, isEmpty);
    expect(a.allNormal, isFalse);
    expect(assessDifferential(_rec(normal, wbc: 6)).allNormal, isTrue);
    // WBC yo'q — "hammasi me'yorda" aytilmaydi.
    expect(assessDifferential(_rec(normal)).allNormal, isFalse);
  });

  test('0,5 yo‘llash chegarasi ekrandagi yaxlitlangan qiymat bo‘yicha '
      '(audit #13)', () {
    // 497/1000 × 1,0 = 0,497 → ekranda 0,50: "< 0,5" emas.
    final shownHalf = assessDifferential(
      _rec({DiffCell.segmented: 497, DiffCell.lymphocyte: 503}, wbc: 1),
    );
    expect(_of(shownHalf, DiffMeasure.neutrophils).flag, DiffFlag.low);
    expect(shownHalf.refer, isFalse);
    // 494/1000 → 0,49 — og'ir neytropeniya, yo'llash.
    final below = assessDifferential(
      _rec({DiffCell.segmented: 494, DiffCell.lymphocyte: 506}, wbc: 1),
    );
    expect(below.refer, isTrue);
    // Eozinofillar: 1,504 → ekranda 1,50 — "> 1,5" emas.
    final eo = assessDifferential(
      _rec({DiffCell.segmented: 812, DiffCell.eosinophil: 188}, wbc: 8),
    );
    expect(_of(eo, DiffMeasure.eosinophils).value, closeTo(1.504, 1e-9));
    expect(eo.refer, isFalse);
  });

  test('Harrison nashri va MSD farqlari ko‘rsatilgan (audit #14)', () {
    expect(DiffSources.harrisonManual.citation, contains('20th ed.'));
    expect(DiffSources.harrisonManual.citation, contains('Table 64-1'));
    expect(diffDefaultLimitsRef.locator, contains('20th ed., Table 64-1'));
    expect(DiffSources.all, contains(DiffSources.msdLymphocytopenia));
    expect(diffLymphocytopeniaRef.locator, contains('< 1000/mcL'));
    expect(diffEosinophiliaRef.locator, contains('> 500/mcL'));
  });

  test('blanka me’yorlari saqlanadi, noto‘g‘risi e’tiborsiz', () async {
    final store = MemoryKeyValueStore();
    final c = DifferentialController(store);
    await c.setLimit(
      DiffMeasure.lymphocytes,
      const DiffLimit(low: 1.2, high: 3.0),
    );
    final again = DifferentialController(store);
    expect(again.limits[DiffMeasure.lymphocytes]!.high, 3.0);
    expect(
      again.limits[DiffMeasure.neutrophils],
      diffDefaultLimits[DiffMeasure.neutrophils],
    );
    final a = assessDifferential(
      _rec({DiffCell.segmented: 60, DiffCell.lymphocyte: 40}, wbc: 8),
      again.limits,
    );
    expect(_of(a, DiffMeasure.lymphocytes).flag, DiffFlag.high);
    await again.resetLimits();
    expect(again.limits, diffDefaultLimits);
    expect(
      decodeDiffLimits('{"lymphocytes":{"low":5,"high":1}}'),
      diffDefaultLimits,
    );
    expect(decodeDiffLimits('not json'), diffDefaultLimits);
  });
}
