import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/backend/backend_models.dart';
import '../../core/backend/step_up.dart';
import '../../core/single_flight.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../support/support_screens.dart' show backendErrorText;

/// Admin STEP-UP oynasi: server xavfli amal uchun yangi tasdiq so'radi
/// (`403 step_up_required`). Email usulida kod shu oyna ochilganda
/// yuboriladi; TOTP usulida — autentifikator kodi. `true` — tasdiqlandi
/// (chaqiruvchi so'rovni bir marta qaytaradi), `false` — bekor qilindi.
Future<bool> showStepUpDialog(
  BuildContext context,
  StepUpBackend backend,
) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => StepUpDialog(backend: backend),
  );
  return ok ?? false;
}

class StepUpDialog extends StatefulWidget {
  const StepUpDialog({super.key, required this.backend});

  final StepUpBackend backend;

  @override
  State<StepUpDialog> createState() => _StepUpDialogState();
}

class _StepUpDialogState extends State<StepUpDialog> with BusyGuard {
  final _code = TextEditingController();
  StepUpChallenge? _challenge;
  String? _error;
  bool _loading = true;

  static const _verifyKey = #verify;
  static const _resendKey = #resend;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _request());
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  String _text(Object e, AppLocalizations l) => switch (e) {
    StepUpException(code: 'invalid_code', :final attemptsLeft)
        when attemptsLeft != null =>
      l.otpInvalid(attemptsLeft),
    StepUpException(code: 'invalid_code') => l.adminMfaWrong,
    StepUpException(code: 'expired') => l.otpExpired,
    StepUpException(code: 'no_active_code') => l.otpNoActiveCode,
    StepUpException(code: 'too_many_attempts') => l.otpTooManyAttempts,
    BackendException(failure: BackendFailure.rateLimited) => l.errRateLimited,
    _ => backendErrorText(e, l),
  };

  Future<void> _request({bool resend = false}) => guard(() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final c = await widget.backend.requestStepUp();
      if (!mounted) return;
      setState(() {
        _challenge = c;
        _error = null;
        _loading = false;
      });
      if (resend) {
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l.otpResent)));
      }
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _text(e, l);
        _loading = false;
        // Kod allaqachon yuborilgan (60 soniya ichida qayta ochildi) —
        // kiritish maydoni baribir ko'rsatiladi.
        _challenge ??= const StepUpChallenge(method: StepUpMethod.email);
      });
    }
  }, key: _resendKey);

  Future<void> _verify() => guard(() async {
    final l = AppLocalizations.of(context);
    final code = _code.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = l.otpFormat);
      return;
    }
    try {
      await widget.backend.verifyStepUp(code);
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) setState(() => _error = _text(e, l));
    }
  }, key: _verifyKey);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = _challenge;
    final body = c == null
        ? ''
        : c.method == StepUpMethod.totp
        ? l.stepUpBodyTotp
        : c.emailMasked == null
        ? l.stepUpBodyEmailNoAddress
        : l.stepUpBodyEmail(c.emailMasked!);
    return AlertDialog(
      title: Text(l.stepUpTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              Text(body),
              LgField(
                label: l.otpCodeLabel,
                controller: _code,
                hint: '••••••',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                errorText: _error,
                onSubmitted: (_) => _verify(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isBusy(_verifyKey)
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(l.actionCancel),
        ),
        if (c != null && c.method == StepUpMethod.email)
          TextButton(
            onPressed: anyBusy ? null : () => _request(resend: true),
            child: Text(l.otpResend),
          ),
        TextButton(
          key: const ValueKey('step-up-confirm'),
          onPressed: _loading || anyBusy ? null : _verify,
          child: Text(l.stepUpConfirm),
        ),
      ],
    );
  }
}
