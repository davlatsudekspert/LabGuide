import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../core/backend/admin_console.dart';
import '../../core/backend/backend_models.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';

/// Ilova ichidan shikoyat yuborish (Apple 1.2: nomaqbul kontent haqida xabar
/// berish). Server ulangan buildda ko'rinadi; mehmon ham yuboradi (javob
/// berib bo'lmasligi ochiq aytiladi). Limit serverda: soatiga 5 ta.
class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key, required this.api, this.targetRef});

  final ComplaintsBackend api;

  /// Ixtiyoriy ishora: ekran/karta/post id (masalan, `community:question:abc`).
  final String? targetRef;

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _text = TextEditingController();
  late ComplaintKind _kind = widget.targetRef == null
      ? ComplaintKind.complaint
      : ComplaintKind.inappropriate;
  String Function(AppLocalizations)? _error;
  bool _busy = false;
  bool _sent = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  String _kindLabel(ComplaintKind k, AppLocalizations l) => switch (k) {
    ComplaintKind.complaint => l.complaintKindComplaint,
    ComplaintKind.inappropriate => l.complaintKindInappropriate,
    ComplaintKind.bug => l.complaintKindBug,
    ComplaintKind.ad => l.complaintKindAd,
    ComplaintKind.other => l.complaintKindOther,
  };

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.length < 5) {
      setState(() => _error = (l) => l.complaintTooShort);
      return;
    }
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.submitComplaint(
        kind: _kind,
        body: body,
        targetRef: widget.targetRef,
        lang: Localizations.localeOf(context).languageCode,
      );
      if (!mounted) return;
      _text.clear();
      setState(() => _sent = true);
    } on ComplaintException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.failure == BackendFailure.rateLimited) {
          final minutes = ((e.retryAfter?.inSeconds ?? 3600) / 60).ceil();
          _error = (l) => l.complaintRateLimited(minutes.clamp(1, 60));
        } else if (e.failure == BackendFailure.invalid) {
          _error = (l) => l.complaintTooShort;
        } else {
          _error = (l) => l.complaintFailed;
        }
      });
    } on Object {
      if (mounted) setState(() => _error = (l) => l.complaintFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final signedIn = context.services.auth.hasAccount;
    return LgPanel(
      key: const ValueKey('complaint-form'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.complaintFormTitle, style: text.titleMedium),
          const SizedBox(height: 6),
          Text(l.complaintFormBody, style: text.bodyMedium),
          const SizedBox(height: 10),
          Text(l.complaintKindLabel, style: text.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final k in ComplaintKind.values)
                LgChoiceChip(
                  key: ValueKey('complaint-kind-${k.wire}'),
                  label: _kindLabel(k, l),
                  selected: _kind == k,
                  onTap: () => setState(() => _kind = k),
                ),
            ],
          ),
          if (widget.targetRef != null) ...[
            const SizedBox(height: 8),
            Text(l.complaintTarget(widget.targetRef!), style: text.bodySmall),
          ],
          LgField(
            key: const ValueKey('complaint-text'),
            label: l.complaintText,
            controller: _text,
            hint: l.complaintTextHint,
            maxLines: 5,
            maxLength: 2000,
            keyboardType: TextInputType.multiline,
            onChanged: (_) {
              if (_sent || _error != null) {
                setState(() {
                  _sent = false;
                  _error = null;
                });
              }
            },
          ),
          Text(l.complaintPhiNote, style: text.bodySmall),
          if (!signedIn) ...[
            const SizedBox(height: 6),
            Text(l.complaintAnonNote, style: text.bodySmall),
          ],
          if (_error != null) LgNotice(_error!(l), kind: NoticeKind.error),
          if (_sent) LgNotice(l.complaintSent, kind: NoticeKind.info),
          const SizedBox(height: 10),
          LgButton(
            key: const ValueKey('complaint-send'),
            label: l.complaintSend,
            icon: Icons.send_rounded,
            busy: _busy,
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}
