import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/differential/diff_assessment.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/differential/differential_controller.dart';

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
      _rec({DiffCell.segmented: 60, DiffCell.eosinophil: 20,
          DiffCell.lymphocyte: 20}, wbc: 10),
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
