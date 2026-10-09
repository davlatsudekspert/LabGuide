import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/partner_models.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/partners/partner_widgets.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';
import '../helpers/partner_fixtures.dart';

/// Hamkorlar (reklama): yorliq, faktlarga ta'sir yo'qligi, bo'sh holat,
/// kesh, ariza va admin oqimi. Server qoidalari
/// `supabase/tests/20_partners.sql` da haqiqiy Postgres'da tekshiriladi.
final _l = lookupAppLocalizations(const Locale('uz'));
const _user = 'lab.user@example.com';
const _firm = 'sales@firm.example.com';
const _admin = 'davlatsudekspert@gmail.com';

/// Butun karta quriladigan baland ekran (dangasa ro'yxat yashirmasin).
const _tall = Size(390, 20000);

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _signInAdmin(
  WidgetTester tester,
  AppServices s,
  FakeLabBackend backend,
) async {
  await _signIn(tester, s, _admin);
  await backend.mfaVerify(factorId: 'totp-1', code: FakeLabBackend.totpCode);
}

Future<void> _signOut(WidgetTester tester, AppServices s) async {
  await s.auth.signOut();
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) =>
    _tap(tester, find.text(text).last);

/// Yorlig'i [label] bo'lgan LgField ga yozish.
Future<void> _enter(WidgetTester tester, String label, String value) async {
  final field = find.descendant(
    of: find
        .ancestor(of: find.text(label).last, matching: find.byType(Column))
        .first,
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field.first);
  await tester.enterText(field.first, value);
  await tester.pumpAndSettle();
}

/// Ekrandagi matnlar tartib bilan ([exclude] ichidagilarsiz).
List<String> _texts(WidgetTester tester, {Finder? exclude}) {
  final skip = exclude == null
      ? <Element>{}
      : find
            .descendant(of: exclude, matching: find.byType(Text))
            .evaluate()
            .toSet();
  return [
    for (final e in find.byType(Text).evaluate())
      if (!skip.contains(e)) (e.widget as Text).data ?? '',
  ];
}

void _expectNoAds() {
  expect(find.byType(PartnerTag), findsNothing);
  expect(find.text(_l.partnerAdLabel), findsNothing);
  expect(find.text(_l.partnerOfficialTitle), findsNothing);
  expect(find.textContaining('MChJ'), findsNothing);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('sozlanmagan build: reklama joylari umuman chiqmaydi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    expect(s.partners.enabled, isFalse);
    await pumpApp(tester, s, size: _tall);
    for (final route in [
      '/lab',
      '/lab/instruments/c/chemistry',
      '/lab/instruments/m/mindray-bs-240',
      '/lab/partners/partner-test-1',
    ]) {
      await goTo(tester, route);
      _expectNoAds();
    }
    // “Hamkor bo'lish” — taklif ko'rinadi, ariza esa halol “ulanmagan”.
    await goTo(tester, '/profile/partnership');
    expect(find.text(_l.partnerOfferTitle), findsOneWidget);
    expect(find.text(_l.partnerPriceBody), findsOneWidget);
    expect(find.text(_l.partnerFormUnavailable), findsOneWidget);
    expect(find.text(_l.partnerFormSend), findsNothing);
  });

  testWidgets('hamkor yo‘q yoki faol emas — hech qanday kompaniya chiqmaydi', (
    tester,
  ) async {
    final backend = FakeLabBackend()
      ..seedPartner(testPartner(id: 'draft', status: PartnerStatus.draft))
      ..seedPartner(testPartner(id: 'paused', status: PartnerStatus.paused))
      ..seedPartner(testPartner(id: 'expired', fromDays: -60, toDays: -1))
      ..seedPartner(testPartner(id: 'future', fromDays: 2, toDays: 40));
    final s = await makeServices(tester, backend: backend);
    await pumpApp(tester, s, size: _tall);
    for (final route in [
      '/lab',
      '/lab/instruments/c/chemistry',
      '/lab/instruments/m/mindray-bs-240',
      '/lab/partners/draft',
    ]) {
      await goTo(tester, route);
      _expectNoAds();
    }
    expect(find.text(_l.partnerNotFoundTitle), findsOneWidget);
  });

  testWidgets(
    'kartada “Rasmiy hamkorlar” — Reklama yorlig‘i, faktlar o‘zgarmaydi',
    (tester) async {
      const route = '/lab/instruments/m/mindray-bs-240';
      // Hamkorsiz karta (taqqoslash uchun).
      final plain = await makeServices(tester, backend: FakeLabBackend());
      await pumpApp(tester, plain, size: _tall);
      await goTo(tester, route);
      final before = _texts(tester);
      await tester.pumpWidget(const SizedBox());

      final backend = FakeLabBackend()..seedPartner(testPartner());
      final s = await makeServices(tester, backend: backend);
      await pumpApp(tester, s, size: _tall);
      await _signIn(tester, s, _user);
      await goTo(tester, route);

      final section = find.byType(InstrumentPartnersSection);
      expect(find.text(_l.partnerOfficialTitle), findsOneWidget);
      expect(
        find.descendant(of: section, matching: find.text(_l.partnerAdLabel)),
        findsOneWidget,
      );
      expect(find.text('Sinov Hamkor MChJ'), findsOneWidget);
      expect(find.text(_l.partnerKindDistributor), findsOneWidget);
      expect(
        find.textContaining(_l.partnerRegistration('TEST-0001')),
        findsOneWidget,
      );
      expect(find.text(_l.partnerSectionNote), findsOneWidget);
      // Katalog ma'lumoti (faktlar, holat, manbalar) aynan o'sha va o'sha
      // tartibda; reklama — alohida, eng oxirida.
      expect(_texts(tester, exclude: section), before);
      expect(
        tester.getTopLeft(find.text(_l.partnerOfficialTitle)).dy,
        greaterThan(tester.getTopLeft(find.text(_l.instSources)).dy),
      );

      // Ko'rsatilish bir marta yuborildi; “Qo'ng'iroq” — bog'lanish.
      expect(backend.partnerTotals('partner-test-1').impressions, 1);
      await _tapText(tester, _l.partnerCall);
      expect(backend.partnerTotals('partner-test-1').contacts, 1);
      // Qayta ochish o'sha kunda qayta sanalmaydi (tejamkor).
      final calls = backend.partnerTrackCalls;
      await goTo(tester, '/lab');
      await goTo(tester, route);
      // +1 faqat Lab bosh sahifasidagi karta (boshqa joy) uchun.
      expect(backend.partnerTotals('partner-test-1').impressions, 2);
      expect(backend.partnerTrackCalls, calls + 1);
    },
  );

  testWidgets('mehmon: reklama ko‘rinadi, lekin hisoblagich yuborilmaydi', (
    tester,
  ) async {
    final backend = FakeLabBackend()..seedPartner(testPartner());
    final s = await makeServices(tester, backend: backend);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/lab/instruments/m/mindray-bs-240');
    expect(find.text('Sinov Hamkor MChJ'), findsOneWidget);
    expect(backend.partnerTrackCalls, 0);
  });

  testWidgets(
    'Lab bosh sahifasi → hamkor sahifasi; yo‘nalish tartibi o‘zgarmaydi',
    (tester) async {
      final plain = await makeServices(tester, backend: FakeLabBackend());
      await pumpApp(tester, plain, size: _tall);
      await goTo(tester, '/lab/instruments/c/chemistry');
      final makersBefore = _texts(tester);
      await tester.pumpWidget(const SizedBox());

      final backend = FakeLabBackend()..seedPartner(testPartner());
      final s = await makeServices(tester, backend: backend);
      await pumpApp(tester, s, size: _tall);
      await goTo(tester, '/lab/instruments/c/chemistry');
      expect(
        find.text('${_l.partnerLabel} · ${_l.partnerAdLabel}'),
        findsOneWidget,
      );
      expect(
        _texts(tester, exclude: find.byType(CategoryPartnerCards)),
        makersBefore,
      );

      await goTo(tester, '/lab');
      expect(find.text(_l.partnerAdLabel), findsOneWidget);
      await _tapText(tester, 'Sinov Hamkor MChJ');
      expect(find.text(_l.partnerAbout), findsOneWidget);
      expect(find.text(_l.partnerPageNote), findsOneWidget);
      expect(find.text('Mindray BS-240'), findsOneWidget);
      expect(find.text(_l.partnerAllModels('Mindray')), findsOneWidget);
      expect(find.text('@sinov_hamkor'), findsOneWidget);
      // Bog'liq model kartasiga o'tish.
      await _tapText(tester, 'Mindray BS-240');
      expect(find.text(_l.partnerOfficialTitle), findsOneWidget);
    },
  );

  testWidgets('kesh: internetsiz oxirgi ro‘yxat, muddati o‘tgani yashirin', (
    tester,
  ) async {
    final store = MemoryKeyValueStore();
    final backend = FakeLabBackend()..seedPartner(testPartner());
    final first = await makeServices(tester, store: store, backend: backend);
    await tester.runAsync(() => first.partners.refresh(force: true));
    expect(store.getString(StoreKeys.partnersCache), isNotNull);

    // Keshga muddati o'tgan hamkor ham yozilgan bo'lsa — ko'rsatilmaydi.
    final cached = jsonDecode(
      store.getString(StoreKeys.partnersCache)!,
    ) as Map<String, Object?>;
    (cached['partners']! as List).add(
      testPartner(
        id: 'old',
        name: 'Eski MChJ',
        fromDays: -90,
        toDays: -2,
      ).toJson(),
    );
    await store.setString(StoreKeys.partnersCache, jsonEncode(cached));

    backend.partnersOffline = true;
    final offline = await makeServices(tester, store: store, backend: backend);
    await pumpApp(tester, offline, size: _tall);
    await goTo(tester, '/lab');
    expect(find.text('Sinov Hamkor MChJ'), findsOneWidget);
    await goTo(tester, '/lab/instruments/m/mindray-bs-240');
    expect(find.text('Sinov Hamkor MChJ'), findsOneWidget);
    expect(find.text('Eski MChJ'), findsNothing);
  });

  testWidgets('ariza: firma vakili → admin javobi → vakil ko‘radi', (
    tester,
  ) async {
    final backend = FakeLabBackend();
    final s = await makeServices(tester, backend: backend);
    await pumpApp(tester, s, size: const Size(390, 8000));

    // Mehmon: taklif va qoidalar, ariza uchun kirish taklifi.
    await goTo(tester, '/profile');
    await _tapText(tester, _l.partnerBecome);
    expect(find.text(_l.partnerOfferTitle), findsOneWidget);
    expect(find.text(_l.partnerFormSignIn), findsOneWidget);
    expect(find.text(_l.partnerFormSend), findsNothing);

    await _signIn(tester, s, _firm);
    await goTo(tester, '/profile/partnership');
    // Bo'sh forma yuborilmaydi.
    await _tapText(tester, _l.partnerFormSend);
    expect(find.text(_l.partnerFormInvalid), findsOneWidget);
    await _enter(tester, _l.partnerFormCompany, 'Firma Test MChJ');
    await _enter(tester, _l.partnerFormContact, 'Aliyev A.');
    await _enter(tester, _l.partnerFormPhone, '+998 90 123-45-67');
    await _enter(tester, _l.partnerFormProducts, 'Mindray BS-240, BC-30s');
    await _enter(tester, _l.partnerFormMessage, 'Hamkorlik shartlari?');
    await _tapText(tester, _l.partnerFormSend);
    expect(find.text(_l.partnerSentTitle), findsOneWidget);
    expect(find.text(_l.partnerMyRequests), findsOneWidget);
    expect(find.text(_l.partnerReqStatusNew), findsOneWidget);
    final request = (await backend.myPartnerRequests()).single;
    expect(request.email, _firm);

    // Admin: “Hamkorlik arizalari” → holat va javob.
    await _signOut(tester, s);
    await _signInAdmin(tester, s, backend);
    await goTo(tester, '/profile/admin');
    await _tapText(tester, _l.adminPartnerRequests);
    expect(find.text('Firma Test MChJ'), findsOneWidget);
    await _tapText(tester, 'Firma Test MChJ');
    expect(find.text('Mindray BS-240, BC-30s'), findsOneWidget);
    await _tapText(tester, _l.partnerReqStatusInReview);
    await _enter(tester, _l.adminRequestReply, 'Ertaga qo‘ng‘iroq qilamiz.');
    await _tapText(tester, _l.adminRequestSave);
    expect(backend.audit.map((e) => e.action), contains('partner_request'));

    // Vakil javobni ko'radi.
    await _signOut(tester, s);
    await _signIn(tester, s, _firm);
    await goTo(tester, '/profile/partnership');
    expect(find.text(_l.partnerReqStatusInReview), findsOneWidget);
    expect(
      find.text(_l.partnerReqReply('Ertaga qo‘ng‘iroq qilamiz.')),
      findsOneWidget,
    );
  });

  testWidgets('admin: yaratish → e’lon → foydalanuvchi bosadi → statistika', (
    tester,
  ) async {
    final backend = FakeLabBackend();
    final s = await makeServices(tester, backend: backend);
    await pumpApp(tester, s, size: const Size(390, 2400));

    // Oddiy foydalanuvchi admin ro'yxatini ocholmaydi.
    await _signIn(tester, s, _user);
    await goTo(tester, '/profile/admin/partners');
    expect(find.text(_l.adminForbiddenTitle), findsOneWidget);
    expect(find.text(_l.adminPartnerNew), findsNothing);
    await _signOut(tester, s);

    await _signInAdmin(tester, s, backend);
    await goTo(tester, '/profile/admin');
    await _tapText(tester, _l.adminPartners);
    expect(find.text(_l.adminPartnersEmpty), findsOneWidget);
    await _tapText(tester, _l.adminPartnerNew);
    await _enter(tester, _l.adminPartnerName, 'Admin Test MChJ');
    await _enter(
      tester,
      _l.adminPartnerSummary('UZ'),
      'Mindray analizatorlari servisi',
    );
    await _enter(tester, _l.partnerFormPhone, '+998 71 111-22-33');
    await _enter(tester, _l.adminPartnerTelegram, '@admin_test_uz');
    // Bog'lanishsiz e'lon qilinmaydi.
    await _tapText(tester, _l.adminPartnerPublish);
    expect(find.text(_l.adminPartnerInvalid), findsOneWidget);
    expect((await backend.adminPartners()).single.status, PartnerStatus.draft);
    await _tap(tester, find.widgetWithText(InkWell, 'Mindray').first);
    await _tapText(tester, _l.adminPartnerSave);
    expect(find.text(_l.adminPartnerSaved), findsOneWidget);
    await _tapText(tester, _l.adminPartnerPublish);
    expect(find.text(_l.adminPartnerPublished), findsOneWidget);
    final saved = (await backend.adminPartners()).single;
    expect(saved.status, PartnerStatus.published);
    expect(saved.telegram, 'admin_test_uz');
    expect(saved.linksMaker('mindray'), isTrue);
    expect(
      backend.audit.map((e) => e.action),
      containsAll(['partner_created', 'partner_published']),
    );

    // Foydalanuvchi kartada ko'radi va bog'lanadi.
    await _signOut(tester, s);
    await _signIn(tester, s, _user);
    await goTo(tester, '/lab/instruments/m/mindray-bc-30s');
    expect(find.text('Admin Test MChJ'), findsOneWidget);
    await _tapText(tester, _l.partnerTelegram);
    expect(backend.partnerTotals(saved.id), (impressions: 1, contacts: 1));

    // Admin statistikasi: hisobot uchun raqamlar.
    await _signOut(tester, s);
    await _signInAdmin(tester, s, backend);
    await goTo(tester, '/profile/admin/partners/${saved.id}/stats');
    expect(find.text(_l.adminStatsByPlacement), findsOneWidget);
    const one = '1';
    final line =
        '${_l.adminStatsImpressions}: $one · '
        '${_l.adminStatsContacts}: $one';
    // Joy (karta) va kun qatorlari; davr qatorlari — ulush bilan.
    expect(find.text(line), findsNWidgets(2));
    expect(find.text('$line · ${_l.adminStatsCtr}: 100.0%'), findsNWidgets(3));
    expect(find.text('${_l.adminStatsCtr}: 100.0%'), findsOneWidget);

    // To'xtatish → reklama darhol yo'qoladi.
    await goTo(tester, '/profile/admin/partners/${saved.id}');
    await _tapText(tester, _l.adminPartnerPause);
    expect(find.text(_l.adminPartnerPausedMsg), findsOneWidget);
    await goTo(tester, '/lab/instruments/m/mindray-bc-30s');
    expect(find.text('Admin Test MChJ'), findsNothing);
    expect(backend.audit.map((e) => e.action), contains('partner_paused'));
  });
}
