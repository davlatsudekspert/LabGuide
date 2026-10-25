import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/entitlements/feature.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../profile/pro_gate.dart';
import '../tools/clinical_calc_screens.dart';
import '../tools/tool_screens.dart';
import 'diff_assessment.dart';
import 'differential_content.dart';
import 'differential_controller.dart';

String _num(BuildContext context, double v, {int decimals = 2}) => formatResult(
  v,
  Localizations.localeOf(context).toLanguageTag(),
  maxDecimals: decimals,
);

String diffMeasureLabel(DiffMeasure m, AppLocalizations l) => switch (m) {
  DiffMeasure.neutrophils => l.diffMeasureNeutrophils,
  DiffMeasure.lymphocytes => l.diffMeasureLymphocytes,
  DiffMeasure.monocytes => l.diffMeasureMonocytes,
  DiffMeasure.eosinophils => l.diffMeasureEosinophils,
  DiffMeasure.basophils => l.diffMeasureBasophils,
  DiffMeasure.bandsPercent => l.diffMeasureBands,
};

/// "Talqin" topilmasi nomi ikki nuqtadan keyin: rus tilida kichik harf bilan
/// (bosh kelishikdagi atama — "Возможная трактовка: нейтропения").
String findingLabel(DiffFinding f, String lang) {
  final t = f.title.of(lang);
  if (lang != 'ru' || t.isEmpty) return t;
  return t[0].toLowerCase() + t.substring(1);
}

String _unit(DiffMeasure m, AppLocalizations l) =>
    m == DiffMeasure.bandsPercent ? '%' : l.diffColAbs;

String _range(BuildContext context, DiffMeasure m, DiffLimit limit) {
  final d = m == DiffMeasure.bandsPercent ? 1 : 2;
  final lo = limit.low == null ? '0' : _num(context, limit.low!, decimals: d);
  return '$lo–${_num(context, limit.high, decimals: d)}';
}

/// Natija jadvali ostidagi baho: har ko'rsatkich me'yor bilan, yuqori/past
/// belgisi, mos "Talqin" topilmasi; xavfli holatda — yo'llash ogohlantirishi.
/// Tashxis qo'yilmaydi.
class DiffAssessmentPanel extends StatelessWidget {
  const DiffAssessmentPanel({
    super.key,
    required this.record,
    required this.base,
  });

  final DiffRecord record;

  /// Leykoformula bo'limi manzili (Talqin va me'yorlar sahifalari uchun).
  final String base;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final diff = context.services.differential;
    final a = assessDifferential(record, diff.limits);
    if (a.results.isEmpty && !a.incomplete) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.diffAssessTitle),
        if (a.refer)
          LgNotice(
            l.diffAssessReferBody,
            key: const ValueKey('diff-assess-refer'),
            title: l.diffReferTitle,
            kind: NoticeKind.error,
          ),
        if (a.incomplete)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              l.diffAssessIncomplete(a.counted, a.target),
              key: const ValueKey('diff-assess-incomplete'),
              style: text.bodyMedium,
            ),
          ),
        if (a.needsWbc)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(l.diffAssessNeedWbc, style: text.bodySmall),
          ),
        for (final r in a.results)
          Semantics(
            container: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: LgPanel(
                soft: r.flag == null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          diffMeasureLabel(r.measure, l),
                          style: text.titleSmall,
                        ),
                        LgTag(
                          switch (r.flag) {
                            DiffFlag.high => l.diffFlagHigh,
                            DiffFlag.low => l.diffFlagLow,
                            null => l.diffFlagNormal,
                          },
                          tone: r.flag == null ? LgTone.brand : LgTone.warning,
                          icon: switch (r.flag) {
                            DiffFlag.high => Icons.arrow_upward_rounded,
                            DiffFlag.low => Icons.arrow_downward_rounded,
                            null => null,
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_num(context, r.value, decimals: r.measure == DiffMeasure.bandsPercent ? 1 : 2)} '
                      '${_unit(r.measure, l)} · '
                      '${l.diffAssessRange(_range(context, r.measure, r.limit))}',
                      style: text.bodyMedium,
                    ),
                    if (r.finding case final f?) ...[
                      const SizedBox(height: 6),
                      Text(
                        l.diffAssessMaySuggest(findingLabel(f, lang)),
                        style: text.bodyMedium!.copyWith(color: p.brand),
                      ),
                      Text(f.what.of(lang), style: text.bodySmall),
                      // Shu topilmaning o'z kartasiga (Talqin sahifasida
                      // o'sha kartagacha surilib, ajratib ko'rsatiladi).
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          key: ValueKey('diff-finding-link-${f.id}'),
                          // Baholash — [Feature.leukocyteEvaluation] (D-76).
                          onPressed: () => pushGated(
                            context,
                            Feature.leukocyteEvaluation,
                            '$base/interpret?finding=${f.id}',
                          ),
                          icon: const Icon(Icons.menu_book_outlined),
                          label: Text(l.diffAssessAboutFinding),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        if (a.allNormal)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l.diffAssessAllNormal,
              key: const ValueKey('diff-assess-all-normal'),
              style: text.bodyMedium,
            ),
          ),
        LgNotice(l.diffAssessNote, kind: NoticeKind.info),
        Wrap(
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: () => pushGated(
                context,
                Feature.leukocyteEvaluation,
                '$base/interpret',
              ),
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(l.diffInterpretTitle),
            ),
            TextButton.icon(
              onPressed: () => context.push('$base/limits'),
              icon: const Icon(Icons.tune_rounded),
              label: Text(l.diffLimitsTitle),
            ),
          ],
        ),
      ],
    );
  }
}

/// Laboratoriya blankasidagi me'yorlarni kiritish. Sukut — manbadagi
/// kattalar oraliqlari; "qaytarish" bilan tiklanadi.
class DiffLimitsScreen extends StatelessWidget {
  const DiffLimitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final diff = context.services.differential;
    return ListenableBuilder(
      listenable: diff,
      builder: (context, _) => LgPage(
        title: l.diffLimitsTitle,
        subtitle: l.diffTitle,
        children: [
          Text(l.diffLimitsSub, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          for (final m in DiffMeasure.values)
            _LimitEditor(
              // Qaytarishdan keyin maydonlar yangi qiymat bilan qayta quriladi.
              key: ValueKey(
                '${m.name}-${diff.limits[m]!.low}-'
                '${diff.limits[m]!.high}',
              ),
              measure: m,
              limit: diff.limits[m]!,
            ),
          LgNotice(l.diffLimitsSourceNote, kind: NoticeKind.info),
          const CalcSourceTile(index: 1, ref: diffDefaultLimitsRef),
          const CalcSourceTile(index: 2, ref: diffNeutropeniaRef),
          const CalcSourceTile(index: 3, ref: diffEosinophiliaRef),
          const CalcSourceTile(index: 4, ref: diffLymphocytopeniaRef),
          const SizedBox(height: 12),
          LgButton.secondary(
            label: l.diffLimitsReset,
            icon: Icons.restart_alt_rounded,
            onPressed: diff.resetLimits,
          ),
        ],
      ),
    );
  }
}

class _LimitEditor extends StatefulWidget {
  const _LimitEditor({super.key, required this.measure, required this.limit});

  final DiffMeasure measure;
  final DiffLimit limit;

  @override
  State<_LimitEditor> createState() => _LimitEditorState();
}

class _LimitEditorState extends State<_LimitEditor> {
  final _low = TextEditingController();
  final _high = TextEditingController();
  String? _error;
  bool _init = false;

  int get _decimals => widget.measure == DiffMeasure.bandsPercent ? 1 : 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final lim = widget.limit;
    if (lim.low != null) {
      _low.text = _num(context, lim.low!, decimals: _decimals);
    }
    _high.text = _num(context, lim.high, decimals: _decimals);
  }

  @override
  void dispose() {
    _low.dispose();
    _high.dispose();
    super.dispose();
  }

  void _changed(String _) {
    final l = AppLocalizations.of(context);
    final low = _low.text.trim().isEmpty
        ? null
        : parseFieldNumber(context, _low.text);
    final high = parseFieldNumber(context, _high.text);
    final lowBad = _low.text.trim().isNotEmpty && low == null;
    final limit = lowBad || high == null
        ? null
        : DiffLimit.fromJson({'low': low, 'high': high});
    if (limit == null) {
      setState(() => _error = l.diffLimitsInvalid);
      return;
    }
    setState(() => _error = null);
    context.services.differential.setLimit(widget.measure, limit);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final unit = _unit(widget.measure, l);
    const keyboard = TextInputType.numberWithOptions(decimal: true);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LgPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${diffMeasureLabel(widget.measure, l)}, $unit',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            LgField(
              label: l.diffLimitsLow,
              controller: _low,
              keyboardType: keyboard,
              textInputAction: TextInputAction.next,
              onChanged: _changed,
            ),
            LgField(
              label: l.diffLimitsHigh,
              controller: _high,
              keyboardType: keyboard,
              textInputAction: TextInputAction.done,
              onChanged: _changed,
              errorText: _error,
            ),
          ],
        ),
      ),
    );
  }
}
