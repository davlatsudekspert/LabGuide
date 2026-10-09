import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../core/backend/backend_models.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../partners/partner_admin_screens.dart' show AdminPartnerRequestsRow;
import '../support/support_screens.dart';

/// Admin bo'limlariga kirish: server admin hisobi deb tasdiqlagan bo'lishi
/// va sessiya ikki bosqichli (aal2) bo'lishi kerak. Aks holda — 2FA oynasi
/// yoki “faqat admin uchun”. Bu faqat ko'rinish: serverdagi har funksiya
/// vakolatni o'zi qayta tekshiradi.
class AdminGate extends StatefulWidget {
  const AdminGate({super.key, required this.child});

  final Widget child;

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
      return _MfaPanel(onVerified: _check);
    }
    return widget.child;
  }
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

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  AdminStats? _stats;
  Object? _error;

  Future<void> _load() async {
    try {
      final s = await context.services.backend.adminStats();
      if (mounted) setState(() => _stats = s);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.adminTitle,
      showProfile: false,
      children: [
        SignedInGate(
          child: AdminGate(
            child: _AutoLoad(
              onLoad: _load,
              child: Builder(
                builder: (context) {
                  final s = _stats;
                  if (_error != null) {
                    return LgStateView(
                      kind: StateKind.error,
                      title: backendErrorText(_error!, l),
                      actionLabel: l.actionRetry,
                      onAction: () {
                        setState(() => _error = null);
                        _load();
                      },
                    );
                  }
                  if (s == null) {
                    return const LgStateView(
                      kind: StateKind.loading,
                      title: '',
                    );
                  }
                  String roleName(String r) => switch (r) {
                    'doctor' => l.roleDoctor,
                    'lab' => l.roleLab,
                    'student' => l.roleStudent,
                    'teacher' => l.roleTeacher,
                    _ => r,
                  };
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LgSectionTitle(l.adminStats),
                      LgPanel(
                        child: Column(
                          children: [
                            LgMetric(
                              label: l.adminRegistered,
                              value: '${s.registered}',
                            ),
                            LgMetric(
                              label: l.adminNewToday,
                              value: '${s.newToday}',
                            ),
                            LgMetric(label: l.adminNew7, value: '${s.new7d}'),
                            LgMetric(label: l.adminNew30, value: '${s.new30d}'),
                            LgMetric(
                              label: l.adminActiveToday,
                              value: '${s.activeToday}',
                            ),
                            LgMetric(
                              label: l.adminActive7,
                              value: '${s.active7d}',
                            ),
                            LgMetric(
                              label: l.adminActive30,
                              value: '${s.active30d}',
                            ),
                          ],
                        ),
                      ),
                      Text(l.adminDefinitions, style: text.bodySmall),
                      LgSectionTitle(l.adminByRole),
                      LgPanel(
                        child: Column(
                          children: [
                            for (final e in s.byRole.entries)
                              LgMetric(
                                label: roleName(e.key),
                                value: '${e.value}',
                              ),
                            if (s.withoutProfile > 0)
                              LgMetric(
                                label: l.adminNoProfile(s.withoutProfile),
                                value: '',
                              ),
                          ],
                        ),
                      ),
                      LgSectionTitle(l.adminByLanguage),
                      LgPanel(
                        child: Column(
                          children: [
                            for (final e in s.byLanguage.entries)
                              LgMetric(
                                label: e.key.toUpperCase(),
                                value: '${e.value}',
                              ),
                          ],
                        ),
                      ),
                      LgNotice(l.adminBilling, kind: NoticeKind.info),
                      const SizedBox(height: 8),
                      LgRow(
                        title: l.adminInbox,
                        subtitle: l.adminAwaiting(
                          s.support['awaiting_reply'] ?? 0,
                        ),
                        icon: Icons.inbox_outlined,
                        onTap: () async {
                          await context.push('/profile/admin/inbox');
                          await _load();
                        },
                      ),
                      LgRow(
                        title: l.adminPartners,
                        subtitle: l.adminPartnersSub,
                        icon: Icons.storefront_outlined,
                        onTap: () => context.push('/profile/admin/partners'),
                      ),
                      const AdminPartnerRequestsRow(),
                      LgRow(
                        title: l.adminUsers,
                        icon: Icons.people_outline_rounded,
                        onTap: () => context.push('/profile/admin/users'),
                      ),
                      LgRow(
                        title: l.adminAudit,
                        icon: Icons.history_rounded,
                        onTap: () => context.push('/profile/admin/audit'),
                        divider: false,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
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
