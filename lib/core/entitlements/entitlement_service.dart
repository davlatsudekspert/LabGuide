import 'package:flutter/foundation.dart';

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

  /// Pro yo'q.
  none,
}

/// Xarid / tiklash natijasi (foydalanuvchiga halol xabar uchun).
enum BillingOutcome {
  /// To'lov hali yoqilmagan (do'kon yoki server sozlanmagan).
  unavailable,

  /// Server bilan bog'lash uchun hisobga kirish kerak.
  signInRequired,
  cancelled,
  success,

  /// Do'konda tiklanadigan amaldagi xarid topilmadi.
  nothingFound,

  /// Xarid boshqa LabGuide hisobiga bog'langan.
  ownedByOther,

  /// Internet yoki server xatosi — holat o'zgarmadi.
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

/// Pro huquqlari: bitta joyda, uch manbadan.
///
/// 1. Build rejimi — [allFeaturesOpen] (`--dart-define=LG_ALL_FEATURES_OPEN=true`
///    TestFlight/CI buildlarda; debug buildda ham ochiq).
/// 2. Server tasdiqlagan obuna (`entitlements` jadvali, faqat server yozadi).
/// 3. Imzolangan, hisobga bog'langan, muddatli kesh — oflaynda muddati
///    tugaguncha ishlaydi.
///
/// Pro hech qachon bitta lokal sozlamaga bog'lanmaydi: keshni qo'lda
/// o'zgartirish imzoni buzadi va kesh e'tiborsiz qoladi.
class EntitlementService extends ChangeNotifier {
  EntitlementService({
    required this.source,
    required EntitlementCacheStore cache,
    required this.allFeaturesOpen,
    this.purchases = const UnavailablePurchaseAdapter(),
    DateTime Function()? clock,
    this.offlineTtl = const Duration(days: 7),
    this.freeHistoryLimit = 3,
  }) : _cacheStore = cache,
       now = clock ?? DateTime.now;

  /// TestFlight/CI build bayrog'i. Do'kon (release) buildda `false`.
  static const buildAllFeaturesOpen = bool.fromEnvironment(
    'LG_ALL_FEATURES_OPEN',
  );

  final EntitlementSource source;
  final PurchaseAdapter purchases;
  final bool allFeaturesOpen;
  final Duration offlineTtl;
  final int freeHistoryLimit;
  DateTime Function() now;

  final EntitlementCacheStore _cacheStore;
  EntitlementCache? _cache;
  bool _fresh = false;

  /// Soat orqaga surilganda ruxsat etilgan farq.
  static const _clockSkew = Duration(minutes: 10);

  /// Oxirgi tasdiqlangan holat (kesh yoki server).
  EntitlementCache? get cached => _cache;

  /// To'lov (do'kon + server tekshiruvi) yoqilganmi.
  bool get purchasesEnabled => purchases.isAvailable && source.isConfigured;

  bool _cacheValid(DateTime t) {
    final c = _cache;
    if (c == null) return false;
    if (t.isBefore(c.receivedAt.subtract(_clockSkew))) return false;
    return t.isBefore(c.validUntil);
  }

  /// Amaldagi xarid (eng uzoq muddatlisi).
  ServerEntitlement? get activeEntitlement {
    final c = _cache;
    final t = now();
    if (c == null || !_cacheValid(t)) return null;
    final serverNow = t.add(c.clockOffset);
    ServerEntitlement? best;
    for (final e in c.items) {
      if (!e.grantsAt(serverNow)) continue;
      if (best == null ||
          e.expiresAt == null ||
          (best.expiresAt != null && e.expiresAt!.isAfter(best.expiresAt!))) {
        best = e;
      }
    }
    return best;
  }

  ProSource get proSource {
    if (allFeaturesOpen) return ProSource.buildOpen;
    if (activeEntitlement == null) return ProSource.none;
    return _fresh ? ProSource.server : ProSource.offlineCache;
  }

  bool get isPro => proSource != ProSource.none;

  /// Imkoniyat ochiqmi. Faqat amal boshlanishidan oldin yoki natijadan
  /// keyin chaqiriladi — boshlangan sanash/imtihon o'rtada to'xtatilmaydi.
  bool can(Feature feature) => !feature.pro || isPro;

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

  /// Serverdan yangilash. Internet bo'lmasa kesh qoladi (soxta holat
  /// ko'rsatilmaydi); hisobdan chiqilgan bo'lsa xotiradagi holat tozalanadi.
  Future<void> refresh() async {
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

  /// Xarid. Hozir to'lov yoqilmagan — [BillingOutcome.unavailable].
  Future<BillingOutcome> purchase(String productId) => _billing(() async {
    final proof = await purchases.buy(productId);
    return proof == null ? null : [proof];
  }, restore: false);

  /// "Xaridni tiklash" (App Store talabi).
  Future<BillingOutcome> restore() =>
      _billing(purchases.restore, restore: true);

  Future<BillingOutcome> _billing(
    Future<List<PurchaseProof>?> Function() run, {
    required bool restore,
  }) async {
    if (!purchasesEnabled) return BillingOutcome.unavailable;
    final user = source.userId;
    if (!source.hasSession || user == null) {
      return BillingOutcome.signInRequired;
    }
    try {
      final proofs = await run();
      if (proofs == null) return BillingOutcome.cancelled;
      if (proofs.isEmpty) return BillingOutcome.nothingFound;
      final snap = await source.verify(proofs, restore: restore);
      await _accept(user, snap);
      if (snap.ownedByOther && activeEntitlement == null) {
        return BillingOutcome.ownedByOther;
      }
      return activeEntitlement != null
          ? BillingOutcome.success
          : BillingOutcome.nothingFound;
    } on PurchaseUnavailableException {
      return BillingOutcome.unavailable;
    } on EntitlementException catch (e) {
      return e.failure == EntitlementFailure.notConfigured
          ? BillingOutcome.unavailable
          : BillingOutcome.failed;
    } on Object catch (e) {
      debugPrint('billing: $e');
      return BillingOutcome.failed;
    }
  }

  /// "Lokal ma'lumotlarni o'chirish" dan keyin.
  void resetInMemory() {
    _cache = null;
    _fresh = false;
    notifyListeners();
  }
}
