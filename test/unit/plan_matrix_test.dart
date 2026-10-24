// Reja ↔ panel matritsasi (D-74): ilova nusxasi server ma'lumoti
// (cloudflare/src/tiers.ts `TIER_CAPABILITIES`) bilan bir xil; Talaba rejasi
// ustoz paneli imkoniyatini ochmaydi; hozir hech narsa yopilmagan.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/core/entitlements/plan_matrix.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';

void main() {
  test('server TIER_CAPABILITIES bilan bir xil', () {
    final src = File('cloudflare/src/tiers.ts').readAsStringSync();
    final block = RegExp(r'TIER_CAPABILITIES[^=]*=\s*\{([^}]*)\}')
        .firstMatch(src)!
        .group(1)!;
    final server = <String, Set<String>>{
      for (final m in RegExp(r'(\w+):\s*\[([^\]]*)\]').allMatches(block))
        m.group(1)!: {
          for (final c in RegExp(r"'(\w+)'").allMatches(m.group(2)!))
            c.group(1)!,
        },
    };
    expect(server, {
      for (final e in PlanMatrix.capabilities.entries)
        e.key.wire: {for (final c in e.value) c.wire},
    });
  });

  test('Talaba ustoz paneli va mutaxassis imkoniyatini ochmaydi', () {
    expect(PlanMatrix.allows(ProPlan.student, ProCapability.learner), isTrue);
    expect(
      PlanMatrix.allows(ProPlan.student, ProCapability.teacherPanel),
      isFalse,
    );
    expect(
      PlanMatrix.allows(ProPlan.student, ProCapability.specialist),
      isFalse,
    );
    expect(
      PlanMatrix.allows(ProPlan.teacher, ProCapability.teacherPanel),
      isTrue,
    );
    expect(
      PlanMatrix.allows(ProPlan.teacher, ProCapability.specialist),
      isFalse,
    );
    for (final c in ProCapability.values) {
      expect(PlanMatrix.allows(ProPlan.specialist, c), isTrue);
      expect(PlanMatrix.allows(null, c), isFalse);
    }
  });

  test('matritsa ProPlan.tier moslashi bilan mos (EntitlementService.can)', () {
    for (final plan in ProPlan.values) {
      for (final f in Feature.values.where((f) => f.pro)) {
        expect(
          PlanMatrix.allows(plan, ProCapability.of(f)),
          plan.tier.covers(f.tier),
          reason: '${plan.name} × ${f.name}',
        );
      }
    }
    expect(ProCapability.of(Feature.leukocyteCounter), isNull);
  });

  test('hozir hech narsa yopilmagan: hech bir reja hech narsa “ochmaydi”', () {
    expect(ProGatePolicy.gated, isEmpty);
    for (final plan in ProPlan.values) {
      expect(PlanMatrix.unlockedBy(plan), isEmpty);
    }
  });

  test('kelajakda yopilsa: daraja faqat o‘z to‘plamidagini ochadi', () {
    const gated = {Feature.examSimulation, Feature.assignments};
    expect(PlanMatrix.unlockedBy(ProPlan.student, gated: gated), [
      Feature.examSimulation,
    ]);
    expect(
      PlanMatrix.unlockedBy(ProPlan.teacher, gated: gated),
      containsAll(gated),
    );
  });
}
