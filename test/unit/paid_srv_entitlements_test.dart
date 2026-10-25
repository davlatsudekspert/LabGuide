import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labguide/core/backend/cloudflare_backend.dart';
import 'package:labguide/core/backend/supabase_backend.dart' show SessionStore;
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/device_attestor.dart';
import 'package:labguide/core/entitlements/entitlement_cache.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/entitlement_service.dart';
import 'package:labguide/core/entitlements/entitlement_source.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/core/entitlements/guest_entitlements.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/core/entitlements/purchase_adapter.dart';
import 'package:labguide/core/entitlements/trial_policy.dart';
import 'package:labguide/core/storage/kv_store.dart';

import '../helpers/billing_fakes.dart';
import '../helpers/guest_fakes.dart';

/// D-77 addendum (paid/srv): mehmon do'kon huquqlari, soat orqaga surilishi,
/// do'kon taklifi shartlari (ikki sinov siyosati), yangi server maydonlari.
final _t0 = DateTime.utc(2026, 10, 25, 9);

ServerEntitlement _guestItem(
  String product, {
  DateTime? end,
  EntitlementStatus status = EntitlementStatus.active,
}) => ServerEntitlement(
  productId: product,
  platform: 'play_store',
  status: status,
  source: ServerEntitlement.guestStoreSource,
  startedAt: _t0.subtract(const Duration(days: 1)),
  expiresAt: end ?? _t0.add(const Duration(days: 30)),
);

EntitlementSnapshot _guestSnap(
  List<ServerEntitlement> items, {
  List<String> tokens = const ['g1.a.b'],
  bool signIn = false,
}) => EntitlementSnapshot(
  serverTime: _t0,
  items: items,
  guestTokens: tokens,
  signInRequired: signIn,
  offlineUntil: _t0.add(const Duration(days: 7)),
);

const _guestPolicy = GuestPolicy(
  purchasePlans: {ProPlan.student, ProPlan.specialist},
);

const _playProof = PurchaseProof(
  platform: 'play_store',
  productId: BillingCatalog.specialistMonthly,
  token: 'play-token-guest-0001',
);

class _NoSessions implements SessionStore {
  @override
  Future<void> delete() async {}
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String v) async {}
}

void main() {
  late MemoryKeyValueStore store;
  late MemoryEntitlementKeyStore keys;
  late FakePurchaseAdapter shop;
  late DateTime now;

  setUp(() {
    store = MemoryKeyValueStore();
    keys = MemoryEntitlementKeyStore();
    shop = FakePurchaseAdapter(proofs: const [_playProof]);
    now = _t0;
  });

  EntitlementService make(
    EntitlementSource source, {
    GuestDeviceStore? guest,
    bool storeOffersAllowed = false,
  }) => EntitlementService(
    source: source,
    cache: EntitlementCacheStore(store, keys),
    allFeaturesOpen: false,
    purchases: shop,
    clock: () => now,
    guestStore: guest,
    storeOffersAllowed: storeOffersAllowed,
  );

  group('mehmon (hisobsiz) xarid — Apple 5.1.1(v), D-77 addendum', () {
    test('ruxsat etilgan reja (Mutaxassis): do‘kon oynasi hisob belgisisiz, server '
        'tekshiradi, Lab ochiladi, ustoz paneli YO‘Q; token saqlanadi', () async {
      final src = FakeGuestSource(user: null, platform: 'play_store', policy: _guestPolicy)
        ..guestReply = _guestSnap([_guestItem(BillingCatalog.premiumMonthly)]);
      final guest = MemoryGuestDeviceStore('guest-dev-123456');
      final s = make(src, guest: guest);
      expect(s.canPurchase(BillingCatalog.specialistMonthly), isTrue);
      expect(s.canPurchase(BillingCatalog.teacherMonthly), isFalse);
      expect(
        await s.purchase(BillingCatalog.specialistMonthly),
        BillingOutcome.success,
      );
      expect(shop.bought.single, (BillingCatalog.specialistMonthly, null));
      expect(src.guestVerifies.single.$2, 'guest-dev-123456');
      expect(src.guestVerifies.single.$3, isFalse);
      expect(src.verified, isNull, reason: 'hisob yo‘li ishlatilmadi');
      expect(s.isPro, isTrue);
      expect(s.tier.allows(ProCapability.lab), isTrue);
      expect(s.tier.allows(ProCapability.learner), isTrue);
      expect(
        s.tier.allows(ProCapability.teacherPanel),
        isFalse,
        reason: 'Premium bo‘lsa ham mehmonda ustoz paneli yo‘q',
      );
      expect(guest.saved, ['g1.a.b']);
      expect(shop.finished, [_playProof]);
    });

    test('ustoz paneli bor reja — signInRequired, do‘kon chaqirilmaydi', () async {
      final src = FakeGuestSource(user: null, policy: _guestPolicy);
      final s = make(src, guest: MemoryGuestDeviceStore());
      expect(
        await s.purchase(BillingCatalog.teacherMonthly),
        BillingOutcome.signInRequired,
      );
      expect(
        await s.purchase(BillingCatalog.premiumYearly),
        BillingOutcome.signInRequired,
      );
      expect(shop.bought, isEmpty);
    });

    test('server mehmon siyosatini bermasa (yoki guestStore yo‘q) — eski qoida '
        '(D-76): signInRequired', () async {
      final noPolicy = make(
        FakeGuestSource(user: null),
        guest: MemoryGuestDeviceStore(),
      );
      expect(
        await noPolicy.purchase(BillingCatalog.specialistMonthly),
        BillingOutcome.signInRequired,
      );
      expect(await noPolicy.restore(), BillingOutcome.signInRequired);
      final noStore = make(FakeGuestSource(user: null, policy: _guestPolicy));
      expect(await noStore.restore(), BillingOutcome.signInRequired);
      expect(shop.bought, isEmpty);
    });

    test('tiklash natijalari: tiklandi / topilmadi / hisobga bog‘langan', () async {
      final src = FakeGuestSource(user: null, policy: _guestPolicy)
        ..guestReply = _guestSnap([_guestItem(BillingCatalog.specialistYearly)]);
      final s = make(src, guest: MemoryGuestDeviceStore());
      expect(await s.restore(), BillingOutcome.success);
      expect(src.guestVerifies.last.$3, isTrue);

      shop.proofs = const [];
      final empty = make(src, guest: MemoryGuestDeviceStore());
      expect(await empty.restore(), BillingOutcome.nothingFound);

      shop.proofs = const [_playProof];
      src.guestReply = _guestSnap(const [], tokens: const [], signIn: true);
      final linked = make(src, guest: MemoryGuestDeviceStore());
      expect(await linked.restore(), BillingOutcome.signInRequired);
      expect(linked.guestSignInRequired, isTrue);
      expect(linked.isPro, isFalse);
    });

    test('ilova qayta ochilganda: tokenlar bilan yangilash; oflayn — imzolangan '
        'kesh; 7 kundan keyin yo‘q', () async {
      final src = FakeGuestSource(user: null, policy: _guestPolicy)
        ..guestReply = _guestSnap([_guestItem(BillingCatalog.specialistYearly)]);
      final guest = MemoryGuestDeviceStore()..saved = ['g1.saved.token'];
      final s = make(src, guest: guest);
      await s.start();
      expect(src.refreshes.single.$2, ['g1.saved.token']);
      expect(s.isPro, isTrue);

      // Oflayn qayta ochilish: yangi servis, server javob bermaydi.
      src.policy = null;
      final off = make(src, guest: guest);
      await off.load();
      expect(off.isPro, isTrue);
      expect(off.proSource, ProSource.offlineCache);
      now = _t0.add(const Duration(days: 7, minutes: 1));
      expect(off.isPro, isFalse);
    });

    test('hisobga kirilganda mehmon tokenlari hisobga bog‘lanadi (bir marta), '
        'tokenlar tozalanadi', () async {
      final src = FakeGuestSource(user: null, policy: _guestPolicy)
        ..guestReply = _guestSnap([_guestItem(BillingCatalog.specialistYearly)])
        ..linkReply = EntitlementSnapshot(
          serverTime: _t0,
          items: [
            ServerEntitlement(
              productId: BillingCatalog.specialistYearly,
              platform: 'play_store',
              status: EntitlementStatus.active,
              startedAt: _t0,
              expiresAt: _t0.add(const Duration(days: 300)),
            ),
          ],
        );
      final guest = MemoryGuestDeviceStore('guest-dev-abcdef');
      final s = make(src, guest: guest);
      expect(
        await s.purchase(BillingCatalog.specialistMonthly),
        BillingOutcome.success,
      );
      src.user = 'user-a';
      src.snapshot = EntitlementSnapshot(serverTime: _t0, items: const []);
      await s.refresh();
      expect(src.links.single.$1, 'guest-dev-abcdef');
      expect(src.links.single.$2, ['g1.a.b']);
      expect(guest.saved, isEmpty);
      expect(s.cached?.userId, 'user-a');
      expect(s.activeEntitlement?.isGuest, isFalse);
      expect(s.isPro, isTrue);
      await s.refresh();
      expect(src.links, hasLength(1), reason: 'qayta bog‘lanmaydi');
    });

    test('mehmon do‘kon yangilanishi (Ask to Buy tasdig‘i) — server tekshiradi, '
        'keyin yakunlanadi', () async {
      final src = FakeGuestSource(user: null, policy: _guestPolicy)
        ..guestReply = _guestSnap([_guestItem(BillingCatalog.specialistMonthly)]);
      final s = make(src, guest: MemoryGuestDeviceStore());
      await s.start();
      shop.emit(_playProof);
      await pumpEventQueue();
      expect(src.guestVerifies, isNotEmpty);
      expect(shop.finished, contains(_playProof));
      expect(s.isPro, isTrue);
    });

    test('server siyosati JSON dan; noto‘g‘ri/bo‘sh — null', () {
      expect(
        GuestPolicy.parse({
          'purchase_plans': ['student', 'specialist', 'gold'],
          'max_devices': 5,
        })?.purchasePlans,
        {ProPlan.student, ProPlan.specialist},
      );
      expect(GuestPolicy.parse({'purchase_plans': <String>[]}), isNull);
      expect(GuestPolicy.parse(null), isNull);
    });
  });

  group('oflayn kesh: soat orqaga surilishi (monoton yuqori belgi)', () {
    EntitlementSnapshot subSnap() => EntitlementSnapshot(
      serverTime: _t0,
      items: [
        ServerEntitlement(
          productId: BillingCatalog.specialistMonthly,
          platform: 'app_store',
          status: EntitlementStatus.active,
          startedAt: _t0,
          expiresAt: _t0.add(const Duration(days: 30)),
        ),
      ],
      offlineUntil: _t0.add(const Duration(days: 7)),
    );

    test('6-kuni ko‘rilgan, keyin soat 1-kunga qaytarilsa — oflayn Pro yo‘q '
        '(oyna ichida cho‘zib bo‘lmaydi)', () async {
      final src = FakeEntitlementSource()..snapshot = subSnap();
      final s = make(src);
      await s.start();
      expect(s.isPro, isTrue);
      // Oflayn: 6-kun, ilova oldingi planga qaytdi (soat kuzatildi).
      src.error = const EntitlementException(EntitlementFailure.network);
      now = _t0.add(const Duration(days: 6));
      await s.onResume();
      expect(s.isPro, isTrue);
      // Foydalanuvchi soatni 1-kunga qaytardi.
      now = _t0.add(const Duration(days: 1));
      expect(s.isPro, isFalse);
      // Ilova qayta ishga tushsa ham (yozilgan yuqori belgi) — yo‘q.
      final again = make(src);
      await again.load();
      expect(again.isPro, isFalse);
      // Soat to‘g‘rilansa — yana (kesh muddati ichida).
      now = _t0.add(const Duration(days: 6, hours: 1));
      expect(again.isPro, isTrue);
    });

    test('yangi server javobi yuqori belgini qayta o‘rnatadi (soat farqi '
        'clockOffset bilan hisoblanadi)', () async {
      final src = FakeEntitlementSource()..snapshot = subSnap();
      final s = make(src);
      now = _t0.add(const Duration(days: 3));
      await s.start();
      now = _t0; // soat orqaga, lekin server javob beradi
      await s.refresh();
      expect(s.isPro, isTrue);
    });

    test('kesh JSON: last_seen saqlanadi; eski kesh (last_seen yo‘q) — receivedAt', () {
      final c = EntitlementCache(
        userId: 'u',
        serverTime: _t0,
        receivedAt: _t0,
        validUntil: _t0.add(const Duration(days: 7)),
        items: const [],
        lastSeen: _t0.add(const Duration(days: 2)),
      );
      final back = EntitlementCache.fromJson(
        (jsonDecode(jsonEncode(c.toJson())) as Map).cast<String, Object?>(),
      );
      expect(back.lastSeen, _t0.add(const Duration(days: 2)));
      final old = c.toJson()..remove('last_seen');
      expect(EntitlementCache.fromJson(old).lastSeen, _t0);
    });
  });

  group('do‘kon kirish taklifi (ikki sinov siyosati)', () {
    const monthly = StorePeriod(1, StorePeriodUnit.month);
    const week = StorePeriod(1, StorePeriodUnit.week);
    StoreProduct product({StoreIntroOffer? offer}) => StoreProduct(
      id: BillingCatalog.specialistMonthly,
      title: 'LabGuide',
      displayPrice: r'$3.49',
      period: monthly,
      introOffer: offer,
    );

    test('App Store: haqli bepul sinov — ko‘rsatiladi (Apple o‘zi qo‘llaydi); '
        'haqli emas — yo‘q', () {
      final shown = StoreOfferPolicy.apply(
        product(offer: const StoreIntroOffer(period: week)),
        ios: true,
        storeOffersAllowed: false,
      );
      expect(shown.freeTrial, week);
      expect(shown.introOffer?.isFreeTrial, isTrue);
      final hidden = StoreOfferPolicy.apply(
        product(offer: const StoreIntroOffer(period: week, eligible: false)),
        ios: true,
        storeOffersAllowed: true,
      );
      expect(hidden.freeTrial, isNull);
      expect(hidden.introOffer, isNull);
    });

    test('Google Play: egasi ruxsat bermasa (standart) — taklif yo‘q; ruxsat '
        'bilan — do‘kon shartlari', () {
      final offer = const StoreIntroOffer(period: week, cycles: 2);
      expect(
        StoreOfferPolicy.visible(product(offer: offer), ios: false, storeOffersAllowed: false),
        isNull,
      );
      final p = StoreOfferPolicy.apply(
        product(offer: offer),
        ios: false,
        storeOffersAllowed: true,
      );
      expect(p.freeTrial, const StorePeriod(2, StorePeriodUnit.week));
      final intro = StoreOfferPolicy.apply(
        product(offer: const StoreIntroOffer(period: monthly, introPrice: r'$0.99', cycles: 3)),
        ios: false,
        storeOffersAllowed: true,
      );
      expect(intro.freeTrial, isNull, reason: 'chegirma — bepul sinov emas');
      expect(intro.introOffer?.introPrice, r'$0.99');
      expect(intro.introOffer?.total, const StorePeriod(3, StorePeriodUnit.month));
    });

    test('servis: offeredProducts siyosatni qo‘llaydi; server sinovi ishlatilgan '
        '— “do‘kon taklifi” izohi', () async {
      shop.products = [product(offer: const StoreIntroOffer(period: week))];
      final ios = make(FakeEntitlementSource());
      expect(ios.offeredProducts.single.freeTrial, week);
      expect(ios.storeOfferAfterServerTrial, isFalse);
      final play = make(FakeEntitlementSource(platform: 'play_store'));
      expect(play.offeredProducts.single.introOffer, isNull);
      // Eski soxta mahsulot (introOffer yo'q, faqat freeTrial) — taklif yo'q.
      shop.products = storeProducts();
      expect(ios.offeredProducts.every((p) => p.freeTrial == null), isTrue);

      final src = FakeEntitlementSource()
        ..snapshot = EntitlementSnapshot(serverTime: _t0, items: const [], trialUsed: true);
      final used = make(src);
      await used.start();
      expect(used.storeOfferAfterServerTrial, isTrue);
    });
  });

  group('server javobi: yangi maydonlar', () {
    test('period_type / auto_renew / pending_product_id / store_guest', () {
      final e = ServerEntitlement.fromJson({
        'product_id': BillingCatalog.premiumYearly,
        'platform': 'play_store',
        'status': 'active',
        'source': 'store_guest',
        'period_type': 'trial',
        'auto_renew': false,
        'pending_product_id': BillingCatalog.studentYearly,
        'expires_at': '2027-01-01T00:00:00.000Z',
      });
      expect(e.periodType, StorePeriodType.trial);
      expect(e.autoRenew, isFalse);
      expect(e.pendingProductId, BillingCatalog.studentYearly);
      expect(e.isGuest, isTrue);
      expect(e.isStore, isTrue);
      expect(e.tier.allows(ProCapability.teacherPanel), isFalse);
      expect(e.tier.allows(ProCapability.lab), isTrue);
      final round = ServerEntitlement.fromJson(e.toJson());
      expect(round.periodType, StorePeriodType.trial);
      expect(round.autoRenew, isFalse);
      // Eski javob — standart qiymatlar.
      final legacy = ServerEntitlement.fromJson({
        'product_id': BillingCatalog.studentMonthly,
        'platform': 'app_store',
        'status': 'active',
      });
      expect(legacy.periodType, StorePeriodType.normal);
      expect(legacy.autoRenew, isNull);
      final snap = EntitlementSnapshot.fromJson({
        'server_time': '2026-10-25T09:00:00.000Z',
        'items': <Object>[],
        'guest_tokens': ['g1.x.y', 5],
        'sign_in_required': true,
      });
      expect(snap.guestTokens, ['g1.x.y']);
      expect(snap.signInRequired, isTrue);
    });

    test('DeviceAttestation.toJson: device_id faqat bo‘lsa', () {
      expect(
        const DeviceAttestation(platform: 'android', token: 't').toJson('n'),
        {'platform': 'android', 'token': 't', 'nonce': 'n'},
      );
    });
  });

  group('CloudflareEntitlementSource: mehmon yo‘llari', () {
    test('probe → guest siyosati; verify/refresh — sessiyasiz, link — sessiya bilan', () async {
      final calls = <http.Request>[];
      final backend = CloudflareLabBackend(
        const ApiConfig(url: 'https://api.test'),
        sessionStore: _NoSessions(),
        httpClient: MockClient((r) async {
          calls.add(r);
          final body = r.url.path == '/v1/billing/status'
              ? {
                  'app_store': false,
                  'play_store': true,
                  'trial': {'android': false, 'ios': false},
                  'guest': {
                    'purchase_plans': ['student', 'specialist'],
                    'account_only_capabilities': ['teacher_panel'],
                    'max_devices': 5,
                  },
                }
              : {
                  'server_time': '2026-10-25T09:00:00.000Z',
                  'items': [
                    {
                      'product_id': BillingCatalog.specialistMonthly,
                      'platform': 'play_store',
                      'source': 'store_guest',
                      'status': 'active',
                      'expires_at': '2026-11-25T09:00:00.000Z',
                    },
                  ],
                  'guest_tokens': ['g1.p.s'],
                };
          return http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json'});
        }),
      );
      final src = CloudflareEntitlementSource(backend, platform: 'play_store');
      await src.probe();
      expect(src.guestPolicy?.purchasePlans, {ProPlan.student, ProPlan.specialist});
      final snap = await src.guestVerify(
        const [_playProof],
        deviceId: 'guest-dev-1',
        restore: true,
      );
      expect(snap.guestTokens, ['g1.p.s']);
      expect(snap.items.single.isGuest, isTrue);
      final req = calls.last;
      expect(req.url.path, '/v1/billing/guest/verify');
      expect(req.headers['authorization'], isNull);
      expect(jsonDecode(req.body), {
        'platform': 'play_store',
        'device_id': 'guest-dev-1',
        'restore': true,
        'purchases': [
          {'product_id': BillingCatalog.specialistMonthly, 'token': _playProof.token},
        ],
      });
      await src.guestRefresh(deviceId: 'guest-dev-1', tokens: const ['g1.p.s']);
      expect(calls.last.url.path, '/v1/billing/guest/entitlements');
      expect(jsonDecode(calls.last.body), {
        'device_id': 'guest-dev-1',
        'guest_tokens': ['g1.p.s'],
      });
    });
  });
}
