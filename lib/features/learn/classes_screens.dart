import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/backend/backend_models.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../content/ui/content_widgets.dart';
import '../settings/settings_controller.dart';
import '../support/support_screens.dart' show formatWhen;
import 'exam_question.dart';
import 'exam_session.dart';
import 'exam_widgets.dart';

// Ustoz–talaba guruhlari. Har amal serverda tekshiriladi (RLS + funksiyalar):
// guruhni yaratgan hisob — o'sha guruh ustozi; ilovadagi “Ustoz” roli hech
// qanday server huquqi bermaydi. Server ulanmagan buildda — halol holat.

String classesErrorText(Object e, AppLocalizations l) => switch (e) {
  BackendException(failure: BackendFailure.network) => l.errNetwork,
  BackendException(failure: BackendFailure.rateLimited) => l.errRateLimited,
  BackendException(failure: BackendFailure.invalid) => l.classesInvalid,
  BackendException(failure: BackendFailure.notFound) => l.classesCodeNotFound,
  BackendException(failure: BackendFailure.forbidden) => l.errForbidden,
  BackendException(failure: BackendFailure.unauthorized) => l.errSessionExpired,
  BackendException(failure: BackendFailure.unavailable) =>
    l.classesUnavailableTitle,
  _ => l.errGeneric,
};

/// Server ulanmagan — halol holat; hisob yo'q — kirish taklifi.
class ClassesGate extends StatelessWidget {
  const ClassesGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final services = context.services;
    if (!services.backend.isConfigured) {
      return LgStateView(
        kind: StateKind.unavailable,
        title: l.classesUnavailableTitle,
        message: l.classesUnavailableBody,
        secondary: LgButton.secondary(
          label: l.classesTryExam,
          icon: Icons.timer_outlined,
          onPressed: () => context.push('/learn/exam'),
        ),
      );
    }
    return ListenableBuilder(
      listenable: services.auth,
      builder: (context, _) => services.auth.hasAccount
          ? child
          : LgStateView(
              kind: StateKind.empty,
              title: l.classesSignInTitle,
              message: l.classesSignInBody,
              actionLabel: l.classesSignIn,
              onAction: () => context.push('/profile/auth'),
            ),
    );
  }
}

/// Server so'rovi holati: yuklanmoqda / xato (qayta urinish) / ma'lumot.
class _Loaded<T> {
  T? data;
  Object? error;
  bool loading = false;
}

Widget _loadState<T>(
  BuildContext context,
  _Loaded<T> s,
  VoidCallback retry,
  Widget Function(T data) builder,
) {
  final l = AppLocalizations.of(context);
  if (s.error != null) {
    return LgStateView(
      kind:
          s.error is BackendException &&
              (s.error! as BackendException).failure == BackendFailure.network
          ? StateKind.offline
          : StateKind.error,
      title: classesErrorText(s.error!, l),
      actionLabel: l.actionRetry,
      onAction: retry,
    );
  }
  final data = s.data;
  if (data == null) {
    return LgStateView(kind: StateKind.loading, title: l.classesLoading);
  }
  return builder(data);
}

/// Paket savollari id bo'yicha (topshiriqlar faqat paket savollaridan).
Map<String, ExamQuestion> _byId(ContentPack pack) => {
  for (final q in PackQuestionSource.of(pack).questions) q.id: q,
};

/// Topshiriq uchun savollar: server kaliti har savolga bitta javob saqlaydi.
List<ExamQuestion> _assignablePool(ContentPack pack, Set<String> topics) => [
  for (final q in examPool(PackQuestionSource.of(pack), topics))
    if (q.correct.length == 1) q,
];

bool _ready(BuildContext context) =>
    context.services.backend.isConfigured && context.services.auth.hasAccount;

/// Hisob almashsa (chiqib, boshqasi bilan kirilsa) sahifa ma'lumoti qayta
/// yuklanadi — oldingi hisobniki ko'rinib qolmasin.
mixin _AccountReload<T extends StatefulWidget> on State<T> {
  String? _uid;
  bool _uidSeen = false;

  void resetForAccount();
  Future<void> reloadForAccount();

  Widget watchAccount(Widget Function(BuildContext context) builder) =>
      ListenableBuilder(
        listenable: context.services.auth,
        builder: (context, _) {
          final uid = context.services.backend.userId;
          if (_uidSeen && uid != _uid) {
            resetForAccount();
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => reloadForAccount(),
            );
          }
          _uidSeen = true;
          _uid = uid;
          return builder(context);
        },
      );
}

// ------------------------------------------------------------ guruhlar ro'yxati

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final _groups = _Loaded<List<StudyGroup>>();
  /// Ro'yxat qaysi hisob uchun yuklangan (hisob almashsa — qayta).
  String? _loadedFor = '';

  Future<void> _load() async {
    if (!_ready(context) || _groups.loading) return;
    setState(() {
      _groups
        ..loading = true
        ..error = null;
    });
    try {
      final g = await context.services.backend.myGroups();
      if (mounted) setState(() => _groups.data = g);
    } on Object catch (e) {
      if (mounted) setState(() => _groups.error = e);
    } finally {
      if (mounted) setState(() => _groups.loading = false);
    }
  }

  Future<void> _open(String location) async {
    await context.push(location);
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = context.services.auth;
    return LgPage(
      title: l.classesTitle,
      subtitle: l.classesSubtitle,
      children: [
        ClassesGate(
          child: ListenableBuilder(
            listenable: auth,
            builder: (context, _) {
              // Kirish/chiqish yoki hisob almashganda qayta yuklanadi.
              final uid = context.services.backend.userId;
              if (_loadedFor != uid) {
                _loadedFor = uid;
                _groups
                  ..data = null
                  ..error = null;
                WidgetsBinding.instance.addPostFrameCallback((_) => _load());
              }
              return _body(context, l);
            },
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, AppLocalizations l) {
    final text = Theme.of(context).textTheme;
    final teacherFirst = context.services.settings.role == AppRole.teacher;
    final create = LgTile(
      title: l.classesCreate,
      caption: l.classesCreateSub,
      icon: Icons.school_outlined,
      highlighted: teacherFirst,
      onTap: () => _open('/learn/classes/new'),
    );
    final join = LgTile(
      title: l.classesJoin,
      caption: l.classesJoinSub,
      icon: Icons.vpn_key_outlined,
      highlighted: !teacherFirst,
      onTap: () => _open('/learn/classes/join'),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        LgTwoColumnGrid(
          children: teacherFirst ? [create, join] : [join, create],
        ),
        Text(l.classesRoleNote, style: text.bodySmall),
        LgSectionTitle(l.classesMine),
        _loadState(context, _groups, _load, (groups) {
          if (groups.isEmpty) {
            return LgStateView(
              kind: StateKind.empty,
              title: l.classesEmpty,
              message: l.classesEmptyBody,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, g) in groups.indexed)
                LgRow(
                  title: g.name,
                  subtitle:
                      '${g.isTeacher ? l.classesRoleTeacher : l.classesRoleStudent}'
                      ' · ${l.classesMembers(g.memberCount)}',
                  icon: g.isTeacher
                      ? Icons.school_outlined
                      : Icons.groups_outlined,
                  divider: i < groups.length - 1,
                  onTap: () => _open('/learn/classes/g/${g.id}'),
                ),
            ],
          );
        }),
      ],
    );
  }
}

// ------------------------------------------------------- yaratish / qo'shilish

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _name = TextEditingController();
  final _display = TextEditingController();
  bool _tried = false;
  bool _busy = false;
  Object? _error;

  @override
  void dispose() {
    _name.dispose();
    _display.dispose();
    super.dispose();
  }

  bool _len(TextEditingController c, int min, int max) {
    final n = c.text.trim().length;
    return n >= min && n <= max;
  }

  Future<void> _submit() async {
    setState(() => _tried = true);
    if (!_len(_name, 3, 80) || !_len(_display, 2, 60)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final g = await context.services.backend.createGroup(
        _name.text.trim(),
        displayName: _display.text.trim(),
      );
      if (!mounted) return;
      showSnack(context, AppLocalizations.of(context).classesCreated);
      context.pushReplacement('/learn/classes/g/${g.id}');
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.classesCreate,
      subtitle: l.classesCreateIntro,
      showProfile: false,
      children: [
        ClassesGate(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LgField(
                label: l.classesGroupName,
                controller: _name,
                hint: l.classesGroupNameHint,
                maxLength: 80,
                textInputAction: TextInputAction.next,
                errorText: _tried && !_len(_name, 3, 80)
                    ? l.classesLengthError(3, 80)
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              LgField(
                label: l.classesDisplayName,
                controller: _display,
                hint: l.classesDisplayNameHintTeacher,
                maxLength: 60,
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                errorText: _tried && !_len(_display, 2, 60)
                    ? l.classesLengthError(2, 60)
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Text(
                l.classesDisplayNameNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_error != null)
                LgNotice(classesErrorText(_error!, l), kind: NoticeKind.error),
              const SizedBox(height: 16),
              LgButton(
                label: l.classesCreateAction,
                icon: Icons.add_rounded,
                busy: _busy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Taklif kodi: faqat ruxsat etilgan 32 belgi, katta harf.
class _CodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final clean = newValue.text.toUpperCase().replaceAll(
      RegExp('[^A-Z0-9]'),
      '',
    );
    final text = clean.length > 8 ? clean.substring(0, 8) : clean;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _code = TextEditingController();
  final _display = TextEditingController();
  bool _tried = false;
  bool _busy = false;
  Object? _error;

  @override
  void dispose() {
    _code.dispose();
    _display.dispose();
    super.dispose();
  }

  bool get _codeOk => _code.text.length == 8;
  bool get _nameOk {
    final n = _display.text.trim().length;
    return n >= 2 && n <= 60;
  }

  Future<void> _submit() async {
    setState(() => _tried = true);
    if (!_codeOk || !_nameOk) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final id = await context.services.backend.joinGroup(
        _code.text,
        displayName: _display.text.trim(),
      );
      if (!mounted) return;
      showSnack(context, AppLocalizations.of(context).classesJoined);
      context.pushReplacement('/learn/classes/g/$id');
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.classesJoin,
      subtitle: l.classesJoinIntro,
      showProfile: false,
      children: [
        ClassesGate(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Text(
                          l.classesCode,
                          style: text.titleSmall!.copyWith(fontSize: 14),
                        ),
                      ),
                      TextField(
                        controller: _code,
                        autocorrect: false,
                        enableSuggestions: false,
                        textCapitalization: TextCapitalization.characters,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [_CodeFormatter()],
                        style: text.headlineSmall!.copyWith(
                          letterSpacing: 4,
                          color: p.ink,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                        onChanged: (_) => setState(() => _error = null),
                        decoration: InputDecoration(
                          hintText: 'ABCD2345',
                          errorText: _tried && !_codeOk
                              ? l.classesCodeError
                              : null,
                          errorMaxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              LgField(
                label: l.classesDisplayName,
                controller: _display,
                hint: l.classesDisplayNameHint,
                maxLength: 60,
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                errorText: _tried && !_nameOk
                    ? l.classesLengthError(2, 60)
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Text(l.classesJoinNote, style: text.bodySmall),
              if (_error != null)
                LgNotice(classesErrorText(_error!, l), kind: NoticeKind.error),
              const SizedBox(height: 16),
              LgButton(
                label: l.classesJoinAction,
                icon: Icons.login_rounded,
                busy: _busy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ guruh

/// Guruh sahifasi uchun bir martada yuklanadigan ma'lumot.
class _GroupData {
  _GroupData(this.group, this.assignments, this.submissions, this.members);

  final StudyGroup group;
  final List<GroupAssignment> assignments;
  final List<GroupSubmission> submissions;
  final List<GroupMember> members;

  List<GroupMember> get students => [
    for (final m in members)
      if (!m.isTeacher) m,
  ];
}

Future<_GroupData?> _loadGroup(BuildContext context, String groupId) async {
  final backend = context.services.backend;
  final groups = await backend.myGroups();
  final group = groups.where((g) => g.id == groupId).firstOrNull;
  if (group == null) return null;
  final results = await Future.wait([
    backend.assignments(groupId),
    backend.groupSubmissions(groupId),
    backend.groupMembers(groupId),
  ]);
  return _GroupData(
    group,
    results[0] as List<GroupAssignment>,
    results[1] as List<GroupSubmission>,
    results[2] as List<GroupMember>,
  );
}

enum _StudentStatus { fresh, inProgress, pending, done, overdue }

_StudentStatus _statusFor(
  BuildContext context,
  GroupAssignment a,
  GroupSubmission? mine,
) {
  final services = context.services;
  if (mine != null) return _StudentStatus.done;
  final local = services.exams.assignmentSession(a.id, services.backend.userId);
  if (local != null) {
    return local.finished ? _StudentStatus.pending : _StudentStatus.inProgress;
  }
  final due = a.dueAt;
  if (due != null && services.exams.now().isAfter(due)) {
    return _StudentStatus.overdue;
  }
  return _StudentStatus.fresh;
}

String _assignmentMeta(BuildContext context, GroupAssignment a) {
  final l = AppLocalizations.of(context);
  return [
    l.quizQuestionCount(a.questionIds.length),
    if (a.timeLimitMinutes != null) l.examMinutes(a.timeLimitMinutes!),
    a.dueAt == null
        ? l.classesNoDue
        : l.classesDue(formatWhen(a.dueAt!, context)),
  ].join(' · ');
}

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> with _AccountReload {
  final _data = _Loaded<_GroupData>();
  bool _missing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted || !_ready(context)) return;
    setState(() {
      _data
        ..loading = true
        ..error = null;
    });
    try {
      final d = await _loadGroup(context, widget.groupId);
      if (!mounted) return;
      setState(() {
        _missing = d == null;
        _data.data = d;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _data.error = e);
    } finally {
      if (mounted) setState(() => _data.loading = false);
    }
  }

  Future<void> _open(String location) async {
    await context.push(location);
    if (mounted) await _load();
  }

  @override
  void resetForAccount() {
    _data
      ..data = null
      ..error = null;
    _missing = false;
  }

  @override
  Future<void> reloadForAccount() => _load();

  @override
  Widget build(BuildContext context) => watchAccount(_page);

  Widget _page(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = _data.data;
    return LgPage(
      title: d?.group.name ?? l.classesTitle,
      subtitle: d == null
          ? null
          : d.group.isTeacher
          ? l.classesYouTeacher(d.group.memberCount)
          : l.classesYouStudent,
      showProfile: false,
      children: [
        ClassesGate(
          child: _missing
              ? LgStateView(
                  kind: StateKind.empty,
                  title: l.classesGroupMissing,
                  actionLabel: l.classesBackToList,
                  onAction: () => context.go('/learn/classes'),
                )
              : _loadState(
                  context,
                  _data,
                  _load,
                  (d) => d.group.isTeacher ? _teacher(d) : _student(d),
                ),
        ),
      ],
    );
  }

  Widget _teacher(_GroupData d) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final students = d.students;
    // Talaba yo'q — birinchi ish kodni yuborish; keyin esa topshiriqlar va
    // natijalar oldinda, kod pastda.
    final inviteFirst = students.isEmpty;
    final assignments = [
      LgSectionTitle(l.classesAssignments),
      LgButton(
        label: l.classesNewAssignment,
        icon: Icons.add_task_rounded,
        onPressed: () => _open('/learn/classes/g/${d.group.id}/assign'),
      ),
      const SizedBox(height: 6),
      if (d.assignments.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(l.classesNoAssignmentsTeacher, style: text.bodyMedium),
        )
      else
        for (final (i, a) in d.assignments.indexed)
          () {
            final done = {
              for (final s in d.submissions)
                if (s.assignmentId == a.id) s.userId,
            }.where((u) => students.any((m) => m.userId == u)).length;
            return _AssignmentTile(
              assignment: a,
              icon: Icons.assignment_outlined,
              tag: students.isEmpty
                  ? null
                  : LgTag(
                      l.classesSubmittedOf(done, students.length),
                      tone: done == students.length
                          ? LgTone.brand
                          : LgTone.neutral,
                    ),
              divider: i < d.assignments.length - 1,
              onTap: () => _open('/learn/classes/g/${d.group.id}/a/${a.id}'),
            );
          }(),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (inviteFirst) _InviteCard(group: d.group),
        ...assignments,
        LgSectionTitle(l.classesMembersTitle(students.length)),
        if (students.isEmpty)
          Text(l.classesNoStudents, style: text.bodyMedium)
        else
          for (final (i, m) in students.indexed)
            () {
              final mine = [
                for (final s in d.submissions)
                  if (s.userId == m.userId) s,
              ];
              final avg = mine.isEmpty
                  ? null
                  : (mine.map((s) => s.percent).reduce((a, b) => a + b) /
                            mine.length)
                        .round();
              return LgRow(
                title: m.displayName,
                subtitle: avg == null
                    ? l.classesMemberNoWork
                    : l.classesMemberSummary(
                        mine.length,
                        d.assignments.length,
                        avg,
                      ),
                icon: Icons.person_outline_rounded,
                divider: i < students.length - 1,
                trailing: IconButton(
                  tooltip: l.classesRemove,
                  icon: const Icon(Icons.person_remove_outlined),
                  onPressed: () => _remove(d.group, m),
                ),
              );
            }(),
        if (!inviteFirst) ...[
          LgSectionTitle(l.classesInviteMore),
          _InviteCard(group: d.group),
        ],
      ],
    );
  }

  Future<void> _remove(StudyGroup g, GroupMember m) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.classesRemoveTitle(m.displayName),
      body: l.classesRemoveBody,
      action: l.classesRemoveAction,
    );
    if (!ok || !mounted) return;
    try {
      await context.services.backend.removeMember(g.id, m.userId);
      await _load();
    } on Object catch (e) {
      if (mounted) showSnack(context, classesErrorText(e, l));
    }
  }

  Widget _student(_GroupData d) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final me = context.services.backend.userId;
    final mine = [
      for (final s in d.submissions)
        if (s.userId == me) s,
    ];
    final avg = mine.isEmpty
        ? null
        : (mine.map((s) => s.percent).reduce((a, b) => a + b) / mine.length)
              .round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (d.assignments.isNotEmpty)
          LgPanel(
            soft: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LgEyebrow(l.classesMyProgress),
                Text(
                  l.classesDoneOf(mine.length, d.assignments.length),
                  style: text.titleLarge,
                ),
                const SizedBox(height: 10),
                ExcludeSemantics(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: mine.length / d.assignments.length,
                      minHeight: 6,
                      color: p.brand,
                      backgroundColor: p.paper,
                    ),
                  ),
                ),
                if (avg != null) ...[
                  const SizedBox(height: 8),
                  Text(l.classesAverage(avg), style: text.bodyMedium),
                ],
              ],
            ),
          ),
        LgSectionTitle(l.classesAssignments),
        if (d.assignments.isEmpty)
          LgStateView(
            kind: StateKind.empty,
            title: l.classesNoAssignmentsStudent,
            message: l.classesNoAssignmentsStudentBody,
          )
        else
          for (final (i, a) in d.assignments.indexed)
            () {
              final sub = mine.where((s) => s.assignmentId == a.id).firstOrNull;
              final status = _statusFor(context, a, sub);
              final (label, tone) = switch (status) {
                _StudentStatus.done => (
                  l.classesStatusDone(sub!.score, sub.total),
                  LgTone.brand,
                ),
                _StudentStatus.inProgress => (
                  l.classesStatusInProgress,
                  LgTone.warning,
                ),
                _StudentStatus.pending => (
                  l.classesStatusPending,
                  LgTone.warning,
                ),
                _StudentStatus.overdue => (
                  l.classesStatusOverdue,
                  LgTone.neutral,
                ),
                _StudentStatus.fresh => (l.classesStatusNew, LgTone.warning),
              };
              return _AssignmentTile(
                assignment: a,
                icon: status == _StudentStatus.done
                    ? Icons.task_alt_rounded
                    : Icons.assignment_outlined,
                tag: LgTag(label, tone: tone),
                divider: i < d.assignments.length - 1,
                onTap: () => _open('/learn/classes/g/${d.group.id}/a/${a.id}'),
              );
            }(),
        const SizedBox(height: 24),
        Text(l.classesStudentNote, style: text.bodySmall),
        const SizedBox(height: 8),
        LgButton.link(
          label: l.classesLeave,
          icon: Icons.logout_rounded,
          onPressed: () => _leave(d.group),
        ),
      ],
    );
  }

  Future<void> _leave(StudyGroup g) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.classesLeaveTitle,
      body: l.classesLeaveBody,
      action: l.classesLeaveAction,
    );
    if (!ok || !mounted) return;
    try {
      await context.services.backend.leaveGroup(g.id);
      if (mounted) context.pop();
    } on Object catch (e) {
      if (mounted) showSnack(context, classesErrorText(e, l));
    }
  }
}

/// Topshiriq qatori: nom, ma'lumot va holat belgisi pastma-past (tor ekran va
/// katta shriftda nom siqilib qolmaydi).
class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({
    required this.assignment,
    required this.icon,
    required this.tag,
    required this.divider,
    required this.onTap,
  });

  final GroupAssignment assignment;
  final IconData icon;
  final Widget? tag;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: p.soft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 21, color: p.brand),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(assignment.title, style: text.titleSmall),
                    const SizedBox(height: 3),
                    Text(
                      _assignmentMeta(context, assignment),
                      style: text.bodySmall!.copyWith(fontSize: 13),
                    ),
                    if (tag != null) ...[const SizedBox(height: 8), tag!],
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

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.group});

  final StudyGroup group;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final code = group.joinCode ?? '';
    final spaced = code.length == 8
        ? '${code.substring(0, 4)} ${code.substring(4)}'
        : code;
    Future<void> copy(String value) async {
      await Clipboard.setData(ClipboardData(text: value));
      if (context.mounted) showSnack(context, l.classesCopied);
    }

    return LgPanel(
      soft: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgEyebrow(l.classesInviteTitle),
          Semantics(
            label: '${l.classesInviteTitle}: ${code.split('').join(' ')}',
            // Kod bitta qatorda: katta shriftda ham bo'linmaydi (kichrayadi).
            child: ExcludeSemantics(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  spaced,
                  maxLines: 1,
                  softWrap: false,
                  style: text.displaySmall!.copyWith(
                    fontSize: 34,
                    letterSpacing: 3,
                    color: p.brand,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(l.classesInviteBody, style: text.bodyMedium),
          const SizedBox(height: 14),
          LgButton(
            label: l.classesCopyCode,
            icon: Icons.copy_rounded,
            onPressed: () => copy(code),
          ),
          const SizedBox(height: 8),
          LgButton.secondary(
            label: l.classesCopyInvite,
            icon: Icons.ios_share_rounded,
            onPressed: () => copy(l.classesInviteText(group.name, code)),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------- yangi topshiriq

enum _Due { none, d1, d3, d7, custom }

class NewAssignmentScreen extends StatefulWidget {
  const NewAssignmentScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<NewAssignmentScreen> createState() => _NewAssignmentScreenState();
}

class _NewAssignmentScreenState extends State<NewAssignmentScreen> {
  /// Server chegarasi: bitta topshiriqda 1–50 savol.
  static const maxQuestions = 50;

  final _title = TextEditingController();
  final _count = TextEditingController(text: '10');
  final _minutes = TextEditingController();
  Set<String> _topics = {};
  _Due _due = _Due.none;
  DateTime? _customDue;
  List<ExamQuestion>? _drawn;
  bool _tried = false;
  bool _busy = false;
  Object? _error;

  @override
  void dispose() {
    _title.dispose();
    _count.dispose();
    _minutes.dispose();
    super.dispose();
  }

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  int _max(ContentPack pack) {
    final n = _assignablePool(pack, _topics).length;
    return n < maxQuestions ? n : maxQuestions;
  }

  bool _countOk(ContentPack pack) {
    final n = _int(_count);
    return n != null && n >= 1 && n <= _max(pack);
  }

  bool get _minutesOk {
    if (_minutes.text.trim().isEmpty) return true;
    final n = _int(_minutes);
    return n != null && n >= 1 && n <= 180;
  }

  bool get _titleOk {
    final n = _title.text.trim().length;
    return n >= 3 && n <= 120;
  }

  /// Muddat — tanlangan kunning oxiri (23:59, qurilma vaqti).
  DateTime? get _dueAt {
    final now = context.services.exams.now();
    DateTime endOf(int days) =>
        DateTime(now.year, now.month, now.day + days, 23, 59);
    return switch (_due) {
      _Due.none => null,
      _Due.d1 => endOf(1),
      _Due.d3 => endOf(3),
      _Due.d7 => endOf(7),
      _Due.custom => _customDue,
    };
  }

  void _redraw(ContentPack pack) {
    final n = _int(_count);
    _drawn = n == null || !_countOk(pack)
        ? null
        : drawQuestions(
            _assignablePool(pack, _topics),
            n,
            context.services.exams.random,
          );
  }

  Future<void> _pickDate() async {
    final now = context.services.exams.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _customDue ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    setState(() {
      _due = _Due.custom;
      _customDue = DateTime(date.year, date.month, date.day, 23, 59);
    });
  }

  Future<void> _submit(ContentPack pack) async {
    setState(() => _tried = true);
    final drawn = _drawn;
    if (!_titleOk || !_countOk(pack) || !_minutesOk || drawn == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.services.backend.createAssignment(
        groupId: widget.groupId,
        title: _title.text.trim(),
        questionIds: [for (final q in drawn) q.id],
        correctIndexes: [for (final q in drawn) q.correct.single],
        dueAt: _dueAt,
        timeLimitMinutes: _minutes.text.trim().isEmpty ? null : _int(_minutes),
      );
      if (!mounted) return;
      showSnack(context, AppLocalizations.of(context).classesAssignmentCreated);
      context.pop(true);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.classesNewAssignment,
      subtitle: l.classesNewAssignmentIntro,
      showProfile: false,
      children: [ClassesGate(child: ContentGate(builder: _form))],
    );
  }

  Widget _form(BuildContext context, ContentPack pack) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    if (_drawn == null && _countOk(pack)) _redraw(pack);
    final max = _max(pack);
    final drawn = _drawn;
    final due = _dueAt;
    void changed() => setState(() => _redraw(pack));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgField(
          label: l.classesAssignmentTitle,
          controller: _title,
          hint: l.classesAssignmentTitleHint,
          maxLength: 120,
          textInputAction: TextInputAction.next,
          errorText: _tried && !_titleOk ? l.classesLengthError(3, 120) : null,
          onChanged: (_) => setState(() {}),
        ),
        LgSectionTitle(l.examTopics),
        TopicChips(
          source: PackQuestionSource.of(pack),
          selected: _topics,
          onChanged: (t) {
            _topics = t;
            changed();
          },
        ),
        LgSectionTitle(l.examSettings),
        NumberPresetField(
          label: l.examCount,
          controller: _count,
          hint: '10',
          helper: l.examCountHint(max),
          errorText: _tried && !_countOk(pack) ? l.examCountError(max) : null,
          presets: [
            for (final n in [5, 10, 20])
              if (n < max) ('$n', '$n'),
            (l.examCountAll(max), '$max'),
          ],
          onChanged: changed,
        ),
        const SizedBox(height: 6),
        NumberPresetField(
          label: l.classesTimeLimit,
          controller: _minutes,
          hint: l.classesNoLimit,
          helper: l.classesTimeLimitHint,
          errorText: _tried && !_minutesOk ? l.examTimeError : null,
          presets: [
            (l.classesNoLimit, ''),
            for (final n in [10, 20, 30]) (l.examMinutes(n), '$n'),
          ],
          onChanged: () => setState(() {}),
        ),
        LgSectionTitle(l.classesDueTitle),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (d, label) in [
              (_Due.none, l.classesDueNone),
              (_Due.d1, l.classesDueDays(1)),
              (_Due.d3, l.classesDueDays(3)),
              (_Due.d7, l.classesDueDays(7)),
            ])
              LgChoiceChip(
                label: label,
                selected: _due == d,
                onTap: () => setState(() => _due = d),
              ),
            LgChoiceChip(
              label: l.classesDuePick,
              selected: _due == _Due.custom,
              onTap: _pickDate,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          due == null
              ? l.classesDueNoneBody
              : l.classesDueAt(formatWhen(due, context)),
          style: text.bodyMedium,
        ),
        LgSectionTitle(l.classesPreview(drawn?.length ?? 0)),
        if (drawn == null)
          Text(l.examCountError(max), style: text.bodyMedium)
        else
          LgPanel(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, q) in drawn.indexed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text('${i + 1}.', style: text.labelLarge),
                        ),
                        Expanded(
                          child: Text(q.prompt(lang), style: text.bodyMedium),
                        ),
                        if (q.isDraft) ...[
                          const SizedBox(width: 6),
                          Tooltip(
                            message: l.quizDraftTag,
                            child: Icon(
                              Icons.pending_outlined,
                              size: 18,
                              color: LgPalette.of(context).amber,
                              semanticLabel: l.quizDraftTag,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (drawn != null) ...[
          const SizedBox(height: 4),
          LgButton.secondary(
            label: l.classesReshuffle,
            icon: Icons.shuffle_rounded,
            onPressed: changed,
          ),
        ],
        const SizedBox(height: 10),
        if (drawn?.any((q) => q.isDraft) ?? false) LgNotice(l.examDraftNotice),
        LgNotice(l.classesKeyNotice, kind: NoticeKind.info),
        if (_error != null)
          LgNotice(classesErrorText(_error!, l), kind: NoticeKind.error),
        const SizedBox(height: 12),
        LgButton(
          label: l.classesSendAssignment,
          icon: Icons.send_rounded,
          busy: _busy,
          onPressed: () => _submit(pack),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- topshiriq

/// Javoblarni yuborish natijasi.
enum SubmitOutcome { sent, network, rejected, failed }

/// Topshiriq javoblarini serverga yuboradi. Qabul qilinsa yoki server rad
/// etsa (vaqt/muddat tugagan, avval topshirilgan) lokal nusxa o'chiriladi;
/// tarmoq xatosida saqlanib qoladi — keyin qayta yuboriladi.
Future<SubmitOutcome> submitAssignmentSession(
  AppServices services,
  ExamSession s,
) async {
  try {
    await services.backend.submitAssignment(
      s.assignmentId!,
      s.submissionAnswers(),
    );
    await recordExamProgress(services, s);
    await services.exams.removeAssignment(s.assignmentId!);
    return SubmitOutcome.sent;
  } on BackendException catch (e) {
    switch (e.failure) {
      case BackendFailure.network:
        return SubmitOutcome.network;
      case BackendFailure.invalid || BackendFailure.forbidden:
        await services.exams.removeAssignment(s.assignmentId!);
        return SubmitOutcome.rejected;
      default:
        return SubmitOutcome.failed;
    }
  }
}

void _reportSubmit(BuildContext context, SubmitOutcome o) {
  final l = AppLocalizations.of(context);
  final msg = switch (o) {
    SubmitOutcome.sent => l.classesSubmitted,
    SubmitOutcome.network => l.classesSubmitNetwork,
    SubmitOutcome.rejected => l.classesSubmitRejected,
    SubmitOutcome.failed => l.errGeneric,
  };
  showSnack(context, msg);
}

class _AssignmentData {
  _AssignmentData({
    required this.group,
    required this.assignment,
    required this.submissions,
    required this.members,
    required this.key,
  });

  final StudyGroup group;
  final GroupAssignment assignment;
  final List<GroupSubmission> submissions;
  final List<GroupMember> members;

  /// Faqat ustozda.
  final List<int>? key;
}

Future<_AssignmentData?> _loadAssignment(
  BuildContext context,
  String groupId,
  String assignmentId,
) async {
  final backend = context.services.backend;
  final group = (await backend.myGroups())
      .where((g) => g.id == groupId)
      .firstOrNull;
  if (group == null) return null;
  final a = (await backend.assignments(groupId))
      .where((a) => a.id == assignmentId)
      .firstOrNull;
  if (a == null) return null;
  return _AssignmentData(
    group: group,
    assignment: a,
    submissions: await backend.submissions(assignmentId),
    members: group.isTeacher ? await backend.groupMembers(groupId) : const [],
    key: group.isTeacher ? await backend.assignmentKey(assignmentId) : null,
  );
}

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({
    super.key,
    required this.groupId,
    required this.assignmentId,
  });

  final String groupId;
  final String assignmentId;

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen>
    with _AccountReload {
  final _data = _Loaded<_AssignmentData>();
  bool _missing = false;
  bool _busy = false;
  bool _all = false;

  String get _base =>
      '/learn/classes/g/${widget.groupId}/a/${widget.assignmentId}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted || !_ready(context)) return;
    setState(() {
      _data
        ..loading = true
        ..error = null;
    });
    try {
      final d = await _loadAssignment(
        context,
        widget.groupId,
        widget.assignmentId,
      );
      if (!mounted) return;
      setState(() {
        _missing = d == null;
        _data.data = d;
      });
      if (d != null && !d.group.isTeacher) await _settleExpired(d);
    } on Object catch (e) {
      if (mounted) setState(() => _data.error = e);
    } finally {
      if (mounted) setState(() => _data.loading = false);
    }
  }

  /// Ilova yopiq paytda vaqti tugagan topshiriq — javoblar o'zi yuboriladi.
  Future<void> _settleExpired(_AssignmentData d) async {
    final services = context.services;
    final me = services.backend.userId;
    final local = services.exams.assignmentSession(widget.assignmentId, me);
    if (local == null ||
        local.finished ||
        !local.expired(services.exams.now()) ||
        d.submissions.any((s) => s.userId == me)) {
      return;
    }
    await services.exams.finishAssignment(local, timedOut: true);
    final outcome = await submitAssignmentSession(services, local);
    if (!mounted) return;
    _reportSubmit(context, outcome);
    if (outcome != SubmitOutcome.network) {
      final fresh = await _loadAssignment(
        context,
        widget.groupId,
        widget.assignmentId,
      );
      if (mounted) setState(() => _data.data = fresh);
    }
  }

  Future<void> _start(GroupAssignment a, ContentPack pack) async {
    final services = context.services;
    final byId = _byId(pack);
    setState(() => _busy = true);
    try {
      final start = await services.backend.startAssignment(a.id);
      final exams = services.exams;
      final localNow = exams.now();
      // Server soati bo'yicha boshlangan vaqt qurilma soatiga o'tkaziladi.
      final startedAt = start.startedAt.add(
        localNow.difference(start.serverNow),
      );
      final limit = a.timeLimitMinutes == null
          ? null
          : Duration(minutes: a.timeLimitMinutes!);
      final due = a.dueAt?.add(localNow.difference(start.serverNow));
      await exams.startAssignment(
        ExamSession.build(
          id: exams.newId(),
          mode: ExamMode.assignment,
          questions: [for (final id in a.questionIds) byId[id]!],
          random: exams.random,
          startedAt: startedAt,
          limit: limit,
          hardDeadline: due,
          title: a.title,
          assignmentId: a.id,
          groupId: a.groupId,
          userId: services.backend.userId,
        ),
      );
      if (mounted) await context.push('$_base/run');
      if (mounted) await _load();
    } on Object catch (e) {
      if (mounted) {
        showSnack(context, classesErrorText(e, AppLocalizations.of(context)));
        await _load();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend(ExamSession s) async {
    setState(() => _busy = true);
    final outcome = await submitAssignmentSession(context.services, s);
    if (!mounted) return;
    _reportSubmit(context, outcome);
    setState(() => _busy = false);
    await _load();
  }

  @override
  void resetForAccount() {
    _data
      ..data = null
      ..error = null;
    _missing = false;
  }

  @override
  Future<void> reloadForAccount() => _load();

  @override
  Widget build(BuildContext context) => watchAccount(_page);

  Widget _page(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = _data.data;
    return LgPage(
      title: d?.assignment.title ?? l.classesAssignments,
      subtitle: d == null ? null : _assignmentMeta(context, d.assignment),
      showProfile: false,
      children: [
        ClassesGate(
          child: _missing
              ? LgStateView(
                  kind: StateKind.empty,
                  title: l.classesAssignmentMissing,
                  actionLabel: l.classesBackToList,
                  onAction: () => context.go('/learn/classes'),
                )
              : _loadState(
                  context,
                  _data,
                  _load,
                  (d) => ContentGate(
                    builder: (context, pack) => ListenableBuilder(
                      listenable: context.services.exams,
                      builder: (context, _) => d.group.isTeacher
                          ? _teacher(d, pack)
                          : _student(d, pack),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _metrics(GroupAssignment a, {List<Widget> extra = const []}) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        ...extra,
        LgMetric(
          label: l.classesMetricQuestions,
          value: '${a.questionIds.length}',
        ),
        LgMetric(
          label: l.classesMetricLimit,
          value: a.timeLimitMinutes == null
              ? l.classesNoLimit
              : l.examMinutes(a.timeLimitMinutes!),
        ),
        LgMetric(
          label: l.classesMetricDue,
          value: a.dueAt == null
              ? l.classesDueNone
              : formatWhen(a.dueAt!, context),
        ),
      ],
    );
  }

  Widget _student(_AssignmentData d, ContentPack pack) {
    final l = AppLocalizations.of(context);
    final services = context.services;
    final a = d.assignment;
    final me = services.backend.userId;
    final mine = d.submissions.where((s) => s.userId == me).firstOrNull;
    if (mine != null) return _studentResult(a, mine, pack);
    final byId = _byId(pack);
    final missing = a.questionIds.where((id) => !byId.containsKey(id)).length;
    final local = services.exams.assignmentSession(a.id, me);
    final status = _statusFor(context, a, mine);
    final Widget action = switch (status) {
      _StudentStatus.pending => LgStateView(
        kind: StateKind.offline,
        title: l.classesPendingTitle,
        message: l.classesPendingBody,
        actionLabel: l.classesResend,
        onAction: _busy ? null : () => _resend(local!),
      ),
      _StudentStatus.inProgress => LgPanel(
        soft: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LgEyebrow(l.classesStatusInProgress),
            Text(
              local!.remaining(services.exams.now()) == null
                  ? l.examAnsweredOf(local.answeredCount, local.length)
                  : l.examActiveBody(
                      local.answeredCount,
                      local.length,
                      formatClock(local.remaining(services.exams.now())!),
                    ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            LgButton(
              label: l.examResume,
              icon: Icons.play_arrow_rounded,
              onPressed: () async {
                await context.push('$_base/run');
                if (mounted) await _load();
              },
            ),
          ],
        ),
      ),
      _StudentStatus.overdue => LgStateView(
        kind: StateKind.unavailable,
        title: l.classesOverdueTitle,
        message: l.classesOverdueBody,
      ),
      _ when missing > 0 => LgNotice(
        l.classesOutdatedPack(missing),
        kind: NoticeKind.error,
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (a.questionIds.any((id) => byId[id]?.isDraft ?? false))
            LgNotice(l.examDraftNotice),
          LgNotice(
            a.timeLimitMinutes == null
                ? l.classesStartNoticeNoLimit
                : l.classesStartNotice(a.timeLimitMinutes!),
            kind: NoticeKind.info,
          ),
          const SizedBox(height: 12),
          LgButton(
            label: l.classesStart,
            icon: Icons.play_arrow_rounded,
            busy: _busy,
            onPressed: () => _start(a, pack),
          ),
        ],
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_metrics(a), const SizedBox(height: 16), action],
    );
  }

  Widget _studentResult(
    GroupAssignment a,
    GroupSubmission mine,
    ContentPack pack,
  ) {
    final l = AppLocalizations.of(context);
    final byId = _byId(pack);
    bool isRight(int i) =>
        mine.correct?[i] ??
        (byId[a.questionIds[i]]?.correct.contains(mine.answers[i]) ?? false);
    final all = [for (var i = 0; i < a.questionIds.length; i++) i];
    final wrong = [
      for (final i in all)
        if (!isRight(i)) i,
    ];
    final shown = _all ? all : wrong;
    final unanswered = mine.answers.where((x) => x < 0).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScoreHero(
          correct: mine.score,
          total: mine.total,
          wrong: mine.total - mine.score - unanswered,
          unanswered: unanswered,
          caption: l.classesSubmittedAt(formatWhen(mine.submittedAt, context)),
          badges: [LgTag(l.classesServerScore, icon: Icons.verified_outlined)],
        ),
        LgSectionTitle(l.examAnalysis),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LgChoiceChip(
              label: l.examFilterMistakes(wrong.length),
              selected: !_all,
              onTap: () => setState(() => _all = false),
            ),
            LgChoiceChip(
              label: l.examFilterAll(all.length),
              selected: _all,
              onTap: () => setState(() => _all = true),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (shown.isEmpty)
          LgStateView(kind: StateKind.success, title: l.quizNoMistakes)
        else
          for (final i in shown)
            () {
              final q = byId[a.questionIds[i]];
              final chosen = i < mine.answers.length && mine.answers[i] >= 0
                  ? mine.answers[i]
                  : null;
              return ExamReviewCard(
                number: i + 1,
                question: q,
                chosen: chosen == null ? null : [chosen],
                // Server “to'g'ri” desa — tanlangan javob to'g'ri javobdir.
                correct: isRight(i) && chosen != null
                    ? [chosen]
                    : (q?.correct.toList() ?? const []),
              );
            }(),
      ],
    );
  }

  Widget _teacher(_AssignmentData d, ContentPack pack) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final a = d.assignment;
    final byId = _byId(pack);
    final students = [
      for (final m in d.members)
        if (!m.isTeacher) m,
    ];
    final subs = {
      for (final s in d.submissions)
        if (students.any((m) => m.userId == s.userId)) s.userId: s,
    };
    final avg = subs.isEmpty
        ? null
        : (subs.values.map((s) => s.percent).reduce((a, b) => a + b) /
                  subs.length)
              .round();
    final rows = [...students]
      ..sort((x, y) {
        final sx = subs[x.userId];
        final sy = subs[y.userId];
        if (sx == null || sy == null) {
          return sx == null ? (sy == null ? 0 : 1) : -1;
        }
        return sy.percent.compareTo(sx.percent);
      });
    bool right(GroupSubmission s, int i) =>
        s.correct?[i] ?? (d.key != null && s.answers[i] == d.key![i]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _metrics(
          a,
          extra: [
            LgMetric(
              label: l.classesMetricSubmitted,
              value: '${subs.length} / ${students.length}',
            ),
            LgMetric(
              label: l.classesMetricAverage,
              value: avg == null ? '—' : '$avg%',
            ),
          ],
        ),
        LgSectionTitle(l.classesResults),
        if (students.isEmpty)
          Text(l.classesNoStudents, style: text.bodyMedium)
        else
          LgPanel(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ExcludeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.classesColStudent,
                            style: text.labelMedium,
                          ),
                        ),
                        Text(l.classesColScore, style: text.labelMedium),
                      ],
                    ),
                  ),
                ),
                for (final m in rows)
                  _ResultRow(
                    name: m.displayName,
                    submission: subs[m.userId],
                    onTap: subs[m.userId] == null
                        ? null
                        : () => context.push('$_base/s/${m.userId}'),
                  ),
              ],
            ),
          ),
        LgSectionTitle(l.classesByQuestion),
        if (subs.isEmpty)
          Text(l.classesByQuestionEmpty, style: text.bodyMedium)
        else
          for (var i = 0; i < a.questionIds.length; i++)
            () {
              final q = byId[a.questionIds[i]];
              final wrong = subs.values.where((s) => !right(s, i)).length;
              final rate = 1 - wrong / subs.length;
              final key = d.key?[i];
              return LgPanel(
                padding: const EdgeInsets.all(16),
                child: Semantics(
                  container: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: LgEyebrow(l.examQuestionN(i + 1))),
                          LgTag(
                            l.classesWrongOf(wrong, subs.length),
                            tone: wrong == 0 ? LgTone.brand : LgTone.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        q?.prompt(lang) ?? l.examQuestionMissing,
                        style: text.bodyMedium,
                      ),
                      if (q != null && key != null && key < q.optionCount) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${l.quizCorrectAnswer}: ${q.option(key, lang)}',
                          style: text.bodySmall!.copyWith(color: p.brand),
                        ),
                      ],
                      const SizedBox(height: 10),
                      ExcludeSemantics(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: rate,
                            minHeight: 6,
                            color: p.brand,
                            backgroundColor: p.amberBg,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }(),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.name,
    required this.submission,
    required this.onTap,
  });

  final String name;
  final GroupSubmission? submission;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final s = submission;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kMinTap + 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: text.titleSmall),
                  if (s != null)
                    Text(
                      formatWhen(s.submittedAt, context),
                      style: text.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (s == null)
              Text(
                l.classesNotSubmitted,
                style: text.bodySmall!.copyWith(color: p.sub),
              )
            else
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${s.score}/${s.total}  ',
                      style: text.titleSmall,
                    ),
                    TextSpan(
                      text: '${s.percent}%',
                      style: text.titleSmall!.copyWith(
                        color: s.percent >= 50 ? p.brand : p.amber,
                      ),
                    ),
                  ],
                ),
              ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: p.sub, size: 22),
          ],
        ),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.line.withValues(alpha: 0.7))),
      ),
      child: onTap == null
          ? Semantics(container: true, child: row)
          : LgPressable(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: row,
            ),
    );
  }
}

/// Ustoz: bitta talabaning javoblari (server kaliti bo'yicha).
class StudentResultScreen extends StatefulWidget {
  const StudentResultScreen({
    super.key,
    required this.groupId,
    required this.assignmentId,
    required this.userId,
  });

  final String groupId;
  final String assignmentId;
  final String userId;

  @override
  State<StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen>
    with _AccountReload {
  final _data = _Loaded<_AssignmentData>();
  bool _missing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted || !_ready(context)) return;
    setState(() {
      _data
        ..loading = true
        ..error = null;
    });
    try {
      final d = await _loadAssignment(
        context,
        widget.groupId,
        widget.assignmentId,
      );
      if (!mounted) return;
      setState(() {
        _missing = d == null || !d.group.isTeacher;
        _data.data = d;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _data.error = e);
    } finally {
      if (mounted) setState(() => _data.loading = false);
    }
  }

  @override
  void resetForAccount() {
    _data
      ..data = null
      ..error = null;
    _missing = false;
  }

  @override
  Future<void> reloadForAccount() => _load();

  @override
  Widget build(BuildContext context) => watchAccount(_page);

  Widget _page(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = _data.data;
    final member = d?.members
        .where((m) => m.userId == widget.userId)
        .firstOrNull;
    final s = d?.submissions
        .where((s) => s.userId == widget.userId)
        .firstOrNull;
    return LgPage(
      title: member?.displayName ?? l.classesResults,
      subtitle: d?.assignment.title,
      showProfile: false,
      children: [
        ClassesGate(
          child: _missing || (d != null && (s == null || d.key == null))
              ? LgStateView(kind: StateKind.empty, title: l.classesNotSubmitted)
              : _loadState(
                  context,
                  _data,
                  _load,
                  (d) => ContentGate(
                    builder: (context, pack) {
                      final byId = _byId(pack);
                      final a = d.assignment;
                      final unanswered = s!.answers.where((x) => x < 0).length;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ScoreHero(
                            title: l.classesStudentResultTitle,
                            correct: s.score,
                            total: s.total,
                            wrong: s.total - s.score - unanswered,
                            unanswered: unanswered,
                            caption: l.classesSubmittedAt(
                              formatWhen(s.submittedAt, context),
                            ),
                          ),
                          LgSectionTitle(l.examAnalysis),
                          for (var i = 0; i < a.questionIds.length; i++)
                            ExamReviewCard(
                              number: i + 1,
                              question: byId[a.questionIds[i]],
                              chosen: i < s.answers.length && s.answers[i] >= 0
                                  ? [s.answers[i]]
                                  : null,
                              correct: [d.key![i]],
                              chosenLabel: l.classesStudentAnswer,
                            ),
                        ],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

/// Topshiriqni yechish (to'liq ekran, imtihon UI'si). Yakunlanganda
/// javoblar serverga yuboriladi; internet bo'lmasa qurilmada qoladi.
class AssignmentRunScreen extends StatefulWidget {
  const AssignmentRunScreen({
    super.key,
    required this.groupId,
    required this.assignmentId,
  });

  final String groupId;
  final String assignmentId;

  @override
  State<AssignmentRunScreen> createState() => _AssignmentRunScreenState();
}

class _AssignmentRunScreenState extends State<AssignmentRunScreen> {
  bool _sending = false;

  Future<void> _finish(ExamSession s, {required bool timedOut}) async {
    final services = context.services;
    setState(() => _sending = true);
    await services.exams.finishAssignment(s, timedOut: timedOut);
    final outcome = await submitAssignmentSession(services, s);
    if (!mounted) return;
    _reportSubmit(context, outcome);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final services = context.services;
    return ListenableBuilder(
      listenable: services.exams,
      builder: (context, _) {
        if (_sending) {
          return ExamStatePage(
            title: l.classesAssignments,
            state: LgStateView(
              kind: StateKind.loading,
              title: l.classesSending,
            ),
          );
        }
        final s = services.exams.assignmentSession(
          widget.assignmentId,
          services.backend.userId,
        );
        if (s == null || s.finished) {
          return ExamStatePage(
            title: l.classesAssignments,
            state: LgStateView(
              kind: StateKind.empty,
              title: l.examNoActive,
              actionLabel: l.actionBack,
              onAction: () => context.pop(),
            ),
          );
        }
        return ExamRunner(
          session: s,
          title: s.title ?? l.classesAssignments,
          onFinish: ({required timedOut}) => _finish(s, timedOut: timedOut),
        );
      },
    );
  }
}
