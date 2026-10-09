import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/backend/lab_backend.dart';
import 'package:labguide/core/backend/partner_models.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/partners/partners_controller.dart';

import '../helpers/fake_backend.dart';
import '../helpers/partner_fixtures.dart';

void main() {
  test('Toshkent sanasi: UTC+5 (yozgi vaqtsiz)', () {
    expect(
      tashkentToday(DateTime.utc(2026, 10, 9, 18, 59)),
      DateTime.utc(2026, 10, 9),
    );
    expect(
      tashkentToday(DateTime.utc(2026, 10, 9, 19, 0)),
      DateTime.utc(2026, 10, 10),
    );
  });

  test('faollik: faqat e’lon qilingan va davr ichida (chegaralar bilan)', () {
    final today = tashkentToday(DateTime.now());
    final p = testPartner(fromDays: 0, toDays: 0);
    expect(p.isLiveOn(today), isTrue);
    expect(p.isLiveOn(today.add(const Duration(days: 1))), isFalse);
    expect(p.isLiveOn(today.subtract(const Duration(days: 1))), isFalse);
    expect(testPartner(status: PartnerStatus.paused).isLiveOn(today), isFalse);
    expect(testPartner(status: PartnerStatus.draft).isLiveOn(today), isFalse);
  });

  test('JSON: kesh uchun aylana (bog‘lanish va guvohnoma bilan)', () {
    final p = testPartner();
    final back = Partner.fromJson(p.toJson());
    expect(back.name, p.name);
    expect(back.startsOn, p.startsOn);
    expect(back.registrationFor('mindray-bs-240'), 'TEST-0001');
    expect(back.linksMaker('mindray'), isTrue);
    expect(back.summaryOf('ru'), startsWith('Биохимические'));
    // Tilda tavsif bo'lmasa — uz.
    final uzOnly = Partner.fromJson({
      ...p.toJson(),
      'summary': {'uz': 'Faqat o‘zbekcha'},
    });
    expect(uzOnly.summaryOf('en'), 'Faqat o‘zbekcha');
  });

  test('kiritish qoidalari (server CHECK lari bilan bir xil)', () {
    expect(normalizeTelegram('@lab_partner'), 'lab_partner');
    expect(normalizeTelegram('https://t.me/lab_partner'), 'lab_partner');
    expect(isValidTelegram('lab'), isFalse);
    expect(isValidPartnerPhone('+998 71 200-00-00'), isTrue);
    expect(isValidPartnerPhone('qo‘ng‘iroq qiling'), isFalse);
    expect(isValidHttpsUrl('http://example.com'), isFalse);
    expect(isValidHttpsUrl('https://example.com/b.pdf'), isTrue);
    expect(telUri('+998 (71) 200-00-00'), 'tel:+998712000000');
    expect(
      const PartnerRequestDraft(company: 'Firma', contactName: 'Ali').isValid,
      isFalse,
      reason: 'telefon yoki email shart',
    );
    expect(
      const PartnerRequestDraft(
        company: 'Firma',
        contactName: 'Ali',
        email: 'a@b.uz',
      ).isValid,
      isTrue,
    );
  });

  test('sozlanmagan server: reklama yo‘q, hodisa yuborilmaydi', () async {
    final c = PartnersController(
      MemoryKeyValueStore(),
      const UnconfiguredBackend(),
    );
    await c.refresh(force: true);
    expect(c.enabled, isFalse);
    expect(c.live, isEmpty);
    expect(c.featured, isNull);
  });

  test('kunlik aylanish: har kuni boshqa hamkor birinchi', () async {
    final backend = FakeLabBackend()
      ..seedPartner(testPartner(id: 'a', name: 'A'))
      ..seedPartner(testPartner(id: 'b', name: 'B'));
    // testPartner sanalari haqiqiy bugunga nisbatan (30 kun faol).
    var now = DateTime.now().toUtc();
    final c = PartnersController(
      MemoryKeyValueStore(),
      backend,
      clock: () => now,
    );
    await c.refresh(force: true);
    final first = c.featured!.id;
    now = now.add(const Duration(days: 1));
    expect(c.featured!.id, isNot(first));
  });

  test('kesh 6 soat: qayta so‘rov yuborilmaydi, force — yuboriladi', () async {
    final backend = FakeLabBackend()..seedPartner(testPartner());
    var now = DateTime.now();
    final c = PartnersController(
      MemoryKeyValueStore(),
      backend,
      clock: () => now,
    );
    await c.refresh();
    await c.refresh();
    expect(backend.partnerFeedCalls, 1);
    now = now.add(const Duration(hours: 7));
    await c.refresh();
    expect(backend.partnerFeedCalls, 2);
    await c.refresh(force: true);
    expect(backend.partnerFeedCalls, 3);
  });

  test('hodisa: bir kunda bir marta, bir kadrda bitta so‘rov', () async {
    final backend = FakeLabBackend()
      ..seedPartner(testPartner(id: 'a'))
      ..seedPartner(testPartner(id: 'b'));
    await backend.requestCode('lab@example.com');
    await backend.verifyCode('lab@example.com', FakeLabBackend.otpCode);
    final c = PartnersController(MemoryKeyValueStore(), backend);
    await c.refresh(force: true);
    final a = c.byId('a')!;
    final b = c.byId('b')!;
    c
      ..trackImpression(a, PartnerPlacement.card)
      ..trackImpression(a, PartnerPlacement.card)
      ..trackImpression(b, PartnerPlacement.card)
      ..trackContact(a, PartnerPlacement.card);
    await Future<void>.delayed(Duration.zero);
    expect(backend.partnerTrackCalls, 1);
    expect(backend.partnerTotals('a'), (impressions: 1, contacts: 1));
    expect(backend.partnerTotals('b'), (impressions: 1, contacts: 0));
    c.trackImpression(a, PartnerPlacement.card);
    await Future<void>.delayed(Duration.zero);
    expect(backend.partnerTrackCalls, 1);
  });

  test('server cheklovi: kuniga 100 dan ortiq hodisa rad etiladi', () async {
    final backend = FakeLabBackend()..seedPartner(testPartner(id: 'a'));
    await backend.requestCode('lab@example.com');
    await backend.verifyCode('lab@example.com', FakeLabBackend.otpCode);
    final batch = [
      for (var i = 0; i < 20; i++)
        const PartnerEvent(
          'a',
          PartnerPlacement.card,
          PartnerEventKind.impression,
        ),
    ];
    for (var i = 0; i < 5; i++) {
      await backend.trackPartnerEvents(batch);
    }
    expect(
      () => backend.trackPartnerEvents(batch.take(1).toList()),
      throwsA(
        isA<BackendException>().having(
          (e) => e.failure,
          'failure',
          BackendFailure.rateLimited,
        ),
      ),
    );
    expect(backend.partnerTotals('a').impressions, 100);
  });
}
