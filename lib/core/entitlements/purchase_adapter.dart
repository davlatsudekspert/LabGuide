import 'dart:async';

import 'package:flutter/foundation.dart';

import 'billing_catalog.dart';

/// Davr uzunligi (do'kondan): masalan, 7 kun, 1 oy, 1 yil.
@immutable
class StorePeriod {
  const StorePeriod(this.count, this.unit);

  final int count;
  final StorePeriodUnit unit;

  /// ISO 8601 (Google Play `billingPeriod`): P7D, P1W, P1M, P1Y.
  static StorePeriod? parseIso(String raw) {
    final m = RegExp(r'^P(\d+)([DWMY])$').firstMatch(raw);
    if (m == null) return null;
    return StorePeriod(int.parse(m[1]!), switch (m[2]!) {
      'D' => StorePeriodUnit.day,
      'W' => StorePeriodUnit.week,
      'M' => StorePeriodUnit.month,
      _ => StorePeriodUnit.year,
    });
  }

  /// Kunlarda (hafta = 7 kun) — taqqoslash va matn uchun.
  int get days => switch (unit) {
    StorePeriodUnit.day => count,
    StorePeriodUnit.week => count * 7,
    StorePeriodUnit.month => count * 30,
    StorePeriodUnit.year => count * 365,
  };

  @override
  bool operator ==(Object other) =>
      other is StorePeriod && other.count == count && other.unit == unit;

  @override
  int get hashCode => Object.hash(count, unit);

  @override
  String toString() => 'StorePeriod($count ${unit.name})';
}

enum StorePeriodUnit { day, week, month, year }

/// Do'kon mahsuloti. Narx, davr va bepul sinov faqat do'kondan (mahalliy
/// valyutada) keladi — ilovaga qotirilmaydi.
@immutable
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.displayPrice,
    this.period,
    this.freeTrial,
  });

  final String id;
  final String title;

  /// Bir davr narxi (do'kon formatlagan, masalan "$3.99").
  final String displayPrice;

  /// Obuna davri (do'kon bermasa — katalogdagi davr ishlatiladi).
  final StorePeriod? period;

  /// Bepul sinov (do'kondagi kirish taklifi; foydalanuvchi unga haqli
  /// bo'lsa). `null` — sinov yo'q.
  final StorePeriod? freeTrial;

  BillingProduct? get catalog => BillingCatalog.byId(id);
}

/// Xarid dalili: serverga tekshirish uchun yuboriladigan identifikator.
/// Holat va muddat ilovadan OLINMAYDI — server do'kon API'sidan o'qiydi.
@immutable
class PurchaseProof {
  const PurchaseProof({
    required this.platform,
    required this.productId,
    required this.token,
    this.purchasedAt,
    this.expiresAt,
  });

  /// `app_store` yoki `play_store`.
  final String platform;
  final String productId;

  /// App Store: transactionId (StoreKit 2); Google Play: purchaseToken.
  final String token;

  /// Qurilmadagi do'kon ma'lumoti — faqat hisobsiz (mehmon) holat uchun.
  /// Serverga yuborilmaydi va server tekshiruvini almashtirmaydi.
  final DateTime? purchasedAt;

  /// StoreKit 2 bergan muddat (Play'da yo'q).
  final DateTime? expiresAt;

  @override
  bool operator ==(Object other) =>
      other is PurchaseProof &&
      other.platform == platform &&
      other.productId == productId &&
      other.token == token;

  @override
  int get hashCode => Object.hash(platform, productId, token);

  @override
  String toString() => 'PurchaseProof($platform, $productId)';
}

/// Do'kon (StoreKit 2 / Google Play Billing) bilan ishlash.
///
/// [isAvailable] faqat do'kon ulangan VA kamida bitta mahsulot yuklanganda
/// `true`. Aks holda ilova to'lov oynasini umuman ko'rsatmaydi.
abstract interface class PurchaseAdapter implements Listenable {
  /// Do'kon ulangan va mahsulotlar yuklangan.
  bool get isAvailable;

  /// Yuklangan mahsulotlar (narx do'kondan).
  List<StoreProduct> get loaded;

  /// Do'konga ulanish va mahsulotlarni yuklash (xato bo'lsa — mavjud emas).
  Future<void> init();

  /// Xarid oynasi. `null` — foydalanuvchi bekor qildi.
  /// [PurchasePendingException] — to'lov kutilmoqda (Ask to Buy, naqd to'lov).
  /// [accountToken] — xaridni hisobga bog'lash belgisi (App Store
  /// appAccountToken — UUID; Play obfuscatedAccountId — hash).
  Future<PurchaseProof?> buy(String productId, {String? accountToken});

  /// "Xaridni tiklash": do'kondagi joriy obunalar. [userInitiated] bo'lsa
  /// iOS do'kon bilan sinxronlanadi (Apple ID so'ralishi mumkin); aks holda
  /// jim (ilova ochilganda).
  Future<List<PurchaseProof>> restore({bool userInitiated = true});

  /// Tranzaksiyani yakunlash (StoreKit `finish` / Play acknowledge) — server
  /// tekshirgandan keyin. Yakunlanmagan tranzaksiya do'kon tomonidan qayta
  /// beriladi.
  Future<void> finish(PurchaseProof proof);

  /// Ilova so'ramagan tranzaksiyalar: yangilanish, Ask to Buy tasdig'i,
  /// kutilgan to'lov yakuni, ilova yopiq paytdagi xarid.
  Stream<PurchaseProof> get updates;

  void dispose();
}

class PurchaseUnavailableException implements Exception {
  const PurchaseUnavailableException();

  @override
  String toString() => 'PurchaseUnavailableException';
}

/// To'lov boshlandi, lekin hali tasdiqlanmagan (ota-ona ruxsati, naqd to'lov).
class PurchasePendingException implements Exception {
  const PurchasePendingException();

  @override
  String toString() => 'PurchasePendingException';
}

/// Do'kon xatosi (to'lov rad etildi, tarmoq va h.k.).
class PurchaseFailedException implements Exception {
  const PurchaseFailedException([this.detail]);

  final String? detail;

  @override
  String toString() => 'PurchaseFailedException($detail)';
}

/// To'lov ulanmagan: hech qanday oyna ochilmaydi, pul yechilmaydi.
class UnavailablePurchaseAdapter extends ChangeNotifier
    implements PurchaseAdapter {
  UnavailablePurchaseAdapter();

  @override
  bool get isAvailable => false;

  @override
  List<StoreProduct> get loaded => const [];

  @override
  Future<void> init() async {}

  @override
  Future<PurchaseProof?> buy(String productId, {String? accountToken}) async =>
      throw const PurchaseUnavailableException();

  @override
  Future<List<PurchaseProof>> restore({bool userInitiated = true}) async =>
      throw const PurchaseUnavailableException();

  @override
  Future<void> finish(PurchaseProof proof) async {}

  @override
  Stream<PurchaseProof> get updates => const Stream.empty();
}
