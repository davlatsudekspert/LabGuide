import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/backend/pro_grants.dart';
import '../../core/entitlements/pro_catalog.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/otp_auth.dart' show isValidEmail, normalizeEmail;
import '../learn/exam_widgets.dart' show confirmDialog;
import '../support/support_screens.dart';
import 'admin_screens.dart';

String proPlanLabel(AppLocalizations l, ProPlan plan) => switch (plan) {
  ProPlan.student => l.proPlanStudent,
  ProPlan.teacher => l.proPlanTeacher,
  ProPlan.specialist => l.proPlanSpecialist,
  ProPlan.premium => l.proPlanPremium,
};

String _durationLabel(AppLocalizations l, int? days) =>
    days == null ? l.proGrantUntilRevoked : l.proGrantDays(days);

/// Admin: “Pro berish” (D-73). Faqat `BuildFlags.proEnabled` VA server
/// ([ProGrantBackend]) bo'lganda ochiladi; kirish [AdminGate] ichida (admin
/// roli + TOTP) — vakolatni har so'rovda server qayta tekshiradi.
class AdminProGrantScreen extends StatefulWidget {
  const AdminProGrantScreen({super.key});

  @override
  State<AdminProGrantScreen> createState() => _AdminProGrantScreenState();
}

class _AdminProGrantScreenState extends State<AdminProGrantScreen> {
  final _email = TextEditingController();
  final _note = TextEditingController();
  ProPlan _plan = ProPlan.student;
  int? _days = 30;
  bool _months = false;
  final _custom = TextEditingController();
  bool _extend = false;
  List<ProGrant>? _grants;
  Object? _error;
  String? _formError;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _note.dispose();
    _custom.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final api = context.services.proGrants;
    if (api == null) return;
    try {
      final g = await api.proGrants();
      if (mounted) {
        setState(() {
          _grants = g;
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
    ProGrantException(code: 'invalid_email') => l.admInvalidEmail,
    ProGrantException(code: 'invalid_note') => l.proGrantErrNote,
    ProGrantException(code: 'pending_cannot_extend') => l.proGrantErrPending,
    ProGrantException(code: 'duration_required') => l.proGrantErrDuration,
    ProGrantException(code: 'too_many_grants') => l.proGrantErrMany,
    ProGrantException(code: 'tier_not_comparable') => l.proGrantErrTierMix,
    _ => backendErrorText(e, l),
  };

  /// Qo'lda kiritilgan son (kun yoki oy) → `_days`. Noto'g'ri bo'lsa `false`.
  bool _applyCustom() {
    final n = int.tryParse(_custom.text.trim());
    if (n == null || n < 1) return false;
    final days = _months ? n * proGrantDaysPerMonth : n;
    if (days > proGrantMaxDays) return false;
    _days = days;
    return true;
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final api = context.services.proGrants;
    if (api == null || _busy) return;
    final email = _email.text.trim();
    if (!isValidEmail(email)) {
      setState(() => _formError = l.admInvalidEmail);
      return;
    }
    if (_note.text.trim().length > proGrantNoteMax) {
      setState(() => _formError = l.proGrantErrNote);
      return;
    }
    if (_custom.text.trim().isNotEmpty && !_applyCustom()) {
      setState(() => _formError = l.proGrantErrRange(proGrantMaxDays));
      return;
    }
    if (_extend && _days == null) {
      setState(() => _formError = l.proGrantErrDuration);
      return;
    }
    setState(() => _formError = null);
    final ok = await confirmDialog(
      context,
      title: l.proGrantConfirmTitle,
      body: l.proGrantConfirmBody(
        normalizeEmail(email),
        proPlanLabel(l, _plan),
        _durationLabel(l, _days),
      ),
      action: l.proGrantSubmit,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      final r = await api.grantPro(
        email: email,
        plan: _plan,
        durationDays: _days,
        note: _note.text,
        extend: _extend,
      );
      if (!mounted) return;
      _email.clear();
      _note.clear();
      _snack(
        r.extended
            ? l.proGrantExtended(r.grant.emailMasked)
            : r.replaced
            ? l.proGrantReplaced(r.grant.emailMasked)
            : l.proGrantDone(r.grant.emailMasked),
      );
      await _load();
    } on Object catch (e) {
      if (mounted) setState(() => _formError = _errorText(e, l));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _revoke(ProGrant g) async {
    final l = AppLocalizations.of(context);
    final api = context.services.proGrants;
    if (api == null) return;
    final ok = await confirmDialog(
      context,
      title: l.proGrantRevokeTitle,
      body: l.proGrantRevokeBody(g.emailMasked),
      action: l.proGrantRevoke,
    );
    if (!ok || !mounted) return;
    try {
      await api.revokePro(g.id);
      if (!mounted) return;
      _snack(l.proGrantRevoked(g.emailMasked));
      await _load();
    } on Object catch (e) {
      if (mounted) _snack(_errorText(e, l));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final available = context.services.proGrants != null;
    return LgPage(
      title: l.proGrantTitle,
      showProfile: false,
      children: [
        if (!available)
          LgStateView(kind: StateKind.unavailable, title: l.admNotConnected)
        else
          SignedInGate(
            child: AdminGate(
              child: AdminAutoLoad(
                onLoad: _load,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.proGrantIntro, style: text.bodyMedium),
                    const SizedBox(height: 14),
                    _form(context, l),
                    ..._list(context, l),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _form(BuildContext context, AppLocalizations l) {
    final text = Theme.of(context).textTheme;
    return LgPanel(
      key: const ValueKey('pro-grant-form'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgField(
            key: const ValueKey('pro-grant-email'),
            label: l.proGrantEmail,
            controller: _email,
            hint: 'name@gmail.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            errorText: _formError,
          ),
          const SizedBox(height: 12),
          Text(l.proGrantTier, style: text.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in ProPlan.values)
                LgChoiceChip(
                  key: ValueKey('pro-grant-plan-${p.name}'),
                  label: proPlanLabel(l, p),
                  selected: _plan == p,
                  onTap: () => setState(() => _plan = p),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l.proGrantDuration, style: text.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in proGrantDurations)
                LgChoiceChip(
                  key: ValueKey('pro-grant-days-${d ?? 'forever'}'),
                  label: _durationLabel(l, d),
                  selected: _days == d,
                  onTap: () => setState(() {
                    _days = d;
                    _custom.clear();
                  }),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: LgField(
                  key: const ValueKey('pro-grant-custom'),
                  label: l.proGrantCustom,
                  controller: _custom,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(_applyCustom),
                ),
              ),
              const SizedBox(width: 8),
              LgChoiceChip(
                key: const ValueKey('pro-grant-unit-days'),
                label: l.proGrantUnitDays,
                selected: !_months,
                onTap: () => setState(() {
                  _months = false;
                  _applyCustom();
                }),
              ),
              const SizedBox(width: 6),
              LgChoiceChip(
                key: const ValueKey('pro-grant-unit-months'),
                label: l.proGrantUnitMonths,
                selected: _months,
                onTap: () => setState(() {
                  _months = true;
                  _applyCustom();
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LgField(
            key: const ValueKey('pro-grant-note'),
            label: l.proGrantNote,
            controller: _note,
            maxLength: proGrantNoteMax,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: LgChoiceChip(
              key: const ValueKey('pro-grant-extend'),
              label: l.proGrantExtend,
              selected: _extend,
              onTap: () => setState(() => _extend = !_extend),
            ),
          ),
          const SizedBox(height: 12),
          LgButton(
            key: const ValueKey('pro-grant-submit'),
            label: l.proGrantSubmit,
            icon: Icons.workspace_premium_outlined,
            busy: _busy,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  List<Widget> _list(BuildContext context, AppLocalizations l) {
    final text = Theme.of(context).textTheme;
    final grants = _grants;
    if (_error != null && grants == null) {
      return [
        const SizedBox(height: 12),
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
    if (grants == null) {
      return const [LgStateView(kind: StateKind.loading, title: '')];
    }
    final date = DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return [
      LgSectionTitle(l.proGrantListTitle(grants.length)),
      if (grants.isEmpty) Text(l.proGrantEmpty, style: text.bodyMedium),
      for (final (i, g) in grants.indexed)
        LgRow(
          key: ValueKey('pro-grant-${g.id}'),
          title: g.emailMasked,
          subtitle: [
            proPlanLabel(l, g.plan),
            if (g.pending)
              l.proGrantPending
            else if (g.expiresAt == null)
              l.proGrantUntilRevoked
            else
              l.proGrantUntil(date.format(g.expiresAt!.toLocal())),
            if (g.note != null && g.note!.isNotEmpty) g.note!,
          ].join('\n'),
          icon: Icons.workspace_premium_outlined,
          divider: i < grants.length - 1,
          trailing: IconButton(
            key: ValueKey('pro-grant-revoke-${g.id}'),
            tooltip: l.proGrantRevoke,
            icon: const Icon(Icons.person_remove_outlined),
            onPressed: () => _revoke(g),
          ),
        ),
    ];
  }
}
