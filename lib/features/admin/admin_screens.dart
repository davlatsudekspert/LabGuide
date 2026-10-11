import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../core/backend/admin_team.dart';
import '../../core/backend/backend_models.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/otp_auth.dart' show isValidEmail, normalizeEmail;
import '../learn/exam_widgets.dart' show confirmDialog;
import '../partners/partner_admin_screens.dart' show AdminPartnerRequestsRow;
import '../support/support_screens.dart';

/// Admin bo'limlariga kirish: server admin hisobi deb tasdiqlagan bo'lishi
/// va sessiya ikki bosqichli (aal2) bo'lishi kerak. Aks holda — 2FA oynasi
/// yoki “faqat admin uchun”. Bu faqat ko'rinish: serverdagi har funksiya
/// vakolatni o'zi qayta tekshiradi.
class AdminGate extends StatefulWidget {
  const AdminGate({super.key, required this.child, this.mfaHint});

  final Widget child;

  /// 2FA oynasi tepasida ko'rsatiladigan qisqa yo'l-yo'riq (ixtiyoriy).
  final String? mfaHint;

  /// Gate ichidagi vakolat (gate tashqarisida — `null`).
  static AccessInfo? accessOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AdminAccessScope>()?.access;

  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  AccessInfo? _access;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    final backend = context.services.backend;
    if (!backend.isConfigured || !backend.hasSession) {
      setState(() => _access = AccessInfo.none);
      return;
    }
    try {
      final a = await backend.myAccess();
      if (mounted) setState(() => _access = a);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final a = _access;
    if (_error != null) {
      return LgStateView(
        kind: StateKind.error,
        title: backendErrorText(_error!, l),
        actionLabel: l.actionRetry,
        onAction: () {
          setState(() => _error = null);
          _check();
        },
      );
    }
    if (a == null) return const LgStateView(kind: StateKind.loading, title: '');
    if (!a.adminAccount) {
      return LgStateView(
        kind: StateKind.unavailable,
        title: l.adminForbiddenTitle,
        message: l.adminForbiddenBody,
      );
    }
    if (!a.aal2) {
      final hint = widget.mfaHint;
      final panel = _MfaPanel(
        onVerified: () {
          // Tasdiqlash tugmasi uchun pastga aylantirilgan bo'lishi mumkin:
          // panel tepasidan (holat kartasidan) boshlansin.
          final pos = Scrollable.maybeOf(context)?.position;
          if (pos != null && pos.hasPixels) pos.jumpTo(pos.minScrollExtent);
          _check();
        },
      );
      if (hint == null) return panel;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgNotice(hint, kind: NoticeKind.info),
          const SizedBox(height: 12),
          panel,
        ],
      );
    }
    return _AdminAccessScope(access: a, child: widget.child);
  }
}

/// [AdminGate] o'tgan bolalar uchun server vakolati (masalan, super admin
/// belgisi) — qayta so'rov yubormasdan.
class _AdminAccessScope extends InheritedWidget {
  const _AdminAccessScope({required this.access, required super.child});

  final AccessInfo access;

  @override
  bool updateShouldNotify(_AdminAccessScope old) => old.access != access;
}

class _MfaPanel extends StatefulWidget {
  const _MfaPanel({required this.onVerified});

  final VoidCallback onVerified;

  @override
  State<_MfaPanel> createState() => _MfaPanelState();
}

class _MfaPanelState extends State<_MfaPanel> {
  MfaStatus? _status;
  TotpEnrollment? _enrollment;
  final _code = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final l = AppLocalizations.of(context);
    final backend = context.services.backend;
    try {
      final s = await backend.mfaStatus();
      TotpEnrollment? e;
      if (s.verifiedFactorId == null) e = await backend.mfaEnroll();
      if (!mounted) return;
      setState(() {
        _status = s;
        _enrollment = e;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _error = backendErrorText(e, l));
    }
  }

  Future<void> _verify() async {
    final l = AppLocalizations.of(context);
    final factorId = _status?.verifiedFactorId ?? _enrollment?.factorId;
    if (factorId == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.services.backend.mfaVerify(
        factorId: factorId,
        code: _code.text,
      );
      widget.onVerified();
    } on BackendException catch (e) {
      if (mounted) {
        setState(
          () => _error = e.failure == BackendFailure.invalid
              ? l.adminMfaWrong
              : backendErrorText(e, l),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final e = _enrollment;
    if (_status == null && _error == null) {
      return const LgStateView(kind: StateKind.loading, title: '');
    }
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.adminMfaTitle, style: text.titleMedium),
          const SizedBox(height: 8),
          Text(
            e == null ? l.adminMfaVerifyBody : l.adminMfaEnrollBody,
            style: text.bodyMedium,
          ),
          if (e != null) ...[
            const SizedBox(height: 12),
            Text(l.adminMfaSecret, style: text.titleSmall),
            const SizedBox(height: 4),
            SelectableText(
              e.secret,
              style: text.titleMedium!.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            LgButton.secondary(
              label: l.adminMfaCopy,
              icon: Icons.copy_rounded,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: e.secret));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(l.adminCopied)));
              },
            ),
            const SizedBox(height: 8),
            LgButton.secondary(
              label: l.adminMfaOpen,
              icon: Icons.open_in_new_rounded,
              onPressed: () => openExternalLink(context, e.uri),
            ),
          ],
          LgField(
            label: l.adminMfaCode,
            controller: _code,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofillHints: const [AutofillHints.oneTimeCode],
            onSubmitted: (_) => _verify(),
          ),
          if (_error != null) LgNotice(_error!, kind: NoticeKind.error),
          const SizedBox(height: 12),
          LgButton(label: l.adminMfaVerify, busy: _busy, onPressed: _verify),
        ],
      ),
    );
  }
}

/// Bo'lim ma'lumoti: yuklanmoqda / tayyor / bu serverda yo'q / xato.
@immutable
class _Slot<T> {
  const _Slot() : value = null, error = null, unavailable = false;
  const _Slot.ready(T this.value) : error = null, unavailable = false;
  const _Slot.unavailable() : value = null, error = null, unavailable = true;
  const _Slot.failed(Object this.error) : value = null, unavailable = false;

  final T? value;
  final Object? error;

  /// Server bu bo'limni hali bermaydi (`501`) — ishlayotgandek ko'rsatilmaydi.
  final bool unavailable;
}

Future<_Slot<T>> _slot<T>(Future<T> Function() load) async {
  try {
    return _Slot.ready(await load());
  } on BackendException catch (e) {
    return e.failure == BackendFailure.unavailable
        ? const _Slot.unavailable()
        : _Slot.failed(e);
  } on Object catch (e) {
    return _Slot.failed(e);
  }
}

/// Admin panel — bitta boshqaruv sahifasi: hamjamiyat moderatsiyasi,
/// murojaatlar, kontent tekshiruvi, adminlar boshqaruvi, 2FA holati.
/// Faqat serverdan kelgan haqiqiy son ko'rsatiladi; serverda hali yo'q
/// bo'lim “ulanmagan” deb ochiq aytiladi (bosilmaydi — boshi berk yo'l yo'q).
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  _Slot<AdminStats> _stats = const _Slot();
  _Slot<int> _suspended = const _Slot();
  _Slot<AdminTeam> _team = const _Slot();

  Future<void> _load() async {
    final services = context.services;
    final backend = services.backend;
    final community = services.community.api;
    final team = services.adminTeam;
    final stats = _slot(backend.adminStats);
    final suspended = community == null
        ? null
        : _slot(() async => (await community.adminMembers()).length);
    final members = team == null ? null : _slot(team.adminTeam);
    final st = await stats;
    final su = await suspended;
    final tm = await members;
    if (!mounted) return;
    setState(() {
      _stats = st;
      if (su != null) _suspended = su;
      if (tm != null) _team = tm;
    });
  }

  Future<void> _open(String location) async {
    await context.push(location);
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.adminTitle,
      showProfile: false,
      children: [
        SignedInGate(
          child: AdminGate(
            child: _AutoLoad(
              onLoad: _load,
              child: Builder(builder: (context) => _dashboard(context, l)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dashboard(BuildContext context, AppLocalizations l) {
    final services = context.services;
    final access = AdminGate.accessOf(context);
    final stats = _stats.value;
    final pack = services.content.pack;
    final team = _team.value;
    final awaiting = stats?.support['awaiting_reply'] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AdminStatusPanel(superAdmin: access?.superAdmin ?? false),
        if (services.community.available) ...[
          LgSectionTitle(l.cmAdminTitle),
          LgRow(
            key: const ValueKey('admin-row-reports'),
            title: l.admReportsQueue,
            subtitle: _suspended.error != null
                ? backendErrorText(_suspended.error!, l)
                : _queueText(_suspended.value, l) ?? l.admReportsSub,
            icon: Icons.flag_outlined,
            trailing: _badge(_suspended.value),
            divider: access?.superAdmin ?? false,
            onTap: () => _open('/profile/admin/community'),
          ),
          // Bir tugma faqat egasi uchun (server ham faqat LG_ADMIN_EMAILS).
          if (access?.superAdmin ?? false)
            LgRow(
              key: const ValueKey('admin-row-launch'),
              title: l.admLaunchRow,
              subtitle: l.admLaunchRowSub,
              icon: Icons.rocket_launch_outlined,
              divider: false,
              onTap: () => _open('/profile/admin/community'),
            ),
        ],
        LgSectionTitle(l.supportTitle),
        if (_stats.unavailable)
          LgRow(
            key: const ValueKey('admin-row-inbox'),
            title: l.adminInbox,
            subtitle: l.admNotConnected,
            icon: Icons.inbox_outlined,
            divider: false,
          )
        else
          LgRow(
            key: const ValueKey('admin-row-inbox'),
            title: l.adminInbox,
            subtitle: _stats.error != null
                ? backendErrorText(_stats.error!, l)
                : stats == null
                ? null
                : l.adminAwaiting(awaiting),
            icon: Icons.inbox_outlined,
            trailing: stats == null ? null : _badge(awaiting),
            divider: false,
            onTap: () => _open('/profile/admin/inbox'),
          ),
        LgSectionTitle(l.admReview),
        LgRow(
          key: const ValueKey('admin-row-review'),
          title: l.libReview,
          subtitle: pack == null
              ? l.libReviewSub
              : l.admReviewSub(
                  pack.analytes.where((a) => !a.isReviewerApproved).length,
                  pack.quiz.where((q) => q.isDraft).length,
                ),
          icon: Icons.rule_rounded,
          divider: false,
          onTap: () => _open('/library/review'),
        ),
        if (services.adminTeam != null) ...[
          LgSectionTitle(l.admTeam),
          LgRow(
            key: const ValueKey('admin-row-team'),
            title: team == null
                ? l.admTeam
                : l.admTeamCount(team.admins.length),
            subtitle: _team.error != null
                ? backendErrorText(_team.error!, l)
                : team == null
                ? null
                : team.canManage
                ? l.admTeamSubManage
                : l.admTeamSubView,
            icon: Icons.manage_accounts_outlined,
            divider: false,
            onTap: () => _open('/profile/admin/admins'),
          ),
        ],
        if (stats != null) ..._legacy(context, l, stats),
        if (_stats.unavailable) ...[
          const SizedBox(height: 16),
          LgNotice(l.admLegacyNote, kind: NoticeKind.info),
        ],
      ],
    );
  }

  /// Kutilayotganlar soni matni (son hali yo'q — `null`).
  static String? _queueText(int? n, AppLocalizations l) => n == null
      ? null
      : n > 0
      ? l.admPending(n)
      : l.admQueueEmpty;

  /// Kutilayotgan ish bo'lsa — ixcham son belgisi (0 da hech narsa).
  static Widget? _badge(int? n) =>
      n == null || n == 0 ? null : LgTag('$n', tone: LgTone.warning);

  /// Statistika va boshqa bo'limlar — faqat server ularni bergan bo'lsa.
  List<Widget> _legacy(BuildContext context, AppLocalizations l, AdminStats s) {
    final text = Theme.of(context).textTheme;
    String roleName(String r) => switch (r) {
      'doctor' => l.roleDoctor,
      'lab' => l.roleLab,
      'student' => l.roleStudent,
      'teacher' => l.roleTeacher,
      _ => r,
    };
    return [
      LgSectionTitle(l.adminStats),
      LgPanel(
        child: Column(
          children: [
            LgMetric(label: l.adminRegistered, value: '${s.registered}'),
            LgMetric(label: l.adminNewToday, value: '${s.newToday}'),
            LgMetric(label: l.adminNew7, value: '${s.new7d}'),
            LgMetric(label: l.adminNew30, value: '${s.new30d}'),
            LgMetric(label: l.adminActiveToday, value: '${s.activeToday}'),
            LgMetric(label: l.adminActive7, value: '${s.active7d}'),
            LgMetric(label: l.adminActive30, value: '${s.active30d}'),
          ],
        ),
      ),
      Text(l.adminDefinitions, style: text.bodySmall),
      LgSectionTitle(l.adminByRole),
      LgPanel(
        child: Column(
          children: [
            for (final e in s.byRole.entries)
              LgMetric(label: roleName(e.key), value: '${e.value}'),
            if (s.withoutProfile > 0)
              LgMetric(label: l.adminNoProfile(s.withoutProfile), value: ''),
          ],
        ),
      ),
      LgSectionTitle(l.adminByLanguage),
      LgPanel(
        child: Column(
          children: [
            for (final e in s.byLanguage.entries)
              LgMetric(label: e.key.toUpperCase(), value: '${e.value}'),
          ],
        ),
      ),
      LgNotice(l.adminBilling, kind: NoticeKind.info),
      LgSectionTitle(l.admOther),
      LgRow(
        title: l.adminPartners,
        subtitle: l.adminPartnersSub,
        icon: Icons.storefront_outlined,
        onTap: () => _open('/profile/admin/partners'),
      ),
      const AdminPartnerRequestsRow(),
      LgRow(
        title: l.adminUsers,
        icon: Icons.people_outline_rounded,
        onTap: () => _open('/profile/admin/users'),
      ),
      LgRow(
        title: l.adminAudit,
        icon: Icons.history_rounded,
        onTap: () => _open('/profile/admin/audit'),
        divider: false,
      ),
    ];
  }
}

/// Kim ekanligingiz va 2FA holati (panel faqat aal2 dan keyin ochiladi).
class _AdminStatusPanel extends StatelessWidget {
  const _AdminStatusPanel({required this.superAdmin});

  final bool superAdmin;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return LgPanel(
      key: const ValueKey('admin-status'),
      soft: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Icon(Icons.verified_user_outlined, color: p.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  superAdmin ? l.admYouSuper : l.admYouAdmin,
                  style: text.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(l.adm2faOn, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bola birinchi marta chizilganda bir marta yuklaydi (AdminGate o'tgach).
class _AutoLoad extends StatefulWidget {
  const _AutoLoad({required this.onLoad, required this.child});

  final Future<void> Function() onLoad;
  final Widget child;

  @override
  State<_AutoLoad> createState() => _AutoLoadState();
}

class _AutoLoadState extends State<_AutoLoad> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onLoad());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AdminInboxScreen extends StatefulWidget {
  const AdminInboxScreen({super.key});

  @override
  State<AdminInboxScreen> createState() => _AdminInboxScreenState();
}

class _AdminInboxScreenState extends State<AdminInboxScreen> {
  SupportStatus? _filter = SupportStatus.newThread;
  List<SupportThread>? _threads;
  Object? _error;

  Future<void> _load() async {
    try {
      final t = await context.services.backend.adminThreads(status: _filter);
      if (mounted) setState(() => _threads = t);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final threads = _threads;
    return LgPage(
      title: l.adminInbox,
      showProfile: false,
      children: [
        SignedInGate(
          child: AdminGate(
            child: _AutoLoad(
              onLoad: _load,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in [null, ...SupportStatus.values])
                        LgChoiceChip(
                          label: s == null
                              ? l.adminAllStatuses
                              : supportStatusLabel(s, l),
                          selected: _filter == s,
                          onTap: () {
                            setState(() {
                              _filter = s;
                              _threads = null;
                            });
                            _load();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_error != null)
                    LgNotice(
                      backendErrorText(_error!, l),
                      kind: NoticeKind.error,
                    )
                  else if (threads == null)
                    const LgStateView(kind: StateKind.loading, title: '')
                  else if (threads.isEmpty)
                    LgStateView(
                      kind: StateKind.empty,
                      title: l.supportEmptyTitle,
                    )
                  else
                    for (final (i, t) in threads.indexed)
                      LgRow(
                        title: t.subject,
                        subtitle:
                            '${supportKindLabel(t.kind, l)} · '
                            '${supportStatusLabel(t.status, l)} · '
                            '${formatWhen(t.updatedAt, context)}',
                        icon: Icons.mark_email_unread_outlined,
                        trailing: t.unreadForAdmin
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: p.amber,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                        divider: i < threads.length - 1,
                        onTap: () async {
                          await context.push('/profile/admin/thread/${t.id}');
                          await _load();
                        },
                      ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AdminThreadScreen extends StatefulWidget {
  const AdminThreadScreen({super.key, required this.threadId});

  final String threadId;

  @override
  State<AdminThreadScreen> createState() => _AdminThreadScreenState();
}

class _AdminThreadScreenState extends State<AdminThreadScreen> {
  SupportThread? _thread;
  List<SupportMessage>? _messages;
  Object? _error;
  final _reply = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _load({bool markRead = false}) async {
    final backend = context.services.backend;
    try {
      final all = await backend.adminThreads();
      final thread =
          all.where((t) => t.id == widget.threadId).firstOrNull ??
          (throw const BackendException(BackendFailure.notFound));
      final messages = await backend.messages(widget.threadId);
      if (markRead && thread.unreadForAdmin) {
        await backend.adminMarkRead(widget.threadId);
      }
      if (mounted) {
        setState(() {
          _thread = thread;
          _messages = messages;
          _error = null;
        });
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      await _load();
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final backend = context.services.backend;
    final thread = _thread;
    final messages = _messages;
    return LgPage(
      title: thread?.subject ?? l.adminInbox,
      showProfile: false,
      children: [
        SignedInGate(
          child: AdminGate(
            child: _AutoLoad(
              onLoad: () => _load(markRead: true),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (thread != null) ...[
                    Text(l.adminStatus, style: text.titleSmall),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final s in SupportStatus.values)
                          LgChoiceChip(
                            label: supportStatusLabel(s, l),
                            selected: thread.status == s,
                            onTap: _busy || thread.status == s
                                ? () {}
                                : () => _run(
                                    () => backend.adminSetStatus(thread.id, s),
                                  ),
                          ),
                      ],
                    ),
                  ],
                  if (messages == null && _error == null)
                    const LgStateView(kind: StateKind.loading, title: ''),
                  if (messages != null)
                    SupportConversation(messages: messages, asAdmin: true),
                  if (_error != null)
                    LgNotice(
                      backendErrorText(_error!, l),
                      kind: NoticeKind.error,
                    ),
                  if (messages != null) ...[
                    LgField(
                      label: l.adminSendReply,
                      controller: _reply,
                      hint: l.adminReplyHint,
                      maxLines: 5,
                      maxLength: 4000,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 10),
                    LgButton(
                      label: l.adminSendReply,
                      icon: Icons.send_rounded,
                      busy: _busy,
                      onPressed: () {
                        final body = _reply.text.trim();
                        if (body.isEmpty) return;
                        _run(() async {
                          await backend.adminReply(widget.threadId, body);
                          _reply.clear();
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  static const _pageSize = 20;
  final _query = TextEditingController();
  String? _role;
  String? _language;
  int _offset = 0;
  AdminUserPage? _page;
  Object? _error;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final page = await context.services.backend.adminUsers(
        query: _query.text.trim().isEmpty ? null : _query.text.trim(),
        role: _role,
        language: _language,
        limit: _pageSize,
        offset: _offset,
      );
      if (mounted) {
        setState(() {
          _page = page;
          _error = null;
        });
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _reload({bool resetPage = true}) {
    if (resetPage) _offset = 0;
    setState(() => _page = null);
    _load();
  }

  Future<void> _details(AdminUserRow u) async {
    final l = AppLocalizations.of(context);
    final backend = context.services.backend;
    String? email;
    var reviewer = false;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                email ?? u.emailMasked,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (email == null)
                LgButton.secondary(
                  label: l.adminShowEmail,
                  icon: Icons.visibility_outlined,
                  onPressed: () async {
                    final e = await backend.adminRevealEmail(u.userId);
                    setSheet(() => email = e);
                  },
                ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l.adminReviewer),
                value: reviewer,
                onChanged: (v) async {
                  await backend.adminSetReviewer(u.userId, enabled: v);
                  setSheet(() => reviewer = v);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMd(locale);
    final page = _page;
    String roleName(String? r) => switch (r) {
      'doctor' => l.roleDoctor,
      'lab' => l.roleLab,
      'student' => l.roleStudent,
      'teacher' => l.roleTeacher,
      _ => '—',
    };
    return LgPage(
      title: l.adminUsers,
      showProfile: false,
      children: [
        SignedInGate(
          child: AdminGate(
            child: _AutoLoad(
              onLoad: _load,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LgField(
                    label: l.adminSearchHint,
                    controller: _query,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _reload(),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final r in [
                        null,
                        'doctor',
                        'lab',
                        'student',
                        'teacher',
                      ])
                        LgChoiceChip(
                          label: r == null ? l.adminAllRoles : roleName(r),
                          selected: _role == r,
                          onTap: () {
                            _role = r;
                            _reload();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final lang in [null, 'uz', 'ru', 'en'])
                        LgChoiceChip(
                          label: lang == null
                              ? l.adminAllLanguages
                              : lang.toUpperCase(),
                          selected: _language == lang,
                          onTap: () {
                            _language = lang;
                            _reload();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_error != null)
                    LgNotice(
                      backendErrorText(_error!, l),
                      kind: NoticeKind.error,
                    )
                  else if (page == null)
                    const LgStateView(kind: StateKind.loading, title: '')
                  else if (page.rows.isEmpty)
                    LgStateView(kind: StateKind.empty, title: l.adminNoUsers)
                  else ...[
                    for (final (i, u) in page.rows.indexed)
                      LgRow(
                        title: u.emailMasked,
                        subtitle: [
                          '${roleName(u.role)} · ${u.language?.toUpperCase() ?? '—'}',
                          l.adminRegisteredOn(date.format(u.registeredOn)),
                          if (u.lastSeenOn != null)
                            l.adminLastSeen(date.format(u.lastSeenOn!)),
                        ].join('\n'),
                        icon: Icons.person_outline_rounded,
                        divider: i < page.rows.length - 1,
                        onTap: () => _details(u),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      l.adminPage(
                        _offset + 1,
                        _offset + page.rows.length,
                        page.total,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: LgButton.secondary(
                            label: l.adminPrev,
                            onPressed: _offset == 0
                                ? null
                                : () {
                                    _offset -= _pageSize;
                                    _reload(resetPage: false);
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LgButton.secondary(
                            label: l.adminNext,
                            onPressed: _offset + page.rows.length >= page.total
                                ? null
                                : () {
                                    _offset += _pageSize;
                                    _reload(resetPage: false);
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String auditActionLabel(String action, AppLocalizations l) => switch (action) {
  'support_reply' => l.adminActionSupportReply,
  'support_status' => l.adminActionSupportStatus,
  'reveal_email' => l.adminActionRevealEmail,
  'reviewer_granted' => l.adminActionReviewerGranted,
  'reviewer_revoked' => l.adminActionReviewerRevoked,
  'admin_granted' => l.adminActionAdminGranted,
  'admin_revoked' => l.adminActionAdminRevoked,
  'admin_grant_added' => l.adminActionGrantAdded,
  'admin_grant_removed' => l.adminActionGrantRemoved,
  'partner_created' => l.adminActionPartnerCreated,
  'partner_updated' => l.adminActionPartnerUpdated,
  'partner_published' => l.adminActionPartnerPublished,
  'partner_paused' => l.adminActionPartnerPaused,
  'partner_draft' => l.adminActionPartnerDraft,
  'partner_request' => l.adminActionPartnerRequest,
  _ => action,
};

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  List<AuditEntry>? _entries;
  Object? _error;

  Future<void> _load() async {
    try {
      final e = await context.services.backend.adminAudit();
      if (mounted) setState(() => _entries = e);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final entries = _entries;
    return LgPage(
      title: l.adminAudit,
      showProfile: false,
      children: [
        SignedInGate(
          child: AdminGate(
            child: _AutoLoad(
              onLoad: _load,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null)
                    LgNotice(
                      backendErrorText(_error!, l),
                      kind: NoticeKind.error,
                    )
                  else if (entries == null)
                    const LgStateView(kind: StateKind.loading, title: '')
                  else if (entries.isEmpty)
                    LgStateView(kind: StateKind.empty, title: l.adminAuditEmpty)
                  else
                    for (final (i, e) in entries.indexed)
                      LgRow(
                        title: auditActionLabel(e.action, l),
                        subtitle: formatWhen(e.at, context),
                        icon: Icons.history_rounded,
                        divider: i < entries.length - 1,
                      ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Adminlar boshqaruvi (D-44): ro'yxat (niqoblangan email), egasi uchun —
/// email bo'yicha qo'shish va tasdiq bilan olib tashlash. Vakolatni server
/// beradi; bu ekran faqat so'rov yuboradi.
class AdminTeamScreen extends StatefulWidget {
  const AdminTeamScreen({super.key});

  @override
  State<AdminTeamScreen> createState() => _AdminTeamScreenState();
}

class _AdminTeamScreenState extends State<AdminTeamScreen> {
  final _email = TextEditingController();
  AdminTeam? _team;
  Object? _error;
  String? _emailError;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final api = context.services.adminTeam;
    if (api == null) return;
    try {
      final t = await api.adminTeam();
      if (mounted) {
        setState(() {
          _team = t;
          _error = null;
        });
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _snack(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  String _errorText(Object e, AppLocalizations l) => switch (e) {
    AdminTeamException(code: 'invalid_email') => l.admInvalidEmail,
    AdminTeamException(code: 'already_admin') => l.admErrAlready,
    AdminTeamException(code: 'already_super_admin') => l.admErrSuper,
    AdminTeamException(code: 'too_many_admins') => l.admErrTooMany(
      _team?.maxGranted ?? 20,
    ),
    AdminTeamException(code: 'not_super_admin') => l.admTeamOwnerOnly,
    _ => backendErrorText(e, l),
  };

  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    final api = context.services.adminTeam;
    final email = _email.text.trim();
    if (api == null || _busy) return;
    if (!isValidEmail(email)) {
      setState(() => _emailError = l.admInvalidEmail);
      return;
    }
    setState(() => _emailError = null);
    final ok = await confirmDialog(
      context,
      title: l.admAddConfirmTitle,
      body: l.admAddConfirmBody(normalizeEmail(email)),
      action: l.admAddButton,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      final added = await api.addAdmin(email);
      if (!mounted) return;
      _email.clear();
      _snack(l.admAdded(added.emailMasked));
      await _load();
    } on Object catch (e) {
      if (mounted) setState(() => _emailError = _errorText(e, l));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(AdminEntry a) async {
    final l = AppLocalizations.of(context);
    final api = context.services.adminTeam;
    final id = a.id;
    if (api == null || id == null) return;
    final ok = await confirmDialog(
      context,
      title: l.admRemoveTitle,
      body: l.admRemoveBody(a.emailMasked),
      action: l.admRemove,
    );
    if (!ok || !mounted) return;
    try {
      await api.removeAdmin(id);
      if (!mounted) return;
      _snack(l.admRemoved(a.emailMasked));
      await _load();
    } on Object catch (e) {
      if (mounted) _snack(_errorText(e, l));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final available = context.services.adminTeam != null;
    return LgPage(
      title: l.admTeam,
      showProfile: false,
      children: [
        if (!available)
          LgStateView(kind: StateKind.unavailable, title: l.admNotConnected)
        else
          SignedInGate(
            child: AdminGate(
              child: _AutoLoad(
                onLoad: _load,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.admTeamIntro, style: text.bodyMedium),
                    const SizedBox(height: 14),
                    ..._body(context, l),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _body(BuildContext context, AppLocalizations l) {
    final text = Theme.of(context).textTheme;
    final team = _team;
    if (_error != null && team == null) {
      return [
        LgStateView(
          kind: StateKind.error,
          title: backendErrorText(_error!, l),
          actionLabel: l.actionRetry,
          onAction: () {
            setState(() => _error = null);
            _load();
          },
        ),
      ];
    }
    if (team == null) {
      return const [LgStateView(kind: StateKind.loading, title: '')];
    }
    final date = DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return [
      if (team.canManage)
        LgPanel(
          key: const ValueKey('admin-team-add'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.admAddTitle, style: text.titleMedium),
              const SizedBox(height: 8),
              LgField(
                label: l.admAddEmail,
                controller: _email,
                hint: 'name@gmail.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                errorText: _emailError,
                onSubmitted: (_) => _add(),
              ),
              const SizedBox(height: 6),
              Text(l.admAddHint, style: text.bodySmall),
              const SizedBox(height: 12),
              LgButton(
                key: const ValueKey('admin-team-add-button'),
                label: l.admAddButton,
                icon: Icons.person_add_alt_1_outlined,
                busy: _busy,
                onPressed: _add,
              ),
            ],
          ),
        )
      else
        LgNotice(l.admTeamOwnerOnly, kind: NoticeKind.info),
      LgSectionTitle(l.admListTitle(team.admins.length)),
      for (final (i, a) in team.admins.indexed)
        LgRow(
          key: ValueKey('admin-team-${a.id ?? 'super-$i'}'),
          title: a.emailMasked,
          subtitle: [
            if (a.kind == AdminKind.superAdmin)
              l.admKindSuper
            else
              l.admKindGranted(
                a.createdAt == null ? '—' : date.format(a.createdAt!.toLocal()),
              ),
            if (!a.active) l.admNotSignedIn,
          ].join('\n'),
          icon: a.kind == AdminKind.superAdmin
              ? Icons.workspace_premium_outlined
              : Icons.admin_panel_settings_outlined,
          divider: i < team.admins.length - 1,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (a.you) LgTag(l.admYou, tone: LgTone.brand),
              if (team.canManage && a.removable)
                IconButton(
                  key: ValueKey('admin-team-remove-${a.id}'),
                  tooltip: l.admRemove,
                  icon: const Icon(Icons.person_remove_outlined),
                  onPressed: () => _remove(a),
                ),
            ],
          ),
        ),
      if (team.grantedCount == 0) ...[
        const SizedBox(height: 8),
        Text(l.admNoGranted, style: text.bodyMedium),
      ],
      const SizedBox(height: 12),
      Text(l.admSuperNote, style: text.bodySmall),
    ];
  }
}
