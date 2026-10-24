// Reja ↔ imkoniyat matritsasi (D-74 → D-76, egasi qarori): ilova nusxasi
// server ma'lumoti (cloudflare/src/tiers.ts `TIER_CAPABILITIES`) bilan bir
// xil; matritsa zinapoya emas (Mutaxassis ustoz panelini, Ustoz Lab'ni
// ochmaydi; Premium — hammasi); hozir hech narsa yopilmagan.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/core/entitlements/plan_matrix.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';

/// Server `TIER_CAPABILITIES` (tiers.ts) — fayldan o'qiladi.
Map<String, Set<String>> _serverMatrix() {
  final src = File('cloudflare/src/tiers.ts').readAsStringSync();
  final block = RegExp(r'TIER_CAPABILITIES[^=]*=\s*\{([^}]*)\}')
      .firstMatch(src)!
      .group(1)!;
  return {
    for (final m in RegExp(r'(\w+):\s*\[([^\]]*)\]').allMatches(block))
      m.group(1)!: {
        for (final c in RegExp(r"'(\w+)'").allMatches(m.group(2)!)) c.group(1)!,
      },
  };
}

void main() {
  test('server TIER_CAPABILITIES bilan bir xil (paritet)', () {
    expect(_serverMatrix(), {
      for (final e in PlanMatrix.capabilities.entries)
        e.key.wire: {for (final c in e.value) c.wire},
    });
    // Imkoniyat nomlari ham bir xil.
    final src = File('cloudflare/src/tiers.ts').readAsStringSync();
    final caps = RegExp(r'CAPABILITIES: readonly Capability\[\] = \[([^\]]*)\]')
        .firstMatch(src)!
        .group(1)!;
    expect(
      [for (final m in RegExp(r"'(\w+)'").allMatches(caps)) m.group(1)],
      [for (final c in ProCapability.values) c.wire],
    );
    // Rejalar ham (billing.ts `Plan`).
    final billing = File('cloudflare/src/billing.ts').readAsStringSync();
    final plans = RegExp(r'export type Plan = ([^;]*);').firstMatch(billing)!;
    expect(
      [for (final m in RegExp(r"'(\w+)'").allMatches(plans.group(1)!)) m[1]],
      [for (final p in ProPlan.values) p.wire],
    );
  });

  test('egasi matritsasi (D-76): har reja × imkoniyat ruxsat / rad', () {
    const want = {
      ProPlan.student: {ProCapability.learner},
      ProPlan.teacher: {ProCapability.learner, ProCapability.teacherPanel},
      ProPlan.specialist: {ProCapability.learner, ProCapability.lab},
      ProPlan.premium: {
        ProCapability.learner,
        ProCapability.teacherPanel,
        ProCapability.lab,
      },
    };
    for (final plan in ProPlan.values) {
      for (final c in ProCapability.values) {
        expect(
          PlanMatrix.allows(plan, c),
          want[plan]!.contains(c),
          reason: '${plan.name} × ${c.name}',
        );
        expect(plan.tier.allows(c), want[plan]!.contains(c));
      }
    }
    for (final c in ProCapability.values) {
      expect(PlanMatrix.allows(null, c), isFalse);
    }
  });

  test('aniq qoidalar: Talaba Lab’siz; Mutaxassis ustoz panelisiz; Ustoz '
      'Lab’siz; Premium hammasi', () {
    expect(PlanMatrix.allows(ProPlan.student, ProCapability.lab), isFalse);
    expect(
      PlanMatrix.allows(ProPlan.student, ProCapability.teacherPanel),
      isFalse,
    );
    expect(
      PlanMatrix.allows(ProPlan.specialist, ProCapability.teacherPanel),
      isFalse,
      reason: 'eski "Mutaxassis Ustozni qamraydi" qoidasi bekor',
    );
    expect(PlanMatrix.allows(ProPlan.specialist, ProCapability.lab), isTrue);
    expect(PlanMatrix.allows(ProPlan.teacher, ProCapability.lab), isFalse);
    expect(
      PlanMatrix.allows(ProPlan.teacher, ProCapability.teacherPanel),
      isTrue,
    );
    for (final c in ProCapability.values) {
      expect(PlanMatrix.allows(ProPlan.premium, c), isTrue);
    }
    // Funksiya darajasida ham.
    expect(ProPlan.specialist.tier.covers(Feature.groups), isFalse);
    expect(ProPlan.specialist.tier.covers(Feature.leukocyteCounter), isTrue);
    expect(ProPlan.teacher.tier.covers(Feature.leukocyteCounter), isFalse);
    expect(ProPlan.student.tier.covers(Feature.calibration), isFalse);
    expect(ProPlan.premium.tier.covers(Feature.assignments), isTrue);
  });

  test('ProTier — to‘plam (zinapoya emas), birlashma', () {
    expect(ProTier.free.isFree, isTrue);
    expect(ProTier.free.covers(Feature.basicGuides), isTrue);
    expect(ProTier.free.covers(Feature.examSimulation), isFalse);
    final both = ProPlan.teacher.tier | ProPlan.specialist.tier;
    expect(both, ProPlan.premium.tier);
    expect(ProTier.all, ProPlan.premium.tier);
    // Mutaxassis Ustozni ham, Ustoz Mutaxassisni ham "qamramaydi".
    expect(
      ProPlan.teacher.tier.capabilities.containsAll(
        ProPlan.specialist.tier.capabilities,
      ),
      isFalse,
    );
    expect(
      ProPlan.specialist.tier.capabilities.containsAll(
        ProPlan.teacher.tier.capabilities,
      ),
      isFalse,
    );
  });

  test('har pullik funksiya bitta toifada; Lab funksiyalari — lab', () {
    for (final f in Feature.values) {
      expect(PlanMatrix.of(f), f.capability);
      expect(f.pro, f.capability != null, reason: f.name);
    }
    for (final f in ProGatePolicy.plannedLabGate) {
      expect(f.capability, ProCapability.lab, reason: f.name);
    }
    expect(Feature.leukocyteCounter.capability, ProCapability.lab);
    expect(Feature.basicGuides.capability, isNull);
    expect(Feature.groups.capability, ProCapability.teacherPanel);
    expect(Feature.examSimulation.capability, ProCapability.learner);
  });

  test('hozir hech narsa yopilmagan: hech bir reja hech narsa “ochmaydi”', () {
    expect(ProGatePolicy.gated, isEmpty);
    expect(
      ProGatePolicy.gated.intersection(ProGatePolicy.plannedLabGate),
      isEmpty,
      reason: 'Lab yopilishi faqat REJA (faol emas)',
    );
    for (final plan in ProPlan.values) {
      expect(PlanMatrix.unlockedBy(plan), isEmpty);
    }
  });

  test('kelajakda yopilsa: reja faqat o‘z to‘plamidagini ochadi', () {
    const gated = {
      Feature.examSimulation,
      Feature.assignments,
      Feature.leukocyteCounter,
    };
    expect(PlanMatrix.unlockedBy(ProPlan.student, gated: gated), [
      Feature.examSimulation,
    ]);
    expect(PlanMatrix.unlockedBy(ProPlan.teacher, gated: gated), [
      Feature.examSimulation,
      Feature.assignments,
    ]);
    expect(PlanMatrix.unlockedBy(ProPlan.specialist, gated: gated), [
      Feature.examSimulation,
      Feature.leukocyteCounter,
    ]);
    expect(
      PlanMatrix.unlockedBy(ProPlan.premium, gated: gated),
      containsAll(gated),
    );
  });
}
