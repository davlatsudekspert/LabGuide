import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/lg_page.dart';
import '../../../core/single_flight.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/lg_widgets.dart';
import '../../../l10n/gen/app_localizations.dart';

const kHeroImage = AssetImage('assets/images/hero_schematic.webp');

/// Kirish va welcome ekranlaridagi katta brend belgisi (yozuvsiz — yozuv
/// sahifada matn sifatida; `tool/icons/make_icons.py`). Shaffof yumaloq
/// burchakli, tashqi oq maydon yo'q; kunduzgi rejimda yumshoq soya.
///
/// [halo] — welcome ekranida: belgi orqasida yumshoq radial nur (soft →
/// fon) va mayin kirish (xiradan, 0.92 → 1 masshtab). Reduced motion'da
/// animatsiyasiz.
class LgLogoHero extends StatelessWidget {
  const LgLogoHero({
    super.key,
    this.size = 120,
    this.halo = false,
    this.animate = true,
  });

  final double size;
  final bool halo;

  /// Halo bilan kirish animatsiyasi (ekranning o'z animatsiyasi bo'lsa — false).
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(size * 0.22);
    Widget mark = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: p.shadow.withValues(alpha: 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: Image(
        image: const AssetImage('assets/images/logo_mark_large.png'),
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
      ),
    );
    if (halo) {
      final glow = size * 2.1;
      mark = SizedBox(
        width: glow,
        height: size * 1.45,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: glow,
              height: glow,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.alphaBlend(p.brand.withValues(alpha: 0.10), p.soft),
                    p.soft.withValues(alpha: 0),
                  ],
                  stops: const [0.3, 1],
                ),
              ),
            ),
            mark,
          ],
        ),
      );
      if (animate && !LgMotion.reduced(context)) {
        mark = TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: LgMotion.enter * 1.5,
          curve: LgMotion.curve,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
          ),
          child: mark,
        );
      }
    }
    return ExcludeSemantics(child: Center(child: mark));
  }
}

/// Welcome ekranidagi bitta afzallik: ikonka badge, kimga va nima.
class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.body,
    this.divider = true,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: divider
              ? Border(bottom: BorderSide(color: p.line.withValues(alpha: 0.7)))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: p.soft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 21, color: p.brand),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: text.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: text.bodyMedium!.copyWith(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
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
        padding: EdgeInsets.only(bottom: 10),
        child: LgLogoHero(size: 88, halo: true),
      ),
      children: [
        // Uchta afzallik — har biri rolga mos: birinchi ekrandayoq
        // "bu ilova men uchunmi?" savoliga javob.
        LgFadeIn(
          delay: 0.15,
          child: LgPanel(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Benefit(
                  icon: Icons.medical_services_outlined,
                  title: l.welcomeBenefitDoctorTitle,
                  body: l.welcomeBenefitDoctorBody,
                ),
                _Benefit(
                  icon: Icons.biotech_outlined,
                  title: l.welcomeBenefitLabTitle,
                  body: l.welcomeBenefitLabBody,
                ),
                _Benefit(
                  icon: Icons.school_outlined,
                  title: l.welcomeBenefitLearnTitle,
                  body: l.welcomeBenefitLearnBody,
                  divider: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        LgFadeIn(
          delay: 0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LgButton(
                label: l.welcomeGetStarted,
                onPressed: () => context.push('/welcome/auth'),
              ),
              const SizedBox(height: 10),
              LgButton.secondary(
                label: l.welcomeGuest,
                // Ikki marta bosish — rol ekrani ikki marta ochilmaydi.
                onPressed: () => SingleFlight.run(#welcomeGuest, () async {
                  await services.auth.continueAsGuest();
                  if (context.mounted) await context.push('/welcome/role');
                }),
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
          ),
        ),
      ],
    );
  }
}
