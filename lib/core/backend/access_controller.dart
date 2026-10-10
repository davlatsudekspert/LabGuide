import 'dart:async';

import 'package:flutter/foundation.dart';

import 'backend_models.dart';
import 'lab_backend.dart';

/// Hisobli foydalanuvchining server bergan holati: vakolatlar (admin,
/// reviewer) va javobi o'qilmagan murojaatlar soni. Ilova qaysi bo'limni
/// ko'rsatishni shundan biladi; amallarning o'zi serverda tekshiriladi.
class AccessController extends ChangeNotifier {
  AccessController(this.backend);

  final LabBackend backend;

  AccessInfo _access = AccessInfo.none;
  int _unread = 0;
  bool _touched = false;

  AccessInfo get access => _access;

  /// Admin javobi kelgan, foydalanuvchi hali ochmagan murojaatlar.
  int get unreadReplies => _unread;

  /// Kirgandan keyin, ilova ochilganda va profil ochilganda chaqiriladi.
  /// Internet bo'lmasa oldingi holat qoladi (soxta qiymat ko'rsatilmaydi).
  Future<void> refresh({String? role, String? language}) async {
    if (!backend.isConfigured || !backend.hasSession) {
      if (_access != AccessInfo.none || _unread != 0) {
        _access = AccessInfo.none;
        _unread = 0;
        notifyListeners();
      }
      return;
    }
    try {
      if (!_touched && role != null && language != null) {
        await backend.touchProfile(role: role, language: language);
        _touched = true;
      }
      _access = await backend.myAccess();
      try {
        final threads = await backend.myThreads();
        _unread = threads.where((t) => t.unreadForUser).length;
      } on BackendException catch (e) {
        // Murojaatlar bo'limi bu serverda bo'lmasa ham vakolatlar yangilansin.
        if (e.failure != BackendFailure.unavailable) rethrow;
        _unread = 0;
      }
      notifyListeners();
    } on BackendException catch (e) {
      debugPrint('access refresh: $e');
    }
  }

  /// Rol yoki til o'zgarganda profil yangilanadi (keyingi refresh'da).
  void profileChanged() => _touched = false;

  void markThreadRead() {
    if (_unread > 0) {
      _unread--;
      notifyListeners();
    }
  }

  void clear() {
    _access = AccessInfo.none;
    _unread = 0;
    _touched = false;
    notifyListeners();
  }
}
