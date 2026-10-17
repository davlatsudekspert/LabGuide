import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/partner_models.dart';
import 'package:labguide/core/build_flags.dart';
import 'package:labguide/features/partners/become_partner_screen.dart';
import 'package:labguide/features/partners/partner_admin_screens.dart';
import 'package:labguide/features/partners/partner_widgets.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';
import '../helpers/partner_fixtures.dart';

/// `LG_PARTNER_ADS` build bayrog'i: do'kon buildida (standart, `false`)
/// reklama/hamkor UI umuman yo'q — faol hamkorlar serverda bo'lsa ham.
/// TestFlight / Play ichki test buildida (`true`) — hozirgidek.

const _tall = Size(390, 6000);

final _l = lookupAppLocalizations(const Locale('uz'));

FakeLabBackend _backendWithPartners() => FakeLabBackend()
  ..seedPartner(testPartner())
  ..seedPartner(
    testPartner(
      id: 'lab-1',
      name: 'Sinov Laboratoriya MChJ',
      kind: PartnerKind.laboratory,
      links: const [],
    ),
  );

/// Admin (2FA o'tgan) sifatida kirgan servislar.
Future<AppServices> _admin(
  WidgetTester tester,
  FakeLabBackend backend, {
  bool? partnerAds,
}) async {
  final s = await makeServices(
    tester,
    backend: backend,
    partnerAds: partnerAds,
  );
  await s.auth.requestCode('davlatsudekspert@gmail.com');
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await backend.mfaVerify(factorId: 'totp-1', code: FakeLabBackend.totpCode);
  await tester.runAsync(s.refreshAccess);
  return s;
}

const _screens = [
  '/home',
  '/lab',
  '/lab/instruments/c/chemistry',
  '/lab/instruments/m/mindray-bs-240',
  '/profile',
  '/profile/contact',
];

void main() {
  setUpAll(loadAppFonts);

  test('standart (do‘kon) build: bayroq o‘chiq', () {
    expect(kPartnerAds, isFalse);
    expect(BuildFlags.partnerAds, isFalse);
  });

  testWidgets('do‘kon build: hech qayerda reklama/hamkor UI yo‘q', (
    tester,
  ) async {
    final backend = _backendWithPartners();
    final s = await _admin(tester, backend);
    expect(s.partners.enabled, isFalse);
    await pumpApp(tester, s, size: _tall);
    for (final route in _screens) {
      await goTo(tester, route);
      expect(tester.takeException(), isNull, reason: route);
      expect(find.byType(HomePartnerPair), findsNothing, reason: route);
      expect(find.byType(HomeAdSlotCard), findsNothing, reason: route);
      expect(find.byType(LabPartnerCard), findsNothing, reason: route);
      expect(find.byType(CategoryPartnerCards), findsNothing, reason: route);
      expect(
        find.byType(InstrumentPartnersSection),
        findsNothing,
        reason: route,
      );
      expect(find.byType(PartnerTag), findsNothing, reason: route);
      expect(find.text(_l.partnerAdLabel), findsNothing, reason: route);
      expect(find.text(_l.homeAdDemoTitle), findsNothing, reason: route);
      expect(find.text('Sinov Hamkor MChJ'), findsNothing, reason: route);
      expect(find.text('Sinov Laboratoriya MChJ'), findsNothing, reason: route);
      expect(find.text(_l.partnerBecome), findsNothing, reason: route);
      expect(find.text(_l.contactAdTitle), findsNothing, reason: route);
    }
    // Admin panelida ham hamkor bo'limlari yo'q.
    await goTo(tester, '/profile/admin');
    expect(find.text(_l.adminStats), findsOneWidget);
    expect(find.text(_l.adminPartners), findsNothing);
    expect(find.byType(AdminPartnerRequestsRow), findsNothing);
    // Hamkor yo'llari ro'yxatdan o'tmagan.
    for (final route in [
      '/lab/partners/partner-test-1',
      '/profile/partnership',
      '/profile/admin/partners',
      '/profile/admin/partner-requests',
    ]) {
      await goTo(tester, route);
      tester.takeException();
      expect(find.byType(PartnerScreen), findsNothing, reason: route);
      expect(find.byType(BecomePartnerScreen), findsNothing, reason: route);
      expect(find.byType(AdminPartnersScreen), findsNothing, reason: route);
      expect(
        find.byType(AdminPartnerRequestsScreen),
        findsNothing,
        reason: route,
      );
    }
    // Serverga hamkor so'rovi ham, ko'rsatilish hisoboti ham yuborilmagan.
    expect(backend.partnerTrackCalls, 0);
  });

  testWidgets('test build (LG_PARTNER_ADS=true): hamkor UI hozirgidek', (
    tester,
  ) async {
    final backend = _backendWithPartners();
    final s = await _admin(tester, backend, partnerAds: true);
    expect(BuildFlags.partnerAds, isTrue);
    expect(s.partners.enabled, isTrue);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/home');
    expect(find.byType(HomePartnerPair), findsOneWidget);
    expect(find.text('Sinov Laboratoriya MChJ'), findsOneWidget);
    await goTo(tester, '/lab/instruments/m/mindray-bs-240');
    expect(find.byType(InstrumentPartnersSection), findsOneWidget);
    expect(find.text('Sinov Hamkor MChJ'), findsWidgets);
    await goTo(tester, '/lab/partners/partner-test-1');
    expect(find.byType(PartnerScreen), findsOneWidget);
    await goTo(tester, '/profile');
    expect(find.text(_l.partnerBecome), findsOneWidget);
    await goTo(tester, '/profile/partnership');
    expect(find.byType(BecomePartnerScreen), findsOneWidget);
    await goTo(tester, '/profile/admin');
    expect(find.text(_l.adminPartners), findsOneWidget);
    expect(backend.partnerTrackCalls, greaterThan(0));
  });
}
