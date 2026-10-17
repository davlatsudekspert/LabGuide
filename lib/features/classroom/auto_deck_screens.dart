import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/analyte_search.dart';
import '../content/content_model.dart';
import '../content/ui/content_widgets.dart';
import '../microscopy/microscopy_atlas.dart';
import '../reference/reference_content.dart';
import 'auto_deck.dart';
import 'classroom_screens.dart';
import 'curriculum.dart';
import 'lecture_slide.dart';

// Avtomatik taqdimot (D-47): tanlash → ko'rish (tartib, olib
// tashlash) → "Boshlash" mavjud Ma'ruza pleyerida ochadi. Slaydlar faqat
// manbali mazmundan yig'iladi (auto_deck.dart), tashqi chaqiruvsiz.

const _routeBase = '/learn/lecture/auto';

/// Mavzuda taqdimot uchun biror material bormi (aks holda ro'yxatda
/// ko'rsatilmaydi: tanlansa bo'sh chiqardi).
bool topicHasMaterial(ContentPack pack, MicroAtlas? atlas, CurriculumTopic t) {
  final k = t.links;
  return k.analytes.any((id) => pack.analyte(id) != null) ||
      k.conditions.any((id) => pack.condition(id) != null) ||
      k.reference.any((id) => refTopic(id) != null) ||
      (atlas != null && k.microscopy.any((id) => atlas.section(id) != null));
}

enum _Mode { topic, tests }

class AutoPresentationPickerScreen extends StatefulWidget {
  const AutoPresentationPickerScreen({super.key});

  @override
  State<AutoPresentationPickerScreen> createState() =>
      _AutoPresentationPickerScreenState();
}

class _AutoPresentationPickerScreenState
    extends State<AutoPresentationPickerScreen> {
  _Mode _mode = _Mode.topic;
  String? _topicId;
  String? _openModule;
  final _analytes = <String>[];
  bool _quiz = true;
  bool _general = false;
  final _query = TextEditingController();
  AnalyteSearch? _search;

  @override
  void initState() {
    super.initState();
    final s = context.services;
    unawaited(s.curriculum.ensureLoaded());
    unawaited(s.microscopy.ensureAtlas());
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool get _ready =>
      _mode == _Mode.topic ? _topicId != null : _analytes.isNotEmpty;

  void _toggleAnalyte(String id) => setState(() {
    if (!_analytes.remove(id)) {
      if (_analytes.length < autoMaxAnalytes) _analytes.add(id);
    }
  });

  void _next() {
    unawaited(
      context.push(
        '$_routeBase/preview',
        extra: AutoDeckSpec(
          topicId: _mode == _Mode.topic ? _topicId : null,
          analyteIds: _mode == _Mode.tests ? List.of(_analytes) : const [],
          includeQuiz: _quiz,
          includeGeneralPreanalytics: _general,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = context.services;
    return ListenableBuilder(
      listenable: Listenable.merge([s.content, s.microscopy, s.settings]),
      builder: (context, _) => LgPage(
        title: l.autoPresTitle,
        subtitle: l.autoPresPickerSub,
        showProfile: false,
        children: [
          LgNotice(l.autoPresLanguageNote, kind: NoticeKind.info),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LgChoiceChip(
                key: const ValueKey('auto-mode-topic'),
                label: l.autoPresModeTopic,
                selected: _mode == _Mode.topic,
                onTap: () => setState(() => _mode = _Mode.topic),
              ),
              LgChoiceChip(
                key: const ValueKey('auto-mode-tests'),
                label: l.autoPresModeTests,
                selected: _mode == _Mode.tests,
                onTap: () => setState(() => _mode = _Mode.tests),
              ),
            ],
          ),
          ContentGate(
            builder: (context, pack) => _mode == _Mode.topic
                ? _topics(context, pack)
                : _tests(context, pack),
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            key: const ValueKey('auto-opt-quiz'),
            contentPadding: EdgeInsets.zero,
            title: Text(l.autoPresOptQuiz),
            subtitle: Text(l.autoPresOptQuizSub),
            value: _quiz,
            onChanged: (v) => setState(() => _quiz = v),
          ),
          SwitchListTile.adaptive(
            key: const ValueKey('auto-opt-general'),
            contentPadding: EdgeInsets.zero,
            title: Text(l.autoPresOptGeneral),
            subtitle: Text(l.autoPresOptGeneralSub),
            value: _general,
            onChanged: (v) => setState(() => _general = v),
          ),
          const SizedBox(height: 8),
          if (!_ready)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l.autoPresPickFirst,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          LgButton(
            key: const ValueKey('auto-preview'),
            label: l.autoPresPreview,
            icon: Icons.slideshow_rounded,
            onPressed: _ready ? _next : null,
          ),
        ],
      ),
    );
  }

  /// Mavzular modul bo'yicha yig'ma ro'yxat: bir vaqtda bitta modul ochiq,
  /// tanlangach yig'iladi (sahifa uzun bo'lib ketmasin).
  Widget _topics(BuildContext context, ContentPack pack) {
    final lang = Localizations.localeOf(context).languageCode;
    final atlas = context.services.microscopy.atlas;
    final p = LgPalette.of(context);
    return CurriculumGate(
      builder: (context, cur) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_topicId != null && cur.topic(_topicId!) != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: LgChoiceChip(
                  key: const ValueKey('auto-topic-chosen'),
                  label: cur.topic(_topicId!)!.title.of(lang),
                  selected: true,
                  onTap: () => setState(() => _topicId = null),
                ),
              ),
            ),
          for (final m in cur.modules)
            if (m.topics.any((t) => topicHasMaterial(pack, atlas, t))) ...[
              Semantics(
                expanded: _openModule == m.id,
                child: LgRow(
                  key: ValueKey('auto-module-${m.id}'),
                  title: m.title.of(lang),
                  icon: Icons.folder_open_outlined,
                  trailing: Icon(
                    _openModule == m.id
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: p.sub,
                  ),
                  onTap: () => setState(
                    () => _openModule = _openModule == m.id ? null : m.id,
                  ),
                ),
              ),
              if (_openModule == m.id)
                for (final t in m.topics)
                  if (topicHasMaterial(pack, atlas, t))
                    Semantics(
                      selected: _topicId == t.id,
                      child: LgRow(
                        key: ValueKey('auto-topic-${t.id}'),
                        title: t.title.of(lang),
                        subtitle: topicMeta(context, t),
                        icon: Icons.slideshow_outlined,
                        trailing: _topicId == t.id
                            ? Icon(Icons.check_circle_rounded, color: p.brand)
                            : null,
                        onTap: () => setState(() {
                          _topicId = t.id;
                          _openModule = null;
                        }),
                      ),
                    ),
            ],
        ],
      ),
    );
  }

  Widget _tests(BuildContext context, ContentPack pack) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final p = LgPalette.of(context);
    final search = _search?.pack == pack
        ? _search!
        : _search = AnalyteSearch(pack);
    final results = search.search(_query.text, lang: lang);
    const shown = 8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgField(
          label: l.autoPresSearch,
          hint: l.autoPresSearchHint,
          controller: _query,
          textInputAction: TextInputAction.search,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Text(
          l.autoPresSelectedCount(_analytes.length, autoMaxAnalytes),
          key: const ValueKey('auto-selected-count'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        if (_analytes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in _analytes)
                if (pack.analyte(id) case final a?)
                  LgChoiceChip(
                    key: ValueKey('auto-chip-$id'),
                    label: a.names.of(lang),
                    selected: true,
                    onTap: () => _toggleAnalyte(id),
                  ),
            ],
          ),
        ],
        if (_analytes.length >= autoMaxAnalytes)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LgNotice(
              l.autoPresLimitReached(autoMaxAnalytes),
              kind: NoticeKind.info,
            ),
          ),
        const SizedBox(height: 4),
        if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(l.autoPresNoResults),
          )
        else
          for (final (i, a) in results.take(shown).indexed)
            LgRow(
              key: ValueKey('auto-analyte-${a.id}'),
              title: a.names.of(lang),
              subtitle: [
                ?pack.group(a.group)?.names.of(lang),
                contentStateLabel(a, l),
              ].join(' · '),
              icon: groupIcon(a.group),
              divider: i < results.take(shown).length - 1,
              trailing: _analytes.contains(a.id)
                  ? Icon(Icons.check_circle_rounded, color: p.brand)
                  : null,
              onTap: () => _toggleAnalyte(a.id),
            ),
        if (results.length > shown)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l.autoPresMoreItems(results.length - shown),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

/// Yig'ilgan slaydlarni ko'rish: tartibni o'zgartirish, olib tashlash.
class AutoPresentationPreviewScreen extends StatefulWidget {
  const AutoPresentationPreviewScreen({super.key, required this.spec});

  final AutoDeckSpec? spec;

  @override
  State<AutoPresentationPreviewScreen> createState() =>
      _AutoPresentationPreviewScreenState();
}

class _AutoPresentationPreviewScreenState
    extends State<AutoPresentationPreviewScreen> {
  AutoDeck? _deck;
  Object? _builtFor;
  List<AutoSlide> _order = [];
  final _removed = <(int, AutoSlide)>[];

  @override
  void initState() {
    super.initState();
    unawaited(context.services.curriculum.ensureLoaded());
    unawaited(context.services.microscopy.ensureAtlas());
  }

  /// Til yoki kontent o'zgarsa qayta yig'iladi (tartib asliga qaytadi).
  void _ensureBuilt(BuildContext context, ContentPack pack) {
    final l = AppLocalizations.of(context);
    final s = context.services;
    final key = (
      pack,
      l.localeName,
      s.curriculum.curriculum,
      s.microscopy.atlas,
    );
    if (_builtFor == key) return;
    _builtFor = key;
    _deck = buildAutoDeck(
      l: l,
      pack: pack,
      spec: widget.spec!,
      curriculum: s.curriculum.curriculum,
      atlas: s.microscopy.atlas,
    );
    _order = List.of(_deck!.slides);
    _removed.clear();
  }

  void _move(int i, int delta) {
    final j = i + delta;
    if (j < 0 || j >= _order.length) return;
    setState(() {
      final x = _order.removeAt(i);
      _order.insert(j, x);
    });
  }

  void _remove(int i) => setState(() {
    final x = _order.removeAt(i);
    _removed.add((_deck!.slides.indexOf(x), x));
  });

  void _restore() => setState(() {
    for (final (idx, x) in _removed) {
      _order.insert(idx.clamp(0, _order.length), x);
    }
    _removed.clear();
  });

  Future<void> _start(AppLocalizations l) async {
    final slides = assembleAutoDeck(l, _deck!, _order);
    unawaited(context.push('$_routeBase/play', extra: slides));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = context.services;
    if (widget.spec == null) {
      return LgPage(
        title: l.autoPresPreviewTitle,
        showProfile: false,
        children: [
          LgStateView(
            kind: StateKind.empty,
            title: l.autoPresPickFirst,
            actionLabel: l.actionBack,
            onAction: () => context.pop(),
          ),
        ],
      );
    }
    return ListenableBuilder(
      listenable: Listenable.merge([
        s.content,
        s.curriculum,
        s.microscopy,
        s.settings,
      ]),
      builder: (context, _) => LgPage(
        title: l.autoPresPreviewTitle,
        subtitle: l.autoPresPreviewSub,
        showProfile: false,
        children: [
          ContentGate(
            builder: (context, pack) {
              _ensureBuilt(context, pack);
              return _content(context, l);
            },
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, AppLocalizations l) {
    final deck = _deck!;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final n in deck.notices)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LgNotice(n, kind: NoticeKind.info),
          ),
        if (deck.isEmpty)
          LgStateView(
            key: const ValueKey('auto-empty'),
            kind: StateKind.empty,
            title: l.autoPresEmptyTitle,
            message: l.autoPresEmptyBody,
            actionLabel: l.actionBack,
            onAction: () => context.pop(),
          )
        else ...[
          Text(
            l.autoPresSlideCount(_order.length),
            key: const ValueKey('auto-slide-count'),
            style: text.titleSmall,
          ),
          const SizedBox(height: 8),
          for (final (i, a) in _order.indexed)
            _SlideRow(
              key: ValueKey('auto-row-${a.id}'),
              index: i,
              slide: a,
              canUp: i > 0,
              canDown: i < _order.length - 1,
              onUp: () => _move(i, -1),
              onDown: () => _move(i, 1),
              onRemove: () => _remove(i),
            ),
          if (_order.isNotEmpty)
            LgRow(
              key: const ValueKey('auto-sources-row'),
              title: l.analyteSources,
              subtitle: l.autoPresSourcesPinned,
              icon: Icons.library_books_outlined,
              divider: false,
            ),
          if (_removed.isNotEmpty)
            LgButton.secondary(
              key: const ValueKey('auto-restore'),
              label: l.autoPresRestore,
              icon: Icons.undo_rounded,
              onPressed: _restore,
            ),
          const SizedBox(height: 12),
          LgButton(
            key: const ValueKey('auto-start'),
            label: l.autoPresStart,
            icon: Icons.play_arrow_rounded,
            onPressed: _order.isEmpty ? null : () => _start(l),
          ),
        ],
      ],
    );
  }
}

String _templateLabel(AppLocalizations l, SlideTemplate t) => switch (t) {
  SlideTemplate.title => l.autoPresTplTitle,
  SlideTemplate.bullets => l.autoPresTplBullets,
  SlideTemplate.table => l.autoPresTplTable,
  SlideTemplate.figure => l.autoPresTplFigure,
  SlideTemplate.qa => l.autoPresTplQa,
};

IconData _templateIcon(SlideTemplate t) => switch (t) {
  SlideTemplate.title => Icons.title_rounded,
  SlideTemplate.bullets => Icons.format_list_bulleted_rounded,
  SlideTemplate.table => Icons.table_chart_outlined,
  SlideTemplate.figure => Icons.image_outlined,
  SlideTemplate.qa => Icons.quiz_outlined,
};

/// Slaydning qisqa mazmuni (ko'rishda nima chiqishini bilish uchun).
String _snippet(LectureSlide s) {
  if (s.bullets.isNotEmpty) return s.bullets.first;
  if (s.tableRows.isNotEmpty) return s.tableRows.first.join(' — ');
  return s.figureCaption ?? s.answerExplanation ?? '';
}

class _SlideRow extends StatelessWidget {
  const _SlideRow({
    super.key,
    required this.index,
    required this.slide,
    required this.canUp,
    required this.canDown,
    required this.onUp,
    required this.onDown,
    required this.onRemove,
  });

  final int index;
  final AutoSlide slide;
  final bool canUp;
  final bool canDown;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final s = slide.slide;
    final snippet = _snippet(s);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 4),
      decoration: BoxDecoration(
        color: p.paper,
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Semantics(
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Icon(_templateIcon(s.template), color: p.brand),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${index + 1}. ${s.title}', style: text.titleSmall),
                      Text(
                        [
                          _templateLabel(l, s.template),
                          if (s.eyebrow != null && s.eyebrow != s.title)
                            s.eyebrow!,
                        ].join(' · '),
                        style: text.bodySmall!.copyWith(color: p.brand),
                      ),
                      if (snippet.isNotEmpty)
                        Text(
                          snippet,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                children: [
                  IconButton(
                    key: ValueKey('auto-up-${slide.id}'),
                    tooltip: l.autoPresMoveUp,
                    icon: const Icon(Icons.arrow_upward_rounded),
                    onPressed: canUp ? onUp : null,
                  ),
                  IconButton(
                    key: ValueKey('auto-down-${slide.id}'),
                    tooltip: l.autoPresMoveDown,
                    icon: const Icon(Icons.arrow_downward_rounded),
                    onPressed: canDown ? onDown : null,
                  ),
                  IconButton(
                    key: ValueKey('auto-remove-${slide.id}'),
                    tooltip: l.autoPresRemove,
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: onRemove,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
