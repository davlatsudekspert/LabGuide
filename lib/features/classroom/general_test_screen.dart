import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/backend/backend_models.dart';
import '../../core/backend/variant_draw.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/analyte_search.dart';
import '../content/ui/content_widgets.dart';
import '../learn/classes_screens.dart' show ClassesGate, classesErrorText;
import '../learn/exam_question.dart';
import '../learn/exam_widgets.dart';
import 'assign_controls.dart';
import 'curriculum.dart';
import 'general_test.dart';

// “Umumiy test berish”: ustoz bir nechta manbadan (toifa, ma'ruza, analizlar)
// mavzular tanlab, guruhga 50 tagacha savollik test beradi. Boshqaruvlar —
// mavzu testini topshirish sahifasi bilan bir xil (assign_controls.dart):
// son, variantli rejim, vaqt, ochiq turish muddati, javoblar qachon ochiladi.

/// Guruhsiz manzil (O'rganish → Guruh va topshiriqlar).
const generalTestLocation = '/learn/classes/test';

/// Guruh sahifasidan: shu guruh oldindan tanlangan.
String groupGeneralTestLocation(String groupId) =>
    '/learn/classes/g/$groupId/assign';

class GeneralTestScreen extends StatefulWidget {
  const GeneralTestScreen({super.key, this.initialGroupId});

  /// Guruh sahifasidan kelindi: shu guruh oldindan tanlangan.
  final String? initialGroupId;

  @override
  State<GeneralTestScreen> createState() => _GeneralTestScreenState();
}

class _GeneralTestScreenState extends State<GeneralTestScreen> {
  final _title = TextEditingController();
  final _count = TextEditingController();
  final _query = TextEditingController();
  final Set<String> _picked = {};
  final Set<String> _selected = {};
  final Set<String> _expanded = {};

  /// Ustoz sarlavhani o'zi yozdi — endi avtomatik yangilanmaydi.
  bool _titleEdited = false;

  /// Ustoz sonni o'zi tanladi — tanlov o'zgarsa ham saqlanadi.
  bool _countTouched = false;

  /// Ustoz vaqtni o'zi tanladi; aks holda — savol soniga mos (≈ 1 daqiqa).
  bool _limitTouched = false;
  int? _limit = kAssignDefaultLimit;

  AssignDue _due = AssignDue.d1;
  DateTime? _customDue;
  bool _afterDue = false;

  List<StudyGroup>? _groups;
  Object? _error;
  bool _loading = false;
  bool _busy = false;
  bool _tried = false;
  bool _initialPicked = false;
  String? _uid;

  /// Variant tanlovi: null — avtomatik (mumkin bo'lsa yoqiq).
  bool? _variantChoice;

  // Tasodifiy tanlovlar — tanlov (va son) o'zgarguncha barqaror.
  String? _drawnFor;
  List<ExamQuestion>? _drawn;
  String? _variantFor;
  List<ExamQuestion>? _variantPool;

  @override
  void initState() {
    super.initState();
    final s = context.services;
    unawaited(s.toifa.ensureLoaded());
    unawaited(s.curriculum.ensureLoaded());
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _title.dispose();
    _count.dispose();
    _query.dispose();
    super.dispose();
  }

  bool get _ready =>
      context.services.backend.isConfigured && context.services.auth.hasAccount;

  Future<void> _load() async {
    if (!mounted || !_ready || _loading) return;
    final backend = context.services.backend;
    _uid = backend.userId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final groups = [
        for (final g in await backend.myGroups())
          if (g.isTeacher) g,
      ];
      if (!mounted) return;
      setState(() {
        _groups = groups;
        final initial = widget.initialGroupId;
        if (_picked.isEmpty && !_initialPicked) {
          _initialPicked = true;
          if (initial != null && groups.any((g) => g.id == initial)) {
            _picked.add(initial);
          } else if (groups.length == 1) {
            _picked.add(groups.single.id);
          }
        }
      });
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ------------------------------------------------------------ hisob-kitob

  int? get _n => int.tryParse(_count.text.trim());

  int _max(List<ExamQuestion> pool) =>
      pool.length < kGeneralTestMax ? pool.length : kGeneralTestMax;

  bool _countOk(List<ExamQuestion> pool) {
    final n = _n;
    return n != null && n >= 1 && n <= _max(pool);
  }

  String get _selectionKey => (_selected.toList()..sort()).join(',');

  int _seed() => context.services.topicTests.nextSeed();

  void _redraw(List<GeneralStratum> strata, List<ExamQuestion> pool) {
    _drawnFor = '$_selectionKey|$_n';
    _drawn = _countOk(pool)
        ? drawBalanced(strata, count: _n!, seed: _seed())
        : null;
  }

  /// Variantli hovuz: hammasi (≤ 100) yoki mavzular bo'yicha teng 100 ta.
  List<ExamQuestion> _poolFor(
    List<GeneralStratum> strata,
    List<ExamQuestion> pool,
  ) {
    if (_variantFor != _selectionKey || _variantPool == null) {
      _variantFor = _selectionKey;
      final out = pool.length <= kGeneralVariantPoolMax
          ? [...pool]
          : drawBalanced(strata, count: kGeneralVariantPoolMax, seed: _seed());
      _variantPool = out..sort((a, b) => a.id.compareTo(b.id));
    }
    return _variantPool!;
  }

  bool _variantAllowed(
    List<ExamQuestion> variantPool,
    List<ExamQuestion> pool,
  ) {
    final n = _n;
    return context.services.backend.supportsVariantTests &&
        _countOk(pool) &&
        n != null &&
        variantAllowed(variantPool.length, n);
  }

  /// Savol soniga mos vaqt (≈ 1 daqiqa savolga), eng yaqin tanlov.
  int _limitFor(int n) =>
      kAssignLimits.firstWhere((m) => m >= n, orElse: () => kAssignLimits.last);

  DateTime? get _dueAt =>
      assignDueAt(_due, _customDue, context.services.exams.now());

  Future<void> _pickDate() async {
    final picked = await pickAssignDueDate(
      context,
      context.services.exams.now(),
      _customDue,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _due = AssignDue.custom;
      _customDue = picked;
    });
  }

  bool get _titleOk {
    final n = _title.text.trim().length;
    return n >= 3 && n <= 120;
  }

  void _toggle(Iterable<String> keys, {bool? on}) {
    final list = keys.toList();
    final add = on ?? !list.every(_selected.contains);
    setState(() {
      if (add) {
        _selected.addAll(list);
      } else {
        _selected.removeAll(list);
      }
    });
  }

  Future<void> _send(
    GeneralCatalog catalog,
    List<GeneralStratum> strata,
    List<ExamQuestion> pool,
  ) async {
    setState(() => _tried = true);
    final drawn = _drawn;
    final due = _dueAt;
    if (_picked.isEmpty || _selected.isEmpty || !_titleOk) return;
    if (drawn == null || !_countOk(pool)) return;
    if (_afterDue && due == null) return;
    final variantPool = _poolFor(strata, pool);
    final variant =
        _variantAllowed(variantPool, pool) && (_variantChoice ?? true);
    final topicOf = stratumOf(strata);
    final l = AppLocalizations.of(context);
    final backend = context.services.backend;
    final title = _title.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });

    Future<void> create(String g, List<ExamQuestion> source) =>
        backend.createAssignment(
          groupId: g,
          title: title,
          questionIds: [for (final q in source) q.id],
          correctIndexes: [for (final q in source) q.correct.single],
          dueAt: due,
          timeLimitMinutes: _limit,
          revealAfterDue: _afterDue,
          perStudent: variant ? _n : null,
          poolTopics: variant ? [for (final q in source) topicOf[q.id]] : null,
        );

    var sent = 0;
    try {
      for (final g in [..._picked]) {
        final source = variant ? variantPool : drawn;
        try {
          await create(g, source);
        } on BackendException catch (e) {
          // Eski server (deploydan oldin) variantli hovuzni 60 gacha qabul
          // qiladi: 2 × N ≤ 60 bo'lsa — teng taqsimlangan 60 ta bilan.
          final n = _n!;
          if (!variant ||
              e.failure != BackendFailure.invalid ||
              source.length <= kVariantPoolMax ||
              !variantAllowed(kVariantPoolMax, n)) {
            rethrow;
          }
          final small = drawBalanced(
            strata,
            count: kVariantPoolMax,
            seed: _seed(),
          )..sort((a, b) => a.id.compareTo(b.id));
          await create(g, small);
        }
        sent++;
        _picked.remove(g);
      }
      if (!mounted) return;
      showSnack(context, l.topicTestSent(sent));
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go('/learn/classes');
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = context.services;
    return LgPage(
      title: l.classesGiveGeneralTest,
      subtitle: l.generalTestSub,
      showProfile: false,
      children: [
        ClassesGate(
          child: ListenableBuilder(
            listenable: Listenable.merge([s.auth, s.curriculum]),
            builder: (context, _) {
              // Hisob almashsa — boshqa hisob guruhlari ko'rinmasin.
              final uid = s.backend.userId;
              if (_uid != null && uid != _uid) {
                _groups = null;
                _picked.clear();
                WidgetsBinding.instance.addPostFrameCallback((_) => _load());
              }
              return ContentGate(
                builder: (context, pack) => ToifaBankGate(
                  builder: (context, bank) {
                    final cur = s.curriculum;
                    if (cur.curriculum == null &&
                        cur.state != CurriculumState.missing &&
                        cur.state != CurriculumState.error) {
                      return LgSkeleton(caption: l.classesLoading);
                    }
                    final catalog = GeneralCatalog.of(
                      cur.curriculum,
                      pack,
                      bank,
                    );
                    return _body(context, catalog);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, GeneralCatalog catalog) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final groups = _groups;
    if (groups == null) {
      if (_error != null) {
        return LgStateView(
          kind: StateKind.error,
          title: classesErrorText(_error!, l),
          actionLabel: l.actionRetry,
          onAction: _load,
        );
      }
      return LgSkeleton(caption: l.classesLoading);
    }
    if (groups.isEmpty) {
      return LgStateView(
        kind: StateKind.empty,
        title: l.topicTestNoGroups,
        message: l.topicTestNoGroupsBody,
        actionLabel: l.topicTestCreateGroup,
        onAction: () async {
          await context.push('/learn/classes/new');
          if (mounted) await _load();
        },
      );
    }

    final strata = catalog.strata(_selected);
    final pool = generalPool(strata);
    final max = _max(pool);
    if (!_countTouched) {
      final v = '${max < 1 ? kGeneralTestMax : max}';
      if (_count.text != v) _count.text = v;
    }
    final n = _n ?? 0;
    if (!_limitTouched && _countOk(pool)) _limit = _limitFor(n);
    if (!_titleEdited) {
      final v = _selected.isEmpty
          ? ''
          : generalTestTitle(l, lang, catalog, _selected);
      if (_title.text != v) _title.text = v;
    }
    if (_drawnFor != '$_selectionKey|$_n') _redraw(strata, pool);
    final drawn = _drawn;
    final variantPool = _poolFor(strata, pool);
    final canVariant = _variantAllowed(variantPool, pool);
    final variant = canVariant && (_variantChoice ?? true);
    final due = _dueAt;
    final needsDue = _afterDue && due == null;
    final selectedTopics = strata.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.generalTestIntro, style: text.bodyMedium),
        LgSectionTitle(l.topicTestGroups),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in groups)
              LgChoiceChip(
                key: ValueKey('assign-group-${g.id}'),
                label: g.name,
                selected: _picked.contains(g.id),
                onTap: () => setState(() {
                  if (!_picked.remove(g.id)) _picked.add(g.id);
                }),
              ),
          ],
        ),
        if (_tried && _picked.isEmpty)
          LgNotice(l.topicTestPickGroup, kind: NoticeKind.error),
        LgSectionTitle(l.generalTestSources),
        TextField(
          key: const ValueKey('general-search'),
          controller: _query,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l.generalTestSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        ..._sources(context, catalog),
        const SizedBox(height: 8),
        Text(
          l.generalSelected(selectedTopics, pool.length),
          key: const ValueKey('general-selected'),
          style: text.labelLarge,
        ),
        if (_tried && _selected.isEmpty)
          LgNotice(l.generalPickTopic, kind: NoticeKind.error),
        LgSectionTitle(l.examSettings),
        LgField(
          key: const ValueKey('general-title'),
          label: l.classesAssignmentTitle,
          controller: _title,
          hint: l.generalTestNameHint,
          maxLength: 120,
          textInputAction: TextInputAction.next,
          errorText: _tried && !_titleOk ? l.classesLengthError(3, 120) : null,
          onChanged: (_) => setState(() => _titleEdited = true),
        ),
        const SizedBox(height: 6),
        NumberPresetField(
          key: const ValueKey('general-count'),
          label: l.examCount,
          controller: _count,
          hint: '$kGeneralTestMax',
          helper: l.examCountHint(max < 1 ? kGeneralTestMax : max),
          errorText: _tried && _selected.isNotEmpty && !_countOk(pool)
              ? l.examCountError(max)
              : null,
          presets: [
            for (final c in const [10, 20, 30, 50])
              if (c < pool.length) ('$c', '$c'),
            if (pool.isNotEmpty && pool.length <= kGeneralTestMax)
              (l.examCountAll(pool.length), '${pool.length}'),
          ],
          onChanged: () => setState(() => _countTouched = true),
        ),
        AssignVariantSwitch(
          supported: context.services.backend.supportsVariantTests,
          allowed: canVariant,
          value: variant,
          poolSize: variantPool.length,
          count: n,
          onChanged: (v) => setState(() => _variantChoice = v),
        ),
        AssignTimingControls(
          limit: _limit,
          onLimit: (m) => setState(() {
            _limitTouched = true;
            _limit = m;
          }),
          due: _due,
          dueAt: due,
          onDue: (d) => setState(() => _due = d),
          onPickDate: _pickDate,
          afterDue: _afterDue,
          onAfterDue: (v) => setState(() => _afterDue = v),
        ),
        LgSectionTitle(
          variant
              ? l.variantPoolTitle(variantPool.length)
              : l.classesPreview(drawn?.length ?? 0),
        ),
        if (_selected.isEmpty)
          Text(l.generalPickTopic, style: text.bodyMedium)
        else if (drawn == null)
          Text(l.examCountError(max), style: text.bodyMedium)
        else if (variant)
          AssignQuestionList(
            key: const ValueKey('assign-variant-pool'),
            questions: variantPool,
            dense: true,
          )
        else ...[
          AssignQuestionList(
            key: const ValueKey('general-preview'),
            questions: drawn,
          ),
          const SizedBox(height: 4),
          LgButton.secondary(
            label: l.classesReshuffle,
            icon: Icons.shuffle_rounded,
            onPressed: () => setState(() => _redraw(strata, pool)),
          ),
        ],
        const SizedBox(height: 10),
        if ((variant ? variantPool : drawn ?? const <ExamQuestion>[]).any(
          (q) => q.isDraft,
        ))
          LgNotice(l.examPracticeNotice, kind: NoticeKind.info),
        LgNotice(l.classesKeyNotice, kind: NoticeKind.info),
        if (_error != null)
          LgNotice(classesErrorText(_error!, l), kind: NoticeKind.error),
        const SizedBox(height: 12),
        LgButton(
          key: const ValueKey('assign-send'),
          label: l.classesSendAssignment,
          icon: Icons.send_rounded,
          busy: _busy,
          onPressed: needsDue ? null : () => _send(catalog, strata, pool),
        ),
      ],
    );
  }

  // ---------------------------------------------------------- manbalar

  bool _matches(GeneralTopic t, AppLocalizations l, String lang, String q) {
    if (q.isEmpty) return true;
    final hay = normalizeForSearch('${t.name(l, lang)} ${t.search}');
    return q.split(RegExp(r'\s+')).every(hay.contains);
  }

  List<Widget> _sources(BuildContext context, GeneralCatalog catalog) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final q = normalizeForSearch(_query.text.trim());
    bool match(GeneralTopic t) => _matches(t, l, lang, q);
    final out = <Widget>[];

    // Toifa savollari.
    final toifa = [
      for (final t in catalog.toifa)
        if (match(t)) t,
    ];
    if (toifa.isNotEmpty) {
      out.add(
        _SourcePanel(
          key: const ValueKey('general-source-toifa'),
          title: l.generalSourceToifa,
          caption:
              '${l.generalSourceToifaSub} · '
              '${l.classesTopicQuestions(catalog.sourceCount(GeneralSource.toifa))}',
          allKey: 'general-all-toifa',
          allSelected: catalog.toifa.every((t) => _selected.contains(t.key)),
          onAll: () => _toggle([for (final t in catalog.toifa) t.key]),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final t in toifa) _chip(t, l, lang)],
            ),
          ],
        ),
      );
    }

    // Ma'ruza mavzulari: modullar va (ochilsa yoki qidirilsa) kunlar.
    final modules = <(GeneralModule, List<GeneralTopic>, bool)>[];
    for (final m in catalog.modules) {
      final moduleHit =
          q.isEmpty ||
          normalizeForSearch(
            '${m.module.title.of(lang)} ${m.module.title.of('uz')} ${m.id}',
          ).contains(q);
      final days = [
        for (final d in m.days)
          if (moduleHit || match(d)) d,
      ];
      if (days.isEmpty) continue;
      modules.add((m, days, moduleHit));
    }
    if (modules.isNotEmpty) {
      final allDays = [for (final d in catalog.lectureDays) d.key];
      out.add(
        _SourcePanel(
          key: const ValueKey('general-source-lecture'),
          title: l.generalSourceLecture,
          caption:
              '${l.generalSourceLectureSub} · '
              '${l.classesTopicQuestions(catalog.sourceCount(GeneralSource.lecture))}',
          allKey: 'general-all-lecture',
          allSelected: allDays.every(_selected.contains),
          onAll: () => _toggle(allDays),
          children: [
            for (final (m, days, moduleHit) in modules)
              _module(
                context,
                m,
                days,
                open: !moduleHit || _expanded.contains(m.id),
              ),
          ],
        ),
      );
    }

    // Analizlar bo'yicha (kontent paketi guruhlari).
    final pack = [
      for (final t in catalog.packGroups)
        if (match(t)) t,
    ];
    if (pack.isNotEmpty) {
      out.add(
        _SourcePanel(
          key: const ValueKey('general-source-pack'),
          title: l.generalSourcePack,
          caption:
              '${l.generalSourcePackSub} · '
              '${l.classesTopicQuestions(catalog.sourceCount(GeneralSource.pack))}',
          allKey: 'general-all-pack',
          allSelected: catalog.packGroups.every(
            (t) => _selected.contains(t.key),
          ),
          onAll: () => _toggle([for (final t in catalog.packGroups) t.key]),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final t in pack) _chip(t, l, lang)],
            ),
          ],
        ),
      );
    }
    if (out.isEmpty) {
      out.add(LgStateView(kind: StateKind.empty, title: l.classesTopicNoMatch));
    }
    return out;
  }

  Widget _chip(GeneralTopic t, AppLocalizations l, String lang) => LgChoiceChip(
    key: ValueKey('general-topic-${t.key}'),
    label: '${t.name(l, lang)} · ${t.questions.length}',
    selected: _selected.contains(t.key),
    onTap: () => _toggle([t.key]),
  );

  Widget _module(
    BuildContext context,
    GeneralModule m,
    List<GeneralTopic> days, {
    required bool open,
  }) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final keys = [for (final d in m.days) d.key];
    final picked = keys.where(_selected.contains).length;
    final all = picked == keys.length;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: LgChoiceChip(
              key: ValueKey('general-module-${m.id}'),
              label:
                  '${m.id} · ${m.module.title.of(lang)} · '
                  '${m.questions.length}',
              selected: all,
              onTap: () => _toggle(keys),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: LgButton.link(
              key: ValueKey('general-days-${m.id}'),
              label: picked > 0 && !all
                  ? '${l.generalDays(m.days.length)} · $picked'
                  : l.generalDays(m.days.length),
              icon: open
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              onPressed: () => setState(() {
                if (!_expanded.remove(m.id)) _expanded.add(m.id);
              }),
            ),
          ),
          if (open)
            for (final d in days)
              // Panel fonli — ListTile siyohi ko'rinsin (o'z Material'i).
              Material(
                type: MaterialType.transparency,
                child: CheckboxListTile.adaptive(
                  key: ValueKey('general-topic-${d.key}'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _selected.contains(d.key),
                  onChanged: (_) => _toggle([d.key]),
                  title: Text(
                    d.name(l, lang),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium,
                  ),
                  subtitle: Text(
                    [
                      if (d.day != null) l.classroomDayN(d.day!.order),
                      l.classesTopicQuestions(d.questions.length),
                    ].join(' · '),
                    style: text.bodySmall,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// Manba bloki: sarlavha, izoh, “Hammasini tanlash” va mavzular.
class _SourcePanel extends StatelessWidget {
  const _SourcePanel({
    super.key,
    required this.title,
    required this.caption,
    required this.allKey,
    required this.allSelected,
    required this.onAll,
    required this.children,
  });

  final String title;
  final String caption;
  final String allKey;
  final bool allSelected;
  final VoidCallback onAll;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: LgPanel(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: text.titleMedium),
            const SizedBox(height: 2),
            Text(caption, style: text.bodySmall),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: LgChoiceChip(
                key: ValueKey(allKey),
                label: l.generalSelectAll,
                selected: allSelected,
                onTap: onAll,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
