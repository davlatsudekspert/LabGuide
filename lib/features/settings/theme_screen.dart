import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/theme.dart';
import '../../design/themes.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';

/// Mavzu nomi va qisqa tavsifi (lokalizatsiya qilingan).
extension LgThemeIdL10n on LgThemeId {
  String title(AppLocalizations l) => switch (this) {
    LgThemeId.classic => l.themeClassicName,
    LgThemeId.ivory => l.themeIvoryName,
  };

  String description(AppLocalizations l) => switch (this) {
    LgThemeId.classic => l.themeClassicDesc,
    LgThemeId.ivory => l.themeIvoryDesc,
  };
}

/// Profil → Mavzu (D-64): mavzu kartalari (nomi — mavzuning o'z sarlavha
/// shriftida, 5 rang nuqtasi, logotipli dumaloq belgi) va kunduzgi/tungi
/// rejim. Tanlov darhol butun ilovaga qo'llanadi va saqlanadi.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.services.settings;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        return LgPage(
          title: l.themeTitle,
          showProfile: false,
          children: [
            _CurrentThemeHeader(theme: settings.appTheme),
            const SizedBox(height: 8),
            for (final t in LgThemeId.values)
              _ThemeCard(
                key: ValueKey('theme-card-${t.name}'),
                theme: t,
                selected: settings.appTheme == t,
                onTap: () => settings.setAppTheme(t),
              ),
            LgSectionTitle(l.themeModeSection),
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
          ],
        );
      },
    );
  }
}

bool _cyrillic(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ru';

/// Mavzu nomi uslubi: serif mavzuda — serif, aks holda Inter sarlavha.
TextStyle _nameStyle(
  BuildContext context,
  LgThemeId theme,
  Color color, {
  required double size,
}) {
  final base = Theme.of(context).textTheme.headlineSmall!.copyWith(
    fontFamily: 'Inter',
    fontFamilyFallback: const <String>[],
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.15,
    color: color,
  );
  final serif = theme.style(Brightness.light).serifDisplay;
  return serif ? lgSerif(base, cyrillic: _cyrillic(context)) : base;
}

/// Sahifa tepasidagi joriy mavzu kartasi. Tungi Ivory'da — chuqur
/// dengiz-qora gradient.
class _CurrentThemeHeader extends StatelessWidget {
  const _CurrentThemeHeader({required this.theme});

  final LgThemeId theme;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final style = LgStyle.of(context);
    final brightness = Theme.of(context).brightness;
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LgRadius.hero),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: style.headerGradient,
          ),
          boxShadow: LgShadow.card(context),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              ThemeBadge(palette: p, ring: style.accentRing, size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LgEyebrow(l.themeCurrent),
                    Text(
                      theme.title(l),
                      textScaler: MediaQuery.textScalerOf(context)
                          .clamp(maxScaleFactor: 1.3),
                      style: _nameStyle(context, theme, p.ink, size: 30),
                    ),
                    const SizedBox(height: 10),
                    ThemeSwatches(
                      colors: theme.swatches(brightness),
                      border: p.outline,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    super.key,
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final LgThemeId theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    // Karta o'z mavzusi ranglarida — tanlashdan oldin ko'rinishi.
    final cp = theme.palette(brightness);
    final cs = theme.style(brightness);
    final text = Theme.of(context).textTheme;
    final current = LgPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LgRadius.card),
          boxShadow: LgShadow.card(context),
        ),
        child: LgPressable(
          onTap: onTap,
          selected: selected,
          semanticLabel: '${theme.title(l)}. ${theme.description(l)}',
          color: cp.paper,
          borderRadius: BorderRadius.circular(LgRadius.card),
          border: Border.all(
            color: selected ? current.brand : cp.line,
            width: selected ? 2 : 1,
          ),
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
              child: Row(
                children: [
                  ThemeBadge(palette: cp, ring: cs.accentRing, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.title(l),
                          textScaler: MediaQuery.textScalerOf(context)
                              .clamp(maxScaleFactor: 1.3),
                          style: _nameStyle(context, theme, cp.ink, size: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          theme.description(l),
                          style: text.bodySmall!.copyWith(
                            color: cp.sub,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ThemeSwatches(
                          colors: theme.swatches(brightness),
                          border: cp.outline,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _SelectMark(selected: selected, palette: cp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tanlov belgisi: tanlangan — to'ldirilgan doira va ✓, aks holda kontur.
class _SelectMark extends StatelessWidget {
  const _SelectMark({required this.selected, required this.palette});

  final bool selected;
  final LgPalette palette;

  @override
  Widget build(BuildContext context) {
    final duration = LgMotion.of(context, LgMotion.press);
    return AnimatedContainer(
      duration: duration,
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? palette.brand : Colors.transparent,
        border: Border.all(
          color: selected ? palette.brand : palette.outline,
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 17, color: palette.onBrand)
          : null,
    );
  }
}

/// Dumaloq belgi: LabGuide logotipi, Ivory'da ingichka oltin halqa.
class ThemeBadge extends StatelessWidget {
  const ThemeBadge({
    super.key,
    required this.palette,
    required this.ring,
    required this.size,
  });

  final LgPalette palette;
  final bool ring;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.paper,
          border: Border.all(
            color: ring ? palette.accent : palette.soft,
            width: ring ? 1.5 : 2,
          ),
        ),
        child: const ClipOval(
          child: Image(
            image: AssetImage('assets/images/logo_mark.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/// Mavzuning 5 rang nuqtasi (och ranglar ko'rinishi uchun ingichka kontur).
class ThemeSwatches extends StatelessWidget {
  const ThemeSwatches({super.key, required this.colors, required this.border});

  final List<Color> colors;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in colors)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: border.withValues(alpha: 0.45),
                    width: 0.8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
