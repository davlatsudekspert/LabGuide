// D-75 ilova tomoni: oflayn chegarasi (server offline_until, hech qachon
// uzaytirilmaydi, yopilganda bepulga qaytadi), ilova qayta ochilganda
// yangilash, Play base plan → kanonik id, sinov platforma ruxsati, soxta
// (debug) xarid oqimi, darajani lokal rol bilan almashtirib bo'lmasligi.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/debug_fake_purchases.dart';
import 'package:labguide/core/entitlements/entitlement_cache.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/entitlement_service.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/core/entitlements/plan_matrix.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/core/storage/kv_store.dart';

import '../helpers/billing_fakes.dart';

final _t0 = DateTime.utc(2026, 10, 24, 12);

ServerEntitlement _store(String product, {required DateTime end}) =>
    ServerEntitlement(
      productId: product,
      platform: 'play_store',
      status: EntitlementStatus.active,
      startedAt: _t0.subtract(const Duration(days: 1)),
      expiresAt: end,
    );

void main() {
  late DateTime now;
  late FakeEntitlementSource src;
  late FakePurchaseAdapter shop;

  setUp(() {
    now = _t0;
    src = FakeEntitlementSource(platform: 'play_store');
    shop = FakePurchaseAdapter();
  });

  EntitlementService make({Set<Feature>? gated}) => EntitlementService(
    source: src,
    cache: EntitlementCacheStore(
      MemoryKeyValueStore(),
      MemoryEntitlementKeyStore(),
    ),
    allFeaturesOpen: false,
    purchases: shop,
    clock: () => now,
    gated: gated ?? ProGatePolicy.gated,
  );

  group('oflayn (D-75)', () {
    test('kesh chegarasi = min(7 kun, server offline_until); oflaynda '
        'uzaytirilmaydi', () async {
      final ent = make();
      src.snapshot = EntitlementSnapshot(
        serverTime: _t0,
        items: [
          _store(
            BillingCatalog.studentYearly,
            end: _t0.add(const Duration(days: 300)),
          ),
        ],
        offlineUntil: _t0.add(const Duration(days: 2)),
      );
      await ent.refresh(reprobe: false);
      expect(ent.cached!.validUntil, _t0.add(const Duration(days: 2)));
      expect(ent.plan, ProPlan.student);
      // Internet yo'q: 3 kundan keyin kesh huquq bermaydi (bepulga qaytadi).
      src.error = Exception('offline');
      now = _t0.add(const Duration(days: 3));
      await ent.refresh(reprobe: false);
      expect(ent.activeEntitlement, isNull);
      expect(ent.proSource, ProSource.none);
      // Bepul imkoniyatlar hech qachon yopilmaydi (gated bo'sh).
      for (final f in Feature.values) {
        expect(ent.can(f), isTrue, reason: f.name);
      }
    });

    test('server offline_until bermasa — lokal 7 kun', () async {
      final ent = make();
      src.snapshot = EntitlementSnapshot(
        serverTime: _t0,
        items: [
          _store(
            BillingCatalog.studentYearly,
            end: _t0.add(const Duration(days: 300)),
          ),
        ],
      );
      await ent.refresh(reprobe: false);
      expect(ent.cached!.validUntil, _t0.add(const Duration(days: 7)));
    });

    test(
      'soat orqaga surilsa kesh ishlamaydi (huquq uzaytirilmaydi)',
      () async {
        final ent = make();
        src.snapshot = EntitlementSnapshot(
          serverTime: _t0,
          items: [
            _store(
              BillingCatalog.teacherMonthly,
              end: _t0.add(const Duration(days: 20)),
            ),
          ],
        );
        await ent.refresh(reprobe: false);
        expect(ent.plan, ProPlan.teacher);
        now = _t0.subtract(const Duration(days: 1));
        expect(ent.activeEntitlement, isNull);
      },
    );
  });

  group('sinxronlash (D-75)', () {
    test('ilova qayta ochilganda yangilaydi, 5 daqiqada bir martadan ko‘p '
        'emas', () async {
      final ent = make();
      var fetches = 0;
      src.snapshot = EntitlementSnapshot(serverTime: _t0, items: const []);
      ent.addListener(() => fetches++);
      await ent.onResume();
      final first = fetches;
      expect(first, greaterThan(0));
      now = _t0.add(const Duration(minutes: 2));
      await ent.onResume();
      expect(fetches, first);
      // Boshqa qurilmada sotib olindi — keyingi qaytishda ko'rinadi.
      src.snapshot = EntitlementSnapshot(
        serverTime: _t0,
        items: [
          _store(
            BillingCatalog.specialistMonthly,
            end: _t0.add(const Duration(days: 30)),
          ),
        ],
      );
      now = _t0.add(const Duration(minutes: 6));
      await ent.onResume();
      expect(ent.plan, ProPlan.specialist);
    });

    test(
      'ziddiyat: yuqori daraja, keyin uzoq muddat (do‘kon, admin, sinov)',
      () async {
        final ent = make();
        src.snapshot = EntitlementSnapshot.fromJson({
          'server_time': _t0.toIso8601String(),
          'items': [
            {
              'product_id': BillingCatalog.studentYearly,
              'platform': 'play_store',
              'status': 'active',
              'expires_at': _t0
                  .add(const Duration(days: 300))
                  .toIso8601String(),
            },
            {
              'product_id': 'admin_grant.teacher',
              'platform': 'admin_grant',
              'source': 'admin_grant',
              'plan': 'teacher',
              'status': 'active',
              'expires_at': _t0.add(const Duration(days: 10)).toIso8601String(),
            },
          ],
        });
        await ent.refresh(reprobe: false);
        expect(ent.plan, ProPlan.teacher);
        expect(ent.proSource, ProSource.adminGrant);
      },
    );
  });

  group('mahsulot id lari (D-75)', () {
    test('Play obuna + base plan → kanonik id; noma’lum — null', () {
      expect(
        BillingCatalog.canonical('uz.labguide.student', basePlanId: 'yearly'),
        BillingCatalog.studentYearly,
      );
      expect(
        BillingCatalog.canonical('uz.labguide.teacher', basePlanId: 'monthly'),
        BillingCatalog.teacherMonthly,
      );
      expect(
        BillingCatalog.canonical('uz.labguide.teacher', basePlanId: 'weekly'),
        isNull,
      );
      expect(
        BillingCatalog.canonical('uz.labguide.pro.monthly'),
        BillingCatalog.specialistMonthly,
      );
      expect(
        BillingCatalog.planOf('uz.labguide.specialist'),
        ProPlan.specialist,
      );
      expect(
        BillingCatalog.storeQueryIds,
        containsAll([...BillingCatalog.ids, 'uz.labguide.student']),
      );
    });

    test('do‘kon sinov taklifi ko‘rsatilmaydi (ikki marta sinov yo‘q)', () {
      final ent = make();
      expect(shop.products.any((p) => p.freeTrial != null), isTrue);
      expect(ent.offeredProducts.every((p) => p.freeTrial == null), isTrue);
    });
  });

  group('daraja huquqi (D-74/D-75)', () {
    test('Talaba rejasi ustoz paneli toifasini ochmaydi; lokal rol hech '
        'narsa o‘zgartirmaydi (qaror faqat server qatoridan)', () async {
      final ent = make(gated: {Feature.teacherTestBuilder, Feature.examSimulation});
      src.snapshot = EntitlementSnapshot(
        serverTime: _t0,
        items: [
          _store(
            BillingCatalog.studentMonthly,
            end: _t0.add(const Duration(days: 20)),
          ),
        ],
      );
      await ent.refresh(reprobe: false);
      expect(ent.plan, ProPlan.student);
      expect(
        PlanMatrix.allows(ProPlan.student, ProCapability.teacherPanel),
        isFalse,
      );
      // `EntitlementService` hech qanday rol qabul qilmaydi — rolni
      // almashtirish uchun API yo'q; daraja faqat server qatoridan.
      expect(ent.tier.allows(ProCapability.teacherPanel), isFalse);
      expect(ent.tier.allows(ProCapability.lab), isFalse);
    });
  });

  group('soxta (debug) xarid oqimi', () {
    test(
      'debug buildda: xarid → soxta server → Pro (sandbox); sinov bir marta',
      () async {
        final fakeSrc = DebugFakeEntitlementSource(src);
        final fakeShop = DebugFakePurchaseAdapter(platform: 'play_store');
        final ent = EntitlementService(
          source: fakeSrc,
          cache: EntitlementCacheStore(
            MemoryKeyValueStore(),
            MemoryEntitlementKeyStore(),
          ),
          allFeaturesOpen: false,
          purchases: fakeShop,
          attestor: DebugFakeDeviceAttestor(),
        );
        await ent.start();
        expect(ent.purchasesEnabled, isTrue);
        // Narxlar katalogdan (yagona manba).
        expect(
          fakeShop.loaded.map((p) => p.displayPrice),
          containsAll([
            r'$1.49',
            r'$9.99',
            r'$2.49',
            r'$24.99',
            r'$3.49',
            r'$34.99',
            r'$4.99',
            r'$49.99',
          ]),
        );
        expect(ent.trialAvailable, isTrue);
        expect(
          await ent.startTrial(plan: ProPlan.student, email: 'a@b.uz'),
          TrialOutcome.success,
        );
        expect(ent.proSource, ProSource.trial);
        expect(
          await ent.purchase(BillingCatalog.teacherYearly),
          BillingOutcome.success,
        );
        expect(ent.plan, ProPlan.teacher);
        expect(ent.activeEntitlement!.environment, 'sandbox');
      },
    );
  });
}
