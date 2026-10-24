import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import 'instrument_catalog.dart';
import 'instrument_screens.dart' show CatalogGate;
import 'lab_direction_card.dart';

String _kindLabel(AppLocalizations l, LabCardKind k) => switch (k) {
  LabCardKind.platform => l.labDirKindPlatform,
  LabCardKind.test => l.labDirKindTest,
  LabCardKind.method => l.labDirKindMethod,
};

String _directionLabel(AppLocalizations l, LabDirection d) => switch (d) {
  LabDirection.tb => l.labDirTb,
  LabDirection.hiv => l.labDirHiv,
};

/// Bosh ekrandagi “TB va OIV” bo'limi (kartalar bo'lsa).
class LabDirectionRows extends StatelessWidget {
  const LabDirectionRows({super.key, required this.catalog});

  final InstrumentCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final dirs = [
      for (final d in LabDirection.values)
        if (catalog.labCardsIn(d).isNotEmpty) d,
    ];
    if (dirs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.labDirSection),
        for (final (i, d) in dirs.indexed)
          LgRow(
            title: _directionLabel(l, d),
            subtitle: l.labDirSectionSub,
            icon: Icons.biotech_outlined,
            divider: i < dirs.length - 1,
            onTap: () => context.push('/lab/instruments/d/${d.name}'),
          ),
      ],
    );
  }
}

class LabDirectionScreen extends StatelessWidget {
  const LabDirectionScreen({super.key, required this.direction});

  final String direction;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final d = LabDirection.values.where((x) => x.name == direction).firstOrNull;
    return CatalogGate(
      builder: (context, catalog) {
        final cards = d == null ? <LabDirectionCard>[] : catalog.labCardsIn(d);
        return LgPage(
          title: d == null ? l.labDirSection : _directionLabel(l, d),
          subtitle: l.labDirDisclaimer,
          children: [
            if (cards.isEmpty) LgNotice(l.labDirEmpty),
            for (final (i, c) in cards.indexed)
              LgRow(
                title: c.name.of(lang),
                subtitle: '${_kindLabel(l, c.kind)} · ${l.labDirTag}',
                icon: Icons.science_outlined,
                divider: i < cards.length - 1,
                onTap: () => context.push('/lab/instruments/lc/${c.id}'),
              ),
          ],
        );
      },
    );
  }
}

class LabCardScreen extends StatelessWidget {
  const LabCardScreen({super.key, required this.cardId});

  final String cardId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CatalogGate(
      builder: (context, catalog) {
        final card = catalog.labCard(cardId);
        if (card == null) {
          return LgPage(
            title: l.instOpenCard,
            children: [
              LgStateView(kind: StateKind.empty, title: l.instNoResultsTitle),
            ],
          );
        }
        return _LabCard(catalog: catalog, card: card);
      },
    );
  }
}

class _LabCard extends StatelessWidget {
  const _LabCard({required this.catalog, required this.card});

  final InstrumentCatalog catalog;
  final LabDirectionCard card;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;

    Widget field(String title, List<SourcedText> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(title),
        if (items.isEmpty)
          Text(l.labDirNotVerified, style: text.bodyMedium)
        else
          for (final t in items) ...[
            Text(t.text.of(lang), style: text.bodyLarge),
            Text(
              t.sourceIds
                  .map((s) => catalog.sources[s]?.title ?? s)
                  .join(' · '),
              style: text.bodySmall,
            ),
            const SizedBox(height: 8),
          ],
      ],
    );

    SourcedText? s(SourcedText? t) => t;
    List<SourcedText> one(SourcedText? t) => [?s(t)];

    return LgPage(
      title: card.name.of(lang),
      eyebrow: _directionLabel(l, card.direction),
      subtitle: _kindLabel(l, card.kind),
      children: [
        LgTag(l.labDirTag, tone: LgTone.warning),
        const SizedBox(height: 8),
        Text(l.labDirStatusLine, style: text.bodySmall),
        const SizedBox(height: 8),
        LgNotice(l.labDirDisclaimer),
        if (card.instrumentVsTestNote case final n?) ...[
          LgSectionTitle(l.labDirVsTest),
          Text(n.of(lang), style: text.bodyLarge),
        ],
        field(l.labDirTechnology, one(card.technology)),
        field(l.labDirSpecimens, card.specimens),
        field(l.labDirTasks, card.tasks),
        field(l.labDirPrinciple, one(card.principle)),
        field(l.labDirLimitations, card.limitations),
        field(l.labDirQc, one(card.qcCalibrationNote)),
        field(l.labDirErrors, card.preanalyticAnalyticErrors),
        field(l.labDirBiosafety, one(card.biosafety)),
        LgSectionTitle(l.labDirModels),
        Text(
          card.models.isEmpty ? l.labDirNotVerified : card.models.join(', '),
          style: text.bodyLarge,
        ),
        if (card.linked.isNotEmpty) ...[
          LgSectionTitle(l.labDirLinked),
          for (final (i, id) in card.linked.indexed)
            if (catalog.labCard(id) case final other?)
              LgRow(
                title: other.name.of(lang),
                subtitle: _kindLabel(l, other.kind),
                icon: Icons.link_rounded,
                divider: i < card.linked.length - 1,
                onTap: () => context.push('/lab/instruments/lc/$id'),
              ),
        ],
        LgSectionTitle(l.instSources),
        for (final (i, id) in card.allSourceIds.toSet().toList().indexed)
          if (catalog.sources[id] case final src?)
            LgRow(
              title: src.title,
              subtitle: [?src.docRef, l.instAccessed(src.accessed)].join(' · '),
              icon: Icons.open_in_new_rounded,
              divider: i < card.allSourceIds.toSet().length - 1,
              onTap: () => openExternalLink(context, src.url),
            ),
      ],
    );
  }
}
