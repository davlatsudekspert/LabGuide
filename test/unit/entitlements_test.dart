import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labguide/core/backend/cloudflare_backend.dart';
import 'package:labguide/core/backend/supabase_backend.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/entitlement_cache.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/entitlement_service.dart';
import 'package:labguide/core/entitlements/entitlement_source.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/core/entitlements/purchase_adapter.dart';
import 'package:labguide/core/storage/kv_store.dart';

import '../helpers/billing_fakes.dart';

final _t0 = DateTime.utc(2026, 10, 9, 12);

ServerEntitlement _sub({
  EntitlementStatus status = EntitlementStatus.active,
  DateTime? start,
  DateTime? end,
  String product = BillingCatalog.specialistMonthly,
}) => ServerEntitlement(
  productId: product,
  platform: 'app_store',
  status: status,
  startedAt: start ?? _t0.subtract(const Duration(days: 3)),
  expiresAt: end ?? _t0.add(const Duration(days: 27)),
);

EntitlementSnapshot _snap(List<ServerEntitlement> items, [DateTime? at]) =>
    EntitlementSnapshot(serverTime: at ?? _t0, items: items);

const _proof = PurchaseProof(
  platform: 'app_store',
  productId: BillingCatalog.specialistMonthly,
  token: '2000000123',
);

/// Xotiradagi sessiya (Cloudflare backend testi uchun).
class _MemorySessions implements SessionStore {
  String? value;
  @override
  Future<void> delete() async => value = null;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async => value = v;
}

void main() {
  late MemoryKeyValueStore store;
  late MemoryEntitlementKeyStore keys;
  late FakeEntitlementSource source;
  late FakePurchaseAdapter shop;
  late DateTime now;

  /// Standart: do'kon buildi, to'lov YOQILGAN (soxta do'kon + server).
  EntitlementService make({bool open = false, PurchaseAdapter? purchases}) =>
      EntitlementService(
        source: source,
        cache: EntitlementCacheStore(store, keys),
        allFeaturesOpen: open,
        // Eski reja: hamma Pro imkoniyat yopiladi (mexanizm sinovi). Haqiqiy
        // standart ro'yxat bo'sh (D-71) — pastdagi alohida testlarda.
        gated: {
          for (final f in Feature.values)
            if (f.pro) f,
        },
        purchases: purchases ?? shop,
        clock: () => now,
      );

  setUp(() {
    store = MemoryKeyValueStore();
    keys = MemoryEntitlementKeyStore();
    source = FakeEntitlementSource();
    shop = FakePurchaseAdapter();
    now = _t0;
  });

  // Tarix: n natija, eng yangisi birinchi, har biri bir kun oldin.
  List<DateTime> history(int n, {DateTime? from}) => [
    for (var i = 0; i < n; i++) (from ?? _t0).subtract(Duration(days: i)),
  ];

  group('build rejimi (TestFlight/debug)', () {
    test('hamma imkoniyat ochiq, server bo‘lmasa ham', () {
      source.user = null;
      final s = make(open: true);
      expect(s.proSource, ProSource.buildOpen);
      expect(s.tier, ProTier.all);
      for (final f in Feature.values) {
        expect(s.can(f), isTrue, reason: f.name);
      }
      expect(s.historyVisibleLimit(), isNull);
      final v = s.historyView(history(10), (d) => d);
      expect(v.visible, hasLength(10));
      expect(v.hiddenCount, 0);
      expect(s.gatingActive, isFalse);
    });

    test('LG_ALL_FEATURES_OPEN standart qiymati — false (do‘kon build)', () {
      expect(EntitlementService.buildAllFeaturesOpen, isFalse);
    });
  });

  group('to‘lov yoqilmagan do‘kon build — hammasi ochiq (App Store 2.1)', () {
    void allOpen(EntitlementService s) {
      expect(s.purchasesEnabled, isFalse);
      expect(s.gatingActive, isFalse);
      for (final f in Feature.values) {
        expect(s.can(f), isTrue, reason: f.name);
      }
      expect(s.historyVisibleLimit(), isNull);
      final v = s.historyView(history(9), (d) => d);
      expect(v.visible, hasLength(9));
      expect(v.hiddenCount, 0);
    }

    test('do‘kon ulanmagan (UnavailablePurchaseAdapter)', () {
      allOpen(make(purchases: UnavailablePurchaseAdapter()));
    });

    test('do‘konda mahsulot yo‘q (hali yaratilmagan)', () {
      shop.products = const [];
      allOpen(make());
    });

    test('server kalitlari sozlanmagan (billing/status: false)', () {
      source.billing = false;
      allOpen(make());
    });

    test('mahsulotlar keyin yuklansa — gating shundan keyin yoqiladi', () {
      shop.available = false;
      final s = make();
      var notified = 0;
      s.addListener(() => notified++);
      expect(s.can(Feature.examSimulation), isTrue);
      shop.setAvailable(true);
      expect(notified, greaterThan(0));
      expect(s.gatingActive, isTrue);
      expect(s.can(Feature.examSimulation), isFalse);
    });

    test('xarid va tiklash — unavailable, do‘kon oynasi ochilmaydi', () async {
      source.billing = false;
      final s = make();
      expect(
        await s.purchase(BillingCatalog.specialistMonthly),
        BillingOutcome.unavailable,
      );
      expect(await s.restore(), BillingOutcome.unavailable);
      expect(shop.bought, isEmpty);
    });
  });

  group('bepul rejim (to‘lov yoqilgan)', () {
    test('D-53: bepul imkoniyatlar ochiq; Pro, ustoz paneli va Lab yopiq', () {
      final s = make();
      expect(s.gatingActive, isTrue);
      expect(s.isPro, isFalse);
      for (final f in [
        Feature.basicGuides,
        Feature.dailyQuestions,
        Feature.mistakeReview,
      ]) {
        expect(s.can(f), isTrue, reason: f.name);
      }
      for (final f in Feature.values.where((f) => f.pro)) {
        expect(s.can(f), isFalse, reason: f.name);
      }
    });

    test('tarixda oxirgi 3 natija; eskilari o‘chmaydi, soni aytiladi', () {
      final s = make();
      expect(s.historyVisibleLimit(), 3);
      final all = history(7);
      final v = s.historyView(all, (d) => d);
      expect(v.visible, all.take(3).toList());
      expect(v.hiddenCount, 4);
      expect(all, hasLength(7));
    });

    test('3 tadan kam bo‘lsa hammasi ko‘rinadi', () {
      final v = make().historyView(history(2), (d) => d);
      expect(v.visible, hasLength(2));
      expect(v.hiddenCount, 0);
    });

    test('to‘lov oynasida talaba mahsuloti ko‘rsatilmaydi (tasdiq yo‘q)', () {
      final ids = make().offeredProducts.map((p) => p.id);
      expect(ids, isNot(contains(BillingCatalog.studentMonthly)));
      expect(ids, contains(BillingCatalog.specialistMonthly));
      expect(ids, contains(BillingCatalog.teacherMonthly));
    });
  });

  group('server tasdiqlagan obuna', () {
    test(
      'faol Pro: Pro ochiq, Ustoz Pro yopiq; imzolangan keshga yoziladi',
      () async {
        source.snapshot = _snap([_sub(product: BillingCatalog.studentMonthly)]);
        final s = make();
        await s.refresh();
        expect(s.proSource, ProSource.server);
        expect(s.tier, ProPlan.student.tier);
        expect(s.can(Feature.examSimulation), isTrue);
        expect(s.can(Feature.fullToifaBank), isTrue);
        expect(s.can(Feature.groups), isFalse);
        expect(s.can(Feature.leukocyteCounter), isFalse, reason: 'Lab yo‘q');
        expect(s.historyVisibleLimit(), isNull);
        expect(store.getString(StoreKeys.entitlementsCache), isNotNull);
      },
    );

    // D-76 matritsasi: har reja faqat o'z to'plamini ochadi.
    for (final (plan, product) in [
      (ProPlan.teacher, BillingCatalog.teacherYearly),
      (ProPlan.specialist, BillingCatalog.specialistMonthly),
      (ProPlan.premium, BillingCatalog.premiumYearly),
    ]) {
      test('${plan.name} rejasi: faqat o‘z imkoniyatlari (D-76)', () async {
        source.snapshot = _snap([_sub(product: product)]);
        final s = make();
        await s.refresh();
        expect(s.plan, plan);
        expect(s.tier, plan.tier);
        for (final f in Feature.values) {
          expect(
            s.can(f),
            f.capability == null || plan.tier.allows(f.capability),
            reason: '${plan.name} × ${f.name}',
          );
        }
      });
    }

    test(
      'Ustoz: Lab yopiq; Mutaxassis: ustoz paneli yopiq; Premium: hammasi',
      () async {
        source.snapshot = _snap([_sub(product: BillingCatalog.teacherMonthly)]);
        final s = make();
        await s.refresh();
        expect(s.can(Feature.groups), isTrue);
        expect(s.can(Feature.leukocyteCounter), isFalse);
        expect(s.can(Feature.calibration), isFalse);
        source.snapshot = _snap([
          _sub(product: BillingCatalog.specialistMonthly),
        ]);
        await s.refresh();
        expect(s.can(Feature.leukocyteCounter), isTrue);
        expect(s.can(Feature.qualityControl), isTrue);
        expect(s.can(Feature.groups), isFalse);
        expect(s.can(Feature.assignments), isFalse);
        source.snapshot = _snap([_sub(product: BillingCatalog.premiumMonthly)]);
        await s.refresh();
        for (final f in Feature.values) {
          expect(s.can(f), isTrue, reason: f.name);
        }
      },
    );

    test('Ustoz obunasi + Mutaxassis admin granti — birlashma (server bilan bir xil)', () async {
      source.snapshot = _snap([
        _sub(product: BillingCatalog.teacherMonthly),
        ServerEntitlement(
          productId: 'admin_grant.specialist',
          platform: 'admin_grant',
          status: EntitlementStatus.active,
          startedAt: _t0.subtract(const Duration(days: 1)),
          expiresAt: _t0.add(const Duration(days: 10)),
          source: ServerEntitlement.adminGrantSource,
          plan: ProPlan.specialist,
        ),
      ]);
      final s = make();
      await s.refresh();
      expect(s.tier, ProPlan.premium.tier);
      expect(s.can(Feature.groups), isTrue);
      expect(s.can(Feature.leukocyteCounter), isTrue);
    });

    test('katalogda yo‘q mahsulot — faqat Talaba to‘plami (ustoz paneli va Lab emas)', () async {
      source.snapshot = _snap([_sub(product: 'labguide.pro.monthly')]);
      final s = make();
      await s.refresh();
      expect(s.tier, ProPlan.student.tier);
      expect(s.can(Feature.labInstruments), isFalse);
    });

    test('imtiyoz davri (grace) Pro beradi, billing retry bermaydi', () async {
      source.snapshot = _snap([_sub(status: EntitlementStatus.gracePeriod)]);
      final s = make();
      await s.refresh();
      expect(s.isPro, isTrue);
      source.snapshot = _snap([_sub(status: EntitlementStatus.billingRetry)]);
      await s.refresh();
      expect(s.isPro, isFalse);
    });

    test('qaytarilgan (refund) xarid Pro bermaydi', () async {
      source.snapshot = _snap([_sub(status: EntitlementStatus.revoked)]);
      final s = make();
      await s.refresh();
      expect(s.isPro, isFalse);
      expect(s.proPeriods, isEmpty);
    });

    test('obuna tugagach Pro davrida saqlangan natijalar ko‘rinadi', () async {
      final start = _t0.subtract(const Duration(days: 30));
      final end = _t0.subtract(const Duration(days: 10));
      source.snapshot = _snap([
        _sub(status: EntitlementStatus.expired, start: start, end: end),
      ]);
      final s = make();
      await s.refresh();
      expect(s.isPro, isFalse);
      expect(
        s.can(Feature.examSimulation),
        isFalse,
        reason: 'yangi Pro amal yopiq',
      );

      final all = history(41);
      final v = s.historyView(all, (d) => d);
      final inPro = all.where((d) => !d.isBefore(start) && !d.isAfter(end));
      expect(inPro, hasLength(21));
      expect(v.visible, containsAll(all.take(3)));
      expect(v.visible, containsAll(inPro));
      expect(v.visible, hasLength(3 + 21));
      expect(v.hiddenCount, all.length - 24);
    });

    test('server Pro bermasa — keshdagi eski Pro ham yo‘qoladi', () async {
      source.snapshot = _snap([_sub()]);
      final s = make();
      await s.refresh();
      expect(s.isPro, isTrue);
      source.snapshot = _snap([]);
      await s.refresh();
      expect(s.isPro, isFalse);
    });

    test('hisobdan chiqilganda xotiradagi Pro tozalanadi', () async {
      source.snapshot = _snap([_sub()]);
      final s = make();
      await s.refresh();
      source.user = null;
      await s.refresh();
      expect(s.isPro, isFalse);
    });
  });

  group('oflayn kesh', () {
    Future<void> seed() async {
      source.snapshot = _snap([_sub(end: _t0.add(const Duration(days: 30)))]);
      await make().refresh();
    }

    test('internetsiz: kesh muddati (7 kun) tugaguncha Pro ishlaydi', () async {
      await seed();
      source.error = const EntitlementException(EntitlementFailure.network);
      now = _t0.add(const Duration(days: 6, hours: 23));
      final s = make();
      await s.load();
      await s.refresh();
      expect(s.proSource, ProSource.offlineCache);
      expect(s.can(Feature.unlimitedHistory), isTrue);

      now = _t0.add(const Duration(days: 7, minutes: 1));
      expect(s.isPro, isFalse, reason: 'oflayn muddat tugadi');
      expect(s.proPeriods, isNotEmpty, reason: 'davrlar tarix uchun qoladi');
    });

    test('kesh ichida obunaning o‘z muddati tugasa — Pro yo‘q', () async {
      source.snapshot = _snap([_sub(end: _t0.add(const Duration(days: 2)))]);
      await make().refresh();
      now = _t0.add(const Duration(days: 3));
      final s = make();
      await s.load();
      expect(s.isPro, isFalse);
    });

    test('soat orqaga surilsa kesh Pro bermaydi', () async {
      await seed();
      now = _t0.subtract(const Duration(days: 1));
      final s = make();
      await s.load();
      expect(s.isPro, isFalse);
    });

    test('qo‘lda o‘zgartirilgan kesh e‘tiborsiz (imzo)', () async {
      source.snapshot = _snap([_sub(status: EntitlementStatus.expired)]);
      await make().refresh();
      final outer = (jsonDecode(
        store.getString(StoreKeys.entitlementsCache)!,
      ) as Map).cast<String, Object?>();
      final tampered = (outer['payload']! as String).replaceAll(
        '"expired"',
        '"active"',
      );
      await store.setString(
        StoreKeys.entitlementsCache,
        jsonEncode({'payload': tampered, 'sig': outer['sig']}),
      );
      final s = make();
      await s.load();
      expect(s.isPro, isFalse);
      expect(s.cached, isNull);
    });

    test('boshqa kalit bilan imzolangan kesh qabul qilinmaydi', () async {
      await seed();
      keys = MemoryEntitlementKeyStore(List.filled(32, 9));
      final s = make();
      await s.load();
      expect(s.cached, isNull);
      expect(s.isPro, isFalse);
    });

    test('kesh boshqa hisobga o‘tmaydi', () async {
      await seed();
      source.user = 'user-b';
      final s = make();
      await s.load();
      expect(s.isPro, isFalse);
    });

    test('lokal sozlamaning o‘zi Pro bermaydi (imzosiz yozuv)', () async {
      await store.setString(
        StoreKeys.entitlementsCache,
        jsonEncode({'payload': '{"user":"user-a"}', 'sig': 'x'}),
      );
      final s = make();
      await s.load();
      expect(s.isPro, isFalse);
    });
  });

  group('xarid va tiklash', () {
    test('xarid: server tekshiradi, keyin tranzaksiya yakunlanadi', () async {
      source.user = '0F8FAD5B-D9CB-469F-A165-70867728950E';
      shop.proofs = const [_proof];
      source.snapshot = _snap([_sub()]);
      final s = make();
      expect(
        await s.purchase(BillingCatalog.specialistMonthly),
        BillingOutcome.success,
      );
      expect(source.verified, [_proof]);
      expect(source.verifiedRestore, isFalse);
      expect(shop.finished, [_proof]);
      // App Store appAccountToken — hisob UUID'i (kichik harf).
      expect(shop.bought.single, (
        BillingCatalog.specialistMonthly,
        '0f8fad5b-d9cb-469f-a165-70867728950e',
      ));
      expect(s.isPro, isTrue);
    });

    test('Play: obfuscatedAccountId — hisob id sining SHA-256 xeshi', () async {
      source = FakeEntitlementSource(platform: 'play_store');
      shop.proofs = const [_proof];
      source.snapshot = _snap([_sub()]);
      await make().purchase(BillingCatalog.specialistMonthly);
      expect(
        shop.bought.single.$2,
        sha256.convert(utf8.encode('user-a')).toString(),
      );
    });

    test(
      'server xatosi: tranzaksiya yakunlanmaydi (do‘kon qayta beradi)',
      () async {
        shop.proofs = const [_proof];
        source.error = const EntitlementException(EntitlementFailure.network);
        final s = make();
        expect(
          await s.purchase(BillingCatalog.specialistMonthly),
          BillingOutcome.failed,
        );
        expect(shop.finished, isEmpty);
        expect(s.isPro, isFalse);
      },
    );

    test('bekor qilish va kutilayotgan to‘lov', () async {
      final s = make();
      shop.cancel = true;
      expect(
        await s.purchase(BillingCatalog.specialistMonthly),
        BillingOutcome.cancelled,
      );
      shop
        ..cancel = false
        ..buyError = const PurchasePendingException();
      expect(
        await s.purchase(BillingCatalog.specialistMonthly),
        BillingOutcome.pending,
      );
      shop.buyError = const PurchaseFailedException('declined');
      expect(
        await s.purchase(BillingCatalog.specialistMonthly),
        BillingOutcome.failed,
      );
      shop.buyError = null;
      shop.proofs = const [_proof];
      source.error = const EntitlementException(EntitlementFailure.pending);
      expect(
        await s.purchase(BillingCatalog.specialistMonthly),
        BillingOutcome.pending,
      );
      expect(s.isPro, isFalse);
    });

    test('tiklash: server tekshiradi va Pro beradi', () async {
      shop.proofs = const [_proof];
      source.snapshot = _snap([_sub()]);
      final s = make();
      expect(await s.restore(), BillingOutcome.success);
      expect(source.verified, [_proof]);
      expect(source.verifiedRestore, isTrue);
      expect(s.isPro, isTrue);
    });

    test('tiklash: do‘konda hech narsa yo‘q', () async {
      expect(await make().restore(), BillingOutcome.nothingFound);
    });

    test('tiklash: xarid boshqa hisobda', () async {
      source.snapshot = EntitlementSnapshot(
        serverTime: _t0,
        items: const [],
        ownedByOther: true,
      );
      shop.proofs = const [_proof];
      final s = make();
      expect(await s.restore(), BillingOutcome.ownedByOther);
      expect(s.isPro, isFalse);
    });

    test('server sozlanmagan (503) — unavailable', () async {
      source.error = const EntitlementException(
        EntitlementFailure.notConfigured,
      );
      shop.proofs = const [_proof];
      expect(await make().restore(), BillingOutcome.unavailable);
    });

    // D-76 (egasi qarori): mehmon xarid qilmaydi va sinov olmaydi — avval
    // hisobga kirish. Mehmon rejimining bepul qismi o'zgarmaydi.
    test(
      'mehmon: xarid va tiklash — signInRequired, do‘kon oynasi ochilmaydi',
      () async {
        source.user = null;
        shop.proofs = const [_proof];
        final s = make();
        expect(
          await s.purchase(BillingCatalog.teacherMonthly),
          BillingOutcome.signInRequired,
        );
        expect(await s.restore(), BillingOutcome.signInRequired);
        expect(shop.bought, isEmpty, reason: 'do‘kon chaqirilmadi');
        expect(source.verified, isNull);
        expect(s.isPro, isFalse);
        expect(s.trialAvailable, isFalse);
        expect(s.trialBlock, TrialBlock.guest);
      },
    );

    test('mehmon: qurilmadagi do‘kon obunasi huquq bermaydi; hisobga '
        'kirilganda serverga bog‘lanadi', () async {
      source
        ..user = null
        ..snapshot = _snap([]);
      shop.proofs = const [_proof];
      final s = make();
      await s.start();
      expect(s.isPro, isFalse, reason: 'mehmon Pro olmaydi');
      expect(s.proSource, ProSource.none);
      expect(source.verified, isNull);
      // Hisobga kirildi — server hali bilmaydi, refresh tiklash sifatida yuboradi.
      source.user = 'user-a';
      await s.refresh();
      expect(source.verified?.single.token, _proof.token);
      expect(source.verifiedRestore, isTrue);
    });

    test('ilova ochilganda: probe → do‘kon → server → jim tiklash', () async {
      source.snapshot = _snap([]);
      shop.proofs = const [_proof];
      final s = make();
      await s.start();
      expect(source.probes, 1);
      expect(shop.inits, 1);
      // Server bilmagan, lekin do'konda bor obuna — bog'lanadi.
      expect(source.verified, [_proof]);
    });

    test(
      'do‘kon o‘zi yuborgan tranzaksiya: tekshiriladi va yakunlanadi',
      () async {
        source.snapshot = _snap([]);
        final s = make();
        await s.start();
        source.snapshot = _snap([_sub()]);
        shop.emit(_proof);
        await pumpEventQueue();
        expect(source.verified, [_proof]);
        expect(source.verifiedRestore, isFalse);
        expect(shop.finished, [_proof]);
        expect(s.isPro, isTrue);
      },
    );
  });

  group('katalog', () {
    test('id lar egasi tasdiqlagan ro‘yxat va server bilan bir xil', () {
      expect(BillingCatalog.ids, {
        'uz.labguide.student.monthly',
        'uz.labguide.student.yearly',
        'uz.labguide.teacher.monthly',
        'uz.labguide.teacher.yearly',
        'uz.labguide.specialist.monthly',
        'uz.labguide.specialist.yearly',
        'uz.labguide.premium.monthly',
        'uz.labguide.premium.yearly',
      });
      final server = File('cloudflare/src/billing.ts').readAsStringSync();
      final ids = RegExp(r"'(uz\.labguide\.[a-z.]+)': \{ plan: '(\w+)' \}")
          .allMatches(server)
          .map((m) => (m[1]!, m[2]!))
          .toSet();
      expect(ids, {
        for (final p in BillingCatalog.all) (p.id, p.plan.wire),
        // Eski id'lar serverda ALIAS (D-73).
        for (final e in BillingCatalog.legacyAliases.entries)
          (e.key, BillingCatalog.byId(e.value)!.plan.wire),
      });
    });

    test('Play billingPeriod (ISO 8601) o‘qiladi', () {
      expect(
        StorePeriod.parseIso('P7D'),
        const StorePeriod(7, StorePeriodUnit.day),
      );
      expect(
        StorePeriod.parseIso('P1M'),
        const StorePeriod(1, StorePeriodUnit.month),
      );
      expect(
        StorePeriod.parseIso('P1Y'),
        const StorePeriod(1, StorePeriodUnit.year),
      );
      expect(
        StorePeriod.parseIso('P2W'),
        const StorePeriod(2, StorePeriodUnit.week),
      );
      expect(StorePeriod.parseIso('bad'), isNull);
    });

    test('obunani boshqarish havolasi', () {
      expect(
        BillingLinks.manageSubscriptions(ios: true),
        'https://apps.apple.com/account/subscriptions',
      );
      expect(
        BillingLinks.manageSubscriptions(ios: false, productId: 'x'),
        'https://play.google.com/store/account/subscriptions?package=uz.labguide.app&sku=x',
      );
    });
  });

  group('CloudflareEntitlementSource', () {
    Future<(CloudflareEntitlementSource, List<http.Request>)> make2(
      http.Response Function(http.Request) handler, {
      bool signedIn = true,
    }) async {
      final calls = <http.Request>[];
      final sessions = _MemorySessions();
      if (signedIn) {
        sessions.value = jsonEncode({
          'token': 'a' * 43,
          'email': 'u@example.test',
          'user_id': 'user-a',
          'expires_at': '2099-01-01T00:00:00.000Z',
        });
      }
      final backend = CloudflareLabBackend(
        const ApiConfig(url: 'https://api.test'),
        sessionStore: sessions,
        httpClient: MockClient((r) async {
          calls.add(r);
          return handler(r);
        }),
      );
      await backend.restoreSession();
      return (
        CloudflareEntitlementSource(backend, platform: 'app_store'),
        calls,
      );
    }

    http.Response j(Object body, [int status = 200]) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

    test('status: faqat shu platforma sozlangan bo‘lsa billingReady', () async {
      final (src, calls) = await make2(
        (_) => j({'app_store': true, 'play_store': false}),
        signedIn: false,
      );
      expect(src.billingReady, isFalse);
      await src.probe();
      expect(src.billingReady, isTrue);
      expect(calls.single.url.path, '/v1/billing/status');
      expect(calls.single.headers['authorization'], isNull);

      final (play, _) = await make2(
        (_) => j({'app_store': true, 'play_store': false}),
        signedIn: false,
      );
      final p = CloudflareEntitlementSource(
        play.backend,
        platform: 'play_store',
      );
      await p.probe();
      expect(p.billingReady, isFalse);
    });

    test('internet yo‘q — to‘lov yoqilmaydi', () async {
      final (src, _) = await make2(
        (_) => throw const SocketException('offline'),
        signedIn: false,
      );
      await src.probe();
      expect(src.billingReady, isFalse);
    });

    test('verify: so‘rov tanasi va javob (owned_by_other)', () async {
      final (src, calls) = await make2(
        (_) => j({
          'server_time': '2026-10-09T12:00:00.000Z',
          'items': [
            {
              'product_id': BillingCatalog.specialistYearly,
              'platform': 'app_store',
              'status': 'active',
              'started_at': '2026-10-01T00:00:00.000Z',
              'expires_at': '2027-10-01T00:00:00.000Z',
              'ownership': 'purchased',
              'environment': 'sandbox',
            },
          ],
          'owned_by_other': true,
        }),
      );
      final snap = await src.verify(const [_proof], restore: false);
      expect(snap.items.single.productId, BillingCatalog.specialistYearly);
      expect(snap.ownedByOther, isTrue);
      final req = calls.single;
      expect(req.url.path, '/v1/billing/verify');
      expect(req.headers['authorization'], 'Bearer ${'a' * 43}');
      expect(jsonDecode(req.body), {
        'platform': 'app_store',
        'restore': false,
        'product_id': BillingCatalog.specialistMonthly,
        'token': '2000000123',
      });

      await src.verify(const [_proof, _proof], restore: true);
      expect((jsonDecode(calls.last.body) as Map)['purchases'], hasLength(2));
    });

    test('xatolar: 503 → notConfigured, 409 pending, 502 → network', () async {
      var reply = j({'error': 'not_configured'}, 503);
      final (src, _) = await make2((_) => reply);
      Future<EntitlementFailure?> failure() async {
        try {
          await src.fetch();
          return null;
        } on EntitlementException catch (e) {
          return e.failure;
        }
      }

      expect(await failure(), EntitlementFailure.notConfigured);
      reply = j({'error': 'purchase_pending'}, 409);
      expect(await failure(), EntitlementFailure.pending);
      reply = j({'error': 'store_unavailable'}, 502);
      expect(await failure(), EntitlementFailure.network);
    });

    test('hisobsiz — unauthorized (serverga so‘rov ketmaydi)', () async {
      final (src, calls) = await make2((_) => j({}), signedIn: false);
      await expectLater(
        src.fetch(),
        throwsA(
          isA<EntitlementException>().having(
            (e) => e.failure,
            'failure',
            EntitlementFailure.unauthorized,
          ),
        ),
      );
      expect(calls, isEmpty);
    });
  });

  test('server javobi (entitlements) o‘qiladi', () {
    final snap = EntitlementSnapshot.fromJson({
      'server_time': '2026-10-09T12:00:00+00:00',
      'items': [
        {
          'product_id': BillingCatalog.specialistYearly,
          'platform': 'play_store',
          'status': 'grace_period',
          'started_at': '2026-01-01T00:00:00+00:00',
          'expires_at': '2027-01-01T00:00:00+00:00',
          'ownership': 'purchased',
          'environment': 'sandbox',
          'updated_at': '2026-10-09T11:00:00+00:00',
        },
      ],
    });
    expect(snap.items.single.status, EntitlementStatus.gracePeriod);
    expect(snap.items.single.grantsAt(_t0), isTrue);
    expect(snap.items.single.environment, 'sandbox');
  });
}
