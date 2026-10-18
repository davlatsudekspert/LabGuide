import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;

import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../content/ui/analyte_screen.dart'
    show formatLimit, formatRange, keepValuesTogether, sectionTitle;
import '../lab/preanalytics_info.dart';
import '../microscopy/microscopy_atlas.dart';
import '../reference/reference_content.dart';
import '../tools/calc_info.dart';
import 'curriculum.dart';
import 'lecture_slide.dart';

// Avtomatik taqdimot (D-47): ustoz tanlagan mavzu yoki tahlillardan
// slaydlar YIG'ILADI — hech qanday LLM yoki tashqi chaqiruvsiz, faqat ilovada
// allaqachon manbaga bog'langan mazmundan:
//   * tahlil kartasi da'volari (maqsad, fiziologiya, oshishi/pasayishi,
//     preanalitika, xalaqit, cheklov) — har da'vo manbasi bilan;
//   * qaror chegaralari, referens intervallar, davolash maqsadlari (jadval);
//   * kitob/WHO manbali jadvallar, klinik holat tavsifi, atlas rasmlari;
//   * mashq savollari (to'g'ri javob va asosi bilan).
// Mazmun yetmasa slayd CHIQMAYDI (to'qilmaydi). Tanlangan tilda matn yo'q
// bo'lsa — o'sha qism tashlab yuboriladi va aytiladi; tillar aralashtirilmaydi.
// Har slaydda manba ko'rsatiladi; oxirida qolgan slaydlarning manbalari
// ro'yxati avtomatik yig'iladi ([assembleAutoDeck]).

/// Preview ro'yxatida slayd turi (belgi va tartib uchun).
enum AutoSlideKind {
  title,
  intro,
  definition,
  limits,
  goals,
  increase,
  decrease,
  result,
  preanalytics,
  interference,
  reference,
  condition,
  atlas,
  general,
  quiz,
  sources,
}

/// Slaydda keltirilgan manba (manbalar slaydi uchun, takrorsiz).
@immutable
class AutoSource {
  const AutoSource({
    required this.id,
    required this.label,
    this.url,
    this.accessed,
  });

  final String id;

  /// "Nashriyot · Sarlavha" yoki bibliografik yozuv.
  final String label;
  final String? url;

  /// Veb-manba ko'rilgan sana (ISO).
  final String? accessed;
}

/// Yig'ilgan slayd: ko'rsatiladigan [slide] + uning manbalari.
@immutable
class AutoSlide {
  const AutoSlide({
    required this.id,
    required this.kind,
    required this.slide,
    required this.sources,
  });

  final String id;
  final AutoSlideKind kind;
  final LectureSlide slide;
  final List<AutoSource> sources;
}

/// Ustoz tanlovi: mavzu YOKI tahlillar.
@immutable
class AutoDeckSpec {
  const AutoDeckSpec({
    this.topicId,
    this.analyteIds = const [],
    this.includeQuiz = true,
    this.includeGeneralPreanalytics = false,
  });

  final String? topicId;
  final List<String> analyteIds;

  /// Mashq savollari slaydlari (kartaga bog'langan savollar).
  final bool includeQuiz;

  /// Umumiy preanalitika (JSST 2010): probirkalar tartibi, gemoliz, jgut.
  final bool includeGeneralPreanalytics;
}

/// Builder natijasi.
@immutable
class AutoDeck {
  const AutoDeck({
    required this.slides,
    required this.notices,
    required this.packVersion,
    required this.skippedForLanguage,
  });

  /// Tarkibiy slaydlar (sarlavha bilan boshlanadi). Mazmun yetmasa — bo'sh.
  final List<AutoSlide> slides;

  /// Ustozga aytiladigan halol izohlar (tashlab yuborilgan kartalar, til).
  final List<String> notices;
  final String packVersion;

  /// Tanlangan tilda matni yo'qligi uchun tashlab yuborilgan elementlar soni.
  final int skippedForLanguage;

  bool get isEmpty => slides.isEmpty;
}

/// Bitta slaydga sig'adigan matn: bandlar soni va belgilar.
const _maxBullets = 3;
const _maxChars = 600;
const _maxTableRows = 4;
const _maxSourcesPerSlide = 4;

/// Tahlilga bog'liq mashq savollari (har tahlildan ko'pi bilan) va umumiy
/// chegara.
const autoQuizPerAnalyte = 2;
const autoQuizTotal = 10;

/// Atlas rasmlari: har bo'limdan va umuman ko'pi bilan.
const _atlasPerSection = 4;
const _atlasTotal = 6;

/// Atlas rasmi izohi (belgi) — slaydga sig'sin.
const _maxCaption = 320;

/// Taqdimotga bir martada qo'shiladigan tahlillar soni (analit rejimi).
const autoMaxAnalytes = 12;

AutoDeck buildAutoDeck({
  required AppLocalizations l,
  required ContentPack pack,
  required AutoDeckSpec spec,
  Curriculum? curriculum,
  MicroAtlas? atlas,
}) => _Builder(
  l: l,
  pack: pack,
  spec: spec,
  curriculum: curriculum,
  atlas: atlas,
).build();

class _Piece {
  const _Piece(this.text, this.refs);
  final String text;
  final List<SourceRef> refs;
}

class _Builder {
  _Builder({
    required this.l,
    required this.pack,
    required this.spec,
    this.curriculum,
    this.atlas,
  }) : lang = l.localeName;

  final AppLocalizations l;
  final ContentPack pack;
  final AutoDeckSpec spec;
  final Curriculum? curriculum;
  final MicroAtlas? atlas;
  final String lang;

  final _content = <AutoSlide>[];
  final _notices = <String>[];
  int _langSkips = 0;
  int _seq = 0;

  /// Tanlangan tildagi matn; yo'q yoki bo'sh bo'lsa `null` (boshqa tilga
  /// o'tilmaydi) va hisobga olinadi.
  String? _say(LocalizedText? t) {
    if (t == null) return null;
    final v = t.values[lang];
    if (v == null || v.trim().isEmpty) {
      _langSkips++;
      return null;
    }
    return v.trim();
  }

  String _id(String scope) => '$scope#${++_seq}';

  // ---------------------------------------------------------------- manbalar

  AutoSource? _packSource(String id) {
    final s = pack.source(id);
    if (s == null) return null;
    return AutoSource(
      id: s.id,
      label: '${s.publisher} · ${s.title}',
      url: s.url,
      accessed: s.accessed,
    );
  }

  /// Da'vo manbalari; hammasi paketda bo'lishi shart (aks holda da'vo
  /// "tekshirilmagan" — `null`).
  ({List<AutoSource> sources, String line})? _refs(List<SourceRef> refs) {
    if (refs.isEmpty) return null;
    final sources = <AutoSource>[];
    final locators = <String, List<String>>{};
    for (final r in refs) {
      final s = _packSource(r.sourceId);
      if (s == null) return null;
      if (!sources.any((x) => x.id == s.id)) sources.add(s);
      final loc = [
        if (r.locator != null && r.locator!.trim().isNotEmpty) r.locator!,
        if (r.pages != null) l.citePage(r.pages!),
      ].join(', ');
      final list = locators.putIfAbsent(s.id, () => []);
      if (loc.isNotEmpty && !list.contains(loc)) list.add(loc);
    }
    final parts = [
      for (final s in sources)
        locators[s.id]!.isEmpty
            ? _short(s.label)
            : '${_short(s.label)} — ${locators[s.id]!.join('; ')}',
    ];
    return (sources: sources, line: parts.join('; '));
  }

  ({List<AutoSource> sources, String line}) _calcRefs(List<CalcRef> refs) {
    final sources = <AutoSource>[];
    final locators = <String, List<String>>{};
    for (final r in refs) {
      if (!sources.any((x) => x.id == r.source.id)) {
        sources.add(
          AutoSource(
            id: r.source.id,
            label: r.source.citation,
            url: r.source.url,
          ),
        );
      }
      final list = locators.putIfAbsent(r.source.id, () => []);
      final loc = r.locator.isEmpty ? '' : localizePages(r.locator, l.citePage);
      if (loc.isNotEmpty && !list.contains(loc)) list.add(loc);
    }
    final parts = [
      for (final s in sources)
        locators[s.id]!.isEmpty
            ? _short(s.label)
            : '${_short(s.label)} — ${locators[s.id]!.join('; ')}',
    ];
    return (sources: sources, line: parts.join('; '));
  }

  /// Slayd pastidagi manba qatori ixcham: uzun sarlavha qisqartiriladi
  /// (to'liq yozuv oxiridagi manbalar slaydida).
  static String _short(String s, [int max = 110]) {
    if (s.length <= max) return s;
    final cut = s.substring(0, max);
    final sp = cut.lastIndexOf(' ');
    return '${(sp > max ~/ 2 ? cut.substring(0, sp) : cut).trimRight()}…';
  }

  String _sourceLine(String text) => l.autoPresSourceLine(text);

  static String _part(String title, int i, int n) =>
      n <= 1 ? title : '$title (${i + 1}/$n)';

  // ----------------------------------------------------------------- qo'shish

  void _add(
    AutoSlideKind kind,
    LectureSlide slide,
    List<AutoSource> sources, {
    String scope = 'slide',
  }) {
    assert(sources.isNotEmpty, 'har slaydda manba bo\'lishi shart');
    _content.add(
      AutoSlide(id: _id(scope), kind: kind, slide: slide, sources: sources),
    );
  }

  /// Bandlar slaydlari: da'volar bo'laklarga bo'linadi, har bo'lak o'z
  /// manbalari bilan.
  void _addBullets(
    AutoSlideKind kind, {
    required String scope,
    required String title,
    required String eyebrow,
    required List<_Piece> pieces,
    String? note,
    ({List<AutoSource> sources, String line})? calc,
  }) {
    final chunks = <List<_Piece>>[];
    var cur = <_Piece>[];
    var chars = 0;
    for (final p in pieces) {
      if (cur.isNotEmpty &&
          (cur.length >= _maxBullets || chars + p.text.length > _maxChars)) {
        chunks.add(cur);
        cur = [];
        chars = 0;
      }
      cur.add(p);
      chars += p.text.length;
    }
    if (cur.isNotEmpty) chunks.add(cur);
    for (final (i, chunk) in chunks.indexed) {
      final refs = calc ?? _refs([for (final p in chunk) ...p.refs])!;
      _add(
        kind,
        LectureSlide(
          eyebrow: eyebrow,
          title: _part(title, i, chunks.length),
          bullets: [for (final p in chunk) p.text],
          note: note,
          source: _sourceLine(refs.line),
        ),
        refs.sources,
        scope: scope,
      );
    }
  }

  // ------------------------------------------------------------------- build

  AutoDeck build() {
    final topic = spec.topicId == null
        ? null
        : curriculum?.topic(spec.topicId!);
    final analyteIds = [
      ...spec.analyteIds,
      if (topic != null) ...topic.links.analytes,
    ];
    final analytes = <Analyte>[];
    for (final id in analyteIds) {
      final a = pack.analyte(id);
      if (a != null && !analytes.contains(a)) analytes.add(a);
    }
    final used = <Analyte>[];
    for (final a in analytes) {
      if (_analyte(a)) used.add(a);
    }
    if (topic != null) {
      for (final id in topic.links.conditions) {
        final c = pack.condition(id);
        if (c != null) _condition(c);
      }
      for (final id in topic.links.reference) {
        final t = refTopic(id);
        if (t != null) _referenceTopic(t);
      }
      if (atlas != null) {
        _atlasFigures(topic.links.microscopy);
      }
    }
    if (spec.includeGeneralPreanalytics) _generalPreanalytics();
    if (spec.includeQuiz) _quiz(used, topic);

    var slides = _content;
    if (slides.isNotEmpty) {
      slides = [_titleSlide(topic, used), ...slides];
    }
    if (_langSkips > 0) _notices.add(l.autoPresNoticeLang(_langSkips));
    return AutoDeck(
      slides: List.unmodifiable(slides),
      notices: List.unmodifiable(_notices),
      packVersion: pack.contentVersion,
      skippedForLanguage: _langSkips,
    );
  }

  AutoSlide _titleSlide(CurriculumTopic? topic, List<Analyte> analytes) {
    final topicTitle = topic?.title.values[lang];
    final module = topic == null ? null : curriculum?.moduleOf(topic);
    final moduleTitle = module?.title.values[lang];
    if (topic != null && topicTitle == null) _langSkips++;
    final names = <String>[for (final a in analytes) ?a.names.values[lang]];
    final note = [
      if (analytes.isNotEmpty) l.sourcesDisclaimer,
      if (_langSkips > 0) l.autoPresNoticeLang(_langSkips),
    ].join('\n');
    return AutoSlide(
      id: _id('title'),
      kind: AutoSlideKind.title,
      sources: [AutoSource(id: 'labguide-pack', label: _packLabel())],
      slide: LectureSlide(
        template: SlideTemplate.title,
        section: true,
        eyebrow: moduleTitle ?? l.autoPresTitle,
        title: topicTitle ?? l.autoPresDeckTitleTests,
        bullets: names.length <= 6
            ? names
            : [...names.take(6), l.autoPresMoreItems(names.length - 6)],
        note: note.isEmpty ? null : note,
        source: _sourceLine(_packLabel()),
      ),
    );
  }

  String _packLabel() => l.autoPresPackSource(pack.contentVersion);

  // ------------------------------------------------------------------ analit

  /// Karta slaydlari; mazmun bo'lmasa `false`.
  bool _analyte(Analyte a) {
    final name = _say(a.names);
    if (name == null) return false;
    if (a.contentState == ContentState.structureOnly) {
      _notices.add(l.autoPresNoticeStructureOnly(name));
      return false;
    }
    final before = _content.length;

    // 1) Kartaning ishchi ko'rinishi: nom, guruh, namuna, birlik.
    final cardSources = <AutoSource>[
      for (final id in a.sourceIds) ?_packSource(id),
    ];
    if (cardSources.isNotEmpty) {
      final group = pack.group(a.group);
      final specimen = a.specimen == null ? null : _say(a.specimen);
      final population = a.population == null ? null : _say(a.population);
      final shown = cardSources.take(2).map((s) => _short(s.label)).join('; ');
      final more = cardSources.length > 3 ? ' +${cardSources.length - 3}' : '';
      _add(
        AutoSlideKind.intro,
        LectureSlide(
          template: SlideTemplate.title,
          eyebrow: group == null ? null : _say(group.names),
          title: name,
          bullets: [
            if (specimen != null) '${l.analyteSpecimen}: $specimen',
            if (population != null) '${l.analytePopulation}: $population',
            if (a.units.isNotEmpty) '${l.analyteUnits}: ${a.units.join(' · ')}',
          ],
          source: _sourceLine('$shown$more'),
        ),
        cardSources,
        scope: a.id,
      );
    }

    // 2) Ta'rif va fiziologiya.
    _section(a, name, 'purpose', AutoSlideKind.definition);
    _section(a, name, 'physiology', AutoSlideKind.definition);

    // 3) Jadvallar: referens intervallar, qaror chegaralari, davolash maqsadi.
    _referenceIntervals(a, name);
    _decisionLimits(a, name);
    _treatmentGoals(a, name);

    // 4) Oshishi/pasayishi, natija talqini, preanalitika, xalaqit. "Cheklovlar"
    // bandi umumiy gap (har kartada bir xil), slayd sifatida chiqarilmaydi.
    _section(a, name, 'high_result', AutoSlideKind.increase);
    _section(a, name, 'low_result', AutoSlideKind.decrease);
    _section(a, name, 'positive_result', AutoSlideKind.result);
    _section(a, name, 'negative_result', AutoSlideKind.result);
    _section(a, name, 'results', AutoSlideKind.result);
    _section(a, name, 'preanalytics', AutoSlideKind.preanalytics);
    _section(a, name, 'interference', AutoSlideKind.interference);

    // Faqat kartaning umumiy qatori chiqqan bo'lsa (mazmun yo'q) — chiqarilmaydi.
    final contentSlides = _content.length - before;
    final onlyIntro =
        contentSlides == 1 && _content.last.kind == AutoSlideKind.intro;
    if (contentSlides == 0 || onlyIntro) {
      if (contentSlides > 0) _content.removeLast();
      _notices.add(l.autoPresNoticeNoContent(name));
      return false;
    }
    return true;
  }

  void _section(Analyte a, String name, String id, AutoSlideKind kind) {
    if (!a.sections.contains(id)) return;
    final pieces = <_Piece>[];
    for (final c in a.claimsFor(id)) {
      final text = _say(c.text);
      if (text == null || _refs(c.refs) == null) continue;
      pieces.add(_Piece(text, c.refs));
    }
    if (pieces.isEmpty) return;
    String? note;
    if (id == 'preanalytics' && a.notes[id] != null) {
      // Tahririy izoh: universal vaqt/harorat berilmaydi (klinik da'vo emas).
      note = _say(a.notes[id]);
    }
    _addBullets(
      kind,
      scope: a.id,
      title: sectionTitle(id, l),
      eyebrow: name,
      pieces: pieces,
      note: note,
    );
  }

  /// Jadval qatorlari bo'laklarga; har bo'lak o'z manbalari bilan.
  void _addTable(
    AutoSlideKind kind, {
    required String scope,
    required String title,
    required String eyebrow,
    required List<String> header,
    required List<List<String>> rows,
    required List<List<SourceRef>> rowRefs,
    String? note,
  }) {
    // Uch ustunli jadvalda qatorlar uzunroq — slaydga kamroq sig'adi.
    final per = header.length >= 3 ? _maxTableRows - 1 : _maxTableRows;
    final n = (rows.length / per).ceil();
    for (var i = 0; i < n; i++) {
      final from = i * per;
      final to = (from + per).clamp(0, rows.length);
      final refs = _refs([for (var k = from; k < to; k++) ...rowRefs[k]])!;
      _add(
        kind,
        LectureSlide(
          template: SlideTemplate.table,
          eyebrow: eyebrow,
          title: _part(title, i, n),
          tableHeader: header,
          tableRows: rows.sublist(from, to),
          note: note,
          source: _sourceLine(refs.line),
        ),
        refs.sources,
        scope: scope,
      );
    }
  }

  void _referenceIntervals(Analyte a, String name) {
    final rows = <List<String>>[];
    final refs = <List<SourceRef>>[];
    for (final r in a.referenceIntervals) {
      final population = _say(r.population);
      if (population == null || _refs(r.refs) == null) continue;
      rows.add([
        '$population · ${r.method}',
        keepValuesTogether(formatRange(r.low, r.high, r.unit, lang)),
      ]);
      refs.add(r.refs);
    }
    if (rows.isEmpty) return;
    _addTable(
      AutoSlideKind.limits,
      scope: a.id,
      title: l.analyteRefIntervals,
      eyebrow: name,
      header: [l.autoPresColIndicator, l.autoPresColValue],
      rows: rows,
      rowRefs: refs,
    );
  }

  void _decisionLimits(Analyte a, String name) {
    final rows = <List<String>>[];
    final refs = <List<SourceRef>>[];
    for (final d in a.decisionLimits) {
      final label = _say(d.label);
      final population = _say(d.population);
      if (label == null || population == null || _refs(d.refs) == null) {
        continue;
      }
      final note = d.note == null ? null : _say(d.note);
      rows.add([
        label,
        keepValuesTogether(formatLimit(d, lang)),
        [population, ?note].join('\n'),
      ]);
      refs.add(d.refs);
    }
    if (rows.isEmpty) return;
    _addTable(
      AutoSlideKind.limits,
      scope: a.id,
      title: l.analyteDecisionLimits,
      eyebrow: name,
      header: [l.autoPresColIndicator, l.autoPresColValue, l.analytePopulation],
      rows: rows,
      rowRefs: refs,
      // Chegara referens interval emas — slaydning o'zida aytiladi.
      note: l.analyteDecisionNotRef,
    );
  }

  void _treatmentGoals(Analyte a, String name) {
    // Almashtirilgan (eskirgan) yo'riqnomalar taqdimotga kirmaydi.
    final byGuideline = <String, List<TreatmentGoal>>{};
    for (final g in a.treatmentGoals) {
      if (g.historical) continue;
      byGuideline.putIfAbsent(g.guidelineId, () => []).add(g);
    }
    for (final goals in byGuideline.values) {
      final rows = <List<String>>[];
      final refs = <List<SourceRef>>[];
      for (final g in goals) {
        final population = _say(g.population);
        final target = _say(g.target);
        if (population == null || target == null || _refs(g.refs) == null) {
          continue;
        }
        final note = g.note == null ? null : _say(g.note);
        rows.add([
          keepValuesTogether(population),
          keepValuesTogether([target, ?note].join('\n')),
        ]);
        refs.add(g.refs);
      }
      if (rows.isEmpty) continue;
      _addTable(
        AutoSlideKind.goals,
        scope: a.id,
        title: l.analyteTreatmentGoals,
        eyebrow:
            '$name · ${l.analyteGoalGuideline(goals.first.guidelineName, '${goals.first.year}')}',
        header: [l.analytePopulation, l.autoPresColTarget],
        rows: rows,
        rowRefs: refs,
        note:
            '${l.analyteTreatmentGoalsNotice}\n${l.analyteTreatmentGoalsNotRef}',
      );
    }
  }

  // ------------------------------------------------------------ klinik holat

  void _condition(ClinicalCondition c) {
    final name = _say(c.names);
    final text = _say(c.summary.text);
    final refs = _refs(c.summary.refs);
    if (name == null || text == null || refs == null) return;
    _add(
      AutoSlideKind.condition,
      LectureSlide(
        eyebrow: l.lectureConditions,
        title: name,
        bullets: [text],
        source: _sourceLine(refs.line),
      ),
      refs.sources,
      scope: c.id,
    );
  }

  // ------------------------------------------------- jadvallar va algoritmlar

  void _referenceTopic(RefTopic t) {
    final topicTitle = _say(t.title);
    if (topicTitle == null) return;
    for (final b in t.blocks) {
      final title = _say(b.title);
      if (title == null || b.refs.isEmpty) continue;
      final tag = b.tag == null ? null : _say(b.tag);
      final refs = _calcRefs(b.refs);
      final rows = <List<String>>[];
      for (final f in b.facts) {
        final label = _say(f.label);
        final value = _say(f.value);
        if (label != null && value != null) rows.add([label, value]);
      }
      final bullets = <String>[];
      for (final x in b.bullets) {
        final s = _say(x);
        if (s != null) bullets.add(s);
      }
      if (rows.isNotEmpty) {
        final n = (rows.length / _maxTableRows).ceil();
        for (var i = 0; i < n; i++) {
          _add(
            AutoSlideKind.reference,
            LectureSlide(
              template: SlideTemplate.table,
              eyebrow: topicTitle,
              title: _part(title, i, n),
              tableRows: rows.sublist(
                i * _maxTableRows,
                ((i + 1) * _maxTableRows).clamp(0, rows.length),
              ),
              note: tag,
              source: _sourceLine(refs.line),
            ),
            refs.sources,
            scope: t.id,
          );
        }
      }
      if (bullets.isNotEmpty) {
        _addBullets(
          AutoSlideKind.reference,
          scope: t.id,
          title: title,
          eyebrow: topicTitle,
          note: tag,
          pieces: [for (final s in bullets) _Piece(s, const [])],
          calc: refs,
        );
      }
    }
  }

  // ------------------------------------------------------------------ atlas

  void _atlasFigures(List<String> sectionIds) {
    final a = atlas;
    if (a == null) return;
    var total = 0;
    for (final sid in sectionIds) {
      final section = a.section(sid);
      if (section == null) continue;
      final sectionName = _say(section.name);
      if (sectionName == null) continue;
      var perSection = 0;
      for (final g in a.groupsIn(sid)) {
        for (final e in a.entitiesIn(g.id)) {
          if (perSection >= _atlasPerSection || total >= _atlasTotal) break;
          // Izohi slaydga sig'adigan (qisqa) rasm; uzun izohli tashlanadi.
          final img = a
              .imagesOf(e.id)
              .where(
                (i) =>
                    i.labelNote == null &&
                    (i.caption.translation.values[lang]?.length ?? 0) <=
                        _maxCaption,
              )
              .firstOrNull;
          if (img == null) continue;
          final entityName = _say(e.name);
          final caption = _say(img.caption.translation);
          if (entityName == null || caption == null) continue;
          final stain = img.stain == null ? null : _say(img.stain!.translation);
          final detail = [
            caption,
            ?stain,
            if (img.magnification != null) img.magnification!,
          ].join(' · ');
          final label =
              '${img.credit} · ${img.author} · ${img.license} · '
              '${img.provider == MicroProvider.commons ? 'Wikimedia Commons' : 'CDC PHIL'}';
          _add(
            AutoSlideKind.atlas,
            LectureSlide(
              template: SlideTemplate.figure,
              eyebrow: sectionName,
              title: entityName,
              figure: img.asset,
              figureCaption: detail,
              source: _sourceLine(label),
            ),
            [AutoSource(id: img.id, label: label, url: img.sourcePage)],
            scope: img.id,
          );
          perSection++;
          total++;
        }
      }
    }
  }

  // --------------------------------------------------------- umumiy preanalitika

  void _generalPreanalytics() {
    final order = _calcRefs(const [
      CalcRef(CalcSources.whoPhlebotomy2010, 'Table 2.3 (p. 15)'),
    ]);
    final rows = <List<String>>[];
    final swatches = <List<Color>>[];
    for (final (i, t) in drawOrder.indexed) {
      final name = _say(t.name);
      final cap = _say(t.cap);
      if (name == null || cap == null) continue;
      rows.add(['${i + 1}. $name', cap]);
      swatches.add(t.colors);
    }
    final note = _say(drawOrderNotes.first);
    final n = (rows.length / _maxTableRows).ceil();
    for (var i = 0; i < n; i++) {
      final from = i * _maxTableRows;
      final to = (from + _maxTableRows).clamp(0, rows.length);
      _add(
        AutoSlideKind.general,
        LectureSlide(
          template: SlideTemplate.table,
          eyebrow: l.sectionPreanalytics,
          title: _part(l.preOrderTitle, i, n),
          tableHeader: [l.autoPresColTube, l.autoPresColCap],
          tableRows: rows.sublist(from, to),
          rowSwatches: swatches.sublist(from, to),
          note: note,
          source: _sourceLine(order.line),
        ),
        order.sources,
        scope: 'pre-order',
      );
    }
    void bullets(String title, List<LocalizedText> items, String locator) {
      final refs = _calcRefs([CalcRef(CalcSources.whoPhlebotomy2010, locator)]);
      final texts = <String>[];
      for (final x in items) {
        final s = _say(x);
        if (s != null) texts.add(s);
      }
      if (texts.isEmpty) return;
      _addBullets(
        AutoSlideKind.general,
        scope: 'pre-$locator',
        title: title,
        eyebrow: l.sectionPreanalytics,
        pieces: [for (final s in texts) _Piece(s, const [])],
        calc: refs,
      );
    }

    bullets(l.preHaemolysisTitle, haemolysisCauses, '1.1.1');
    bullets(l.preTourniquetTitle, tourniquetRules, '2.2.3 (Steps 3, 6)');
  }

  // ------------------------------------------------------------------ savollar

  void _quiz(List<Analyte> analytes, CurriculumTopic? topic) {
    final picked = <QuizQuestion>[];
    void take(QuizQuestion q) {
      if (picked.length < autoQuizTotal && !picked.contains(q)) picked.add(q);
    }

    for (final a in analytes) {
      var n = 0;
      for (final q in pack.quiz) {
        if (n >= autoQuizPerAnalyte) break;
        if (q.topicIds.contains(a.id) && _quizUsable(q)) {
          take(q);
          n++;
        }
      }
    }
    if (topic != null) {
      for (final id in topic.packQuizCandidates) {
        final q = pack.quiz.where((x) => x.id == id).firstOrNull;
        if (q != null && _quizUsable(q)) take(q);
      }
    }
    for (final (i, q) in picked.indexed) {
      final prompt = _say(q.prompt);
      final options = <String>[];
      for (final o in q.options) {
        final s = _say(o.text);
        if (s != null) options.add(s);
      }
      final explanation = _say(q.options[q.correctIndex].explanation);
      final refs = _refs(q.refs);
      if (prompt == null ||
          refs == null ||
          explanation == null ||
          options.length != q.options.length) {
        continue;
      }
      _add(
        AutoSlideKind.quiz,
        LectureSlide(
          template: SlideTemplate.qa,
          question: true,
          eyebrow: l.lectureQuestionN(i + 1),
          title: prompt,
          options: options,
          correctIndex: q.correctIndex,
          answerExplanation: explanation,
          source: _sourceLine(refs.line),
        ),
        refs.sources,
        scope: q.id,
      );
    }
  }

  /// Savol taqdimotga faqat manbasi bo'lsa chiqadi.
  bool _quizUsable(QuizQuestion q) => q.refs.isNotEmpty && _refsResolve(q.refs);

  bool _refsResolve(List<SourceRef> refs) =>
      refs.every((r) => pack.source(r.sourceId) != null);
}

/// Foydalanuvchi qoldirgan slaydlardan yakuniy deck: tarkibiy slaydlar +
/// OXIRIDAGI manbalar slaydlari (qolgan slaydlar manbalaridan avtomatik).
List<LectureSlide> assembleAutoDeck(
  AppLocalizations l,
  AutoDeck deck,
  List<AutoSlide> kept,
) {
  final out = [for (final s in kept) s.slide];
  if (kept.isEmpty) return out;
  final sources = <AutoSource>[];
  for (final s in kept) {
    for (final x in s.sources) {
      if (x.id == 'labguide-pack') continue;
      if (!sources.any((y) => y.id == x.id)) sources.add(x);
    }
  }
  if (sources.isEmpty) return out;
  final n = (sources.length / _maxSourcesPerSlide).ceil();
  for (var i = 0; i < n; i++) {
    final chunk = sources.sublist(
      i * _maxSourcesPerSlide,
      ((i + 1) * _maxSourcesPerSlide).clamp(0, sources.length),
    );
    out.add(
      LectureSlide(
        title: n <= 1 ? l.analyteSources : '${l.analyteSources} (${i + 1}/$n)',
        bullets: [for (final s in chunk) _sourceBullet(l, s)],
        compact: true,
        source: l.autoPresSourceLine(l.autoPresPackSource(deck.packVersion)),
      ),
    );
  }
  return out;
}

String _sourceBullet(AppLocalizations l, AutoSource s) {
  final where = [
    if (s.url != null) s.url!.replaceFirst(RegExp('^https?://'), ''),
    if (s.accessed != null) l.analyteSourceAccessed(s.accessed!),
  ].join('; ');
  return where.isEmpty ? s.label : '${s.label} ($where)';
}
