import 'package:flutter/foundation.dart';

import 'backend_models.dart';

/// Admin STEP-UP (server: `cloudflare/src/stepup.ts`). Xavfli admin amali
/// (hisobni o'chirish/to'xtatish, rol, adminlar, sessiyalarni bekor qilish,
/// moderatsiya) yoki muddati o'tgan admin oynasi (12 soat / 30 daqiqa)
/// serverdan `403 step_up_required` oladi. Ilova kodni so'raydi
/// ([stepUpPrompt]) va so'rovni BIR marta qaytaradi.
///
/// Usul serverda tanlanadi: admin TOTP faktori bo'lsa — autentifikator kodi,
/// aks holda — egasining emailiga yangi 6 xonali kod.
abstract interface class StepUpBackend {
  /// Kod so'rash. Email usulida kod yuboriladi (qayta yuborish 60 soniya).
  Future<StepUpChallenge> requestStepUp();

  /// Kodni tasdiqlash. Xato — [StepUpException] (`invalid_code`,
  /// `expired`, `no_active_code`, `too_many_attempts`, `rate_limited`).
  Future<void> verifyStepUp(String code);

  /// Ilova ro'yxatdan o'tkazadigan so'rovchi: `true` — tasdiqlandi (so'rov
  /// qaytariladi), `false` — bekor qilindi. Bir vaqtda bitta oyna.
  StepUpPrompt? get stepUpPrompt;
  set stepUpPrompt(StepUpPrompt? prompt);
}

/// [action] — server aytgan amal turi (`account_delete`, `role`, …) yoki null.
typedef StepUpPrompt = Future<bool> Function(String? action);

/// Foydalanuvchining o'zi: hamma qurilmalardan chiqish (server barcha
/// sessiyalarni o'chiradi; bu qurilma ham chiqadi).
abstract interface class SessionsBackend {
  Future<void> signOutEverywhere();
}

enum StepUpMethod { email, totp }

@immutable
class StepUpChallenge {
  const StepUpChallenge({
    required this.method,
    this.emailMasked,
    this.retryAfter,
  });

  factory StepUpChallenge.fromJson(Map<String, Object?> j) => StepUpChallenge(
    method: j['method'] == 'totp' ? StepUpMethod.totp : StepUpMethod.email,
    emailMasked: j['email_masked'] as String?,
    retryAfter: j['retry_after'] is num
        ? Duration(seconds: (j['retry_after']! as num).toInt())
        : null,
  );

  final StepUpMethod method;
  final String? emailMasked;
  final Duration? retryAfter;
}

class StepUpException extends BackendException {
  const StepUpException(
    BackendFailure failure,
    String? code, {
    this.attemptsLeft,
    this.retryAfter,
    String? detail,
  }) : super(failure, detail, code);

  final int? attemptsLeft;
  final Duration? retryAfter;
}

/// Server xavfli amal uchun yangi tasdiq so'radi.
bool isStepUpRequired(Object e) =>
    e is BackendException && e.code == 'step_up_required';
