import 'dart:ui' show PlatformDispatcher;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../core/entitlements/billing_catalog.dart';
import '../../core/entitlements/entitlement_service.dart';
import '../../core/entitlements/feature.dart';
import '../../core/entitlements/purchase_adapter.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../learn/exam_question.dart' show keepUnitsTogether;
import '../../l10n/gen/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../auth/ui/role_screen.dart';
import '../settings/settings_controller.dart';
import '../community/community_screens.dart';
import '../support/support_screens.dart';
import '../toifa/toifa_bank.dart' show toifaAvailable;

enum _SignOut { keepData, deleteData }

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _nativeLanguage = {
    AppLanguage.uz: 'O‘zbekcha',
    AppLanguage.ru: 'Русский',
    AppLanguage.en: 'English',
  };

  /// Hisobli foydalanuvchi: chiqishdan oldin shu qurilmadagi ma'lumotni
  /// ham o'chirish tanlovi (keyingi foydalanuvchi oldingisining QC qaydlari
  /// va xatcho'plarini ko'rmasligi uchun). Mehmon uchun bu “boshidan
  /// sozlash” — ma'lumot o'sha odamniki, o'chirilmaydi.
  Future<void> _signOut(BuildContext context) async {
    final services = context.services;
    if (services.auth.hasAccount) {
      final l = AppLocalizations.of(context);
      final choice = await showDialog<_SignOut>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.profileSignOutTitle),
          content: Text(l.profileSignOutBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.actionCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(_SignOut.deleteData),
              child: Text(l.profileSignOutDelete),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(_SignOut.keepData),
              child: Text(l.profileSignOut),
            ),
          ],
        ),
      );
      if (choice == null) return;
      if (choice == _SignOut.deleteData) {
        await services.deleteLocalData(PlatformDispatcher.instance.locales);
        await services.settings.resetOnboarding();
        return;
      }
    }
    await services.auth.signOut();
    await services.settings.resetOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    final settings = services.settings;
    final auth = services.auth;
    final access = services.access;
    final ent = services.entitlements;
    return ListenableBuilder(
      listenable: Listenable.merge([settings, auth, access, ent]),
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final text = Theme.of(context).textTheme;
        final session = auth.session;
        final (String tag, String title, String subtitle) = switch (session) {
          EmailSession(:final email, isDemo: true) => (
            l.profileDemoSession,
            email,
            settings.effectiveRole.title(l),
          ),
          EmailSession(:final email) => (
            l.authEmailLabel,
            email,
            settings.effectiveRole.title(l),
          ),
          _ => (l.profileGuest, l.profileGuestLocal, l.profileGuestSub),
        };
        return LgPage(
          title: l.profileTitle,
          showProfile: false,
          children: [
            LgPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LgTag(tag),
                  const SizedBox(height: 12),
                  Text(title, style: text.titleLarge),
                  const SizedBox(height: 4),
                  Text(subtitle, style: text.bodyMedium),
                  if (!auth.hasAccount) ...[
                    const SizedBox(height: 14),
                    LgButton.secondary(
                      label: l.profileSignIn,
                      icon: Icons.mail_outline_rounded,
                      onPressed: () => context.push('/profile/auth'),
                    ),
                  ],
                ],
              ),
            ),
            LgRow(
              title: l.profileRole,
              subtitle:
                  '${settings.effectiveRole.title(l)} · ${l.profileRoleSub}',
              icon: settings.effectiveRole.icon,
              onTap: () => context.push('/profile/role'),
              divider: false,
            ),
            LgSectionTitle(l.profileLanguage),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final lang in AppLanguage.values)
                  LgChoiceChip(
                    label: _nativeLanguage[lang]!,
                    selected: settings.language == lang,
                    onTap: () => settings.setLanguage(lang),
                  ),
              ],
            ),
            LgSectionTitle(l.profileUnits),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final (unit, label) in [
                  (UnitSystem.si, keepUnitsTogether(l.profileUnitsSi)),
                  (
                    UnitSystem.conventional,
                    keepUnitsTogether(l.profileUnitsConventional),
                  ),
                ])
                  LgChoiceChip(
                    label: label,
                    selected: settings.unitSystem == unit,
                    onTap: () => settings.setUnitSystem(unit),
                  ),
              ],
            ),
            LgSectionTitle(l.profileAppearance),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final (mode, label) in [
                  (ThemeMode.system, l.themeSystem),
                  (ThemeMode.light, l.themeLight),
                  (ThemeMode.dark, l.themeDark),
                ])
                  LgChoiceChip(
                    label: label,
                    selected: settings.themeMode == mode,
                    onTap: () => settings.setThemeMode(mode),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            LgRow(
              title: l.libPacks,
              subtitle: l.libPacksSub,
              icon: Icons.download_for_offline_outlined,
              onTap: () => context.push('/profile/packs'),
            ),
            // Obuna — faqat to'lov haqiqatan ishlaganda (do'kon mahsulotlari
            // yuklangan va server sozlangan) yoki amaldagi obuna bo'lsa.
            // Aks holda qator umuman yo'q (App Store 2.1: "tez orada" yo'q).
            if (ent.purchasesEnabled ||
                (ent.activeEntitlement != null &&
                    ent.proSource != ProSource.buildOpen))
              LgRow(
                title: l.profilePurchase,
                subtitle: l.profilePurchaseSub,
                icon: Icons.workspace_premium_outlined,
                onTap: () => context.push('/profile/purchase'),
              ),
            LgRow(
              title: l.supportTitle,
              subtitle: services.backend.isConfigured
                  ? l.supportSub
                  : '${l.supportSub} · ${l.notAvailableYet}',
              icon: Icons.forum_outlined,
              trailing: access.unreadReplies > 0
                  ? LgTag(
                      l.supportUnreadCount(access.unreadReplies),
                      tone: LgTone.brand,
                    )
                  : null,
              onTap: () => context.push('/profile/support'),
            ),
            // Hamjamiyat — faqat server ulangan buildda.
            if (services.community.available) ...[
              LgRow(
                title: l.cmMyQuestions,
                subtitle: l.cmMyQuestionsSub,
                icon: Icons.forum_outlined,
                onTap: () => context.push(CommunityRoutes.mine),
              ),
              LgRow(
                title: l.cmVerifyTitle,
                subtitle: l.cmVerifySub,
                icon: Icons.verified_outlined,
                onTap: () => context.push(CommunityRoutes.verify),
              ),
            ],
            LgRow(
              title: l.partnerBecome,
              subtitle: services.backend.isConfigured
                  ? l.partnerBecomeSub
                  : '${l.partnerBecomeSub} · ${l.notAvailableYet}',
              icon: Icons.handshake_outlined,
              onTap: () => context.push('/profile/partnership'),
            ),
            // Faqat server admin hisobi deb tasdiqlagan foydalanuvchiga
            // ko'rinadi; ichkarida yana 2FA va har RPC'da tekshiruv bor.
            // Hamjamiyat moderatsiyasi va adminlar — panel ichida (bitta kirish).
            if (access.access.adminAccount)
              LgRow(
                title: l.adminTitle,
                subtitle: l.adminSub,
                icon: Icons.admin_panel_settings_outlined,
                onTap: () => context.push('/profile/admin'),
              ),
            LgRow(
              title: l.profilePrivacy,
              subtitle: l.profilePrivacySub,
              icon: Icons.shield_outlined,
              onTap: () => context.push('/profile/privacy'),
              divider: false,
            ),
            const SizedBox(height: 18),
            LgButton.secondary(
              label: auth.hasAccount ? l.profileSignOut : l.profileRestartSetup,
              icon: auth.hasAccount
                  ? Icons.logout_rounded
                  : Icons.restart_alt_rounded,
              onPressed: () => _signOut(context),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                l.profileVersion(services.config.appVersion),
                style: text.bodySmall,
              ),
            ),
            if (services.config.showDebugBadge)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: LgTag(l.debugBuildBadge, tone: LgTone.warning),
                ),
              ),
          ],
        );
      },
    );
  }
}

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
    final teacher = ent.tier == ProTier.teacher;
    final end = active?.expiresAt;
    final line = switch ((teacher, end)) {
      (true, null) => l.payStatusTeacherNoEnd,
      (true, final DateTime e) => l.payStatusTeacher(formatWhen(e, context)),
      (false, null) => l.purchaseStatusProNoEnd,
      (false, final DateTime e) => l.purchaseStatusPro(formatWhen(e, context)),
    };
    return [
      LgSectionTitle(l.purchaseStatusTitle),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: LgTag(teacher ? l.payTierTeacher : l.payTierPro),
      ),
      const SizedBox(height: 8),
      Text(line, style: text.bodyLarge),
      if (ent.proSource == ProSource.offlineCache && cache != null) ...[
        const SizedBox(height: 4),
        Text(
          l.purchaseStatusOffline(formatWhen(cache.receivedAt, context)),
          style: text.bodySmall,
        ),
      ],
      if (ent.proSource == ProSource.store) ...[
        const SizedBox(height: 4),
        Text(l.payStatusDevice, style: text.bodySmall),
      ],
      const SizedBox(height: 10),
    ];
  }

  static String _period(AppLocalizations l, StorePeriod p) => p.count == 1
      ? switch (p.unit) {
          StorePeriodUnit.day => l.payUnitDay,
          StorePeriodUnit.week => l.payUnitWeek,
          StorePeriodUnit.month => l.payUnitMonth,
          StorePeriodUnit.year => l.payUnitYear,
        }
      : _length(l, p);

  static String _length(AppLocalizations l, StorePeriod p) => switch (p.unit) {
    StorePeriodUnit.day => l.payDays(p.count),
    StorePeriodUnit.week => l.payWeeks(p.count),
    StorePeriodUnit.month => l.payMonths(p.count),
    StorePeriodUnit.year => l.payYears(p.count),
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
      BillingOutcome.success => restore ? l.payRestored : l.paySuccess,
      BillingOutcome.cancelled => null,
      BillingOutcome.pending => l.payPending,
      BillingOutcome.nothingFound => l.payNothingFound,
      BillingOutcome.ownedByOther => l.payOwnedByOther,
      BillingOutcome.unavailable => l.payUnavailable,
      BillingOutcome.failed => l.payFailed,
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
    final price = l.payPricePer(p.displayPrice, _period(l, period));
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
                      ? l.payPlanYearly
                      : l.payPlanMonthly,
                  style: text.titleMedium,
                ),
              ),
              if (mine) LgTag(l.payCurrent),
            ],
          ),
          const SizedBox(height: 4),
          // Har davr uchun to'lanadigan summa — eng ko'zga tashlanadigan matn.
          Text(price, style: text.titleLarge),
          if (trial != null && !mine) ...[
            const SizedBox(height: 4),
            Text(l.payTrial(_length(l, trial), price), style: text.bodyMedium),
          ],
          if (!mine) ...[
            const SizedBox(height: 12),
            LgButton(
              label: trial != null ? l.payStartTrial : l.paySubscribe,
              busy: ent.busy,
              onPressed: ent.busy
                  ? null
                  : () => _run(
                      context,
                      () => ent.purchase(p.id),
                      restore: false,
                    ),
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
        Expanded(
          child: Text(s, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    ),
  );

  List<Widget> _tier(
    BuildContext context,
    AppLocalizations l, {
    required ProTier tier,
    required List<StoreProduct> plans,
    required Set<String> owned,
  }) {
    if (plans.isEmpty) return const [];
    final text = Theme.of(context).textTheme;
    final settings = context.services.settings;
    final toifa = toifaAvailable(
      settings.language,
      PlatformDispatcher.instance.locales,
      role: settings.role,
    );
    final included = tier == ProTier.teacher
        ? [
            l.payFeatAllPro,
            l.payFeatGroups,
            l.payFeatAssignments,
            l.payFeatLecture,
          ]
        : [
            l.payFeatQuestions,
            l.payFeatExam,
            if (toifa) l.payFeatToifa,
            l.payFeatWeak,
            l.payFeatAtlas,
            l.payFeatHistory,
          ];
    return [
      LgSectionTitle(tier == ProTier.teacher ? l.payTierTeacher : l.payTierPro),
      Text(
        tier == ProTier.teacher ? l.payTierTeacherSub : l.payTierProSub,
        style: text.bodyMedium,
      ),
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
    final services = context.services;
    if (!ent.purchasesEnabled) {
      // To'lov yoqilmagan: hech qanday xarid elementi yo'q.
      return LgPage(
        title: l.purchaseTitle,
        showProfile: false,
        children: [
          LgNotice(
            ent.proSource == ProSource.buildOpen
                ? l.payTestBuildOpen
                : l.payAllOpen,
            kind: NoticeKind.info,
          ),
          ..._status(context, l),
        ],
      );
    }
    final products = ent.offeredProducts;
    final owned = {
      if (ent.activeEntitlement case final a?) a.productId,
    };
    final active = ent.activeEntitlement;
    final locked = feature;
    return LgPage(
      title: l.purchaseTitle,
      showProfile: false,
      children: [
        if (ent.proSource == ProSource.buildOpen)
          LgNotice(l.payTestBuildOpen, kind: NoticeKind.info),
        if (locked != null && !ent.can(locked))
          LgNotice(
            locked.tier == ProTier.teacher
                ? l.payLockedTeacher
                : l.payLockedPro,
            kind: NoticeKind.info,
          ),
        ..._status(context, l),
        if (ent.tier != ProTier.teacher || ent.proSource == ProSource.buildOpen)
          ..._tier(
            context,
            l,
            tier: ProTier.pro,
            plans: [
              for (final p in products)
                if (p.catalog!.tier == ProTier.pro) p,
            ],
            owned: owned,
          ),
        ..._tier(
          context,
          l,
          tier: ProTier.teacher,
          plans: [
            for (final p in products)
              if (p.catalog!.tier == ProTier.teacher) p,
          ],
          owned: owned,
        ),
        const SizedBox(height: 8),
        Text(l.payFree, style: text.bodySmall),
        const SizedBox(height: 10),
        Text(l.payDisclosure(_store), style: text.bodySmall),
        if (!services.backend.hasSession) ...[
          const SizedBox(height: 8),
          Text(l.payGuestNote, style: text.bodySmall),
        ],
        const SizedBox(height: 14),
        LgButton.secondary(
          label: l.payRestore,
          icon: Icons.restore_rounded,
          busy: ent.busy,
          onPressed: ent.busy
              ? null
              : () => _run(context, ent.restore, restore: true),
        ),
        const SizedBox(height: 6),
        LgButton.link(
          label: l.payManage,
          onPressed: () => openExternalLink(
            context,
            BillingLinks.manageSubscriptions(
              ios: ent.source.platform == 'app_store',
              productId: active?.productId,
            ),
          ),
        ),
        LgButton.link(
          label: l.payTerms,
          onPressed: () => openExternalLink(context, BillingLinks.termsOfUse),
        ),
        LgButton.link(
          label: l.payPrivacy,
          onPressed: () =>
              openExternalLink(context, BillingLinks.privacyPolicy),
        ),
      ],
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  Future<void> _confirmDelete(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final services = context.services;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.privacyDeleteConfirmTitle),
        content: Text(l.privacyDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await services.deleteLocalData(PlatformDispatcher.instance.locales);
    // Til tizim tiliga qaytdi: xabar ham shu (yangi) tilda chiqadi.
    final after = lookupAppLocalizations(services.settings.language.locale);
    messenger.showSnackBar(SnackBar(content: Text(after.privacyDeleted)));
  }

  /// Serverdagi hisobni o'chirish (Edge Function, service role faqat
  /// serverda). Muvaffaqiyatdan keyin qurilmadagi ma'lumot ham tozalanadi.
  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final services = context.services;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.accountDeleteTitle),
        content: Text(
          services.entitlements.purchasesEnabled ||
                  services.entitlements.activeEntitlement != null
              ? '${l.accountDeleteBody}\n\n${l.payDeleteAccountNote(services.entitlements.source.platform == 'app_store' ? 'App Store' : 'Google Play')}'
              : l.accountDeleteBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await services.backend.deleteAccount();
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(backendErrorText(e, l))));
      return;
    }
    await services.deleteLocalData(PlatformDispatcher.instance.locales);
    await services.settings.resetOnboarding();
    messenger.showSnackBar(SnackBar(content: Text(l.accountDeleted)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final services = context.services;
    final hasServerAccount =
        services.backend.isConfigured && services.backend.hasSession;
    return LgPage(
      title: l.privacyTitle,
      showProfile: false,
      children: [
        Text(
          services.backend.isConfigured ? l.privacyBody : l.privacyBodyLocal,
          style: text.bodyLarge,
        ),
        const SizedBox(height: 12),
        LgRow(
          title: l.privacyTerms,
          subtitle: l.privacyTermsSub,
          icon: Icons.description_outlined,
          onTap: () => context.push('/terms'),
        ),
        LgRow(
          title: l.privacyDeleteLocal,
          subtitle: l.privacyDeleteLocalSub,
          icon: Icons.delete_outline_rounded,
          onTap: () => _confirmDelete(context),
          divider: hasServerAccount,
        ),
        if (hasServerAccount)
          LgRow(
            title: l.accountDelete,
            subtitle: l.accountDeleteSub,
            icon: Icons.person_remove_outlined,
            onTap: () => _confirmDeleteAccount(context),
            divider: false,
          ),
      ],
    );
  }
}
