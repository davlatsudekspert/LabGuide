import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import 'billing_catalog.dart';
import 'pro_catalog.dart';
import 'purchase_adapter.dart';

/// Haqiqiy do'kon: rasmiy `in_app_purchase` plagini (iOS — StoreKit 2,
/// Android — Google Play Billing).
///
/// * [isAvailable] — do'kon javob berdi VA kamida bitta katalog mahsuloti
///   yuklandi. Mahsulotlar hali yaratilmagan bo'lsa — `false`, ilova to'lov
///   oynasini ko'rsatmaydi.
/// * Narx, davr va bepul sinov — faqat do'kondan.
/// * Tranzaksiya [finish] chaqirilguncha yakunlanmaydi (server tekshirgandan
///   keyin); yakunlanmagani do'kon tomonidan qayta beriladi.
class StorePurchaseAdapter extends ChangeNotifier implements PurchaseAdapter {
  StorePurchaseAdapter({InAppPurchase? iap, Set<String>? productIds})
    : _iapOverride = iap,
      _ids = productIds ?? BillingCatalog.storeQueryIds;

  final InAppPurchase? _iapOverride;
  final Set<String> _ids;

  InAppPurchase get _iap => _iapOverride ?? InAppPurchase.instance;

  /// Faqat telefon platformalari (web/desktop/test — do'kon yo'q).
  static bool get supported =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  static bool get _ios => !kIsWeb && Platform.isIOS;

  StreamSubscription<List<PurchaseDetails>>? _sub;
  final _updates = StreamController<PurchaseProof>.broadcast();
  final _details = <String, ProductDetails>{};
  var _loaded = const <StoreProduct>[];
  bool _ready = false;
  Future<void>? _init;

  /// Yakunlanishi kerak bo'lgan tranzaksiyalar (token bo'yicha).
  final _unfinished = <String, PurchaseDetails>{};

  /// Android: qurilmadagi joriy obuna (Pro ↔ Ustoz Pro almashtirish uchun).
  final _owned = <String, GooglePlayPurchaseDetails>{};

  Completer<PurchaseProof?>? _buying;
  String? _buyingId;
  List<PurchaseProof>? _restoring;

  @override
  bool get isAvailable => _ready && _loaded.isNotEmpty;

  @override
  List<StoreProduct> get loaded => _loaded;

  @override
  Stream<PurchaseProof> get updates => _updates.stream;

  @override
  Future<void> init() => _init ??= _doInit();

  Future<void> _doInit() async {
    if (!supported) return;
    try {
      // Stream eng avval tinglanadi: ilova yopiq paytdagi xaridlar yo'qolmaydi.
      _sub = _iap.purchaseStream.listen(
        _onPurchases,
        onError: (Object e) => debugPrint('iap stream: $e'),
      );
      if (!await _iap.isAvailable()) return;
      final res = await _iap.queryProductDetails(_ids);
      if (res.error != null) debugPrint('iap products: ${res.error}');
      final products = <StoreProduct>[];
      if (_ios) {
        products.addAll(await _iosProducts(res.productDetails));
      } else {
        products.addAll(_androidProducts(res.productDetails));
      }
      // Katalog tartibida (oylik, yillik; Pro, keyin Ustoz Pro).
      products.sort(
        (a, b) => BillingCatalog.all
            .indexWhere((p) => p.id == a.id)
            .compareTo(BillingCatalog.all.indexWhere((p) => p.id == b.id)),
      );
      _loaded = List.unmodifiable(products);
      _ready = true;
      notifyListeners();
    } on Object catch (e) {
      // Do'kon xatosi — to'lov "mavjud emas" bo'lib qoladi (yopiq tugma yo'q).
      debugPrint('iap init: $e');
    }
  }

  // ------------------------------------------------------------ iOS
  Future<List<StoreProduct>> _iosProducts(List<ProductDetails> list) async {
    // Kirish taklifi (bepul sinov) StoreKit 1 mahsulot javobida bor.
    final sk1 = <String, SKProductWrapper>{};
    try {
      final r = await SKRequestMaker().startProductRequest(_ids.toList());
      for (final p in r.products) {
        sk1[p.productIdentifier] = p;
      }
    } on Object catch (e) {
      debugPrint('iap sk1: $e');
    }
    final out = <StoreProduct>[];
    for (final d in list) {
      if (!_ids.contains(d.id)) continue;
      _details[d.id] = d;
      StorePeriod? period;
      if (d is AppStoreProduct2Details) {
        final p = d.sk2Product.subscription?.subscriptionPeriod;
        if (p != null) period = StorePeriod(p.value, _sk2Unit(p.unit));
      }
      final legacy = sk1[d.id];
      if (period == null && legacy?.subscriptionPeriod != null) {
        final p = legacy!.subscriptionPeriod!;
        period = StorePeriod(p.numberOfUnits, _sk1Unit(p.unit));
      }
      out.add(
        StoreProduct(
          id: d.id,
          title: d.title,
          displayPrice: d.price,
          period: period,
          // D-75: do'kon kirish taklifi (avtomatik pullikka o'tadi) ko'rsatilmaydi.
          freeTrial: ProTrialConfig.storeIntroOffersAllowed
              ? await _iosTrial(d.id, legacy)
              : null,
        ),
      );
    }
    return out;
  }

  Future<StorePeriod?> _iosTrial(String id, SKProductWrapper? p) async {
    final intro = p?.introductoryPrice;
    if (intro == null ||
        intro.paymentMode != SKProductDiscountPaymentMode.freeTrail) {
      return null;
    }
    try {
      // Sinovdan foydalangan foydalanuvchiga "bepul sinov" ko'rsatilmaydi.
      if (!await SK2Product.isIntroductoryOfferEligible(id)) return null;
    } on Object catch (e) {
      debugPrint('iap eligibility: $e');
    }
    final s = intro.subscriptionPeriod;
    final n =
        s.numberOfUnits *
        (intro.numberOfPeriods < 1 ? 1 : intro.numberOfPeriods);
    return StorePeriod(n, _sk1Unit(s.unit));
  }

  static StorePeriodUnit _sk2Unit(SK2SubscriptionPeriodUnit u) => switch (u) {
    SK2SubscriptionPeriodUnit.day => StorePeriodUnit.day,
    SK2SubscriptionPeriodUnit.week => StorePeriodUnit.week,
    SK2SubscriptionPeriodUnit.month => StorePeriodUnit.month,
    SK2SubscriptionPeriodUnit.year => StorePeriodUnit.year,
  };

  static StorePeriodUnit _sk1Unit(SKSubscriptionPeriodUnit u) => switch (u) {
    SKSubscriptionPeriodUnit.day => StorePeriodUnit.day,
    SKSubscriptionPeriodUnit.week => StorePeriodUnit.week,
    SKSubscriptionPeriodUnit.month => StorePeriodUnit.month,
    SKSubscriptionPeriodUnit.year => StorePeriodUnit.year,
  };

  // ------------------------------------------------------------ Android
  /// Play har taklif (base plan / offer) uchun alohida yozuv beradi.
  /// D-75: faqat ASOSIY REJA (base plan, `offerId == null`) olinadi — bepul
  /// sinov va chegirmali takliflar ko'rsatilmaydi va tanlanmaydi (30 kunlik
  /// sinov server beradi; Play sinovi bilan ikki marta sinov bo'lmasin).
  /// Mahsulot id si kanonik: `uz.labguide.student` + base plan `yearly` →
  /// `uz.labguide.student.yearly` ([BillingCatalog.canonical]).
  List<StoreProduct> _androidProducts(List<ProductDetails> list) {
    final out = <StoreProduct>[];
    for (final d in list) {
      if (d is! GooglePlayProductDetails || !_ids.contains(d.id)) continue;
      final i = d.subscriptionIndex;
      final offers = d.productDetails.subscriptionOfferDetails;
      if (i == null || offers == null || i >= offers.length) continue;
      final offer = offers[i];
      if (offer.offerId != null) continue;
      final id = BillingCatalog.canonical(d.id, basePlanId: offer.basePlanId);
      if (id == null || _details.containsKey(id)) continue;
      final phases = offer.pricingPhases;
      if (phases.isEmpty) continue;
      // Asosiy rejada faqat cheksiz takrorlanuvchi to'liq narx bo'ladi.
      final recurring = phases.lastWhere(
        (p) => p.recurrenceMode == RecurrenceMode.infiniteRecurring,
        orElse: () => phases.last,
      );
      if (recurring.priceAmountMicros <= 0) continue;
      _details[id] = d;
      out.add(
        StoreProduct(
          id: id,
          title: d.title,
          displayPrice: recurring.formattedPrice,
          period: StorePeriod.parseIso(recurring.billingPeriod),
        ),
      );
    }
    return out;
  }

  /// Do'kon `productID` (Play'da obuna id si) [_buyingId] (kanonik) ga mosmi.
  static bool _same(String storeId, String? canonicalId) =>
      canonicalId != null &&
      (storeId == canonicalId || canonicalId.startsWith('$storeId.'));

  // ------------------------------------------------------------ oqim
  PurchaseProof? _proof(PurchaseDetails p) {
    final token = _ios
        ? p.purchaseID
        : p.verificationData.serverVerificationData;
    if (token == null || token.isEmpty) return null;
    DateTime? ms(String? v) {
      final n = v == null ? null : int.tryParse(v);
      return n == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(n, isUtc: true);
    }

    // Kanonik id: App Store'da o'zi; Play'da obuna id si — base plan
    // xarid paytida ma'lum ([_buyingId]); tiklashda server aniqlaydi.
    final canonical =
        BillingCatalog.canonical(p.productID) ??
        (_same(p.productID, _buyingId) ? _buyingId! : p.productID);
    return PurchaseProof(
      platform: _ios ? 'app_store' : 'play_store',
      productId: canonical,
      token: token,
      purchasedAt: ms(p.transactionDate),
      expiresAt: p is SK2PurchaseDetails ? ms(p.expirationDate) : null,
    );
  }

  void _onPurchases(List<PurchaseDetails> list) {
    for (final p in list) {
      if (!_ids.contains(p.productID)) {
        // Bizniki emas (masalan, eski sinov mahsuloti) — faqat yakunlanadi.
        if (p.pendingCompletePurchase) unawaited(_complete(p));
        continue;
      }
      final buyingThis = _buying != null && _same(p.productID, _buyingId);
      switch (p.status) {
        case PurchaseStatus.pending:
          if (buyingThis) _settle(error: const PurchasePendingException());
        case PurchaseStatus.canceled:
          if (buyingThis) _settle();
          if (p.pendingCompletePurchase) unawaited(_complete(p));
        case PurchaseStatus.error:
          if (buyingThis) {
            _settle(error: PurchaseFailedException(p.error?.code));
          }
          if (p.pendingCompletePurchase) unawaited(_complete(p));
        case PurchaseStatus.purchased || PurchaseStatus.restored:
          final proof = _proof(p);
          if (proof == null) {
            if (buyingThis) {
              _settle(error: const PurchaseFailedException('no token'));
            }
            continue;
          }
          if (p.pendingCompletePurchase) _unfinished[proof.token] = p;
          if (p is GooglePlayPurchaseDetails) _owned[p.productID] = p;
          if (buyingThis && p.status == PurchaseStatus.purchased) {
            _settle(proof: proof);
          } else if (_restoring != null &&
              p.status == PurchaseStatus.restored) {
            _restoring!.add(proof);
          } else {
            _updates.add(proof);
          }
      }
    }
  }

  void _settle({PurchaseProof? proof, Object? error}) {
    final c = _buying;
    _buying = null;
    _buyingId = null;
    if (c == null || c.isCompleted) return;
    if (error != null) {
      c.completeError(error);
    } else {
      c.complete(proof);
    }
  }

  Future<void> _complete(PurchaseDetails p) async {
    try {
      await _iap.completePurchase(p);
    } on Object catch (e) {
      debugPrint('iap complete: $e');
    }
  }

  // ------------------------------------------------------------ amallar
  @override
  Future<PurchaseProof?> buy(String productId, {String? accountToken}) async {
    final details = _details[productId];
    if (!isAvailable || details == null) {
      throw const PurchaseUnavailableException();
    }
    if (_buying != null) throw const PurchaseFailedException('busy');
    final c = _buying = Completer<PurchaseProof?>();
    _buyingId = productId;
    final PurchaseParam param;
    if (details is GooglePlayProductDetails) {
      // Pro ↔ Ustoz Pro: Play'da eski obuna almashtiriladi (ikkita bo'lmaydi).
      final old = _owned.values
          .where((o) => o.productID != productId)
          .firstOrNull;
      param = GooglePlayPurchaseParam(
        productDetails: details,
        applicationUserName: accountToken,
        changeSubscriptionParam: old == null
            ? null
            : ChangeSubscriptionParam(
                oldPurchaseDetails: old,
                replacementMode: ReplacementMode.withTimeProration,
              ),
      );
    } else {
      // App Store: appAccountToken faqat UUID bo'lishi mumkin.
      param = PurchaseParam(
        productDetails: details,
        applicationUserName: accountToken,
      );
    }
    try {
      final started = await _iap.buyNonConsumable(purchaseParam: param);
      if (!started) _settle();
    } on Object catch (e) {
      // StoreKit: foydalanuvchi oynani yopdi — bekor qilish, xato emas.
      final msg = '$e';
      if (msg.contains('userCancelled') || msg.contains('canceled')) {
        _settle();
      } else {
        _settle(error: PurchaseFailedException(msg));
      }
    }
    // Do'kon javob bermay qolsa ham tugma abadiy "band" bo'lib qolmasin.
    // Kechikkan tranzaksiya baribir `updates` orqali keladi.
    return c.future.timeout(
      const Duration(minutes: 10),
      onTimeout: () {
        if (identical(_buying, c)) {
          _buying = null;
          _buyingId = null;
        }
        throw const PurchaseFailedException('timeout');
      },
    );
  }

  @override
  Future<List<PurchaseProof>> restore({bool userInitiated = true}) async {
    if (!_ready) throw const PurchaseUnavailableException();
    final found = _restoring = <PurchaseProof>[];
    try {
      if (_ios && userInitiated) {
        // Foydalanuvchi o'zi bosdi: do'kon bilan sinxronlash (Apple talabi).
        try {
          await _iap
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>()
              .sync();
        } on Object catch (e) {
          debugPrint('iap sync: $e');
        }
      }
      await _iap.restorePurchases();
      // Natijalar oqim orqali keladi — qisqa kutish.
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      return {...found}.toList();
    } finally {
      _restoring = null;
    }
  }

  @override
  Future<void> finish(PurchaseProof proof) async {
    final p = _unfinished.remove(proof.token);
    if (p != null) await _complete(p);
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    unawaited(_updates.close());
    super.dispose();
  }
}
