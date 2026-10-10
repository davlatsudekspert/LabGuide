import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../app/shell.dart';
import '../../../app/widgets/lg_page.dart';
import '../../../app/widgets/links.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/lg_widgets.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../learn/exam_question.dart' show keepUnitsTogether;
import '../../reference/reference_content.dart';
import '../../reference/reference_screens.dart';
import '../../settings/settings_controller.dart';
import '../../tools/calc_info.dart';
import '../../tools/clinical_calc_screens.dart';
import '../../tools/clinical_calculators.dart';
import '../../tools/tool_screens.dart';
import '../content_model.dart';
import 'conditions_screens.dart';
import 'content_widgets.dart';

String sectionTitle(String id, AppLocalizations l) => switch (id) {
  'purpose' => l.sectionPurpose,
  'physiology' => l.sectionPhysiology,
  'high_result' => l.sectionHighResult,
  'low_result' => l.sectionLowResult,
  // Sifat (musbat/manfiy) testlar: serologiya, autoantitelolar.
  'positive_result' => l.sectionPositiveResult,
  'negative_result' => l.sectionNegativeResult,
  // Tavsifiy tahlillar (likvor, koprogramma, PAP-test): natija talqini.
  'results' => l.sectionResults,
  'preanalytics' => l.sectionPreanalytics,
  'interference' => l.sectionInterference,
  'related_tests' => l.analyteRelated,
  'limitations' => l.sectionLimitations,
  _ => id,
};

/// Raqamni ortiqcha nolsiz ko'rsatish (100 → "100", 5.55 → "5.55").
///
/// [locale] berilsa — o'nlik belgisi va guruhlash shu til bo'yicha
/// (ru: "5,55", en: "5.55"); berilmasa — nuqta.
String formatNumber(double v, [String? locale]) {
  if (locale != null) return formatResult(v, locale, maxDecimals: 6);
  return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

String formatLimit(DecisionLimit d, [String? locale]) =>
    formatLimitWith(d, (v) => formatNumber(v, locale), d.unit);

/// Chegarani [number] formatlovchi va [unit] bilan yozish (SI ekvivalenti
/// uchun ham — belgilar va qamrov bir xil).
String formatLimitWith(
  DecisionLimit d,
  String Function(double) number,
  String unit,
) {
  final lowSign = d.lowExclusive ? '>' : '≥';
  final highSign = d.highExclusive ? '<' : '≤';
  if (d.low != null && d.high != null) {
    if (!d.lowExclusive && !d.highExclusive) {
      return '${number(d.low!)}–${number(d.high!)} $unit';
    }
    return '$lowSign ${number(d.low!)}, $highSign ${number(d.high!)} $unit';
  }
  if (d.low != null) return '$lowSign ${number(d.low!)} $unit';
  if (d.high != null) return '$highSign ${number(d.high!)} $unit';
  return unit;
}

/// Oraliq: ikkala chegara — “a–b”, bittasi — “≥ a” yoki “≤ b”
/// (avval bir chegarali oraliq “–5” ko'rinishida chiqardi).
String formatRange(double? low, double? high, String unit, [String? locale]) {
  String n(double v) => formatNumber(v, locale);
  if (low != null && high != null) return '${n(low)}–${n(high)} $unit';
  if (low != null) return '≥ ${n(low)} $unit';
  if (high != null) return '≤ ${n(high)} $unit';
  return unit;
}

/// Qiymatni satr bo'linishidan saqlaydi: belgi, son va birlik bir qatorda
/// qoladi ("< 1.4" va "mmol/L" turli qatorga tushmaydi, "mg/" va "dL" ham
/// ajralmaydi). Matn mazmuni o'zgarmaydi — faqat bo'linmas bo'shliq
/// (U+00A0) va so'z bog'lovchi (U+2060) qo'shiladi.
String keepValuesTogether(String text) => text
    .replaceAllMapped(RegExp(r'([<>≤≥]) (?=\d)'), (m) => '${m[1]}\u00A0')
    .replaceAllMapped(RegExp(r'(\d) (?=mg|mmol|mL)'), (m) => '${m[1]}\u00A0')
    .replaceAllMapped(
      RegExp(r'\b(mg|mmol|mL)/(dL|L|24)'),
      (m) => '${m[1]}/\u2060${m[2]}',
    );

/// mg/dL → SI (mmol/L yoki µmol/L) ko'paytuvchisi, moddaning molyar massasi
/// bo'yicha. Raqamlar manbada yo'q — hisoblanadi va "hisoblangan" deb
/// belgilanadi.
double siFactor(UnitConversion c) =>
    (c.siUnit == 'µmol/L' ? 10000 : 10) / c.molarMass;

/// [value] mg/dL ni SI ga o'girib, [locale] bo'yicha formatlaydi
/// (µmol/L — butun, mmol/L — bitta kasr xona).
String siNumber(double value, UnitConversion c, String locale) {
  final digits = c.siUnit == 'µmol/L' ? 0 : 1;
  final f = NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: digits,
  );
  return f.format(roundHalfUp(value * siFactor(c), digits));
}

final _mgDlValue = RegExp(r'(\d+(?:\.\d+)?)(\s|\u00A0)*mg/dL');

/// Faqat mg/dL da berilgan maqsad matnidagi har bir "N mg/dL" ni SI
/// ekvivalentiga almashtiradi ("< 100 mg/dL" → "< 2,6 mmol/L"). Birlik
/// mg/dL bo'lmasa yoki konversiya yo'q bo'lsa — `null`.
String? goalTextInSi(
  TreatmentGoal goal,
  String text,
  UnitConversion? conversion,
  String locale,
) {
  if (conversion == null) return null;
  if (goal.units.length != 1 || goal.units.first != 'mg/dL') return null;
  if (!_mgDlValue.hasMatch(text)) return null;
  return text.replaceAllMapped(
    _mgDlValue,
    (m) =>
        '${siNumber(double.parse(m[1]!), conversion, locale)} ${conversion.siUnit}',
  );
}

class AnalyteScreen extends StatelessWidget {
  const AnalyteScreen({super.key, required this.analyteId});

  final String analyteId;

  @override
  Widget build(BuildContext context) {
    final content = context.services.content;
    return ListenableBuilder(
      listenable: Listenable.merge([content, context.services.settings]),
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final lang = Localizations.localeOf(context).languageCode;
        final pack = content.pack;
        final analyte = pack?.analyte(analyteId);
        if (pack == null || analyte == null) {
          // Yuklanmoqda / xato holatini ContentGate ko'rsatadi; paket tayyor
          // bo'lsa-yu analit topilmasa — "topilmadi".
          return LgPage(
            title: l.testsTitle,
            children: [
              ContentGate(
                builder: (context, _) => LgStateView(
                  kind: StateKind.empty,
                  title: l.analyteNotFound,
                  actionLabel: l.actionBack,
                  onAction: () => context.pop(),
                ),
              ),
            ],
          );
        }
        return LgPage(
          title: analyte.names.of(lang),
          subtitle:
              analyte.tagline?.of(lang) ??
              pack.group(analyte.group)?.names.of(lang),
          children: _AnalyteBody(
            pack: pack,
            analyte: analyte,
            lang: lang,
          ).build(context),
        );
      },
    );
  }
}

/// Karta tarkibini yig'uvchi (LgPage ro'yxatiga to'g'ridan-to'g'ri
/// elementlar sifatida beriladi — ichma-ich scroll yo'q).
class _AnalyteBody {
  _AnalyteBody({required this.pack, required this.analyte, required this.lang});

  final ContentPack pack;
  final Analyte analyte;
  final String lang;

  /// Manba raqami kartadagi tartib bo'yicha: [1], kitob bo'lsa sahifa
  /// bilan — [1, 45-bet].
  /// Bir manba bir da'voda ikki bo'limdan keltirilsa ham bir marta: [1].
  String cite(List<SourceRef> refs, AppLocalizations l) {
    final seen = <String>{};
    return refs
        .map((r) {
          final n = analyte.sourceIds.indexOf(r.sourceId) + 1;
          return r.pages == null ? '[$n]' : '[$n, ${l.citePage(r.pages!)}]';
        })
        .where(seen.add)
        .join('');
  }

  List<Widget> build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final location = GoRouterState.of(context).matchedLocation;
    final base = location.substring(0, location.indexOf('/analyte/'));
    final structureOnly = analyte.contentState == ContentState.structureOnly;
    final group = pack.group(analyte.group);

    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          LgTag(
            contentStateLabel(analyte, l),
            tone: contentStateTone(analyte),
            icon: structureOnly
                ? Icons.construction_rounded
                : Icons.menu_book_rounded,
          ),
          // Subtitle allaqachon guruh nomi bo'lsa, takrorlanmaydi.
          if (group != null && analyte.tagline != null)
            LgTag(group.names.of(lang), tone: LgTone.neutral),
        ],
      ),
      const SizedBox(height: 12),
      _BookmarkButton(analyteId: analyte.id),
      const SizedBox(height: 6),
      if (structureOnly)
        LgNotice(l.analyteStructureOnlyBody, title: l.analyteStructureOnlyTitle)
      else
        LgNotice(l.analyteSampleNotice),
      if (!structureOnly) _glance(context, l),
      if (structureOnly)
        _structureOutline(context, l)
      else
        for (final s in analyte.sections)
          if (s != 'related_tests') _section(context, l, s),
      if (!structureOnly) ...[
        _referenceIntervals(context, l),
        if (analyte.decisionLimits.isNotEmpty) _decisionLimits(context, l),
        if (analyte.treatmentGoals.isNotEmpty) _treatmentGoals(context, l),
      ],
      LgNotice(l.analyteNoInterpretation, kind: NoticeKind.info),
      AnalyteConditionsSection(pack: pack, analyteId: analyte.id),
      if (analyte.related.isNotEmpty) ...[
        LgSectionTitle(l.analyteRelated),
        for (final id in analyte.related)
          if (pack.analyte(id) case final related?)
            AnalyteRow(
              analyte: related,
              onTap: () => context.push('$base/analyte/${related.id}'),
            ),
      ],
      const SizedBox(height: 8),
      if (analyte.conversion != null)
        LgRow(
          title: l.analyteConvertUnits,
          subtitle: l.analyteConvertUnitsSub,
          icon: Icons.swap_vert_rounded,
          onTap: () => context.push('$location/units'),
        ),
      for (final c
          in calculatorsByAnalyte[analyte.id] ?? const <ClinicalCalc>[])
        LgRow(
          title: calcTitle(c, l),
          subtitle: l.analyteCalculatorSub,
          icon: calcIcon(c),
          onTap: () => openInTab(context, '/lab/calculators/${calcRoute(c)}'),
        ),
      // Kitob/rasmiy manbalarga asoslangan jadval va algoritmlar.
      for (final t in refTopicsForAnalyte(analyte.id))
        LgRow(
          title: t.title.of(lang),
          subtitle: l.refOpenSub,
          icon: Icons.table_chart_outlined,
          onTap: () => openInTab(context, refRoute(t.id)),
        ),
      LgRow(
        title: l.analyteMethodCalibration,
        subtitle: l.analyteMethodCalibrationSub,
        icon: Icons.tune_rounded,
        onTap: () =>
            openInTab(context, '/lab/calibration?analyte=${analyte.id}'),
      ),
      // Shu analit bo'yicha savollar bo'lsa — o'sha joyning o'zida (tab
      // stacki saqlanadi); bo'lmasa — umumiy mashq bo'limi.
      if (pack.quiz.where((q) => q.topicIds.contains(analyte.id)).length
          case final n when n > 0)
        LgRow(
          title: l.analytePractice,
          subtitle: l.quizQuestionCount(n),
          icon: Icons.quiz_outlined,
          onTap: () => context.push('$location/quiz'),
          divider: false,
        )
      else
        LgRow(
          title: l.analytePractice,
          subtitle: l.analytePracticeSub,
          icon: Icons.quiz_outlined,
          // O'rganish tabidagi eski mashq holati emas — yangi mavzu tanlash.
          onTap: () => context.go(
            '/learn/quiz?fresh=${DateTime.now().microsecondsSinceEpoch}',
          ),
          divider: false,
        ),
      if (analyte.sourceIds.isNotEmpty) _sources(context, l),
      _review(context, l, text),
    ];
  }

  Widget _glance(BuildContext context, AppLocalizations l) {
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.analyteAtAGlance,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          if (analyte.specimen != null)
            LgMetric(
              label: l.analyteSpecimen,
              value: analyte.specimen!.of(lang),
            ),
          if (analyte.population != null)
            LgMetric(
              label: l.analytePopulation,
              value: analyte.population!.of(lang),
            ),
          LgMetric(
            label: l.analyteMethod,
            value: analyte.method ?? l.analyteMethodNotSet,
          ),
          if (analyte.units.isNotEmpty)
            LgMetric(label: l.analyteUnits, value: analyte.units.join(' · ')),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, AppLocalizations l, String id) {
    final text = Theme.of(context).textTheme;
    final claims = analyte.claimsFor(id);
    final note = analyte.notes[id];
    final empty = claims.isEmpty && note == null;
    return _Expandable(
      title: sectionTitle(id, l),
      initiallyExpanded: !empty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final c in claims)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${c.text.of(lang)} ${cite(c.refs, l)}',
                style: text.bodyLarge,
              ),
            ),
          if (note != null) Text(note.of(lang), style: text.bodyMedium),
          if (empty) Text(l.analyteNotWritten, style: text.bodyMedium),
        ],
      ),
    );
  }

  Widget _structureOutline(BuildContext context, AppLocalizations l) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in [
            ...analyte.sections.where((s) => s != 'related_tests'),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: p.sub,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(sectionTitle(s, l), style: text.titleSmall),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(l.analyteNotWritten, style: text.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _referenceIntervals(BuildContext context, AppLocalizations l) {
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.analyteRefIntervals, style: text.titleMedium),
          const SizedBox(height: 6),
          if (analyte.referenceIntervals.isEmpty)
            Text(l.analyteRefIntervalNone, style: text.bodyMedium)
          else
            for (final r in analyte.referenceIntervals)
              LgMetric(
                label: '${r.population.of(lang)} · ${r.method}',
                value:
                    '${formatRange(r.low, r.high, r.unit, locale)} ${cite(r.refs, l)}',
              ),
        ],
      ),
    );
  }

  /// Har bir chegara alohida blokda: qiymat, nomi, qaysi aholiga tegishli,
  /// izoh va o'z manbasi. (Avval aholi va izohlar umumiy ro'yxatda edi —
  /// qaysi chegara qaysi aholiga tegishli ekani adashtirardi.)
  Widget _decisionLimits(BuildContext context, AppLocalizations l) {
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final limits = analyte.decisionLimits;
    final conversion = analyte.conversion;
    // mg/dL chegarasining SI ekvivalenti (SI tanlangan bo'lsa). Manbada yo'q —
    // hisoblangan, belgilanadi.
    final siPreferred = context.services.settings.unitSystem == UnitSystem.si;
    String? si(DecisionLimit d) {
      if (!siPreferred || conversion == null || d.unit != 'mg/dL') return null;
      return l.analyteSiApprox(
        formatLimitWith(
          d,
          (v) => siNumber(v, conversion, locale),
          conversion.siUnit,
        ),
      );
    }

    final anySi = limits.any((d) => si(d) != null);
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LgTag(analyte.names.of(lang)),
          const SizedBox(height: 10),
          Text(l.analyteDecisionLimits, style: text.titleMedium),
          for (final (i, d) in limits.indexed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: i == limits.length - 1
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: p.line.withValues(alpha: 0.7),
                        ),
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 2,
                    children: [
                      Text(d.label.of(lang), style: text.bodyMedium),
                      Text(
                        '${formatLimit(d, locale)} ${cite(d.refs, l)}',
                        style: text.titleSmall,
                      ),
                    ],
                  ),
                  if (si(d) case final siText?)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(siText, style: text.bodyMedium),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(d.population.of(lang), style: text.bodySmall),
                  ),
                  if (d.note != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(d.note!.of(lang), style: text.bodySmall),
                    ),
                ],
              ),
            ),
          if (anySi)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                keepUnitsTogether(
                  l.analyteSiNote(
                    conversion!.siUnit,
                    formatResult(conversion.molarMass, locale, maxDecimals: 3),
                  ),
                ),
                style: text.bodySmall,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l.analyteDecisionNotRef,
              style: text.bodySmall!.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Davolash maqsadlari — RI va DL dan ALOHIDA panel. Har bir yo'riqnoma
  /// o'z jadvalida (nomi va yili sarlavhada); qatorda — yo'riqnomaning o'z
  /// bemor guruhi, maqsad va manba. Ilova xavf toifasini aniqlamaydi va
  /// tavsiya bermaydi: yuqorida shu haqda ogohlantirish turadi.
  Widget _treatmentGoals(BuildContext context, AppLocalizations l) {
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final siPreferred = context.services.settings.unitSystem == UnitSystem.si;
    final byGuideline = <String, List<TreatmentGoal>>{};
    for (final g in analyte.treatmentGoals) {
      byGuideline.putIfAbsent(g.guidelineId, () => []).add(g);
    }
    return LgPanel(
      key: const ValueKey('treatment-goals-panel'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LgTag(analyte.names.of(lang)),
          const SizedBox(height: 10),
          Semantics(
            header: true,
            child: Text(l.analyteTreatmentGoals, style: text.titleMedium),
          ),
          LgNotice(l.analyteTreatmentGoalsNotice),
          for (final MapEntry(key: id, value: goals) in byGuideline.entries)
            Semantics(
              container: true,
              child: Container(
                key: ValueKey('treatment-goals-$id'),
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                decoration: BoxDecoration(
                  border: Border.all(color: p.line),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l.analyteGoalGuideline(
                          goals.first.guidelineName,
                          '${goals.first.year}',
                        ),
                        style: text.titleSmall,
                      ),
                    ),
                    for (final (i, g) in goals.indexed)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: i == goals.length - 1
                              ? null
                              : Border(
                                  bottom: BorderSide(
                                    color: p.line.withValues(alpha: 0.7),
                                  ),
                                ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              keepValuesTogether(g.population.of(lang)),
                              style: text.bodyMedium,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '${keepValuesTogether(g.target.of(lang))}'
                                '\u00A0${cite(g.refs, l)}',
                                style: text.titleSmall,
                              ),
                            ),
                            if (siPreferred)
                              if (goalTextInSi(
                                    g,
                                    g.target.of(lang),
                                    analyte.conversion,
                                    locale,
                                  )
                                  case final siText?)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    l.analyteSiApprox(
                                      keepValuesTogether(siText),
                                    ),
                                    key: const ValueKey('goal-si'),
                                    style: text.bodyMedium,
                                  ),
                                ),
                            if (g.note != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  keepValuesTogether(g.note!.of(lang)),
                                  style: text.bodySmall,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (siPreferred &&
              analyte.conversion != null &&
              analyte.treatmentGoals.any(
                (g) =>
                    goalTextInSi(
                      g,
                      g.target.of(lang),
                      analyte.conversion,
                      locale,
                    ) !=
                    null,
              ))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                keepUnitsTogether(
                  l.analyteSiNote(
                    analyte.conversion!.siUnit,
                    formatResult(
                      analyte.conversion!.molarMass,
                      locale,
                      maxDecimals: 3,
                    ),
                  ),
                ),
                style: text.bodySmall,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              l.analyteTreatmentGoalsNotRef,
              style: text.bodySmall!.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sources(BuildContext context, AppLocalizations l) {
    final text = Theme.of(context).textTheme;
    return LgPanel(
      margin: const EdgeInsets.only(top: 18, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.analyteSources, style: text.titleMedium),
          const SizedBox(height: 4),
          for (var i = 0; i < analyte.sourceIds.length; i++)
            if (pack.source(analyte.sourceIds[i]) case final s?)
              SourceTile(index: i + 1, source: s),
        ],
      ),
    );
  }

  /// Karta manbalari ko'rilgan eng so'nggi sana (`accessed`).
  String? _lastAccessed() {
    final dates = [
      for (final id in analyte.sourceIds) ?pack.source(id)?.accessed,
    ]..sort();
    return dates.isEmpty ? null : dates.last;
  }

  Widget _review(BuildContext context, AppLocalizations l, TextTheme text) {
    final approved = analyte.isReviewerApproved;
    final translationsPending = analyte.translationReview.values.any(
      (v) => v != 'approved',
    );
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.analyteReview, style: text.titleMedium),
          const SizedBox(height: 6),
          // Mustaqil mutaxassis tasdig'i va avtomatik (agent) tekshiruvi —
          // alohida qatorlar: agent tekshiruvi tasdiq o'rnini bosmaydi.
          LgMetric(
            label: l.analyteExpertApproval,
            value: approved
                ? l.analyteReviewApproved
                : l.analyteExpertApprovalPending,
          ),
          if (!approved)
            LgMetric(label: '—', value: l.analyteReviewerNotAssigned),
          // Bir kunda bir nechta tekshiruv (turli audit) — bitta qator.
          for (final date in {for (final c in analyte.agentChecks) c.date})
            LgMetric(
              label: l.analyteAgentCheck,
              value: l.analyteAgentCheckValue(date),
            ),
          // Kelib chiqishi: kim tayyorlagan va manbalar qachon ko'rilgan.
          LgMetric(label: l.analytePreparedBy, value: l.analyteEditorial),
          if (_lastAccessed() case final date?)
            LgMetric(label: l.analyteSourcesChecked, value: date),
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

/// Manba: raqam, nashriyot, sarlavha, sanalar, yurisdiksiya. Veb-manba
/// havolasini ochish yoki nusxalash mumkin; kitob/qo'llanma uchun
/// mualliflar, yil va til ko'rsatiladi.
class SourceTile extends StatelessWidget {
  const SourceTile({super.key, required this.index, required this.source});

  final int index;
  final ContentSource source;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final item = source.libraryItemId == null
        ? null
        : context.services.content.pack?.libraryItem(source.libraryItemId!);
    final meta = [
      if (item != null) ...[
        if (item.authors.isNotEmpty) item.authors.join(', '),
        if (item.year != null) '${item.year}',
        item.language.toUpperCase(),
      ],
      if (source.accessed != null) l.analyteSourceAccessed(source.accessed!),
      ?source.sourceDate,
      ?source.jurisdiction,
    ].join(' · ');
    final url = source.url;
    final title = Text(
      '[$index] ${source.publisher} · ${source.title}',
      style: text.titleSmall!.copyWith(
        color: url == null ? null : p.brand,
        decoration: url == null ? null : TextDecoration.underline,
        decorationColor: p.brand.withValues(alpha: 0.5),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (url == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: title,
            )
          else
            InkWell(
              onTap: () => openExternalLink(context, url),
              onLongPress: () => copyLink(context, url),
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: kMinTap),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: title),
                      const SizedBox(width: 6),
                      Icon(Icons.open_in_new_rounded, size: 18, color: p.brand),
                    ],
                  ),
                ),
              ),
            ),
          if (meta.isNotEmpty) Text(meta, style: text.bodySmall),
          if (source.note != null) Text(source.note!, style: text.bodySmall),
          Text(
            source.isCitationOnlyBook
                ? l.analyteReuseCitationOnly
                : item == null
                ? l.analyteReuseRightsVerify
                : rightsLabel(item.rights.distribution, l),
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}

String rightsLabel(DistributionRights r, AppLocalizations l) => switch (r) {
  DistributionRights.unknown => l.rightsUnknown,
  DistributionRights.personalOnly => l.rightsPersonal,
  DistributionRights.permitted => l.rightsPermitted,
  DistributionRights.denied => l.rightsDenied,
};

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.analyteId});

  final String analyteId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bookmarks = context.services.bookmarks;
    return ListenableBuilder(
      listenable: bookmarks,
      builder: (context, _) {
        final saved = bookmarks.contains(analyteId);
        return Semantics(
          toggled: saved,
          child: LgButton.secondary(
            label: saved ? l.analyteSaved : l.analyteSave,
            icon: saved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final added = await bookmarks.toggle(analyteId);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      added ? l.analyteSavedToast : l.analyteRemovedToast,
                    ),
                  ),
                );
            },
          ),
        );
      },
    );
  }
}

/// Ochiladigan bo'lim (HTML `<details>` analogi). Sarlavha 44 px dan
/// past emas; holat screen readerga "expanded/collapsed" sifatida beriladi.
class _Expandable extends StatefulWidget {
  const _Expandable({
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<_Expandable> createState() => _ExpandableState();
}

class _ExpandableState extends State<_Expandable> {
  late bool _open = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final duration = LgMotion.of(context, const Duration(milliseconds: 180));
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: p.line.withValues(alpha: 0.7)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            expanded: _open,
            button: true,
            child: InkWell(
              onTap: () => setState(() => _open = !_open),
              borderRadius: BorderRadius.circular(10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(widget.title, style: text.titleMedium),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: duration,
                      child: Icon(Icons.expand_more_rounded, color: p.sub),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: duration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
