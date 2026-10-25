// Admin bergan Pro (D-73): server holatidagi `admin_grant` qatorini ilova
// tanishi, do'kon xaridini bosib o'tmasligi, muddat va bekor qilish.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/backend/pro_grants.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/entitlement_cache.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/entitlement_service.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/core/storage/kv_store.dart';

import '../helpers/billing_fakes.dart';

final _t0 = DateTime.utc(2026, 10, 24, 12);

Map<String, Object?> _grantJson({
  String plan = 'teacher',
  String status = 'active',
  DateTime? end,
}) => {
  'product_id': 'admin_grant.$plan',
  'platform': 'admin_grant',
  'source': 'admin_grant',
  'plan': plan,
  'status': status,
  'started_at': _t0.toIso8601String(),
  'expires_at': end?.toIso8601String(),
  'ownership': 'granted',
  'environment': 'production',
};

Map<String, Object?> _storeJson(String product, {DateTime? end}) => {
  'product_id': product,
  'platform': 'app_store',
  'source': 'store',
  'status': 'active',
  'started_at': _t0.toIso8601String(),
  'expires_at': end?.toIso8601String(),
  'ownership': 'purchased',
  'environment': 'production',
};

EntitlementSnapshot _snap(List<Map<String, Object?>> items) =>
    EntitlementSnapshot.fromJson({
      'server_time': _t0.toIso8601String(),
      'items': items,
    });

void main() {
  late FakeEntitlementSource source;
  late DateTime now;

  EntitlementService make() => EntitlementService(
    source: source,
    cache: EntitlementCacheStore(
      MemoryKeyValueStore(),
      MemoryEntitlementKeyStore(),
    ),
    allFeaturesOpen: false,
    gated: ProGatePolicy.catalog,
    purchases: FakePurchaseAdapter(),
    clock: () => now,
  );

  setUp(() {
    source = FakeEntitlementSource();
    now = _t0;
  });

  group('server javobini o‘qish', () {
    test('admin_grant qatori: manba, daraja, muddat', () {
      final e = _snap([_grantJson(end: _t0.add(const Duration(days: 30)))])
          .items
          .single;
      expect(e.isAdminGrant, isTrue);
      expect(e.source, 'admin_grant');
      expect(e.plan, ProPlan.teacher);
      expect(e.effectivePlan, ProPlan.teacher);
      expect(e.tier, ProPlan.teacher.tier);
      expect(e.grantsAt(_t0), isTrue);
      expect(e.grantsAt(_t0.add(const Duration(days: 31))), isFalse);
    });

    test('manba maydoni yo‘q eski javob: platform bo‘yicha aniqlanadi', () {
      final grant = ServerEntitlement.fromJson({
        'product_id': 'admin_grant.student',
        'platform': 'admin_grant',
        'status': 'active',
      });
      expect(grant.isAdminGrant, isTrue);
      final store = ServerEntitlement.fromJson({
        'product_id': BillingCatalog.studentMonthly,
        'platform': 'app_store',
        'status': 'active',
      });
      expect(store.isAdminGrant, isFalse);
      expect(store.effectivePlan, ProPlan.student);
    });

    test('toJson/fromJson kesh aylanishi manba va darajani saqlaydi', () {
      final e = _snap([_grantJson(plan: 'specialist')]).items.single;
      final back = ServerEntitlement.fromJson(e.toJson());
      expect(back.isAdminGrant, isTrue);
      expect(back.plan, ProPlan.specialist);
    });

    test('eski mahsulot id lari yangi darajaga o‘giriladi', () {
      expect(
        BillingCatalog.planOf('uz.labguide.pro.monthly'),
        ProPlan.specialist,
      );
      expect(
        BillingCatalog.planOf('uz.labguide.pro.student.yearly'),
        ProPlan.student,
      );
      expect(
        BillingCatalog.planOf('uz.labguide.teacherpro.monthly'),
        ProPlan.teacher,
      );
      expect(BillingCatalog.planOf('yo‘q.mahsulot'), isNull);
    });
  });

  group('xizmat (EntitlementService)', () {
    test(
      'faqat admin grant: Pro faol, manba adminGrant, daraja bo‘yicha',
      () async {
        source.snapshot = _snap([_grantJson(plan: 'student')]);
        final s = make();
        await s.refresh();
        expect(s.isPro, isTrue);
        expect(s.proSource, ProSource.adminGrant);
        expect(s.plan, ProPlan.student);
        expect(s.tier, ProPlan.student.tier);
        expect(s.activeEntitlement!.isAdminGrant, isTrue);
      },
    );

    test('muddati tugagan grant huquq bermaydi', () async {
      source.snapshot = _snap([
        _grantJson(end: _t0.add(const Duration(days: 30))),
      ]);
      final s = make();
      await s.refresh();
      expect(s.isPro, isTrue);
      now = _t0.add(const Duration(days: 31));
      expect(s.isPro, isFalse);
    });

    test('bekor qilingan grant (serverda qator yo‘q) darhol olinadi', () async {
      source.snapshot = _snap([_grantJson()]);
      final s = make();
      await s.refresh();
      expect(s.isPro, isTrue);
      source.snapshot = _snap([]);
      await s.refresh();
      expect(s.isPro, isFalse);
      expect(s.proSource, ProSource.none);
    });

    test('do‘kon obunasini bosib o‘tmaydi: yuqori daraja yutadi', () async {
      final end = _t0.add(const Duration(days: 20));
      source.snapshot = _snap([
        _storeJson(BillingCatalog.specialistMonthly, end: end),
        _grantJson(plan: 'student', end: _t0.add(const Duration(days: 365))),
      ]);
      final s = make();
      await s.refresh();
      expect(s.plan, ProPlan.specialist);
      expect(s.proSource, ProSource.server);
      expect(s.activeEntitlement!.isAdminGrant, isFalse);
    });

    test('teng darajada uzoqroq muddat; to‘liq tenglikda do‘kon', () async {
      source.snapshot = _snap([
        _storeJson(
          BillingCatalog.teacherMonthly,
          end: _t0.add(const Duration(days: 10)),
        ),
        _grantJson(end: _t0.add(const Duration(days: 40))),
      ]);
      final s = make();
      await s.refresh();
      expect(s.proSource, ProSource.adminGrant);

      final same = _t0.add(const Duration(days: 10));
      source.snapshot = _snap([
        _grantJson(end: same),
        _storeJson(BillingCatalog.teacherMonthly, end: same),
      ]);
      await s.refresh();
      expect(s.proSource, ProSource.server);
      expect(s.activeEntitlement!.isAdminGrant, isFalse);
    });

    test('muddatsiz grant (end yo‘q) eng uzoq hisoblanadi', () async {
      source.snapshot = _snap([
        _storeJson(
          BillingCatalog.teacherYearly,
          end: _t0.add(const Duration(days: 300)),
        ),
        _grantJson(),
      ]);
      final s = make();
      await s.refresh();
      expect(s.proSource, ProSource.adminGrant);
      expect(s.activeEntitlement!.expiresAt, isNull);
    });
  });

  group('klient modeli (ProGrant)', () {
    test('ro‘yxat qatori: kutilayotgan va faol', () {
      final pending = ProGrant.fromJson({
        'id': 'g1',
        'email_masked': 'ab***@example.com',
        'tier': 'specialist',
        'status': 'pending',
        'duration_days': 30,
        'starts_at': null,
        'expires_at': null,
        'note': 'konferensiya',
        'created_at': _t0.toIso8601String(),
      });
      expect(pending.pending, isTrue);
      expect(pending.plan, ProPlan.specialist);
      expect(pending.durationDays, 30);
      expect(pending.expiresAt, isNull);
      expect(pending.note, 'konferensiya');
      final active = ProGrant.fromJson({
        'id': 'g2',
        'email_masked': 'cd***@example.com',
        'tier': 'student',
        'status': 'active',
        'expires_at': _t0.add(const Duration(days: 90)).toIso8601String(),
      });
      expect(active.pending, isFalse);
      expect(active.expiresAt, _t0.add(const Duration(days: 90)));
      expect(active.durationDays, isNull);
    });

    test('natija: replaced / extended bayroqlari', () {
      final r = ProGrantResult.fromJson({
        'id': 'g3',
        'email_masked': 'ef***@example.com',
        'tier': 'teacher',
        'status': 'active',
        'replaced': true,
        'extended': false,
      });
      expect(r.replaced, isTrue);
      expect(r.extended, isFalse);
      expect(r.grant.plan, ProPlan.teacher);
    });

    test('muddatlar server bilan bir xil: 30/90/365/bekor qilinguncha', () {
      expect(proGrantDurations, [30, 90, 365, null]);
    });
  });
}
