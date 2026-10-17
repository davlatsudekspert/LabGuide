import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../core/build_flags.dart';
import '../../core/contact.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';

/// “Aloqa va shikoyat” — serverni talab qilmaydigan, DOIM ochiq ekran:
/// savol/taklif, shikoyat (va faqat hamkor UI yoqilgan test buildda —
/// reklama) — hammasi `mailto:` (pochta ilovasi)
/// orqali, manzil [Contact.email]'da. Pochta ilovasi bo'lmasa manzil
/// nusxalanadi. Xat matniga faqat ilova versiyasi va platforma qo'yiladi —
/// shaxsiy ma'lumot yo'q.
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _copy(BuildContext context, {String? message}) async {
    final messenger = ScaffoldMessenger.of(context);
    final text = message ?? AppLocalizations.of(context).contactCopied;
    await Clipboard.setData(const ClipboardData(text: Contact.email));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Pochta ilovasini ochadi; ochilmasa (ilova yo'q, xato) manzilni
  /// nusxalab, buni aytadi — “ochildi” deb yolg'on aytilmaydi.
  Future<void> _mail(BuildContext context, Uri uri) async {
    final noApp = AppLocalizations.of(context).contactNoMailApp;
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      opened = false;
    }
    if (!opened && context.mounted) await _copy(context, message: noApp);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final services = context.services;
    final version = services.config.appVersion;
    final platform = defaultTargetPlatform.name;
    return LgPage(
      title: l.contactTitle,
      subtitle: l.contactIntro,
      showProfile: false,
      children: [
        LgPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.contactEmailLabel, style: text.bodySmall),
              const SizedBox(height: 4),
              SelectableText(
                Contact.email,
                key: const ValueKey('contact-email'),
                style: text.titleMedium,
              ),
              const SizedBox(height: 12),
              LgButton.secondary(
                key: const ValueKey('contact-copy'),
                label: l.contactCopy,
                icon: Icons.copy_rounded,
                onPressed: () => _copy(context),
              ),
            ],
          ),
        ),
        LgSectionTitle(l.contactQuestionTitle),
        Text(l.contactQuestionBody, style: text.bodyLarge),
        const SizedBox(height: 10),
        LgButton(
          key: const ValueKey('contact-mail-question'),
          label: l.contactQuestionAction,
          icon: Icons.mail_outline_rounded,
          onPressed: () => _mail(
            context,
            Contact.mailto(
              subject: Contact.subjectQuestion,
              body: l.contactMailBodyQuestion(version, platform),
            ),
          ),
        ),
        // Reklama/hamkorlik — faqat hamkor UI yoqilgan (test) buildda.
        if (BuildFlags.partnerAds) ...[
          LgSectionTitle(l.contactAdTitle),
          Text(l.contactAdBody, style: text.bodyLarge),
          const SizedBox(height: 10),
          LgButton.secondary(
            key: const ValueKey('contact-mail-ad'),
            label: l.contactAdAction,
            icon: Icons.campaign_outlined,
            onPressed: () => _mail(
              context,
              Contact.mailto(
                subject: Contact.subjectAd,
                body: l.contactMailBodyAd(version, platform),
              ),
            ),
          ),
          // Ariza shakli faqat server ulangan buildda ishlaydi.
          if (services.backend.isConfigured)
            LgButton.link(
              key: const ValueKey('contact-partner-link'),
              label: l.partnerBecome,
              icon: Icons.handshake_outlined,
              onPressed: () => context.push('/profile/partnership'),
            ),
        ],
        LgSectionTitle(l.contactReportTitle),
        Text(l.contactReportBody, style: text.bodyLarge),
        const SizedBox(height: 8),
        Text(l.contactReportHint, style: text.bodyMedium),
        const SizedBox(height: 10),
        LgButton.secondary(
          key: const ValueKey('contact-mail-report'),
          label: l.contactReportAction,
          icon: Icons.flag_outlined,
          onPressed: () => _mail(
            context,
            Contact.mailto(
              subject: Contact.subjectReport,
              body: l.contactMailBodyReport(version, platform),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(l.contactResponseNote, style: text.bodySmall),
        const SizedBox(height: 16),
        LgRow(
          key: const ValueKey('contact-privacy'),
          title: l.contactPrivacyPolicy,
          subtitle: l.contactPrivacyNote,
          icon: Icons.shield_outlined,
          onTap: () => openExternalLink(context, Contact.privacyPolicyUrl),
          divider: false,
        ),
      ],
    );
  }
}
