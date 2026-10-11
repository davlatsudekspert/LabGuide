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
import 'lecture_decks.dart';
import 'topic_questions.dart';

// Ma'ruza (taqdimot) rejimi: ustoz mavzuni katta ekranda ko'rsatadi.
// Serversiz ishlaydi — slaydlar o'quv dasturi va ilova kontentidan
// yig'iladi; ekran o'chmaydi (wakelock), katta shrift, oldinga/orqaga
// (tugma, surish, klaviatura ← →).

String _lang(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

@immutable
class LectureSlide {
  const LectureSlide({
    required this.title,
    this.eyebrow,
    this.bullets = const [],
    this.note,
    this.question = false,
    this.teacherNote,
    this.source,
    this.section = false,
  });

  final String? eyebrow;
  final String title;
  final List<String> bullets;
  final String? note;

  /// Ustoz izohi — faqat tugma bosilganda ko'rinadi.
  final String? teacherNote;

  /// Manba (slayd pastida kichik yozuv).
  final String? source;

  /// Bo'lim boshi slaydi (sarlavha kattaroq).
  final bool section;

  /// Savol slaydi (auditoriyaga beriladi).
  final bool question;
}

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

/// Tayyor taqdimot slaydlari. Birinchi slaydda halol holat: qoralama va
/// (boshqa tilda) "faqat o'zbekcha".
List<LectureSlide> deckLectureSlides(BuildContext context, LectureDeck deck) {
  final l = AppLocalizations.of(context);
  final notice = [
    if (deck.draft) l.lectureDraftNotice,
    if (deck.lang != _lang(context)) l.lectureUzOnly,
  ].join('\n');
  return [
    for (final (i, d) in deck.slides.indexed)
      LectureSlide(
        eyebrow: d.eyebrow,
        title: d.title,
        bullets: d.bullets,
        note: i == 0 && notice.isNotEmpty ? notice : null,
        teacherNote: d.note,
        source: d.source,
        section: d.section,
      ),
  ];
}

/// O'quv dasturi mavzulari ro'yxati — ma'ruzani tanlash (serversiz).
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
    );
  }
}

class LectureScreen extends StatefulWidget {
  const LectureScreen({super.key, required this.topicId});

  final String topicId;

  @override
  State<LectureScreen> createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  int _index = 0;
  bool _notes = false;
  bool _deckLoaded = false;
  LectureDeck? _authored;
  final _focus = FocusNode(debugLabel: 'lecture');

  @override
  void initState() {
    super.initState();
    unawaited(DiffDevice.screenAwake.set(on: true));
    final s = context.services;
    unawaited(s.curriculum.ensureLoaded());
    unawaited(s.toifa.ensureLoaded());
    unawaited(s.microscopy.ensureAtlas());
    final bundle = s.curriculum.bundle ?? rootBundle;
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = context.services;
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
        return KeyEventResult.ignored;
      },
      child: Scaffold(
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
                    if (slides[i].teacherNote != null)
                      IconButton(
                        key: const ValueKey('lecture-notes'),
                        tooltip: _notes
                            ? l.lectureNotesHide
                            : l.lectureNotesShow,
                        isSelected: _notes,
                        icon: const Icon(Icons.speaker_notes_outlined),
                        selectedIcon: const Icon(Icons.speaker_notes_rounded),
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
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
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
                      child: LgButton(
                        label: l.lectureNext,
                        icon: Icons.chevron_right_rounded,
                        onPressed: i == slides.length - 1
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
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    super.key,
    required this.slide,
    required this.width,
    this.height = double.infinity,
    this.showNotes = false,
  });

  final LectureSlide slide;
  final double width;

  /// Yotiq ekranda (televizor, proyektor) shrift balandlikka ham moslanadi.
  final double height;
  final bool showNotes;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    // Katta ekranda (proyektor, planshet) shrift kattalashadi.
    final base = math.min(width / 22, height / 19).clamp(16.0, 34.0);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: (width * 0.06).clamp(16.0, 64.0),
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                fontSize: slide.section
                    ? base * 1.9
                    : slide.question
                    ? base * 1.4
                    : base * 1.6,
                height: 1.2,
                color: p.ink,
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                        fontSize: base,
                        color: p.brand,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      style: text.bodyLarge!.copyWith(
                        fontSize: base,
                        height: 1.35,
                        color: p.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (slide.note != null) ...[
            const SizedBox(height: 8),
            LgNotice(slide.note!, kind: NoticeKind.info),
          ],
          if (slide.source != null) ...[
            const SizedBox(height: 8),
            Text(
              slide.source!,
              style: text.bodySmall!.copyWith(
                fontSize: (base * 0.6).clamp(12.0, 18.0),
                color: p.sub,
              ),
            ),
          ],
          if (showNotes && slide.teacherNote != null) ...[
            const SizedBox(height: 16),
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
            ),
          ],
        ],
      ),
    );
  }
}
