// Bepul sinov (D-74) ilova tomoni: `trial` qatorini tanish, qolgan kunlar,
// pullik obunani bosib o'tmaslik, sinovni boshlash oqimi (soxta attestatsiya
// va soxta server), attestatsiya sozlanmagan — sinov yo'q.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/device_attestor.dart';
import 'package:labguide/core/entitlements/entitlement_cache.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/entitlement_service.dart';
import 'package:labguide/core/entitlements/entitlement_source.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/core/storage/kv_store.dart';

import '../helpers/billing_fakes.dart';

final _t0 = DateTime.utc(2026, 10, 24, 12);

Map<String, Object?> _trial({String plan = 'student', int days = 30}) => {
  'product_id': 'trial.$plan',
  'platform': 'trial',
  'source': 'trial',
  'plan': plan,
  'status': 'active',
  'started_at': _t0.toIso8601String(),
  'expires_at': _t0.add(Duration(days: days)).toIso8601String(),
  'ownership': 'trial',
  'environment': 'production',
};

Map<String, Object?> _store(String product) => {
  'product_id': product,
  'platform': 'app_store',
  'source': 'store',
  'status': 'active',
  'started_at': _t0.toIso8601String(),
  'expires_at': _t0.add(const Duration(days: 30)).toIso8601String(),
  'ownership': 'purchased',
  'environment': 'production',
};

EntitlementSnapshot _snap(
  List<Map<String, Object?>> items, {
  bool used = false,
  DateTime? at,
}) => EntitlementSnapshot.fromJson({
  'server_time': (at ?? _t0).toIso8601String(),
  'items': items,
  'trial_used': used,
});

class _TrialServer extends FakeEntitlementSource implements TrialSource {
  String? errorCode;
  Map<String, Object?>? last;

  @override
  Future<String> trialChallenge() async => 'n' * 43;

  @override
  Future<EntitlementSnapshot> startTrial({
    required ProPlan plan,
    required String email,
    required String nonce,
    required DeviceAttestation attestation,
  }) async {
    last = {'plan': plan.wire, 'email': email, ...attestation.toJson(nonce)};
    if (errorCode != null) {
      throw EntitlementException(EntitlementFailure.unknown, errorCode);
    }
    snapshot = _snap([_trial(plan: plan.wire)], used: true);
    return snapshot!;
  }
}

class _FakeAttestor implements DeviceAttestor {
  @override
  bool get available => true;
  @override
  Future<DeviceAttestation> attest(String nonce) async =>
      DeviceAttestation(platform: 'ios', token: 'fake:phone:$nonce');
}

void main() {
  late DateTime now;
  setUp(() => now = _t0);

  EntitlementService make(
    FakeEntitlementSource source, {
    DeviceAttestor attestor = const UnconfiguredDeviceAttestor(),
  }) => EntitlementService(
    source: source,
    cache: EntitlementCacheStore(
      MemoryKeyValueStore(),
      MemoryEntitlementKeyStore(),
    ),
    allFeaturesOpen: false,
    purchases: FakePurchaseAdapter(),
    clock: () => now,
    attestor: attestor,
  );

  test('trial qatori: manba, daraja, qolgan kunlar, muddat tugashi', () async {
    final src = FakeEntitlementSource()..snapshot = _snap([_trial()]);
    final ent = make(src);
    await ent.refresh(reprobe: false);
    expect(ent.activeEntitlement!.isTrial, isTrue);
    expect(ent.proSource, ProSource.trial);
    expect(ent.plan, ProPlan.student);
    expect(ent.trialDaysLeft, 30);
    expect(ent.trialUsed, isTrue);
    // Server bilan qayta sinxronlangach (oflayn kesh 7 kun).
    now = _t0.add(const Duration(days: 29, hours: 1));
    src.snapshot = _snap([_trial()], at: now);
    await ent.refresh(reprobe: false);
    expect(ent.trialDaysLeft, 1);
    now = _t0.add(const Duration(days: 31));
    src.snapshot = _snap([_trial()], at: now);
    await ent.refresh(reprobe: false);
    expect(ent.activeEntitlement, isNull);
    expect(ent.proSource, ProSource.none);
  });

  test(
    'sinov pullik obunani bosib o‘tmaydi (yuqori darajadagi sinov ham)',
    () async {
      final src = FakeEntitlementSource()
        ..snapshot = _snap([
          _trial(plan: 'specialist'),
          _store(BillingCatalog.studentMonthly),
        ]);
      final ent = make(src);
      await ent.refresh(reprobe: false);
      expect(ent.activeEntitlement!.isStore, isTrue);
      expect(ent.plan, ProPlan.student);
      expect(ent.proSource, ProSource.server);
      expect(ent.trialDaysLeft, isNull);
    },
  );

  test(
    'attestatsiya sozlanmagan (standart): sinov taklif qilinmaydi',
    () async {
      final src = _TrialServer();
      final ent = make(src);
      expect(ent.trialAvailable, isFalse);
      expect(
        await ent.startTrial(plan: ProPlan.student, email: 'a@b.uz'),
        TrialOutcome.unavailable,
      );
      expect(src.last, isNull);
    },
  );

  test(
    'sinovni boshlash: nonce → attestatsiya → server; qayta — yo‘q',
    () async {
      final src = _TrialServer();
      final ent = make(src, attestor: _FakeAttestor());
      await ent.refresh(reprobe: false);
      expect(ent.trialAvailable, isTrue);
      expect(
        await ent.startTrial(plan: ProPlan.teacher, email: 'a@b.uz'),
        TrialOutcome.success,
      );
      expect(src.last, {
        'plan': 'teacher',
        'email': 'a@b.uz',
        'platform': 'ios',
        'token': 'fake:phone:${'n' * 43}',
        'nonce': 'n' * 43,
      });
      expect(ent.proSource, ProSource.trial);
      expect(ent.trialAvailable, isFalse);
    },
  );

  test('server rad javoblari aniq natijaga aylanadi', () async {
    for (final (code, outcome) in [
      ('trial_already_used', TrialOutcome.alreadyUsed),
      ('plan_not_allowed', TrialOutcome.planNotAllowed),
      ('email_not_verified', TrialOutcome.emailNotVerified),
      ('device_attestation_failed', TrialOutcome.attestationFailed),
      ('already_subscribed', TrialOutcome.alreadySubscribed),
      ('device_attestation_not_configured', TrialOutcome.unavailable),
      ('internal', TrialOutcome.failed),
    ]) {
      final src = _TrialServer()..errorCode = code;
      final ent = make(src, attestor: _FakeAttestor());
      expect(
        await ent.startTrial(plan: ProPlan.student, email: 'a@b.uz'),
        outcome,
        reason: code,
      );
      expect(ent.trialUsed, code == 'trial_already_used', reason: code);
    }
  });

  test('mehmon (sessiyasiz) — sinov yo‘q', () async {
    final src = _TrialServer()..user = null;
    final ent = make(src, attestor: _FakeAttestor());
    expect(ent.trialAvailable, isFalse);
    expect(
      await ent.startTrial(plan: ProPlan.student, email: 'a@b.uz'),
      TrialOutcome.unavailable,
    );
  });
}
