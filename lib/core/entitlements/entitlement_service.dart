import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../storage/kv_store.dart';
import 'billing_catalog.dart';
import 'device_attestor.dart';
import 'entitlement_cache.dart';
import 'entitlement_models.dart';
import 'entitlement_source.dart';
import 'feature.dart';
import 'guest_entitlements.dart';
import 'pro_catalog.dart';
import 'purchase_adapter.dart';
import 'trial_policy.dart';

/// Pro qayerdan keldi.
enum ProSource {
  /// Build rejimi: `LG_ALL_FEATURES_OPEN=true` (TestFlight/CI) yoki debug.
  buildOpen,

  /// Shu sessiyada serverdan tasdiqlangan.
  server,

  /// Admin bergan Pro (D-73), shu sessiyada serverdan tasdiqlangan.
  adminGrant,

  /// 7 kunlik bepul sinov (D-74/D-76), shu sessiyada serverdan tasdiqlangan.
  trial,

  /// Imzolangan oflayn kesh (muddati tugamagan).
  offlineCache,

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

  /// Mehmon (hisobsiz): xarid va tiklash uchun avval hisobga kirish kerak
  /// (D-76, egasi qarori). Do'kon oynasi ochilmaydi.
  signInRequired,

  /// Internet, do'kon yoki server xatosi — holat o'zgarmadi.
  failed,
}

/// Sinov tugmasi nega yo'q (D-75; UI oddiy izoh beradi).
enum TrialBlock {
  /// Sinov boshlash mumkin.
  none,

  /// Hisob yo'q (mehmon).
  guest,

  /// Shu hisob/telefon sinovdan foydalangan.
  used,

  /// Amaldagi Pro bor (obuna, admin yoki sinov).
  hasAccess,

  /// Server bu platformada sinov bermaydi (iOS — Apple javobigacha).
  notOnPlatform,

  /// Qurilma attestatsiyasi (Play Integrity / DeviceCheck) sozlanmagan.
  notConfigured,
}

/// Bepul sinovni boshlash natijasi (D-74).
enum TrialOutcome {
  /// Sinov yoqilmagan: server bayrog'i o'chiq, attestatsiya sozlanmagan yoki
  /// mehmon (hisob yo'q).
  unavailable,
  success,

  /// Shu telefon, email yoki hisob sinovdan foydalangan.
  alreadyUsed,

  /// Bu reja hisob uchun ruxsat etilmagan (masalan, serverda ustoz emas).
  planNotAllowed,

  /// Email hisobning tasdiqlangan emaili emas.
  emailNotVerified,

  /// Qurilma attestatsiyasi rad etildi.
  attestationFailed,

  /// Amaldagi pullik obuna bor.
  alreadySubscribed,
  failed,
}

/// Pro huquqlari: bitta joyda, uch manbadan.
///
/// 1. Build rejimi — [allFeaturesOpen] (`--dart-define=LG_ALL_FEATURES_OPEN=true`
///    TestFlight/CI buildlarda; debug buildda ham ochiq).
/// 2. Server tasdiqlagan huquq (do'kon obunasi, admin grant, bepul sinov —
///    faqat server yozadi).
/// 3. Imzolangan, hisobga bog'langan, muddatli kesh — oflaynda muddati
///    tugaguncha ishlaydi.
///
/// Mehmon (hisobsiz) — D-77 addendum (Apple 5.1.1(v), D-76 §5 ni
/// almashtiradi): server mehmon siyosatini bersa ([GuestPolicy]) va
/// [guestStore] ulangan bo'lsa, mehmon hisobga bog'liq bo'lmagan rejalarni
/// (learner, lab) sotib oladi va TIKLAYDI; server do'kon tranzaksiyasi +
/// qurilmaga bog'langan imzolangan token beradi, hisobga kirilganda xarid
/// hisobga o'tadi (ikki marta berilmaydi). `teacher_panel` — faqat hisob bilan.
/// Server mehmon siyosatini bermasa — eski qoida: xarid/tiklash uchun hisobga
/// kirish ([BillingOutcome.signInRequired]). Sinov — faqat hisob bilan.
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
    this.studentVerified = false,
    this.gated = ProGatePolicy.gated,
    this.attestor = const UnconfiguredDeviceAttestor(),
    this.guestStore,
    this.storeOffersAllowed = ProTrialConfig.storeIntroOffersAllowed,
  }) : purchases = purchases ?? UnavailablePurchaseAdapter(),
       _cacheStore = cache,
       now = clock ?? DateTime.now {
    this.purchases.addListener(notifyListeners);
  }

  /// TestFlight/CI build bayrog'i. Do'kon (release) buildda `false`.
  static const buildAllFeaturesOpen = bool.fromEnvironment(
    'LG_ALL_FEATURES_OPEN',
  );

  /// Pro YOQILMAGAN (`BuildFlags.proEnabled == false`) holat: do'kon yo'q,
  /// server yo'q, `start()` hech qachon chaqirilmaydi. `can()` doim `true`.
  /// Hech qanday plagin yoki tarmoq ishga tushmaydi.
  factory EntitlementService.disabled() => EntitlementService(
    source: const UnavailableEntitlementSource(),
    cache: EntitlementCacheStore(
      MemoryKeyValueStore(),
      MemoryEntitlementKeyStore(),
    ),
    allFeaturesOpen: true,
  );

  final EntitlementSource source;
  final PurchaseAdapter purchases;
  final bool allFeaturesOpen;

  /// Haqiqatan yopiladigan imkoniyatlar (standart: bo'sh, D-71).
  final Set<Feature> gated;

  /// Bepul sinov uchun qurilma attestatsiyasi (D-74). Standart —
  /// sozlanmagan: sinov taklif qilinmaydi.
  final DeviceAttestor attestor;

  /// Mehmon qurilma belgisi va tokenlari (D-77 addendum). `null` — mehmon
  /// xaridi o'chiq (D-76 xatti-harakati).
  final GuestDeviceStore? guestStore;

  /// Play'da do'kon kirish taklifini tanlash/ko'rsatish (egasi qarori;
  /// standart `ProTrialConfig.storeIntroOffersAllowed` = false). App Store'da
  /// haqli foydalanuvchiga taklifni Apple o'zi qo'llaydi — shartlar baribir
  /// ko'rsatiladi (trial_policy.dart).
  final bool storeOffersAllowed;
  final Duration offlineTtl;

  /// Talaba holati tasdiqlangan hisob (D-49). Ilovada hali bunday tasdiq
  /// yo'q — talaba mahsulotlari ko'rsatilmaydi.
  final bool studentVerified;
  DateTime Function() now;

  final EntitlementCacheStore _cacheStore;
  EntitlementCache? _cache;
  bool _fresh = false;

  /// Mehmon paytida qurilmada ko'rilgan do'kon tranzaksiyalari (shu sessiya).
  /// Huquq BERMAYDI (D-76) — faqat hisobga kirilganda serverga bog'lanadi.
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
  /// Do'kon kirish taklifi — [StoreOfferPolicy] (D-77 addendum): shartlar
  /// faqat do'kondan va faqat do'kon haqli desa; Play'da taklif faqat egasi
  /// yoqsa ([storeOffersAllowed]); App Store'da Apple o'zi qo'llaydigan
  /// taklif yashirilmaydi.
  List<StoreProduct> get offeredProducts => [
    for (final p in purchases.loaded)
      if (p.catalog case final c?)
        if (BillingCatalog.offered(c, studentVerified: studentVerified))
          StoreOfferPolicy.apply(
            p,
            ios: source.platform == 'app_store',
            storeOffersAllowed: storeOffersAllowed,
          ),
  ];

  /// Ko'rsatilgan do'kon taklifi LabGuide server sinovidan keyin
  /// (foydalanuvchi sinovdan foydalangan) — UI "bu do'kon taklifi, 7 kunlik
  /// LabGuide sinovidan alohida" deb aniq yozadi.
  bool get storeOfferAfterServerTrial => trialUsed;

  /// Kesh huquq beradimi. Soat orqaga surilgan bo'lsa (javob olingan
  /// paytdan yoki kuzatilgan eng katta vaqtdan [_clockSkew] dan ko'p) —
  /// yo'q; yangi server javobi kerak.
  bool _cacheValid(DateTime t) {
    final c = _cache;
    if (c == null) return false;
    if (t.isBefore(c.receivedAt.subtract(_clockSkew))) return false;
    final seen = _seen != null && _seen!.isAfter(c.lastSeen) ? _seen! : c.lastSeen;
    if (t.isBefore(seen.subtract(_clockSkew))) return false;
    return t.isBefore(c.validUntil);
  }

  /// Shu sessiyada kuzatilgan eng katta qurilma vaqti.
  DateTime? _seen;

  /// Soatni kuzatish (ishga tushish / oldingi planga qaytish): yuqori suv
  /// belgisi oshsa keshga yoziladi (orqaga surilgan soat uni kamaytirmaydi).
  Future<void> _touchClock() async {
    final t = now();
    if (_seen == null || t.isAfter(_seen!)) _seen = t;
    final c = _cache;
    if (c == null || !t.isAfter(c.lastSeen.add(const Duration(minutes: 1)))) {
      return;
    }
    _cache = c.withLastSeen(t);
    await _cacheStore.write(_cache!);
  }

  /// Mehmon keshi uchun hisob o'rniga belgi (kesh faqat shu qurilmada).
  static const guestCacheUser = '~guest';

  /// Kesh egasi: hisob yoki (mehmon xaridi yoqilgan bo'lsa) mehmon.
  String? get _cacheUser =>
      source.userId ?? (guestStore != null ? guestCacheUser : null);

  GuestBillingSource? get _guestSource => switch (source) {
    final GuestBillingSource g when g.guestPolicy != null && guestStore != null => g,
    _ => null,
  };

  /// Mehmon shu mahsulotni sotib olishi mumkinmi (server siyosati).
  bool guestCanPurchase(String productId) =>
      _guestSource?.guestPolicy?.allows(BillingCatalog.planOf(productId)) ??
      false;

  /// Xarid tugmasi ko'rsatilsinmi: hisob bilan — hamma reja; mehmon —
  /// faqat server ruxsat bergan (hisobga bog'liq bo'lmagan) rejalar.
  bool canPurchase(String productId) =>
      source.hasSession || guestCanPurchase(productId);

  /// Mehmon "Xaridlarni tiklash" ni ishlata oladimi.
  bool get guestRestoreAvailable => _guestSource != null;

  /// Mehmon xaridi bog'langan hisob bor — huquq uchun hisobga kirish kerak.
  bool get guestSignInRequired => _guestSignIn;
  bool _guestSignIn = false;

  /// Server qatorlaridan amaldagilari. Bepul sinov (D-74) pullik do'kon
  /// obunasini hech qachon bosib o'tmaydi: amaldagi obuna bo'lsa sinov
  /// qatori hisobga olinmaydi (server `resolveAccess` bilan bir xil).
  Iterable<ServerEntitlement> _serverGranting() {
    final c = _cache;
    final t = now();
    if (c == null || !_cacheValid(t)) return const [];
    final serverNow = t.add(c.clockOffset);
    final live = [
      for (final e in c.items)
        if (e.grantsAt(serverNow)) e,
    ];
    if (live.any((e) => e.isStore)) return live.where((e) => !e.isTrial);
    return live;
  }

  /// Eng yaxshi qator (D-73): yuqori daraja yutadi; teng darajada eng uzoq
  /// muddat (`null` — muddatsiz, eng uzoq); to'liq tenglikda do'kon xaridi
  /// (admin grant do'kon obunasini hech qachon bosib o'tmaydi). Server
  /// `resolved` bilan bir xil qoida.
  static ServerEntitlement? _best(Iterable<ServerEntitlement> items) {
    ServerEntitlement? best;
    for (final e in items) {
      if (best == null || _beats(e, best)) best = e;
    }
    return best;
  }

  static bool _beats(ServerEntitlement a, ServerEntitlement b) {
    final ra = a.effectivePlan?.index ?? -1;
    final rb = b.effectivePlan?.index ?? -1;
    if (ra != rb) return ra > rb;
    final ea = a.expiresAt;
    final eb = b.expiresAt;
    if (ea != eb) {
      if (ea == null) return true;
      if (eb == null) return false;
      return ea.isAfter(eb);
    }
    // Tenglikda: do'kon > admin grant > sinov.
    int prio(ServerEntitlement e) => e.isStore ? 2 : (e.isAdminGrant ? 1 : 0);
    return prio(a) > prio(b);
  }

  /// Amaldagi huquq (eng yaxshisi): server/kesh. Mehmonda — yo'q (D-76).
  ServerEntitlement? get activeEntitlement => _best(_serverGranting());

  /// Serverda do'kon xaridi bormi (admin grant sanalmaydi: qurilmadagi xarid
  /// admin grant bo'lsa ham hisobga bog'lanadi).
  bool get _hasStoreOnServer => _serverGranting().any((e) => e.isStore);

  /// Amaldagi pullik daraja (`null` — yo'q yoki katalogda yo'q).
  ProPlan? get plan => activeEntitlement?.effectivePlan;

  ProSource get proSource {
    if (allFeaturesOpen) return ProSource.buildOpen;
    if (_best(_serverGranting()) case final e?) {
      if (!_fresh) return ProSource.offlineCache;
      if (e.isTrial) return ProSource.trial;
      return e.isAdminGrant ? ProSource.adminGrant : ProSource.server;
    }
    return ProSource.none;
  }

  bool get isPro => proSource != ProSource.none;

  /// Amaldagi imkoniyatlar to'plami: hozir amal qilayotgan BARCHA huquq
  /// qatorlari birlashmasi (D-76: matritsa zinapoya emas — Ustoz obunasi va
  /// Mutaxassis granti birga ustoz paneli + Lab beradi). Server
  /// `tiers.ts` `accessCapabilities` bilan bir xil.
  ProTier get tier {
    if (allFeaturesOpen) return ProTier.all;
    var have = ProTier.free;
    for (final e in _serverGranting()) {
      have = have | e.tier;
    }
    return have;
  }

  /// Amaldagi bepul sinovda qolgan to'liq kunlar (`null` — sinov yo'q).
  int? get trialDaysLeft {
    final e = activeEntitlement;
    final end = e?.expiresAt;
    if (e == null || !e.isTrial || end == null) return null;
    final left = end.difference(now().toUtc().add(_cache!.clockOffset));
    if (left.isNegative) return 0;
    return (left.inHours / 24).ceil();
  }

  /// Shu hisob bepul sinovdan foydalanganmi (server qatori yoki belgisi).
  /// Telefon bo'yicha holat faqat serverda tekshiriladi.
  bool get trialUsed =>
      _trialUsed || (_cache?.items.any((e) => e.isTrial) ?? false);
  bool _trialUsed = false;

  /// Bepul sinovni boshlash mumkinmi: hisob, server imkoniyat so'rovi shu
  /// platformada sinov bor desa ([TrialSource.trialOffered] — D-75: iOS
  /// standart yopiq) va qurilma attestatsiyasi (D-74). Bugun hech bir buildda
  /// attestatsiya yo'q → `false`.
  bool get trialAvailable =>
      attestor.available &&
      _trialSource?.trialOffered == true &&
      source.hasSession &&
      !trialUsed &&
      activeEntitlement == null;

  /// Server shu platformada sinov beradimi (D-75 imkoniyat so'rovi).
  bool get trialOfferedHere => _trialSource?.trialOffered == true;

  TrialSource? get _trialSource => switch (source) {
    final TrialSource t => t,
    _ => null,
  };

  /// Nima uchun sinov tugmasi yo'q (UI uchun oddiy izoh).
  TrialBlock get trialBlock {
    if (!source.hasSession) return TrialBlock.guest;
    if (trialUsed) return TrialBlock.used;
    if (activeEntitlement != null) return TrialBlock.hasAccess;
    if (_trialSource?.trialOffered != true) return TrialBlock.notOnPlatform;
    if (!attestor.available) return TrialBlock.notConfigured;
    return TrialBlock.none;
  }

  /// Bepul sinovni boshlash: nonce → qurilma attestatsiyasi → server.
  /// [email] — hisobning tasdiqlangan emaili (server tekshiradi).
  Future<TrialOutcome> startTrial({
    required ProPlan plan,
    required String email,
  }) async {
    final user = source.userId;
    final src = _trialSource;
    // Sinov kodi HECH QACHON do'kon xaridini boshlamaydi (purchases.buy yo'q):
    // to'lov usuli so'ralmaydi, pul yechilmaydi (D-75).
    if (!attestor.available ||
        src == null ||
        !src.trialOffered ||
        user == null) {
      return TrialOutcome.unavailable;
    }
    if (_busy) return TrialOutcome.failed;
    _busy = true;
    notifyListeners();
    try {
      final nonce = await src.trialChallenge();
      final attestation = await attestor.attest(nonce);
      await _accept(
        user,
        await src.startTrial(
          plan: plan,
          email: email,
          nonce: nonce,
          attestation: attestation,
        ),
      );
      return TrialOutcome.success;
    } on EntitlementException catch (e) {
      if (e.detail == 'trial_already_used') _trialUsed = true;
      return switch (e.detail) {
        'trial_already_used' => TrialOutcome.alreadyUsed,
        'plan_not_allowed' => TrialOutcome.planNotAllowed,
        'email_not_verified' => TrialOutcome.emailNotVerified,
        'device_attestation_failed' => TrialOutcome.attestationFailed,
        'already_subscribed' => TrialOutcome.alreadySubscribed,
        'device_attestation_not_configured' ||
        'not_found' => TrialOutcome.unavailable,
        _ =>
          e.failure == EntitlementFailure.notConfigured
              ? TrialOutcome.unavailable
              : TrialOutcome.failed,
      };
    } on Object catch (e) {
      debugPrint('trial: $e');
      return TrialOutcome.failed;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Imkoniyat ochiqmi. Faqat amal boshlanishidan oldin yoki natijadan
  /// keyin chaqiriladi — boshlangan amal o'rtada to'xtatilmaydi.
  /// To'lov yoqilmagan bo'lsa — doim `true`. Katalogda faqat pullik
  /// funksiyalar bor (D-78): bugungi bepul funksiyalar bu yerdan umuman
  /// so'ralmaydi va hech qachon yopilmaydi; foydalanuvchi ma'lumoti va
  /// tarix hech qachon cheklanmaydi yoki yashirilmaydi.
  bool can(Feature feature) =>
      !gated.contains(feature) || !gatingActive || tier.covers(feature);

  /// Pro amalda bo'lgan davrlar (qaytarilgan xaridsiz). Kesh oflayn
  /// muddati o'tgan bo'lsa ham davrlar saqlanadi — bu huquq emas, tarix.
  List<ProPeriod> get proPeriods => [
    for (final e in _cache?.items ?? const <ServerEntitlement>[]) ?e.period,
  ];

  /// Ilova ochilganda: shu hisobning imzolangan keshi (bo'lsa).
  Future<void> load() async {
    final user = _cacheUser;
    _cache = user == null ? null : await _cacheStore.read(user);
    _fresh = false;
    _trialUsed = false;
    notifyListeners();
  }

  /// Ilova ochilganda (main): kesh → server to'lov sozlamasi → do'kon
  /// mahsulotlari → serverdan holat → do'kondagi joriy obunalar (jim).
  Future<void> start() async {
    await load();
    await _touchClock();
    if (attestor case final PreparableAttestor a) await a.prepare();
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
    if (source.isConfigured && !source.hasSession && guestStore != null) {
      await _refreshGuest();
      return;
    }
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
    // Mehmon paytidagi xaridlar (tokenlar) — endi hisobga o'tadi (bir marta).
    await _linkGuest(user);
    // Mehmon paytida qilingan xarid — endi hisobga bog'lanadi.
    if (_device.isNotEmpty && !_hasStoreOnServer) {
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

  /// Mehmon: saqlangan tokenlar bo'yicha serverdan holat (yo'q bo'lsa —
  /// mehmon keshi qoladi yoki tozalanadi).
  Future<void> _refreshGuest() async {
    final store = guestStore!;
    if (_cache != null && _cache!.userId != guestCacheUser) {
      _cache = null;
      _fresh = false;
    }
    _cache ??= await _cacheStore.read(guestCacheUser);
    final g = _guestSource;
    final tokens = await store.tokens();
    if (g == null || tokens.isEmpty) {
      notifyListeners();
      return;
    }
    try {
      final snap = await g.guestRefresh(
        deviceId: await store.deviceId(),
        tokens: tokens,
      );
      await _acceptGuest(snap, merge: false);
    } on Object catch (e) {
      debugPrint('guest refresh: $e');
    }
  }

  Future<void> _acceptGuest(EntitlementSnapshot snap, {required bool merge}) async {
    final store = guestStore!;
    final previous = merge ? await store.tokens() : const <String>[];
    await store.saveTokens({...previous, ...snap.guestTokens}.toList());
    _guestSignIn = snap.signInRequired;
    await _accept(guestCacheUser, snap);
  }

  /// Hisobga kirilganda mehmon tokenlarini hisobga bog'laydi.
  Future<void> _linkGuest(String user) async {
    final store = guestStore;
    final g = switch (source) {
      final GuestBillingSource s => s,
      _ => null,
    };
    if (store == null || g == null) return;
    final tokens = await store.tokens();
    if (tokens.isEmpty) return;
    try {
      final snap = await g.guestLink(
        deviceId: await store.deviceId(),
        tokens: tokens,
      );
      await store.saveTokens(const []);
      _guestSignIn = false;
      await _accept(user, snap);
    } on Object catch (e) {
      // Tokenlar qoladi — keyingi refresh'da yana urinadi.
      debugPrint('guest link: $e');
    }
  }

  Future<void> _accept(String user, EntitlementSnapshot snap) async {
    final t = now();
    // Oflayn chegarasi (D-75): min(lokal [offlineTtl] (7 kun), server bergan
    // `offline_until` — qurilma soatiga o'girilgan). Oflaynda hech qachon
    // uzaytirilmaydi: yangi chegara faqat serverning yangi javobi bilan.
    var until = t.add(offlineTtl);
    if (snap.offlineUntil case final server?) {
      final local = server.subtract(snap.serverTime.difference(t.toUtc()));
      if (local.isBefore(until)) until = local;
    }
    _cache = EntitlementCache(
      userId: user,
      serverTime: snap.serverTime,
      receivedAt: t,
      validUntil: until,
      items: snap.items,
    );
    if (snap.trialUsed) _trialUsed = true;
    // Yangi server javobi — soat kuzatuvi shu paytdan qayta boshlanadi.
    _seen = t;
    _fresh = true;
    await _cacheStore.write(_cache!);
    notifyListeners();
  }

  /// Do'kondagi joriy obunalar (jim, oyna yo'q): mehmonda — faqat eslab
  /// qolinadi (huquq bermaydi, D-76); hisobda — server bilmagan xarid bo'lsa
  /// bog'lanadi.
  Future<void> _syncDevice() async {
    List<PurchaseProof> proofs;
    try {
      proofs = await purchases.restore(userInitiated: false);
    } on Object catch (e) {
      debugPrint('entitlements sync: $e');
      return;
    }
    _setDevice(proofs);
    if (source.hasSession && !_hasStoreOnServer) {
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
    final g = _guestSource;
    if ((!source.hasSession || user == null) && g != null) {
      // Mehmon xaridi (yangilanish, Ask to Buy tasdig'i): server tekshiradi.
      try {
        await _acceptGuest(
          await g.guestVerify(
            [proof],
            deviceId: await guestStore!.deviceId(),
            restore: false,
          ),
          merge: true,
        );
        await purchases.finish(proof);
      } on Object catch (e) {
        debugPrint('guest update: $e');
      }
      return;
    }
    if (!source.hasSession || user == null) {
      // Mehmon (server mehmon xaridini qo'llamaydi): huquq bermaydi, hisobga
      // kirilganda serverga bog'lanadi.
      // Yakunlanadi — Play tasdiqlanmagan xaridni 3 kundan keyin qaytaradi.
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

  /// Xarid — faqat foydalanuvchi bosganda; to'lov do'konning o'z tasdiq
  /// oynasida. Mehmon: server ruxsat bergan rejani sotib oladi (D-77
  /// addendum), aks holda [BillingOutcome.signInRequired] (do'kon oynasi
  /// ochilmaydi).
  Future<BillingOutcome> purchase(String productId) => _billing(
    () async {
      final proof = await purchases.buy(
        productId,
        accountToken: _accountToken(),
      );
      return proof == null ? null : [proof];
    },
    restore: false,
    guestAllowed: guestCanPurchase(productId),
  );

  /// "Xaridni tiklash" (App Store talabi) — hisob bilan ham, mehmon uchun
  /// ham (server mehmon xaridini qo'llasa).
  Future<BillingOutcome> restore() => _billing(
    () => purchases.restore(userInitiated: true),
    restore: true,
    guestAllowed: guestRestoreAvailable,
  );

  Future<BillingOutcome> _billing(
    Future<List<PurchaseProof>?> Function() run, {
    required bool restore,
    bool guestAllowed = false,
  }) async {
    if (!purchasesEnabled) return BillingOutcome.unavailable;
    final user = source.userId;
    final guest = !source.hasSession || user == null;
    // Mehmon: faqat server ruxsat bergan holat; aks holda do'kon chaqirilmaydi.
    if (guest && (!guestAllowed || _guestSource == null)) {
      return BillingOutcome.signInRequired;
    }
    if (_busy) return BillingOutcome.failed;
    _busy = true;
    notifyListeners();
    try {
      final proofs = await run();
      if (proofs == null) return BillingOutcome.cancelled;
      if (proofs.isEmpty) return BillingOutcome.nothingFound;
      if (guest) return await _guestBilling(proofs, restore: restore);
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

  /// Mehmon xaridi/tiklashi: server tekshiradi, token saqlanadi.
  Future<BillingOutcome> _guestBilling(
    List<PurchaseProof> proofs, {
    required bool restore,
  }) async {
    final snap = await _guestSource!.guestVerify(
      proofs,
      deviceId: await guestStore!.deviceId(),
      restore: restore,
    );
    await _acceptGuest(snap, merge: true);
    for (final p in proofs) {
      await purchases.finish(p);
    }
    if (activeEntitlement != null) return BillingOutcome.success;
    if (snap.signInRequired) return BillingOutcome.signInRequired;
    return restore ? BillingOutcome.nothingFound : BillingOutcome.failed;
  }

  /// Ilova oldingi planga qaytganda (D-75): serverdan yangilash, lekin
  /// [resumeThrottle] dan tez-tez emas. Boshqa qurilmadagi xarid/bekor qilish
  /// shu yerda ko'rinadi. Xato bo'lsa kesh qoladi (huquq UZAYTIRILMAYDI).
  Future<void> onResume() async {
    final t = now();
    final last = _lastResume;
    await _touchClock();
    if (last != null && t.difference(last) < resumeThrottle && !t.isBefore(last)) {
      return;
    }
    _lastResume = t;
    await refresh();
  }

  DateTime? _lastResume;

  /// Ilova qayta ochilganda server so'rovlari orasidagi eng kam vaqt.
  static const resumeThrottle = Duration(minutes: 5);

  /// "Lokal ma'lumotlarni o'chirish" dan keyin.
  void resetInMemory() {
    _trialUsed = false;
    _guestSignIn = false;
    _seen = null;
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
