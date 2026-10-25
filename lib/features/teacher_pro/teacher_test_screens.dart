import 'dart:async';

import 'package:flutter/services.dart';
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
import '../content/ui/content_widgets.dart' show ContentGate;
import '../learn/exam_question.dart';
import '../learn/exam_widgets.dart' show confirmDialog, showSnack;
import '../profile/pro_gate.dart';
import '../support/support_screens.dart' show formatWhen;
import 'teacher_pro_common.dart';

// Ustoz Pro — test yaratish (Feature.teacherTestBuilder). Ko'rish (ro'yxat,
// test, natijalar) obunasiz ham ochiq (D-78 §7: ma'lumot yashirilmaydi);
// YANGI test, tahrir va saqlash — boshlanishidan oldin gate.

// ------------------------------------------------------------ ro'yxat

class TeacherTestsScreen extends StatefulWidget {
  const TeacherTestsScreen({super.key});

  @override
  State<TeacherTestsScreen> createState() => _TeacherTestsScreenState();
}

class _TeacherTestsScreenState extends State<TeacherTestsScreen> {
  final _tests = TtLoad<List<TeacherTest>>();
  String? _loadedFor = '';

  Future<void> _load(TeacherTestBackend api) async {
    if (_tests.loading) return;
    final services = context.services;
    final uid = services.backend.userId;
    setState(() {
      _tests
        ..loading = true
        ..error = null;
    });
    try {
      final list = await api.teacherTests();
      await services.teacherTestCache.saveTests(uid, list);
      if (mounted) {
        setState(() {
          _tests
            ..data = list
            ..fromCache = false;
        });
      }
    } on Object catch (e) {
      // Internetsiz — oxirgi saqlangan ro'yxat (halol belgi bilan).
      final cached = services.teacherTestCache.tests(uid);
      if (mounted) {
        setState(() {
          if (cached != null &&
              e is BackendException &&
              e.failure == BackendFailure.network) {
            _tests
              ..data = cached
              ..fromCache = true;
          } else {
            _tests.error = e;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _tests.loading = false);
    }
  }

  Future<void> _open(TeacherTestBackend api, String path) async {
    await context.push(path);
    if (mounted) await _load(api);
  }

  Future<void> _create(TeacherTestBackend api) async {
    await pushGated(context, Feature.teacherTestBuilder, TtRoutes.newTest);
    if (mounted) await _load(api);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.ttTestsTitle,
      subtitle: l.proTierNameTeacher,
      children: [
        TeacherProGate(
          builder: (context, api) {
            final uid = context.services.backend.userId;
            if (_loadedFor != uid) {
              _loadedFor = uid;
              _tests
                ..data = null
                ..error = null;
              WidgetsBinding.instance.addPostFrameCallback((_) => _load(api));
            }
            return ListenableBuilder(
              listenable: context.services.entitlements,
              builder: (context, _) => _body(context, l, api),
            );
          },
        ),
      ],
    );
  }

  Widget _body(BuildContext context, AppLocalizations l, TeacherTestBackend api) {
    final ent = context.services.entitlements;
    final locked = !ent.can(Feature.teacherTestBuilder);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (locked) LgNotice(l.ttLockedNote, title: l.proLockedTeacher),
        LgButton(
          key: const ValueKey('tt-new'),
          label: l.ttNewTest,
          icon: Icons.add_rounded,
          onPressed: () => _create(api),
        ),
        const SizedBox(height: 10),
        LgButton.secondary(
          key: const ValueKey('tt-invites'),
          label: l.ttInvitesTitle,
          icon: Icons.mail_outline_rounded,
          onPressed: () => _open(api, TtRoutes.invites),
        ),
        LgSectionTitle(l.ttTestsTitle),
        ttLoadState(context, _tests, () => _load(api), (tests) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_tests.fromCache)
                LgNotice(l.ttOfflineCached, kind: NoticeKind.info),
              if (tests.isEmpty)
                LgStateView(
                  kind: StateKind.empty,
                  title: l.ttTestsEmpty,
                  message: l.ttTestsEmptyBody,
                )
              else
                for (final (i, t) in tests.indexed)
                  LgRow(
                    key: ValueKey('tt-test-${t.id}'),
                    title: t.title,
                    subtitle: [
                      t.published
                          ? l.ttStatusPublished
                          : l.ttStatusUnpublished,
                      l.ttQuestionsCount(t.questionCount),
                      if (t.assignmentCount > 0)
                        l.ttAssignedCount(t.assignmentCount),
                    ].join(' · '),
                    icon: t.published
                        ? Icons.assignment_turned_in_outlined
                        : Icons.edit_note_rounded,
                    divider: i < tests.length - 1,
                    onTap: () => _open(api, TtRoutes.test(t.id)),
                  ),
            ],
          );
        }),
      ],
    );
  }
}

// ------------------------------------------------------- test sahifasi

class TeacherTestDetailScreen extends StatefulWidget {
  const TeacherTestDetailScreen({super.key, required this.testId});

  final String testId;

  @override
  State<TeacherTestDetailScreen> createState() =>
      _TeacherTestDetailScreenState();
}

class _Detail {
  const _Detail(this.test, this.assignments);
  final TeacherTest test;
  final List<TtAssignment> assignments;
}

class _TeacherTestDetailScreenState extends State<TeacherTestDetailScreen> {
  final _data = TtLoad<_Detail>();
  bool _started = false;

  Future<void> _load(TeacherTestBackend api) async {
    if (_data.loading) return;
    final services = context.services;
    setState(() {
      _data
        ..loading = true
        ..error = null;
    });
    try {
      final t = await api.teacherTest(widget.testId);
      final a = await api.teacherAssignments(testId: widget.testId);
      await services.teacherTestCache.putTest(services.backend.userId, t);
      if (mounted) setState(() => _data.data = _Detail(t, a));
    } on Object catch (e) {
      final cached = services.teacherTestCache.test(
        services.backend.userId,
        widget.testId,
      );
      if (mounted) {
        setState(() {
          if (cached?.questions != null &&
              e is BackendException &&
              e.failure == BackendFailure.network) {
            _data
              ..data = _Detail(cached!, const [])
              ..fromCache = true;
          } else {
            _data.error = e;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _data.loading = false);
    }
  }

  Future<void> _go(
    TeacherTestBackend api,
    Feature feature,
    String path,
  ) async {
    await pushGated(context, feature, path);
    if (mounted) await _load(api);
  }

  Future<void> _assign(TeacherTestBackend api) async {
    await pushGated(
      context,
      Feature.teacherTestAssign,
      TtRoutes.assign(widget.testId),
    );
    if (mounted) await _load(api);
  }

  Future<void> _delete(TeacherTestBackend api) async {
    final l = AppLocalizations.of(context);
    final services = context.services;
    final ok = await confirmDialog(
      context,
      title: l.ttDeleteTest,
      body: l.ttDeleteTestBody,
      action: l.actionDelete,
    );
    if (!ok || !mounted) return;
    try {
      await api.deleteTeacherTest(widget.testId);
      await services.teacherTestCache.removeTest(
        services.backend.userId,
        widget.testId,
      );
      if (mounted) context.pop();
    } on Object catch (e) {
      if (mounted) showSnack(context, ttErrorText(e, l));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = _data.data;
    return LgPage(
      title: data?.test.title ?? l.ttTestsTitle,
      titleMaxLines: 3,
      subtitle: l.proTierNameTeacher,
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
              (d) => _body(context, l, api, d),
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
    _Detail d,
  ) {
    final t = d.test;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_data.fromCache) LgNotice(l.ttOfflineCached, kind: NoticeKind.info),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            LgTag(
              t.published ? l.ttStatusPublished : l.ttStatusUnpublished,
              tone: t.published ? LgTone.brand : LgTone.neutral,
            ),
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
        if (t.description case final desc?) ...[
          const SizedBox(height: 10),
          Text(desc, style: text.bodyMedium),
        ],
        const SizedBox(height: 14),
        LgButton(
          key: const ValueKey('tt-assign'),
          label: l.ttAssign,
          icon: Icons.send_rounded,
          onPressed: t.published && !_data.fromCache
              ? () => _assign(api)
              : null,
        ),
        if (!t.published) LgNotice(l.ttMustPublish, kind: NoticeKind.info),
        const SizedBox(height: 10),
        LgButton.secondary(
          key: const ValueKey('tt-edit'),
          label: l.ttEdit,
          icon: Icons.edit_outlined,
          onPressed: _data.fromCache
              ? null
              : () => _go(api, Feature.teacherTestBuilder, TtRoutes.edit(t.id)),
        ),
        LgSectionTitle(l.ttAssignmentsTitle),
        if (d.assignments.isEmpty)
          Text(l.ttNoAssignments, style: text.bodyMedium)
        else
          for (final (i, a) in d.assignments.indexed)
            LgRow(
              key: ValueKey('tt-assignment-${a.id}'),
              title: a.groupName ?? l.ttAssignmentsTitle,
              subtitle: [
                l.ttDueOn(formatWhen(a.dueAt, context)),
                l.ttSubmittedOf(a.submittedCount, a.targetCount),
                if (a.closed) l.ttClosed,
              ].join(' · '),
              icon: a.userId == null
                  ? Icons.groups_outlined
                  : Icons.person_outline_rounded,
              divider: i < d.assignments.length - 1,
              onTap: () async {
                await context.push(TtRoutes.results(a.id));
                if (mounted) await _load(api);
              },
            ),
        LgSectionTitle(l.ttQuestionsTitle),
        for (final (i, q) in (t.questions ?? const <TtQuestion>[]).indexed)
          TtQuestionPreview(index: i, question: q),
        const SizedBox(height: 18),
        LgButton.link(
          key: const ValueKey('tt-delete'),
          label: l.ttDeleteTest,
          icon: Icons.delete_outline_rounded,
          onPressed: _data.fromCache ? null : () => _delete(api),
        ),
      ],
    );
  }
}

/// Savol: matn, variantlar (to'g'risi belgi bilan), izoh, manba.
class TtQuestionPreview extends StatelessWidget {
  const TtQuestionPreview({
    super.key,
    required this.index,
    required this.question,
    this.trailing,
    this.onTap,
  });

  final int index;
  final TtQuestion question;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: LgEyebrow(l.ttQuestionNumber(index + 1))),
            ?trailing,
          ],
        ),
        const SizedBox(height: 4),
        Text(question.text, style: text.titleSmall),
        const SizedBox(height: 6),
        for (final (i, o) in question.options.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  i == question.correct
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: i == question.correct ? p.brand : p.sub,
                  semanticLabel: i == question.correct
                      ? l.ttCorrectAnswer
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(o, style: text.bodyMedium)),
              ],
            ),
          ),
        if (question.explanation case final e?) ...[
          const SizedBox(height: 6),
          Text(e, style: text.bodySmall),
        ],
        if (question.source case final s?) ...[
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: LgTag(
              l.ttFromBank(ttBankName(l, s.bank)),
              tone: LgTone.neutral,
              icon: Icons.content_copy_rounded,
            ),
          ),
        ],
      ],
    );
    return LgPanel(
      child: onTap == null
          ? body
          : LgPressable(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: body,
            ),
    );
  }
}

String ttBankName(AppLocalizations l, TtBank b) => switch (b) {
  TtBank.quiz => l.ttSourceQuiz,
  TtBank.toifa => l.ttSourceToifa,
  TtBank.deck => l.ttSourceDeck,
};

// ---------------------------------------------------------- tahrirlash

class TeacherTestEditScreen extends StatefulWidget {
  const TeacherTestEditScreen({super.key, this.testId});

  /// `null` — yangi test.
  final String? testId;

  @override
  State<TeacherTestEditScreen> createState() => _TeacherTestEditScreenState();
}

class _TeacherTestEditScreenState extends State<TeacherTestEditScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _limit = TextEditingController();
  final _pass = TextEditingController();
  final _questions = <TtQuestion>[];
  bool _published = false;
  int? _version;
  bool _loaded = false;
  Object? _loadError;
  bool _saving = false;
  String? _error;

  bool get _isNew => widget.testId == null;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _limit.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _load(TeacherTestBackend api) async {
    if (_isNew) {
      setState(() => _loaded = true);
      return;
    }
    try {
      final t = await api.teacherTest(widget.testId!);
      if (!mounted) return;
      setState(() {
        _title.text = t.title;
        _description.text = t.description ?? '';
        _limit.text = t.timeLimitMinutes?.toString() ?? '';
        _pass.text = t.passPercent?.toString() ?? '';
        _questions
          ..clear()
          ..addAll(t.questions ?? const []);
        _published = t.published;
        _version = t.version;
        _loaded = true;
        _loadError = null;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _loadError = e);
    }
  }

  int? _int(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : int.tryParse(t) ?? -1;
  }

  TeacherTestInput _input() => TeacherTestInput(
    title: _title.text,
    description: _description.text,
    questions: List.of(_questions),
    published: _published,
    timeLimitMinutes: _int(_limit),
    passPercent: _int(_pass),
    version: _version,
  );

  Future<void> _save(TeacherTestBackend api) async {
    final l = AppLocalizations.of(context);
    final input = _input();
    final invalid = input.validate();
    if (invalid != null) {
      final at = _questions.indexWhere((q) => q.validate() != null);
      setState(
        () => _error = at >= 0 && invalid == _questions[at].validate()
            ? l.ttErrQuestionAt(at + 1, ttValidationText(invalid, l))
            : ttValidationText(invalid, l),
      );
      return;
    }
    // Saqlash — yangi pullik amal: obuna shu orada tugagan bo'lsa, forma
    // yo'qolmaydi, faqat to'lov oynasi ochiladi.
    if (!allowOrOffer(context, Feature.teacherTestBuilder)) return;
    final services = context.services;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = _isNew
          ? await api.createTeacherTest(input)
          : await api.updateTeacherTest(widget.testId!, input);
      await services.teacherTestCache.putTest(services.backend.userId, saved);
      if (!mounted) return;
      showSnack(context, l.ttSaved);
      context.pop(saved.id);
    } on Object catch (e) {
      if (!mounted) return;
      if (!ttOfferIfPlanError(context, e, Feature.teacherTestBuilder)) {
        setState(() => _error = ttErrorText(e, l));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editQuestion([int? index]) async {
    final q = await showTtQuestionDialog(
      context,
      index == null ? null : _questions[index],
      number: (index ?? _questions.length) + 1,
    );
    if (q == null || !mounted) return;
    setState(() {
      if (index == null) {
        _questions.add(q);
      } else {
        _questions[index] = q;
      }
      _error = null;
    });
  }

  Future<void> _fromBank() async {
    final picked = await context.push<List<TtQuestion>>(TtRoutes.bank);
    if (picked == null || picked.isEmpty || !mounted) return;
    setState(() {
      final room = TeacherTestLimits.questions - _questions.length;
      _questions.addAll(picked.take(room < 0 ? 0 : room));
      _error = null;
    });
  }

  void _move(int i, int by) {
    final j = i + by;
    if (j < 0 || j >= _questions.length) return;
    setState(() {
      final q = _questions.removeAt(i);
      _questions.insert(j, q);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: _isNew ? l.ttEditTitleNew : l.ttEditTitle,
      subtitle: l.proTierNameTeacher,
      children: [
        TeacherProGate(
          builder: (context, api) {
            if (!_loaded && _loadError == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_loaded) unawaited(_load(api));
              });
              return LgSkeleton(caption: l.classesLoading);
            }
            if (_loadError != null) {
              return LgStateView(
                kind: StateKind.error,
                title: ttErrorText(_loadError!, l),
                actionLabel: l.actionRetry,
                onAction: () {
                  setState(() => _loadError = null);
                  unawaited(_load(api));
                },
              );
            }
            return _form(context, l, api);
          },
        ),
      ],
    );
  }

  Widget _form(BuildContext context, AppLocalizations l, TeacherTestBackend api) {
    final full = _questions.length >= TeacherTestLimits.questions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgField(
          key: const ValueKey('tt-field-title'),
          label: l.ttFieldTitle,
          controller: _title,
          maxLength: TeacherTestLimits.titleMax,
          textInputAction: TextInputAction.next,
        ),
        LgField(
          key: const ValueKey('tt-field-description'),
          label: l.ttFieldDescription,
          controller: _description,
          maxLines: 3,
          maxLength: TeacherTestLimits.description,
        ),
        LgField(
          key: const ValueKey('tt-field-limit'),
          label: l.ttFieldTimeLimit,
          controller: _limit,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 3,
        ),
        LgField(
          key: const ValueKey('tt-field-pass'),
          label: l.ttFieldPassPercent,
          controller: _pass,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 3,
        ),
        const SizedBox(height: 6),
        SwitchListTile.adaptive(
          key: const ValueKey('tt-publish'),
          contentPadding: EdgeInsets.zero,
          title: Text(l.ttPublishToggle),
          subtitle: Text(l.ttPublishNote),
          value: _published,
          onChanged: (v) => setState(() => _published = v),
        ),
        LgSectionTitle(
          '${l.ttQuestionsTitle} · ${_questions.length}/${TeacherTestLimits.questions}',
        ),
        if (_questions.isEmpty)
          Text(
            l.ttNoQuestionsYet,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        for (final (i, q) in _questions.indexed)
          TtQuestionPreview(
            key: ValueKey('tt-q-$i'),
            index: i,
            question: q,
            onTap: () => _editQuestion(i),
            trailing: Wrap(
              children: [
                IconButton(
                  tooltip: l.ttMoveUp,
                  icon: const Icon(Icons.arrow_upward_rounded),
                  onPressed: i == 0 ? null : () => _move(i, -1),
                ),
                IconButton(
                  tooltip: l.ttMoveDown,
                  icon: const Icon(Icons.arrow_downward_rounded),
                  onPressed: i == _questions.length - 1
                      ? null
                      : () => _move(i, 1),
                ),
                IconButton(
                  key: ValueKey('tt-q-remove-$i'),
                  tooltip: l.ttRemoveQuestion,
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => setState(() => _questions.removeAt(i)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        LgButton.secondary(
          key: const ValueKey('tt-add-question'),
          label: l.ttAddQuestion,
          icon: Icons.add_rounded,
          onPressed: full ? null : () => _editQuestion(),
        ),
        const SizedBox(height: 10),
        LgButton.secondary(
          key: const ValueKey('tt-add-bank'),
          label: l.ttAddFromBank,
          icon: Icons.library_add_outlined,
          onPressed: full ? null : _fromBank,
        ),
        if (_error case final e?) ...[
          const SizedBox(height: 8),
          LgNotice(e, kind: NoticeKind.error),
        ],
        const SizedBox(height: 16),
        LgButton(
          key: const ValueKey('tt-save'),
          label: l.ttSave,
          icon: Icons.check_rounded,
          busy: _saving,
          onPressed: _saving ? null : () => _save(api),
        ),
      ],
    );
  }
}

// ------------------------------------------------------- savol oynasi

/// Savolni yozish/tahrirlash: matn, 2–6 variant (bittasi to'g'ri), izoh.
Future<TtQuestion?> showTtQuestionDialog(
  BuildContext context,
  TtQuestion? initial, {
  required int number,
}) => showDialog<TtQuestion>(
  context: context,
  builder: (context) => _QuestionDialog(initial: initial, number: number),
);

class _QuestionDialog extends StatefulWidget {
  const _QuestionDialog({required this.initial, required this.number});

  final TtQuestion? initial;
  final int number;

  @override
  State<_QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<_QuestionDialog> {
  late final _text = TextEditingController(text: widget.initial?.text);
  late final _explanation = TextEditingController(
    text: widget.initial?.explanation,
  );
  late final List<TextEditingController> _options = [
    for (final o in widget.initial?.options ?? const ['', '', ''])
      TextEditingController(text: o),
  ];
  late int _correct = widget.initial?.correct ?? 0;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    _explanation.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  void _done() {
    final l = AppLocalizations.of(context);
    final explanation = _explanation.text.trim();
    final q = TtQuestion(
      text: _text.text.trim(),
      options: [for (final c in _options) c.text.trim()],
      correct: _correct,
      explanation: explanation.isEmpty ? null : explanation,
      source: widget.initial?.source,
    );
    final invalid = q.validate();
    if (invalid != null) {
      setState(() => _error = ttValidationText(invalid, l));
      return;
    }
    Navigator.of(context).pop(q);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(l.ttQuestionNumber(widget.number)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('tt-dialog-text'),
            controller: _text,
            maxLines: null,
            maxLength: TeacherTestLimits.text,
            decoration: InputDecoration(labelText: l.ttFieldQuestion),
          ),
          Text(l.ttOptionsHint, style: Theme.of(context).textTheme.bodySmall),
          for (final (i, c) in _options.indexed)
            Row(
              children: [
                IconButton(
                  key: ValueKey('tt-dialog-correct-$i'),
                  tooltip: l.ttMarkCorrect,
                  isSelected: i == _correct,
                  icon: Icon(
                    i == _correct
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: i == _correct ? p.brand : p.sub,
                  ),
                  onPressed: () => setState(() => _correct = i),
                ),
                Expanded(
                  child: TextField(
                    key: ValueKey('tt-dialog-option-$i'),
                    controller: c,
                    maxLength: TeacherTestLimits.option,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: l.ttFieldOption(i + 1),
                      counterText: '',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l.ttRemoveOption,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: _options.length <= TeacherTestLimits.optionsMin
                      ? null
                      : () => setState(() {
                          _options.removeAt(i).dispose();
                          if (_correct >= _options.length) {
                            _correct = _options.length - 1;
                          } else if (_correct > i) {
                            _correct--;
                          }
                        }),
                ),
              ],
            ),
          if (_options.length < TeacherTestLimits.optionsMax)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const ValueKey('tt-dialog-add-option'),
                onPressed: () =>
                    setState(() => _options.add(TextEditingController())),
                icon: const Icon(Icons.add_rounded),
                label: Text(l.ttAddOption),
              ),
            ),
          TextField(
            key: const ValueKey('tt-dialog-explanation'),
            controller: _explanation,
            maxLines: null,
            maxLength: TeacherTestLimits.explanation,
            decoration: InputDecoration(labelText: l.ttFieldExplanation),
          ),
          if (_error case final e?) LgNotice(e, kind: NoticeKind.error),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.actionCancel),
        ),
        TextButton(
          key: const ValueKey('tt-dialog-done'),
          onPressed: _done,
          child: Text(l.ttDone),
        ),
      ],
    );
  }
}

// ----------------------------------------------- ilova banki (nusxa)

/// Ilovadagi savollar (mashq savollari va toifa banki) — faqat bitta
/// to'g'ri javobli, 2–6 variantli va kaliti bahsli bo'lmaganlari. Tanlanganlari
/// ustoz testiga NUSXA sifatida (manbasi bilan) qo'shiladi.
class TtBankPickerScreen extends StatefulWidget {
  const TtBankPickerScreen({super.key});

  @override
  State<TtBankPickerScreen> createState() => _TtBankPickerScreenState();
}

class _BankItem {
  const _BankItem(this.bank, this.question);
  final TtBank bank;
  final ExamQuestion question;
}

class _TtBankPickerScreenState extends State<TtBankPickerScreen> {
  final _query = TextEditingController();
  final _picked = <String>{};
  TtBank? _bank;

  static const _shown = 100;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  static bool _usable(ExamQuestion q) =>
      q.correct.length == 1 &&
      q.optionCount >= TeacherTestLimits.optionsMin &&
      q.optionCount <= TeacherTestLimits.optionsMax &&
      !q.isDraft &&
      !(q.officialKeyCheck?.flagged ?? false);

  List<_BankItem> _items(BuildContext context, PackQuestionSource pack) {
    final toifa = context.services.toifa.bank;
    return [
      for (final q in pack.questions)
        if (_usable(q)) _BankItem(TtBank.quiz, q),
      if (toifa != null)
        for (final q in toifa.scorable)
          if (_usable(q)) _BankItem(TtBank.toifa, q),
    ];
  }

  /// Joriy til matni bilan nusxa; chegaradan uzun yoki takroriy variantli
  /// savol — `null` (qo'shilmaydi).
  static TtQuestion? copyOf(_BankItem item, String lang) {
    final q = item.question;
    final correct = q.correct.single;
    final copy = TtQuestion(
      text: q.prompt(lang).trim(),
      options: [
        for (var i = 0; i < q.optionCount; i++) q.option(i, lang).trim(),
      ],
      correct: correct,
      explanation: switch (q.explanation(correct, lang) ?? q.basis(lang)) {
        final String e when e.trim().isNotEmpty =>
          e.trim().length > TeacherTestLimits.explanation
              ? null
              : e.trim(),
        _ => null,
      },
      source: TtSource(item.bank, q.id),
    );
    return copy.validate() == null ? copy : null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return LgPage(
      title: l.ttBankTitle,
      subtitle: l.ttBankSubtitle,
      children: [
        ContentGate(
          builder: (context, pack) {
            final all = _items(context, PackQuestionSource.of(pack));
            final q = _query.text.trim().toLowerCase();
            final filtered = [
              for (final it in all)
                if ((_bank == null || it.bank == _bank) &&
                    (q.isEmpty ||
                        it.question.prompt(lang).toLowerCase().contains(q)))
                  it,
            ];
            final hasToifa = all.any((i) => i.bank == TtBank.toifa);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LgField(
                  key: const ValueKey('tt-bank-search'),
                  label: l.ttBankSearch,
                  controller: _query,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    LgChoiceChip(
                      label: l.ttBankAll,
                      selected: _bank == null,
                      onTap: () => setState(() => _bank = null),
                    ),
                    LgChoiceChip(
                      label: l.ttSourceQuiz,
                      selected: _bank == TtBank.quiz,
                      onTap: () => setState(() => _bank = TtBank.quiz),
                    ),
                    if (hasToifa)
                      LgChoiceChip(
                        label: l.ttSourceToifa,
                        selected: _bank == TtBank.toifa,
                        onTap: () => setState(() => _bank = TtBank.toifa),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                LgButton(
                  key: const ValueKey('tt-bank-add'),
                  label: l.ttBankAdd(_picked.length),
                  icon: Icons.library_add_check_outlined,
                  onPressed: _picked.isEmpty
                      ? null
                      : () {
                          final out = <TtQuestion>[
                            for (final it in all)
                              if (_picked.contains('${it.bank.name}:${it.question.id}'))
                                ?copyOf(it, lang),
                          ];
                          context.pop(out);
                        },
                ),
                const SizedBox(height: 8),
                if (filtered.isEmpty)
                  LgStateView(kind: StateKind.empty, title: l.ttBankEmpty)
                else ...[
                  if (filtered.length > _shown)
                    Text(
                      l.ttBankRefine(filtered.length),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  for (final it in filtered.take(_shown))
                    CheckboxListTile(
                      key: ValueKey('tt-bank-${it.question.id}'),
                      contentPadding: EdgeInsets.zero,
                      value: _picked.contains(
                        '${it.bank.name}:${it.question.id}',
                      ),
                      onChanged: (v) => setState(() {
                        final k = '${it.bank.name}:${it.question.id}';
                        if (v ?? false) {
                          _picked.add(k);
                        } else {
                          _picked.remove(k);
                        }
                      }),
                      title: Text(
                        it.question.prompt(lang),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(ttBankName(l, it.bank)),
                    ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
