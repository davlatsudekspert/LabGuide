// Admin panel (D-44) — egasi va qo'shilgan admin sifatida (walk_helper.dart):
// boshqaruv sahifasi, adminlar boshqaruvi, hamjamiyat moderatsiyasi.
// uz/ru/en, 390×844, 320×640 va qorong'i mavzu.
//
//   flutter test tool/screenshots/walk_admins_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/community_backend.dart';
import 'package:labguide/core/backend/lab_backend.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/fake_backend.dart';
import '../../test/helpers/fake_community.dart';
import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

const _owner = 'davlatsudekspert@gmail.com';
const _helper = 'helper.lab@gmail.com';

Future<(AppServices, FakeAdminTeamBackend)> _start(
  WidgetTester tester, {
  AppLanguage lang = AppLanguage.uz,
  ThemeMode theme = ThemeMode.light,
  Size size = const Size(390, 844),
  LabBackend? backend,
}) async {
  final lab = backend is FakeAdminTeamBackend
      ? backend
      : FakeAdminTeamBackend();
  final community = FakeCommunityBackend(lab);
  // Shikoyat qilingan (avtomatik to'xtatilgan) a'zo — moderatsiya navbati.
  await lab.requestCode('bad@example.com');
  await lab.verifyCode('bad@example.com', FakeLabBackend.otpCode);
  final bad = lab.userId!;
  community.makeSpecialist(bad);
  final qid = community.seedQuestion(
    author: bad,
    title: 'Arzon reagentlar — bizning saytda chegirma!',
    body: 'Reklama matni, savol emas.',
  );
  await lab.signOut();
  for (final e in ['r1@example.com', 'r2@example.com', 'r3@example.com']) {
    await lab.requestCode(e);
    await lab.verifyCode(e, FakeLabBackend.otpCode);
    await community.report(
      kind: PostKind.question,
      id: qid,
      reason: ReportReason.spam,
    );
    await lab.signOut();
  }
  final s = await makeServices(
    tester,
    language: lang,
    themeMode: theme,
    backend: backend ?? lab,
    community: community,
  );
  await pumpApp(tester, s, size: size);
  return (s, lab);
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

/// Uzun (lazy) ro'yxatda pastga aylantirib bosish.
Future<void> _scrollTap(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _mfa(WidgetTester tester, Walk w, AppLocalizations l) async {
  await tester.enterText(find.byType(TextField).last, FakeLabBackend.totpCode);
  await w.tap(find.text(l.adminMfaVerify));
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('egasi (${lang.name}): panel → adminlar → moderatsiya', (
      tester,
    ) async {
      final l = lookupAppLocalizations(lang.locale);
      final (s, _) = await _start(tester, lang: lang);
      final w = Walk(tester, 'admins_owner_${lang.name}');
      await _signIn(tester, s, _owner);
      await goTo(tester, '/profile');
      await _scrollTap(tester, find.text(l.adminTitle));
      await w.snap('mfa');
      await _mfa(tester, w, l);
      await w.snap('dashboard');
      await w.scroll(500);
      await w.snap('dashboard_bottom');
      await w.tap(find.byKey(const ValueKey('admin-row-team')));
      await w.snap('team_empty');
      await tester.enterText(find.byType(TextField).first, 'bad-email');
      await w.tap(find.byKey(const ValueKey('admin-team-add-button')));
      await w.snap('team_invalid');
      await tester.enterText(find.byType(TextField).first, _helper);
      await w.tap(find.byKey(const ValueKey('admin-team-add-button')));
      await w.snap('team_add_confirm');
      await w.tap(find.text(l.admAddButton).last);
      await w.snap('team_added');
      await w.tap(find.byTooltip(l.admRemove).first);
      await w.snap('team_remove_confirm');
      await w.tap(find.text(l.actionCancel));
      await goTo(tester, '/profile/admin/community');
      await w.snap('community');
      await w.scroll(400);
      await w.snap('community_queue');
      await w.tap(find.text(l.cmAdminRevoke).first);
      await w.snap('community_revoke_confirm');
    });
  }

  testWidgets('egasi (uz) — 320×640 va qorong‘i', (tester) async {
    final l = lookupAppLocalizations(AppLanguage.uz.locale);
    final (s, _) = await _start(
      tester,
      size: const Size(320, 640),
      theme: ThemeMode.dark,
    );
    final w = Walk(tester, 'admins_owner_uz_320_dark');
    await _signIn(tester, s, _owner);
    await goTo(tester, '/profile/admin');
    await w.snap('mfa');
    await _mfa(tester, w, l);
    await w.snap('dashboard');
    await w.scroll(400);
    await w.snap('dashboard_bottom');
    await w.tap(find.byKey(const ValueKey('admin-row-team')));
    await tester.enterText(find.byType(TextField).first, _helper);
    await w.tap(find.byKey(const ValueKey('admin-team-add-button')));
    await w.tap(find.text(l.admAddButton).last);
    await w.snap('team_added');
    await w.scroll(300);
    await w.snap('team_added_bottom');
    await goTo(tester, '/profile/admin/community');
    await w.snap('community');
  });

  for (final (lang, size, theme) in [
    (AppLanguage.ru, const Size(320, 640), ThemeMode.light),
    (AppLanguage.en, const Size(390, 844), ThemeMode.dark),
  ]) {
    testWidgets('qo‘shilgan admin (${lang.name} ${size.width.toInt()})', (
      tester,
    ) async {
      final l = lookupAppLocalizations(lang.locale);
      final lab = FakeAdminTeamBackend();
      await lab.requestCode(_owner);
      await lab.verifyCode(_owner, FakeLabBackend.otpCode);
      await lab.mfaVerify(factorId: 'totp-1', code: FakeLabBackend.totpCode);
      await lab.addAdmin(_helper);
      await lab.signOut();
      final (s, _) = await _start(
        tester,
        lang: lang,
        size: size,
        theme: theme,
        backend: lab,
      );
      final w = Walk(
        tester,
        'admins_helper_${lang.name}_${size.width.toInt()}',
      );
      await _signIn(tester, s, _helper);
      await goTo(tester, '/profile');
      await _scrollTap(tester, find.text(l.adminTitle));
      await _mfa(tester, w, l);
      await w.snap('dashboard');
      await w.tap(find.byKey(const ValueKey('admin-row-team')));
      await w.snap('team_view_only');
      await goTo(tester, '/profile/admin/community');
      await w.snap('community_no_launch');
    });
  }

  testWidgets('Supabase-turdagi server (uz): statistika bilan', (tester) async {
    final l = lookupAppLocalizations(AppLanguage.uz.locale);
    final (s, _) = await _start(
      tester,
      backend: FakeAdminTeamBackend(legacyAdminApi: true),
    );
    final w = Walk(tester, 'admins_legacy_uz');
    await _signIn(tester, s, _owner);
    await goTo(tester, '/profile/admin');
    await _mfa(tester, w, l);
    await w.snap('dashboard');
    await w.scroll(700);
    await w.snap('dashboard_mid');
    await w.scroll(900);
    await w.snap('dashboard_bottom');
  });
}
