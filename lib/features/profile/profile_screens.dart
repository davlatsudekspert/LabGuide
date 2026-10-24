import 'dart:ui' show PlatformDispatcher;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../core/backend/step_up.dart';
import '../../core/build_flags.dart';
import '../../core/contact.dart';
import '../../core/single_flight.dart';
import '../../design/widgets/lg_widgets.dart';
import '../learn/exam_question.dart' show keepUnitsTogether;
import '../../l10n/gen/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../auth/social_auth.dart';
import '../auth/ui/role_screen.dart';
import '../settings/settings_controller.dart';
import '../settings/theme_screen.dart' show LgThemeIdL10n;
import '../community/community_screens.dart';
import '../support/support_screens.dart';

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
  /// Ikki marta bosish: bitta dialog, bitta chiqish (qulf dialogdan oldin).
  Future<void> _signOut(BuildContext context) =>
      SingleFlight.run(#profileSignOut, () => _signOutOnce(context));

  Future<void> _signOutOnce(BuildContext context) async {
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

  /// Hamma qurilmalardan chiqish (server `logout-all`): shu va boshqa
  /// qurilmalardagi sessiyalar o'chadi; shu qurilmadagi ma'lumot saqlanadi.
  /// Xato (internet yo'q) bo'lsa — hech qayerda chiqilmagan, xabar ko'rsatiladi.
  Future<void> _signOutAll(BuildContext context) => SingleFlight.run(
    #profileSignOutAll,
    () async {
      final services = context.services;
      final l = AppLocalizations.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final backend = services.backend;
      if (backend is! SessionsBackend) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.profileSignOutAll),
          content: Text(l.profileSignOutAllBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l.actionCancel),
            ),
            TextButton(
              key: const ValueKey('sign-out-all-confirm'),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l.profileSignOutAll),
            ),
          ],
        ),
      );
      if (ok != true) return;
      try {
        await (backend as SessionsBackend).signOutEverywhere();
      } on Object catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(backendErrorText(e, l))));
        return;
      }
      await services.auth.signOut();
      await services.settings.resetOnboarding();
      messenger.showSnackBar(SnackBar(content: Text(l.profileSignOutAllDone)));
    },
  );

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    final settings = services.settings;
    final auth = services.auth;
    final access = services.access;
    return ListenableBuilder(
      listenable: Listenable.merge([settings, auth, access]),
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
            // Malaka toifasi (KDL attestatsiyasi) tildan mustaqil boshqariladi.
            // Shifokor va talabaga bo'lim baribir ko'rsatilmaydi — sozlama ham
            // yashirin.
            if (settings.role != AppRole.doctor &&
                settings.role != AppRole.student) ...[
              LgSectionTitle(l.profileAttestation),
              Wrap(
                key: const ValueKey('profile-attestation'),
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final (region, label) in [
                    (AttestationRegion.auto, l.profileAttestationAuto),
                    (AttestationRegion.uz, l.profileAttestationUz),
                    (AttestationRegion.none, l.profileAttestationNone),
                  ])
                    LgChoiceChip(
                      label: label,
                      selected: settings.attestationRegion == region,
                      onTap: () => settings.setAttestationRegion(region),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(l.profileAttestationNote, style: text.bodySmall),
            ],
            LgSectionTitle(l.profileAppearance),
            LgRow(
              key: const ValueKey('profile-theme-row'),
              title: l.themeTitle,
              subtitle: '${settings.appTheme.title(l)} · ${l.themeRowSub}',
              icon: Icons.palette_outlined,
              onTap: () => context.push('/profile/theme'),
              divider: false,
            ),
            const SizedBox(height: 4),
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
            // Yagona “Yordam va aloqa” (D-69 Q6): ichida ilova ichidagi
            // yozishma va email/shikoyat. Serverga bog'liq emas — doim
            // ko'rinadi (email yo'li doim ishlaydi).
            LgRow(
              key: const ValueKey('profile-help'),
              title: l.helpTitle,
              subtitle: l.helpSub,
              icon: Icons.support_agent_outlined,
              trailing: access.unreadReplies > 0
                  ? LgTag(
                      l.supportUnreadCount(access.unreadReplies),
                      tone: LgTone.brand,
                    )
                  : null,
              onTap: () => context.push('/profile/help'),
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
            // Hamkorlik — faqat hamkor UI yoqilgan (test) buildda.
            if (BuildFlags.partnerAds)
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
            if (access.access.adminAccount || access.access.panelAdmin)
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
            if (auth.hasAccount &&
                services.backend is SessionsBackend &&
                services.backend.hasSession)
              LgButton.link(
                key: const ValueKey('profile-sign-out-all'),
                label: l.profileSignOutAll,
                icon: Icons.devices_other_outlined,
                onPressed: () => _signOutAll(context),
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
  /// Ikki marta bosish — bitta dialog va bitta o'chirish so'rovi (dialogdan
  /// oldin tarmoq so'rovi bor: qulf darhol qo'yiladi).
  Future<void> _confirmDeleteAccount(BuildContext context) => SingleFlight.run(
    #accountDelete,
    () => _confirmDeleteAccountOnce(context),
  );

  Future<void> _confirmDeleteAccountOnce(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final services = context.services;
    final messenger = ScaffoldMessenger.of(context);
    final backend = services.backend;
    final social = services.auth.social;
    final socialBackend = social.backend;
    final apple = social.provider(SocialProvider.apple);
    // Apple (App Store 5.1.1(v)): hisob Apple bilan bog'langan bo'lsa, o'chirishda
    // Apple tokeni bekor qilinadi — buning uchun Apple'dan yangi tasdiq olinadi.
    var appleLinked = false;
    if (socialBackend != null && apple != null && apple.isSupported) {
      try {
        appleLinked = (await socialBackend.linkedProviders()).contains(
          SocialProvider.apple,
        );
      } on Object {
        appleLinked = false;
      }
    }
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.accountDeleteTitle),
        content: Text(
          [
            l.accountDeleteBody,
            if (appleLinked) l.accountDeleteAppleNote,
          ].join('\n\n'),
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
    String? appleCode;
    if (appleLinked) {
      try {
        final credential = await apple!.authenticate();
        if (credential == null) {
          // Foydalanuvchi Apple tasdig'ini bekor qildi: hech narsa o'chirilmaydi.
          messenger.showSnackBar(
            SnackBar(content: Text(l.accountDeleteAppleCancelled)),
          );
          return;
        }
        appleCode = credential.authorizationCode;
      } on Object {
        // Apple oynasi ochilmadi: hisobni o'chirish to'silmaydi (server
        // bekor qilish o'tkazib yuborilganini jurnalga yozadi).
        appleCode = null;
      }
    }
    try {
      if (socialBackend != null) {
        await socialBackend.deleteAccountWithApple(appleCode);
      } else {
        await backend.deleteAccount();
      }
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
        // Maxfiylik siyosatining o'zi (sayt) — audit 2026-10-18 (tablar).
        LgRow(
          key: const ValueKey('privacy-policy-link'),
          title: l.contactPrivacyPolicy,
          subtitle: l.contactPrivacyNote,
          icon: Icons.shield_outlined,
          onTap: () => openExternalLink(context, Contact.privacyPolicyUrl),
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
