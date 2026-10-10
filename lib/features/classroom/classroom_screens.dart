import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/backend/backend_models.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../content/ui/content_widgets.dart';
import '../learn/classes_screens.dart';
import '../learn/exam_question.dart';
import '../learn/exam_widgets.dart';
import '../reference/reference_content.dart';
import '../toifa/toifa_bank.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart' show calcRoute, calcTitle;
import '../tools/manual_calc_info.dart';
import '../tools/manual_calc_screens.dart';
import 'classroom_local.dart';
import 'curriculum.dart';
import 'topic_questions.dart';

// Guruh darslari o'quv dasturi bo'yicha: jadval (hafta/kun → mavzu →
// holat), mavzu sahifasi (ma'ruza → og'zaki savol-javob → test), ustoz
// natijalar paneli (mavjud topshiriq ekrani). Har amal serverda
// tekshiriladi; server ulanmagan buildda ClassesGate halol holatni
// ko'rsatadi. Ma'ruza rejimi serversiz ishlaydi (lecture_screens.dart).

String _lang(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

String _day(BuildContext context, DateTime d) =>
    DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).format(d);

/// O'quv dasturi yuklanguncha — holat; asset yo'q — halol “qo'shilmagan”.
class CurriculumGate extends StatefulWidget {
  const CurriculumGate({super.key, required this.builder});

  final Widget Function(BuildContext context, Curriculum curriculum) builder;

  @override
  State<CurriculumGate> createState() => _CurriculumGateState();
}

class _CurriculumGateState extends State<CurriculumGate> {
  @override
  void initState() {
    super.initState();
    unawaited(context.services.curriculum.ensureLoaded());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.services.curriculum;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final cur = c.curriculum;
        if (cur != null) return widget.builder(context, cur);
        return switch (c.state) {
          CurriculumState.missing => LgStateView(
            kind: StateKind.empty,
            title: l.classroomNoCurriculumTitle,
            message: l.classroomNoCurriculumBody,
          ),
          CurriculumState.error => LgStateView(
            kind: StateKind.error,
            title: l.classroomCurriculumError,
          ),
          _ => LgStateView(kind: StateKind.loading, title: l.classesLoading),
        };
      },
    );
  }
}

/// Mavzu holati jadvalda: o'tildi / savol-javob / test.
enum TopicStatus { closed, opened, lectured, oral, testRunning, testDone }

TopicStatus topicStatus(GroupTopic? t, GroupAssignment? test, DateTime now) {
  if (t == null) return TopicStatus.closed;
  if (test != null) {
    final due = test.dueAt;
    return due != null && !due.isAfter(now)
        ? TopicStatus.testDone
        : TopicStatus.testRunning;
  }
  if (t.oralDoneAt != null) return TopicStatus.oral;
  if (t.lectureDoneAt != null) return TopicStatus.lectured;
  return TopicStatus.opened;
}

(String, LgTone) topicStatusLabel(TopicStatus s, AppLocalizations l) =>
    switch (s) {
      TopicStatus.closed => (l.classroomStatusClosed, LgTone.neutral),
      TopicStatus.opened => (l.classroomStatusOpened, LgTone.warning),
      TopicStatus.lectured => (l.classroomStatusLectured, LgTone.brand),
      TopicStatus.oral => (l.classroomStatusOral, LgTone.brand),
      TopicStatus.testRunning => (l.classroomStatusTestRunning, LgTone.warning),
      TopicStatus.testDone => (l.classroomStatusTestDone, LgTone.brand),
    };

String topicTypeLabel(CurriculumTopicType t, AppLocalizations l) => switch (t) {
  CurriculumTopicType.lecture => l.classroomTypeLecture,
  CurriculumTopicType.practical => l.classroomTypePractical,
  CurriculumTopicType.seminar => l.classroomTypeSeminar,
  CurriculumTopicType.attestation => l.classroomTypeAttestation,
  CurriculumTopicType.other => l.classroomTypeOther,
};

/// Jadval sanasi: fayldagi sana yoki guruh boshlanishidan (taxminiy).
DateTime? topicDate(CurriculumTopic t, DateTime? start) =>
    t.date ?? (start == null ? null : studyDayDate(start, t.order));

String topicMeta(BuildContext context, CurriculumTopic t, {DateTime? start}) {
  final l = AppLocalizations.of(context);
  final date = topicDate(t, start);
  return [
    l.classroomDayN(t.order),
    if (t.week != null) l.classroomWeekN(t.week!),
    if (date != null) _day(context, date),
    topicTypeLabel(t.type, l),
    if (t.hours != null) l.classroomHours(t.hours!),
  ].join(' · ');
}

class _PlanData {
  _PlanData(
    this.group,
    this.topics,
    this.assignments,
    this.submissions,
    this.members,
  );

  final StudyGroup group;
  final Map<String, GroupTopic> topics;
  final List<GroupAssignment> assignments;
  final List<GroupSubmission> submissions;
  final List<GroupMember> members;

  GroupAssignment? testOf(String topicId) {
    final id = topics[topicId]?.testAssignmentId;
    return id == null ? null : assignments.where((a) => a.id == id).firstOrNull;
  }

  List<GroupMember> get students => [
    for (final m in members)
      if (!m.isTeacher) m,
  ];
}

Future<_PlanData?> _loadPlan(AppServices services, String groupId) async {
  final backend = services.backend;
  final group = (await backend.myGroups())
      .where((g) => g.id == groupId)
      .firstOrNull;
  if (group == null) return null;
  final r = await Future.wait([
    backend.groupTopics(groupId),
    backend.assignments(groupId),
    backend.groupSubmissions(groupId),
    backend.groupMembers(groupId),
  ]);
  return _PlanData(
    group,
    {for (final t in r[0] as List<GroupTopic>) t.topicId: t},
    r[1] as List<GroupAssignment>,
    r[2] as List<GroupSubmission>,
    r[3] as List<GroupMember>,
  );
}

/// Server ma'lumoti bilan sahifa: yuklash, xato/qayta urinish, guruh yo'q.
mixin _PlanLoader<T extends StatefulWidget> on State<T> {
  String get groupId;
  _PlanData? data;
  Object? error;
  bool missing = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => reload());
  }

  Future<void> reload() async {
    final services = context.services;
    if (!mounted ||
        _loading ||
        !services.backend.isConfigured ||
        !services.auth.hasAccount) {
      return;
    }
    _loading = true;
    setState(() => error = null);
    try {
      final d = await _loadPlan(services, groupId);
      if (!mounted) return;
      setState(() {
        data = d;
        missing = d == null;
      });
    } on Object catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      _loading = false;
    }
  }

  Widget loaded(Widget Function(_PlanData d) builder) {
    final l = AppLocalizations.of(context);
    if (missing) {
      return LgStateView(
        kind: StateKind.empty,
        title: l.classesGroupMissing,
        actionLabel: l.classesBackToList,
        onAction: () => context.go('/learn/classes'),
      );
    }
    if (error != null) {
      return LgStateView(
        kind:
            error is BackendException &&
                (error! as BackendException).failure == BackendFailure.network
            ? StateKind.offline
            : StateKind.error,
        title: classesErrorText(error!, l),
        actionLabel: l.actionRetry,
        onAction: reload,
      );
    }
    final d = data;
    if (d == null) {
      return LgStateView(kind: StateKind.loading, title: l.classesLoading);
    }
    return builder(d);
  }

  Future<void> act(Future<void> Function() run) async {
    final l = AppLocalizations.of(context);
    try {
      await run();
    } on Object catch (e) {
      if (mounted) showSnack(context, classesErrorText(e, l));
    }
    if (mounted) await reload();
  }

  Future<void> open(String location) async {
    await context.push(location);
    if (mounted) await reload();
  }
}

// ------------------------------------------------------------- jadval

class GroupPlanScreen extends StatefulWidget {
  const GroupPlanScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupPlanScreen> createState() => _GroupPlanScreenState();
}

class _GroupPlanScreenState extends State<GroupPlanScreen>
    with _PlanLoader<GroupPlanScreen> {
  @override
  String get groupId => widget.groupId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final teacher = data?.group.isTeacher ?? true;
    return LgPage(
      title: teacher ? l.classroomPlanTitle : l.classroomTopicsTitle,
      subtitle: data?.group.name,
      showProfile: false,
      children: [
        ClassesGate(
          child: CurriculumGate(
            builder: (context, cur) => loaded(
              (d) => d.group.isTeacher ? _teacher(d, cur) : _student(d, cur),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickStart(DateTime? current) async {
    final local = context.services.classroom;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) await local.setStartDate(widget.groupId, picked);
  }

  Widget _teacher(_PlanData d, Curriculum cur) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final local = context.services.classroom;
    final now = context.services.exams.now();
    return ListenableBuilder(
      listenable: local,
      builder: (context, _) {
        final start = local.startDate(widget.groupId);
        final done = cur.topics
            .where(
              (t) =>
                  topicStatus(d.topics[t.id], d.testOf(t.id), now) ==
                  TopicStatus.testDone,
            )
            .length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LgPanel(
              soft: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LgEyebrow(l.classroomProgramEyebrow),
                  Text(cur.name.of(_lang(context)), style: text.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    l.classroomPlanProgress(done, cur.topics.length),
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    start == null
                        ? l.classroomStartNone
                        : l.classroomStartAt(_day(context, start)),
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(l.classroomStartNote, style: text.bodySmall),
                  const SizedBox(height: 10),
                  LgButton.secondary(
                    label: l.classroomStartPick,
                    icon: Icons.event_outlined,
                    onPressed: () => _pickStart(start),
                  ),
                ],
              ),
            ),
            for (final m in cur.modules) ...[
              LgSectionTitle(m.title.of(_lang(context))),
              for (final (i, t) in m.topics.indexed)
                _TopicRow(
                  topic: t,
                  meta: topicMeta(context, t, start: start),
                  status: topicStatus(d.topics[t.id], d.testOf(t.id), now),
                  divider: i < m.topics.length - 1,
                  onTap: () =>
                      open('/learn/classes/g/${widget.groupId}/t/${t.id}'),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _student(_PlanData d, Curriculum cur) {
    final l = AppLocalizations.of(context);
    final now = context.services.exams.now();
    final opened = [
      for (final t in cur.topics)
        if (d.topics.containsKey(t.id)) t,
    ];
    if (opened.isEmpty) {
      return LgStateView(
        kind: StateKind.empty,
        title: l.classroomNoTopicsStudent,
        message: l.classroomNoTopicsStudentBody,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, t) in opened.indexed)
          _TopicRow(
            topic: t,
            meta: topicMeta(context, t),
            status: topicStatus(d.topics[t.id], d.testOf(t.id), now),
            divider: i < opened.length - 1,
            onTap: () => open('/learn/classes/g/${widget.groupId}/t/${t.id}'),
          ),
      ],
    );
  }
}

/// Jadval qatori: mavzu nomi, kun/hafta/sana va holat belgisi
/// pastma-past (tor ekranda siqilmaydi).
class _TopicRow extends StatelessWidget {
  const _TopicRow({
    required this.topic,
    required this.meta,
    required this.status,
    required this.divider,
    required this.onTap,
  });

  final CurriculumTopic topic;
  final String meta;
  final TopicStatus status;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final (label, tone) = topicStatusLabel(status, l);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? Border(bottom: BorderSide(color: p.line.withValues(alpha: 0.7)))
            : null,
      ),
      child: LgPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title.of(_lang(context)),
                      style: text.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(meta, style: text.bodySmall!.copyWith(fontSize: 13)),
                    const SizedBox(height: 6),
                    LgTag(label, tone: tone),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              ExcludeSemantics(
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: p.sub,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------- mavzu sahifasi

class GroupTopicScreen extends StatefulWidget {
  const GroupTopicScreen({
    super.key,
    required this.groupId,
    required this.topicId,
  });

  final String groupId;
  final String topicId;

  @override
  State<GroupTopicScreen> createState() => _GroupTopicScreenState();
}

class _GroupTopicScreenState extends State<GroupTopicScreen>
    with _PlanLoader<GroupTopicScreen> {
  @override
  String get groupId => widget.groupId;

  String get _base => '/learn/classes/g/${widget.groupId}/t/${widget.topicId}';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cur = context.services.curriculum.curriculum;
    final topic = cur?.topic(widget.topicId);
    return LgPage(
      title: topic?.title.of(_lang(context)) ?? l.classroomTopicTitle,
      subtitle: data?.group.name,
      showProfile: false,
      children: [
        ClassesGate(
          child: CurriculumGate(
            builder: (context, cur) {
              final t = cur.topic(widget.topicId);
              if (t == null) {
                return LgStateView(
                  kind: StateKind.empty,
                  title: l.classroomTopicMissing,
                );
              }
              return loaded(
                (d) => d.group.isTeacher
                    ? _teacher(d, cur, t)
                    : _student(d, cur, t),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _header(Curriculum cur, CurriculumTopic t, {DateTime? start}) {
    final text = Theme.of(context).textTheme;
    final module = cur.moduleOf(t);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (module != null) LgEyebrow(module.title.of(_lang(context))),
        Text(topicMeta(context, t, start: start), style: text.bodyMedium),
      ],
    );
  }

  Widget _teacher(_PlanData d, Curriculum cur, CurriculumTopic t) {
    final l = AppLocalizations.of(context);
    final services = context.services;
    final text = Theme.of(context).textTheme;
    final gt = d.topics[t.id];
    final test = d.testOf(t.id);
    final now = services.exams.now();
    final status = topicStatus(gt, test, now);
    final students = d.students;
    final submitted = test == null
        ? 0
        : {
            for (final s in d.submissions)
              if (s.assignmentId == test.id) s.userId,
          }.where((u) => students.any((m) => m.userId == u)).length;
    final asked = services.classroom.askedCount(widget.groupId, t.id);
    final (label, tone) = topicStatusLabel(status, l);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(cur, t, start: services.classroom.startDate(widget.groupId)),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: LgTag(label, tone: tone),
        ),
        if (gt == null) ...[
          const SizedBox(height: 12),
          Text(l.classroomOpenNote, style: text.bodyMedium),
          const SizedBox(height: 10),
          LgButton(
            label: l.classroomOpenTopic,
            icon: Icons.lock_open_rounded,
            onPressed: () =>
                act(() => services.backend.openTopic(widget.groupId, t.id)),
          ),
        ],
        // 1. Ma'ruza (taqdimot rejimi — serversiz ham ishlaydi).
        _StageCard(
          step: 1,
          title: l.classroomStageLecture,
          body: l.classroomStageLectureBody,
          done: gt?.lectureDoneAt != null,
          children: [
            LgButton(
              label: l.lectureStart,
              icon: Icons.slideshow_outlined,
              onPressed: () =>
                  context.push('/learn/lecture/${t.id}?g=${widget.groupId}'),
            ),
            if (gt?.lectureDoneAt == null) ...[
              const SizedBox(height: 8),
              LgButton.secondary(
                label: l.classroomMarkDone,
                icon: Icons.check_rounded,
                onPressed: () => act(
                  () => services.backend.markTopicStage(
                    widget.groupId,
                    t.id,
                    TopicStage.lecture,
                  ),
                ),
              ),
            ],
          ],
        ),
        // 2. Og'zaki savol-javob (baholar faqat ustoz qurilmasida).
        _StageCard(
          step: 2,
          title: l.classroomStageOral,
          body: l.classroomStageOralBody(asked),
          done: gt?.oralDoneAt != null,
          children: [
            LgButton(
              label: l.classroomOralOpen,
              icon: Icons.record_voice_over_outlined,
              onPressed: () => open('$_base/oral'),
            ),
            if (gt?.oralDoneAt == null) ...[
              const SizedBox(height: 8),
              LgButton.secondary(
                label: l.classroomMarkDone,
                icon: Icons.check_rounded,
                onPressed: () => act(
                  () => services.backend.markTopicStage(
                    widget.groupId,
                    t.id,
                    TopicStage.oral,
                  ),
                ),
              ),
            ],
          ],
        ),
        // 3. Guruh testi.
        _StageCard(
          step: 3,
          title: l.classroomStageTest,
          body: test == null
              ? l.classroomStageTestBody
              : l.classroomTestSubmitted(submitted, students.length),
          done: status == TopicStatus.testDone,
          children: [
            if (test == null)
              LgButton(
                label: l.classroomTestPrepare,
                icon: Icons.quiz_outlined,
                onPressed: () => open('$_base/test'),
              )
            else ...[
              LgButton(
                label: l.classroomTestResults,
                icon: Icons.insights_outlined,
                onPressed: () =>
                    open('/learn/classes/g/${widget.groupId}/a/${test.id}'),
              ),
              if (status == TopicStatus.testRunning) ...[
                const SizedBox(height: 8),
                LgButton.secondary(
                  label: l.classroomTestFinish,
                  icon: Icons.stop_circle_outlined,
                  onPressed: () => _finishTest(t),
                ),
              ],
            ],
          ],
        ),
        LgSectionTitle(l.classroomMaterials),
        TopicMaterials(topic: t),
      ],
    );
  }

  Future<void> _finishTest(CurriculumTopic t) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.classroomTestFinishTitle,
      body: l.classroomTestFinishBody,
      action: l.classroomTestFinish,
    );
    if (!ok || !mounted) return;
    final backend = context.services.backend;
    await act(() => backend.finishTopicTest(widget.groupId, t.id));
  }

  Widget _student(_PlanData d, Curriculum cur, CurriculumTopic t) {
    final l = AppLocalizations.of(context);
    final services = context.services;
    if (!d.topics.containsKey(t.id)) {
      return LgStateView(
        kind: StateKind.empty,
        title: l.classroomTopicNotOpened,
      );
    }
    final test = d.testOf(t.id);
    final me = services.backend.userId;
    final mine = test == null
        ? null
        : d.submissions
              .where((s) => s.assignmentId == test.id && s.userId == me)
              .firstOrNull;
    final due = test?.dueAt;
    final closed = due != null && !due.isAfter(services.exams.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(cur, t),
        LgSectionTitle(l.classroomMaterials),
        TopicMaterials(topic: t),
        LgSectionTitle(l.classroomStageTest),
        if (test == null)
          Text(
            l.classroomTestNotStarted,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          LgRow(
            title: test.title,
            subtitle: mine != null
                ? l.classesStatusDone(mine.score, mine.total)
                : closed
                ? l.classroomStatusTestDone
                : l.classroomTestOpenStudent,
            icon: mine != null
                ? Icons.task_alt_rounded
                : Icons.assignment_outlined,
            divider: false,
            onTap: () =>
                open('/learn/classes/g/${widget.groupId}/a/${test.id}'),
          ),
      ],
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.step,
    required this.title,
    required this.body,
    required this.done,
    required this.children,
  });

  final int step;
  final String title;
  final String body;
  final bool done;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LgPanel(
      margin: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgEyebrow(l.classroomStep(step)),
          Text(title, style: text.titleMedium),
          const SizedBox(height: 4),
          Text(body, style: text.bodyMedium),
          if (done) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: LgTag(l.classroomStageDone, icon: Icons.check_rounded),
            ),
          ],
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- materiallar

/// Mavzuga bog'langan ilova materiallari (kartalar, jadvallar, atlas,
/// kalkulyatorlar). Ilovada yo'q id lar ko'rsatilmaydi.
class TopicMaterials extends StatefulWidget {
  const TopicMaterials({super.key, required this.topic});

  final CurriculumTopic topic;

  @override
  State<TopicMaterials> createState() => _TopicMaterialsState();
}

class _TopicMaterialsState extends State<TopicMaterials> {
  @override
  void initState() {
    super.initState();
    if (widget.topic.links.microscopy.isNotEmpty) {
      unawaited(context.services.microscopy.ensureAtlas());
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    return ListenableBuilder(
      listenable: Listenable.merge([services.content, services.microscopy]),
      builder: (context, _) {
        final items = topicMaterialItems(context, widget.topic);
        final l = AppLocalizations.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.topic.links.gap)
              LgNotice(l.classroomGapNote, kind: NoticeKind.info),
            if (items.isEmpty)
              Text(
                l.classroomNoMaterials,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (final (i, m) in items.indexed)
                LgRow(
                  title: m.title,
                  subtitle: m.kind,
                  icon: m.icon,
                  divider: i < items.length - 1,
                  onTap: () => context.push(m.route),
                ),
          ],
        );
      },
    );
  }
}

@immutable
class TopicMaterial {
  const TopicMaterial({
    required this.title,
    required this.kind,
    required this.icon,
    required this.route,
    this.summary,
  });

  final String title;
  final String kind;
  final IconData icon;
  final String route;

  /// Ma'ruza slaydida qisqa izoh (bo'lsa).
  final String? summary;
}

/// Ilova ichida topilgan materiallar (tartib: kartalar, holatlar, jadvallar,
/// atlas, kalkulyatorlar).
List<TopicMaterial> topicMaterialItems(
  BuildContext context,
  CurriculumTopic t,
) {
  final l = AppLocalizations.of(context);
  final lang = _lang(context);
  final pack = context.services.content.pack;
  final atlas = context.services.microscopy.atlas;
  final out = <TopicMaterial>[];
  for (final id in t.links.analytes) {
    final a = pack?.analyte(id);
    if (a == null) continue;
    out.add(
      TopicMaterial(
        title: a.names.of(lang),
        kind: l.classroomKindAnalyte,
        icon: Icons.science_outlined,
        route: '/tests/analyte/$id',
        summary: a.tagline?.of(lang),
      ),
    );
  }
  for (final id in t.links.conditions) {
    final c = pack?.condition(id);
    if (c == null) continue;
    out.add(
      TopicMaterial(
        title: c.names.of(lang),
        kind: l.classroomKindCondition,
        icon: Icons.medical_information_outlined,
        route: '/tests/conditions/$id',
      ),
    );
  }
  for (final id in t.links.reference) {
    final r = refTopic(id);
    if (r == null) continue;
    out.add(
      TopicMaterial(
        title: r.title.of(lang),
        kind: l.classroomKindReference,
        icon: Icons.table_chart_outlined,
        route: '/learn/reference/$id',
        summary: r.summary.of(lang),
      ),
    );
  }
  for (final id in t.links.microscopy) {
    final s = atlas?.section(id);
    if (s == null) continue;
    out.add(
      TopicMaterial(
        title: s.name.of(lang),
        kind: l.classroomKindAtlas,
        icon: Icons.biotech_outlined,
        route: '/lab/microscopy/s/$id',
        summary: s.subtitle.of(lang),
      ),
    );
  }
  for (final path in t.links.tools) {
    final title = _toolTitle(path, l);
    if (title == null) continue;
    out.add(
      TopicMaterial(
        title: title,
        kind: l.classroomKindTool,
        icon: Icons.calculate_outlined,
        route: path,
      ),
    );
  }
  return out;
}

/// Ilovada mavjud asbob nomi (noma'lum manzil — null, ko'rsatilmaydi).
String? _toolTitle(String path, AppLocalizations l) {
  const calc = '/lab/calculators/';
  if (path.startsWith(calc)) {
    final slug = path.substring(calc.length);
    for (final c in ClinicalCalc.values) {
      if (calcRoute(c) == slug) return calcTitle(c, l);
    }
    for (final c in ManualCalc.values) {
      if (manualCalcRoute(c) == slug) return manualCalcTitle(c, l);
    }
    return null;
  }
  return switch (path) {
    '/lab/qc' => l.classroomToolQc,
    '/lab/preanalytics' => l.classroomToolPreanalytics,
    '/lab/instruments' => l.classroomToolInstruments,
    '/lab/calibration' => l.classroomToolCalibration,
    '/lab/differential' => l.classroomToolDifferential,
    _ => null,
  };
}

// -------------------------------------------------- og'zaki savol-javob

class TopicOralScreen extends StatefulWidget {
  const TopicOralScreen({
    super.key,
    required this.groupId,
    required this.topicId,
  });

  final String groupId;
  final String topicId;

  @override
  State<TopicOralScreen> createState() => _TopicOralScreenState();
}

class _TopicOralScreenState extends State<TopicOralScreen>
    with _PlanLoader<TopicOralScreen> {
  @override
  String get groupId => widget.groupId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.classroomStageOral,
      subtitle: context.services.curriculum.curriculum
          ?.topic(widget.topicId)
          ?.title
          .of(_lang(context)),
      showProfile: false,
      children: [
        ClassesGate(
          child: CurriculumGate(
            builder: (context, cur) {
              final t = cur.topic(widget.topicId);
              if (t == null) {
                return LgStateView(
                  kind: StateKind.empty,
                  title: l.classroomTopicMissing,
                );
              }
              return loaded((d) {
                if (!d.group.isTeacher) {
                  return LgStateView(
                    kind: StateKind.empty,
                    title: l.errForbidden,
                  );
                }
                return ToifaBankGate(
                  builder: (context, bank) => _body(d, t, bank),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _body(_PlanData d, CurriculumTopic t, ToifaBank bank) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final local = context.services.classroom;
    final qs = oralCandidates(t, bank);
    return ListenableBuilder(
      listenable: local,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgNotice(l.classroomOralNotice, kind: NoticeKind.info),
          if (qs.isEmpty)
            LgStateView(kind: StateKind.empty, title: l.classroomOralEmpty)
          else
            for (final (i, q) in [
              for (final o in qs)
                o.localized(Localizations.localeOf(context).languageCode),
            ].indexed)
              LgPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LgEyebrow(l.classroomCandidate(i + 1)),
                    Text(q.text, style: text.titleSmall),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: OfficialTextTag(),
                    ),
                    if (q.plan.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(l.classroomOralPlan, style: text.labelMedium),
                      for (final p in q.plan.take(4))
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text('• $p', style: text.bodySmall),
                        ),
                    ] else ...[
                      const SizedBox(height: 6),
                      Text(l.classroomOralNoPlan, style: text.bodySmall),
                    ],
                    // Panel foni ustida ink ko'rinsin.
                    Material(
                      type: MaterialType.transparency,
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(l.classroomOralAsked),
                        value: local.asked(widget.groupId, t.id, q.id),
                        onChanged: (v) => local.setAsked(
                          widget.groupId,
                          t.id,
                          q.id,
                          value: v ?? false,
                        ),
                      ),
                    ),
                    if (local.asked(widget.groupId, t.id, q.id) &&
                        d.students.isNotEmpty)
                      LgButton.link(
                        label: l.classroomOralGrade(
                          local.grades(widget.groupId, t.id, q.id).length,
                        ),
                        icon: Icons.rate_review_outlined,
                        onPressed: () => _grade(d, t, q),
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _grade(
    _PlanData d,
    CurriculumTopic t,
    ToifaOralQuestion q,
  ) async {
    final l = AppLocalizations.of(context);
    final local = context.services.classroom;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => ListenableBuilder(
        listenable: local,
        builder: (context, _) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                l.classroomOralGradeTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                l.classroomOralGradeNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              for (final m in d.students) ...[
                const SizedBox(height: 12),
                Text(
                  memberLabel(context, widget.groupId, m),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (g, label) in [
                      (OralGrade.knew, l.classroomGradeKnew),
                      (OralGrade.partial, l.classroomGradePartial),
                      (OralGrade.didNot, l.classroomGradeDidNot),
                    ])
                      LgChoiceChip(
                        label: label,
                        selected:
                            local.grade(widget.groupId, t.id, q.id, m.userId) ==
                            g,
                        onTap: () => local.setGrade(
                          widget.groupId,
                          t.id,
                          q.id,
                          m.userId,
                          local.grade(widget.groupId, t.id, q.id, m.userId) == g
                              ? null
                              : g,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ mavzu testi

class TopicTestSetupScreen extends StatefulWidget {
  const TopicTestSetupScreen({
    super.key,
    required this.groupId,
    required this.topicId,
  });

  final String groupId;
  final String topicId;

  @override
  State<TopicTestSetupScreen> createState() => _TopicTestSetupScreenState();
}

class _TopicTestSetupScreenState extends State<TopicTestSetupScreen>
    with _PlanLoader<TopicTestSetupScreen> {
  @override
  String get groupId => widget.groupId;

  static const _limits = [10, 15, 20, 30];
  final Set<String> _picked = {};
  int? _minutes = 15;
  bool _busy = false;
  bool _tried = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.classroomTestPrepare,
      subtitle: context.services.curriculum.curriculum
          ?.topic(widget.topicId)
          ?.title
          .of(_lang(context)),
      showProfile: false,
      children: [
        ClassesGate(
          child: CurriculumGate(
            builder: (context, cur) {
              final t = cur.topic(widget.topicId);
              if (t == null) {
                return LgStateView(
                  kind: StateKind.empty,
                  title: l.classroomTopicMissing,
                );
              }
              return loaded((d) {
                if (!d.group.isTeacher) {
                  return LgStateView(
                    kind: StateKind.empty,
                    title: l.errForbidden,
                  );
                }
                if (d.testOf(t.id) != null) {
                  return LgStateView(
                    kind: StateKind.success,
                    title: l.classroomTestAlready,
                  );
                }
                return ContentGate(
                  builder: (context, pack) => ToifaBankGate(
                    builder: (context, bank) => _form(t, pack, bank),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Future<void> _start(CurriculumTopic t, List<ExamQuestion> pool) async {
    setState(() => _tried = true);
    final chosen = [
      for (final q in pool)
        if (_picked.contains(q.id)) q,
    ];
    if (chosen.isEmpty || chosen.length > 50) return;
    final l = AppLocalizations.of(context);
    final services = context.services;
    setState(() => _busy = true);
    try {
      await services.backend.startTopicTest(
        groupId: widget.groupId,
        topicId: t.id,
        title: l.classroomTestTitle(t.title.of(_lang(context))),
        questionIds: [for (final q in chosen) q.id],
        correctIndexes: [for (final q in chosen) q.correct.single],
        timeLimitMinutes: _minutes,
      );
      if (!mounted) return;
      showSnack(context, l.classroomTestStarted);
      context.pop();
    } on Object catch (e) {
      if (mounted) showSnack(context, classesErrorText(e, l));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _form(CurriculumTopic t, ContentPack pack, ToifaBank bank) {
    final l = AppLocalizations.of(context);
    final lang = _lang(context);
    final text = Theme.of(context).textTheme;
    final pool = testCandidates(t, pack, bank);
    if (pool.isEmpty) {
      return LgStateView(
        kind: StateKind.empty,
        title: l.classroomTestNoCandidates,
        message: l.classroomTestNoCandidatesBody,
      );
    }
    final count = pool.where((q) => _picked.contains(q.id)).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgNotice(l.classroomCandidatesNotice, kind: NoticeKind.warning),
        LgSectionTitle(l.classesTimeLimit),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in _limits)
              LgChoiceChip(
                label: l.examMinutes(m),
                selected: _minutes == m,
                onTap: () => setState(() => _minutes = m),
              ),
            LgChoiceChip(
              label: l.classesNoLimit,
              selected: _minutes == null,
              onTap: () => setState(() => _minutes = null),
            ),
          ],
        ),
        LgSectionTitle(
          l.classroomCandidatesTitle(count, pool.length),
          trailing: TextButton(
            onPressed: () => setState(() {
              if (count == pool.length) {
                _picked.clear();
              } else {
                _picked.addAll(pool.take(50).map((q) => q.id));
              }
            }),
            child: Text(
              count == pool.length ? l.classroomPickNone : l.classroomPickAll,
            ),
          ),
        ),
        for (final (i, q) in pool.indexed)
          Material(
            type: MaterialType.transparency,
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _picked.contains(q.id),
              onChanged: (v) => setState(() {
                v == true ? _picked.add(q.id) : _picked.remove(q.id);
              }),
              title: Text(
                '${i + 1}. ${q.prompt(lang)}',
                style: text.bodyMedium,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.classroomKeyShown(q.option(q.correct.single, lang)),
                    style: text.bodySmall,
                  ),
                  if (q.officialKeyCheck?.flagged ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: LgTag(
                        l.classroomKeyFlagged,
                        tone: LgTone.warning,
                        icon: Icons.flag_outlined,
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (_tried && count == 0)
          LgNotice(l.classroomPickAtLeastOne, kind: NoticeKind.error),
        if (count > 50) LgNotice(l.classroomPickMax, kind: NoticeKind.error),
        const SizedBox(height: 16),
        LgButton(
          label: l.classroomTestStart(count),
          icon: Icons.play_arrow_rounded,
          busy: _busy,
          onPressed: () => _start(t, pool),
        ),
      ],
    );
  }
}
