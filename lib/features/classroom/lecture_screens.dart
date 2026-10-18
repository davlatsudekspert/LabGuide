import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../differential/diff_eyes_free.dart' show DiffDevice;
import 'classroom_screens.dart';
import 'curriculum.dart';
import 'lecture_catalog.dart';
import 'lecture_decks.dart';
import 'lecture_library.dart';
import 'lecture_slide.dart';
import 'lecture_canvas.dart';
import 'lecture_present.dart';
import 'topic_questions.dart';
import 'topic_test.dart' show DeckTestState;
import 'topic_test_screens.dart';

// Ma'ruza (taqdimot) rejimi: ustoz mavzuni katta ekranda ko'rsatadi.
// Serversiz ishlaydi — slaydlar o'quv dasturi va ilova kontentidan
// yig'iladi; ekran o'chmaydi (wakelock), katta shrift, oldinga/orqaga
// (tugma, surish, klaviatura ← →).

export 'lecture_slide.dart' show LectureSlide, SlideTemplate;

String _lang(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

/// Slaydlar: mavzu → maqsad → asosiy tushunchalar → bog'langan kartalar,
/// jadvallar, atlas, kalkulyatorlar → savollar → yakun.
List<LectureSlide> buildLectureSlides(
  BuildContext context,
  Curriculum cur,
  CurriculumTopic t,
) {
  final l = AppLocalizations.of(context);
  final lang = _lang(context);
  final module = cur.moduleOf(t);
  final materials = topicMaterialItems(context, t);
  List<String> kind(String k) => [
    for (final m in materials)
      if (m.kind == k)
        m.summary == null || m.summary!.isEmpty
            ? m.title
            : '${m.title} — ${m.summary}',
  ];
  final slides = <LectureSlide>[
    LectureSlide(
      eyebrow: module?.title.of(lang),
      title: t.title.of(lang),
      bullets: [topicMeta(context, t)],
      note: t.links.gap ? l.classroomGapNote : null,
    ),
    if (t.goals.isNotEmpty)
      LectureSlide(
        eyebrow: l.lectureGoals,
        title: l.lectureGoals,
        bullets: t.goals,
      ),
    if (t.keyPoints.isNotEmpty)
      LectureSlide(
        eyebrow: l.lectureKeyPoints,
        title: l.lectureKeyPoints,
        bullets: t.keyPoints,
      ),
  ];
  void section(String k, String title) {
    final items = kind(k);
    // Bitta slaydda ko'pi bilan 5 band — katta shriftda sig'sin.
    for (var i = 0; i < items.length; i += 5) {
      slides.add(
        LectureSlide(
          eyebrow: title,
          title: title,
          bullets: items.sublist(
            i,
            i + 5 > items.length ? items.length : i + 5,
          ),
        ),
      );
    }
  }

  section(l.classroomKindAnalyte, l.lectureConcepts);
  section(l.classroomKindCondition, l.lectureConditions);
  section(l.classroomKindReference, l.lectureTables);
  section(l.classroomKindAtlas, l.lectureAtlas);
  section(l.classroomKindTool, l.lectureTools);
  final oral = oralCandidates(t, context.services.toifa.bank);
  for (final (i, q) in oral.take(3).indexed) {
    slides.add(
      LectureSlide(
        eyebrow: l.lectureQuestionN(i + 1),
        title: q.localized(lang).text,
        question: true,
      ),
    );
  }
  slides.add(
    LectureSlide(
      eyebrow: l.lectureEndEyebrow,
      title: l.lectureEndTitle,
      bullets: [l.lectureEndOral, l.lectureEndTest],
    ),
  );
  return slides;
}

/// Tayyor taqdimot slaydlari. Birinchi slaydda: "darsdan oldin ko'rib
/// chiqing" eslatmasi va (til yo'q bo'lsa) "boshqa tilda ko'rsatilmoqda". [wanted] —
/// so'ralgan til (standart: ilova tili).
List<LectureSlide> deckLectureSlides(
  BuildContext context,
  LectureDeck deck, {
  String? wanted,
}) {
  final l = AppLocalizations.of(context);
  final want = wanted ?? _lang(context);
  // Rasmli slaydlarda eslatma slaydning o'zida bor.
  final pictures = deck.slides.every((d) => d.image != null);
  final notice = [
    if (deck.draft && !pictures) l.lectureDraftNotice,
    if (deck.lang != want)
      deck.lang == 'uz'
          ? l.lectureUzOnly
          : l.lectureLangFallback(
              kDeckLangNames[want] ?? want,
              kDeckLangNames[deck.lang] ?? deck.lang,
            ),
  ].join('\n');
  final bib = deck.bibliography;
  return [
    for (final (i, d) in deck.slides.indexed)
      LectureSlide(
        eyebrow: d.eyebrow,
        title: d.title,
        bullets: d.bullets,
        note: d.footnote,
        notice: i == 0 && notice.isNotEmpty ? notice : null,
        teacherNote: d.note,
        source: d.source,
        refs: [
          for (final r in d.refs)
            if (r.index < bib.length)
              SlideRef(
                number: r.index + 1,
                text: bib[r.index],
                locators: r.locators,
              ),
        ],
        section: d.section,
        image: d.image,
        template: switch (d.template) {
          'title' => SlideTemplate.title,
          'table' => SlideTemplate.table,
          'figure' => SlideTemplate.figure,
          'qa' => SlideTemplate.qa,
          'stats' when d.stats.isNotEmpty => SlideTemplate.stats,
          'range' when d.range != null => SlideTemplate.range,
          'steps' => SlideTemplate.steps,
          'split' when d.cols.length == 2 => SlideTemplate.split,
          'tree' => SlideTemplate.tree,
          'example' when d.example != null => SlideTemplate.example,
          _ => SlideTemplate.bullets,
        },
        stats: [
          for (final st in d.stats)
            if (st.length >= 2) SlideStat(st[0], st[1]),
        ],
        range: _range(d.range),
        columns: [for (final (h, k, items) in d.cols) SlideColumn(h, k, items)],
        example: d.example,
        category: d.category,
        question: d.template == 'qa',
        tableHeader: d.header,
        tableRows: d.rows,
        figure: d.figure,
        figureCaption: d.caption,
        figureCredit: d.credit,
        options: d.options,
        correctIndex: d.correct,
        answerExplanation: d.explanation,
        compact: d.compact,
        plan: d.plan,
      ),
  ];
}

/// Deck JSON `range` -> [SlideRange] (noto'g'ri tuzilma — null, oddiy jadval
/// slaydi ko'rinadi).
SlideRange? _range(Map<String, Object?>? j) {
  if (j == null) return null;
  final rows = <SlideRangeRow>[];
  for (final r in (j['rows'] as List?) ?? const []) {
    if (r is! List || r.length < 7) continue;
    final flags = (r[4] as num?)?.toInt() ?? 0;
    rows.add(
      SlideRangeRow(
        label: r[0] as String? ?? '',
        sub: r[1] as String?,
        low: (r[2] as num?)?.toDouble(),
        high: (r[3] as num?)?.toDouble(),
        lowExclusive: flags & 1 != 0,
        highExclusive: flags & 2 != 0,
        lowText: r[5] as String?,
        highText: r[6] as String?,
      ),
    );
  }
  if (rows.isEmpty) return null;
  return SlideRange(
    unit: j['u'] as String? ?? '',
    caption: j['cap'] as String?,
    rows: rows,
  );
}

/// Ma'ruza bo'limi: BARCHA tayyor taqdimotlar (qidiruv va filtr bilan),
/// avtomatik taqdimot kirishi va o'quv dasturi mavzulari (serversiz).
class LectureListScreen extends StatelessWidget {
  const LectureListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bundle = context.services.curriculum.bundle ?? rootBundle;
    final decks = LectureDecks.all(bundle);
    return LgPage(
      title: l.lectureListTitle,
      subtitle: l.lectureListSub,
      showProfile: false,
      children: [
        LectureLibrary(
          bundle: bundle,
          // Avtomatik taqdimot: mavzu yoki tahlillardan yig'iladi.
          autoEntry: LgRow(
            key: const ValueKey('lecture-auto-entry'),
            title: l.autoPresTitle,
            subtitle: l.autoPresEntrySub,
            icon: Icons.auto_awesome_motion_outlined,
            onTap: () => context.push('/learn/lecture/auto'),
          ),
          topicsSection: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LgSectionTitle(l.lectureTopicsAutoTitle),
              Text(
                l.lectureTopicsAutoSub,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              CurriculumGate(
                builder: (context, cur) => FutureBuilder(
                  future: decks,
                  initialData: LectureDecks.peek(bundle),
                  builder: (context, snap) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final m in cur.modules) ...[
                        LgSectionTitle(m.title.of(_lang(context))),
                        for (final (i, t) in m.topics.indexed)
                          LgRow(
                            title: t.title.of(_lang(context)),
                            subtitle: [
                              topicMeta(context, t),
                              if (snap.data?[t.id] case final d?)
                                l.lectureDeckReady(d.slides.length),
                            ].join('\n'),
                            icon: snap.data?[t.id] != null
                                ? Icons.co_present_outlined
                                : Icons.slideshow_outlined,
                            divider: i < m.topics.length - 1,
                            onTap: () => context.push('/learn/lecture/${t.id}'),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LectureScreen extends StatefulWidget {
  const LectureScreen({
    super.key,
    required this.topicId,
    this.generated,
    this.deckId,
    this.deckLang,
    this.startSlide = 0,
  });

  final String topicId;

  /// Avtomatik taqdimot: tayyor slaydlar (o'quv dasturi va tayyor decklar
  /// yuklanmaydi). Berilsa [topicId] e'tiborsiz.
  final List<LectureSlide>? generated;

  /// Katalogdagi deck (index_v2.json); berilsa [topicId] e'tiborsiz. Til —
  /// [deckLang] yoki ilova tili; deckda bu til bo'lmasa — ko'rinadigan
  /// ogohlantirish bilan o'zbekcha.
  final String? deckId;
  final String? deckLang;

  /// Boshlang'ich slayd (qidiruvda mos slayd sarlavhasi bosilganda).
  final int startSlide;

  @override
  State<LectureScreen> createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  int _index = 0;
  bool _notes = false;

  /// Javobi ochilgan savol slaydlari (indeks bo'yicha).
  final _answers = <int>{};
  bool _deckLoaded = false;
  LectureDeck? _authored;
  final _focus = FocusNode(debugLabel: 'lecture');

  // Taqdimot ko'rinishi (to'liq ekran / taqdimotchi) va tizim holati.
  _View _view = _View.normal;
  bool _immersive = false;
  bool _chrome = true;
  Timer? _chromeTimer;

  // Katalog decki (deckId bilan ochilganda).
  bool _catalogStarted = false;
  bool _catalogFailed = false;
  LectureDeck? _catalogDeck;
  String _wantedLang = 'uz';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.deckId != null && !_catalogStarted) {
      _catalogStarted = true;
      _startCatalogDeck();
    }
  }

  void _startCatalogDeck() {
    final bundle = context.services.curriculum.bundle ?? rootBundle;
    final wanted = widget.deckLang ?? _lang(context);
    _wantedLang = wanted;
    void done(LectureDeck? d) {
      if (!mounted) return;
      setState(() {
        _catalogDeck = d;
        _catalogFailed = d == null;
        _deckLoaded = true;
      });
    }

    final catalog = DeckCatalog.peek(bundle);
    final entry = catalog?.byId(widget.deckId!);
    if (catalog != null && entry == null) {
      // Katalog yuklangan, lekin bunday deck yo'q — darhol halol xato.
      _catalogFailed = true;
      _deckLoaded = true;
      return;
    }
    final ready = entry == null
        ? null
        : DeckCatalog.peekDeck(bundle, entry, entry.resolveLang(wanted));
    if (ready != null) {
      _catalogDeck = ready;
      _deckLoaded = true;
      return;
    }
    unawaited(() async {
      try {
        final c = await DeckCatalog.load(bundle);
        final e = c.byId(widget.deckId!);
        if (e == null) return done(null);
        done(await DeckCatalog.loadDeck(bundle, e, e.resolveLang(wanted)));
      } on Object {
        done(null);
      }
    }());
  }

  /// Mavzu testi qaysi deck bo'yicha: katalog decki yoki mavzuning decki
  /// (avtomatik taqdimotda — yo'q).
  DeckEntry? _testDeck() {
    if (widget.generated != null) return null;
    final c = DeckCatalog.peek(
      context.services.curriculum.bundle ?? rootBundle,
    );
    if (widget.deckId != null) return c?.byId(widget.deckId!);
    return widget.topicId.isEmpty ? null : c?.byTopic(widget.topicId);
  }

  @override
  void initState() {
    super.initState();
    unawaited(DiffDevice.screenAwake.set(on: true));
    // Mavzu testi tugmasi uchun katalog (ro'yxat ochilmagan bo'lsa).
    final bundle = context.services.curriculum.bundle ?? rootBundle;
    if (widget.generated == null && DeckCatalog.peek(bundle) == null) {
      unawaited(
        DeckCatalog.load(bundle).then<void>((_) {
          if (mounted) setState(() {});
        }, onError: (Object _) {}),
      );
    }
    if (widget.deckId != null) {
      _index = widget.startSlide;
      return;
    }
    if (widget.generated != null) {
      _deckLoaded = true;
      return;
    }
    final s = context.services;
    unawaited(s.curriculum.ensureLoaded());
    unawaited(s.toifa.ensureLoaded());
    unawaited(s.microscopy.ensureAtlas());
    final ready = LectureDecks.peek(bundle);
    if (ready != null) {
      _authored = ready[widget.topicId];
      _deckLoaded = true;
    } else {
      unawaited(
        LectureDecks.forTopic(
          bundle,
          widget.topicId,
        ).then<LectureDeck?>((d) => d, onError: (Object _) => null).then((d) {
          if (mounted) {
            setState(() {
              _authored = d;
              _deckLoaded = true;
            });
          }
        }),
      );
    }
  }

  @override
  void dispose() {
    unawaited(DiffDevice.screenAwake.set(on: false));
    _chromeTimer?.cancel();
    // Ekran holati va tizim panellari har doim qaytariladi (orqaga, yopish).
    if (_immersive) unawaited(LecturePresentation.exit());
    _focus.dispose();
    super.dispose();
  }

  void _go(int delta, int count) {
    final next = (_index + delta).clamp(0, count - 1);
    if (next != _index) setState(() => _index = next);
  }

  void _toggleAnswer(int i) => setState(
    () => _answers.contains(i) ? _answers.remove(i) : _answers.add(i),
  );

  void _swipe(DragEndDetails d, int count) {
    final v = d.primaryVelocity ?? 0;
    if (v < -200) _go(1, count);
    if (v > 200) _go(-1, count);
  }

  /// Taqdimot (to'liq ekran) yoki taqdimotchi ko'rinishini boshlash. Tik
  /// ekranda ekran holati so'raladi (yoki eslab qolingan tanlov).
  Future<void> _present({_View view = _View.present, bool cast = false}) async {
    final store = context.services.store;
    final size = MediaQuery.sizeOf(context);
    var landscape = false;
    if (size.height > size.width) {
      switch (LecturePresentation.read(store)) {
        case LectureOrientation.landscape:
          landscape = true;
        case LectureOrientation.keep:
          landscape = false;
        case LectureOrientation.ask:
          final r = await askLandscape(context, cast: cast);
          if (r == null || !mounted) return;
          landscape = r.landscape;
          if (r.remember) {
            await LecturePresentation.write(
              store,
              r.landscape
                  ? LectureOrientation.landscape
                  : LectureOrientation.keep,
            );
          }
      }
    }
    if (!mounted) return;
    _immersive = true;
    setState(() => _view = view);
    _showChrome();
    _focus.requestFocus();
    await LecturePresentation.enter(landscape: landscape);
  }

  Future<void> _leave() async {
    if (_view == _View.normal) return;
    _chromeTimer?.cancel();
    setState(() => _view = _View.normal);
    if (_immersive) {
      _immersive = false;
      await LecturePresentation.exit();
    }
  }

  /// To'liq ekrandagi kichik tugmalar: bosilganda ko'rinadi, 3 soniyadan
  /// keyin yashirinadi (televizorga uzatilganda ekranda faqat slayd).
  void _showChrome() {
    _chromeTimer?.cancel();
    if (!_chrome) setState(() => _chrome = true);
    _chromeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _chrome = false);
    });
  }

  void _cast() =>
      unawaited(showCastSheet(context, () => unawaited(_present(cast: true))));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = context.services;
    if (widget.deckId != null) {
      if (!_deckLoaded) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final deck = _catalogDeck;
      if (_catalogFailed || deck == null || deck.slides.isEmpty) {
        return LgPage(
          title: l.lectureTitle,
          showProfile: false,
          children: [
            LgStateView(kind: StateKind.error, title: l.lectureDeckLoadFailed),
          ],
        );
      }
      final slides = deckLectureSlides(context, deck, wanted: _wantedLang);
      return _deck(
        context,
        slides,
        _index.clamp(0, slides.length - 1),
        deck.title ?? slides.first.title,
      );
    }
    if (widget.generated case final slides? when slides.isNotEmpty) {
      return _deck(
        context,
        slides,
        _index.clamp(0, slides.length - 1),
        slides.first.title,
      );
    }
    return ListenableBuilder(
      listenable: Listenable.merge([
        s.curriculum,
        s.toifa,
        s.content,
        s.microscopy,
      ]),
      builder: (context, _) {
        final cur = s.curriculum.curriculum;
        final t = cur?.topic(widget.topicId);
        if (cur == null || t == null) {
          return LgPage(
            title: l.lectureTitle,
            showProfile: false,
            children: [
              CurriculumGate(
                builder: (context, _) => LgStateView(
                  kind: StateKind.empty,
                  title: l.classroomTopicMissing,
                ),
              ),
            ],
          );
        }
        if (!_deckLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final slides = _authored != null
            ? deckLectureSlides(context, _authored!)
            : buildLectureSlides(context, cur, t);
        final i = _index.clamp(0, slides.length - 1);
        return _deck(
          context,
          slides,
          i,
          _authored?.title ?? t.title.of(_lang(context)),
        );
      },
    );
  }

  KeyEventResult _key(KeyEvent e, List<LectureSlide> slides, int i) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowRight ||
        k == LogicalKeyboardKey.pageDown ||
        k == LogicalKeyboardKey.space) {
      _go(1, slides.length);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowLeft || k == LogicalKeyboardKey.pageUp) {
      _go(-1, slides.length);
      return KeyEventResult.handled;
    }
    // Savol slaydida Enter — javobni ochish/yopish.
    if (k == LogicalKeyboardKey.enter &&
        slides[i].template == SlideTemplate.qa) {
      _toggleAnswer(i);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.escape && _view != _View.normal) {
      unawaited(_leave());
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.keyF && _view == _View.normal) {
      unawaited(_present());
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _deck(
    BuildContext context,
    List<LectureSlide> slides,
    int i,
    String? title,
  ) {
    final size = MediaQuery.sizeOf(context);
    final Widget body = switch (_view) {
      _View.present => _presentation(context, slides, i, title),
      _View.presenter => PresenterView(
        slides: slides,
        index: i,
        deckTitle: title,
        answerShown: _answers.contains(i),
        onGo: (d) => _go(d, slides.length),
        onExit: () => unawaited(_leave()),
        onToggleAnswer: () => _toggleAnswer(i),
      ),
      _View.normal when size.width >= _wideWidth => _wide(
        context,
        slides,
        i,
        title,
      ),
      _View.normal when size.width > size.height => _stage(
        context,
        slides,
        i,
        title,
      ),
      _View.normal => _portrait(context, slides, i, title),
    };
    return PopScope(
      canPop: _view == _View.normal,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave());
      },
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: (node, e) => _key(e, slides, i),
        child: body,
      ),
    );
  }

  /// Planshet/keng ekran: slayd katta, yonida ma'lumot paneli.
  static const _wideWidth = 900.0;

  DeckEntry? _endDeck(List<LectureSlide> slides, int i) =>
      i == slides.length - 1 && widget.deckId != null ? _testDeck() : null;

  /// Slayd kartasi: 16:9, yumaloq, soyali; surish — oldinga/orqaga.
  Widget _card(
    BuildContext context,
    List<LectureSlide> slides,
    int i,
    String? title,
  ) {
    final p = LgPalette.of(context);
    return GestureDetector(
      key: const ValueKey('lecture-slide-card'),
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (d) => _swipe(d, slides.length),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: p.shadow.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Karta foni sahifa foni bilan bir xil — yuqori va chap qirrasi
        // "kesilgan"dek ko'rinmasin: har ikki mavzuda ingichka chegara.
        position: DecorationPosition.background,
        child: Container(
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? p.line
                  : p.outline.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SlideCanvas(
              key: ValueKey('lecture-canvas-$i'),
              slide: slides[i],
              number: i + 1,
              total: slides.length,
              deckTitle: title,
              answerShown: _answers.contains(i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, List<LectureSlide> slides, int i) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final testDeck = _testDeck();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: l.lectureClose,
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
          if (testDeck != null) DeckTestMenu(deck: testDeck),
          if (slides[i].teacherNote != null) _notesButton(context),
          _moreMenu(context),
          const SizedBox(width: 4),
          Semantics(
            liveRegion: true,
            child: Text(
              l.lectureCounter(i + 1, slides.length),
              style: text.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesButton(BuildContext context, {bool tonal = false}) {
    final l = AppLocalizations.of(context);
    final tip = _notes ? l.lectureNotesHide : l.lectureNotesShow;
    final icon = Icon(
      _notes ? Icons.speaker_notes_rounded : Icons.speaker_notes_outlined,
    );
    void tap() => setState(() => _notes = !_notes);
    return tonal
        ? IconButton.filledTonal(
            key: const ValueKey('lecture-notes'),
            tooltip: tip,
            onPressed: tap,
            icon: icon,
          )
        : IconButton(
            key: const ValueKey('lecture-notes'),
            tooltip: tip,
            isSelected: _notes,
            onPressed: tap,
            icon: icon,
          );
  }

  /// Menyu: ekranga uzatish, taqdimotchi rejimi, ekran holati tanlovi.
  Widget _moreMenu(BuildContext context, {bool tonal = false}) {
    final l = AppLocalizations.of(context);
    final store = context.services.store;
    final current = LecturePresentation.read(store);
    return PopupMenuButton<Object>(
      key: const ValueKey('lecture-more'),
      tooltip: l.lectureMore,
      icon: const Icon(Icons.tune_rounded),
      style: tonal ? IconButton.styleFrom() : null,
      onSelected: (v) {
        if (v == 'cast') _cast();
        if (v == 'presenter') unawaited(_present(view: _View.presenter));
        if (v is LectureOrientation) {
          unawaited(
            LecturePresentation.write(
              store,
              v,
            ).then((_) => mounted ? setState(() {}) : null),
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          key: const ValueKey('lecture-menu-cast'),
          value: 'cast',
          child: ListTile(
            leading: const Icon(Icons.cast_rounded),
            title: Text(l.lectureCast),
          ),
        ),
        PopupMenuItem(
          key: const ValueKey('lecture-menu-presenter'),
          value: 'presenter',
          child: ListTile(
            leading: const Icon(Icons.co_present_outlined),
            title: Text(l.lecturePresenter),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: false,
          child: Text(
            l.lectureOrientationMenu,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        for (final (o, label) in [
          (LectureOrientation.ask, l.lectureOrientationAsk),
          (LectureOrientation.landscape, l.lectureOrientationLandscape),
          (LectureOrientation.keep, l.lectureOrientationKeep),
        ])
          CheckedPopupMenuItem<Object>(
            key: ValueKey('lecture-orient-${o.name}'),
            value: o,
            checked: current == o,
            child: Text(label),
          ),
      ],
    );
  }

  /// Slayd ostidagi panel: amallar, manba, ogohlantirish, ustoz izohi.
  List<Widget> _info(BuildContext context, List<LectureSlide> slides, int i) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final slide = slides[i];
    final endDeck = _endDeck(slides, i);
    final shown = _answers.contains(i);
    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.tonalIcon(
            key: const ValueKey('lecture-fullscreen'),
            onPressed: () => unawaited(_present()),
            icon: const Icon(Icons.fullscreen_rounded),
            label: Text(l.lectureFullscreen),
          ),
          OutlinedButton.icon(
            key: const ValueKey('lecture-cast'),
            onPressed: _cast,
            icon: const Icon(Icons.cast_rounded),
            label: Text(l.lectureCast),
          ),
          if (slide.template == SlideTemplate.qa)
            OutlinedButton.icon(
              key: const ValueKey('lecture-answer'),
              onPressed: () => _toggleAnswer(i),
              icon: Icon(
                shown
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              label: Text(shown ? l.autoPresHideAnswer : l.autoPresShowAnswer),
            ),
        ],
      ),
      if (slide.source != null || slide.refs.isNotEmpty) ...[
        const SizedBox(height: 12),
        SlideSourceTile(slide: slide),
      ],
      if (slide.notice != null) ...[
        const SizedBox(height: 12),
        LgNotice(slide.notice!, kind: NoticeKind.info),
      ],
      if (_notes && slide.teacherNote != null) ...[
        const SizedBox(height: 12),
        Container(
          key: const ValueKey('lecture-teacher-note'),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.soft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.lectureTeacherNote,
                style: text.labelLarge!.copyWith(color: p.brand),
              ),
              const SizedBox(height: 6),
              Text(
                slide.teacherNote!,
                style: text.bodyMedium!.copyWith(height: 1.4, color: p.ink),
              ),
            ],
          ),
        ),
      ],
      // Savollar yetmasa — oxirgi slaydda halol izoh.
      if (endDeck != null)
        DeckTestBuilder(
          deck: endDeck,
          builder: (context, state, _) => state == DeckTestState.preparing
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    l.topicTestPreparing,
                    key: const ValueKey('lecture-test-preparing'),
                    textAlign: TextAlign.center,
                    style: text.bodySmall,
                  ),
                )
              : const SizedBox.shrink(),
        ),
    ];
  }

  Widget _navRow(BuildContext context, List<LectureSlide> slides, int i) {
    final l = AppLocalizations.of(context);
    final last = i == slides.length - 1;
    final endDeck = _endDeck(slides, i);
    return Row(
      children: [
        Expanded(
          child: LgButton.secondary(
            label: l.lecturePrev,
            icon: Icons.chevron_left_rounded,
            onPressed: i == 0 ? null : () => _go(-1, slides.length),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: endDeck != null
              ? DeckTestBuilder(
                  deck: endDeck,
                  builder: (context, state, _) => state == DeckTestState.ready
                      ? DeckTestEndButton(deck: endDeck)
                      : LgButton(
                          label: l.lectureNext,
                          icon: Icons.chevron_right_rounded,
                          onPressed: null,
                        ),
                )
              : LgButton(
                  label: l.lectureNext,
                  icon: Icons.chevron_right_rounded,
                  onPressed: last ? null : () => _go(1, slides.length),
                ),
        ),
      ],
    );
  }

  /// Telefon (tik): 16:9 slayd kartasi tepada, ostida panel.
  Widget _portrait(
    BuildContext context,
    List<LectureSlide> slides,
    int i,
    String? title,
  ) {
    final p = LgPalette.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context, slides, i),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _card(context, slides, i, title),
                    const SizedBox(height: 16),
                    ..._info(context, slides, i),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _navRow(context, slides, i),
            ),
          ],
        ),
      ),
    );
  }

  /// Planshet / keng ekran (≥ 900 px): slayd katta, yonida panel —
  /// aylantirish shart emas.
  Widget _wide(
    BuildContext context,
    List<LectureSlide> slides,
    int i,
    String? title,
  ) {
    final p = LgPalette.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context, slides, i),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 16, 24),
                      child: Center(child: _card(context, slides, i, title)),
                    ),
                  ),
                  SizedBox(
                    width: 360,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 20, 16),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: _info(context, slides, i),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _navRow(context, slides, i),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Yotiq telefon (to'liq ekransiz): slayd butun balandlikda, boshqaruv
  /// kichik va chetlarda; slayd chetini bosish — oldinga/orqaga.
  Widget _stage(
    BuildContext context,
    List<LectureSlide> slides,
    int i,
    String? title,
  ) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final slide = slides[i];
    final testDeck = _testDeck();
    final last = i == slides.length - 1;
    final endDeck = _endDeck(slides, i);
    Widget round(IconData icon, String tip, VoidCallback? onTap, {Key? key}) =>
        IconButton.filledTonal(
          key: key,
          tooltip: tip,
          onPressed: onTap,
          icon: Icon(icon),
        );
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: (d) => _swipe(d, slides.length),
                onTapUp: (d) {
                  final w = MediaQuery.sizeOf(context).width;
                  if (d.localPosition.dx > w * 0.65) _go(1, slides.length);
                  if (d.localPosition.dx < w * 0.35) _go(-1, slides.length);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: Center(
                    child: SlideCanvas(
                      key: ValueKey('lecture-canvas-$i'),
                      slide: slide,
                      number: i + 1,
                      total: slides.length,
                      deckTitle: title,
                      answerShown: _answers.contains(i),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: round(
                Icons.close_rounded,
                l.lectureClose,
                () => context.pop(),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Row(
                children: [
                  if (testDeck != null) DeckTestMenu(deck: testDeck),
                  if (slide.teacherNote != null)
                    _notesButton(context, tonal: true),
                  round(
                    Icons.fullscreen_rounded,
                    l.lectureFullscreen,
                    () => unawaited(_present()),
                    key: const ValueKey('lecture-fullscreen'),
                  ),
                  _moreMenu(context),
                  const SizedBox(width: 4),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      l.lectureCounter(i + 1, slides.length),
                      style: text.labelLarge,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 4,
              bottom: 4,
              child: round(
                Icons.chevron_left_rounded,
                l.lecturePrev,
                i == 0 ? null : () => _go(-1, slides.length),
              ),
            ),
            if (slide.template == SlideTemplate.qa)
              Positioned(
                left: 4,
                top: 56,
                child: round(
                  _answers.contains(i)
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  _answers.contains(i)
                      ? l.autoPresHideAnswer
                      : l.autoPresShowAnswer,
                  () => _toggleAnswer(i),
                  key: const ValueKey('lecture-answer'),
                ),
              ),
            if (slide.source != null || slide.refs.isNotEmpty)
              Positioned(
                left: 4,
                bottom: 56,
                child: round(
                  Icons.menu_book_outlined,
                  l.lectureSourcesOpen,
                  () => unawaited(showSlideSources(context, slide)),
                  key: const ValueKey('lecture-source'),
                ),
              ),
            Positioned(
              right: 4,
              bottom: 4,
              child: endDeck != null
                  ? DeckTestBuilder(
                      deck: endDeck,
                      builder: (context, state, _) =>
                          state == DeckTestState.ready
                          ? round(
                              Icons.quiz_outlined,
                              l.topicTestAction,
                              () => openTopicTest(context, endDeck.id),
                              key: const ValueKey('lecture-topic-test'),
                            )
                          : round(
                              Icons.chevron_right_rounded,
                              l.lectureNext,
                              null,
                            ),
                    )
                  : round(
                      Icons.chevron_right_rounded,
                      l.lectureNext,
                      last ? null : () => _go(1, slides.length),
                    ),
            ),
            if (_notes && slide.teacherNote != null)
              Positioned(
                left: 64,
                right: 64,
                bottom: 8,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                  ),
                  child: Material(
                    color: p.soft,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.lectureTeacherNote,
                            style: text.labelLarge!.copyWith(color: p.brand),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide.teacherNote!,
                            key: const ValueKey('lecture-teacher-note'),
                            style: text.bodyMedium!.copyWith(color: p.ink),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (slide.notice != null)
              Positioned(
                left: 64,
                right: 64,
                top: 8,
                child: LgNotice(slide.notice!, kind: NoticeKind.info),
              ),
          ],
        ),
      ),
    );
  }

  /// Taqdimot (to'liq ekran): faqat 16:9 slayd — televizorga uzatishga
  /// (ekran takrorlash) mos. Chap/o'ng yarmini bosish yoki surish —
  /// orqaga/oldinga; kichik tugmalar 3 soniyadan keyin yashirinadi.
  Widget _presentation(
    BuildContext context,
    List<LectureSlide> slides,
    int i,
    String? title,
  ) {
    final l = AppLocalizations.of(context);
    final slide = slides[i];
    Widget small(IconData icon, String tip, VoidCallback onTap, Key key) =>
        AnimatedOpacity(
          opacity: _chrome ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: IconButton(
            key: key,
            tooltip: tip,
            onPressed: () {
              _showChrome();
              onTap();
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.45),
              foregroundColor: Colors.white,
            ),
            icon: Icon(icon),
          ),
        );
    return Scaffold(
      key: const ValueKey('lecture-presentation'),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (d) => _swipe(d, slides.length),
              onTapUp: (d) {
                final w = MediaQuery.sizeOf(context).width;
                _go(d.localPosition.dx >= w / 2 ? 1 : -1, slides.length);
                _showChrome();
              },
              child: Center(
                child: SlideCanvas(
                  key: ValueKey('lecture-canvas-$i'),
                  slide: slide,
                  number: i + 1,
                  total: slides.length,
                  deckTitle: title,
                  answerShown: _answers.contains(i),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: small(
              Icons.close_fullscreen_rounded,
              l.lectureFullscreenExit,
              () => unawaited(_leave()),
              const ValueKey('lecture-fullscreen-exit'),
            ),
          ),
          if (slide.template == SlideTemplate.qa)
            Positioned(
              right: 8,
              bottom: 8,
              child: small(
                _answers.contains(i)
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                _answers.contains(i)
                    ? l.autoPresHideAnswer
                    : l.autoPresShowAnswer,
                () => _toggleAnswer(i),
                const ValueKey('lecture-answer'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pleyer ko'rinishi.
enum _View { normal, present, presenter }
