import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/lg_page.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/lg_widgets.dart';
import '../../../l10n/gen/app_localizations.dart';

const kHeroImage = AssetImage('assets/images/molecular_hero.webp');

/// Kirish va welcome ekranlaridagi katta brend belgisi (yozuvsiz — yozuv
/// sahifada matn sifatida; `tool/icons/make_icons.py`). Shaffof yumaloq
/// burchakli, tashqi oq maydon yo'q; kunduzgi rejimda yumshoq soya.
class LgLogoHero extends StatelessWidget {
  const LgLogoHero({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(size * 0.22);
    return ExcludeSemantics(
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: dark
                ? null
                : [
                    BoxShadow(
                      color: LgPalette.of(context).shadow
                          .withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Image(
            image: const AssetImage('assets/images/logo_mark_large.png'),
            width: size,
            height: size,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final services = context.services;
    return LgPage(
      title: l.welcomeTitle,
      subtitle: l.welcomeSubtitle,
      eyebrow: l.welcomeEyebrow,
      showBrand: true,
      showProfile: false,
      leadingHero: const Padding(
        padding: EdgeInsets.only(bottom: 22, top: 8),
        child: LgLogoHero(),
      ),
      children: [
        LgPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const LgTag('UZ · RU · EN'),
                  Text(l.welcomeDevices, style: text.bodySmall),
                ],
              ),
              const SizedBox(height: 12),
              Text(l.welcomeRoles, style: text.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LgButton(
          label: l.welcomeGetStarted,
          onPressed: () => context.push('/welcome/auth'),
        ),
        const SizedBox(height: 10),
        LgButton.secondary(
          label: l.welcomeGuest,
          onPressed: () async {
            await services.auth.continueAsGuest();
            if (context.mounted) await context.push('/welcome/role');
          },
        ),
        const SizedBox(height: 4),
        LgButton.link(
          label: l.welcomeSignIn,
          onPressed: () => context.push('/welcome/auth'),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LgSpace.sm),
          child: Text(
            l.welcomeGuestNote,
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
        ),
      ],
    );
  }
}
