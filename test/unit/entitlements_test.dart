import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/entitlements/entitlement_cache.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/entitlement_service.dart';
import 'package:labguide/core/entitlements/entitlement_source.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/core/entitlements/purchase_adapter.dart';
import 'package:labguide/core/storage/kv_store.dart';

/// Server o'rnida: javob yoki xato (internet yo'q).
class _FakeSource implements EntitlementSource {
  _FakeSource();

  String? user = 'user-a';
  EntitlementSnapshot? snapshot;
  Object? error;
  List<PurchaseProof>? verified;

  @override
  bool get isConfigured => true;
  @override
  bool get hasSession => user != null;
  @override
  String? get userId => user;

  @override
  Future<EntitlementSnapshot> fetch() async {
    if (error != null) throw error!;
    return snapshot!;
  }

  @override
  Future<EntitlementSnapshot> verify(
    List<PurchaseProof> proofs, {
    required bool restore,
  }) async {
    verified = proofs;
    return fetch();
  }
}

class _FakeStore implements PurchaseAdapter {
  _FakeStore(this.proofs);
  final List<PurchaseProof> proofs;

  @override
  bool get isAvailable => true;
  @override
  Future<List<StoreProduct>> products(Set<String> ids) async => const [];
  @override
  Future<PurchaseProof?> buy(String productId) async => proofs.firstOrNull;
  @override
  Future<List<PurchaseProof>> restore() async => proofs;
}

final _t0 = DateTime.utc(2026, 10, 9, 12);

ServerEntitlement _sub({
  EntitlementStatus status = EntitlementStatus.active,
  DateTime? start,
  DateTime? end,
}) => ServerEntitlement(
  productId: 'labguide.pro.monthly',
  platform: 'app_store',
  status: status,
  startedAt: start ?? _t0.subtract(const Duration(days: 3)),
  expiresAt: end ?? _t0.add(const Duration(days: 27)),
);

EntitlementSnapshot _snap(List<ServerEntitlement> items, [DateTime? at]) =>
    EntitlementSnapshot(serverTime: at ?? _t0, items: items);

void main() {
  late MemoryKeyValueStore store;
  late MemoryEntitlementKeyStore keys;
  late _FakeSource source;
  late DateTime now;

  EntitlementService make({bool open = false, PurchaseAdapter? purchases}) =>
      EntitlementService(
        source: source,
        cache: EntitlementCacheStore(store, keys),
        allFeaturesOpen: open,
        purchases: purchases ?? const UnavailablePurchaseAdapter(),
        clock: () => now,
      );

  setUp(() {
    store = MemoryKeyValueStore();
    keys = MemoryEntitlementKeyStore();
    source = _FakeSource();
    now = _t0;
  });

  // Tarix: 6 natija, eng yangisi birinchi, har biri bir kun oldin.
  List<DateTime> history(int n, {DateTime? from}) => [
    for (var i = 0; i < n; i++) (from ?? _t0).subtract(Duration(days: i)),
  ];

  group('build rejimi (TestFlight/debug)', () {
    test('hamma imkoniyat ochiq, server bo‘lmasa ham', () {
      source.user = null;
      final s = make(open: true);
      expect(s.proSource, ProSource.buildOpen);
      for (final f in Feature.values) {
        expect(s.can(f), isTrue, reason: f.name);
      }
      expect(s.historyVisibleLimit(), isNull);
      final v = s.historyView(history(10), (d) => d);
      expect(v.visible, hasLength(10));
      expect(v.hiddenCount, 0);
    });

    test('LG_ALL_FEATURES_OPEN standart qiymati — false (do‘kon build)', () {
      expect(EntitlementService.buildAllFeaturesOpen, isFalse);
    });
  });

  group('bepul rejim', () {
    test('bepul imkoniyatlar ochiq, Pro yopiq', () {
      final s = make();
      expect(s.isPro, isFalse);
      expect(s.can(Feature.leukocyteCounter), isTrue);
      expect(s.can(Feature.absoluteCounts), isTrue);
      expect(s.can(Feature.basicGuides), isTrue);
      expect(s.can(Feature.unlimitedHistory), isFalse);
      expect(s.can(Feature.pdfExport), isFalse);
      expect(s.can(Feature.advancedPractice), isFalse);
      expect(s.can(Feature.categoryExamPrep), isFalse);
    });

    test('tarixda oxirgi 3 natija; eskilari o‘chmaydi, soni aytiladi', () {
      final s = make();
      expect(s.historyVisibleLimit(), 3);
      final all = history(7);
      final v = s.historyView(all, (d) => d);
      expect(v.visible, all.take(3).toList());
      expect(v.hiddenCount, 4);
      // Asl ro'yxat o'zgarmadi — hech narsa o'chirilmagan.
      expect(all, hasLength(7));
    });

    test('3 tadan kam bo‘lsa hammasi ko‘rinadi', () {
      final v = make().historyView(history(2), (d) => d);
      expect(v.visible, hasLength(2));
      expect(v.hiddenCount, 0);
    });
  });

  group('server tasdiqlagan obuna', () {
    test('faol obuna Pro beradi va imzolangan keshga yoziladi', () async {
      source.snapshot = _snap([_sub()]);
      final s = make();
      await s.refresh();
      expect(s.proSource, ProSource.server);
      expect(s.can(Feature.pdfExport), isTrue);
      expect(s.historyVisibleLimit(), isNull);
      expect(store.getString(StoreKeys.entitlementsCache), isNotNull);
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
      // Obuna 30..10 kun oldin amalda bo'lgan, endi tugagan.
      final start = _t0.subtract(const Duration(days: 30));
      final end = _t0.subtract(const Duration(days: 10));
      source.snapshot = _snap([
        _sub(status: EntitlementStatus.expired, start: start, end: end),
      ]);
      final s = make();
      await s.refresh();
      expect(s.isPro, isFalse);
      expect(s.can(Feature.pdfExport), isFalse, reason: 'yangi Pro amal yopiq');

      // Kunlik natijalar: bugundan 40 kun oldingacha (eng yangisi birinchi).
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
      await s.refresh(); // internet yo'q — kesh qoladi
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
    test('to‘lov yoqilmagan: unavailable, hech narsa o‘zgarmaydi', () async {
      final s = make();
      expect(s.purchasesEnabled, isFalse);
      expect(await s.restore(), BillingOutcome.unavailable);
      expect(
        await s.purchase('labguide.pro.monthly'),
        BillingOutcome.unavailable,
      );
      expect(s.isPro, isFalse);
    });

    test('tiklash: server tekshiradi va Pro beradi', () async {
      const proof = PurchaseProof(
        platform: 'app_store',
        productId: 'labguide.pro.monthly',
        token: '2000000123',
      );
      source.snapshot = _snap([_sub()]);
      final s = make(purchases: _FakeStore([proof]));
      expect(await s.restore(), BillingOutcome.success);
      expect(source.verified, [proof]);
      expect(s.isPro, isTrue);
    });

    test('tiklash: xarid boshqa hisobda', () async {
      source.snapshot = EntitlementSnapshot(
        serverTime: _t0,
        items: const [],
        ownedByOther: true,
      );
      final s = make(
        purchases: _FakeStore(const [
          PurchaseProof(platform: 'app_store', productId: 'p', token: 't'),
        ]),
      );
      expect(await s.restore(), BillingOutcome.ownedByOther);
      expect(s.isPro, isFalse);
    });

    test('server sozlanmagan (503) — unavailable', () async {
      source.error = const EntitlementException(
        EntitlementFailure.notConfigured,
      );
      final s = make(
        purchases: _FakeStore(const [
          PurchaseProof(platform: 'app_store', productId: 'p', token: 't'),
        ]),
      );
      expect(await s.restore(), BillingOutcome.unavailable);
    });

    test('hisobsiz tiklash — kirish kerak', () async {
      source.user = null;
      final s = make(purchases: _FakeStore(const []));
      expect(await s.restore(), BillingOutcome.signInRequired);
    });
  });

  test('server javobi (my_entitlements) o‘qiladi', () {
    final snap = EntitlementSnapshot.fromJson({
      'server_time': '2026-10-09T12:00:00+00:00',
      'items': [
        {
          'product_id': 'labguide.pro.yearly',
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
