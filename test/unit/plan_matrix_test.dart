// Reja ↔ imkoniyat matritsasi (D-74 → D-76, egasi qarori) va pullik
// funksiyalar katalogi (D-78): ilova nusxasi server ma'lumoti
// (cloudflare/src/tiers.ts `TIER_CAPABILITIES`, `FEATURE_CAPABILITIES`) bilan
// bir xil; matritsa zinapoya emas (Mutaxassis ustoz panelini, Ustoz Lab Pro'ni
// ochmaydi; Premium — hammasi).
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

/// Server `FEATURE_CAPABILITIES` (tiers.ts) — fayldan o'qiladi.
Map<String, String> _serverFeatures() {
  final src = File('cloudflare/src/tiers.ts').readAsStringSync();
  final block = RegExp(r'FEATURE_CAPABILITIES[^=]*=\s*\{([^}]*)\}')
      .firstMatch(src)!
      .group(1)!;
  return {
    for (final m in RegExp(r"(\w+):\s*'(\w+)'").allMatches(block))
      m.group(1)!: m.group(2)!,
  };
}

void main() {
  test('server FEATURE_CAPABILITIES bilan bir xil (D-78 katalog paritet)', () {
    expect(_serverFeatures(), {
      for (final f in Feature.values) f.wire: f.capability.wire,
    });
    // Nomlar takrorlanmaydi.
    expect(
      {for (final f in Feature.values) f.wire},
      hasLength(Feature.values.length),
    );
  });

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
    expect(ProPlan.specialist.tier.covers(Feature.teacherTestBuilder), isFalse);
    expect(ProPlan.specialist.tier.covers(Feature.qcReport), isTrue);
    expect(ProPlan.specialist.tier.covers(Feature.examSimulation), isTrue);
    expect(ProPlan.teacher.tier.covers(Feature.qcReport), isFalse);
    expect(ProPlan.teacher.tier.covers(Feature.resultsAnalytics), isTrue);
    expect(ProPlan.student.tier.covers(Feature.calibrationExport), isFalse);
    expect(ProPlan.student.tier.covers(Feature.teacherResults), isFalse);
    expect(ProPlan.premium.tier.covers(Feature.teacherTestAssign), isTrue);
  });

  test('ProTier — to‘plam (zinapoya emas), birlashma', () {
    expect(ProTier.free.isFree, isTrue);
    expect(ProTier.free.allows(null), isTrue);
    for (final f in Feature.values) {
      expect(ProTier.free.covers(f), isFalse, reason: f.name);
    }
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

  test('D-78 katalog: egasi ro‘yxati bo‘yicha toifalar', () {
    const want = {
      Feature.resultsAnalytics: ProCapability.learner,
      Feature.examSimulation: ProCapability.learner,
      Feature.resultsExport: ProCapability.learner,
      Feature.teacherTests: ProCapability.learner,
      Feature.teacherTestBuilder: ProCapability.teacherPanel,
      Feature.teacherTestAssign: ProCapability.teacherPanel,
      Feature.teacherResults: ProCapability.teacherPanel,
      Feature.calibrationExport: ProCapability.lab,
      Feature.qcReport: ProCapability.lab,
    };
    expect({for (final f in Feature.values) f: f.capability}, want);
    for (final f in Feature.values) {
      expect(PlanMatrix.of(f), f.capability);
    }
    expect(ProGatePolicy.catalog, Feature.values.toSet());
    expect(ProGatePolicy.gated.difference(ProGatePolicy.catalog), isEmpty);
  });

  test('D-78: bugungi bepul funksiyalar katalogda YO‘Q (eski nomlar)', () {
    final names = {for (final f in Feature.values) f.name};
    for (final old in [
      'basicGuides',
      'dailyQuestions',
      'mistakeReview',
      'unlimitedHistory',
      'unlimitedQuestions',
      'fullToifaBank',
      'weakTopics',
      'atlasPractice',
      'groups',
      'assignments',
      'autoPresentation',
      'leukocyteCounter',
      'absoluteCounts',
      'leukocyteEvaluation',
      'labSections',
      'coagulogram',
      'labInstruments',
      'labDirections',
      'calibration',
      'qualityControl',
      'labCalculators',
    ]) {
      expect(names, isNot(contains(old)), reason: old);
    }
  });

  test('reja faqat o‘z to‘plamidagi QURILGAN (gated) funksiyani ochadi', () {
    const gated = {
      Feature.examSimulation,
      Feature.teacherTestAssign,
      Feature.qcReport,
    };
    expect(PlanMatrix.unlockedBy(ProPlan.student, gated: gated), [
      Feature.examSimulation,
    ]);
    expect(PlanMatrix.unlockedBy(ProPlan.teacher, gated: gated), [
      Feature.examSimulation,
      Feature.teacherTestAssign,
    ]);
    expect(PlanMatrix.unlockedBy(ProPlan.specialist, gated: gated), [
      Feature.examSimulation,
      Feature.qcReport,
    ]);
    expect(
      PlanMatrix.unlockedBy(ProPlan.premium, gated: gated),
      containsAll(gated),
    );
    expect(PlanMatrix.unlockedBy(ProPlan.premium, gated: const {}), isEmpty);
  });
}
