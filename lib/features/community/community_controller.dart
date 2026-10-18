import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/backend/community_backend.dart';
import '../../core/storage/kv_store.dart';

/// Hamjamiyat holati: server bormi, foydalanuvchining mutaxassis holati va
/// mavzular bo'yicha savollar soni (qisqa kesh — har kartada so'rov
/// takrorlanmasin).
///
/// [api] `null` — server ulanmagan (Supabase yoki “ulanmagan” build):
/// hamjamiyat UI umuman ko'rsatilmaydi (D-43, F).
class CommunityController extends ChangeNotifier {
  CommunityController(this.api, {DateTime Function()? clock, this.store})
    : _clock = clock ?? DateTime.now {
    _blocked.addAll(_readBlocked());
  }

  final CommunityBackend? api;
  final DateTime Function() _clock;

  /// Bloklar shu omborda (qurilma bo'yicha); `null` — faqat xotirada.
  final KeyValueStore? store;

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

  // ---- bloklash (App Store 1.2: "ability to block abusive users")

  final Set<String> _blocked = {};

  /// Bloklangan mualliflar soni.
  int get blockedCount => _blocked.length;

  /// Muallif bloklanganmi. Belgisi ([CommunityAuthor.ref]) yo'q yoki o'zimiz
  /// bo'lsak — hech qachon.
  bool isBlocked(CommunityAuthor a) =>
      !a.isMe && a.ref != null && _blocked.contains(a.ref);

  /// Muallifni bloklash mumkinmi (server belgi bergan, o'zimiz emas, egasi
  /// emas — egasi LabGuide jamoasi, uni shikoyat orqali hal qilamiz).
  bool canBlock(CommunityAuthor a) =>
      a.ref != null && !a.isMe && a.kind != AuthorKind.owner;

  List<String> _readBlocked() {
    try {
      return store?.getStringList(StoreKeys.communityBlocked) ?? const [];
    } on Object {
      return const [];
    }
  }

  Future<void> _saveBlocked() async {
    try {
      await store?.setStringList(StoreKeys.communityBlocked, [..._blocked]);
    } on Object {
      // Eslab qolish xato bersa ham joriy sessiyada blok ishlayveradi.
    }
  }

  /// Muallifni bloklash: darhol shu qurilmada yashiriladi; hisob bilan
  /// kirilgan bo'lsa ([kind] + [postId] bilan) serverga ham yoziladi
  /// (D-62) — boshqa qurilmada ham, server ro'yxatlarida ham yashirin.
  /// Server xatosi lokal blokni bekor qilmaydi.
  Future<void> block(
    CommunityAuthor a, {
    PostKind? kind,
    String? postId,
  }) async {
    final ref = a.ref;
    if (ref == null || !canBlock(a)) return;
    if (_blocked.add(ref)) {
      notifyListeners();
      await _saveBlocked();
    }
    final api = this.api;
    if (api != null && api.hasSession && kind != null && postId != null) {
      try {
        await api.blockAuthor(kind: kind, id: postId);
      } on Object {
        // Tarmoq/server xatosi: lokal blok ishlayveradi.
      }
    }
  }

  /// Hisobdagi (server) bloklarni shu qurilmaga qo'shish. Xato — jim.
  Future<void> syncBlocks() async {
    final api = this.api;
    if (api == null || !api.hasSession) return;
    try {
      final refs = await api.blockedRefs();
      final before = _blocked.length;
      _blocked.addAll(refs);
      if (_blocked.length != before) {
        notifyListeners();
        await _saveBlocked();
      }
    } on Object {
      // Server bo'lmasa ham lokal bloklar ishlaydi.
    }
  }

  /// Hammasini blokdan chiqarish (“Bloklanganlar” bo'limidan) — serverda ham.
  Future<void> unblockAll() async {
    final api = this.api;
    if (api != null && api.hasSession) {
      try {
        await api.clearBlocks();
      } on Object {
        // Lokal tozalash baribir bajariladi.
      }
    }
    if (_blocked.isEmpty) return;
    _blocked.clear();
    notifyListeners();
    await _saveBlocked();
  }

  /// "Lokal ma'lumotlarni o'chirish": ombor tozalangan, xotiradagi bloklar ham.
  void resetInMemory() {
    _blocked.clear();
    reset();
  }

  /// Hisobdan chiqish / kirish (bloklar qurilmada qoladi).
  void reset() {
    _me = null;
    _counts.clear();
    notifyListeners();
  }
}
