import 'feature.dart';
import 'pro_catalog.dart';

export 'feature.dart' show ProCapability, ProTier;

/// Daraja × imkoniyat matritsasi (D-76, egasi qarori; MA'LUMOT, server
/// `cloudflare/src/tiers.ts` `TIER_CAPABILITIES` bilan bir xil — test
/// solishtiradi). Bu ZINAPOYA EMAS, to'plam:
/// * Talaba — o'qish (learner);
/// * Ustoz — Talaba + ustoz paneli (Lab YO'Q);
/// * Mutaxassis — Talaba + professional Lab funksiyalari (ustoz paneli
///   YO'Q; D-73/D-74 dagi "Mutaxassis Ustozni ham qamraydi" qoidasi BEKOR);
/// * Premium — hammasi.
abstract final class PlanMatrix {
  static const capabilities = <ProPlan, Set<ProCapability>>{
    ProPlan.student: {ProCapability.learner},
    ProPlan.teacher: {ProCapability.learner, ProCapability.teacherPanel},
    ProPlan.specialist: {ProCapability.learner, ProCapability.lab},
    ProPlan.premium: {
      ProCapability.learner,
      ProCapability.teacherPanel,
      ProCapability.lab,
    },
  };

  /// [feature] qaysi toifaga tegishli (katalogda faqat pullik funksiyalar).
  static ProCapability of(Feature feature) => feature.capability;

  static bool allows(ProPlan? plan, ProCapability? capability) =>
      plan != null &&
      capability != null &&
      capabilities[plan]!.contains(capability);

  /// [plan] HAQIQATAN ochadigan pullik funksiyalar: faqat [gated] dagilar
  /// (standart — bo'sh, ya'ni hamma narsa bepul va hech narsa va'da
  /// qilinmaydi).
  static List<Feature> unlockedBy(
    ProPlan plan, {
    Set<Feature> gated = ProGatePolicy.gated,
  }) => [
    for (final f in Feature.values)
      if (gated.contains(f) && allows(plan, f.capability)) f,
  ];
}
