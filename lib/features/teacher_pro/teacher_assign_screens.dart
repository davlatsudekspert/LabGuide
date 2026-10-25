import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/backend/backend_models.dart';
import '../../core/backend/teacher_tests.dart';
import '../../core/entitlements/feature.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../classroom/assign_controls.dart'
    show AssignDue, assignDueAt, pickAssignDueDate;
import '../learn/exam_widgets.dart' show confirmDialog, showSnack;
import '../profile/pro_gate.dart';
import '../support/support_screens.dart' show formatWhen;
import 'teacher_pro_common.dart';

// Ustoz Pro — talabalarni biriktirish va testni topshirish
// (Feature.teacherTestAssign). Bepul guruhlar (kod bilan qo'shilish,
// a'zolarni chiqarish, bepul topshiriqlar) o'zgarmaydi; bu yerda — YANGI
// imkoniyatlar: muddatli taklifnoma (talabaning aniq roziligi bilan), o'z
// testini guruhga yoki bitta talabaga muddat va urinishlar soni bilan berish.

/// Talabaning guruhdagi ko'rinadigan nomi (ustozning lokal belgisi bilan).
String ttStudentLabel(
  BuildContext context,
  String groupId,
  String userId, {
  String? alias,
  int? seatNo,
}) {
  final l = AppLocalizations.of(context);
  final base =
      alias ??
      (seatNo == null
          ? l.classesRoleStudent
          : l.classesSeat(seatNo.toString().padLeft(2, '0')));
  final local = context.services.classroom.localName(groupId, userId);
  return local == null ? base : '$local · $base';
}

/// Ustozning o'z guruhlari (bepul guruhlar ro'yxatidan).
Future<List<StudyGroup>> ttTeacherGroups(BuildContext context) async => [
  for (final g in await context.services.backend.myGroups())
    if (g.isTeacher) g,
];

// ------------------------------------------------------------ topshirish

class TtAssignScreen extends StatefulWidget {
  const TtAssignScreen({super.key, required this.testId});

  final String testId;

  @override
  State<TtAssignScreen> createState() => _TtAssignScreenState();
}

class _TtAssignScreenState extends State<TtAssignScreen> {
  final _groups = TtLoad<List<StudyGroup>>();
  String? _groupId;
  List<GroupMember>? _members;
  String? _userId;
  AssignDue _due = AssignDue.d3;
  DateTime? _custom;
  int _attempts = 1;
  bool _acceptLate = false;
  bool _busy = false;
  String? _error;
  bool _started = false;

  Future<void> _load() async {
    setState(() {
      _groups
        ..loading = true
        ..error = null;
    });
    try {
      final g = await ttTeacherGroups(context);
      if (!mounted) return;
      setState(() => _groups.data = g);
      if (g.isNotEmpty) await _pickGroup(g.first.id);
    } on Object catch (e) {
      if (mounted) setState(() => _groups.error = e);
    } finally {
      if (mounted) setState(() => _groups.loading = false);
    }
  }

  Future<void> _pickGroup(String id) async {
    setState(() {
      _groupId = id;
      _userId = null;
      _members = null;
    });
    try {
      final m = await context.services.backend.groupMembers(id);
      if (mounted && _groupId == id) {
        setState(
          () => _members = [
            for (final x in m)
              if (!x.isTeacher) x,
          ],
        );
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() => _error = ttErrorText(e, AppLocalizations.of(context)));
      }
    }
  }

  Future<void> _pickDate() async {
    final now = context.services.exams.now();
    final d = await pickAssignDueDate(context, now, _custom);
    if (d != null && mounted) {
      setState(() {
        _custom = d;
        _due = AssignDue.custom;
      });
    }
  }

  Future<void> _submit(TeacherTestBackend api) async {
    final l = AppLocalizations.of(context);
    final gid = _groupId;
    if (gid == null) return;
    // Topshirish — yangi pullik amal (obuna shu orada tugagan bo'lsa ham
    // tanlovlar yo'qolmaydi).
    if (!await requireFeature(context, Feature.teacherTestAssign) || !mounted) {
      return;
    }
    final due = assignDueAt(_due, _custom, context.services.exams.now());
    if (due == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await api.assignTeacherTest(
        widget.testId,
        groupId: gid,
        userId: _userId,
        dueAt: due,
        maxAttempts: _attempts,
        acceptLate: _acceptLate,
      );
      if (!mounted) return;
      showSnack(context, l.ttAssigned);
      context.pop(true);
    } on Object catch (e) {
      if (mounted &&
          !ttOfferIfPlanError(context, e, Feature.teacherTestAssign)) {
        setState(() => _error = ttErrorText(e, l));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.ttAssignTitle,
      subtitle: l.proTierNameTeacher,
      children: [
        TeacherProGate(
          builder: (context, api) {
            if (!_started) {
              _started = true;
              WidgetsBinding.instance.addPostFrameCallback((_) => _load());
            }
            return ttLoadState(
              context,
              _groups,
              _load,
              (groups) => _body(context, l, api, groups),
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
    List<StudyGroup> groups,
  ) {
    final text = Theme.of(context).textTheme;
    if (groups.isEmpty) {
      return LgStateView(
        kind: StateKind.empty,
        title: l.ttAssignNoGroups,
        actionLabel: l.classesCreate,
        onAction: () async {
          await context.push('/learn/classes/new');
          if (mounted) await _load();
        },
      );
    }
    final due = assignDueAt(_due, _custom, context.services.exams.now());
    final members = _members;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.ttAssignGroup),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in groups)
              LgChoiceChip(
                key: ValueKey('tt-group-${g.id}'),
                label: g.name,
                selected: _groupId == g.id,
                onTap: () => _pickGroup(g.id),
              ),
          ],
        ),
        LgSectionTitle(l.ttAssignWho),
        if (members == null)
          LgSkeleton(rows: 1, caption: l.classesLoading)
        else ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LgChoiceChip(
                key: const ValueKey('tt-who-all'),
                label: l.ttAssignWholeGroup,
                selected: _userId == null,
                onTap: () => setState(() => _userId = null),
              ),
              for (final m in members)
                LgChoiceChip(
                  key: ValueKey('tt-who-${m.userId}'),
                  label: ttStudentLabel(
                    context,
                    _groupId!,
                    m.userId,
                    alias: m.alias,
                    seatNo: m.seatNo,
                  ),
                  selected: _userId == m.userId,
                  onTap: () => setState(() => _userId = m.userId),
                ),
            ],
          ),
          if (members.isEmpty) ...[
            const SizedBox(height: 8),
            Text(l.ttAssignNoStudents, style: text.bodyMedium),
          ],
        ],
        LgSectionTitle(l.ttAssignDue),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (d, days) in [
              (AssignDue.d1, 1),
              (AssignDue.d3, 3),
              (AssignDue.d7, 7),
            ])
              LgChoiceChip(
                key: ValueKey('tt-due-${d.name}'),
                label: l.classesDueDays(days),
                selected: _due == d,
                onTap: () => setState(() => _due = d),
              ),
            LgChoiceChip(
              label: l.classesDuePick,
              selected: _due == AssignDue.custom,
              onTap: _pickDate,
            ),
          ],
        ),
        if (due != null) ...[
          const SizedBox(height: 8),
          Text(
            l.classesDueAt(formatWhen(due, context)),
            style: text.bodyMedium,
          ),
        ],
        LgSectionTitle(l.ttAssignAttempts),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var n = 1; n <= 3; n++)
              LgChoiceChip(
                key: ValueKey('tt-attempts-$n'),
                label: '$n',
                selected: _attempts == n,
                onTap: () => setState(() => _attempts = n),
              ),
          ],
        ),
        const SizedBox(height: 6),
        SwitchListTile.adaptive(
          key: const ValueKey('tt-late'),
          contentPadding: EdgeInsets.zero,
          title: Text(l.ttAssignLate),
          value: _acceptLate,
          onChanged: (v) => setState(() => _acceptLate = v),
        ),
        LgNotice(l.ttAssignPrivacy, kind: NoticeKind.info),
        if (_error case final e?) LgNotice(e, kind: NoticeKind.error),
        const SizedBox(height: 12),
        LgButton(
          key: const ValueKey('tt-assign-submit'),
          label: l.ttAssignSubmit,
          icon: Icons.send_rounded,
          busy: _busy,
          onPressed: _busy || _groupId == null || due == null
              ? null
              : () => _submit(api),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ taklifnoma

class TtInvitesScreen extends StatefulWidget {
  const TtInvitesScreen({super.key});

  @override
  State<TtInvitesScreen> createState() => _TtInvitesScreenState();
}

class _TtInvitesScreenState extends State<TtInvitesScreen> {
  final _groups = TtLoad<List<StudyGroup>>();
  final _invites = TtLoad<List<TtInvite>>();
  String? _groupId;
  int _days = 7;
  int _uses = 50;
  bool _busy = false;
  bool _started = false;

  Future<void> _load(TeacherTestBackend api) async {
    setState(() {
      _groups
        ..loading = true
        ..error = null;
    });
    try {
      final g = await ttTeacherGroups(context);
      if (!mounted) return;
      setState(() => _groups.data = g);
      if (g.isNotEmpty) await _pick(api, _groupId ?? g.first.id);
    } on Object catch (e) {
      if (mounted) setState(() => _groups.error = e);
    } finally {
      if (mounted) setState(() => _groups.loading = false);
    }
  }

  Future<void> _pick(TeacherTestBackend api, String gid) async {
    setState(() {
      _groupId = gid;
      _invites
        ..data = null
        ..error = null;
    });
    try {
      final list = await api.groupInvites(gid);
      if (mounted && _groupId == gid) setState(() => _invites.data = list);
    } on Object catch (e) {
      if (mounted) setState(() => _invites.error = e);
    }
  }

  Future<void> _create(TeacherTestBackend api) async {
    final gid = _groupId;
    if (gid == null) return;
    // Taklifnoma — Ustoz Pro'ning yangi amali.
    if (!allowOrOffer(context, Feature.teacherTestAssign)) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await api.createInvite(gid, maxUses: _uses, days: _days);
      if (mounted) await _pick(api, gid);
    } on Object catch (e) {
      if (mounted &&
          !ttOfferIfPlanError(context, e, Feature.teacherTestAssign)) {
        showSnack(context, ttErrorText(e, l));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy(TtInvite i, String group) async {
    final l = AppLocalizations.of(context);
    await Clipboard.setData(
      ClipboardData(
        text: l.ttInviteShareText(
          group,
          TtInviteCode.format(i.token),
          TtInviteCode.appLink(i.token),
        ),
      ),
    );
    if (mounted) showSnack(context, l.ttInviteCopied);
  }

  Future<void> _revoke(TeacherTestBackend api, TtInvite i) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.ttInviteRevoke,
      body: l.ttInviteRevokeBody,
      action: l.ttInviteRevoke,
    );
    if (!ok || !mounted) return;
    try {
      await api.revokeInvite(i.id);
      if (mounted) await _pick(api, i.groupId);
    } on Object catch (e) {
      if (mounted) showSnack(context, ttErrorText(e, l));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.ttInvitesTitle,
      subtitle: l.ttInvitesSubtitle,
      children: [
        TeacherProGate(
          builder: (context, api) {
            if (!_started) {
              _started = true;
              WidgetsBinding.instance.addPostFrameCallback((_) => _load(api));
            }
            return ttLoadState(
              context,
              _groups,
              () => _load(api),
              (groups) => _body(context, l, api, groups),
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
    List<StudyGroup> groups,
  ) {
    if (groups.isEmpty) {
      return LgStateView(
        kind: StateKind.empty,
        title: l.ttAssignNoGroups,
        actionLabel: l.classesCreate,
        onAction: () async {
          await context.push('/learn/classes/new');
          if (mounted) await _load(api);
        },
      );
    }
    final text = Theme.of(context).textTheme;
    final group = groups.where((g) => g.id == _groupId).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.ttAssignGroup),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in groups)
              LgChoiceChip(
                key: ValueKey('tt-inv-group-${g.id}'),
                label: g.name,
                selected: _groupId == g.id,
                onTap: () => _pick(api, g.id),
              ),
          ],
        ),
        LgSectionTitle(l.ttInviteDays),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final d in const [1, 7, 30])
              LgChoiceChip(
                key: ValueKey('tt-inv-days-$d'),
                label: l.classesDueDays(d),
                selected: _days == d,
                onTap: () => setState(() => _days = d),
              ),
          ],
        ),
        LgSectionTitle(l.ttInviteMaxUses),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final n in const [1, 50, 200])
              LgChoiceChip(
                key: ValueKey('tt-inv-uses-$n'),
                label: '$n',
                selected: _uses == n,
                onTap: () => setState(() => _uses = n),
              ),
          ],
        ),
        const SizedBox(height: 12),
        LgButton(
          key: const ValueKey('tt-inv-create'),
          label: l.ttInviteCreate,
          icon: Icons.add_link_rounded,
          busy: _busy,
          onPressed: _busy ? null : () => _create(api),
        ),
        LgNotice(l.ttInviteHowTo, kind: NoticeKind.info),
        LgSectionTitle(l.ttInvitesActive),
        ttLoadState(context, _invites, () => _pick(api, _groupId!), (list) {
          final active = [
            for (final i in list)
              if (i.active) i,
          ];
          if (active.isEmpty) {
            return Text(l.ttInvitesEmpty, style: text.bodyMedium);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final i in active)
                LgPanel(
                  key: ValueKey('tt-invite-${i.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SelectableText(
                        TtInviteCode.format(i.token),
                        style: text.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l.ttInviteUses(i.uses, i.maxUses)} · '
                        '${l.ttInviteUntil(formatWhen(i.expiresAt, context))}',
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      LgButton.secondary(
                        label: l.ttInviteCopy,
                        icon: Icons.copy_rounded,
                        onPressed: () => _copy(i, group?.name ?? ''),
                      ),
                      LgButton.link(
                        label: l.ttInviteRevoke,
                        icon: Icons.block_rounded,
                        onPressed: () => _revoke(api, i),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}
