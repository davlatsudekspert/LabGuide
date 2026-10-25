import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../storage/kv_store.dart';
import 'entitlement_models.dart';

/// Keshni imzolash kaliti. Ilovada — Keychain/Keystore (shared
/// preferences'da emas), testlarda — xotira.
abstract interface class EntitlementKeyStore {
  Future<List<int>> key();
}

class SecureEntitlementKeyStore implements EntitlementKeyStore {
  const SecureEntitlementKeyStore();

  static const _name = 'labguide.entitlements.key';
  static const _storage = FlutterSecureStorage();

  @override
  Future<List<int>> key() async {
    final stored = await _storage.read(key: _name);
    if (stored != null) return base64Decode(stored);
    final rnd = Random.secure();
    final bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
    await _storage.write(key: _name, value: base64Encode(bytes));
    return bytes;
  }
}

class MemoryEntitlementKeyStore implements EntitlementKeyStore {
  MemoryEntitlementKeyStore([List<int>? key])
    : _key = key ?? List<int>.generate(32, (i) => i * 7 + 1);

  final List<int> _key;

  @override
  Future<List<int>> key() async => _key;
}

/// Server javobining qurilmadagi nusxasi: hisobga bog'langan, imzolangan
/// (HMAC-SHA256, kalit Keychain'da) va muddatli. Oflaynda Pro faqat
/// [validUntil] gacha va har xaridning o'z muddati tugaguncha ishlaydi.
///
/// Bu qurilmadagi qulaylik, xavfsizlik chegarasi emas: serverdagi Pro
/// amallar (masalan, kelajakdagi AI o'qish) serverda qayta tekshiriladi.
@immutable
class EntitlementCache {
  const EntitlementCache({
    required this.userId,
    required this.serverTime,
    required this.receivedAt,
    required this.validUntil,
    required this.items,
  });

  /// Kim uchun olingan (boshqa hisobga o'tmaydi).
  final String userId;

  /// Server vaqti (javob paytida).
  final DateTime serverTime;

  /// Qurilma vaqti (javob olingan payt) — soat orqaga surilganini aniqlash.
  final DateTime receivedAt;

  /// Oflayn kesh muddati (qurilma vaqti bilan).
  final DateTime validUntil;
  final List<ServerEntitlement> items;

  /// Qurilma soati va server soati farqi.
  Duration get clockOffset => serverTime.difference(receivedAt);

  Map<String, Object?> toJson() => {
    'user': userId,
    'server_time': serverTime.toUtc().toIso8601String(),
    'received_at': receivedAt.toUtc().toIso8601String(),
    'valid_until': validUntil.toUtc().toIso8601String(),
    'items': [for (final e in items) e.toJson()],
  };

  factory EntitlementCache.fromJson(Map<String, Object?> j) => EntitlementCache(
    userId: j['user']! as String,
    serverTime: DateTime.parse(j['server_time']! as String),
    receivedAt: DateTime.parse(j['received_at']! as String),
    validUntil: DateTime.parse(j['valid_until']! as String),
    items: [
      for (final e in j['items']! as List)
        ServerEntitlement.fromJson((e as Map).cast<String, Object?>()),
    ],
  );
}

/// Keshni [KeyValueStore] ga imzo bilan yozadi va o'qiydi.
class EntitlementCacheStore {
  EntitlementCacheStore(this._store, this._keys);

  final KeyValueStore _store;
  final EntitlementKeyStore _keys;

  Future<String> _sign(String payload) async {
    final mac = Hmac(sha256, await _keys.key());
    return base64Encode(mac.convert(utf8.encode(payload)).bytes);
  }

  Future<void> write(EntitlementCache cache) async {
    final payload = jsonEncode(cache.toJson());
    await _store.setString(
      StoreKeys.entitlementsCache,
      jsonEncode({'payload': payload, 'sig': await _sign(payload)}),
    );
  }

  /// Imzosi to'g'ri va [userId] ga tegishli kesh; aks holda `null`
  /// (qo'lda o'zgartirilgan yoki boshqa hisobniki — e'tiborsiz).
  Future<EntitlementCache?> read(String userId) async {
    final raw = _store.getString(StoreKeys.entitlementsCache);
    if (raw == null) return null;
    try {
      final outer = (jsonDecode(raw) as Map).cast<String, Object?>();
      final payload = outer['payload']! as String;
      final expected = await _sign(payload);
      if (!_equal(expected, outer['sig']! as String)) return null;
      final cache = EntitlementCache.fromJson(
        (jsonDecode(payload) as Map).cast<String, Object?>(),
      );
      return cache.userId == userId ? cache : null;
    } on Object {
      return null;
    }
  }

  Future<void> clear() => _store.remove(StoreKeys.entitlementsCache);

  /// Vaqt bo'yicha teng solishtirish (imzo uchun).
  static bool _equal(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
