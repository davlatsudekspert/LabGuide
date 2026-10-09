import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/backend/lab_backend.dart';
import '../../core/storage/kv_store.dart';
import 'otp_auth.dart';

/// Joriy sessiya. Kontentni o'qish uchun sessiya shart emas: mehmon ham
/// barcha o'qish ekranlarini ko'radi. Hisob faqat sinxronlash, guruh va
/// xaridni bog'lash uchun kerak.
sealed class AuthSession {
  const AuthSession();
}

class GuestSession extends AuthSession {
  const GuestSession();
}

class EmailSession extends AuthSession {
  const EmailSession(this.email, {required this.isDemo});

  final String email;

  /// Debug demo adapter orqali ochilgan sessiya — server hisob emas.
  final bool isDemo;
}

class AuthController extends ChangeNotifier {
  AuthController(
    this._store,
    this.adapter, {
    DateTime Function()? clock,
    this.backend,
  }) : _session = _restore(_store),
       _clock = clock ?? DateTime.now {
    // Server sessiyani bekor qildi (token yaroqsiz, hisob o'chirilgan):
    // qurilmada ham hisobdan chiqiladi, mehmon rejimi qoladi.
    _lost = backend?.sessionLost.listen((_) {
      if (_session is EmailSession) unawaited(_clearSession());
    });
  }

  final KeyValueStore _store;
  final OtpAuthAdapter adapter;
  final DateTime Function() _clock;

  /// Sozlangan bo'lsa — haqiqiy server (sessiya tokeni shu yerda).
  final LabBackend? backend;
  StreamSubscription<void>? _lost;

  AuthSession? _session;
  String? _pendingEmail;
  OtpRequestResult? _lastRequest;
  DateTime? _lastRequestAt;

  AuthSession? get session => _session;
  bool get hasAccount => _session is EmailSession;
  String? get pendingEmail => _pendingEmail;
  OtpRequestResult? get lastRequest => _lastRequest;

  /// Qayta yuborish qachondan mumkin — kod yuborilgan vaqtdan hisoblanadi
  /// (ekran ochilgan vaqtdan emas).
  DateTime? get resendAvailableAt {
    final at = _lastRequestAt;
    final after = _lastRequest?.retryAfter;
    return at == null || after == null ? null : at.add(after);
  }

  Future<void> continueAsGuest() async {
    _session = const GuestSession();
    notifyListeners();
    await _store.setString(StoreKeys.session, 'guest');
  }

  Future<OtpRequestResult> requestCode(String email) async {
    final result = await adapter.requestCode(email);
    if (result.status == OtpRequestStatus.sent) {
      _pendingEmail = normalizeEmail(email);
      _lastRequest = result;
      _lastRequestAt = _clock();
      notifyListeners();
    }
    return result;
  }

  Future<OtpVerifyResult> verifyCode(String code) async {
    final email = _pendingEmail;
    if (email == null) {
      return const OtpVerifyResult(OtpVerifyStatus.noActiveCode);
    }
    final result = await adapter.verifyCode(email, code);
    if (result.status == OtpVerifyStatus.verified) {
      _session = EmailSession(email, isDemo: adapter.isDemo);
      _pendingEmail = null;
      _lastRequest = null;
      notifyListeners();
      // Demo sessiya qayta ochilganda tiklanmaydi: release foydalanuvchisi
      // hech qachon demo hisob bilan qolmasligi uchun faqat haqiqiy
      // sessiya belgisi saqlanadi (token keyingi bosqichda secure storage).
      if (!adapter.isDemo) {
        await _store.setString(StoreKeys.session, 'email:$email');
      } else {
        await _store.setString(StoreKeys.session, 'guest');
      }
    }
    return result;
  }

  /// Ilova ochilganda, server sessiyasi tiklangandan keyin: qurilmadagi
  /// belgi va server sessiyasi bir-biriga mos bo'lishi kerak. Token
  /// eskirgan bo'lsa — hisobdan chiqiladi (soxta “kirgan” holat qolmaydi);
  /// qayta o'rnatishdan keyin Keychain'da qolgan begona sessiya o'chiriladi.
  Future<void> reconcileWithBackend() async {
    final b = backend;
    if (b == null || !b.isConfigured) return;
    final s = _session;
    if (s is EmailSession && !s.isDemo && !b.hasSession) {
      await _clearSession();
    } else if (s is! EmailSession && b.hasSession) {
      await b.signOut();
    }
  }

  Future<void> signOut() async {
    final b = backend;
    if (b != null && b.isConfigured && b.hasSession) await b.signOut();
    await _clearSession();
  }

  Future<void> _clearSession() async {
    _session = null;
    _pendingEmail = null;
    _lastRequest = null;
    notifyListeners();
    await _store.remove(StoreKeys.session);
  }

  @override
  void dispose() {
    unawaited(_lost?.cancel());
    super.dispose();
  }

  static AuthSession? _restore(KeyValueStore store) {
    final raw = store.getString(StoreKeys.session);
    if (raw == 'guest') return const GuestSession();
    if (raw != null && raw.startsWith('email:')) {
      return EmailSession(raw.substring(6), isDemo: false);
    }
    return null;
  }
}
