import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/shell.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../content/ui/content_widgets.dart';
import '../content/ui/tests_screen.dart' show SearchBox;
import 'microscopy_atlas.dart';
import 'microscopy_controller.dart';
import 'microscopy_widgets.dart';

/// Bo'lim kartasi muqovasi (bo'lsa) — aks holda bo'limning birinchi rasmi.
const _sectionCovers = {
  'urine': 'u-cryst-uric-1',
  'blood': 'b-baso-1',
  'parasites': 'p-mal-thin-1',
};

/// Mashq kartasidagi doiralar.
const _heroMosaic = ['b-neut-2', 'u-cryst-triple-1', 'p-mal-thin-1'];

IconData microSectionIcon(String id) => switch (id) {
  'urine' => Icons.water_drop_outlined,
  'blood' => Icons.bloodtype_outlined,
  _ => Icons.bug_report_outlined,
};

/// Atlas bosh sahifasi: “Bu nima?” mashqi, qidiruv, bo'limlar, mualliflar.
class MicroscopyScreen extends StatefulWidget {
  const MicroscopyScreen({super.key});

  @override
  State<MicroscopyScreen> createState() => _MicroscopyScreenState();
}

class _MicroscopyScreenState extends State<MicroscopyScreen> {
  final _query = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return MicroAtlasGate(
      fallbackTitle: l.micTitle,
      builder: (context, atlas) {
        final results = _q.trim().isEmpty ? null : atlas.search(_q);
        return LgPage(
          title: l.micTitle,
          subtitle: l.micSubtitle,
          children: [
            SearchBox(
              controller: _query,
              label: l.micSearchLabel,
              hint: l.micSearchHint,
              onChanged: (v) => setState(() => _q = v),
            ),
            if (results == null) _QuizHero(atlas: atlas),
            if (results != null) ...[
              if (results.isEmpty)
                LgStateView(
                  kind: StateKind.empty,
                  title: l.micNoResultsTitle,
                  message: l.micNoResultsBody,
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    l.micResultsCount(microCards(atlas, results).length),
                    style: text.bodySmall,
                  ),
                ),
                LgTwoColumnGrid(children: microCards(atlas, results)),
              ],
            ] else ...[
              LgSectionTitle(l.micSections),
              for (final s in atlas.sections)
                _SectionCard(atlas: atlas, section: s),
              const SizedBox(height: 6),
              LgNotice(l.micEduNotice, kind: NoticeKind.info),
              LgRow(
                title: l.micCreditsRow,
                subtitle: l.micCreditsRowSub,
                icon: Icons.attribution_outlined,
                onTap: () => context.push('$microBase/credits'),
                divider: false,
              ),
              // Siydik mikroskopiyasi kartasi (kontent paketidan, bo'lsa).
              ContentGate(
                builder: (context, pack) {
                  final card = pack.analyte('urine-microscopy');
                  if (card == null) return const SizedBox.shrink();
                  return AnalyteRow(
                    analyte: card,
                    divider: false,
                    onTap: () =>
                        openInTab(context, '/tests/analyte/${card.id}'),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

/// “Bu nima?” mashqiga kirish kartasi (brend fonida).
class _QuizHero extends StatelessWidget {
  const _QuizHero({required this.atlas});

  final MicroAtlas atlas;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final c = context.services.microscopy;
    final mosaic = [for (final id in _heroMosaic) ?atlas.image(id)];
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final best = c.best(MicroscopyController.allScope);
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(LgRadius.hero),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [p.brand, Color.lerp(p.brand, p.ink, 0.28)!],
              ),
              boxShadow: [
                BoxShadow(
                  color: p.shadow.withValues(alpha: 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MicroMosaic(images: mosaic),
                      const Spacer(),
                      Icon(
                        Icons.quiz_outlined,
                        color: p.onBrand.withValues(alpha: 0.8),
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.micHeroEyebrow.toUpperCase(),
                    style: text.labelSmall!.copyWith(
                      color: p.onBrand.withValues(alpha: 0.85),
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Semantics(
                    header: true,
                    child: Text(
                      l.micQuizTitle,
                      style: text.headlineMedium!.copyWith(color: p.onBrand),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.micQuizHeroBody,
                    style: text.bodyMedium!.copyWith(
                      color: p.onBrand.withValues(alpha: 0.92),
                    ),
                  ),
                  if (best != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 18,
                          color: p.onBrand,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            l.micQuizBest(best.correct, best.total),
                            style: text.labelLarge!.copyWith(color: p.onBrand),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  LgButton.secondary(
                    label: l.micQuizCta,
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => context.push(microQuizRoute()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Bo'lim kartasi: muqova mikrofoto, nom, rasm soni.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.atlas, required this.section});

  final MicroAtlas atlas;
  final MicroSection section;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final images = atlas.imagesInSection(section.id);
    final gaps = atlas.gapsIn(section.id);
    final cover =
        atlas.image(_sectionCovers[section.id] ?? '') ?? images.firstOrNull;
    final name = section.name.of(lang);
    const radius = BorderRadius.all(Radius.circular(LgRadius.card));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LgPressable(
        onTap: () => context.push(microSectionRoute(section.id)),
        borderRadius: radius,
        semanticLabel:
            '$name. ${section.subtitle.of(lang)}. '
            '${l.micImagesCount(images.length)}',
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 168),
            child: Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                if (cover != null)
                  Positioned.fill(
                    child: Image(
                      image: microThumb(cover, width: MicroThumb.large),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.5),
                          Colors.black.withValues(alpha: 0.1),
                        ],
                        stops: const [0, 0.65, 1],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 40, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            microSectionIcon(section.id),
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              style: text.titleLarge!.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        section.subtitle.of(lang),
                        style: text.bodySmall!.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          MicroGlassPill(
                            l.micImagesCount(images.length),
                            icon: Icons.photo_library_outlined,
                          ),
                          if (gaps.isNotEmpty)
                            MicroGlassPill(
                              l.micGapsCount(gaps.length),
                              icon: Icons.hide_image_outlined,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bo'lim galereyasi: guruh filtri va rasm kartalari (rasmsiz turlar ham).
class MicroSectionScreen extends StatefulWidget {
  const MicroSectionScreen({super.key, required this.sectionId});

  final String sectionId;

  @override
  State<MicroSectionScreen> createState() => _MicroSectionScreenState();
}

class _MicroSectionScreenState extends State<MicroSectionScreen> {
  String? _group;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return MicroAtlasGate(
      fallbackTitle: l.micTitle,
      builder: (context, atlas) {
        final section = atlas.section(widget.sectionId);
        if (section == null) return const MicroNotFound();
        final groups = atlas.groupsIn(section.id);
        final shown = [
          for (final g in groups)
            if (_group == null || _group == g.id) g,
        ];
        return LgPage(
          title: section.name.of(lang),
          subtitle: section.subtitle.of(lang),
          children: [
            if (groups.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      LgChoiceChip(
                        label: l.micAllGroups,
                        selected: _group == null,
                        onTap: () => setState(() => _group = null),
                      ),
                      for (final g in groups) ...[
                        const SizedBox(width: 6),
                        LgChoiceChip(
                          label: g.name.of(lang),
                          selected: _group == g.id,
                          onTap: () => setState(
                            () => _group = _group == g.id ? null : g.id,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            for (final g in shown) ...[
              LgSectionTitle(
                g.name.of(lang),
                trailing: LgTag(
                  l.micImagesCount(
                    atlas
                        .entitiesIn(g.id)
                        .fold(0, (n, e) => n + atlas.imagesOf(e.id).length),
                  ),
                  tone: LgTone.neutral,
                ),
              ),
              LgTwoColumnGrid(
                gap: 12,
                children: microCards(atlas, atlas.entitiesIn(g.id)),
              ),
            ],
            const SizedBox(height: 14),
            if (atlas.quizImages(sectionId: section.id).isNotEmpty)
              LgButton.secondary(
                label: l.micSectionQuiz,
                icon: Icons.quiz_outlined,
                onPressed: () => context.push(microQuizRoute(section.id)),
              ),
          ],
        );
      },
    );
  }
}

/// Rasm kartasi: kattalashtirish, nomlar (uz/ru/en), asl izoh va tarjima,
/// preparat, draft tushuntirish, muallif/litsenziya/manba.
class MicroImageScreen extends StatelessWidget {
  const MicroImageScreen({super.key, required this.imageId});

  final String imageId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return MicroAtlasGate(
      fallbackTitle: l.micTitle,
      builder: (context, atlas) {
        final image = atlas.image(imageId);
        if (image == null) return const MicroNotFound();
        final entity = atlas.entity(image.entityId)!;
        final group = atlas.group(entity.groupId);
        final section = atlas.sectionOf(entity);
        final name = entity.name.of(lang);
        final others = [
          for (final i in atlas.imagesOf(entity.id))
            if (i.id != image.id) i,
        ];
        return LgPage(
          title: name,
          subtitle: '${section.name.of(lang)} · ${group.name.of(lang)}',
          children: [
            _ZoomableHero(image: image, name: name),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                LgTag(
                  l.micEduTag,
                  tone: LgTone.warning,
                  icon: Icons.school_outlined,
                ),
                LgTag(
                  image.license,
                  tone: LgTone.neutral,
                  icon: Icons.attribution_outlined,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _NamesPanel(entity: entity),
            if (image.labelNote != null) ...[
              const SizedBox(height: 12),
              _LabelNote(note: image.labelNote!.of(lang)),
            ],
            LgSectionTitle(l.micOriginalCaption),
            _CaptionPanel(image: image),
            LgSectionTitle(l.micPreparation),
            LgMetric(
              label: l.micMagnification,
              value: image.magnification ?? l.micNotStated,
            ),
            LgMetric(
              label: l.micStain,
              value: switch (image.stain) {
                null => l.micNotStated,
                final s when s.translation.of(lang) == s.text => s.text,
                final s => '${s.translation.of(lang)} (“${s.text}”)',
              },
            ),
            const SizedBox(height: 6),
            Text(l.micOnlySource, style: text.bodySmall),
            if (entity.note != null) ...[
              const SizedBox(height: 14),
              _DraftNote(note: entity.note!.of(lang)),
            ],
            LgSectionTitle(l.micCreditTitle),
            _CreditPanel(image: image),
            if (others.isNotEmpty) ...[
              LgSectionTitle(l.micSameEntity),
              LgTwoColumnGrid(
                children: [
                  for (final i in others)
                    MicroImageCard(atlas: atlas, image: i),
                ],
              ),
            ],
            const SizedBox(height: 16),
            LgButton.secondary(
              label: l.micSectionQuiz,
              icon: Icons.quiz_outlined,
              onPressed: () => context.push(microQuizRoute(section.id)),
            ),
          ],
        );
      },
    );
  }
}

class _ZoomableHero extends StatelessWidget {
  const _ZoomableHero({required this.image, required this.name});

  final MicroImage image;
  final String name;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const radius = BorderRadius.all(Radius.circular(LgRadius.card));
    return LgPressable(
      onTap: () => openMicroViewer(context, image, name),
      borderRadius: radius,
      semanticLabel: l.micOpenFull(name),
      child: Stack(
        children: [
          MicroPicture(
            image: image,
            cacheWidth: MicroThumb.large,
            borderRadius: radius,
            semanticLabel: l.micImageSemantics(name),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: MicroGlassPill(l.micZoom, icon: Icons.zoom_out_map_rounded),
          ),
        ],
      ),
    );
  }
}

class _NamesPanel extends StatelessWidget {
  const _NamesPanel({required this.entity});

  final MicroEntity entity;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final order = [
      lang,
      ...LocalizedText.requiredLanguages.where((x) => x != lang),
    ];
    return LgPanel(
      soft: true,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.micNames, style: text.labelSmall),
          const SizedBox(height: 6),
          for (final code in order)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    margin: const EdgeInsets.only(right: 10, top: 1),
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: code == lang ? p.brand : p.paper,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      code.toUpperCase(),
                      style: text.labelSmall!.copyWith(
                        color: code == lang ? p.onBrand : p.sub,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entity.name.of(code),
                      style: code == lang ? text.titleSmall : text.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CaptionPanel extends StatelessWidget {
  const _CaptionPanel({required this.image});

  final MicroImage image;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final caption = image.caption;
    return LgPanel(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote_rounded, color: p.brand, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.micCaptionLang(microLanguageName(l, caption.lang)),
                  style: text.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '“${caption.text}”',
            style: text.bodyLarge!.copyWith(fontStyle: FontStyle.italic),
          ),
          if (caption.lang != lang) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: p.line),
            ),
            Text(l.micTranslation, style: text.labelSmall),
            const SizedBox(height: 6),
            Text(caption.translation.of(lang), style: text.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Nom faqat manba izohiga tayanadi (mustaqil tekshiruv izohi).
class _LabelNote extends StatelessWidget {
  const _LabelNote({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LgRadius.card),
        border: Border.all(color: p.amber.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline_rounded, color: p.ink, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l.micLabelBySource, style: text.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LgTag(
              l.micLabelNoQuiz,
              tone: LgTone.warning,
              icon: Icons.quiz_outlined,
            ),
            const SizedBox(height: 10),
            Text(note, style: text.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _DraftNote extends StatelessWidget {
  const _DraftNote({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LgRadius.card),
        border: Border.all(color: p.amber.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.visibility_outlined, color: p.ink, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(l.micDraftTitle, style: text.titleMedium)),
              ],
            ),
            const SizedBox(height: 8),
            LgTag(
              l.micDraftTag,
              tone: LgTone.warning,
              icon: Icons.edit_note_rounded,
            ),
            const SizedBox(height: 10),
            Text(note, style: text.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _CreditPanel extends StatelessWidget {
  const _CreditPanel({required this.image});

  final MicroImage image;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final cdc = image.provider == MicroProvider.cdcPhil;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgMetric(label: l.micAuthor, value: image.author),
        LgMetric(
          label: l.micCredit,
          value: image.credit == 'Own work' ? l.micOwnWork : image.credit,
        ),
        LgMetric(label: l.micLicense, value: image.license),
        if (image.date != null)
          LgMetric(label: l.micSourceDate, value: image.date!),
        const SizedBox(height: 4),
        if (image.authorUrl case final url?)
          LgRow(
            title: l.micAuthorPage,
            subtitle: Uri.parse(url).host,
            icon: Icons.person_outline_rounded,
            onTap: () => openExternalLink(context, url),
          ),
        LgRow(
          title: l.micSourcePage,
          subtitle: image.sourceTitle,
          icon: Icons.open_in_new_rounded,
          onTap: () => openExternalLink(context, image.sourcePage),
        ),
        LgRow(
          title: l.micLicenseText(image.license),
          subtitle: Uri.parse(image.licenseUrl).host,
          icon: Icons.gavel_rounded,
          onTap: () => openExternalLink(context, image.licenseUrl),
        ),
        LgRow(
          title: l.micOriginalFile,
          subtitle: '${image.originalWidth}×${image.originalHeight} px',
          icon: Icons.image_outlined,
          onTap: () => openExternalLink(context, image.fileUrl),
          divider: false,
        ),
        const SizedBox(height: 8),
        Text(
          image.resized
              ? l.micResized(
                  image.width,
                  image.height,
                  image.originalWidth,
                  image.originalHeight,
                )
              : l.micNotResized(image.width, image.height),
          style: text.bodySmall,
        ),
        if (image.shareAlike) ...[
          const SizedBox(height: 6),
          Text(l.micShareAlike, style: text.bodySmall),
        ],
        if (cdc) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.soft,
              borderRadius: BorderRadius.circular(LgRadius.button),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.micCdcTerms, style: text.labelSmall),
                const SizedBox(height: 6),
                Text(
                  '“${image.termsQuote}”',
                  style: text.bodySmall!.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                Text(l.micCdcFree, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Barcha rasmlar: muallif, litsenziya, manba; litsenziya matnlari.
class MicroCreditsScreen extends StatelessWidget {
  const MicroCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    return MicroAtlasGate(
      fallbackTitle: l.micCreditsTitle,
      builder: (context, atlas) {
        final licenses = {
          for (final i in atlas.images) i.license: i.licenseUrl,
        };
        return LgPage(
          title: l.micCreditsTitle,
          subtitle: l.micCreditsSub,
          children: [
            Text(l.micCreditsIntro(atlas.accessed), style: text.bodyMedium),
            for (final provider in MicroProvider.values) ...[
              LgSectionTitle(switch (provider) {
                MicroProvider.commons => 'Wikimedia Commons',
                MicroProvider.cdcPhil =>
                  'CDC Public Health Image Library (PHIL)',
              }),
              for (final (k, i)
                  in atlas.images.where((i) => i.provider == provider).indexed)
                _CreditRow(
                  image: i,
                  name: atlas.entity(i.entityId)!.name.of(lang),
                  divider:
                      k <
                      atlas.images.where((x) => x.provider == provider).length -
                          1,
                ),
            ],
            LgSectionTitle(l.micLicenseTexts),
            for (final (k, e) in licenses.entries.indexed)
              LgRow(
                title: e.key,
                subtitle: e.value,
                icon: Icons.gavel_rounded,
                onTap: () => openExternalLink(context, e.value),
                divider: k < licenses.length - 1,
              ),
          ],
        );
      },
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({
    required this.image,
    required this.name,
    required this.divider,
  });

  final MicroImage image;
  final String name;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? Border(bottom: BorderSide(color: p.line.withValues(alpha: 0.7)))
            : null,
      ),
      child: LgPressable(
        onTap: () => context.push(microImageRoute(image.id)),
        borderRadius: BorderRadius.circular(14),
        semanticLabel: '$name. ${image.author}. ${image.license}',
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 64,
                  child: MicroPicture(
                    image: image,
                    aspectRatio: 1,
                    cacheWidth: MicroThumb.small,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: text.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        '${image.author} · ${image.license}',
                        style: text.bodySmall,
                      ),
                      Text(
                        image.sourceTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall!.copyWith(color: p.sub),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: p.sub),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
