import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../core/backend/partner_models.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../instruments/instrument_catalog.dart';
import '../instruments/instrument_screens.dart' show CatalogGate, categoryIcon;

// Hamkor (reklama) bloklari. Qoidalar:
// * har blokda aniq “Reklama” yoki “Hamkor” yorlig'i;
// * katalog ma'lumot bo'limidan alohida, oxirida — faktlar, tartib va
//   tekshiruv holatiga ta'sir qilmaydi;
// * haqiqiy faol hamkor bo'lmasa (yoki server sozlanmagan bo'lsa) — hech
//   narsa chizilmaydi.

String partnerKindLabel(PartnerKind k, AppLocalizations l) => switch (k) {
  PartnerKind.manufacturer => l.partnerKindManufacturer,
  PartnerKind.distributor => l.partnerKindDistributor,
  PartnerKind.service => l.partnerKindService,
  PartnerKind.laboratory => l.partnerKindLaboratory,
};

String partnerRegionsText(Partner p, String lang) =>
    p.regions.map((r) => uzRegionName(r, lang)).join(', ');

/// Reklama yorlig'i: rangsiz holatda ham matn va ikonka bilan ajraladi.
class PartnerTag extends StatelessWidget {
  const PartnerTag(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      LgTag(text, tone: LgTone.warning, icon: Icons.campaign_outlined);
}

/// Kompaniya logosi (server URL). Yuklanmasa yoki internet bo'lmasa —
/// bosh harflar (soxta rasm qo'yilmaydi).
class PartnerLogo extends StatelessWidget {
  const PartnerLogo({super.key, required this.partner, this.size = 48});

  final Partner partner;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final initials = partner.name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w.characters.first.toUpperCase())
        .join();
    final fallback = Center(
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          color: p.brand,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
        ),
        textScaler: TextScaler.noScaling,
      ),
    );
    final url = partner.logoUrl;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: p.soft,
          borderRadius: BorderRadius.circular(size * 0.28),
          border: Border.all(color: p.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: url == null
            ? fallback
            : Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

/// Blok birinchi marta chizilganda bitta “ko'rsatilish” yuboradi (kuniga
/// bir marta — dublikatni controller tashlaydi).
class _Impression extends StatefulWidget {
  const _Impression({
    required this.partner,
    required this.placement,
    required this.child,
  });

  final Partner partner;
  final PartnerPlacement placement;
  final Widget child;

  @override
  State<_Impression> createState() => _ImpressionState();
}

class _ImpressionState extends State<_Impression> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.services.partners.trackImpression(
        widget.partner,
        widget.placement,
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Hamkor bilan bog'lanish: “bog'lanish” hisoblagichi + tashqi ilova.
Future<void> contactPartner(
  BuildContext context,
  Partner partner,
  PartnerPlacement placement,
  String url,
) {
  context.services.partners.trackContact(partner, placement);
  return openExternalLink(context, url);
}

/// Ixcham aloqa tugmalari (telefon, Telegram; ular bo'lmasa — sayt/email).
/// Joy yetsa yonma-yon, tor ekran yoki katta shriftda — ustma-ust.
class PartnerQuickContacts extends StatelessWidget {
  const PartnerQuickContacts({
    super.key,
    required this.partner,
    required this.placement,
  });

  final Partner partner;
  final PartnerPlacement placement;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = partner;
    final actions = <(IconData, String, String)>[
      if (p.phone case final phone?)
        (Icons.call_outlined, l.partnerCall, telUri(phone)),
      if (p.telegram case final tg?)
        (Icons.send_outlined, l.partnerTelegram, 'https://t.me/$tg'),
      if (p.phone == null && p.telegram == null) ...[
        if (p.website case final site?)
          (Icons.language_rounded, l.partnerWebsite, site),
        if (p.email case final email?)
          (Icons.mail_outline_rounded, l.partnerEmail, 'mailto:$email'),
      ],
    ];
    if (actions.isEmpty) return const SizedBox.shrink();
    final buttons = [
      for (final (i, (icon, label, url)) in actions.indexed)
        _ContactButton(
          icon: icon,
          label: label,
          primary: i == 0,
          onTap: () => contactPartner(context, p, placement, url),
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final side = buttons.length > 1 && constraints.maxWidth / scale >= 260;
        if (side) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, b) in buttons.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: b),
              ],
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, b) in buttons.indexed) ...[
              if (i > 0) const SizedBox(height: 8),
              b,
            ],
          ],
        );
      },
    );
  }
}

/// Aloqa tugmasi: birinchisi — asosiy (to'q), qolgani yumshoq fonli.
class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final fg = primary ? p.onBrand : p.brand;
    return LgPressable(
      onTap: onTap,
      color: primary ? p.brand : p.soft,
      borderRadius: BorderRadius.circular(LgRadius.button),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTap + 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: fg),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge!
                      .copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kichik “Batafsil →” havolasi (chapga tekislangan, bosish maydoni ≥ 44).
class _MoreLink extends StatelessWidget {
  const _MoreLink({required this.label, this.onTap});

  final String label;

  /// `null` — faqat ko'rinish (butun karta bosiladi).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kMinTap),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: onTap == null ? 0 : 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall!
                    .copyWith(color: p.brand),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded, size: 18, color: p.brand),
          ],
        ),
      ),
    );
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: onTap == null
          ? ExcludeSemantics(child: row)
          : LgPressable(onTap: onTap, child: row),
    );
  }
}

/// Reklamadan hamkor sahifasiga: oldingi xabar (snackbar) yopiladi.
void _openPartner(BuildContext context, Partner p) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  context.push('/lab/partners/${p.id}');
}

class _PartnerHeader extends StatelessWidget {
  const _PartnerHeader({required this.partner, this.logoSize = 48});

  final Partner partner;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        PartnerLogo(partner: partner, size: logoSize),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(partner.name, style: text.titleMedium),
              const SizedBox(height: 2),
              Text(partnerKindLabel(partner.kind, l), style: text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

/// Reklama kartasining umumiy “qobig'i”: ma'lumot panellaridan farqli —
/// chegara bilan ajratilgan.
class _AdFrame extends StatelessWidget {
  const _AdFrame({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final radius = BorderRadius.circular(LgRadius.card);
    final body = Padding(padding: const EdgeInsets.all(16), child: child);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: onTap == null
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: p.paper,
                borderRadius: radius,
                border: Border.all(color: p.line),
              ),
              child: body,
            )
          : LgPressable(
              onTap: onTap,
              color: p.paper,
              borderRadius: radius,
              border: Border.all(color: p.line),
              child: body,
            ),
    );
  }
}

/// Bir qator ikonka + matn (hudud, guvohnoma).
class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 16, color: p.sub),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

/// Apparat kartasining oxiridagi “Rasmiy hamkorlar” bo'limi.
class InstrumentPartnersSection extends StatefulWidget {
  const InstrumentPartnersSection({super.key, required this.model});

  final InstrumentModel model;

  @override
  State<InstrumentPartnersSection> createState() =>
      _InstrumentPartnersSectionState();
}

class _InstrumentPartnersSectionState extends State<InstrumentPartnersSection> {
  @override
  void initState() {
    super.initState();
    context.services.partners.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final controller = context.services.partners;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final list = controller.forModel(widget.model);
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            LgSectionTitle(
              l.partnerOfficialTitle,
              trailing: PartnerTag(l.partnerAdLabel),
            ),
            Text(l.partnerSectionNote, style: text.bodySmall),
            const SizedBox(height: 6),
            for (final p in list)
              _Impression(
                partner: p,
                placement: PartnerPlacement.card,
                child: _AdFrame(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PartnerHeader(partner: p),
                      if (p.summaryOf(lang).isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(p.summaryOf(lang), style: text.bodyMedium),
                      ],
                      if (p.regions.isNotEmpty)
                        _InfoLine(
                          icon: Icons.place_outlined,
                          text: l.partnerRegions(partnerRegionsText(p, lang)),
                        ),
                      if (p.registrationFor(widget.model.id) case final no?)
                        _InfoLine(
                          icon: Icons.assignment_outlined,
                          text:
                              '${l.partnerRegistration(no)}\n'
                              '${l.partnerRegistrationNote}',
                        ),
                      const SizedBox(height: 12),
                      PartnerQuickContacts(
                        partner: p,
                        placement: PartnerPlacement.card,
                      ),
                      const SizedBox(height: 6),
                      _MoreLink(
                        label: l.partnerMore,
                        onTap: () => _openPartner(context, p),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Yo'nalish ichidagi ixcham “Hamkor” kartalari (ko'pi bilan ikkitasi,
/// har kuni navbat bilan).
class CategoryPartnerCards extends StatefulWidget {
  const CategoryPartnerCards({
    super.key,
    required this.catalog,
    required this.category,
  });

  final InstrumentCatalog catalog;
  final InstrumentCategory category;

  @override
  State<CategoryPartnerCards> createState() => _CategoryPartnerCardsState();
}

class _CategoryPartnerCardsState extends State<CategoryPartnerCards> {
  @override
  void initState() {
    super.initState();
    context.services.partners.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.services.partners;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final list = controller
            .forCategory(widget.catalog, widget.category)
            .take(2)
            .toList();
        if (list.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final p in list)
                PartnerCompactCard(
                  partner: p,
                  placement: PartnerPlacement.category,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Ixcham karta: logo, nom, tur, bir-ikki qator tavsif → hamkor sahifasi.
class PartnerCompactCard extends StatelessWidget {
  const PartnerCompactCard({
    super.key,
    required this.partner,
    required this.placement,
  });

  final Partner partner;
  final PartnerPlacement placement;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final summary = partner.summaryOf(lang);
    return _Impression(
      partner: partner,
      placement: placement,
      child: _AdFrame(
        onTap: () => _openPartner(context, partner),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PartnerTag('${l.partnerLabel} · ${l.partnerAdLabel}'),
            const SizedBox(height: 10),
            Row(
              children: [
                PartnerLogo(partner: partner, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(partner.name, style: text.titleSmall),
                      Text(
                        partnerKindLabel(partner.kind, l),
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
                ExcludeSemantics(
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: p.sub,
                    size: 22,
                  ),
                ),
              ],
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                summary,
                style: text.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lab bosh sahifasidagi bitta reklama kartasi (faqat haqiqiy faol hamkor
/// bo'lsa).
class LabPartnerCard extends StatefulWidget {
  const LabPartnerCard({super.key});

  @override
  State<LabPartnerCard> createState() => _LabPartnerCardState();
}

class _LabPartnerCardState extends State<LabPartnerCard> {
  @override
  void initState() {
    super.initState();
    context.services.partners.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final controller = context.services.partners;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.featured;
        if (p == null) return const SizedBox.shrink();
        final summary = p.summaryOf(lang);
        return Padding(
          padding: const EdgeInsets.only(top: 18),
          child: _Impression(
            partner: p,
            placement: PartnerPlacement.labHome,
            child: _AdFrame(
              onTap: () => _openPartner(context, p),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: PartnerTag(l.partnerAdLabel),
                  ),
                  const SizedBox(height: 12),
                  _PartnerHeader(partner: p, logoSize: 44),
                  if (summary.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      summary,
                      style: text.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  _MoreLink(label: l.partnerMore),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Asosiy menyu (Bosh sahifa) reklama joylari — qidiruvdan darhol keyin:
/// 1 — laboratoriya xizmati ([PartnerPlacement.homeLab]), 2 — apparat firmasi
/// ([PartnerPlacement.homeEquipment]). Ikkalasi yonma-yon bir juft ixcham
/// karta (birinchi ekranda ko'rinadi); tor ekranda (< 360 px) yoki katta
/// shriftda (> 1.15×) ustma-ust ixcham qatorlar.
///
/// Har joy uchun:
/// * haqiqiy faol hamkor bor — hamkor kartasi (kunlik aylanish,
///   ko'rsatilish/bog'lanish hisoblagichi bilan);
/// * hamkor yo'q, demo/test build (`allFeaturesOpen`) — aniq “Namuna / Demo”
///   belgili o'rin: kompaniya, telefon, Telegram yo'q, hisoblagich yo'q;
/// * hamkor yo'q, do'kon (release) build — hech narsa chizilmaydi.
class HomePartnerPair extends StatefulWidget {
  const HomePartnerPair({super.key});

  @override
  State<HomePartnerPair> createState() => _HomePartnerPairState();
}

class _HomePartnerPairState extends State<HomePartnerPair> {
  @override
  void initState() {
    super.initState();
    context.services.partners.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.services.partners;
    final demoBuild = context.services.entitlements.allFeaturesOpen;
    final media = MediaQuery.of(context);
    final scale = media.textScaler.scale(16) / 16;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final slots = <(PartnerPlacement, Partner?)>[
          for (final pl in const [
            PartnerPlacement.homeLab,
            PartnerPlacement.homeEquipment,
          ])
            if (controller.forHome(pl) case final p?)
              (pl, p)
            else if (demoBuild)
              (pl, null),
        ];
        if (slots.isEmpty) return const SizedBox.shrink();
        final tiles =
            slots.length == 2 && media.size.width >= 360 && scale <= 1.15;
        Widget card((PartnerPlacement, Partner?) s) => HomeAdSlotCard(
          // Hamkor almashganda ko'rsatilish yangidan sanalsin.
          key: ValueKey('${s.$1.wire}/${s.$2?.id}'),
          placement: s.$1,
          partner: s.$2,
          tile: tiles,
        );
        if (!tiles) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (final s in slots) card(s)],
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: card(slots[0])),
                const SizedBox(width: 8),
                Expanded(child: card(slots[1])),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Juda kichik “Reklama” yorlig'i (ikonka + matn: rangga tayanmaydi).
class _MiniAdTag extends StatelessWidget {
  const _MiniAdTag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.amberBg,
        borderRadius: BorderRadius.circular(LgRadius.tag),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(Icons.campaign_outlined, size: 12, color: p.amber),
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall!
                    .copyWith(color: p.amber, height: 1.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bosh sahifadagi bitta reklama joyi kartasi: haqiqiy hamkor yoki (demo
/// buildda hamkor yo'q bo'lsa) “Namuna / Demo” o'rni. [tile] — yonma-yon
/// juftlikdagi tor karta; aks holda to'liq kenglikdagi bir qatorli karta.
class HomeAdSlotCard extends StatelessWidget {
  const HomeAdSlotCard({
    super.key,
    required this.placement,
    required this.tile,
    this.partner,
  });

  final PartnerPlacement placement;

  /// `null` — namuna (faqat demo/test build).
  final Partner? partner;
  final bool tile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final p = LgPalette.of(context);
    final size = tile ? 20.0 : 44.0;
    final partner = this.partner;
    if (partner != null) {
      final summary = partner.summaryOf(lang);
      final kind = partnerKindLabel(partner.kind, l);
      return _Impression(
        partner: partner,
        placement: placement,
        child: _HomeAdFrame(
          tile: tile,
          leading: PartnerLogo(partner: partner, size: size),
          title: partner.name,
          body: summary.isEmpty ? kind : summary,
          footer: '$kind · ${l.partnerMore}',
          onTap: () => _openPartner(context, partner),
        ),
      );
    }
    // Namuna: soxta kompaniya emas — nom, logo, aloqa yo'q; ko'rsatilish ham
    // sanalmaydi.
    return _HomeAdFrame(
      tile: tile,
      demo: true,
      leading: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: p.paper,
            borderRadius: BorderRadius.circular(size * 0.28),
            border: Border.all(color: p.line),
          ),
          child: Icon(
            placement == PartnerPlacement.homeLab
                ? Icons.biotech_outlined
                : Icons.precision_manufacturing_outlined,
            color: p.sub,
            size: size * 0.55,
          ),
        ),
      ),
      title: l.homeAdDemoTitle,
      body: placement == PartnerPlacement.homeLab
          ? l.homeAdDemoLabBody
          : l.homeAdDemoEquipmentBody,
      footer: '${l.homeAdDemoCta} →',
      onTap: () => context.push('/profile/partnership'),
    );
  }
}

/// Reklama kartasining ixcham “qobig'i”: [tile] — yonma-yon juftlik uchun
/// (yorliq + belgi qatori, so'ng matn), aks holda chapda belgi, o'ngda matn.
class _HomeAdFrame extends StatelessWidget {
  const _HomeAdFrame({
    required this.tile,
    required this.leading,
    required this.title,
    required this.body,
    required this.footer,
    required this.onTap,
    this.demo = false,
  });

  final bool tile;
  final Widget leading;
  final String title;
  final String body;
  final String footer;
  final VoidCallback onTap;

  /// Namuna: yumshoq fon — haqiqiy kartadan ajralib turadi.
  final bool demo;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: text.labelLarge,
    );
    final bodyText = Text(
      body,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: text.bodySmall,
    );
    final footerText = Text(
      footer,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: text.labelMedium!.copyWith(color: p.brand),
    );
    final Widget content = tile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(child: _MiniAdTag(l.partnerAdLabel)),
                  const Spacer(),
                  leading,
                ],
              ),
              const SizedBox(height: 1),
              titleText,
              bodyText,
              const SizedBox(height: 1),
              footerText,
            ],
          )
        : Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _MiniAdTag(l.partnerAdLabel),
                        const SizedBox(width: 6),
                        Expanded(child: titleText),
                      ],
                    ),
                    const SizedBox(height: 1),
                    bodyText,
                    const SizedBox(height: 1),
                    footerText,
                  ],
                ),
              ),
            ],
          );
    final frame = LgPressable(
      onTap: onTap,
      color: demo ? p.soft : p.paper,
      borderRadius: BorderRadius.circular(LgRadius.card),
      border: Border.all(color: p.line),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tile ? 10 : 12,
          vertical: tile ? 5 : 6,
        ),
        child: content,
      ),
    );
    return tile
        ? frame
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: frame,
          );
  }
}

/// Hamkor sahifasi: tavsif, aloqa, bog'liq apparatlar (guvohnoma raqami
/// bilan), buklet. Butun sahifa — reklama (yorliq va izoh bilan).
class PartnerScreen extends StatefulWidget {
  const PartnerScreen({super.key, required this.partnerId});

  final String partnerId;

  @override
  State<PartnerScreen> createState() => _PartnerScreenState();
}

class _PartnerScreenState extends State<PartnerScreen> {
  @override
  void initState() {
    super.initState();
    context.services.partners.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = context.services.partners;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.byId(widget.partnerId);
        if (p == null) {
          return LgPage(
            title: l.partnerLabel,
            children: [
              LgStateView(
                kind: StateKind.empty,
                title: l.partnerNotFoundTitle,
                message: l.partnerNotFoundBody,
              ),
            ],
          );
        }
        return CatalogGate(
          builder: (context, catalog) => _Impression(
            partner: p,
            placement: PartnerPlacement.partnerPage,
            child: _PartnerPage(partner: p, catalog: catalog),
          ),
        );
      },
    );
  }
}

class _PartnerPage extends StatelessWidget {
  const _PartnerPage({required this.partner, required this.catalog});

  final Partner partner;
  final InstrumentCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final p = partner;
    const placement = PartnerPlacement.partnerPage;
    final makers = [
      for (final link in p.links)
        if (link.target == PartnerLinkTarget.maker)
          ?catalog.makers.where((m) => m.id == link.catalogId).firstOrNull,
    ];
    final models = [
      for (final link in p.links)
        if (link.target == PartnerLinkTarget.model)
          if (catalog.model(link.catalogId) case final m?) (m, link),
    ];
    final contacts = [
      if (p.phone case final phone?)
        (Icons.call_outlined, l.partnerCall, phone, telUri(phone)),
      if (p.telegram case final tg?)
        (Icons.send_outlined, l.partnerTelegram, '@$tg', 'https://t.me/$tg'),
      if (p.website case final site?)
        (
          Icons.language_rounded,
          l.partnerWebsite,
          Uri.tryParse(site)?.host ?? site,
          site,
        ),
      if (p.email case final email?)
        (Icons.mail_outline_rounded, l.partnerEmail, email, 'mailto:$email'),
      if (p.brochureUrl case final url?)
        (
          Icons.picture_as_pdf_outlined,
          l.partnerBrochure,
          Uri.tryParse(url)?.host ?? url,
          url,
        ),
    ];
    return LgPage(
      title: p.name,
      eyebrow: partnerKindLabel(p.kind, l),
      children: [
        Row(
          children: [
            PartnerLogo(partner: p, size: 64),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PartnerTag(l.partnerAdLabel),
                  if (p.regions.isNotEmpty)
                    _InfoLine(
                      icon: Icons.place_outlined,
                      text: l.partnerRegions(partnerRegionsText(p, lang)),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (p.summaryOf(lang).isNotEmpty) ...[
          LgSectionTitle(l.partnerAbout),
          Text(p.summaryOf(lang), style: text.bodyLarge),
        ],
        if (contacts.isNotEmpty) LgSectionTitle(l.partnerContacts),
        for (final (i, (icon, title, sub, url)) in contacts.indexed)
          LgRow(
            title: title,
            subtitle: sub,
            icon: icon,
            divider: i < contacts.length - 1,
            onTap: () => contactPartner(context, p, placement, url),
          ),
        if (makers.isNotEmpty || models.isNotEmpty)
          LgSectionTitle(l.partnerInstruments),
        for (final mk in makers)
          LgRow(
            title: l.partnerAllModels(mk.name),
            icon: Icons.factory_outlined,
            divider: models.isNotEmpty || mk != makers.last,
          ),
        for (final (i, (m, link)) in models.indexed)
          LgRow(
            title: '${catalog.maker(m.makerId).name} ${m.model}',
            subtitle: [
              m.kind.of(lang),
              if (link.registrationNo case final no?) l.partnerRegistration(no),
            ].join('\n'),
            icon: categoryIcon(m.category),
            divider: i < models.length - 1,
            onTap: () => context.push('/lab/instruments/m/${m.id}'),
          ),
        if (models.any((e) => e.$2.registrationNo != null))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l.partnerRegistrationNote, style: text.bodySmall),
          ),
        const SizedBox(height: 10),
        LgNotice(l.partnerPageNote),
        const SizedBox(height: 4),
        LgButton.link(
          label: l.partnerBecome,
          icon: Icons.handshake_outlined,
          onPressed: () => context.push('/profile/partnership'),
        ),
      ],
    );
  }
}
