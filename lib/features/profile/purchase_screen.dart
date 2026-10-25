import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../core/entitlements/billing_catalog.dart';
import '../../core/entitlements/entitlement_service.dart';
import '../../core/entitlements/feature.dart';
import '../../core/entitlements/pro_catalog.dart';
import '../../core/entitlements/purchase_adapter.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../support/support_screens.dart' show formatWhen;

/// Obuna oynasi (App Store 3.1.2): har reja uchun nom, davr, do'kondan
/// kelgan narx, bepul sinov (do'kon taklifi bo'lsa), nima kirishi,
/// avtomatik yangilanish sharti, Foydalanish shartlari va Maxfiylik
/// havolalari, "Xaridni tiklash" va "Obunani boshqarish".
///
/// To'lov yoqilmagan bo'lsa (do'kon mahsulotlari yo'q yoki server
/// sozlanmagan) bu ekranga Profil'dan kirilmaydi; to'g'ridan-to'g'ri
/// ochilsa ham faqat "hamma imkoniyat ochiq" deyiladi — yopiq tugma,
/// "tez orada" yoki "to'lov yoqilmagan" yozuvi yo'q.
class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key, this.feature});

  /// Ekran shu imkoniyat uchun ochildi (boshlash tugmasidan).
  final Feature? feature;

  @override
  Widget build(BuildContext context) {
    final ent = context.services.entitlements;
    return ListenableBuilder(
      listenable: ent,
      builder: (context, _) => _PurchaseBody(ent: ent, feature: feature),
    );
  }
}

class _PurchaseBody extends StatelessWidget {
  const _PurchaseBody({required this.ent, this.feature});

  final EntitlementService ent;
  final Feature? feature;

  String get _store =>
      ent.source.platform == 'app_store' ? 'App Store' : 'Google Play';

  /// Halol holat: qaysi manbadan Pro (yoki yo'q).
  List<Widget> _status(BuildContext context, AppLocalizations l) {
    final text = Theme.of(context).textTheme;
    final active = ent.activeEntitlement;
    final cache = ent.cached;
    if (!ent.isPro || ent.proSource == ProSource.buildOpen) return const [];
    final plan = ent.plan;
    final end = active?.expiresAt;
    final grant = active?.isAdminGrant ?? false;
    final line = grant
        ? (end == null
              ? l.proPayStatusAdminGrant
              : l.proPayStatusAdminGrantUntil(formatWhen(end, context)))
        : switch ((plan, end)) {
            (final ProPlan p, null) => l.proSubStatusPlan(_planTitle(l, p)),
            (final ProPlan p, final DateTime e) => l.proSubStatusPlanUntil(
              _planTitle(l, p),
              formatWhen(e, context),
            ),
            (null, null) => l.proStatusProNoEnd,
            (null, final DateTime e) => l.proStatusPro(formatWhen(e, context)),
          };
    return [
      LgSectionTitle(l.proStatusTitle),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: LgTag(plan == null ? l.proPayTierPro : _planTitle(l, plan)),
      ),
      const SizedBox(height: 8),
      Text(line, style: text.bodyLarge),
      if (ent.proSource == ProSource.offlineCache && cache != null) ...[
        const SizedBox(height: 4),
        Text(
          l.proStatusOffline(formatWhen(cache.receivedAt, context)),
          style: text.bodySmall,
        ),
      ],
      const SizedBox(height: 10),
    ];
  }

  static String _planTitle(AppLocalizations l, ProPlan plan) => switch (plan) {
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

  static String _period(AppLocalizations l, StorePeriod p) => p.count == 1
      ? switch (p.unit) {
          StorePeriodUnit.day => l.proPayUnitDay,
          StorePeriodUnit.week => l.proPayUnitWeek,
          StorePeriodUnit.month => l.proPayUnitMonth,
          StorePeriodUnit.year => l.proPayUnitYear,
        }
      : _length(l, p);

  static String _length(AppLocalizations l, StorePeriod p) => switch (p.unit) {
    StorePeriodUnit.day => l.proPayDays(p.count),
    StorePeriodUnit.week => l.proPayWeeks(p.count),
    StorePeriodUnit.month => l.proPayMonths(p.count),
    StorePeriodUnit.year => l.proPayYears(p.count),
  };

  Future<void> _run(
    BuildContext context,
    Future<BillingOutcome> Function() action, {
    required bool restore,
  }) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await action();
    final message = switch (outcome) {
      BillingOutcome.success => restore ? l.proPayRestored : l.proPaySuccess,
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
    // Imkoniyat uchun ochilgan bo'lsa — muvaffaqiyatdan keyin o'sha joyga qaytadi.
    if (outcome == BillingOutcome.success &&
        feature != null &&
        ent.can(feature!) &&
        context.mounted &&
        context.canPop()) {
      context.pop();
    }
  }

  Widget _plan(
    BuildContext context,
    AppLocalizations l,
    StoreProduct p,
    Set<String> owned,
  ) {
    final text = Theme.of(context).textTheme;
    final catalog = p.catalog!;
    final period =
        p.period ??
        StorePeriod(
          1,
          catalog.period == BillingPeriod.year
              ? StorePeriodUnit.year
              : StorePeriodUnit.month,
        );
    final price = l.proPayPricePer(p.displayPrice, _period(l, period));
    final trial = p.freeTrial;
    final mine = owned.contains(p.id);
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  catalog.period == BillingPeriod.year
                      ? l.proPayPlanYearly
                      : l.proPayPlanMonthly,
                  style: text.titleMedium,
                ),
              ),
              if (mine) LgTag(l.proPayCurrent),
            ],
          ),
          const SizedBox(height: 4),
          // Har davr uchun to'lanadigan summa — eng ko'zga tashlanadigan matn.
          Text(price, style: text.titleLarge),
          if (trial != null && !mine) ...[
            const SizedBox(height: 4),
            Text(
              l.proPayTrial(_length(l, trial), price),
              style: text.bodyMedium,
            ),
          ],
          // Mehmon xarid qilmaydi (D-76): tugma o'rniga pastda "Hisobga kirish".
          // TODO(billing-agent, D-78): Apple 5.1.1(v) — hisobsiz capability
          // (learner, lab) xaridi kerak bo'lsa, EntitlementService mehmon
          // xaridi/tiklashini beradi (masalan, `ent.canPurchaseAsGuest(plan)`);
          // shu shart o'sha API ga almashtiriladi. Mijoz boshqa joyda faqat
          // `requireFeature` / `EntitlementService.can` ga tayanadi.
          if (!mine && ent.source.hasSession) ...[
            const SizedBox(height: 12),
            LgButton(
              label: trial != null ? l.proPayStartTrial : l.proPaySubscribe,
              busy: ent.busy,
              onPressed: ent.busy
                  ? null
                  : () =>
                        _run(context, () => ent.purchase(p.id), restore: false),
            ),
          ],
        ],
      ),
    );
  }


  Widget _bullet(BuildContext context, String s) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_rounded,
            size: 18,
            color: LgPalette.of(context).brand,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(s, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    ),
  );

  List<Widget> _tier(
    BuildContext context,
    AppLocalizations l, {
    required ProPlan plan,
    required List<StoreProduct> plans,
    required Set<String> owned,
  }) {
    if (plans.isEmpty) return const [];
    final text = Theme.of(context).textTheme;
    // Faqat HAQIQATAN yopilgan (`gated`) imkoniyatlar sanaladi (D-71): hozir
    // ro'yxat bo'sh, shuning uchun hech narsa va'da qilinmaydi.
    final included = <String>[
      for (final f in Feature.values)
        if (ent.gated.contains(f) && plan.tier.covers(f)) proFeatureLabel(l, f),
    ];
    return [
      LgSectionTitle(_planTitle(l, plan)),
      Text(_planSub(l, plan), style: text.bodyMedium),
      const SizedBox(height: 6),
      for (final s in included) _bullet(context, s),
      const SizedBox(height: 4),
      for (final p in plans) _plan(context, l, p, owned),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    if (!ent.purchasesEnabled) {
      // To'lov yoqilmagan: hech qanday xarid elementi yo'q.
      return LgPage(
        title: l.proPurchaseTitle,
        showProfile: false,
        children: [
          LgNotice(
            ent.proSource == ProSource.buildOpen
                ? l.proPayTestBuildOpen
                : l.proPayAllOpen,
            kind: NoticeKind.info,
          ),
          ..._status(context, l),
        ],
      );
    }
    final products = ent.offeredProducts;
    final owned = {if (ent.activeEntitlement case final a?) a.productId};
    final active = ent.activeEntitlement;
    final locked = feature;
    return LgPage(
      title: l.proPurchaseTitle,
      showProfile: false,
      children: [
        if (ent.proSource == ProSource.buildOpen)
          LgNotice(l.proPayTestBuildOpen, kind: NoticeKind.info),
        if (locked != null && !ent.can(locked))
          LgNotice(
            switch (locked.capability) {
              ProCapability.learner => l.proLockedLearner,
              ProCapability.teacherPanel => l.proLockedTeacher,
              ProCapability.lab => l.proLockedLab,
            },
            key: const ValueKey('pay-locked'),
            kind: NoticeKind.info,
          ),
        if (ent.gated.isEmpty)
          LgNotice(l.proNothingGated, kind: NoticeKind.info),
        ..._status(context, l),
        // Yopiq imkoniyatdan kelganda — faqat uni OCHADIGAN rejalar (masalan,
        // Lab uchun Ustoz rejasi taklif qilinmaydi: u Labni ochmaydi).
        for (final plan in ProPlan.values)
          if (locked == null || plan.tier.covers(locked))
            ..._tier(
              context,
              l,
              plan: plan,
              plans: [
                for (final p in products)
                  if (p.catalog!.plan == plan) p,
              ],
              owned: owned,
            ),
        const SizedBox(height: 8),
        Text(l.proPayFree, style: text.bodySmall),
        const SizedBox(height: 10),
        Text(l.proPayDisclosure(_store), style: text.bodySmall),
        // Mehmon (D-76): obuna, tiklash va sinov — faqat hisob bilan.
        if (!ent.source.hasSession) ...[
          const SizedBox(height: 8),
          Text(
            l.proPayGuestNote,
            key: const ValueKey('pay-guest-note'),
            style: text.bodySmall,
          ),
          const SizedBox(height: 8),
          LgButton(
            key: const ValueKey('pay-sign-in'),
            label: l.profileSignIn,
            icon: Icons.mail_outline_rounded,
            onPressed: () => context.push('/profile/auth'),
          ),
        ],
        const SizedBox(height: 14),
        LgButton.secondary(
          label: l.proPayRestore,
          icon: Icons.restore_rounded,
          busy: ent.busy,
          onPressed: ent.busy
              ? null
              : () => _run(context, ent.restore, restore: true),
        ),
        const SizedBox(height: 6),
        LgButton.link(
          label: l.proPayManage,
          onPressed: () => openExternalLink(
            context,
            BillingLinks.manageSubscriptions(
              ios: ent.source.platform == 'app_store',
              productId: active?.productId,
            ),
          ),
        ),
        LgButton.link(
          label: l.proPayTerms,
          onPressed: () => openExternalLink(context, BillingLinks.termsOfUse),
        ),
        LgButton.link(
          label: l.proPayPrivacy,
          onPressed: () =>
              openExternalLink(context, BillingLinks.privacyPolicy),
        ),
      ],
    );
  }
}

/// Pullik funksiya nomi (to'lov oynasi va "Obuna" ekrani ro'yxatlari).
String proFeatureLabel(AppLocalizations l, Feature f) => switch (f) {
  Feature.resultsAnalytics => l.proFeatResultsAnalytics,
  Feature.examSimulation => l.proFeatExamSimulation,
  Feature.resultsExport => l.proFeatResultsExport,
  Feature.teacherTests => l.proFeatTeacherTests,
  Feature.teacherTestBuilder => l.proFeatTeacherTestBuilder,
  Feature.teacherTestAssign => l.proFeatTeacherTestAssign,
  Feature.teacherResults => l.proFeatTeacherResults,
  Feature.calibrationExport => l.proFeatCalibrationExport,
  Feature.qcReport => l.proFeatQcReport,
};
