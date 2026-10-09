// Hamkorlar va reklama — foydalanuvchi sifatida (walk_helper.dart):
// laboratoriya mutaxassisi, firma vakili va admin.
//
//   flutter test tool/screenshots/walk_partners_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/partner_models.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/fake_backend.dart';
import '../../test/helpers/harness.dart';
import '../../test/helpers/partner_fixtures.dart';
import 'walk_helper.dart';

const _admin = 'davlatsudekspert@gmail.com';

/// walk_helper `start` bilan bir xil, lekin sinov serveri bilan.
Future<AppServices> _start(
  WidgetTester tester,
  FakeLabBackend backend, {
  AppLanguage lang = AppLanguage.uz,
  ThemeMode theme = ThemeMode.light,
  double textScale = 1,
  AppRole role = AppRole.lab,
}) async {
  final s = await makeServices(
    tester,
    language: lang,
    themeMode: theme,
    role: role,
    backend: backend,
  );
  await pumpApp(tester, s, textScale: textScale);
  await tester.runAsync(() async {
    final ctx = tester.element(find.byType(Scaffold).first);
    for (final n in ['chemistry', 'hematology', 'immunoassay', 'urinalysis']) {
      await precacheImage(AssetImage('assets/instruments/img/$n.png'), ctx);
    }
    await precacheImage(const AssetImage('assets/images/logo_mark.png'), ctx);
  });
  return s;
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('laboratoriya mutaxassisi: karta → hamkor → bog‘lanish (uz)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final backend = FakeLabBackend()..seedPartner(testPartner());
    final s = await _start(tester, backend);
    await _signIn(tester, s, 'lab.user@example.com');
    final w = Walk(tester, 'partners_lab_uz');
    await goTo(tester, '/lab');
    await w.snap('lab');
    await w.scroll(600);
    await w.snap('lab_reklama_kartasi');
    await w.scroll(-2000);
    await w.tapText(l.labInstruments);
    await w.tapText('Biokimyo');
    await w.snap('biokimyo_hamkor');
    await w.tapText('Mindray');
    await w.tapText('BS-240');
    await w.snap('karta_tepa');
    await w.scroll(5000);
    await w.snap('karta_rasmiy_hamkorlar');
    await w.tap(find.text(l.partnerCall).last);
    await w.snap('qongiroq_bosildi');
    await w.tap(find.text(l.partnerMore).last);
    await w.snap('hamkor_sahifasi');
    await w.scroll(700);
    await w.snap('hamkor_sahifasi_pasti');
    await w.tap(find.text('Mindray BS-240').last);
    await w.snap('modelga_qaytish');
    expect(backend.partnerTotals('partner-test-1').contacts, 1);
  });

  testWidgets('firma vakili: Hamkor bo‘lish → ariza (ru, qorong‘i, 1.35)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    final backend = FakeLabBackend();
    final s = await _start(
      tester,
      backend,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
    );
    final w = Walk(tester, 'partners_firm_ru_dark_large');
    await goTo(tester, '/profile');
    await w.scroll(900);
    await w.snap('profil');
    await w.tap(find.text(l.partnerBecome).last);
    await w.snap('taklif_tepa');
    await w.scroll(700);
    await w.snap('nima_beriladi');
    await w.scroll(800);
    await w.snap('qoidalar');
    await w.scroll(900);
    await w.snap('narx_qadamlar');
    await w.scroll(900);
    await w.snap('kirish_taklifi');
    await _signIn(tester, s, 'sales@firm.example.com');
    await w.snap('forma');
    await w.enter(l.partnerFormCompany, 'ООО «Тест Партнёр»');
    await w.enter(l.partnerFormContact, 'Алиев А.');
    await w.enter(l.partnerFormPhone, '+998 90 123-45-67');
    await w.enter(l.partnerFormProducts, 'Mindray BS-240, BC-30s');
    await w.enter(
      l.partnerFormMessage,
      'Хотим разместить контакты в карточке.',
    );
    await w.snap('forma_toldirildi');
    await w.tap(find.text(l.partnerFormSend).last);
    await w.snap('yuborildi');
    await w.scroll(-500);
    await w.snap('arizalar');
    // Qayta ochish: arizaning holati saqlangan.
    await goTo(tester, '/profile');
    await goTo(tester, '/profile/partnership');
    await w.scroll(6000);
    await w.snap('qayta_ochildi');
  });

  testWidgets('admin: hamkor yaratish → e’lon → statistika (en)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('en'));
    final backend = FakeLabBackend();
    final s = await _start(tester, backend, lang: AppLanguage.en);
    // Firma arizasi (oldindan).
    await _signIn(tester, s, 'sales@firm.example.com');
    await backend.createPartnerRequest(
      const PartnerRequestDraft(
        company: 'Test Partner LLC',
        contactName: 'A. Aliyev',
        email: 'sales@firm.example.com',
        products: 'Mindray BS-240',
        message: 'We would like to list our service contacts.',
      ),
    );
    await s.auth.signOut();
    await _signIn(tester, s, _admin);
    await backend.mfaVerify(factorId: 'totp-1', code: FakeLabBackend.totpCode);
    final w = Walk(tester, 'partners_admin_en');
    await goTo(tester, '/profile/admin');
    await w.scroll(900);
    await w.snap('admin_panel');
    await w.tap(find.text(l.adminPartnerRequests).last);
    await w.snap('arizalar');
    await w.tapText('Test Partner LLC');
    await w.snap('ariza');
    await goTo(tester, '/profile/admin/partners');
    await w.snap('hamkorlar_bosh');
    await w.tapText(l.adminPartnerNew);
    await w.snap('yangi_hamkor');
    await w.enter(l.adminPartnerName, 'Test Partner LLC');
    await w.enter(
      l.adminPartnerSummary('UZ'),
      'Mindray analizatorlari: yetkazib berish, o‘rnatish va servis.',
    );
    await w.enter(
      l.adminPartnerSummary('EN'),
      'Mindray analysers: supply, installation and service.',
    );
    await w.snap('nom_tavsif');
    await w.tap(find.text('Tashkent city').last);
    await w.enter(l.partnerFormPhone, '+998 71 200-00-00');
    await w.enter(l.adminPartnerTelegram, '@test_partner_uz');
    await w.snap('aloqa');
    await w.tap(find.text('Mindray').last);
    await w.tap(find.text(l.adminPartnerAddModel).last);
    await w.snap('model_tanlash');
    await tester.enterText(find.byType(TextField).last, 'BS-240');
    await w.tap(find.text('Mindray BS-240').last);
    await w.enter(l.adminPartnerRegNo, 'TEST-0001');
    await w.snap('boglanishlar');
    await w.tap(find.text(l.adminPartnerSave).last);
    await w.snap('saqlandi');
    await w.tap(find.text(l.adminPartnerPublish).last);
    await w.snap('elon_qilindi');
    final id = (await backend.adminPartners()).single.id;

    // Foydalanuvchi ko'radi va bog'lanadi (hisobot uchun).
    await s.auth.signOut();
    await _signIn(tester, s, 'lab.user@example.com');
    await goTo(tester, '/lab/instruments/m/mindray-bs-240');
    await w.scroll(5000);
    await w.snap('foydalanuvchi_kartada');
    await w.tap(find.text(l.partnerTelegram).last);
    await goTo(tester, '/lab');
    await s.auth.signOut();
    await _signIn(tester, s, _admin);
    await backend.mfaVerify(factorId: 'totp-1', code: FakeLabBackend.totpCode);
    await goTo(tester, '/profile/admin/partners');
    await w.snap('hamkorlar_royxati');
    await goTo(tester, '/profile/admin/partners/$id/stats');
    await w.snap('statistika');
    await w.scroll(700);
    await w.snap('statistika_pasti');
  });

  testWidgets('karta va Lab — ru qorong‘i katta shrift, en', (tester) async {
    final backend = FakeLabBackend()..seedPartner(testPartner());
    await _start(
      tester,
      backend,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
    );
    final w = Walk(tester, 'partners_card_ru_dark_large');
    await goTo(tester, '/lab/instruments/m/mindray-bs-240');
    await w.scroll(6000);
    await w.snap('karta_hamkorlar');
    await goTo(tester, '/lab');
    await w.scroll(900);
    await w.snap('lab_reklama');
    await goTo(tester, '/lab/instruments/c/chemistry');
    await w.snap('yonalish');
    await goTo(tester, '/lab/partners/partner-test-1');
    await w.snap('hamkor_sahifasi');
    await tester.pumpWidget(const SizedBox());

    await _start(tester, backend, lang: AppLanguage.en);
    final e = Walk(tester, 'partners_card_en');
    await goTo(tester, '/lab/instruments/m/mindray-bs-240');
    await e.scroll(6000);
    await e.snap('card_partners');
    await goTo(tester, '/lab');
    await e.scroll(900);
    await e.snap('lab_ad');
  });
}
