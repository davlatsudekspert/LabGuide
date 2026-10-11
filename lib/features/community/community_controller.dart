import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/backend/community_backend.dart';

/// Hamjamiyat holati: server bormi, foydalanuvchining mutaxassis holati va
/// mavzular bo'yicha savollar soni (qisqa kesh — har kartada so'rov
/// takrorlanmasin).
///
/// [api] `null` — server ulanmagan (Supabase yoki “ulanmagan” build):
/// hamjamiyat UI umuman ko'rsatilmaydi (D-43, F).
class CommunityController extends ChangeNotifier {
  CommunityController(this.api, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final CommunityBackend? api;
  final DateTime Function() _clock;

  static const _ttl = Duration(minutes: 5);

  bool get available => api != null;

  CommunityMe? _me;
  CommunityMe? get me => _me;

  final Map<String, (int, DateTime)> _counts = {};
  final Map<String, Future<int>> _pending = {};

  /// Savollar soni (mavzu bo'yicha); xato bo'lsa — null (havola sonsiz).
  int? cachedCount(String topic) {
    final c = _counts[topic];
    if (c == null || _clock().difference(c.$2) > _ttl) return null;
    return c.$1;
  }

  Future<int> count(String topic) {
    final cached = cachedCount(topic);
    if (cached != null) return Future.value(cached);
    final api = this.api;
    if (api == null) return Future.value(0);
    return _pending[topic] ??= api
        .questions(topic: topic, limit: 1)
        .then((p) {
          _counts[topic] = (p.total, _clock());
          return p.total;
        })
        .whenComplete(() {
          // Blok tanasi: `remove` shu Future'ni qaytaradi — `=>` bilan
          // whenComplete o'zini kutib qolardi.
          _pending.remove(topic);
        });
  }

  Future<CommunityMe?> refreshMe() async {
    final api = this.api;
    if (api == null || !api.hasSession) {
      if (_me != null) {
        _me = null;
        notifyListeners();
      }
      return null;
    }
    _me = await api.communityMe();
    notifyListeners();
    return _me;
  }

  void setMe(CommunityMe me) {
    _me = me;
    notifyListeners();
  }

  /// Yangi savol/o'chirishdan keyin: sonlar qayta o'qiladi.
  void invalidate() {
    _counts.clear();
    notifyListeners();
  }

  /// Chiqish / lokal ma'lumotni o'chirish.
  void reset() {
    _me = null;
    _counts.clear();
    notifyListeners();
  }
}
