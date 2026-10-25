import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../core/entitlements/billing_catalog.dart';
import '../../core/entitlements/entitlement_service.dart';
import '../../core/entitlements/purchase_adapter.dart';
import '../auth/auth_controller.dart';
import '../../core/entitlements/plan_matrix.dart';
import '../../core/entitlements/pro_catalog.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import 'purchase_screen.dart' show proFeatureLabel;
import '../support/support_screens.dart' show formatWhen;

/// “Obuna” ekrani (D-74). FAQAT `BuildFlags.proEnabled` buildda (Profil
/// qatori va `/profile/subscription` yo'li bayroq ortida). Oddiy tilda:
/// to'rt reja (D-76: Talaba, Ustoz, Mutaxassis, Premium) va ularning oylik/yillik narxi (katalog MA'LUMOTIDAN, USD),
/// har reja nimani ochishi (matritsadan; hech narsa yopilmagan bo'lsa —
/// “hozircha hamma imkoniyat bepul”), joriy holat (bepul / sinov / reja /
/// admin bergan), bepul sinov qoidasi (bir telefonga bir marta) va
/// “Xaridni tiklash”.
///
/// D-75 (do'kon qoidalari, POLICY_REVIEW §4): har davr uchun to'lanadigan
/// summa — eng ko'zga tashlanadigan narx (do'kon yuklangan bo'lsa do'kon
/// narxi, mahalliy valyutada); yillik — yillik narx sifatida ("/ yil"),
/// oylikka bo'linmaydi; “Obunani boshqarish yoki bekor qilish” (do'konning
/// obuna sozlamalari), “Xaridni tiklash”, Foydalanish shartlari va Maxfiylik
/// havolalari; boshqa to'lov usuli yoki boshqa do'kon narxi YO'Q (iOS 3.1.3).
/// Sinov tugmasi faqat server imkoniyat so'rovi shu platformada sinov bor
/// desa VA attestatsiya sozlangan bo'lsa; aks holda oddiy izoh. Sinov matni:
/// to'lov usuli yo'q, pul yechilmaydi, bepul imkoniyatlar davom etadi.
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ent = context.services.entitlements;
    return ListenableBuilder(
      listenable: ent,
      builder: (context, _) => _SubscriptionBody(ent: ent),
    );
  }
}

class _SubscriptionBody extends StatelessWidget {
  const _SubscriptionBody({required this.ent});

  final EntitlementService ent;

  static String planTitle(AppLocalizations l, ProPlan plan) => switch (plan) {
    ProPlan.student => l.proTierNameStudent,
    ProPlan.teacher => l.proTierNameTeacher,
    ProPlan.specialist => l.proTierNameSpecialist,
    ProPlan.premium => l.proTierNamePremium,
  };

  static String _planSub(AppLocalizations l, ProPlan plan) => switch (plan) {
    ProPlan.student => l.proTierSubStudent,
    ProPlan.teacher => l.proTierSubTeacher,
    ProPlan.specialist => l.proTierSubSpecialist,
    ProPlan.premium => l.proTierSubPremium,
  };

  static String _cap(AppLocalizations l, ProCapability c) => switch (c) {
    ProCapability.learner => l.proSubCapLearner,
    ProCapability.teacherPanel => l.proSubCapTeacherPanel,
    ProCapability.lab => l.proCapLabPro,
  };

  static String _usd(double v) => '\$${v.toStringAsFixed(2)}';

  /// Narx: do'kon yuklagan bo'lsa — do'kon narxi (mahalliy valyuta, Play
  /// sec.6: ilovadagi narx do'kondagiga teng); aks holda katalog (USD).
  String _price(String productId, double catalogUsd) {
    for (final StoreProduct p in ent.purchases.loaded) {
      if (p.id == productId) return p.displayPrice;
    }
    return _usd(catalogUsd);
  }

  /// Joriy holat: bepul / sinov (qolgan kunlar) / reja / admin bergan.
  String _status(BuildContext context, AppLocalizations l) {
    final active = ent.activeEntitlement;
    final plan = active?.effectivePlan;
    if (active == null || plan == null) return l.proSubStatusFree;
    final name = planTitle(l, plan);
    final end = active.expiresAt;
    if (active.isTrial) {
      return l.proSubStatusTrial(name, l.proPayDays(ent.trialDaysLeft ?? 0));
    }
    if (active.isAdminGrant) {
      return end == null
          ? l.proSubStatusAdmin(name)
          : l.proSubStatusAdminUntil(name, formatWhen(end, context));
    }
    return end == null
        ? l.proSubStatusPlan(name)
        : l.proSubStatusPlanUntil(name, formatWhen(end, context));
  }

  String? _trialLine(AppLocalizations l) => switch (ent.trialBlock) {
    TrialBlock.none => null,
    TrialBlock.guest => l.proSubTrialGuest,
    TrialBlock.used => l.proSubTrialUsed,
    TrialBlock.hasAccess => l.proSubTrialHasAccess,
    TrialBlock.notOnPlatform => l.proSubTrialNotOnPlatform,
    TrialBlock.notConfigured => l.proSubTrialNotActive,
  };

  /// Sinov shu platformada server tomonidan taklif qilinadimi (D-75).
  bool get _trialOnPlatform => ent.trialOfferedHere;

  Future<void> _startTrial(BuildContext context, ProPlan plan) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final email = switch (context.services.auth.session) {
      EmailSession(:final email) => email,
      _ => null,
    };
    if (email == null) return;
    final until = DateTime.now().add(
      const Duration(days: ProTrialConfig.serverTrialDays),
    );
    final name = planTitle(l, plan);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.proSubTrialConfirmTitle),
        content: Text(
          l.proTrialConfirmBody(name, formatWhen(until, ctx)),
          key: const ValueKey('sub-trial-confirm-body'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.proSubTrialCancel),
          ),
          FilledButton(
            key: const ValueKey('sub-trial-confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.proSubTrialConfirm),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final outcome = await ent.startTrial(plan: plan, email: email);
    if (!context.mounted) return;
    final end = ent.activeEntitlement?.expiresAt;
    final message = switch (outcome) {
      TrialOutcome.success => l.proSubTrialStarted(
        end == null ? '' : formatWhen(end, context),
      ),
      TrialOutcome.alreadyUsed => l.proSubTrialUsed,
      TrialOutcome.planNotAllowed => l.proSubTrialPlanNotAllowed,
      TrialOutcome.emailNotVerified => l.proSubTrialEmail,
      TrialOutcome.attestationFailed => l.proSubTrialDevice,
      TrialOutcome.alreadySubscribed => l.proSubTrialSubscribed,
      TrialOutcome.unavailable => l.proSubTrialNotOnPlatform,
      TrialOutcome.failed => l.proPayFailed,
    };
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<Widget> _trialSection(BuildContext context, AppLocalizations l) {
    final text = Theme.of(context).textTheme;
    final line = _trialLine(l);
    return [
      LgSectionTitle(l.proSubTrialTitle(ProTrialConfig.serverTrialDays)),
      if (_trialOnPlatform) ...[
        Text(
          l.proSubTrialBody(ProTrialConfig.serverTrialDays),
          key: const ValueKey('sub-trial-body'),
          style: text.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          l.proSubTrialOncePerPhone,
          key: const ValueKey('sub-trial-rule'),
          style: text.bodySmall,
        ),
        const SizedBox(height: 4),
      ],
      if (line != null)
        Text(
          line,
          key: const ValueKey('sub-trial-state'),
          style: text.bodySmall,
        ),
      // Tugma faqat imkoniyat so'rovi + attestatsiya + hisob bo'lsa (D-75).
      if (ent.trialAvailable)
        for (final plan in ProPlan.values)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LgButton.secondary(
              key: ValueKey('sub-trial-start-${plan.name}'),
              label: l.proSubTrialStart(planTitle(l, plan)),
              busy: ent.busy,
              onPressed: ent.busy ? null : () => _startTrial(context, plan),
            ),
          ),
    ];
  }

  /// Ilgari Pro bo'lgan, endi yo'q: “Pro tugadi, bepul imkoniyatlar ishlaydi”.
  bool get _ended =>
      ent.activeEntitlement == null && (ent.cached?.items.isNotEmpty ?? false);

  Future<void> _restore(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await ent.restore();
    final message = switch (outcome) {
      BillingOutcome.success => l.proPayRestored,
      BillingOutcome.cancelled => null,
      BillingOutcome.pending => l.proPayPending,
      BillingOutcome.nothingFound => l.proPayNothingFound,
      BillingOutcome.ownedByOther => l.proPayOwnedByOther,
      BillingOutcome.signInRequired => l.proPaySignInRequired,
      BillingOutcome.unavailable => l.proPayUnavailable,
      BillingOutcome.failed => l.proPayFailed,
    };
    if (message == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _plan(BuildContext context, AppLocalizations l, ProPlanSpec spec) {
    final text = Theme.of(context).textTheme;
    final caps = [
      for (final c in ProCapability.values)
        if (PlanMatrix.allows(spec.plan, c)) _cap(l, c),
    ];
    final unlocked = PlanMatrix.unlockedBy(spec.plan, gated: ent.gated);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LgPanel(
        key: ValueKey('sub-plan-${spec.plan.name}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(planTitle(l, spec.plan), style: text.titleMedium),
            const SizedBox(height: 2),
            Text(_planSub(l, spec.plan), style: text.bodySmall),
            const SizedBox(height: 8),
            // To'lanadigan summa — eng ko'zga tashlanadigan narx elementi.
            Text(
              '${l.proPayPlanMonthly}: '
              '${l.proPayPricePer(_price(spec.monthlyProductId, spec.monthlyUsd), l.proPayUnitMonth)}',
              style: text.titleMedium,
            ),
            if (spec.yearlyUsd case final y?)
              Text(
                '${l.proPayPlanYearly}: '
                '${l.proPayPricePer(_price(spec.yearlyProductId, y), l.proPayUnitYear)}',
                style: text.titleMedium,
              ),
            const SizedBox(height: 8),
            Text(l.proSubUnlocks(caps.join(', ')), style: text.bodyMedium),
            // D-78: faqat QURILGAN pullik funksiyalar (`gated`) sanaladi.
            for (final f in unlocked)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• ${proFeatureLabel(l, f)}', style: text.bodySmall),
              ),
            if (unlocked.isEmpty) ...[
              const SizedBox(height: 4),
              Text(l.proSubNothingGated, style: text.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.proSubTitle,
      showProfile: false,
      children: [
        if (ent.gated.isEmpty)
          LgNotice(
            l.proSubAllFree,
            kind: NoticeKind.info,
            key: const ValueKey('sub-all-free'),
          ),
        LgSectionTitle(l.proSubStatusTitle),
        Text(
          _status(context, l),
          key: const ValueKey('sub-status'),
          style: text.bodyLarge,
        ),
        if (_ended) ...[
          const SizedBox(height: 4),
          Text(
            l.proSubEnded,
            key: const ValueKey('sub-ended'),
            style: text.bodyMedium,
          ),
        ],
        const SizedBox(height: 6),
        LgSectionTitle(l.proSubPlansTitle),
        for (final spec in ProPricing.plans) _plan(context, l, spec),
        Text(l.proSubPriceNote, style: text.bodySmall),
        const SizedBox(height: 4),
        Text(l.proSubPriceYearlyNote, style: text.bodySmall),
        const SizedBox(height: 4),
        Text(
          l.proSubWithoutSubscription,
          key: const ValueKey('sub-without'),
          style: text.bodySmall,
        ),
        const SizedBox(height: 6),
        Text(l.proTierNote, style: text.bodySmall),
        const SizedBox(height: 6),
        ..._trialSection(context, l),
        const SizedBox(height: 14),
        if (ent.purchasesEnabled) ...[
          LgButton(
            label: l.proPaySubscribe,
            onPressed: () => context.push('/profile/purchase'),
          ),
          const SizedBox(height: 8),
        ],
        LgButton.secondary(
          key: const ValueKey('sub-restore'),
          label: l.proPayRestore,
          icon: Icons.restore_rounded,
          busy: ent.busy,
          onPressed: ent.busy ? null : () => _restore(context),
        ),
        const SizedBox(height: 6),
        // Do'konning o'z obuna sozlamalari (bekor qilish shu yerda).
        LgButton.link(
          key: const ValueKey('sub-manage'),
          label: l.proPayManage,
          onPressed: () => openExternalLink(
            context,
            BillingLinks.manageSubscriptions(
              ios: ent.source.platform == 'app_store',
              productId: ent.activeEntitlement?.isStore == true
                  ? ent.activeEntitlement?.productId
                  : null,
            ),
          ),
        ),
        LgButton.link(
          key: const ValueKey('sub-terms'),
          label: l.proPayTerms,
          onPressed: () => openExternalLink(context, BillingLinks.termsOfUse),
        ),
        LgButton.link(
          key: const ValueKey('sub-privacy'),
          label: l.proPayPrivacy,
          onPressed: () =>
              openExternalLink(context, BillingLinks.privacyPolicy),
        ),
      ],
    );
  }
}
