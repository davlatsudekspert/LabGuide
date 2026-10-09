import 'package:flutter/foundation.dart';

/// Do'kon mahsuloti. Narx faqat do'kondan (mahalliy valyutada) keladi —
/// ilovaga qotirilmaydi.
@immutable
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.displayPrice,
  });

  final String id;
  final String title;
  final String displayPrice;
}

/// Xarid dalili: serverga tekshirish uchun yuboriladigan identifikator.
/// Holat va muddat ilovadan OLINMAYDI — server do'kon API'sidan o'qiydi.
@immutable
class PurchaseProof {
  const PurchaseProof({
    required this.platform,
    required this.productId,
    required this.token,
  });

  /// `app_store` yoki `play_store`.
  final String platform;
  final String productId;

  /// App Store: transactionId (StoreKit 2); Google Play: purchaseToken.
  final String token;
}

/// Do'kon (StoreKit 2 / Google Play Billing) bilan ishlash. Hozircha
/// ulanmagan — [UnavailablePurchaseAdapter]. Haqiqiy adapter narx
/// tasdiqlangach qo'shiladi (docs/PRO_BILLING_PLAN.md).
abstract interface class PurchaseAdapter {
  /// Do'kon ulangan va to'lov yoqilgan.
  bool get isAvailable;

  Future<List<StoreProduct>> products(Set<String> ids);

  /// Xarid oynasi. `null` — foydalanuvchi bekor qildi.
  Future<PurchaseProof?> buy(String productId);

  /// "Xaridni tiklash": do'kondagi joriy xaridlar.
  Future<List<PurchaseProof>> restore();
}

class PurchaseUnavailableException implements Exception {
  const PurchaseUnavailableException();

  @override
  String toString() => 'PurchaseUnavailableException';
}

/// To'lov hali yoqilmagan: hech qanday oyna ochilmaydi, pul yechilmaydi.
class UnavailablePurchaseAdapter implements PurchaseAdapter {
  const UnavailablePurchaseAdapter();

  @override
  bool get isAvailable => false;

  @override
  Future<List<StoreProduct>> products(Set<String> ids) async => const [];

  @override
  Future<PurchaseProof?> buy(String productId) async =>
      throw const PurchaseUnavailableException();

  @override
  Future<List<PurchaseProof>> restore() async =>
      throw const PurchaseUnavailableException();
}
