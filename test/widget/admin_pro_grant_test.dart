// Admin “Pro berish” (D-73): faqat Pro bayrog‘i yoqilgan buildda VA admin
// (TOTP) bo‘lganda; bayroq o‘chiq bo‘lsa admin panel avvalgidek, bo‘limning
// izi yo‘q. Soxta server qoidalari: test/helpers/fake_backend.dart.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/pro_grants.dart';
import 'package:labguide/core/build_flags.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/fake_community.dart';
import '../helpers/harness.dart';

const _owner = 'davlatsudekspert@gmail.com';
const _existing = 'existing.user@example.com';
const _newcomer = 'new.person@example.com';

AppLocalizations _l(AppLanguage lang) => lookupAppLocalizations(lang.locale);

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  // Pastki navigatsiya tugmani to'smasligi uchun ekran o'rtasiga olib kelamiz.
  await Scrollable.ensureVisible(tester.element(f.first), alignment: 0.4);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<AppServices> _setup(
  WidgetTester tester,
  FakeLabBackend lab, {
  AppLanguage language = AppLanguage.uz,
  bool? proEnabled,
}) async {
  final s = await makeServices(
    tester,
    language: language,
    backend: lab,
    community: FakeCommunityBackend(lab),
    proEnabled: proEnabled,
  );
  await pumpApp(tester, s);
  return s;
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _mfa(WidgetTester tester, AppLocalizations l) async {
  await tester.enterText(find.byType(TextField).last, FakeLabBackend.totpCode);
  await _tap(tester, find.text(l.adminMfaVerify));
}

/// Hisobi bor oddiy foydalanuvchi (serverda allaqachon ro‘yxatdan o‘tgan).
Future<FakeAdminTeamBackend> _lab() async {
  final lab = FakeAdminTeamBackend();
  await lab.requestCode(_existing);
  await lab.verifyCode(_existing, FakeLabBackend.otpCode);
  await lab.signOut();
  return lab;
}

Future<void> _openGrants(WidgetTester tester, AppLocalizations l) async {
  await goTo(tester, '/profile');
  await _tap(tester, find.text(l.adminTitle));
  await _mfa(tester, l);
  await _tap(tester, find.byKey(const ValueKey('admin-row-pro-grants')));
}

Future<void> _fill(WidgetTester tester, String email, {String? note}) async {
  await tester.enterText(find.byKey(const ValueKey('pro-grant-email')), email);
  if (note != null) {
    await tester.enterText(find.byKey(const ValueKey('pro-grant-note')), note);
  }
}

Future<void> _submit(
  WidgetTester tester,
  AppLocalizations l, {
  bool confirm = true,
}) async {
  await _tap(tester, find.byKey(const ValueKey('pro-grant-submit')));
  if (!confirm) return;
  expect(find.text(l.proGrantConfirmTitle), findsOneWidget);
  await tester.tap(find.text(l.proGrantSubmit).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('admin muddatni o‘zi kiritadi: kun, oy (30 kun), chegara '
        '(${lang.name})', (tester) async {
      final l = _l(lang);
      final lab = await _lab();
      final s = await _setup(tester, lab, language: lang, proEnabled: true);
      await _signIn(tester, s, _owner);
      await _openGrants(tester, l);

      Future<void> custom(String n, {bool months = false}) async {
        await tester.ensureVisible(
          find.byKey(const ValueKey('pro-grant-custom')),
        );
        await tester.enterText(
          find.descendant(
            of: find.byKey(const ValueKey('pro-grant-custom')),
            matching: find.byType(TextField),
          ),
          n,
        );
        await _tap(
          tester,
          find.byKey(
            ValueKey(months ? 'pro-grant-unit-months' : 'pro-grant-unit-days'),
          ),
        );
      }

      // 45 kun.
      await _fill(tester, _newcomer);
      await custom('45');
      await _submit(tester, l);
      expect(lab.grantCalls.last['days'], 45);

      // 2 oy = 60 kun.
      await _fill(tester, 'two.months@example.com');
      await custom('2', months: true);
      await _submit(tester, l);
      expect(lab.grantCalls.last['days'], 60);

      // Chegaradan oshgan muddat — serverga yuborilmaydi.
      final before = lab.grantCalls.length;
      await _fill(tester, 'too.long@example.com');
      await custom('4000');
      await _submit(tester, l, confirm: false);
      expect(find.text(l.proGrantErrRange(proGrantMaxDays)), findsOneWidget);
      expect(lab.grantCalls.length, before);
    });
  }

  for (final lang in AppLanguage.values) {
    testWidgets('bayroq YOQIQ + admin: berish, tekshiruv, almashtirish, '
        'uzaytirish, bekor qilish (${lang.name})', (tester) async {
      final l = _l(lang);
      final lab = await _lab();
      final s = await _setup(tester, lab, language: lang, proEnabled: true);
      expect(s.proGrants, isNotNull);
      await _signIn(tester, s, _owner);
      await _openGrants(tester, l);

      expect(find.text(l.proGrantIntro), findsOneWidget);
      expect(find.text(l.proGrantEmpty), findsOneWidget);

      // Noto'g'ri email — serverga yuborilmaydi.
      await _fill(tester, 'not-an-email');
      await _submit(tester, l, confirm: false);
      expect(find.text(l.admInvalidEmail), findsOneWidget);
      expect(lab.grantCalls, isEmpty);

      // Izoh maydoni 200 belgidan oshirmaydi (server ham rad etadi).
      await _fill(tester, _newcomer, note: 'x' * 201);
      final noteField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const ValueKey('pro-grant-note')),
          matching: find.byType(TextField),
        ),
      );
      expect(noteField.controller!.text.length, proGrantNoteMax);

      // Tasdiqni bekor qilish — hech narsa yozilmaydi.
      await _fill(tester, _newcomer, note: 'konferensiya');
      await _tap(
        tester,
        find.byKey(const ValueKey('pro-grant-plan-specialist')),
      );
      await _tap(tester, find.byKey(const ValueKey('pro-grant-days-90')));
      await _submit(tester, l, confirm: false);
      expect(find.text(l.proGrantConfirmTitle), findsOneWidget);
      expect(
        find.text(
          l.proGrantConfirmBody(
            _newcomer,
            l.proPlanSpecialist,
            l.proGrantDays(90),
          ),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(l.actionCancel));
      await tester.pumpAndSettle();
      expect(lab.grantCalls, isEmpty);

      // Hisobi yo'q email — KUTILMOQDA; ro'yxatda niqoblangan.
      await _submit(tester, l);
      expect(lab.grantCalls, hasLength(1));
      expect(lab.grantCalls.single['plan'], ProPlan.specialist);
      expect(lab.grantCalls.single['days'], 90);
      expect(find.text(l.proGrantDone('ne***@example.com')), findsOneWidget);
      expect(find.text(l.proGrantListTitle(1)), findsOneWidget);
      expect(find.text('ne***@example.com'), findsOneWidget);
      expect(find.textContaining(l.proGrantPending), findsOneWidget);
      expect(find.textContaining(_newcomer), findsNothing);

      // Hisobi bor email — darhol faol, muddat bor; email katta-kichik harfda.
      await _fill(tester, ' Existing.User@Example.com ');
      await _tap(tester, find.byKey(const ValueKey('pro-grant-plan-student')));
      await _tap(tester, find.byKey(const ValueKey('pro-grant-days-30')));
      await _submit(tester, l);
      expect(find.text(l.proGrantListTitle(2)), findsOneWidget);
      expect(lab.grantCalls.last['plan'], ProPlan.student);

      // Qayta berish — almashtiradi (yangi qator qo'shilmaydi).
      await _fill(tester, _existing);
      await _tap(tester, find.byKey(const ValueKey('pro-grant-plan-teacher')));
      await _submit(tester, l);
      expect(
        find.text(l.proGrantReplaced('ex***@example.com')),
        findsOneWidget,
      );
      expect(find.text(l.proGrantListTitle(2)), findsOneWidget);

      // Uzaytirish rejimi: muddatsiz tanlansa xato; 90 kun bilan uzayadi.
      await _fill(tester, _existing);
      await _tap(tester, find.byKey(const ValueKey('pro-grant-extend')));
      await _tap(tester, find.byKey(const ValueKey('pro-grant-days-forever')));
      await _submit(tester, l, confirm: false);
      expect(find.text(l.proGrantErrDuration), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('pro-grant-days-90')));
      await _submit(tester, l);
      expect(
        find.text(l.proGrantExtended('ex***@example.com')),
        findsOneWidget,
      );

      // Kutilayotgan grantni uzaytirib bo'lmaydi — server xatosi tushunarli.
      await _fill(tester, _newcomer);
      await _submit(tester, l);
      expect(find.text(l.proGrantErrPending), findsOneWidget);

      // Bekor qilish — tasdiq bilan; bekor qilsa saqlanadi.
      final pendingRevoke = find.byTooltip(l.proGrantRevoke).first;
      await _tap(tester, pendingRevoke);
      expect(find.text(l.proGrantRevokeTitle), findsOneWidget);
      await tester.tap(find.text(l.actionCancel));
      await tester.pumpAndSettle();
      expect(find.text(l.proGrantListTitle(2)), findsOneWidget);
      await _tap(tester, find.byTooltip(l.proGrantRevoke).first);
      await tester.tap(find.text(l.proGrantRevoke).last);
      await tester.pumpAndSettle();
      expect(find.text(l.proGrantListTitle(1)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('bayroq YOQIQ, lekin admin emas: bo‘lim ko‘rinmaydi, server '
      'ham rad etadi', (tester) async {
    final l = _l(AppLanguage.uz);
    final lab = await _lab();
    final s = await _setup(tester, lab, proEnabled: true);
    await _signIn(tester, s, _existing);
    await goTo(tester, '/profile');
    expect(find.text(l.adminTitle), findsNothing);
    expect(find.byKey(const ValueKey('admin-row-pro-grants')), findsNothing);
    expect(find.text(l.proGrantRow), findsNothing);
    // To'g'ridan-to'g'ri yo'l: AdminGate “faqat admin” — forma yo'q.
    await goTo(tester, '/profile/admin/pro-grants');
    expect(find.byKey(const ValueKey('pro-grant-form')), findsNothing);
    expect(find.byKey(const ValueKey('pro-grant-submit')), findsNothing);
    // Backend darajasida ham: oddiy foydalanuvchi — forbidden.
    await expectLater(
      s.proGrants!.grantPro(email: _newcomer, plan: ProPlan.student),
      throwsA(isA<ProGrantException>()),
    );
    expect(lab.grantCalls, isEmpty);
  });

  testWidgets('admin, lekin TOTP (aal2) siz: forma ochilmaydi', (tester) async {
    final l = _l(AppLanguage.uz);
    final lab = await _lab();
    final s = await _setup(tester, lab, proEnabled: true);
    await _signIn(tester, s, _owner);
    await goTo(tester, '/profile');
    await _tap(tester, find.text(l.adminTitle));
    // 2FA oynasi — forma ham, qator ham yo'q.
    expect(find.text(l.adminMfaTitle), findsOneWidget);
    expect(find.byKey(const ValueKey('admin-row-pro-grants')), findsNothing);
    await expectLater(
      s.proGrants!.proGrants(),
      throwsA(isA<ProGrantException>()),
    );
  });

  for (final lang in AppLanguage.values) {
    testWidgets('bayroq O‘CHIQ: admin panel avvalgidek, “Pro berish” yo‘q '
        '(${lang.name})', (tester) async {
      final l = _l(lang);
      final lab = await _lab();
      final s = await _setup(tester, lab, language: lang);
      expect(BuildFlags.proEnabled, isFalse);
      // Backend bu imkoniyatni biladi, lekin bayroqsiz ilova uni ko'rmaydi.
      expect(lab, isA<ProGrantBackend>());
      expect(s.proGrants, isNull);
      await _signIn(tester, s, _owner);
      await goTo(tester, '/profile');
      await _tap(tester, find.text(l.adminTitle));
      await _mfa(tester, l);
      // Avvalgi qatorlar o'z joyida (admin_team_test bilan bir xil).
      expect(find.text(l.admYouSuper), findsOneWidget);
      expect(find.byKey(const ValueKey('admin-row-team')), findsOneWidget);
      // Bo'limning izi yo'q.
      expect(find.byKey(const ValueKey('admin-row-pro-grants')), findsNothing);
      expect(find.text(l.proGrantRow), findsNothing);
      expect(find.text(l.proGrantRowSub), findsNothing);
      // Yo'l ro'yxatga olinmagan: forma ochilmaydi, so'rov ketmaydi.
      await goTo(tester, '/profile/admin/pro-grants');
      expect(find.byKey(const ValueKey('pro-grant-form')), findsNothing);
      expect(find.text(l.proGrantTitle), findsNothing);
      expect(lab.grantCalls, isEmpty);
    });
  }

  testWidgets('to‘rt reja (D-76): Premium tanlanadi va serverga yuboriladi', (
    tester,
  ) async {
    final l = _l(AppLanguage.uz);
    final lab = await _lab();
    final s = await _setup(tester, lab, proEnabled: true);
    await _signIn(tester, s, _owner);
    await _openGrants(tester, l);
    for (final p in ProPlan.values) {
      expect(
        find.byKey(ValueKey('pro-grant-plan-${p.name}')),
        findsOneWidget,
        reason: p.name,
      );
    }
    expect(find.text(l.proPlanPremium), findsOneWidget);
    await _fill(tester, _newcomer);
    await _tap(tester, find.byKey(const ValueKey('pro-grant-plan-premium')));
    await _tap(tester, find.byKey(const ValueKey('pro-grant-days-30')));
    await _submit(tester, l);
    expect(lab.grantCalls.single['plan'], ProPlan.premium);
    expect(lab.grantCalls.single['days'], 30);
  });
}
