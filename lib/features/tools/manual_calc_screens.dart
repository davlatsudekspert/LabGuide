import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import 'clinical_calc_screens.dart';
import 'clinical_calculators.dart' show roundHalfUp;
import 'manual_calc_info.dart';
import 'manual_calculators.dart';
import 'tool_screens.dart';

const _decimalKeyboard = TextInputType.numberWithOptions(decimal: true);

String manualCalcTitle(ManualCalc c, AppLocalizations l) => switch (c) {
  ManualCalc.chamber => l.mcChamber,
  ManualCalc.differential => l.mcDiff,
  ManualCalc.reticulocytes => l.mcRetic,
  ManualCalc.light => l.mcLight,
  ManualCalc.colourIndex => l.mcColour,
};

String manualCalcSubtitle(ManualCalc c, AppLocalizations l) => switch (c) {
  ManualCalc.chamber => l.mcChamberSub,
  ManualCalc.differential => l.mcDiffSub,
  ManualCalc.reticulocytes => l.mcReticSub,
  ManualCalc.light => l.mcLightSub,
  ManualCalc.colourIndex => l.mcColourSub,
};

IconData manualCalcIcon(ManualCalc c) => switch (c) {
  ManualCalc.chamber => Icons.grid_on_rounded,
  ManualCalc.differential => Icons.donut_small_outlined,
  ManualCalc.reticulocytes => Icons.bubble_chart_outlined,
  ManualCalc.light => Icons.science_outlined,
  ManualCalc.colourIndex => Icons.palette_outlined,
};

String manualCalcRoute(ManualCalc c) => switch (c) {
  ManualCalc.chamber => 'chamber',
  ManualCalc.differential => 'differential',
  ManualCalc.reticulocytes => 'reticulocytes',
  ManualCalc.light => 'light',
  ManualCalc.colourIndex => 'colour-index',
};

Widget manualCalcScreen(ManualCalc c) => switch (c) {
  ManualCalc.chamber => const ChamberCalcScreen(),
  ManualCalc.differential => const DifferentialCalcScreen(),
  ManualCalc.reticulocytes => const ReticCalcScreen(),
  ManualCalc.light => const LightCalcScreen(),
  ManualCalc.colourIndex => const ColourIndexScreen(),
};

/// Maydon nomi (birligi bilan) — xato matni va kiritmalar ro'yxati uchun.
String manualFieldName(ManualField f, AppLocalizations l) => switch (f) {
  ManualField.cells => l.mfCells,
  ManualField.squares => l.mfSquares,
  ManualField.squareArea => l.mfSquareArea,
  ManualField.depth => l.mfDepth,
  ManualField.dilution => l.mfDilution,
  ManualField.wbc => '${l.mfWbc}, ×10⁹/L',
  ManualField.neutrophilsSeg => '${l.mfSeg}, %',
  ManualField.neutrophilsBand => '${l.mfBand}, %',
  ManualField.eosinophils => '${l.mfEos}, %',
  ManualField.basophils => '${l.mfBaso}, %',
  ManualField.lymphocytes => '${l.mfLymph}, %',
  ManualField.monocytes => '${l.mfMono}, %',
  ManualField.otherCells => '${l.mfOther}, %',
  ManualField.nrbc => l.mfNrbc,
  ManualField.reticCounted => l.mfReticCounted,
  ManualField.rbcExamined => l.mfRbcExamined,
  ManualField.hematocrit => '${l.mfHct}, %',
  ManualField.rbcCount => '${l.mfRbc}, ×10¹²/L',
  ManualField.pfProtein => l.mfPfProtein,
  ManualField.serumProtein => l.mfSerumProtein,
  ManualField.pfLdh => l.mfPfLdh,
  ManualField.serumLdh => l.mfSerumLdh,
  ManualField.ldhUln => l.mfLdhUln,
};

String _n(double v, String locale, int d) =>
    formatResult(roundHalfUp(v, d), locale, maxDecimals: d);

/// Yetilish koeffitsiyenti — jadvaldagidek doim bitta kasr belgisi (2,0).
String _f1(double v, String locale) =>
    (NumberFormat.decimalPattern(locale)
          ..minimumFractionDigits = 1
          ..maximumFractionDigits = 1)
        .format(v);

String manualErrorText(
  AppLocalizations l,
  ManualFail<Object?> f,
  String locale,
) {
  final field = f.field;
  final name = field == null ? '' : manualFieldName(field, l);
  String num(double? v) => v == null ? '' : _n(v, locale, 4);
  switch (f.issue) {
    case ManualIssue.missing:
      return l.errCalcMissing(name);
    case ManualIssue.implausible:
      if (field == ManualField.cells || field == ManualField.squares) {
        return l.mErrWhole(name, num(f.min), num(f.max));
      }
      return l.errCalcImplausible(name, num(f.min), num(f.max), '');
    case ManualIssue.inconsistent:
      if (f.sum != null) return l.mErrSum(_n(f.sum!, locale, 1));
      return l.mErrReticGtExamined;
  }
}

/// Barcha qo'lda usul kalkulyatorlari uchun umumiy sahifa: kiritmalar,
/// “Hisoblash”, natija va pastda formula / cheklovlar / manbalar.
class _ManualPage extends StatelessWidget {
  const _ManualPage({
    required this.calc,
    required this.inputs,
    required this.onCalculate,
    required this.result,
    this.resultKey,
  });

  final ManualCalc calc;

  /// Natija bloki — hisobdan keyin unga suriladi.
  final Key? resultKey;
  final List<Widget> inputs;
  final VoidCallback onCalculate;
  final Widget? result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: manualCalcTitle(calc, l),
      subtitle: manualCalcSubtitle(calc, l),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: LgTag(l.calcFormulaTag, icon: Icons.menu_book_outlined),
        ),
        ...inputs,
        const SizedBox(height: 18),
        LgButton(label: l.dilCalculate, onPressed: onCalculate),
        const SizedBox(height: 10),
        Semantics(
          key: resultKey,
          liveRegion: true,
          child: result ?? const SizedBox.shrink(),
        ),
        const SizedBox(height: 6),
        LgNotice(l.calcNotDiagnosis, kind: NoticeKind.info),
        ..._infoSections(context, calc),
      ],
    );
  }
}

List<Widget> _infoSections(BuildContext context, ManualCalc calc) {
  final l = AppLocalizations.of(context);
  final text = Theme.of(context).textTheme;
  final lang = Localizations.localeOf(context).languageCode;
  final info = manualCalcInfo[calc]!;
  return [
    LgSectionTitle(l.calcFormula),
    for (final f in info.formula)
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(f.of(lang), style: text.bodyMedium),
      ),
    LgSectionTitle(l.calcLimitations),
    for (final x in info.limitations) _Bullet(x.of(lang)),
    LgSectionTitle(l.calcSources),
    for (final (i, r) in info.refs.indexed)
      CalcSourceTile(index: i + 1, ref: r),
  ];
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: style),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

/// Tanlov guruhi sarlavhasi va chiplari.
class _ChipGroup<T> extends StatelessWidget {
  const _ChipGroup({
    required this.label,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

  final String label;
  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 7),
            child: Text(label, style: text.titleSmall!.copyWith(fontSize: 14)),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final o in options)
                LgChoiceChip(
                  label: labelOf(o),
                  selected: o == selected,
                  onTap: () => onSelect(o),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Natija paneli: sarlavha, asosiy qiymat va qo'shimcha qatorlar.
class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.title,
    required this.headline,
    this.children = const [],
  });

  final String title;
  final String headline;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleSmall),
          Text(headline, style: text.headlineSmall!.copyWith(color: p.brand)),
          ...children,
        ],
      ),
    );
  }
}

Widget _note(BuildContext context, String s) => Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Text(s, style: Theme.of(context).textTheme.bodySmall),
);

/// Maydonlar uchun umumiy holat: controller'lar va eski natijani tozalash.
mixin _Fields<W extends StatefulWidget> on State<W> {
  final Map<ManualField, TextEditingController> ctrl = {};
  ManualOutcome<Object?>? outcome;
  final resultKey = GlobalKey();

  TextEditingController c(ManualField f) =>
      ctrl.putIfAbsent(f, TextEditingController.new);

  void invalidate() {
    if (outcome != null) setState(() => outcome = null);
  }

  /// Bo'sh maydon — `null`; matn bor, lekin son emas — [_invalid].
  double? read(ManualField f) {
    final raw = c(f).text;
    if (raw.trim().isEmpty) return null;
    final v = parseFieldNumber(context, raw);
    if (v == null) throw _Invalid(f);
    return v;
  }

  /// Maydonlarni o'qib, hisoblaydi; noto'g'ri yozilgan son — xato natija.
  void run(ManualOutcome<Object?> Function() compute) {
    FocusScope.of(context).unfocus();
    ManualOutcome<Object?> r;
    try {
      r = compute();
    } on _Invalid catch (e) {
      r = ManualFail<Object?>(ManualIssue.missing, field: e.field);
    }
    setState(() => outcome = r);
    // Natija tugma ostida — ekrandan tashqarida qolmasin.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = resultKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      // 0,3 — natija boshi kengaygan sarlavha ostida qolmasin.
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.3,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Widget field(
    ManualField f, {
    String? label,
    bool last = false,
    bool optional = false,
    VoidCallback? onDone,
  }) {
    final l = AppLocalizations.of(context);
    return LgField(
      label:
          (label ?? manualFieldName(f, l)) +
          (optional ? ' · ${l.calcOptional}' : ''),
      controller: c(f),
      keyboardType: _decimalKeyboard,
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      onSubmitted: last && onDone != null ? (_) => onDone() : null,
      onChanged: (_) => invalidate(),
    );
  }

  @override
  void dispose() {
    for (final x in ctrl.values) {
      x.dispose();
    }
    super.dispose();
  }
}

class _Invalid implements Exception {
  const _Invalid(this.field);
  final ManualField field;
}

// ---------------------------------------------------------------------------
// Hisob kamerasi
// ---------------------------------------------------------------------------

class ChamberCalcScreen extends StatefulWidget {
  const ChamberCalcScreen({super.key});

  @override
  State<ChamberCalcScreen> createState() => _ChamberCalcScreenState();
}

class _ChamberCalcScreenState extends State<ChamberCalcScreen>
    with _Fields<ChamberCalcScreen> {
  double _area = chamberSquareAreas.first;
  double _depth = chamberDepths.first;

  void _calculate() => run(
    () => chamberCount(
      cells: read(ManualField.cells),
      squares: read(ManualField.squares),
      squareArea: _area,
      depth: _depth,
      dilution: read(ManualField.dilution),
    ),
  );

  String _areaLabel(double a, String locale) {
    if (a == 1) return '1 mm²';
    if (a == 0.04) return '1/25 mm² (${_n(a, locale, 2)})';
    return '1/400 mm² (${_n(a, locale, 4)})';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final o = outcome;
    return _ManualPage(
      calc: ManualCalc.chamber,
      inputs: [
        field(ManualField.cells),
        field(ManualField.squares),
        _ChipGroup<double>(
          label: l.mfSquareArea,
          options: chamberSquareAreas,
          selected: _area,
          labelOf: (a) => _areaLabel(a, locale),
          onSelect: (a) => setState(() {
            _area = a;
            outcome = null;
          }),
        ),
        _ChipGroup<double>(
          label: l.mfDepth,
          options: chamberDepths,
          selected: _depth,
          labelOf: (d) => '${_n(d, locale, 1)} mm',
          onSelect: (d) => setState(() {
            _depth = d;
            outcome = null;
          }),
        ),
        field(ManualField.dilution, last: true, onDone: _calculate),
      ],
      onCalculate: _calculate,
      resultKey: resultKey,
      result: switch (o) {
        null => null,
        final ManualFail<Object?> f => LgNotice(
          manualErrorText(l, f, locale),
          kind: NoticeKind.error,
        ),
        ManualOk(value: final ChamberResult r) => _ResultPanel(
          title: l.mcChamber,
          headline: '${_n(r.perMicroLitre, locale, 1)} ${l.mrCellsPerUl}',
          children: [
            LgMetric(
              label: '×10⁹/L',
              value: _n(r.gigaPerLitre, locale, r.gigaPerLitre < 10 ? 2 : 1),
            ),
            LgMetric(label: l.mrVolume, value: '${_n(r.volume, locale, 4)} µL'),
          ],
        ),
        _ => null,
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Leykoformula: mutlaq sonlar
// ---------------------------------------------------------------------------

class DifferentialCalcScreen extends StatefulWidget {
  const DifferentialCalcScreen({super.key});

  @override
  State<DifferentialCalcScreen> createState() => _DifferentialCalcScreenState();
}

class _DifferentialCalcScreenState extends State<DifferentialCalcScreen>
    with _Fields<DifferentialCalcScreen> {
  void _calculate() => run(() {
    final wbc = read(ManualField.wbc);
    final percents = <ManualField, double>{
      for (final f in differentialFields) f: ?read(f),
    };
    return differentialAbsolute(
      wbc: wbc,
      percents: percents,
      nrbcPer100: read(ManualField.nrbc),
    );
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final o = outcome;
    return _ManualPage(
      calc: ManualCalc.differential,
      inputs: [
        field(ManualField.wbc),
        for (final f in differentialFields)
          field(f, optional: f == ManualField.otherCells),
        field(ManualField.nrbc, optional: true, last: true, onDone: _calculate),
      ],
      onCalculate: _calculate,
      resultKey: resultKey,
      result: switch (o) {
        null => null,
        final ManualFail<Object?> f => LgNotice(
          manualErrorText(l, f, locale),
          kind: NoticeKind.error,
        ),
        ManualOk(value: final DifferentialResult r) => _ResultPanel(
          title: r.corrected ? l.mrWbcUsed : 'WBC',
          headline: '${_n(r.wbcUsed, locale, 2)} ×10⁹/L',
          children: [
            if (r.nrbcAbsolute case final nrbc?)
              LgMetric(label: l.mrNrbc, value: '${_n(nrbc, locale, 2)} ×10⁹/L'),
            const SizedBox(height: 6),
            Text(l.mrAbsolute, style: Theme.of(context).textTheme.titleSmall),
            for (final e in r.absolute.entries)
              LgMetric(
                label: manualFieldName(e.key, l).split(',').first,
                value: '${_n(e.value, locale, 2)} ×10⁹/L',
              ),
            LgMetric(
              label: l.mrPercentSum,
              value: '${_n(r.percentSum, locale, 1)} %',
            ),
            if (!r.corrected) _note(context, l.mrNoCorrection),
          ],
        ),
        _ => null,
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Retikulotsitlar
// ---------------------------------------------------------------------------

class ReticCalcScreen extends StatefulWidget {
  const ReticCalcScreen({super.key});

  @override
  State<ReticCalcScreen> createState() => _ReticCalcScreenState();
}

class _ReticCalcScreenState extends State<ReticCalcScreen>
    with _Fields<ReticCalcScreen> {
  /// `null` — avto (jadvalning eng yaqin nuqtasi).
  double? _factor;

  void _calculate() => run(
    () => reticulocytes(
      counted: read(ManualField.reticCounted),
      examined: read(ManualField.rbcExamined),
      hematocrit: read(ManualField.hematocrit),
      rbc: read(ManualField.rbcCount),
      maturation: _factor,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final o = outcome;
    final factors = <double?>[null, for (final r in maturationTable) r.$2];
    return _ManualPage(
      calc: ManualCalc.reticulocytes,
      inputs: [
        field(ManualField.reticCounted),
        field(ManualField.rbcExamined),
        field(ManualField.hematocrit),
        field(ManualField.rbcCount, optional: true),
        _ChipGroup<double?>(
          label: l.mfMaturation,
          options: factors,
          selected: _factor,
          labelOf: (f) {
            if (f == null) return l.mfMaturationAuto;
            final hct = maturationTable.firstWhere((r) => r.$2 == f).$1;
            return '${_f1(f, locale)} · Ht ${_n(hct, locale, 0)} %';
          },
          onSelect: (f) => setState(() {
            _factor = f;
            outcome = null;
          }),
        ),
      ],
      onCalculate: _calculate,
      resultKey: resultKey,
      result: switch (o) {
        null => null,
        final ManualFail<Object?> f => LgNotice(
          manualErrorText(l, f, locale),
          kind: NoticeKind.error,
        ),
        ManualOk(value: final ReticResult r) => _ResultPanel(
          title: l.mcRetic,
          headline: '${_n(r.percent, locale, 2)} %',
          children: [
            LgMetric(
              label: l.mrReticAbs,
              value: r.absolute == null
                  ? l.mrNoRbc
                  : '${_n(r.absolute!, locale, 1)} ×10⁹/L',
            ),
            LgMetric(
              label: l.mrReticCorrected,
              value: '${_n(r.corrected, locale, 2)} %',
            ),
            LgMetric(label: l.mrRpi, value: _n(r.rpi, locale, 2)),
            _note(
              context,
              r.maturationSuggested
                  ? l.mrMaturationAuto(
                      _f1(r.maturation, locale),
                      _n(r.hematocrit, locale, 1),
                    )
                  : l.mrMaturationChosen(_f1(r.maturation, locale)),
            ),
          ],
        ),
        _ => null,
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Light mezonlari
// ---------------------------------------------------------------------------

class LightCalcScreen extends StatefulWidget {
  const LightCalcScreen({super.key});

  @override
  State<LightCalcScreen> createState() => _LightCalcScreenState();
}

class _LightCalcScreenState extends State<LightCalcScreen>
    with _Fields<LightCalcScreen> {
  void _calculate() => run(
    () => lightCriteria(
      pfProtein: read(ManualField.pfProtein),
      serumProtein: read(ManualField.serumProtein),
      pfLdh: read(ManualField.pfLdh),
      serumLdh: read(ManualField.serumLdh),
      ldhUln: read(ManualField.ldhUln),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final o = outcome;
    String state(bool? met) => switch (met) {
      true => l.mrMet,
      false => l.mrNotMet,
      null => l.mrNotAssessed,
    };
    return _ManualPage(
      calc: ManualCalc.light,
      inputs: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(l.mfSameUnit, style: text.bodySmall),
        ),
        field(ManualField.pfProtein),
        field(ManualField.serumProtein),
        field(ManualField.pfLdh),
        field(ManualField.serumLdh),
        field(
          ManualField.ldhUln,
          optional: true,
          last: true,
          onDone: _calculate,
        ),
      ],
      onCalculate: _calculate,
      resultKey: resultKey,
      result: switch (o) {
        null => null,
        final ManualFail<Object?> f => LgNotice(
          manualErrorText(l, f, locale),
          kind: NoticeKind.error,
        ),
        ManualOk(value: final LightResult r) => _ResultPanel(
          title: l.mcLight,
          headline: switch (r.verdict) {
            LightVerdict.exudate => l.mrExudate,
            LightVerdict.transudate => l.mrTransudate,
            LightVerdict.incomplete => l.mrIncomplete,
          },
          children: [
            LgMetric(
              label: l.mrProteinRatio,
              value:
                  '${_n(r.proteinRatio, locale, 2)} · ${state(r.proteinMet)}',
            ),
            LgMetric(
              label: l.mrLdhRatio,
              value: '${_n(r.ldhRatio, locale, 2)} · ${state(r.ldhRatioMet)}',
            ),
            LgMetric(
              label: l.mrLdhUln,
              value: r.ldhOfUln == null
                  ? state(null)
                  : '${_n(r.ldhOfUln!, locale, 2)} · ${state(r.ldhUlnMet)}',
            ),
          ],
        ),
        _ => null,
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Rang ko'rsatkichi — hisoblanmaydi, nima uchunligi va o'rniga MCH/MCHC.
// ---------------------------------------------------------------------------

class ColourIndexScreen extends StatelessWidget {
  const ColourIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final info = manualCalcInfo[ManualCalc.colourIndex]!;
    return LgPage(
      title: l.mcColour,
      subtitle: l.mcColourSub,
      children: [
        LgSectionTitle(l.ciWhatTitle),
        Text(l.ciWhat, style: text.bodyMedium),
        LgSectionTitle(l.ciWhyTitle),
        LgNotice(l.ciWhy, kind: NoticeKind.info),
        LgSectionTitle(l.ciUseTitle),
        Text(l.ciUse, style: text.bodyMedium),
        const SizedBox(height: 10),
        for (final f in info.formula)
          LgPanel(child: Text(f.of(lang), style: text.bodyMedium)),
        LgSectionTitle(l.calcSources),
        for (final (i, r) in info.refs.indexed)
          CalcSourceTile(index: i + 1, ref: r),
      ],
    );
  }
}
