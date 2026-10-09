import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/backend/partner_models.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../support/support_screens.dart' show backendErrorText, formatWhen;

String partnerRequestStatusLabel(PartnerRequestStatus s, AppLocalizations l) =>
    switch (s) {
      PartnerRequestStatus.newRequest => l.partnerReqStatusNew,
      PartnerRequestStatus.inReview => l.partnerReqStatusInReview,
      PartnerRequestStatus.accepted => l.partnerReqStatusAccepted,
      PartnerRequestStatus.declined => l.partnerReqStatusDeclined,
    };

LgTone partnerRequestTone(PartnerRequestStatus s) => switch (s) {
  PartnerRequestStatus.newRequest ||
  PartnerRequestStatus.inReview => LgTone.warning,
  PartnerRequestStatus.accepted => LgTone.brand,
  PartnerRequestStatus.declined => LgTone.neutral,
};

/// “Hamkor bo'lish” — firmalar uchun taklif, qoidalar va ariza. Narx
/// o'ylab topilmaydi (“narx kelishiladi”), auditoriya soni aytilmaydi.
class BecomePartnerScreen extends StatefulWidget {
  const BecomePartnerScreen({super.key});

  @override
  State<BecomePartnerScreen> createState() => _BecomePartnerScreenState();
}

class _BecomePartnerScreenState extends State<BecomePartnerScreen> {
  final _company = TextEditingController();
  final _contact = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _products = TextEditingController();
  final _message = TextEditingController();
  String? _error;
  bool _busy = false;
  List<PartnerRequest>? _requests;
  bool? _signedIn;

  /// Ariza hozirgina yuborildi — forma o'rnida tasdiq.
  bool _sent = false;

  @override
  void dispose() {
    for (final c in [_company, _contact, _phone, _email, _products, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadRequests() async {
    final backend = context.services.backend;
    if (!backend.isConfigured || !backend.hasSession) return;
    if (_email.text.isEmpty) _email.text = backend.sessionEmail ?? '';
    try {
      final list = await backend.myPartnerRequests();
      if (mounted) setState(() => _requests = list);
    } on Object catch (e) {
      debugPrint('partner requests: $e');
    }
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    String? opt(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    final draft = PartnerRequestDraft(
      company: _company.text,
      contactName: _contact.text,
      phone: opt(_phone),
      email: opt(_email),
      products: _products.text,
      message: _message.text,
    );
    if (!draft.isValid) {
      setState(() => _error = l.partnerFormInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.services.backend.createPartnerRequest(draft);
      if (!mounted) return;
      for (final c in [_company, _contact, _phone, _products, _message]) {
        c.clear();
      }
      setState(() => _sent = true);
      await _loadRequests();
    } on Object catch (e) {
      if (mounted) setState(() => _error = backendErrorText(e, l));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.partnerBecome,
      subtitle: l.partnerBecomeSub,
      showProfile: false,
      children: [
        LgHeroCard(title: l.partnerOfferTitle, body: l.partnerOfferBody),
        LgSectionTitle(l.partnerWhatTitle),
        _Point(
          icon: Icons.precision_manufacturing_outlined,
          text: l.partnerWhatCard,
        ),
        _Point(icon: Icons.category_outlined, text: l.partnerWhatCategory),
        _Point(icon: Icons.dashboard_outlined, text: l.partnerWhatLabHome),
        _Point(icon: Icons.storefront_outlined, text: l.partnerWhatPage),
        _Point(icon: Icons.bar_chart_rounded, text: l.partnerWhatReport),
        LgSectionTitle(l.partnerAudienceTitle),
        Text(l.partnerAudienceBody, style: text.bodyMedium),
        LgSectionTitle(l.partnerRulesTitle),
        _Point(icon: Icons.campaign_outlined, text: l.partnerRule1),
        _Point(icon: Icons.fact_check_outlined, text: l.partnerRule2),
        _Point(icon: Icons.assignment_outlined, text: l.partnerRule3),
        _Point(icon: Icons.rule_rounded, text: l.partnerRule4),
        _Point(icon: Icons.lock_outline_rounded, text: l.partnerRule5),
        LgSectionTitle(l.partnerPriceTitle),
        LgPanel(
          soft: true,
          child: Text(l.partnerPriceBody, style: text.bodyLarge),
        ),
        LgSectionTitle(l.partnerHowTitle),
        LgSteps([l.partnerHow1, l.partnerHow2, l.partnerHow3, l.partnerHow4]),
        _account(context),
      ],
    );
  }

  /// Hisobga bog'liq qism: arizalar holati va forma (server ulanmagan
  /// bo'lsa — halol izoh, kirmagan bo'lsa — kirish taklifi).
  Widget _account(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final services = context.services;
    if (!services.backend.isConfigured) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgSectionTitle(l.partnerFormTitle),
          LgNotice(l.partnerFormUnavailable),
        ],
      );
    }
    return ListenableBuilder(
      listenable: services.auth,
      builder: (context, _) {
        final signedIn = services.auth.hasAccount;
        if (signedIn != _signedIn) {
          _signedIn = signedIn;
          _requests = null;
          _sent = false;
          if (signedIn) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _loadRequests(),
            );
          }
        }
        if (!signedIn) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LgSectionTitle(l.partnerFormTitle),
              LgPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.partnerFormSignIn, style: text.bodyMedium),
                    const SizedBox(height: 12),
                    LgButton(
                      label: l.profileSignIn,
                      icon: Icons.mail_outline_rounded,
                      onPressed: () => context.push('/profile/auth'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_requests case final list? when list.isNotEmpty) ...[
              LgSectionTitle(l.partnerMyRequests),
              for (final r in list) _RequestTile(request: r),
            ],
            LgSectionTitle(l.partnerFormTitle),
            if (_sent)
              LgStateView(
                kind: StateKind.success,
                title: l.partnerSentTitle,
                message: l.partnerSentBody,
                secondary: LgButton.link(
                  label: l.partnerSendAnother,
                  icon: Icons.add_rounded,
                  onPressed: () => setState(() => _sent = false),
                ),
              )
            else
              _form(context),
          ],
        );
      },
    );
  }

  Widget _form(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgField(
          label: l.partnerFormCompany,
          controller: _company,
          maxLength: 120,
          textInputAction: TextInputAction.next,
        ),
        LgField(
          label: l.partnerFormContact,
          controller: _contact,
          maxLength: 80,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
        ),
        LgField(
          label: l.partnerFormPhone,
          controller: _phone,
          hint: '+998 __ ___ __ __',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumber],
        ),
        LgField(
          label: l.partnerFormEmail,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(l.partnerFormHint, style: text.bodySmall),
        ),
        LgField(
          label: l.partnerFormProducts,
          controller: _products,
          maxLines: 3,
          maxLength: 1000,
          keyboardType: TextInputType.multiline,
        ),
        LgField(
          label: l.partnerFormMessage,
          controller: _message,
          maxLines: 4,
          maxLength: 2000,
          keyboardType: TextInputType.multiline,
        ),
        if (_error != null) LgNotice(_error!, kind: NoticeKind.error),
        const SizedBox(height: 12),
        LgButton(
          label: l.partnerFormSend,
          icon: Icons.send_rounded,
          busy: _busy,
          onPressed: _send,
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: p.soft,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: p.brand),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});

  final PartnerRequest request;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final r = request;
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LgTag(
            partnerRequestStatusLabel(r.status, l),
            tone: partnerRequestTone(r.status),
          ),
          const SizedBox(height: 8),
          Text(r.company, style: text.titleSmall),
          Text(formatWhen(r.createdAt, context), style: text.bodySmall),
          if (r.adminReply case final reply?) ...[
            const SizedBox(height: 8),
            Text(l.partnerReqReply(reply), style: text.bodyMedium),
          ],
        ],
      ),
    );
  }
}
