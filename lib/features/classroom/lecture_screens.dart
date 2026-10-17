import 'dart:async';
import 'dart:math' as math;

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
import 'lecture_templates.dart';
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

String? _joinNote(List<String?> parts) {
  final s = [
    for (final p in parts)
      if (p != null && p.isNotEmpty) p,
  ].join('\n');
  return s.isEmpty ? null : s;
}

/// Tayyor taqdimot slaydlari. Birinchi slaydda halol holat: qoralama va
/// (til yo'q bo'lsa) "boshqa tilda ko'rsatilmoqda" ogohlantirishi. [wanted] —
/// so'ralgan til (standart: ilova tili).
List<LectureSlide> deckLectureSlides(
  BuildContext context,
  LectureDeck deck, {
  String? wanted,
}) {
  final l = AppLocalizations.of(context);
  final want = wanted ?? _lang(context);
  // Rasmli slaydlarda "qoralama" yozuvi slaydning o'zida bor.
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
  return [
    for (final (i, d) in deck.slides.indexed)
      LectureSlide(
        eyebrow: d.eyebrow,
        title: d.title,
        bullets: d.bullets,
        note: _joinNote([if (i == 0) notice, d.footnote]),
        teacherNote: d.note,
        source: d.source,
        section: d.section,
        image: d.image,
        template: switch (d.template) {
          'title' => SlideTemplate.title,
          'table' => SlideTemplate.table,
          'figure' => SlideTemplate.figure,
          'qa' => SlideTemplate.qa,
          _ => SlideTemplate.bullets,
        },
        question: d.template == 'qa',
        tableHeader: d.header,
        tableRows: d.rows,
        figure: d.figure,
        figureCaption: d.caption,
        options: d.options,
        correctIndex: d.correct,
        answerExplanation: d.explanation,
        compact: d.compact,
      ),
  ];
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
      return _deck(context, slides, _index.clamp(0, slides.length - 1));
    }
    if (widget.generated case final slides? when slides.isNotEmpty) {
      return _deck(context, slides, _index.clamp(0, slides.length - 1));
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
        return _deck(context, slides, i);
      },
    );
  }

  Widget _deck(BuildContext context, List<LectureSlide> slides, int i) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final testDeck = _testDeck();
    final last = i == slides.length - 1;
    // Katalog deckining oxirgi slaydi (manbalardan keyin) — “Mavzu testi”.
    // Mavzu (avtomatik slaydlar) marshrutida — faqat menyuda.
    final endDeck = last && widget.deckId != null ? testDeck : null;
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (node, e) {
        if (e is! KeyDownEvent) return KeyEventResult.ignored;
        if (e.logicalKey == LogicalKeyboardKey.arrowRight ||
            e.logicalKey == LogicalKeyboardKey.pageDown ||
            e.logicalKey == LogicalKeyboardKey.space) {
          _go(1, slides.length);
          return KeyEventResult.handled;
        }
        if (e.logicalKey == LogicalKeyboardKey.arrowLeft ||
            e.logicalKey == LogicalKeyboardKey.pageUp) {
          _go(-1, slides.length);
          return KeyEventResult.handled;
        }
        // Savol slaydida Enter — javobni ochish/yopish.
        if (e.logicalKey == LogicalKeyboardKey.enter &&
            slides[i].template == SlideTemplate.qa) {
          _toggleAnswer(i);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child:
          slides[i].image != null &&
              MediaQuery.sizeOf(context).width >
                  MediaQuery.sizeOf(context).height
          ? _stage(context, slides, i)
          : Scaffold(
              backgroundColor: p.bg,
              body: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: l.lectureClose,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => context.pop(),
                          ),
                          const Spacer(),
                          if (testDeck != null) DeckTestMenu(deck: testDeck),
                          if (slides[i].teacherNote != null)
                            IconButton(
                              key: const ValueKey('lecture-notes'),
                              tooltip: _notes
                                  ? l.lectureNotesHide
                                  : l.lectureNotesShow,
                              isSelected: _notes,
                              icon: const Icon(Icons.speaker_notes_outlined),
                              selectedIcon: const Icon(
                                Icons.speaker_notes_rounded,
                              ),
                              onPressed: () => setState(() => _notes = !_notes),
                            ),
                          const SizedBox(width: 8),
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
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragEnd: (d) {
                          final v = d.primaryVelocity ?? 0;
                          if (v < -200) _go(1, slides.length);
                          if (v > 200) _go(-1, slides.length);
                        },
                        child: LayoutBuilder(
                          builder: (context, box) => _SlideView(
                            key: ValueKey(i),
                            slide: slides[i],
                            width: box.maxWidth,
                            height: box.maxHeight,
                            showNotes: _notes,
                            answerShown: _answers.contains(i),
                            onAnswer: () => _toggleAnswer(i),
                          ),
                        ),
                      ),
                    ),
                    // Savollar yetmasa — oxirgi slaydda halol izoh.
                    if (endDeck != null)
                      DeckTestBuilder(
                        deck: endDeck,
                        builder: (context, state, _) =>
                            state == DeckTestState.preparing
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  6,
                                  16,
                                  0,
                                ),
                                child: Text(
                                  l.topicTestPreparing,
                                  key: const ValueKey('lecture-test-preparing'),
                                  textAlign: TextAlign.center,
                                  style: text.bodySmall,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: LgButton.secondary(
                              label: l.lecturePrev,
                              icon: Icons.chevron_left_rounded,
                              onPressed: i == 0
                                  ? null
                                  : () => _go(-1, slides.length),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: endDeck != null
                                ? DeckTestBuilder(
                                    deck: endDeck,
                                    builder: (context, state, _) =>
                                        state == DeckTestState.ready
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
                                    onPressed: last
                                        ? null
                                        : () => _go(1, slides.length),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Yotiq ekran (TV, proyektor): rasmli slayd butun ekranda, boshqaruv
  /// kichik va chetlarda; slayd chetini bosish — oldinga/orqaga.
  Widget _stage(BuildContext context, List<LectureSlide> slides, int i) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final slide = slides[i];
    final testDeck = _testDeck();
    final last = i == slides.length - 1;
    final endDeck = last && widget.deckId != null ? testDeck : null;
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
                onHorizontalDragEnd: (d) {
                  final v = d.primaryVelocity ?? 0;
                  if (v < -200) _go(1, slides.length);
                  if (v > 200) _go(-1, slides.length);
                },
                onTapUp: (d) {
                  final w = MediaQuery.sizeOf(context).width;
                  if (d.localPosition.dx > w * 0.65) _go(1, slides.length);
                  if (d.localPosition.dx < w * 0.35) _go(-1, slides.length);
                },
                child: SizedBox.expand(
                  child: Semantics(
                    image: true,
                    label: [slide.title, ...slide.bullets].join('. '),
                    child: Image.asset(
                      slide.image!,
                      key: ValueKey(slide.image),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      excludeFromSemantics: true,
                      gaplessPlayback: true,
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
              right: 8,
              child: Row(
                children: [
                  if (testDeck != null) DeckTestMenu(deck: testDeck),
                  if (slide.teacherNote != null)
                    round(
                      _notes
                          ? Icons.speaker_notes_rounded
                          : Icons.speaker_notes_outlined,
                      _notes ? l.lectureNotesHide : l.lectureNotesShow,
                      () => setState(() => _notes = !_notes),
                      key: const ValueKey('lecture-notes'),
                    ),
                  const SizedBox(width: 8),
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
            if (slide.note != null)
              Positioned(
                left: 64,
                right: 64,
                top: 8,
                child: LgNotice(slide.note!, kind: NoticeKind.info),
              ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    super.key,
    required this.slide,
    required this.width,
    this.height = double.infinity,
    this.showNotes = false,
    this.answerShown = false,
    this.onAnswer,
  });

  final LectureSlide slide;
  final double width;

  /// Savol-javob shabloni: javob ochiqmi va uni almashtirish.
  final bool answerShown;
  final VoidCallback? onAnswer;

  /// Yotiq ekranda (televizor, proyektor) shrift balandlikka ham moslanadi.
  final double height;
  final bool showNotes;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    // Katta ekranda (proyektor, televizor) shrift kattalashadi.
    final base = slideBaseFont(width, height);
    if (slide.image != null) return _picture(context, base);
    final isTitle = slide.template == SlideTemplate.title;
    final pad = (width * 0.06).clamp(16.0, 64.0);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isTitle && height.isFinite
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        if (slide.eyebrow != null && slide.eyebrow != slide.title)
          Text(
            slide.eyebrow!,
            style: text.labelLarge!.copyWith(
              fontSize: base * 0.7,
              color: p.brand,
            ),
          ),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            slide.title,
            style: text.headlineMedium!.copyWith(
              fontSize: isTitle
                  // Uzun mavzu nomi kichikroq: sarlavha slaydi sig'sin.
                  ? (slide.title.length > 90
                        ? base * 1.35
                        : slide.title.length > 50
                        ? base * 1.7
                        : base * 2.1)
                  : slide.section
                  ? base * 1.9
                  : slide.question
                  // Uzun savol matni kichikroq: javob bilan birga sig'sin.
                  ? (slide.title.length > 110 ? base * 1.15 : base * 1.4)
                  : base * 1.6,
              height: 1.2,
              color: p.ink,
            ),
          ),
        ),
        SizedBox(height: isTitle ? 28 : 20),
        ..._body(context, base, pad),
        if (slide.note != null) ...[
          const SizedBox(height: 8),
          _scaled(context, base, LgNotice(slide.note!, kind: NoticeKind.info)),
        ],
        if (slide.source != null) ...[
          const SizedBox(height: 8),
          Text(
            slide.source!,
            key: const ValueKey('lecture-source'),
            style: text.bodySmall!.copyWith(
              fontSize: (base * 0.6).clamp(12.0, 24.0),
              color: p.sub,
            ),
          ),
        ],
        if (showNotes && slide.teacherNote != null) ...[
          const SizedBox(height: 16),
          _notes(context, base),
        ],
      ],
    );
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 16),
      child: height.isFinite
          ? ConstrainedBox(
              constraints: BoxConstraints(minHeight: height - 32),
              child: content,
            )
          : content,
    );
  }

  /// Katta ekranda (televizor) izoh matni ham kattalashadi: oddiy 14 px
  /// 1080p da o'qilmaydi.
  Widget _scaled(BuildContext context, double base, Widget child) {
    final k = (base / 28).clamp(1.0, 1.5);
    if (k <= 1.0) return child;
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: TextScaler.linear(mq.textScaler.scale(1) * k),
      ),
      child: child,
    );
  }

  /// Shablonga qarab slayd tanasi.
  List<Widget> _body(BuildContext context, double base, double pad) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    switch (slide.template) {
      case SlideTemplate.title:
        return [SlideTitleBody(slide: slide, base: base)];
      case SlideTemplate.table:
        return [
          SlideTableBody(slide: slide, base: base, width: width - pad * 2),
        ];
      case SlideTemplate.figure:
        return [
          if (slide.figure != null)
            SlideFigureBody(
              slide: slide,
              base: base,
              width: width,
              height: height,
            ),
          const SizedBox(height: 12),
        ];
      case SlideTemplate.qa:
        return [
          SlideQaBody(
            slide: slide,
            base: base,
            answerShown: answerShown,
            onToggleAnswer: onAnswer ?? () {},
          ),
        ];
      case SlideTemplate.bullets:
        final f = slide.compact ? base * 0.8 : base;
        return [
          for (final b in slide.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      '•  ',
                      style: text.bodyLarge!.copyWith(
                        fontSize: f,
                        color: p.brand,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      style: text.bodyLarge!.copyWith(
                        fontSize: f,
                        height: 1.35,
                        color: p.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ];
    }
  }

  Widget _notes(BuildContext context, double base) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Container(
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
            AppLocalizations.of(context).lectureTeacherNote,
            style: text.labelLarge!.copyWith(color: p.brand),
          ),
          const SizedBox(height: 6),
          Text(
            slide.teacherNote!,
            style: text.bodyMedium!.copyWith(
              fontSize: (base * 0.7).clamp(14.0, 22.0),
              height: 1.4,
              color: p.ink,
            ),
          ),
        ],
      ),
    );
  }

  /// Tayyor dizayndagi slayd: ekranga sig'adigan eng katta 16:9 rasm.
  Widget _picture(BuildContext context, double base) {
    final pad = width > height ? 8.0 : 16.0;
    final w = math.min(width - pad * 2, (height - pad * 2) * 16 / 9);
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        children: [
          Semantics(
            image: true,
            label: [slide.title, ...slide.bullets].join('. '),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                slide.image!,
                key: ValueKey(slide.image),
                width: w,
                height: w * 9 / 16,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
                gaplessPlayback: true,
              ),
            ),
          ),
          if (slide.note != null) ...[
            const SizedBox(height: 12),
            LgNotice(slide.note!, kind: NoticeKind.info),
          ],
          if (showNotes && slide.teacherNote != null) ...[
            const SizedBox(height: 12),
            _notes(context, base),
          ],
        ],
      ),
    );
  }
}
