import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'billing_catalog.dart';
import 'entitlement_cache.dart';
import 'entitlement_models.dart';
import 'entitlement_source.dart';
import 'feature.dart';
import 'purchase_adapter.dart';

/// Pro qayerdan keldi.
enum ProSource {
  /// Build rejimi: `LG_ALL_FEATURES_OPEN=true` (TestFlight/CI) yoki debug.
  buildOpen,

  /// Shu sessiyada serverdan tasdiqlangan.
  server,

  /// Imzolangan oflayn kesh (muddati tugamagan).
  offlineCache,

  /// Hisobsiz (mehmon) xarid: qurilmadagi do'kon tasdiqlagan tranzaksiya
  /// (StoreKit 2 / Play). Hisobga kirilganda serverga bog'lanadi.
  store,

  /// Pro yo'q.
  none,
}

/// Xarid / tiklash natijasi (foydalanuvchiga halol xabar uchun).
enum BillingOutcome {
  /// To'lov yoqilmagan (do'kon yoki server sozlanmagan).
  unavailable,
  cancelled,
  success,

  /// To'lov kutilmoqda (ota-ona ruxsati, naqd to'lov) — tasdiqlangach ochiladi.
  pending,

  /// Do'konda tiklanadigan amaldagi xarid topilmadi.
  nothingFound,

  /// Xarid boshqa LabGuide hisobiga bog'langan.
  ownedByOther,

  /// Internet, do'kon yoki server xatosi — holat o'zgarmadi.
  failed,
}

/// Tarixdan ko'rinadigan qism: eskilari o'chirilmaydi, faqat yashiriladi.
@immutable
class HistoryView<T> {
  const HistoryView(this.visible, this.hiddenCount);

  final List<T> visible;

  /// Saqlangan, lekin bepul rejimda ko'rinmaydigan natijalar soni
  /// ("N ta eski natija saqlangan").
  final int hiddenCount;
}

/// Pro huquqlari: bitta joyda, to'rt manbadan.
///
/// 1. Build rejimi — [allFeaturesOpen] (`--dart-define=LG_ALL_FEATURES_OPEN=true`
///    TestFlight/CI buildlarda; debug buildda ham ochiq).
/// 2. Server tasdiqlagan obuna (`entitlements` jadvali, faqat server yozadi).
/// 3. Imzolangan, hisobga bog'langan, muddatli kesh — oflaynda muddati
///    tugaguncha ishlaydi.
/// 4. Hisobsiz xarid — qurilmadagi do'kon tranzaksiyasi (shu sessiya).
///
/// **To'lov yoqilmagan bo'lsa** ([purchasesEnabled] = false: do'kon
/// mahsulotlari yuklanmagan yoki server sozlanmagan) hech narsa yopilmaydi:
/// [can] doim `true`, tarix cheklanmaydi va to'lov oynasi ko'rsatilmaydi
/// (App Store 2.1 / 3.1.1 — "tez orada" xarid tugmasi yo'q).
///
/// Pro hech qachon bitta lokal sozlamaga bog'lanmaydi: keshni qo'lda
/// o'zgartirish imzoni buzadi va kesh e'tiborsiz qoladi.
class EntitlementService extends ChangeNotifier {
  EntitlementService({
    required this.source,
    required EntitlementCacheStore cache,
    required this.allFeaturesOpen,
    PurchaseAdapter? purchases,
    DateTime Function()? clock,
    this.offlineTtl = const Duration(days: 7),
    this.freeHistoryLimit = 3,
    this.studentVerified = false,
  }) : purchases = purchases ?? UnavailablePurchaseAdapter(),
       _cacheStore = cache,
       now = clock ?? DateTime.now {
    this.purchases.addListener(notifyListeners);
  }

  /// TestFlight/CI build bayrog'i. Do'kon (release) buildda `false`.
  static const buildAllFeaturesOpen = bool.fromEnvironment(
    'LG_ALL_FEATURES_OPEN',
  );

  final EntitlementSource source;
  final PurchaseAdapter purchases;
  final bool allFeaturesOpen;
  final Duration offlineTtl;
  final int freeHistoryLimit;

  /// Talaba holati tasdiqlangan hisob (D-49). Ilovada hali bunday tasdiq
  /// yo'q — talaba mahsulotlari ko'rsatilmaydi.
  final bool studentVerified;
  DateTime Function() now;

  final EntitlementCacheStore _cacheStore;
  EntitlementCache? _cache;
  bool _fresh = false;

  /// Hisobsiz xaridlar (qurilmadagi do'kon tranzaksiyalari, shu sessiya).
  var _device = const <ServerEntitlement>[];
  StreamSubscription<PurchaseProof>? _updates;
  bool _busy = false;

  /// Soat orqaga surilganda ruxsat etilgan farq.
  static const _clockSkew = Duration(minutes: 10);

  /// Oxirgi tasdiqlangan holat (kesh yoki server).
  EntitlementCache? get cached => _cache;

  /// To'lov (do'kon + server tekshiruvi) yoqilganmi. `false` bo'lsa to'lov
  /// oynasi, Pro qatori va "yopiq" belgilari umuman ko'rsatilmaydi.
  bool get purchasesEnabled => purchases.isAvailable && source.billingReady;

  /// Pullik imkoniyatlar haqiqatan yopiladimi: faqat do'kon buildda va
  /// to'lov ishlayotganda. TestFlight/debug va to'lovsiz buildda — yo'q.
  bool get gatingActive => !allFeaturesOpen && purchasesEnabled;

  /// Xarid yoki tiklash davom etmoqda.
  bool get busy => _busy;

  /// To'lov oynasida ko'rsatiladigan mahsulotlar (narx do'kondan).
  List<StoreProduct> get offeredProducts => [
    for (final p in purchases.loaded)
      if (p.catalog case final c?)
        if (BillingCatalog.offered(c, studentVerified: studentVerified)) p,
  ];

  bool _cacheValid(DateTime t) {
    final c = _cache;
    if (c == null) return false;
    if (t.isBefore(c.receivedAt.subtract(_clockSkew))) return false;
    return t.isBefore(c.validUntil);
  }

  Iterable<ServerEntitlement> _serverGranting() sync* {
    final c = _cache;
    final t = now();
    if (c == null || !_cacheValid(t)) return;
    final serverNow = t.add(c.clockOffset);
    for (final e in c.items) {
      if (e.grantsAt(serverNow)) yield e;
    }
  }

  Iterable<ServerEntitlement> _deviceGranting() sync* {
    if (source.hasSession) return;
    final t = now().toUtc();
    for (final e in _device) {
      if (e.grantsAt(t)) yield e;
    }
  }

  static ServerEntitlement? _longest(Iterable<ServerEntitlement> items) {
    ServerEntitlement? best;
    for (final e in items) {
      if (best == null ||
          e.expiresAt == null ||
          (best.expiresAt != null && e.expiresAt!.isAfter(best.expiresAt!))) {
        best = e;
      }
    }
    return best;
  }

  /// Amaldagi xarid (eng uzoq muddatlisi): server/kesh, mehmonda — qurilma.
  ServerEntitlement? get activeEntitlement =>
      _longest(_serverGranting()) ?? _longest(_deviceGranting());

  ProSource get proSource {
    if (allFeaturesOpen) return ProSource.buildOpen;
    if (_longest(_serverGranting()) != null) {
      return _fresh ? ProSource.server : ProSource.offlineCache;
    }
    if (_longest(_deviceGranting()) != null) return ProSource.store;
    return ProSource.none;
  }

  bool get isPro => proSource != ProSource.none;

  /// Amaldagi obuna darajasi (Ustoz Pro Pro'ni ham o'z ichiga oladi).
  ProTier get tier {
    if (allFeaturesOpen) return ProTier.teacher;
    var best = ProTier.free;
    for (final e in [..._serverGranting(), ..._deviceGranting()]) {
      final t = BillingCatalog.tierOf(e.productId);
      if (t.index > best.index) best = t;
    }
    return best;
  }

  /// Imkoniyat ochiqmi. Faqat amal boshlanishidan oldin yoki natijadan
  /// keyin chaqiriladi — boshlangan sanash/imtihon o'rtada to'xtatilmaydi.
  /// To'lov yoqilmagan bo'lsa — doim `true`.
  bool can(Feature feature) =>
      !feature.pro || !gatingActive || tier.covers(feature.tier);

  /// Tarixda ko'rinadigan oxirgi natijalar soni; `null` — cheksiz.
  int? historyVisibleLimit() =>
      can(Feature.unlimitedHistory) ? null : freeHistoryLimit;

  /// Pro amalda bo'lgan davrlar (qaytarilgan xaridsiz). Kesh oflayn
  /// muddati o'tgan bo'lsa ham davrlar saqlanadi — bu huquq emas, tarix.
  List<ProPeriod> get proPeriods => [
    for (final e in _cache?.items ?? const <ServerEntitlement>[]) ?e.period,
  ];

  /// Tarix ro'yxatidan ko'rinadigan qism ([newestFirst] — eng yangisi
  /// birinchi). Bepul rejimda oxirgi [freeHistoryLimit] ta + Pro davrida
  /// saqlanganlar ko'rinadi; qolganlari O'CHIRILMAYDI, faqat sanaladi.
  HistoryView<T> historyView<T>(
    List<T> newestFirst,
    DateTime Function(T item) savedAt,
  ) {
    final limit = historyVisibleLimit();
    if (limit == null) return HistoryView(List.unmodifiable(newestFirst), 0);
    final periods = proPeriods;
    final visible = <T>[
      for (final (i, item) in newestFirst.indexed)
        if (i < limit || periods.any((p) => p.contains(savedAt(item).toUtc())))
          item,
    ];
    return HistoryView(
      List.unmodifiable(visible),
      newestFirst.length - visible.length,
    );
  }

  /// Ilova ochilganda: shu hisobning imzolangan keshi (bo'lsa).
  Future<void> load() async {
    final user = source.userId;
    _cache = user == null ? null : await _cacheStore.read(user);
    _fresh = false;
    notifyListeners();
  }

  /// Ilova ochilganda (main): kesh → server to'lov sozlamasi → do'kon
  /// mahsulotlari → serverdan holat → do'kondagi joriy obunalar (jim).
  Future<void> start() async {
    await load();
    await source.probe();
    await purchases.init();
    _updates ??= purchases.updates.listen((p) => unawaited(_onUpdate(p)));
    notifyListeners();
    await refresh(reprobe: false);
    if (purchasesEnabled) await _syncDevice();
  }

  /// Serverdan yangilash. Internet bo'lmasa kesh qoladi (soxta holat
  /// ko'rsatilmaydi); hisobdan chiqilgan bo'lsa xotiradagi holat tozalanadi.
  /// [reprobe] — ilova ochilganda server javob bermagan bo'lsa, to'lov
  /// sozlamasi qayta so'raladi (kirish/chiqishda).
  Future<void> refresh({bool reprobe = true}) async {
    if (reprobe && !source.billingReady) {
      await source.probe();
      notifyListeners();
    }
    final user = source.userId;
    if (!source.isConfigured || !source.hasSession || user == null) {
      if (_cache != null || _fresh) {
        _cache = null;
        _fresh = false;
        notifyListeners();
      }
      return;
    }
    if (_cache?.userId != user) await load();
    try {
      await _accept(user, await source.fetch());
    } on Object catch (e) {
      debugPrint('entitlements refresh: $e');
      return;
    }
    // Mehmon paytida qilingan xarid — endi hisobga bog'lanadi.
    if (_device.isNotEmpty && _longest(_serverGranting()) == null) {
      await _bind([
        for (final e in _device)
          if (e.grantsAt(now().toUtc()) && e.token != null)
            PurchaseProof(
              platform: e.platform,
              productId: e.productId,
              token: e.token!,
            ),
      ]);
    }
  }

  Future<void> _accept(String user, EntitlementSnapshot snap) async {
    final t = now();
    _cache = EntitlementCache(
      userId: user,
      serverTime: snap.serverTime,
      receivedAt: t,
      validUntil: t.add(offlineTtl),
      items: snap.items,
    );
    _fresh = true;
    await _cacheStore.write(_cache!);
    notifyListeners();
  }

  /// Do'kondagi joriy obunalar (jim, oyna yo'q): mehmonda — qurilma
  /// huquqi; hisobda — server bilmagan xarid bo'lsa bog'lanadi.
  Future<void> _syncDevice() async {
    List<PurchaseProof> proofs;
    try {
      proofs = await purchases.restore(userInitiated: false);
    } on Object catch (e) {
      debugPrint('entitlements sync: $e');
      return;
    }
    _setDevice(proofs);
    if (source.hasSession && _longest(_serverGranting()) == null) {
      await _bind(proofs);
    }
  }

  Future<void> _bind(List<PurchaseProof> proofs) async {
    final user = source.userId;
    if (proofs.isEmpty || user == null || !source.billingReady) return;
    try {
      await _accept(user, await source.verify(proofs, restore: true));
    } on Object catch (e) {
      debugPrint('entitlements bind: $e');
    }
  }

  void _setDevice(List<PurchaseProof> proofs) {
    _device = [
      for (final p in proofs)
        ServerEntitlement(
          productId: p.productId,
          platform: p.platform,
          status: EntitlementStatus.active,
          startedAt: p.purchasedAt,
          expiresAt: p.expiresAt,
          token: p.token,
        ),
    ];
    notifyListeners();
  }

  /// Ilova so'ramagan tranzaksiya (yangilanish, Ask to Buy, kutilgan to'lov):
  /// server tekshiradi, keyin yakunlanadi. Xato bo'lsa yakunlanmaydi —
  /// do'kon keyingi ochilishda qayta beradi.
  Future<void> _onUpdate(PurchaseProof proof) async {
    final user = source.userId;
    if (!source.hasSession || user == null) {
      _setDevice([
        ..._device.where((e) => e.token != proof.token).map(_proofOf),
        proof,
      ]);
      await purchases.finish(proof);
      return;
    }
    try {
      await _accept(user, await source.verify([proof], restore: false));
      await purchases.finish(proof);
    } on Object catch (e) {
      debugPrint('entitlements update: $e');
    }
  }

  static PurchaseProof _proofOf(ServerEntitlement e) => PurchaseProof(
    platform: e.platform,
    productId: e.productId,
    token: e.token ?? '',
    purchasedAt: e.startedAt,
    expiresAt: e.expiresAt,
  );

  /// Xaridni hisobga bog'lash belgisi: App Store — hisob UUID'i
  /// (appAccountToken), Play — uning SHA-256 xeshi (obfuscatedAccountId).
  /// Server shu belgi bilan xarid boshqa hisobniki emasligini tekshiradi.
  String? _accountToken() {
    final user = source.userId;
    if (!source.hasSession || user == null) return null;
    if (source.platform == 'play_store') {
      return sha256.convert(utf8.encode(user)).toString();
    }
    final uuid = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    );
    final lower = user.toLowerCase();
    return uuid.hasMatch(lower) ? lower : null;
  }

  /// Xarid. Mehmon ham sotib oladi (hisob talab qilinmaydi — App Store
  /// 5.1.1); hisobga kirganda xarid serverga bog'lanadi.
  Future<BillingOutcome> purchase(String productId) => _billing(() async {
    final proof = await purchases.buy(
      productId,
      accountToken: _accountToken(),
    );
    return proof == null ? null : [proof];
  }, restore: false);

  /// "Xaridni tiklash" (App Store talabi).
  Future<BillingOutcome> restore() => _billing(
    () => purchases.restore(userInitiated: true),
    restore: true,
  );

  Future<BillingOutcome> _billing(
    Future<List<PurchaseProof>?> Function() run, {
    required bool restore,
  }) async {
    if (!purchasesEnabled) return BillingOutcome.unavailable;
    if (_busy) return BillingOutcome.failed;
    _busy = true;
    notifyListeners();
    try {
      final proofs = await run();
      if (proofs == null) return BillingOutcome.cancelled;
      if (proofs.isEmpty) return BillingOutcome.nothingFound;
      final user = source.userId;
      if (!source.hasSession || user == null) {
        // Mehmon: do'kon (StoreKit 2 / Play) tasdiqlagan tranzaksiya.
        _setDevice(
          restore
              ? proofs
              : [..._device.map(_proofOf), ...proofs],
        );
        for (final p in proofs) {
          await purchases.finish(p);
        }
        return activeEntitlement != null
            ? BillingOutcome.success
            : BillingOutcome.nothingFound;
      }
      final snap = await source.verify(proofs, restore: restore);
      await _accept(user, snap);
      // Server qabul qildi — tranzaksiya yakunlanadi (aks holda do'kon qayta beradi).
      for (final p in proofs) {
        await purchases.finish(p);
      }
      if (snap.ownedByOther && activeEntitlement == null) {
        return BillingOutcome.ownedByOther;
      }
      if (activeEntitlement != null) return BillingOutcome.success;
      return restore ? BillingOutcome.nothingFound : BillingOutcome.failed;
    } on PurchasePendingException {
      return BillingOutcome.pending;
    } on PurchaseUnavailableException {
      return BillingOutcome.unavailable;
    } on PurchaseFailedException catch (e) {
      debugPrint('billing store: $e');
      return BillingOutcome.failed;
    } on EntitlementException catch (e) {
      return switch (e.failure) {
        EntitlementFailure.notConfigured => BillingOutcome.unavailable,
        EntitlementFailure.pending => BillingOutcome.pending,
        _ => BillingOutcome.failed,
      };
    } on Object catch (e) {
      debugPrint('billing: $e');
      return BillingOutcome.failed;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// "Lokal ma'lumotlarni o'chirish" dan keyin.
  void resetInMemory() {
    _cache = null;
    _fresh = false;
    _device = const [];
    notifyListeners();
  }

  @override
  void dispose() {
    purchases.removeListener(notifyListeners);
    unawaited(_updates?.cancel());
    super.dispose();
  }
}
