import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Ilova mavzulari reestri (D-64). Har mavzu — kunduzgi va tungi
/// [LgPalette] hamda shakl/tipografika "uslubi" ([LgStyle]). Ekranlar faqat
/// tokenlardan foydalanadi, shuning uchun mavzu almashganda hammasi birga
/// o'zgaradi.
enum LgThemeId {
  /// Asl LabGuide: iliq ivory + forest yashil (tungi — yashil-qora + lime).
  classic,

  /// Ivory: fil suyagi sirtlar, deyarli qora asosiy rang, oltin aksent,
  /// katta sarlavhalar serif shriftda. Tungi — ko'mir/siyoh fon, ivory matn.
  ivory;

  static LgThemeId? tryParse(String? raw) {
    for (final t in values) {
      if (t.name == raw) return t;
    }
    return null;
  }

  LgPalette palette(Brightness brightness) => switch (this) {
    classic =>
      brightness == Brightness.light ? LgPalette.light : LgPalette.dark,
    ivory =>
      brightness == Brightness.light
          ? LgPalette.ivoryLight
          : LgPalette.ivoryDark,
  };

  LgStyle style(Brightness brightness) => switch (this) {
    classic =>
      brightness == Brightness.light ? LgStyle.classic : LgStyle.classicDark,
    ivory =>
      brightness == Brightness.light ? LgStyle.ivoryLight : LgStyle.ivoryDark,
  };

  /// Tanlash kartasidagi 5 ta rang nuqtasi (fon → aksent → asosiy).
  List<Color> swatches(Brightness brightness) {
    final p = palette(brightness);
    return switch (this) {
      // Klassik: fon, yumshoq, lime, kulrang-yashil, forest.
      classic => [
        p.bg,
        p.soft,
        LgPalette.dark.brand,
        p.sub,
        LgPalette.light.brand,
      ],
      ivory => [p.bg, p.soft, p.accent, p.sub, p.brand],
    };
  }
}

/// Mavzuning rangdan tashqari xususiyatlari: sarlavha shrifti, teg va
/// tanlangan holat ko'rinishi, dekorativ gradient.
@immutable
class LgStyle extends ThemeExtension<LgStyle> {
  const LgStyle({
    required this.id,
    this.serifDisplay = false,
    this.outlinedTags = false,
    this.solidSelection = false,
    this.accentRing = false,
    this.pillControls = false,
    required this.headerGradient,
  });

  final LgThemeId id;

  /// Katta sarlavhalar (displaySmall / headlineMedium / headlineSmall)
  /// tor, yuqori kontrastli serif shriftda.
  final bool serifDisplay;

  /// [LgTag] — to'ldirilgan pill o'rniga ingichka konturli pill, bosh
  /// harflar va keng harf oralig'i.
  final bool outlinedTags;

  /// Pastki menyuda tanlangan tab — asosiy rangli (qora) kapsula, ikonka
  /// [LgPalette.onBrand] rangida.
  final bool solidSelection;

  /// Dumaloq belgilar (Lab tugmasi, mavzu belgisi) atrofida ingichka
  /// [LgPalette.accent] (oltin) halqa.
  final bool accentRing;

  /// Tugma va filtr chiplari — to'liq kapsula (pill) shaklida.
  final bool pillControls;

  /// [pillControls] bo'lsa — kapsula, aks holda berilgan radius.
  double controlRadius(double fallback) => pillControls ? 999 : fallback;

  /// Mavzu tanlash ekranining sarlavha kartasi foni.
  final List<Color> headerGradient;

  static const classic = LgStyle(
    id: LgThemeId.classic,
    headerGradient: [Color(0xFFE9EFE1), Color(0xFFFFFEF9)],
  );

  static const classicDark = LgStyle(
    id: LgThemeId.classic,
    headerGradient: [Color(0xFF223A31), Color(0xFF172828)],
  );

  static const ivoryLight = LgStyle(
    id: LgThemeId.ivory,
    serifDisplay: true,
    outlinedTags: true,
    solidSelection: true,
    accentRing: true,
    pillControls: true,
    headerGradient: [Color(0xFFFCFBF8), Color(0xFFEAE6DD)],
  );

  /// Tungi Ivory: sarlavha kartasi chuqur dengiz-qora gradientda.
  static const ivoryDark = LgStyle(
    id: LgThemeId.ivory,
    serifDisplay: true,
    outlinedTags: true,
    solidSelection: true,
    accentRing: true,
    pillControls: true,
    headerGradient: [Color(0xFF0A0E1A), Color(0xFF1B1F2B)],
  );

  static LgStyle of(BuildContext context) =>
      Theme.of(context).extension<LgStyle>() ?? classic;

  @override
  LgStyle copyWith({
    LgThemeId? id,
    bool? serifDisplay,
    bool? outlinedTags,
    bool? solidSelection,
    bool? accentRing,
    bool? pillControls,
    List<Color>? headerGradient,
  }) => LgStyle(
    id: id ?? this.id,
    serifDisplay: serifDisplay ?? this.serifDisplay,
    outlinedTags: outlinedTags ?? this.outlinedTags,
    solidSelection: solidSelection ?? this.solidSelection,
    accentRing: accentRing ?? this.accentRing,
    pillControls: pillControls ?? this.pillControls,
    headerGradient: headerGradient ?? this.headerGradient,
  );

  @override
  LgStyle lerp(ThemeExtension<LgStyle>? other, double t) {
    if (other is! LgStyle) return this;
    final base = t < 0.5 ? this : other;
    return base.copyWith(
      headerGradient: [
        for (var i = 0; i < headerGradient.length; i++)
          Color.lerp(headerGradient[i], other.headerGradient[i], t)!,
      ],
    );
  }
}
