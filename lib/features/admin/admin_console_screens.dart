import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../core/backend/admin_console.dart';
import '../../core/backend/backend_models.dart';
import '../../core/contact.dart';
import '../../core/single_flight.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../learn/exam_widgets.dart' show confirmDialog;
import '../support/support_screens.dart';
import 'admin_screens.dart';

// Egasi admin paneli (Cloudflare): umumiy ko'rsatkichlar, ilova shikoyatlari,
// hamjamiyat shikoyatlari, foydalanuvchilar. Har ekran AdminGate(panel: true)
// ichida; server har so'rovda vakolatni o'zi tekshiradi. Ekranda faqat
// serverdan kelgan haqiqiy sonlar — soxta qiymat yo'q.

String roleLabel(String? r, AppLocalizations l) => switch (r) {
  'doctor' => l.roleDoctor,
  'lab' => l.roleLab,
  'student' => l.roleStudent,
  'teacher' => l.roleTeacher,
  _ => '—',
};

String complaintKindLabel(ComplaintKind k, AppLocalizations l) => switch (k) {
  ComplaintKind.complaint => l.complaintKindComplaint,
  ComplaintKind.inappropriate => l.complaintKindInappropriate,
  ComplaintKind.bug => l.complaintKindBug,
  ComplaintKind.ad => l.complaintKindAd,
  ComplaintKind.other => l.complaintKindOther,
};

String communityStatusLabel(String s, AppLocalizations l) => switch (s) {
  'verified' => l.cmAdminVerified,
  'rejected' => l.cmAdminRejected,
  'suspended' => l.cmAdminSuspended,
  _ => l.admCommunityNone,
};

String _reasonLabel(String r, AppLocalizations l) => switch (r) {
  'spam' => l.cmReasonSpam,
  'wrong' => l.cmReasonWrong,
  'abuse' => l.cmReasonAbuse,
  'fake_specialist' => l.cmReasonFake,
  'patient_data' => l.cmReasonPatient,
  _ => l.cmReasonOther,
};

/// Admin xatosi — tushunarli matn (server kodi bo'yicha).
String adminConsoleErrorText(Object e, AppLocalizations l) => switch (e) {
  AdminConsoleException(code: 'self') => l.admErrSelf,
  AdminConsoleException(code: 'admin') => l.admAccountAdminNote,
  AdminConsoleException(code: 'owner') => l.admErrOwner,
  AdminConsoleException(code: 'invalid_email') => l.admInvalidEmail,
  AdminConsoleException(code: 'invalid_name') => l.admErrName,
  AdminConsoleException(code: 'confirmation_mismatch' || 'not_found') =>
    l.admDeleteMismatch,
  _ => backendErrorText(e, l),
};

void _snack(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

/// Yuklanmoqda / xato / tayyor — bitta ko'rinish (qayta urinish bilan).
class _Async<T> extends StatelessWidget {
  const _Async({
    required this.value,
    required this.error,
    required this.onRetry,
    required this.builder,
  });

  final T? value;
  final Object? error;
  final VoidCallback onRetry;
  final Widget Function(T value) builder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final v = value;
    if (error != null && v == null) {
      return LgStateView(
        kind: StateKind.error,
        title: adminConsoleErrorText(error!, l),
        actionLabel: l.actionRetry,
        onAction: onRetry,
      );
    }
    if (v == null) return const LgStateView(kind: StateKind.loading, title: '');
    return builder(v);
  }
}

/// Server bu bo'limni bermaydi (masalan, Supabase builds) — halol holat.
Widget _unavailable(AppLocalizations l) =>
    LgStateView(kind: StateKind.unavailable, title: l.admNotConnected);

// ------------------------------------------------------------ statistika
class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  AdminStats? _stats;
  Object? _error;

  Future<void> _load() async {
    setState(() => _error = null);
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
    return LgPage(
      title: l.admOverview,
      showProfile: false,
      children: [
        SignedInGate(
          child: AdminGate(
            panel: true,
            child: AdminAutoLoad(
              onLoad: _load,
              child: _Async<AdminStats>(
                value: _stats,
                error: _error,
                onRetry: _load,
                builder: (s) => _StatsBody(stats: s),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final s = stats;
    final groups = s.groupsSection ?? const {};
    final community = s.communitySection ?? const {};
    final complaints = s.complaintsSection ?? const {};
    final updated = s.generatedAt;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String num(int? v) =>
        v == null ? '—' : NumberFormat.decimalPattern(locale).format(v);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (updated != null)
          Text(
            l.admStatsUpdated(formatWhen(updated, context)),
            style: text.bodySmall,
          ),
        LgSectionTitle(l.admStatsAccounts),
        LgPanel(
          child: Column(
            children: [
              LgMetric(label: l.adminRegistered, value: num(s.registered)),
              LgMetric(label: l.adminNewToday, value: num(s.newToday)),
              LgMetric(label: l.adminNew7, value: num(s.new7d)),
              LgMetric(label: l.adminNew30, value: num(s.new30d)),
              if (s.onlineNow != null)
                LgMetric(label: l.admOnlineNow, value: num(s.onlineNow)),
              LgMetric(label: l.adminActive7, value: num(s.active7d)),
              LgMetric(label: l.adminActive30, value: num(s.active30d)),
              if (s.suspendedAccounts != null)
                LgMetric(
                  label: l.admSuspendedAccounts,
                  value: num(s.suspendedAccounts),
                ),
            ],
          ),
        ),
        Text(l.admStatsActiveNote, style: text.bodySmall),
        if (s.newByDay.isNotEmpty) ...[
          LgSectionTitle(l.admChartTitle),
          LgPanel(child: NewAccountsChart(days: s.newByDay)),
        ],
        LgSectionTitle(l.adminByRole),
        LgPanel(
          child: Column(
            children: [
              for (final e in s.byRole.entries)
                LgMetric(label: roleLabel(e.key, l), value: num(e.value)),
            ],
          ),
        ),
        LgSectionTitle(l.adminByLanguage),
        LgPanel(
          child: Column(
            children: [
              for (final e in s.byLanguage.entries)
                LgMetric(label: e.key.toUpperCase(), value: num(e.value)),
            ],
          ),
        ),
        LgSectionTitle(l.admStatsObjects),
        LgPanel(
          child: Column(
            children: [
              LgMetric(
                label: l.admStatsGroupsCount,
                value: num(groups['groups']),
              ),
              LgMetric(
                label: l.admStatsTeachers,
                value: num(groups['teachers']),
              ),
              LgMetric(
                label: l.admStatsStudents,
                value: num(groups['students']),
              ),
              LgMetric(
                label: l.admStatsAssignments,
                value: num(groups['assignments']),
              ),
              LgMetric(label: l.admStatsResults, value: num(groups['results'])),
              LgMetric(
                label: l.admStatsQuestions,
                value: num(community['questions']),
              ),
              LgMetric(
                label: l.admStatsAnswers,
                value: num(community['answers']),
              ),
              LgMetric(
                label: l.admStatsComplaintsOpen,
                value: num(complaints['open']),
              ),
              LgMetric(
                label: l.admStatsComplaintsResolved,
                value: num(complaints['resolved']),
              ),
              LgMetric(
                label: l.admStatsReportsOpen,
                value: num(community['reports_open']),
              ),
              LgMetric(
                label: l.admStatsAwaiting,
                value: num(s.support['awaiting_reply']),
              ),
            ],
          ),
        ),
        Text(l.adminDefinitions, style: text.bodySmall),
        const StoreConsolesPanel(),
      ],
    );
  }
}

/// Oxirgi 14 kundagi yangi hisoblar — oddiy ustunli grafik (qo'shimcha
/// kutubxonasiz). Har ustun screen reader uchun “sana: son” deb o'qiladi.
class NewAccountsChart extends StatelessWidget {
  const NewAccountsChart({super.key, required this.days});

  final List<DayCount> days;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final day = DateFormat.Md(locale);
    final full = DateFormat.yMMMd(locale);
    final max = days.fold<int>(0, (m, d) => d.count > m ? d.count : m);
    final total = days.fold<int>(0, (m, d) => m + d.count);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.admChartTotal(total), style: text.titleSmall),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final d in days)
                Expanded(
                  child: Semantics(
                    container: true,
                    label: l.admChartBar(full.format(d.day), d.count),
                    excludeSemantics: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (d.count > 0)
                            FittedBox(
                              child: Text('${d.count}', style: text.labelSmall),
                            ),
                          const SizedBox(height: 2),
                          Container(
                            height: max == 0 ? 2 : 2 + 86 * d.count / max,
                            decoration: BoxDecoration(
                              color: d.count == 0 ? p.line : p.brand,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ExcludeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day.format(days.first.day), style: text.bodySmall),
              Text(day.format(days.last.day), style: text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

/// Yuklab olishlar va sotuvlar: server ko'rmaydi — konsollarga havola.
class StoreConsolesPanel extends StatelessWidget {
  const StoreConsolesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.admStoreTitle),
        LgPanel(
          key: const ValueKey('admin-store-panel'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.admStoreBody, style: text.bodyMedium),
              const SizedBox(height: 10),
              Text(l.admSales, style: text.titleSmall),
              const SizedBox(height: 12),
              LgButton.secondary(
                key: const ValueKey('admin-open-asc'),
                label: l.admAppStoreConnect,
                icon: Icons.open_in_new_rounded,
                onPressed: () =>
                    openExternalLink(context, StoreConsoles.appStoreConnect),
              ),
              const SizedBox(height: 8),
              LgButton.secondary(
                key: const ValueKey('admin-open-play'),
                label: l.admPlayConsole,
                icon: Icons.open_in_new_rounded,
                onPressed: () =>
                    openExternalLink(context, StoreConsoles.playConsole),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------- ilova shikoyatlari
class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  ComplaintStatus? _status = ComplaintStatus.open;
  ComplaintKind? _kind;
  List<Complaint>? _items;
  Object? _error;

  Future<void> _load() async {
    final api = context.services.adminConsole;
    if (api == null) return;
    setState(() {
      _items = null;
      _error = null;
    });
    try {
      final items = await api.adminComplaints(status: _status, kind: _kind);
      if (mounted) setState(() => _items = items);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final api = context.services.adminConsole;
    return LgPage(
      title: l.admComplaintsTitle,
      showProfile: false,
      children: [
        if (api == null)
          _unavailable(l)
        else
          SignedInGate(
            child: AdminGate(
              panel: true,
              child: AdminAutoLoad(
                onLoad: _load,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LgNotice(l.admApple12Note, kind: NoticeKind.info),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final (s, label) in [
                          (ComplaintStatus.open, l.admFilterOpen),
                          (ComplaintStatus.resolved, l.admFilterResolved),
                          (null, l.adminAllStatuses),
                        ])
                          LgChoiceChip(
                            label: label,
                            selected: _status == s,
                            onTap: () {
                              _status = s;
                              _load();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final k in [null, ...ComplaintKind.values])
                          LgChoiceChip(
                            label: k == null
                                ? l.admAllKinds
                                : complaintKindLabel(k, l),
                            selected: _kind == k,
                            onTap: () {
                              _kind = k;
                              _load();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _Async<List<Complaint>>(
                      value: _items,
                      error: _error,
                      onRetry: _load,
                      builder: (items) => items.isEmpty
                          ? LgStateView(
                              kind: StateKind.empty,
                              title: l.admComplaintsEmpty,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final (i, c) in items.indexed)
                                  LgRow(
                                    key: ValueKey('complaint-${c.id}'),
                                    title: c.body.length > 90
                                        ? '${c.body.substring(0, 90)}…'
                                        : c.body,
                                    subtitle: [
                                      complaintKindLabel(c.kind, l),
                                      c.anonymous
                                          ? l.admComplaintAnon
                                          : c.emailMasked ?? '—',
                                      formatWhen(c.createdAt, context),
                                    ].join(' · '),
                                    icon: c.status == ComplaintStatus.open
                                        ? Icons.report_outlined
                                        : Icons.task_alt_rounded,
                                    trailing: c.status == ComplaintStatus.open
                                        ? LgTag(
                                            l.admFilterOpen,
                                            tone: LgTone.warning,
                                          )
                                        : null,
                                    divider: i < items.length - 1,
                                    onTap: () async {
                                      await context.push(
                                        '/profile/admin/complaints/${c.id}',
                                      );
                                      await _load();
                                    },
                                  ),
                              ],
                            ),
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

class AdminComplaintScreen extends StatefulWidget {
  const AdminComplaintScreen({super.key, required this.id});

  final String id;

  @override
  State<AdminComplaintScreen> createState() => _AdminComplaintScreenState();
}

class _AdminComplaintScreenState extends State<AdminComplaintScreen> {
  final _note = TextEditingController();
  Complaint? _c;
  Object? _error;
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AdminComplaintScreen old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) {
      _c = null;
      _load();
    }
  }

  void _set(Complaint c) {
    _c = c;
    _note.text = c.adminNote ?? '';
  }

  Future<void> _load() async {
    final api = context.services.adminConsole;
    if (api == null) return;
    setState(() => _error = null);
    try {
      final c = await api.adminComplaint(widget.id);
      if (mounted) setState(() => _set(c));
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _run(Future<Complaint> Function() action, String done) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final c = await action();
      if (!mounted) return;
      setState(() => _set(c));
      _snack(context, done);
    } on Object catch (e) {
      if (mounted) {
        _snack(context, adminConsoleErrorText(e, AppLocalizations.of(context)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final api = context.services.adminConsole;
    return LgPage(
      title: l.admComplaintsTitle,
      showProfile: false,
      children: [
        if (api == null)
          _unavailable(l)
        else
          SignedInGate(
            child: AdminGate(
              panel: true,
              child: AdminAutoLoad(
                onLoad: _load,
                child: _Async<Complaint>(
                  value: _c,
                  error: _error,
                  onRetry: _load,
                  builder: (c) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          LgTag(complaintKindLabel(c.kind, l)),
                          LgTag(
                            c.status == ComplaintStatus.open
                                ? l.admFilterOpen
                                : l.admFilterResolved,
                            tone: c.status == ComplaintStatus.open
                                ? LgTone.warning
                                : LgTone.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LgPanel(
                        child: SelectableText(c.body, style: text.bodyLarge),
                      ),
                      Text(
                        [
                          formatWhen(c.createdAt, context),
                          if (c.anonymous)
                            l.admComplaintAnon
                          else
                            l.admComplaintFrom(c.emailMasked ?? '—'),
                          if (c.targetRef != null)
                            l.admComplaintTarget(c.targetRef!),
                          if (c.resolvedAt != null)
                            l.admComplaintResolvedOn(
                              formatWhen(c.resolvedAt!, context),
                            ),
                        ].join('\n'),
                        style: text.bodySmall,
                      ),
                      if (!c.anonymous && c.userId != null)
                        LgButton.link(
                          label: l.admUserTitle,
                          icon: Icons.person_outline_rounded,
                          onPressed: () =>
                              context.push('/profile/admin/users/${c.userId}'),
                        ),
                      LgField(
                        key: const ValueKey('complaint-note'),
                        label: l.admComplaintNote,
                        controller: _note,
                        hint: l.admComplaintNoteHint,
                        maxLines: 4,
                        maxLength: 2000,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 8),
                      LgButton.secondary(
                        key: const ValueKey('complaint-save-note'),
                        label: l.admComplaintSaveNote,
                        icon: Icons.save_outlined,
                        busy: _busy,
                        onPressed: () => _run(
                          () => api.adminComplaintNote(c.id, _note.text),
                          l.admSaved,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (c.status == ComplaintStatus.open)
                        LgButton(
                          key: const ValueKey('complaint-resolve'),
                          label: l.admComplaintResolve,
                          icon: Icons.task_alt_rounded,
                          busy: _busy,
                          onPressed: () => _run(
                            () => api.adminSetComplaintStatus(
                              c.id,
                              ComplaintStatus.resolved,
                            ),
                            l.cmAdminDone,
                          ),
                        )
                      else
                        LgButton.secondary(
                          key: const ValueKey('complaint-reopen'),
                          label: l.admComplaintReopen,
                          icon: Icons.restart_alt_rounded,
                          busy: _busy,
                          onPressed: () => _run(
                            () => api.adminSetComplaintStatus(
                              c.id,
                              ComplaintStatus.open,
                            ),
                            l.cmAdminDone,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------- hamjamiyat shikoyatlari
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with BusyGuard {
  ReportStatus _status = ReportStatus.open;
  List<ReportItem>? _items;
  Object? _error;

  Future<void> _load() async {
    final api = context.services.adminConsole;
    if (api == null) return;
    setState(() {
      _items = null;
      _error = null;
    });
    try {
      final items = await api.adminReports(status: _status);
      if (mounted) setState(() => _items = items);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _act(
    ReportItem r, {
    required String title,
    required String body,
    required String action,
    required Future<void> Function() run,
  }) => guard(() async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: title,
      body: body,
      action: action,
    );
    if (!ok || !mounted) return;
    try {
      await run();
      if (!mounted) return;
      _snack(context, l.cmAdminDone);
      await _load();
    } on Object catch (e) {
      if (mounted) _snack(context, adminConsoleErrorText(e, l));
    }
  });

  String _statusLabel(ReportStatus s, AppLocalizations l) => switch (s) {
    ReportStatus.open => l.admReportOpen,
    ReportStatus.dismissed => l.admReportDismissed,
    ReportStatus.resolved => l.admReportResolved,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final api = context.services.adminConsole;
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.admReportsRow,
      showProfile: false,
      children: [
        if (api == null)
          _unavailable(l)
        else
          SignedInGate(
            child: AdminGate(
              panel: true,
              child: AdminAutoLoad(
                onLoad: _load,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final s in ReportStatus.values)
                          LgChoiceChip(
                            label: _statusLabel(s, l),
                            selected: _status == s,
                            onTap: () {
                              _status = s;
                              _load();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _Async<List<ReportItem>>(
                      value: _items,
                      error: _error,
                      onRetry: _load,
                      builder: (items) => items.isEmpty
                          ? LgStateView(
                              kind: StateKind.empty,
                              title: l.admReportsEmpty,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final r in items)
                                  LgPanel(
                                    key: ValueKey('report-${r.kind}-${r.id}'),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: [
                                            LgTag(
                                              r.kind == 'answer'
                                                  ? l.admReportKindAnswer
                                                  : l.admReportKindQuestion,
                                            ),
                                            if (r.postDeleted)
                                              LgTag(
                                                l.admReportDeleted,
                                                tone: LgTone.neutral,
                                              ),
                                            if (r.authorStatus == 'suspended')
                                              LgTag(
                                                l.admReportAuthorSuspended,
                                                tone: LgTone.warning,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (r.excerpt != null)
                                          Text(
                                            r.excerpt!,
                                            style: text.bodyLarge,
                                          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          [
                                            l.admReportCount(
                                              r.reports,
                                              r.reporters,
                                            ),
                                            l.admReportReasons(
                                              r.reasons
                                                  .map(
                                                    (x) => _reasonLabel(x, l),
                                                  )
                                                  .join(', '),
                                            ),
                                            formatWhen(r.lastAt, context),
                                          ].join('\n'),
                                          style: text.bodySmall,
                                        ),
                                        if (r.questionId != null &&
                                            !r.postDeleted)
                                          LgButton.link(
                                            label: l.admReportOpenPost,
                                            icon: Icons.open_in_new_rounded,
                                            onPressed: () => context.push(
                                              '/profile/community/q/${r.questionId}',
                                            ),
                                          ),
                                        if (r.status == ReportStatus.open) ...[
                                          const SizedBox(height: 8),
                                          LgButton.secondary(
                                            label: l.admReportDismiss,
                                            icon: Icons.block_outlined,
                                            onPressed: () => _act(
                                              r,
                                              title: l.admReportDismissTitle,
                                              body: l.admReportDismissBody,
                                              action: l.admReportDismiss,
                                              run: () => api.dismissReport(r),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          LgButton.secondary(
                                            label: l.admReportResolve,
                                            icon: Icons.task_alt_rounded,
                                            onPressed: () => _act(
                                              r,
                                              title: l.admReportResolveTitle,
                                              body: l.admReportResolveBody,
                                              action: l.admReportResolve,
                                              run: () => api.resolveReport(r),
                                            ),
                                          ),
                                          if (r.authorStatus !=
                                              'suspended') ...[
                                            const SizedBox(height: 6),
                                            LgButton(
                                              label: l.admReportSuspend,
                                              icon: Icons.person_off_outlined,
                                              onPressed: () => _act(
                                                r,
                                                title: l.admReportSuspendTitle,
                                                body: l.admReportSuspendBody,
                                                action: l.admReportSuspend,
                                                run: () =>
                                                    api.suspendReportAuthor(r),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ],
                                    ),
                                  ),
                              ],
                            ),
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

// --------------------------------------------------------- foydalanuvchilar
class AdminAccountsScreen extends StatefulWidget {
  const AdminAccountsScreen({super.key});

  @override
  State<AdminAccountsScreen> createState() => _AdminAccountsScreenState();
}

class _AdminAccountsScreenState extends State<AdminAccountsScreen> {
  static const _pageSize = 20;
  final _query = TextEditingController();
  bool _byName = false;
  String? _role;
  AccountStatus? _status;
  int _offset = 0;
  AdminAccountPage? _page;
  Object? _error;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final api = context.services.adminConsole;
    if (api == null) return;
    final q = _query.text.trim();
    setState(() {
      _page = null;
      _error = null;
    });
    try {
      final page = await api.adminAccounts(
        email: _byName || q.isEmpty ? null : q,
        name: _byName && q.isNotEmpty ? q : null,
        role: _role,
        status: _status,
        limit: _pageSize,
        offset: _offset,
      );
      if (mounted) setState(() => _page = page);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _reload() {
    _offset = 0;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMd(locale);
    final page = _page;
    return LgPage(
      title: l.adminUsers,
      showProfile: false,
      children: [
        SignedInGate(
          child: AdminGate(
            panel: true,
            child: AdminAutoLoad(
              onLoad: _load,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      LgChoiceChip(
                        label: l.admSearchModeEmail,
                        selected: !_byName,
                        onTap: () => setState(() => _byName = false),
                      ),
                      LgChoiceChip(
                        label: l.admSearchModeName,
                        selected: _byName,
                        onTap: () => setState(() => _byName = true),
                      ),
                    ],
                  ),
                  LgField(
                    key: const ValueKey('admin-user-search'),
                    label: _byName ? l.admSearchName : l.admSearchEmail,
                    controller: _query,
                    keyboardType: _byName
                        ? TextInputType.text
                        : TextInputType.emailAddress,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _reload(),
                  ),
                  const SizedBox(height: 6),
                  Text(l.admUsersSearchNote, style: text.bodySmall),
                  const SizedBox(height: 8),
                  LgButton.secondary(
                    key: const ValueKey('admin-user-search-button'),
                    label: l.admSearch,
                    icon: Icons.search_rounded,
                    onPressed: _reload,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final r in [
                        null,
                        'student',
                        'teacher',
                        'doctor',
                        'lab',
                      ])
                        LgChoiceChip(
                          label: r == null ? l.adminAllRoles : roleLabel(r, l),
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
                      for (final (s, label) in [
                        (null, l.adminAllStatuses),
                        (AccountStatus.active, l.admStatusActive),
                        (AccountStatus.suspended, l.admStatusSuspended),
                      ])
                        LgChoiceChip(
                          label: label,
                          selected: _status == s,
                          onTap: () {
                            _status = s;
                            _reload();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _Async<AdminAccountPage>(
                    value: page,
                    error: _error,
                    onRetry: _load,
                    builder: (page) => page.rows.isEmpty
                        ? LgStateView(
                            kind: StateKind.empty,
                            title: l.adminNoUsers,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final (i, u) in page.rows.indexed)
                                LgRow(
                                  key: ValueKey('admin-user-${u.userId}'),
                                  title: u.emailMasked,
                                  subtitle: [
                                    '${roleLabel(u.role, l)} · ${u.language?.toUpperCase() ?? '—'}',
                                    l.adminRegisteredOn(
                                      date.format(u.registeredOn.toLocal()),
                                    ),
                                    if (u.lastSeenOn != null)
                                      l.adminLastSeen(
                                        date.format(u.lastSeenOn!),
                                      ),
                                  ].join('\n'),
                                  icon: u.status == AccountStatus.suspended
                                      ? Icons.person_off_outlined
                                      : Icons.person_outline_rounded,
                                  trailing: u.admin
                                      ? LgTag(l.admUserAdminTag)
                                      : u.status == AccountStatus.suspended
                                      ? LgTag(
                                          l.admStatusSuspended,
                                          tone: LgTone.warning,
                                        )
                                      : null,
                                  divider: i < page.rows.length - 1,
                                  onTap: () async {
                                    await context.push(
                                      '/profile/admin/users/${u.userId}',
                                    );
                                    await _load();
                                  },
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
                                              _load();
                                            },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: LgButton.secondary(
                                      label: l.adminNext,
                                      onPressed:
                                          _offset + page.rows.length >=
                                              page.total
                                          ? null
                                          : () {
                                              _offset += _pageSize;
                                              _load();
                                            },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key, required this.userId});

  final String userId;

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  AdminUserDetail? _u;
  Object? _error;

  /// Tasdiqlangan amal serverda ketyapti (tugmalar "band").
  bool _busy = false;

  /// Hisob shu sahifadan o'chirildi (D-63): ma'lumot endi yo'q.
  bool _deleted = false;

  @override
  void didUpdateWidget(AdminUserScreen old) {
    super.didUpdateWidget(old);
    // Bir xil yo'l, boshqa foydalanuvchi (go_router sahifani qayta ishlatadi).
    if (old.userId != widget.userId) {
      _u = null;
      _load();
    }
  }

  Future<void> _load() async {
    final api = context.services.adminConsole;
    if (api == null) return;
    setState(() => _error = null);
    try {
      final u = await api.adminUserDetail(widget.userId);
      if (mounted) setState(() => _u = u);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// Qulf tasdiq oynasidan OLDIN sinxron qo'yiladi: tez ikki bosish ikkita
  /// oyna/amal ochmaydi. Step-up so'ralsa — backend kodni so'rab, so'rovni
  /// bir marta qaytaradi (lib/app/app.dart).
  Future<void> _run(
    Future<void> Function() action, {
    String? title,
    String? body,
    String? confirm,
    String? done,
    String Function()? doneText,
  }) => SingleFlight.run((#adminUserAction, this), () async {
    final l = AppLocalizations.of(context);
    if (_busy) return;
    if (title != null) {
      final ok = await confirmDialog(
        context,
        title: title,
        body: body ?? '',
        action: confirm ?? title,
      );
      if (!ok || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      _snack(context, doneText?.call() ?? done ?? '');
      await _load();
    } on Object catch (e) {
      if (mounted) _snack(context, adminConsoleErrorText(e, l));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final api = context.services.adminConsole;
    return LgPage(
      title: l.admUserTitle,
      showProfile: false,
      children: [
        if (api == null)
          _unavailable(l)
        else if (_deleted)
          LgStateView(
            key: const ValueKey('admin-user-deleted'),
            kind: StateKind.success,
            title: l.admDeleteDone,
            actionLabel: l.adminUsers,
            // Ro'yxatdan ochilgan bo'lsa — orqaga (ro'yxat qayta yuklanadi).
            onAction: () => context.canPop()
                ? context.pop()
                : context.go('/profile/admin/users'),
          )
        else
          SignedInGate(
            child: AdminGate(
              panel: true,
              child: AdminAutoLoad(
                onLoad: _load,
                child: _Async<AdminUserDetail>(
                  value: _u,
                  error: _error,
                  onRetry: _load,
                  builder: (u) => _detail(context, l, api, u),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _detail(
    BuildContext context,
    AppLocalizations l,
    AdminConsoleBackend api,
    AdminUserDetail u,
  ) {
    final text = Theme.of(context).textTheme;
    final a = u.account;
    final date = DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final suspended = a.status == AccountStatus.suspended;
    final locked = u.you || a.admin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.emailMasked, style: text.titleMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (a.admin) LgTag(l.admUserAdminTag),
                  if (u.you) LgTag(l.admYou, tone: LgTone.neutral),
                  LgTag(
                    suspended ? l.admStatusSuspended : l.admStatusActive,
                    tone: suspended ? LgTone.warning : LgTone.brand,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                [
                  '${roleLabel(a.role, l)} · ${a.language?.toUpperCase() ?? '—'}',
                  l.adminRegisteredOn(date.format(a.registeredOn.toLocal())),
                  if (a.lastSeenOn != null)
                    l.adminLastSeen(date.format(a.lastSeenOn!)),
                  l.admUserFacts(
                    u.groupsOwned,
                    u.groupsJoined,
                    u.supportThreads,
                    u.complaints,
                  ),
                ].join('\n'),
                style: text.bodyMedium,
              ),
            ],
          ),
        ),
        LgSectionTitle(l.admUserRole),
        if (u.you)
          LgNotice(l.admRoleSelfNote, kind: NoticeKind.info)
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final r in ['student', 'teacher', 'doctor', 'lab'])
                LgChoiceChip(
                  key: ValueKey('admin-role-$r'),
                  label: roleLabel(r, l),
                  selected: a.role == r,
                  onTap: _busy || a.role == r
                      ? () {}
                      : () => _run(
                          () => api.adminSetRole(a.userId, r),
                          done: l.admRoleChanged,
                        ),
                ),
            ],
          ),
        LgSectionTitle(l.admAccountTitle),
        if (locked)
          LgNotice(
            a.admin ? l.admAccountAdminNote : l.admRoleSelfNote,
            kind: NoticeKind.info,
          )
        else if (suspended)
          LgButton(
            key: const ValueKey('admin-reactivate'),
            label: l.admAccountReactivate,
            icon: Icons.lock_open_rounded,
            busy: _busy,
            onPressed: () => _run(
              () => api.adminReactivateAccount(a.userId),
              title: l.admAccountReactivateTitle,
              body: l.admAccountReactivateBody,
              confirm: l.admAccountReactivate,
              done: l.cmAdminDone,
            ),
          )
        else
          LgButton.secondary(
            key: const ValueKey('admin-suspend'),
            label: l.admAccountSuspend,
            icon: Icons.person_off_outlined,
            busy: _busy,
            onPressed: () => _run(
              () => api.adminSuspendAccount(a.userId),
              title: l.admAccountSuspendTitle,
              body: l.admAccountSuspendBody,
              confirm: l.admAccountSuspend,
              done: l.cmAdminDone,
            ),
          ),
        if (!u.you) ...[
          const SizedBox(height: 8),
          LgButton.secondary(
            key: const ValueKey('admin-revoke-sessions'),
            label: l.admRevokeSessions,
            icon: Icons.devices_other_outlined,
            busy: _busy,
            onPressed: () {
              var n = 0;
              _run(
                () async => n = await api.adminRevokeSessions(a.userId),
                title: l.admRevokeSessions,
                body: l.admRevokeSessionsBody,
                confirm: l.admRevokeSessions,
                doneText: () => l.admRevokeSessionsDone(n),
              );
            },
          ),
        ],
        if (!locked) ...[
          LgSectionTitle(l.admDeleteTitle),
          AdminDeleteAccountPanel(
            key: ValueKey('admin-delete-${a.userId}'),
            account: a,
            api: api,
            onDeleted: () {
              if (mounted) setState(() => _deleted = true);
            },
          ),
        ],
        LgSectionTitle(l.admUserCommunity),
        Text(
          '${communityStatusLabel(u.communityStatus, l)}\n'
          '${l.admUserCommunityFacts(u.questions, u.answers, u.reporters)}',
          style: text.bodyMedium,
        ),
        const SizedBox(height: 8),
        if (!u.communityOwner && !u.you)
          u.communitySuspended
              ? LgButton.secondary(
                  key: const ValueKey('admin-community-restore'),
                  label: l.cmAdminRestore,
                  icon: Icons.restore_rounded,
                  busy: _busy,
                  onPressed: () => _run(
                    () => api.adminRestoreCommunity(a.userId),
                    title: l.cmAdminRestoreTitle,
                    body: l.cmAdminRestoreBody,
                    confirm: l.cmAdminRestore,
                    done: l.cmAdminDone,
                  ),
                )
              : LgButton.secondary(
                  key: const ValueKey('admin-community-suspend'),
                  label: l.admCommunitySuspend,
                  icon: Icons.speaker_notes_off_outlined,
                  busy: _busy,
                  onPressed: () => _run(
                    () => api.adminSuspendCommunity(a.userId),
                    title: l.admCommunitySuspendTitle,
                    body: l.admCommunitySuspendBody,
                    confirm: l.admCommunitySuspend,
                    done: l.cmAdminDone,
                  ),
                ),
      ],
    );
  }
}

/// Hisobni butunlay o'chirish (D-63): emailda kelgan so'rov bo'yicha egasi
/// foydalanuvchining TO'LIQ emailini qayta kiritadi — server uni HMAC qilib
/// shu hisob bilan solishtiradi (`confirm_user_id`), so'ng tasdiq oynasi.
/// O'chirish yo'li — foydalanuvchi o'zi o'chirgandagi bilan bir xil.
class AdminDeleteAccountPanel extends StatefulWidget {
  const AdminDeleteAccountPanel({
    super.key,
    required this.account,
    required this.api,
    required this.onDeleted,
  });

  final AdminAccountRow account;
  final AdminConsoleBackend api;

  /// Hisob o'chirildi — sahifa "o'chirildi" holatiga o'tadi.
  final VoidCallback onDeleted;

  @override
  State<AdminDeleteAccountPanel> createState() =>
      _AdminDeleteAccountPanelState();
}

class _AdminDeleteAccountPanelState extends State<AdminDeleteAccountPanel> {
  final _email = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final email = _email.text.trim();
    if (email.isEmpty) return;
    // Qulf tasdiq oynasidan OLDIN: tez ikki bosish — bitta oyna, bitta so'rov.
    await SingleFlight.run((#adminDeleteAccount, this), () async {
      final l = AppLocalizations.of(context);
      final ok = await confirmDialog(
        context,
        title: l.admDeleteConfirmTitle,
        body: l.admDeleteConfirmBody(widget.account.emailMasked),
        action: l.admDeleteButton,
      );
      if (!ok || !mounted) return;
      setState(() => _busy = true);
      try {
        await widget.api.adminDeleteAccount(
          email: email,
          confirmUserId: widget.account.userId,
        );
        if (mounted) _snack(context, l.admDeleteDone);
        widget.onDeleted();
      } on Object catch (e) {
        if (mounted) setState(() => _error = adminConsoleErrorText(e, l));
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgNotice(l.admDeleteNote, kind: NoticeKind.warning),
        const SizedBox(height: 8),
        LgField(
          key: const ValueKey('admin-delete-email'),
          label: l.admDeleteEmail,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          errorText: _error,
          // Tugma holati va eski xato matni yozish bilan yangilanadi.
          onChanged: (_) => setState(() => _error = null),
          onSubmitted: (_) => _delete(),
        ),
        const SizedBox(height: 8),
        LgButton.secondary(
          key: const ValueKey('admin-delete-account'),
          label: l.admDeleteButton,
          icon: Icons.delete_forever_outlined,
          busy: _busy,
          onPressed: _email.text.trim().isEmpty ? null : _delete,
        ),
      ],
    );
  }
}

/// Bosh sahifadagi “email orqali kelgan shikoyatlar” izohi.
class AdminEmailNote extends StatelessWidget {
  const AdminEmailNote({super.key});

  @override
  Widget build(BuildContext context) => LgNotice(
    AppLocalizations.of(context).admEmailNote(Contact.email),
    kind: NoticeKind.info,
  );
}
