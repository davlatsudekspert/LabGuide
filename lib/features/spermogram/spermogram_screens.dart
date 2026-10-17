import 'dart:math';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../learn/quiz_session.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart' show CalcSourceTile;
import '../tools/tool_screens.dart' show formatResult, parseFieldNumber;
import 'spermogram_content.dart';
import 'spermogram_logic.dart';

const spermBase = '/lab/spermogram';
const spermCardImage = 'assets/spermogram/card.png';

extension on BuildContext {
  String get _lang => Localizations.localeOf(this).languageCode;

  /// Matn joriy tilda.
  String tr(LocalizedText t) => t.of(_lang);

  /// Son ilova tilida (UZ/RU — vergul).
  String num(double v, {int decimals = 1}) => formatResult(
    v,
    Localizations.localeOf(this).toLanguageTag(),
    maxDecimals: decimals,
  );
}

/// "16 (15–18)" ko'rinishida pastki chegara.
String _limitText(BuildContext context, SpermLimit l) =>
    '${context.num(l.lower)} (${context.num(l.ciLow)}–${context.num(l.ciHigh)})';

/// Manbalar ro'yxati (lokator bilan).
class _Refs extends StatelessWidget {
  const _Refs(this.refs);

  final List<CalcRef> refs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.diffSourcesTitle),
        for (final (i, r) in refs.indexed) CalcSourceTile(index: i + 1, ref: r),
      ],
    );
  }
}

// ───────────────────────── Bosh sahifa ─────────────────────────

/// Spermogramma bo'limining bosh sahifasi.
class SpermogramScreen extends StatelessWidget {
  const SpermogramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = [
      (
        SpermL.limitsTitle,
        SpermL.limitsSub,
        Icons.table_chart_outlined,
        'limits',
      ),
      (
        SpermL.counterTitle,
        SpermL.counterSub,
        Icons.exposure_plus_1_rounded,
        'count',
      ),
      (
        SpermL.assessTitle,
        SpermL.assessSub,
        Icons.fact_check_outlined,
        'assess',
      ),
      (SpermL.termsTitle, SpermL.termsSub, Icons.menu_book_outlined, 'terms'),
      (SpermL.preTitle, SpermL.preSub, Icons.schedule_rounded, 'preanalytics'),
      (SpermL.quizTitle, SpermL.quizSub, Icons.quiz_outlined, 'quiz'),
    ];
    return LgPage(
      title: l.spermTitle,
      subtitle: context.tr(SpermL.subtitle),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  spermCardImage,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
        LgNotice(context.tr(SpermL.draftNote), title: l.diffDraftTag),
        for (final (i, (title, sub, icon, path)) in rows.indexed)
          LgRow(
            key: ValueKey('sperm-row-$path'),
            title: context.tr(title),
            subtitle: context.tr(sub),
            icon: icon,
            onTap: () => context.push('$spermBase/$path'),
            divider: i < rows.length - 1,
          ),
        LgSectionTitle(l.diffSourcesTitle),
        for (final (i, s) in SpermSources.all.indexed)
          CalcSourceTile(index: i + 1, ref: CalcRef(s, '')),
      ],
    );
  }
}

// ───────────────────────── Asosiy ko'rsatkichlar ─────────────────────────

class SpermLimitsScreen extends StatelessWidget {
  const SpermLimitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    return LgPage(
      title: context.tr(SpermL.limitsTitle),
      subtitle: l.spermTitle,
      children: [
        Text(context.tr(SpermL.limitsIntro), style: text.bodyMedium),
        LgNotice(context.tr(SpermL.notThreshold), kind: NoticeKind.error),
        const SizedBox(height: 4),
        for (final lim in spermLimits)
          Padding(
            key: ValueKey('sperm-limit-${lim.param.name}'),
            padding: const EdgeInsets.only(bottom: 8),
            child: LgPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${context.tr(spermParamNames[lim.param]!)}, '
                    '${context.tr(spermParamUnits[lim.param]!)}',
                    style: text.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${context.tr(SpermL.colLower)}: ',
                              style: text.bodySmall,
                            ),
                            TextSpan(
                              text: _limitText(context, lim),
                              style: text.titleMedium!.copyWith(
                                color: p.brand,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${context.tr(SpermL.colMedian)}: '
                        '${context.num(lim.median)} · N = ${lim.n}',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        Text(context.tr(SpermL.totalNote), style: text.bodySmall),
        LgSectionTitle(context.tr(SpermL.phTitle)),
        Text(context.tr(SpermL.phNote), style: text.bodyMedium),
        LgNotice(context.tr(SpermL.multiparam)),
        const _Refs([
          refTable83,
          refPopulation,
          refNotThreshold,
          refMultiparam,
          refTotalNumber,
          refPh,
          refPhCbavd,
          refEau,
        ]),
      ],
    );
  }
}

// ───────────────────────── Hisoblagich ─────────────────────────

class SpermCounterScreen extends StatefulWidget {
  const SpermCounterScreen({super.key});

  @override
  State<SpermCounterScreen> createState() => _SpermCounterScreenState();
}

class _SpermCounterScreenState extends State<SpermCounterScreen> {
  final _motility = MotilityCount();
  final _morph = MorphologyCount();
  final _defects = <MorphDefect>{};
  bool _morphMode = false;
  int _target = spermWhoTarget;

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  int get _total => _morphMode ? _morph.total : _motility.total;

  void _afterAdd() {
    HapticFeedback.selectionClick();
    if (_total == _target) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        context.tr(SpermL.targetReached),
        Directionality.of(context),
      );
    }
  }

  void _addGrade(MotilityGrade g) {
    setState(() => _motility.add(g));
    _afterAdd();
  }

  void _addNormal() {
    setState(_morph.addNormal);
    _afterAdd();
  }

  void _addAbnormal() {
    if (!_morph.addAbnormal(_defects)) {
      _snack(context.tr(SpermL.pickDefect));
      return;
    }
    setState(_defects.clear);
    _afterAdd();
  }

  void _undo() => setState(_morphMode ? _morph.undo : _motility.undo);

  void _reset() => setState(() {
    if (_morphMode) {
      _morph.reset();
      _defects.clear();
    } else {
      _motility.reset();
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final canUndo = _morphMode ? _morph.canUndo : _motility.canUndo;
    return LgPage(
      title: context.tr(SpermL.counterTitle),
      subtitle: l.spermTitle,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LgChoiceChip(
              key: const ValueKey('sperm-tab-motility'),
              label: context.tr(SpermL.tabMotility),
              selected: !_morphMode,
              onTap: () => setState(() => _morphMode = false),
            ),
            LgChoiceChip(
              key: const ValueKey('sperm-tab-morph'),
              label: context.tr(SpermL.tabMorph),
              selected: _morphMode,
              onTap: () => setState(() => _morphMode = true),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _Progress(
          total: _total,
          target: _target,
          onTarget: (t) => setState(() => _target = t),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            context.tr(_morphMode ? SpermL.morphHow : SpermL.motilityHow),
            style: text.bodySmall,
          ),
        ),
        if (_total >= _target)
          LgNotice(context.tr(SpermL.targetReached), kind: NoticeKind.info),
        if (_morphMode) ..._morphBody(context) else ..._motilityBody(context),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            LgButton.secondary(
              label: context.tr(SpermL.undo),
              icon: Icons.undo_rounded,
              expand: false,
              onPressed: canUndo ? _undo : null,
            ),
            LgButton.secondary(
              label: context.tr(SpermL.reset),
              icon: Icons.restart_alt_rounded,
              expand: false,
              onPressed: _total == 0 ? null : _reset,
            ),
          ],
        ),
        _Refs(
          _morphMode
              ? const [refMorph, refTzi, refTable83]
              : const [
                  refMotility,
                  refMotilityGrades,
                  refMotilityCalc,
                  refTable83,
                ],
        ),
      ],
    );
  }

  List<Widget> _motilityBody(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final pct = _motility.percents;
    final pr = _motility.progressive;
    final tm = _motility.totalMotility;
    return [
      _Grid(
        children: [
          for (final (i, g) in MotilityGrade.values.indexed)
            _CountButton(
              key: ValueKey('sperm-mot-${g.name}'),
              badge: motilityGrades[g]!.letter,
              label: context.tr(motilityGrades[g]!.name),
              count: _motility.count(g),
              percent: _motility.isEmpty ? null : '${pct[i]}%',
              onTap: () => _addGrade(g),
            ),
        ],
      ),
      if (!_motility.isEmpty) ...[
        _ResultLine(
          key: const ValueKey('sperm-res-pr'),
          label: context.tr(SpermL.progressive),
          value: '${context.num(pr!, decimals: 0)}%',
          limit: spermLimit(SpermParam.progressive),
          below: pr < spermLimit(SpermParam.progressive).lower,
        ),
        _ResultLine(
          key: const ValueKey('sperm-res-tm'),
          label: context.tr(SpermL.totalMotility),
          value: '${context.num(tm!, decimals: 0)}%',
          limit: spermLimit(SpermParam.totalMotility),
          below: tm < spermLimit(SpermParam.totalMotility).lower,
        ),
        const SizedBox(height: 6),
        Text(context.tr(SpermL.roundingNote), style: text.bodySmall),
      ],
    ];
  }

  List<Widget> _morphBody(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final np = _morph.normalPercent;
    final tzi = _morph.tzi;
    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final d in MorphDefect.values)
            LgChoiceChip(
              key: ValueKey('sperm-def-${d.name}'),
              label: context.tr(morphDefectNames[d]!),
              selected: _defects.contains(d),
              onTap: () => setState(() {
                if (!_defects.remove(d)) _defects.add(d);
              }),
            ),
        ],
      ),
      const SizedBox(height: 10),
      _Grid(
        children: [
          _CountButton(
            key: const ValueKey('sperm-morph-normal'),
            label: context.tr(SpermL.normal),
            count: _morph.normal,
            percent: np == null ? null : '${context.num(np)}%',
            onTap: _addNormal,
          ),
          _CountButton(
            key: const ValueKey('sperm-morph-abnormal'),
            label: context.tr(SpermL.abnormal),
            count: _morph.abnormal,
            percent: np == null ? null : '${context.num(100 - np)}%',
            onTap: _addAbnormal,
          ),
        ],
      ),
      if (np != null) ...[
        _ResultLine(
          key: const ValueKey('sperm-res-normal'),
          label: context.tr(SpermL.normalForms),
          value: '${context.num(np)}%',
          limit: spermLimit(SpermParam.normalForms),
          below: np < spermLimit(SpermParam.normalForms).lower,
        ),
        LgSectionTitle(context.tr(SpermL.defectsTitle)),
        for (final d in MorphDefect.values)
          LgMetric(
            label: context.tr(morphDefectNames[d]!),
            value:
                '${_morph.defect(d)} · ${context.num(_morph.defectPercent(d)!)}%',
          ),
        if (tzi != null)
          LgMetric(
            label: context.tr(SpermL.tzi),
            value: context.num(tzi, decimals: 2),
          ),
        const SizedBox(height: 6),
        Text(context.tr(SpermL.defectsNote), style: text.bodySmall),
        Text(context.tr(SpermL.tziNote), style: text.bodySmall),
      ],
      const SizedBox(height: 6),
      Text(context.tr(cytoplasmNote), style: text.bodySmall),
    ];
  }
}

class _Progress extends StatelessWidget {
  const _Progress({
    required this.total,
    required this.target,
    required this.onTarget,
  });

  final int total;
  final int target;
  final ValueChanged<int> onTarget;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final done = total >= target;
    return LgPanel(
      soft: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Semantics(
                liveRegion: true,
                label: '${context.tr(SpermL.counted)}: $total / $target',
                child: ExcludeSemantics(
                  child: Text.rich(
                    key: const ValueKey('sperm-total'),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$total',
                          style: text.displaySmall!.copyWith(
                            color: done ? p.brand : p.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: ' / $target',
                          style: text.titleLarge!.copyWith(color: p.sub),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Semantics(
                label: context.tr(SpermL.targetLabel),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final t in spermTargets)
                      LgChoiceChip(
                        label: '$t',
                        selected: target == t,
                        onTap: () => onTarget(t),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (total / target).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: p.paper,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ikki ustunli to'r (juda tor ekranda — bitta ustun).
class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final cols = c.maxWidth < 250 ? 1 : 2;
      return Column(
        children: [
          for (var i = 0; i < children.length; i += cols)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = 0; j < cols; j++) ...[
                      if (j > 0) const SizedBox(width: 8),
                      Expanded(
                        child: i + j < children.length
                            ? children[i + j]
                            : const SizedBox(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

/// Katta sanash tugmasi: bosish +1 (bekor qilish — alohida tugma).
class _CountButton extends StatelessWidget {
  const _CountButton({
    super.key,
    required this.label,
    required this.count,
    required this.percent,
    required this.onTap,
    this.badge,
  });

  final String? badge;
  final String label;
  final int count;
  final String? percent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final active = count > 0;
    final radius = BorderRadius.circular(LgRadius.card);
    final name = badge == null ? label : '$badge — $label';
    return Semantics(
      button: true,
      label: '$name: $count${percent == null ? '' : ', $percent'}',
      child: ExcludeSemantics(
        child: Material(
          color: active ? p.soft : p.paper,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: p.line),
          ),
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 96),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (badge != null)
                          Text(
                            badge!,
                            style: text.titleLarge!.copyWith(color: p.sub),
                          ),
                        const Spacer(),
                        Flexible(
                          flex: 3,
                          child: Text(
                            '$count',
                            textAlign: TextAlign.end,
                            style: text.headlineMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: active ? p.brand : p.sub,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(label, style: text.titleSmall),
                    if (percent != null) Text(percent!, style: text.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Natija qatori: qiymat va JSST pastki chegarasi; pastda bo'lsa belgisi.
class _ResultLine extends StatelessWidget {
  const _ResultLine({
    super.key,
    required this.label,
    required this.value,
    required this.limit,
    required this.below,
  });

  final String label;
  final String value;
  final SpermLimit limit;
  final bool below;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: p.line.withValues(alpha: 0.7)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 2,
            children: [
              Text(label, style: text.bodyMedium),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (below) ...[
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 18,
                      color: p.danger,
                      semanticLabel: context.tr(SpermL.belowTitle),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    value,
                    style: text.titleSmall!.copyWith(
                      color: below ? p.danger : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '${context.tr(SpermL.whoLower)}: ${_limitText(context, limit)}',
            style: text.bodySmall!.copyWith(color: p.sub),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Baholash ─────────────────────────

enum _Field {
  volume,
  concentration,
  progressive,
  totalMotility,
  vitality,
  normalForms,
  ph,
}

class SpermAssessScreen extends StatefulWidget {
  const SpermAssessScreen({super.key});

  @override
  State<SpermAssessScreen> createState() => _SpermAssessScreenState();
}

class _SpermAssessScreenState extends State<SpermAssessScreen> {
  final _ctrl = {for (final f in _Field.values) f: TextEditingController()};
  final _values = <_Field, double>{};
  final _errors = <_Field, String>{};

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  static bool _isPercent(_Field f) => switch (f) {
    _Field.progressive ||
    _Field.totalMotility ||
    _Field.vitality ||
    _Field.normalForms => true,
    _ => false,
  };

  void _onChanged(_Field f, String raw) {
    setState(() {
      _values.remove(f);
      _errors.remove(f);
      if (raw.trim().isEmpty) return;
      final v = parseFieldNumber(context, raw);
      final max = f == _Field.ph
          ? 14.0
          : _isPercent(f)
          ? 100.0
          : double.infinity;
      if (v == null || !v.isFinite || v < 0 || v > max) {
        _errors[f] = context.tr(
          f == _Field.ph
              ? SpermL.invalidPh
              : _isPercent(f)
              ? SpermL.invalidPercent
              : SpermL.invalid,
        );
        return;
      }
      _values[f] = v;
    });
  }

  String _label(_Field f) => switch (f) {
    _Field.volume => _paramLabel(SpermParam.volume),
    _Field.concentration => _paramLabel(SpermParam.concentration),
    _Field.progressive => _paramLabel(SpermParam.progressive),
    _Field.totalMotility => _paramLabel(SpermParam.totalMotility),
    _Field.vitality => _paramLabel(SpermParam.vitality),
    _Field.normalForms => _paramLabel(SpermParam.normalForms),
    _Field.ph => context.tr(SpermL.phOptional),
  };

  String _paramLabel(SpermParam p) =>
      '${context.tr(spermParamNames[p]!)}, ${context.tr(spermParamUnits[p]!)}';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final input = SpermInput(
      volume: _values[_Field.volume],
      concentration: _values[_Field.concentration],
      progressive: _values[_Field.progressive],
      totalMotility: _values[_Field.totalMotility],
      vitality: _values[_Field.vitality],
      normalForms: _values[_Field.normalForms],
      ph: _values[_Field.ph],
    );
    final a = assessSperm(input);
    return LgPage(
      title: context.tr(SpermL.assessTitle),
      subtitle: l.spermTitle,
      children: [
        LgNotice(context.tr(SpermL.draftNote), title: l.diffDraftTag),
        Text(context.tr(SpermL.assessIntro), style: text.bodyMedium),
        for (final f in _Field.values)
          LgField(
            key: ValueKey('sperm-in-${f.name}'),
            label: _label(f),
            controller: _ctrl[f],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: f == _Field.ph
                ? TextInputAction.done
                : TextInputAction.next,
            onChanged: (s) => _onChanged(f, s),
            errorText: _errors[f],
          ),
        LgSectionTitle(context.tr(SpermL.resultTitle)),
        Semantics(
          liveRegion: true,
          container: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: input.isEmpty
                ? [Text(context.tr(SpermL.emptyHint), style: text.bodyMedium)]
                : _results(context, input, a),
          ),
        ),
        LgNotice(context.tr(SpermL.notThreshold)),
        LgNotice(context.tr(SpermL.referNote), kind: NoticeKind.info),
        const _Refs([
          refTable83,
          refNotThreshold,
          refTotalNumber,
          refAzoo,
          refTerms2010,
          refPh,
          refEau,
        ]),
      ],
    );
  }

  List<Widget> _results(
    BuildContext context,
    SpermInput input,
    SpermAssessment a,
  ) {
    final text = Theme.of(context).textTheme;
    final total = input.totalNumber;
    final shown = <(SpermParam, double)>[
      if (input.volume case final v?) (SpermParam.volume, v),
      if (input.concentration case final v?) (SpermParam.concentration, v),
      if (total != null) (SpermParam.totalNumber, total),
      if (input.progressive case final v?) (SpermParam.progressive, v),
      if (input.totalMotility case final v?) (SpermParam.totalMotility, v),
      if (input.vitality case final v?) (SpermParam.vitality, v),
      if (input.normalForms case final v?) (SpermParam.normalForms, v),
    ];
    return [
      if (a.errors.contains(SpermInputError.progressiveAboveTotal))
        LgNotice(context.tr(SpermL.errProgressive), kind: NoticeKind.error),
      for (final (p, v) in shown)
        _ResultLine(
          key: ValueKey('sperm-assess-${p.name}'),
          label: p == SpermParam.totalNumber
              ? '${context.tr(SpermL.calculatedTotal)}, '
                    '${context.tr(spermParamUnits[p]!)}'
              : '${context.tr(spermParamNames[p]!)}, '
                    '${context.tr(spermParamUnits[p]!)}',
          value: context.num(v),
          limit: spermLimit(p),
          below: a.below.contains(p),
        ),
      const SizedBox(height: 8),
      if (shown.isNotEmpty && a.below.isEmpty)
        LgNotice(context.tr(SpermL.allAbove), kind: NoticeKind.info),
      if (a.terms.isNotEmpty) ...[
        LgSectionTitle(context.tr(SpermL.mayPoint)),
        for (final t in a.terms)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LgPanel(
              key: ValueKey('sperm-term-${t.name}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr(spermTerms[t]!.name), style: text.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    context.tr(spermTerms[t]!.definition),
                    style: text.bodySmall,
                  ),
                  if (t == SpermTerm.azoospermia) ...[
                    const SizedBox(height: 4),
                    Text(context.tr(SpermL.azooNote), style: text.bodySmall),
                  ],
                  if (t == SpermTerm.necrozoospermia) ...[
                    const SizedBox(height: 4),
                    Text(context.tr(SpermL.necroNote), style: text.bodySmall),
                  ],
                ],
              ),
            ),
          ),
        if (a.countBasis == SpermParam.totalNumber && a.terms.any(_isOligo))
          Text(context.tr(SpermL.basisTotal), style: text.bodySmall),
        if (a.countBasis == SpermParam.concentration && a.terms.any(_isOligo))
          Text(context.tr(SpermL.basisConc), style: text.bodySmall),
        const SizedBox(height: 4),
        Text(context.tr(SpermL.termsBasis), style: text.bodySmall),
      ],
      if (a.lowPh) LgNotice(context.tr(SpermL.lowPh), kind: NoticeKind.warning),
    ];
  }

  static bool _isOligo(SpermTerm t) => switch (t) {
    SpermTerm.oligozoospermia ||
    SpermTerm.oligoasthenozoospermia ||
    SpermTerm.oligoteratozoospermia ||
    SpermTerm.oligoasthenoteratozoospermia => true,
    _ => false,
  };
}

// ───────────────────────── Atamalar ─────────────────────────

class SpermTermsScreen extends StatelessWidget {
  const SpermTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    Widget term(SpermTermInfo t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LgPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr(t.name), style: text.titleSmall),
            const SizedBox(height: 4),
            Text(context.tr(t.definition), style: text.bodyMedium),
            if (t.extra case final e?) ...[
              const SizedBox(height: 6),
              Text(context.tr(e), style: text.bodySmall),
            ],
          ],
        ),
      ),
    );
    return LgPage(
      title: context.tr(SpermL.termsTitle),
      subtitle: l.spermTitle,
      children: [
        Text(context.tr(SpermL.termsIntro), style: text.bodyMedium),
        const SizedBox(height: 10),
        for (final t in SpermTerm.values) term(spermTerms[t]!),
        for (final t in spermExtraTerms) term(t),
        LgNotice(context.tr(SpermL.suffixNote)),
        LgSectionTitle(context.tr(SpermL.gradesTitle)),
        for (final g in MotilityGrade.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    motilityGrades[g]!.letter,
                    style: text.titleMedium,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(motilityGrades[g]!.name),
                        style: text.titleSmall,
                      ),
                      Text(
                        context.tr(motilityGrades[g]!.definition),
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Text(context.tr(SpermL.gradesNote), style: text.bodySmall),
        LgSectionTitle(context.tr(SpermL.morphTitle)),
        for (final d in MorphDefect.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '•  ${context.tr(morphDefectNames[d]!)}',
              style: text.bodyMedium,
            ),
          ),
        Text(context.tr(cytoplasmNote), style: text.bodySmall),
        const _Refs([
          refTerms2010,
          refEau,
          refAzoo,
          refMotilityGrades,
          CalcRef(SpermSources.who2021, '§1, p. 3'),
          refMorph,
        ]),
      ],
    );
  }
}

// ───────────────────────── Preanalitika ─────────────────────────

class SpermPreScreen extends StatelessWidget {
  const SpermPreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    // Manbalar takrorsiz, qadamlar tartibida.
    final seen = <String>{};
    final refs = [
      for (final s in spermPreSteps)
        if (seen.add(s.ref.locator)) s.ref,
      refVitality,
      refPh,
    ];
    return LgPage(
      title: context.tr(SpermL.preTitle),
      subtitle: l.spermTitle,
      children: [
        for (final (i, s) in spermPreSteps.indexed) ...[
          LgSectionTitle('${i + 1}. ${context.tr(s.title)}'),
          Text(context.tr(s.body), style: text.bodyMedium),
        ],
        const SizedBox(height: 8),
        LgNotice(context.tr(SpermL.draftNote), title: l.diffDraftTag),
        _Refs(refs),
      ],
    );
  }
}

// ───────────────────────── Mashq ─────────────────────────

/// Savollar (variantlar aralashtirilgan).
List<QuizQuestion> buildSpermQuiz(Random rnd) => [
  for (final item in [...spermQuiz]..shuffle(rnd))
    () {
      final order = List.generate(item.options.length, (i) => i)..shuffle(rnd);
      return QuizQuestion(
        id: item.id,
        prompt: item.prompt,
        options: [
          for (final o in order)
            QuizOption(text: item.options[o], explanation: item.basis),
        ],
        correctIndex: order.indexOf(0),
        basis: item.basis,
        refs: const [],
        reviewState: ReviewState.pending,
      );
    }(),
];

class SpermQuizScreen extends StatefulWidget {
  const SpermQuizScreen({super.key, this.random});

  final Random? random;

  @override
  State<SpermQuizScreen> createState() => _SpermQuizScreenState();
}

class _SpermQuizScreenState extends State<SpermQuizScreen> {
  QuizSession? _session;

  void _start() => setState(() {
    _session = QuizSession(buildSpermQuiz(widget.random ?? Random()));
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final s = _session;
    return LgPage(
      key: ValueKey((s == null, s?.index, s?.finished)),
      title: context.tr(SpermL.quizTitle),
      subtitle: l.spermTitle,
      children: [
        if (s == null) ...[
          Text(context.tr(SpermL.quizIntro), style: text.bodyLarge),
          const SizedBox(height: 16),
          LgButton(label: context.tr(SpermL.quizStart), onPressed: _start),
          const SizedBox(height: 14),
          Text(l.quizReviewNote, style: text.bodySmall),
        ] else if (s.finished) ...[
          LgStateView(
            kind: StateKind.success,
            title: l.quizDoneTitle,
            message: l.quizScore(s.correctCount, s.questions.length),
          ),
          LgSectionTitle(l.quizMistakes),
          if (s.mistakes.isEmpty)
            Text(l.quizNoMistakes, style: text.bodyMedium)
          else
            for (final (q, chosen) in s.mistakes)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LgPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr(q.prompt), style: text.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        '${l.quizYourAnswer}: '
                        '${context.tr(q.options[chosen].text)}',
                        style: text.bodyMedium,
                      ),
                      Text(
                        '${l.quizCorrectAnswer}: '
                        '${context.tr(q.options[q.correctIndex].text)}',
                        style: text.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(context.tr(q.basis), style: text.bodySmall),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 16),
          LgButton(label: l.quizRestart, onPressed: _start),
        ] else
          _Question(session: s, onChanged: () => setState(() {})),
        const _Refs([refTable83, refNotThreshold, refPatient, refAzoo]),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.session, required this.onChanged});

  final QuizSession session;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final q = session.current;
    final answer = session.answerFor(session.index);
    final answered = answer != null;
    final total = session.questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            LgEyebrow(l.quizProgress(session.index + 1, total)),
            LgTag(l.quizDraftTag, tone: LgTone.warning),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (session.index + 1) / total,
              minHeight: 6,
              semanticsLabel: l.quizProgress(session.index + 1, total),
            ),
          ),
        ),
        Semantics(
          header: true,
          child: Text(context.tr(q.prompt), style: text.headlineSmall),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LgPressable(
              key: ValueKey('sperm-opt-$i'),
              onTap: answered
                  ? null
                  : () {
                      if (session.answer(i)) onChanged();
                    },
              color: !answered
                  ? p.paper
                  : i == q.correctIndex
                  ? p.soft
                  : i == answer
                  ? p.amberBg
                  : p.paper,
              border: Border.all(
                color: !answered
                    ? p.line
                    : i == q.correctIndex
                    ? p.brand
                    : i == answer
                    ? p.amber
                    : p.line,
                width: answered && (i == q.correctIndex || i == answer) ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(LgRadius.button),
              semanticLabel: [
                context.tr(q.options[i].text),
                if (answered && i == q.correctIndex) l.quizCorrectAnswer,
                if (answered && i == answer && i != q.correctIndex)
                  l.quizYourAnswer,
              ].join('. '),
              child: ExcludeSemantics(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.tr(q.options[i].text),
                            style: text.bodyLarge,
                          ),
                        ),
                        if (answered && i == q.correctIndex)
                          Icon(Icons.check_circle_rounded, color: p.brand)
                        else if (answered && i == answer)
                          Icon(Icons.cancel_rounded, color: p.amber),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (answered) ...[
          LgNotice(
            context.tr(q.basis),
            title: answer == q.correctIndex ? l.quizCorrect : l.quizIncorrect,
            kind: answer == q.correctIndex
                ? NoticeKind.info
                : NoticeKind.warning,
          ),
          const SizedBox(height: 8),
          LgButton(
            label: session.isLast ? l.quizFinish : l.quizNext,
            onPressed: () {
              session.next();
              onChanged();
            },
          ),
        ],
      ],
    );
  }
}
