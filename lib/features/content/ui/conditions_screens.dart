import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/lg_page.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/lg_widgets.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../condition_search.dart';
import '../content_model.dart';
import 'analyte_screen.dart';
import 'content_widgets.dart';
import 'tests_screen.dart';

// ------------------------------------------------------------ umumiy

IconData systemIcon(ConditionSystem s) => switch (s) {
  ConditionSystem.endocrine => Icons.scatter_plot_outlined,
  ConditionSystem.kidney => Icons.water_drop_outlined,
  ConditionSystem.liver => Icons.healing_outlined,
  ConditionSystem.digestive => Icons.restaurant_outlined,
  ConditionSystem.cardio => Icons.monitor_heart_outlined,
  ConditionSystem.blood => Icons.bloodtype_outlined,
  ConditionSystem.infection => Icons.coronavirus_outlined,
  ConditionSystem.rheumatology => Icons.back_hand_outlined,
  ConditionSystem.bone => Icons.elderly_outlined,
  ConditionSystem.pregnancy => Icons.pregnant_woman_outlined,
  ConditionSystem.prostate => Icons.male_outlined,
};

String systemName(ConditionSystem s, AppLocalizations l) => switch (s) {
  ConditionSystem.endocrine => l.condSysEndocrine,
  ConditionSystem.kidney => l.condSysKidney,
  ConditionSystem.liver => l.condSysLiver,
  ConditionSystem.digestive => l.condSysDigestive,
  ConditionSystem.cardio => l.condSysCardio,
  ConditionSystem.blood => l.condSysBlood,
  ConditionSystem.infection => l.condSysInfection,
  ConditionSystem.rheumatology => l.condSysRheumatology,
  ConditionSystem.bone => l.condSysBone,
  ConditionSystem.pregnancy => l.condSysPregnancy,
  ConditionSystem.prostate => l.condSysProstate,
};

String tierName(PanelTier t, AppLocalizations l) => switch (t) {
  PanelTier.firstLine => l.condTierFirstLine,
  PanelTier.additional => l.condTierAdditional,
  PanelTier.monitoring => l.condTierMonitoring,
};

String tierHint(PanelTier t, AppLocalizations l) => switch (t) {
  PanelTier.firstLine => l.condTierFirstLineHint,
  PanelTier.additional => l.condTierAdditionalHint,
  PanelTier.monitoring => l.condTierMonitoringHint,
};

IconData tierIcon(PanelTier t) => switch (t) {
  PanelTier.firstLine => Icons.looks_one_rounded,
  PanelTier.additional => Icons.add_circle_outline_rounded,
  PanelTier.monitoring => Icons.timeline_rounded,
};

/// Tab ildizi (masalan, `/tests` yoki `/library/saved`): holat va analit
/// kartalari shu tab stekida ochiladi — “orqaga” kelgan joyga qaytaradi.
String tabBase(String location) {
  var end = location.length;
  for (final marker in ['/conditions', '/analyte/']) {
    final i = location.indexOf(marker);
    if (i >= 0 && i < end) end = i;
  }
  return location.substring(0, end);
}

/// Birinchi navbatdagi tahlillar nomlari (ro'yxat qatori izohi uchun).
String firstLineSummary(ClinicalCondition c, String lang) {
  final names = <String>[];
  for (final t in c.panelFor(PanelTier.firstLine)) {
    final n = t.names.of(lang);
    if (!names.contains(n)) names.add(n);
  }
  return names.join(' · ');
}

/// Holat qatori: nom, tizim ikonkasi va birinchi navbatdagi tahlillar.
class ConditionRow extends StatelessWidget {
  const ConditionRow({
    super.key,
    required this.condition,
    required this.onTap,
    this.divider = true,
    this.subtitle,
  });

  final ClinicalCondition condition;
  final VoidCallback onTap;
  final bool divider;

  /// Berilmasa — “Avval: …” (birinchi navbatdagi tahlillar).
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return LgRow(
      title: condition.names.of(lang),
      subtitle:
          subtitle ?? l.condRowFirstLine(firstLineSummary(condition, lang)),
      icon: systemIcon(condition.system),
      onTap: onTap,
      divider: divider,
    );
  }
}

// ------------------------------------------------------------ ro'yxat

class ConditionsScreen extends StatefulWidget {
  const ConditionsScreen({super.key, this.autofocus = false});

  /// Bosh sahifadagi qidiruv maydonidan kelinganda — klaviatura darhol.
  final bool autofocus;

  @override
  State<ConditionsScreen> createState() => _ConditionsScreenState();
}

class _ConditionsScreenState extends State<ConditionsScreen> {
  final _query = TextEditingController();
  ConditionSystem? _system;
  ConditionSearch? _search;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _clear() {
    _query.clear();
    setState(() => _system = null);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final location = GoRouterState.of(context).matchedLocation;
    return LgPage(
      title: l.condGuideTitle,
      subtitle: l.condListSubtitle,
      children: [
        SearchBox(
          controller: _query,
          label: l.condSearchLabel,
          hint: l.condSearchHint,
          autofocus: widget.autofocus,
          onChanged: (_) => setState(() {}),
        ),
        ContentGate(
          builder: (context, pack) {
            final search = _search?.pack == pack
                ? _search!
                : _search = ConditionSearch(pack);
            final results = search.search(
              _query.text,
              system: _system,
              lang: lang,
            );
            final systems = [
              for (final s in ConditionSystem.values)
                if (pack.conditions.any((c) => c.system == s)) s,
            ];
            final grouped = _query.text.trim().isEmpty && _system == null;
            void open(ClinicalCondition c) =>
                context.push('$location/${c.id}');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SystemFilter(
                  systems: systems,
                  selected: _system,
                  allLabel: l.testsFilterAll,
                  onSelect: (s) => setState(() => _system = s),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 2),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      l.condCount(results.length),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                if (results.isEmpty)
                  LgStateView(
                    kind: StateKind.empty,
                    title: l.condEmptyTitle,
                    message: l.condEmptyBody,
                    actionLabel: l.testsClearSearch,
                    onAction: _clear,
                  )
                else if (grouped)
                  for (final s in systems) ...[
                    _SystemHeader(
                      system: s,
                      count: results.where((c) => c.system == s).length,
                    ),
                    for (final c in results.where((c) => c.system == s))
                      ConditionRow(condition: c, onTap: () => open(c)),
                  ]
                else
                  for (var i = 0; i < results.length; i++)
                    ConditionRow(
                      condition: results[i],
                      divider: i < results.length - 1,
                      onTap: () => open(results[i]),
                    ),
                const SizedBox(height: 12),
                LgNotice(
                  l.condNotDiagnosticBody,
                  title: l.condNotDiagnosticTitle,
                  kind: NoticeKind.info,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SystemFilter extends StatelessWidget {
  const _SystemFilter({
    required this.systems,
    required this.selected,
    required this.allLabel,
    required this.onSelect,
  });

  final List<ConditionSystem> systems;
  final ConditionSystem? selected;
  final String allLabel;
  final ValueChanged<ConditionSystem?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          LgChoiceChip(
            label: allLabel,
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final s in systems) ...[
            const SizedBox(width: 6),
            LgChoiceChip(
              label: systemName(s, l),
              selected: selected == s,
              onTap: () => onSelect(selected == s ? null : s),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tizim sarlavhasi: ikonka, nom va holatlar soni.
class _SystemHeader extends StatelessWidget {
  const _SystemHeader({required this.system, required this.count});

  final ConditionSystem system;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 4),
      child: Semantics(
        header: true,
        child: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: p.brand,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(systemIcon(system), size: 19, color: p.onBrand),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(systemName(system, l), style: text.titleLarge),
            ),
            const SizedBox(width: 8),
            Text(l.condCount(count), style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ holat kartasi

class ConditionScreen extends StatelessWidget {
  const ConditionScreen({super.key, required this.conditionId});

  final String conditionId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return ContentGateOr(
      fallbackTitle: l.condGuideTitle,
      builder: (context, pack) {
        final c = pack.condition(conditionId);
        if (c == null) {
          return LgPage(
            title: l.condGuideTitle,
            children: [
              LgStateView(
                kind: StateKind.empty,
                title: l.condEmptyTitle,
                actionLabel: l.actionBack,
                onAction: () => context.pop(),
              ),
            ],
          );
        }
        return LgPage(
          title: c.names.of(lang),
          subtitle: systemName(c.system, l),
          children: _ConditionBody(
            pack: pack,
            condition: c,
            lang: lang,
          ).build(context),
        );
      },
    );
  }
}

/// Paket yuklanmaguncha (yoki xato bo'lsa) oddiy sahifa ichida
/// [ContentGate]; tayyor bo'lsa — [builder] o'zi sahifani quradi.
class ContentGateOr extends StatelessWidget {
  const ContentGateOr({
    super.key,
    required this.fallbackTitle,
    required this.builder,
  });

  final String fallbackTitle;
  final Widget Function(BuildContext context, ContentPack pack) builder;

  @override
  Widget build(BuildContext context) {
    final content = context.services.content;
    return ListenableBuilder(
      listenable: content,
      builder: (context, _) {
        final pack = content.pack;
        if (pack != null) return builder(context, pack);
        return LgPage(
          title: fallbackTitle,
          children: [ContentGate(builder: (context, _) => const SizedBox())],
        );
      },
    );
  }
}

class _ConditionBody {
  _ConditionBody({
    required this.pack,
    required this.condition,
    required this.lang,
  });

  final ContentPack pack;
  final ClinicalCondition condition;
  final String lang;

  late final List<String> _sources = condition.sourceIds;

  /// Manba raqami holat kartasidagi tartib bo'yicha: [1][2].
  String cite(List<SourceRef> refs) {
    final seen = <int>{};
    return [
      for (final r in refs)
        if (seen.add(_sources.indexOf(r.sourceId) + 1))
          '[${_sources.indexOf(r.sourceId) + 1}]',
    ].join();
  }

  List<Widget> build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final location = GoRouterState.of(context).matchedLocation;
    final c = condition;
    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          LgTag(
            systemName(c.system, l),
            icon: systemIcon(c.system),
          ),
          LgTag(
            c.isReviewerApproved ? l.statusVerified : l.statusSourcedSample,
            tone: c.isReviewerApproved ? LgTone.brand : LgTone.warning,
            icon: Icons.menu_book_rounded,
          ),
        ],
      ),
      const SizedBox(height: 6),
      LgNotice(l.condNotDiagnosticBody, title: l.condNotDiagnosticTitle),
      LgPanel(
        child: Text(
          '${c.summary.text.of(lang)} ${cite(c.summary.refs)}',
          style: text.bodyLarge,
        ),
      ),
      for (final tier in PanelTier.values)
        if (c.panelFor(tier) case final tests when tests.isNotEmpty) ...[
          _TierHeader(tier: tier, count: tests.length),
          for (final t in tests)
            _TestTile(
              test: t,
              lang: lang,
              cite: cite(t.refs),
              available: t.analyteId != null && pack.analyte(t.analyteId!) != null,
              onOpen: () => context.push('$location/analyte/${t.analyteId}'),
            ),
        ],
      if (c.patterns.isNotEmpty) ...[
        LgSectionTitle(l.condPatternsTitle),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(l.condPatternsHint, style: text.bodyMedium),
        ),
        for (final p in c.patterns)
          _PatternTile(pattern: p, lang: lang, cite: cite(p.refs)),
      ],
      if (c.cautions.isNotEmpty) ...[
        LgSectionTitle(l.condCautionsTitle),
        for (final w in c.cautions)
          LgNotice('${w.text.of(lang)} ${cite(w.refs)}', kind: NoticeKind.info),
      ],
      const SizedBox(height: 12),
      LgButton.secondary(
        label: l.condCopyList,
        icon: Icons.content_copy_rounded,
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          await Clipboard.setData(
            ClipboardData(text: referralText(c, lang, l)),
          );
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l.condCopied)));
        },
      ),
      Padding(
        padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
        child: Text(
          l.condCopyListSub,
          style: text.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
      _sourcesPanel(context, l),
      _reviewPanel(context, l, text),
    ];
  }

  Widget _sourcesPanel(BuildContext context, AppLocalizations l) {
    final text = Theme.of(context).textTheme;
    return LgPanel(
      margin: const EdgeInsets.only(top: 18, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.analyteSources, style: text.titleMedium),
          const SizedBox(height: 4),
          for (var i = 0; i < _sources.length; i++)
            if (pack.source(_sources[i]) case final s?)
              SourceTile(index: i + 1, source: s),
        ],
      ),
    );
  }

  Widget _reviewPanel(
    BuildContext context,
    AppLocalizations l,
    TextTheme text,
  ) {
    final approved = condition.isReviewerApproved;
    final dates = [
      for (final id in _sources) ?pack.source(id)?.accessed,
    ]..sort();
    final translationsPending = condition.translationReview.values.any(
      (v) => v != 'approved',
    );
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.analyteReview, style: text.titleMedium),
          const SizedBox(height: 6),
          LgMetric(
            label: l.analyteReview,
            value: approved ? l.analyteReviewApproved : l.analyteReviewPending,
          ),
          if (!approved)
            LgMetric(label: '—', value: l.analyteReviewerNotAssigned),
          LgMetric(label: l.analytePreparedBy, value: l.analyteEditorial),
          if (dates.isNotEmpty)
            LgMetric(label: l.analyteSourcesChecked, value: dates.last),
          if (translationsPending)
            LgMetric(label: 'UZ · RU · EN', value: l.analyteTranslationPending),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              l.analyteContentVersion(pack.contentVersion),
              style: text.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bemorga/hamkasbga yuboriladigan tahlillar ro'yxati (oddiy matn).
String referralText(ClinicalCondition c, String lang, AppLocalizations l) {
  final out = StringBuffer(l.condReferralTitle(c.names.of(lang)));
  for (final tier in PanelTier.values) {
    final names = <String>[];
    for (final t in c.panelFor(tier)) {
      final n = t.names.of(lang);
      if (!names.contains(n)) names.add(n);
    }
    if (names.isEmpty) continue;
    out.write('\n\n${tierName(tier, l)}:');
    for (final n in names) {
      out.write('\n• $n');
    }
  }
  out.write('\n\n${l.condReferralFooter}');
  return out.toString();
}

class _TierHeader extends StatelessWidget {
  const _TierHeader({required this.tier, required this.count});

  final PanelTier tier;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    // Daraja rang bilan emas, ikonka va matn bilan ajratiladi.
    final (Color bg, Color fg) = switch (tier) {
      PanelTier.firstLine => (p.brand, p.onBrand),
      PanelTier.additional => (p.soft, p.brand),
      PanelTier.monitoring => (p.amberBg, p.amber),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 6),
      child: Semantics(
        header: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(tierIcon(tier), size: 20, color: fg),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tierName(tier, l)} · $count',
                    style: text.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(tierHint(tier, l), style: text.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paneldagi tahlil: nom, nima uchun (manba bilan) va karta bo'lsa —
/// bosilganda analit kartasi ochiladi.
class _TestTile extends StatelessWidget {
  const _TestTile({
    required this.test,
    required this.lang,
    required this.cite,
    required this.available,
    required this.onOpen,
  });

  final PanelTest test;
  final String lang;
  final String cite;
  final bool available;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final body = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.names.of(lang),
                  style: text.titleSmall!.copyWith(
                    color: available ? p.brand : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${test.why.of(lang)} $cite', style: text.bodyMedium),
                if (!available) ...[
                  const SizedBox(height: 8),
                  LgTag(l.condNoCard, tone: LgTone.neutral),
                ],
              ],
            ),
          ),
          if (available) ...[
            const SizedBox(width: 6),
            ExcludeSemantics(
              child: Icon(Icons.chevron_right_rounded, color: p.sub, size: 22),
            ),
          ],
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: available
          ? LgPressable(
              onTap: onOpen,
              color: p.paper,
              borderRadius: BorderRadius.circular(LgRadius.button),
              child: body,
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                color: p.paper,
                borderRadius: BorderRadius.circular(LgRadius.button),
              ),
              child: Semantics(container: true, child: body),
            ),
    );
  }
}

/// “Mana bu chiqsa — mana bu ehtimoli bor”.
class _PatternTile extends StatelessWidget {
  const _PatternTile({
    required this.pattern,
    required this.lang,
    required this.cite,
  });

  final ResultPattern pattern;
  final String lang;
  final String cite;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        container: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: p.soft,
            borderRadius: BorderRadius.circular(LgRadius.button),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pattern.finding.of(lang),
                  style: text.titleSmall!.copyWith(color: p.brand),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: ExcludeSemantics(
                        child: Icon(
                          Icons.east_rounded,
                          size: 18,
                          color: p.brand,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${pattern.meaning.of(lang)} $cite',
                        style: text.bodyMedium!.copyWith(color: p.ink),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ kirish nuqtalari

/// Shifokor bosh sahifasidagi ko'zga tashlanadigan kirish: qidiruv
/// maydoni, mashhur holatlar (1 bosishda) va “Barcha holatlar”.
class ConditionGuideCard extends StatelessWidget {
  const ConditionGuideCard({
    super.key,
    required this.base,
    this.featured = const [],
  });

  /// Tab ildizi (masalan, `/home`).
  final String base;

  /// Bir bosishda ochiladigan holatlar id lari.
  final List<String> featured;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final pack = context.services.content.pack;
    final conditions = pack?.conditions ?? const <ClinicalCondition>[];
    final systems = {for (final c in conditions) c.system}.length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LgRadius.hero),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.soft, p.paper],
          ),
          boxShadow: [
            BoxShadow(
              color: p.shadow.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 7),
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
                  ExcludeSemantics(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: p.brand,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.medical_information_outlined,
                        color: p.onBrand,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: LgEyebrow(l.condGuideEyebrow)),
                ],
              ),
              const SizedBox(height: 12),
              Semantics(
                header: true,
                child: Text(l.condGuideTitle, style: text.headlineMedium),
              ),
              const SizedBox(height: 6),
              Text(l.condGuideBody, style: text.bodyMedium),
              if (conditions.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    LgTag(
                      l.condCount(conditions.length),
                      icon: Icons.checklist_rounded,
                    ),
                    LgTag(
                      l.condSystemCount(systems),
                      tone: LgTone.neutral,
                      icon: Icons.category_outlined,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              _FakeSearchField(
                hint: l.condGuideSearch,
                onTap: () => context.push('$base/conditions?search=1'),
              ),
              if (pack != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final id in featured)
                      if (pack.condition(id) case final c?)
                        _QuickChip(
                          label: c.names.of(lang),
                          icon: systemIcon(c.system),
                          onTap: () => context.push('$base/conditions/${c.id}'),
                        ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              LgButton(
                label: l.condGuideAll,
                icon: Icons.arrow_forward_rounded,
                onPressed: () => context.push('$base/conditions'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Qidiruv maydoniga o'xshash tugma: bosilganda ro'yxat ochiladi va
/// klaviatura darhol chiqadi.
class _FakeSearchField extends StatelessWidget {
  const _FakeSearchField({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return LgPressable(
      onTap: onTap,
      color: p.paper,
      semanticLabel: hint,
      border: Border.all(color: p.outline.withValues(alpha: 0.6)),
      borderRadius: BorderRadius.circular(LgRadius.button),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: p.sub),
              const SizedBox(width: 10),
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    hint,
                    style: text.bodyLarge!.copyWith(color: p.sub),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final style = Theme.of(context).textTheme.labelMedium!.copyWith(
      fontSize: 13,
      color: p.ink,
    );
    return LgPressable(
      onTap: onTap,
      color: p.paper,
      border: Border.all(color: p.outline.withValues(alpha: 0.6)),
      borderRadius: BorderRadius.circular(LgRadius.chip),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTap),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: p.brand),
              const SizedBox(width: 6),
              Flexible(child: Text(label, style: style)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tahlillar tabidagi kirish qatori.
class ConditionsEntryRow extends StatelessWidget {
  const ConditionsEntryRow({super.key, required this.base});

  final String base;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      child: LgPressable(
        onTap: () => context.push('$base/conditions'),
        color: p.soft,
        borderRadius: BorderRadius.circular(LgRadius.card),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: p.brand,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.medical_information_outlined,
                    color: p.onBrand,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.condGuideTitle, style: text.titleMedium),
                    const SizedBox(height: 2),
                    Text(l.condTestsEntrySub, style: text.bodySmall),
                  ],
                ),
              ),
              ExcludeSemantics(
                child: Icon(Icons.chevron_right_rounded, color: p.brand),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Analit kartasidagi teskari yo'nalish: shu tahlil qaysi holatlarda
/// buyuriladi (eng yuqori daraja bilan).
class AnalyteConditionsSection extends StatelessWidget {
  const AnalyteConditionsSection({
    super.key,
    required this.pack,
    required this.analyteId,
  });

  final ContentPack pack;
  final String analyteId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final conditions = pack.conditionsForAnalyte(analyteId);
    if (conditions.isEmpty) return const SizedBox.shrink();
    final base = tabBase(GoRouterState.of(context).matchedLocation);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.condAnalyteSection),
        for (var i = 0; i < conditions.length; i++)
          ConditionRow(
            condition: conditions[i],
            divider: i < conditions.length - 1,
            subtitle: [
              tierName(_bestTier(conditions[i]), l),
              systemName(conditions[i].system, l),
            ].join(' · '),
            onTap: () =>
                context.push('$base/conditions/${conditions[i].id}'),
          ),
      ],
    );
  }

  PanelTier _bestTier(ClinicalCondition c) => PanelTier.values.firstWhere(
    (t) => c.panelFor(t).any((p) => p.analyteId == analyteId),
  );
}
