import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/entitlements/entitlement_service.dart';
import '../../core/entitlements/plan_matrix.dart';
import '../../core/entitlements/pro_catalog.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../support/support_screens.dart' show formatWhen;

/// “Obuna” ekrani (D-74). FAQAT `BuildFlags.proEnabled` buildda (Profil
/// qatori va `/profile/subscription` yo'li bayroq ortida). Oddiy tilda:
/// uch reja va ularning oylik/yillik narxi (katalog MA'LUMOTIDAN, USD),
/// har reja nimani ochishi (matritsadan; hech narsa yopilmagan bo'lsa —
/// “hozircha hamma imkoniyat bepul”), joriy holat (bepul / sinov / reja /
/// admin bergan), bepul sinov qoidasi (bir telefonga bir marta) va
/// “Xaridni tiklash”.
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
    ProPlan.student => l.proPayTierStudent,
    ProPlan.teacher => l.proPayTierTeacher,
    ProPlan.specialist => l.proPayTierSpecialist,
  };

  static String _planSub(AppLocalizations l, ProPlan plan) => switch (plan) {
    ProPlan.student => l.proPayTierStudentSub,
    ProPlan.teacher => l.proPayTierTeacherSub,
    ProPlan.specialist => l.proPayTierSpecialistSub,
  };

  static String _cap(AppLocalizations l, ProCapability c) => switch (c) {
    ProCapability.learner => l.proSubCapLearner,
    ProCapability.teacherPanel => l.proSubCapTeacherPanel,
    ProCapability.specialist => l.proSubCapSpecialist,
  };

  static String _usd(double v) => '\$${v.toStringAsFixed(2)}';

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

  String _trialLine(BuildContext context, AppLocalizations l) {
    if (!ent.source.hasSession) return l.proSubTrialGuest;
    if (ent.trialUsed) return l.proSubTrialUsed;
    return l.proSubTrialNotActive;
  }

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
            Text(
              '${l.proPayPlanMonthly}: '
              '${l.proPayPricePer(_usd(spec.monthlyUsd), l.proPayUnitMonth)}',
              style: text.bodyLarge,
            ),
            if (spec.yearlyUsd case final y?)
              Text(
                '${l.proPayPlanYearly}: '
                '${l.proPayPricePer(_usd(y), l.proPayUnitYear)}',
                style: text.bodyLarge,
              ),
            const SizedBox(height: 8),
            Text(l.proSubUnlocks(caps.join(', ')), style: text.bodyMedium),
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
        const SizedBox(height: 6),
        LgSectionTitle(l.proSubPlansTitle),
        for (final spec in ProPricing.plans) _plan(context, l, spec),
        Text(l.proSubPriceNote, style: text.bodySmall),
        const SizedBox(height: 6),
        Text(l.proSubTeacherNote, style: text.bodySmall),
        const SizedBox(height: 6),
        LgSectionTitle(l.proSubTrialTitle),
        Text(
          l.proSubTrialOncePerPhone,
          key: const ValueKey('sub-trial-rule'),
          style: text.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          _trialLine(context, l),
          key: const ValueKey('sub-trial-state'),
          style: text.bodySmall,
        ),
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
      ],
    );
  }
}
