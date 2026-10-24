import 'feature.dart';
import 'pro_catalog.dart';

/// Pro imkoniyat TOIFASI (D-74) — funksiya emas. Kelajakda yopiladigan har
/// funksiya ([ProGatePolicy.gated]) shu toifalardan biriga tegishli va
/// daraja faqat o'z to'plamidagini ocha oladi.
///
/// QAROR SERVERDA: `cloudflare/src/tiers.ts` (`requireTier`) — serverda
/// saqlangan huquqdan (do'kon / admin grant / sinov), ilovadagi roldan
/// emas. Bu nusxa faqat UI ko'rsatmalari uchun (test ikkalasini
/// solishtiradi).
enum ProCapability {
  /// Talaba tomonidagi Pro imkoniyatlari.
  learner('learner'),

  /// Ustoz paneli Pro imkoniyatlari (bugungi bepul guruhlar EMAS).
  teacherPanel('teacher_panel'),

  /// Mutaxassis (laborant/shifokor) Pro imkoniyatlari.
  specialist('specialist');

  const ProCapability(this.wire);

  /// Server bilan umumiy nom.
  final String wire;

  /// [feature] qaysi toifaga tegishli (`null` — bepul funksiya).
  static ProCapability? of(Feature feature) => switch (feature.tier) {
    ProTier.free => null,
    ProTier.pro => learner,
    ProTier.teacher => teacherPanel,
  };
}

/// Daraja × imkoniyat matritsasi (D-74, MA'LUMOT; server bilan bir xil).
abstract final class PlanMatrix {
  /// Mutaxassis Ustoz imkoniyatlarini ham oladi — D-73 qoidasi ("eng qimmat
  /// reja kamroq bermasin"); bu ochiq qaror.
  static const capabilities = <ProPlan, Set<ProCapability>>{
    ProPlan.student: {ProCapability.learner},
    ProPlan.teacher: {ProCapability.learner, ProCapability.teacherPanel},
    ProPlan.specialist: {
      ProCapability.learner,
      ProCapability.teacherPanel,
      ProCapability.specialist,
    },
  };

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
      if (gated.contains(f) && allows(plan, ProCapability.of(f))) f,
  ];
}
