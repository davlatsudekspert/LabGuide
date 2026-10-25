import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/backend/backend_models.dart';
import '../../core/backend/teacher_tests.dart';
import '../../core/entitlements/feature.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../classroom/invite_link.dart' show nicknameAllowed, normalizeNickname;
import '../learn/exam_widgets.dart' show confirmDialog, showSnack;
import '../profile/pro_gate.dart';
import '../support/support_screens.dart' show formatWhen;
import 'teacher_pro_common.dart';
import 'teacher_results_screens.dart' show ttStateLabel;

// Talaba tomoni (Feature.teacherTests, Talaba Pro): ustoz bergan maxsus
// testlar. Ro'yxat va o'z natijasi — doim ko'rinadi; YANGI urinish —
// boshlanishidan oldin gate (`allowOrOffer`). Boshlangan urinish hech qachon
// to'xtatilmaydi: obuna o'rtada tugasa ham davom etadi va topshiriladi.
// Birinchi topshirishdan oldin: "natija ustozga ko'rinadi" ogohlantirishi.

// -------------------------------------------------------------- ro'yxat

class StudentTeacherTestsScreen extends StatefulWidget {
  const StudentTeacherTestsScreen({super.key});

  @override
  State<StudentTeacherTestsScreen> createState() =>
      _StudentTeacherTestsScreenState();
}

class _StudentTeacherTestsScreenState extends State<StudentTeacherTestsScreen> {
  final _list = TtLoad<List<StudentTeacherTest>>();
  String? _loadedFor = '';

  Future<void> _load(TeacherTestBackend api) async {
    if (_list.loading) return;
    setState(() {
      _list
        ..loading = true
        ..error = null;
    });
    try {
      final r = await api.myTeacherTests();
      if (mounted) setState(() => _list.data = r);
    } on Object catch (e) {
      if (mounted) setState(() => _list.error = e);
    } finally {
      if (mounted) setState(() => _list.loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.ttMyTitle,
      subtitle: l.ttMySubtitle,
      children: [
        TeacherProGate(
          builder: (context, api) {
            final uid = context.services.backend.userId;
            if (_loadedFor != uid) {
              _loadedFor = uid;
              _list
                ..data = null
                ..error = null;
              WidgetsBinding.instance.addPostFrameCallback((_) => _load(api));
            }
            return ttLoadState(context, _list, () => _load(api), (tests) {
              if (tests.isEmpty) {
                return LgStateView(
                  kind: StateKind.empty,
                  title: l.ttMyEmpty,
                  message: l.ttMyEmptyBody,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, t) in tests.indexed)
                    LgRow(
                      key: ValueKey('tt-my-${t.id}'),
                      title: t.title,
                      subtitle: [
                        ttStateLabel(l, t.state),
                        t.groupName,
                        l.ttDueOn(formatWhen(t.dueAt, context)),
                        if (t.bestPercent != null) l.ttBest(t.bestPercent!),
                      ].join(' · '),
                      icon: switch (t.state) {
                        TtState.submitted => Icons.task_alt_rounded,
                        TtState.started => Icons.timelapse_rounded,
                        TtState.expired => Icons.event_busy_rounded,
                        TtState.assigned => Icons.assignment_outlined,
                      },
                      divider: i < tests.length - 1,
                      onTap: () async {
                        await context.push(TtRoutes.myTest(t.id));
                        if (mounted) await _load(api);
                      },
                    ),
                ],
              );
            });
          },
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ test sahifasi

class StudentTeacherTestScreen extends StatefulWidget {
  const StudentTeacherTestScreen({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  State<StudentTeacherTestScreen> createState() =>
      _StudentTeacherTestScreenState();
}

class _StudentTeacherTestScreenState extends State<StudentTeacherTestScreen> {
  final _data = TtLoad<StudentTeacherTest>();
  bool _started = false;
  bool _starting = false;

  Future<void> _load(TeacherTestBackend api) async {
    setState(() {
      _data
        ..loading = true
        ..error = null;
    });
    try {
      final r = await api.myTeacherTest(widget.assignmentId);
      if (mounted) setState(() => _data.data = r);
    } on Object catch (e) {
      if (mounted) setState(() => _data.error = e);
    } finally {
      if (mounted) setState(() => _data.loading = false);
    }
  }

  /// Boshlash: YANGI urinish — gate; boshlangan urinish — tekshiruvsiz.
  void _onStart(TeacherTestBackend api, StudentTeacherTest t) {
    if (_starting) return;
    if (!allowOrOffer(context, Feature.teacherTests, inProgress: t.inProgress)) {
      return;
    }
    unawaited(_start(api, t));
  }

  Future<void> _start(TeacherTestBackend api, StudentTeacherTest t) async {
    final l = AppLocalizations.of(context);
    setState(() => _starting = true);
    try {
      final run = await api.startTeacherTest(t.id);
      if (!mounted) return;
      setState(() => _starting = false);
      final result = await context.push<TtAttempt>(
        TtRoutes.run(t.id),
        extra: TtRunArgs(test: t, run: run),
      );
      if (!mounted) return;
      if (result?.score != null) {
        showSnack(context, l.ttSubmittedSnack(result!.score!, result.total));
      }
      await _load(api);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _starting = false);
      if (!ttOfferIfPlanError(context, e, Feature.teacherTests)) {
        showSnack(context, ttErrorText(e, l));
        await _load(api);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: _data.data?.title ?? l.ttMyTitle,
      titleMaxLines: 3,
      subtitle: _data.data?.groupName,
      children: [
        TeacherProGate(
          builder: (context, api) {
            if (!_started) {
              _started = true;
              WidgetsBinding.instance.addPostFrameCallback((_) => _load(api));
            }
            return ttLoadState(
              context,
              _data,
              () => _load(api),
              (t) => ListenableBuilder(
                listenable: context.services.entitlements,
                builder: (context, _) => _body(context, l, api, t),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l,
    TeacherTestBackend api,
    StudentTeacherTest t,
  ) {
    final text = Theme.of(context).textTheme;
    final locked =
        !t.inProgress && !context.services.entitlements.can(Feature.teacherTests);
    final reason = t.canStart || t.inProgress
        ? null
        : t.closed
        ? l.ttCantClosed
        : t.attemptsUsed >= t.maxAttempts
        ? l.ttCantNoAttempts
        : l.ttCantPastDue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            LgTag(ttStateLabel(l, t.state)),
            LgTag(l.ttQuestionsCount(t.questionCount), tone: LgTone.neutral),
            LgTag(
              t.timeLimitMinutes == null
                  ? l.ttNoTimeLimit
                  : l.ttTimeLimit(t.timeLimitMinutes!),
              tone: LgTone.neutral,
            ),
            if (t.passPercent != null)
              LgTag(l.ttPassMark(t.passPercent!), tone: LgTone.neutral),
          ],
        ),
        const SizedBox(height: 10),
        LgMetric(
          label: l.ttAssignDue,
          value: formatWhen(t.dueAt, context),
        ),
        LgMetric(
          label: l.ttAssignAttempts,
          value: '${t.attemptsUsed}/${t.maxAttempts}',
        ),
        if (t.teacherAlias case final name?)
          LgMetric(label: l.classesRoleTeacher, value: name),
        const SizedBox(height: 6),
        Text(
          t.acceptLate ? l.ttLatePolicyAccept : l.ttLatePolicyReject,
          style: text.bodySmall,
        ),
        // Birinchi topshirishdan OLDIN — aniq ogohlantirish (maxfiylik).
        if (t.firstSubmission)
          LgNotice(
            l.ttVisibleNotice,
            title: l.ttVisibleNoticeTitle,
            kind: NoticeKind.info,
          ),
        if (locked) LgNotice(l.ttStudentLocked, title: l.proLockedLearner),
        if (reason != null) LgNotice(reason),
        if (t.canStart || t.inProgress) ...[
          const SizedBox(height: 8),
          LgButton(
            key: const ValueKey('tt-start'),
            label: t.inProgress ? l.ttContinue : l.ttStart,
            icon: Icons.play_arrow_rounded,
            busy: _starting,
            onPressed: _starting ? null : () => _onStart(api, t),
          ),
        ],
        if (t.attempts.isNotEmpty) ...[
          LgSectionTitle(l.ttYourAttempts),
          for (final a in t.attempts) _AttemptCard(attempt: a),
          if (t.attempts.any(
            (a) => a.status == TtState.submitted && a.review == null,
          ))
            Text(l.ttReviewHidden, style: text.bodySmall),
        ],
      ],
    );
  }
}

class _AttemptCard extends StatelessWidget {
  const _AttemptCard({required this.attempt});

  final TtAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final a = attempt;
    final summary = switch (a.status) {
      TtState.submitted => [
        '${a.score}/${a.total} (${a.percent}%)',
        if (a.passed != null) a.passed! ? l.ttPassed : l.ttNotPassed,
        if (a.seconds != null) ttDuration(l, a.seconds!),
        if (a.late) l.ttLate,
      ].join(' · '),
      TtState.started => l.ttStateStarted,
      _ => l.ttErrTimeOver,
    };
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgEyebrow(l.ttAttemptN(a.attemptNo)),
          const SizedBox(height: 4),
          Text(summary, style: text.titleSmall),
          for (final (i, r) in (a.review ?? const <TtReviewItem>[]).indexed)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${i + 1}. ${r.text}',
                    style: text.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        r.answer == r.correct
                            ? Icons.check_circle_rounded
                            : Icons.cancel_outlined,
                        size: 18,
                        color: r.answer == r.correct ? p.brand : p.danger,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${l.ttYourAnswer}: '
                          '${r.answer >= 0 && r.answer < r.options.length ? r.options[r.answer] : l.ttNoAnswer}',
                          style: text.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  if (r.answer != r.correct && r.correct < r.options.length)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, left: 24),
                      child: Text(
                        '${l.ttCorrectAnswer}: ${r.options[r.correct]}',
                        style: text.bodySmall,
                      ),
                    ),
                  if (r.explanation case final e?)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, left: 24),
                      child: Text(e, style: text.bodySmall),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- yechish

/// Yechish ekraniga uzatiladigan ma'lumot (`extra`).
class TtRunArgs {
  const TtRunArgs({required this.test, required this.run});
  final StudentTeacherTest test;
  final TtRun run;
}

/// Oddiy test oqimi: bitta savol, variantlar, oldinga/orqaga, savollar
/// xaritasi, taymer (server vaqti bo'yicha). Javoblar qurilmada saqlanadi —
/// ilova yopilsa ham yo'qolmaydi. Vaqt tugasa — o'zi topshiriladi.
class TtRunScreen extends StatefulWidget {
  const TtRunScreen({super.key, required this.assignmentId, this.args});

  final String assignmentId;
  final TtRunArgs? args;

  @override
  State<TtRunScreen> createState() => _TtRunScreenState();
}

class _TtRunScreenState extends State<TtRunScreen> {
  late List<int> _answers;
  int _index = 0;
  Timer? _ticker;
  bool _sending = false;
  bool _autoSent = false;

  /// Server soati − qurilma soati (taymer server vaqti bo'yicha).
  Duration _offset = Duration.zero;

  TtRun? get _run => widget.args?.run;

  @override
  void initState() {
    super.initState();
    final run = _run;
    if (run == null) return;
    final cache = context.services.teacherTestCache;
    _answers =
        cache.answers(run.attemptId, run.questions.length) ??
        List<int>.filled(run.questions.length, -1);
    _offset = run.serverNow.difference(DateTime.now().toUtc());
    if (run.timeUpAt != null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  DateTime get _now => DateTime.now().toUtc().add(_offset);

  Duration? get _left => _run?.timeUpAt?.difference(_now);

  void _tick() {
    if (!mounted || _sending) return;
    final left = _left;
    if (left != null && left <= Duration.zero && !_autoSent) {
      _autoSent = true;
      unawaited(_submit(confirm: false));
      return;
    }
    setState(() {});
  }

  void _choose(int option) {
    setState(() => _answers[_index] = option);
    unawaited(
      context.services.teacherTestCache.saveAnswers(_run!.attemptId, _answers),
    );
  }

  Future<void> _submit({bool confirm = true}) async {
    final run = _run!;
    final t = widget.args!.test;
    final l = AppLocalizations.of(context);
    if (confirm) {
      final unanswered = _answers.where((a) => a < 0).length;
      final ok = await confirmDialog(
        context,
        title: l.ttSubmitConfirmTitle,
        body: [
          if (unanswered > 0) l.ttSubmitUnanswered(unanswered),
          l.ttSubmitFinal,
          if (t.firstSubmission) l.ttSubmitVisible,
        ].join(' '),
        action: l.ttSubmit,
      );
      if (!ok || !mounted) return;
    }
    final services = context.services;
    final api = services.teacherTests;
    if (api == null) return;
    setState(() => _sending = true);
    _ticker?.cancel();
    try {
      // Topshirish tekshirilmaydi: boshlangan urinish obunasiz ham topshiriladi.
      final result = await api.submitTeacherTest(
        t.id,
        attemptId: run.attemptId,
        answers: _answers,
      );
      await services.teacherTestCache.clearAnswers(run.attemptId);
      if (mounted) context.pop(result);
    } on Object catch (e) {
      if (!mounted) return;
      final terminal =
          e is BackendException &&
          const {
            'time_over',
            'already_submitted',
            'closed',
          }.contains(e.code);
      if (terminal) {
        await services.teacherTestCache.clearAnswers(run.attemptId);
        if (!mounted) return;
        showSnack(context, ttErrorText(e, l));
        context.pop();
        return;
      }
      setState(() => _sending = false);
      showSnack(context, l.ttSubmitFailedSaved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final run = _run;
    if (run == null || run.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l.ttMyTitle)),
        body: LgStateView(
          kind: StateKind.empty,
          title: l.examNoActive,
          actionLabel: l.actionBack,
          onAction: () => context.pop(),
        ),
      );
    }
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final q = run.questions[_index];
    final left = _left;
    final last = _index == run.questions.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.args!.test.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        top: false,
        child: _sending
            ? LgStateView(kind: StateKind.loading, title: l.classesSending)
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      LgEyebrow(l.quizProgress(_index + 1, run.questions.length)),
                      if (left != null)
                        LgTag(
                          l.ttTimeLeft(
                            ttDuration(l, left.isNegative ? 0 : left.inSeconds),
                          ),
                          key: const ValueKey('tt-run-timer'),
                          tone: left.inMinutes < 1
                              ? LgTone.warning
                              : LgTone.neutral,
                          icon: Icons.timer_outlined,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(q.text, style: text.titleMedium),
                  const SizedBox(height: 12),
                  for (final (i, o) in q.options.indexed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Semantics(
                        selected: _answers[_index] == i,
                        button: true,
                        child: LgPressable(
                          key: ValueKey('tt-run-option-$i'),
                          onTap: () => _choose(i),
                          selected: _answers[_index] == i,
                          color: _answers[_index] == i ? p.soft : p.paper,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _answers[_index] == i ? p.brand : p.outline,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Icon(
                                  _answers[_index] == i
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: _answers[_index] == i
                                      ? p.brand
                                      : p.sub,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(o, style: text.bodyLarge)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: LgButton.secondary(
                          key: const ValueKey('tt-run-prev'),
                          label: l.lecturePrev,
                          onPressed: _index == 0
                              ? null
                              : () => setState(() => _index--),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LgButton.secondary(
                          key: const ValueKey('tt-run-next'),
                          label: l.lectureNext,
                          onPressed: last
                              ? null
                              : () => setState(() => _index++),
                        ),
                      ),
                    ],
                  ),
                  LgSectionTitle(l.examMap),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (var i = 0; i < run.questions.length; i++)
                        LgChoiceChip(
                          key: ValueKey('tt-run-map-$i'),
                          label: '${i + 1}${_answers[i] >= 0 ? ' ✓' : ''}',
                          selected: i == _index,
                          onTap: () => setState(() => _index = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  LgButton(
                    key: const ValueKey('tt-run-submit'),
                    label: l.ttSubmit,
                    icon: Icons.flag_circle_outlined,
                    onPressed: () => _submit(),
                  ),
                ],
              ),
      ),
    );
  }
}

// --------------------------------------------------- taklifnoma (rozilik)

/// Talaba ustoz bergan taklifnoma kodini kiritadi, guruh va ustozga nima
/// ko'rinishini o'qiydi va O'ZI rozilik beradi (yoki rad etadi — hech narsa
/// yozilmaydi). Hisobsiz — kirish taklifi (ClassesGate).
class TtInviteAcceptScreen extends StatefulWidget {
  const TtInviteAcceptScreen({super.key, this.token});

  final String? token;

  @override
  State<TtInviteAcceptScreen> createState() => _TtInviteAcceptScreenState();
}

class _TtInviteAcceptScreenState extends State<TtInviteAcceptScreen> {
  late final _code = TextEditingController(text: widget.token ?? '');
  final _nick = TextEditingController();
  TtInvitePreview? _preview;
  String? _token;
  String? _error;
  bool _busy = false;
  bool _consent = false;
  bool _auto = false;

  @override
  void dispose() {
    _code.dispose();
    _nick.dispose();
    super.dispose();
  }

  Future<void> _check(TeacherTestBackend api) async {
    final l = AppLocalizations.of(context);
    final token = TtInviteCode.normalize(_code.text);
    if (token == null) {
      setState(() => _error = l.ttInviteNotFound);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _preview = null;
      _consent = false;
    });
    try {
      final p = await api.previewInvite(token);
      if (mounted) {
        setState(() {
          _preview = p;
          _token = token;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(
          () => _error =
              e is BackendException && e.failure == BackendFailure.notFound
              ? l.ttInviteNotFound
              : ttErrorText(e, l),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _accept(TeacherTestBackend api) async {
    final l = AppLocalizations.of(context);
    final token = _token;
    if (token == null || !_consent) return;
    final nick = normalizeNickname(_nick.text);
    if (!nicknameAllowed(nick)) {
      setState(() => _error = l.classesNicknameInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final gid = await api.acceptInvite(
        token,
        displayName: nick.isEmpty ? null : nick,
      );
      if (!mounted) return;
      showSnack(context, l.ttInviteJoined);
      context.go('/learn/classes/g/$gid');
    } on Object catch (e) {
      if (mounted) setState(() => _error = ttErrorText(e, l));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.ttInviteAcceptTitle,
      children: [
        TeacherProGate(
          builder: (context, api) {
            if (!_auto && TtInviteCode.normalize(widget.token) != null) {
              _auto = true;
              WidgetsBinding.instance.addPostFrameCallback((_) => _check(api));
            }
            return _body(context, l, api);
          },
        ),
      ],
    );
  }

  Widget _body(BuildContext context, AppLocalizations l, TeacherTestBackend api) {
    final text = Theme.of(context).textTheme;
    final p = _preview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgField(
          key: const ValueKey('tt-invite-code'),
          label: l.ttInviteCodeField,
          controller: _code,
          hint: 'ABCD-EFGH-JKLM',
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _check(api),
        ),
        const SizedBox(height: 10),
        LgButton.secondary(
          key: const ValueKey('tt-invite-check'),
          label: l.ttInviteCheck,
          busy: _busy && p == null,
          onPressed: _busy ? null : () => _check(api),
        ),
        if (p != null) ...[
          LgSectionTitle(l.ttInviteGroupTitle),
          LgPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(p.groupName, style: text.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${l.classesRoleTeacher}: ${p.teacherAlias ?? l.classesRoleTeacher}',
                  style: text.bodyMedium,
                ),
              ],
            ),
          ),
          if (p.ownGroup)
            LgNotice(l.ttInviteOwn, kind: NoticeKind.info)
          else if (p.alreadyMember) ...[
            LgNotice(l.ttInviteAlready, kind: NoticeKind.info),
            LgButton(
              label: l.ttInviteOpenGroup,
              onPressed: () => context.go('/learn/classes/g/${p.groupId}'),
            ),
          ] else ...[
            LgNotice(
              l.ttInviteConsentBody,
              title: l.ttInviteConsentTitle,
              kind: NoticeKind.info,
            ),
            CheckboxListTile(
              key: const ValueKey('tt-invite-consent'),
              contentPadding: EdgeInsets.zero,
              value: _consent,
              onChanged: (v) => setState(() => _consent = v ?? false),
              title: Text(l.ttInviteConsentCheck),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            LgField(
              key: const ValueKey('tt-invite-nick'),
              label: l.ttInviteNickname,
              controller: _nick,
              maxLength: 24,
            ),
            Text(l.classesNicknameNote, style: text.bodySmall),
            const SizedBox(height: 12),
            LgButton(
              key: const ValueKey('tt-invite-accept'),
              label: l.ttInviteAccept,
              busy: _busy,
              onPressed: _consent && !_busy ? () => _accept(api) : null,
            ),
            LgButton.link(
              key: const ValueKey('tt-invite-decline'),
              label: l.ttInviteDecline,
              // Rad etish — serverga hech narsa yuborilmaydi.
              onPressed: () => context.canPop()
                  ? context.pop()
                  : context.go('/learn/classes'),
            ),
          ],
        ],
        if (_error case final e?) LgNotice(e, kind: NoticeKind.error),
      ],
    );
  }
}
