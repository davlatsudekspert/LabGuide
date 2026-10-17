// Egasi admin paneli (Cloudflare): ADMIN_EMAILS + email kodi (TOTP siz),
// ko'rsatkichlar, ilova shikoyatlari, hamjamiyat shikoyatlari,
// foydalanuvchilar (rol, to'xtatish), jurnal; Aloqa va shikoyat shakli.
// Vakolat faqat soxta server (FakeAdminConsoleBackend) bergan holda.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/admin_console.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/contact.dart';
import 'package:labguide/features/admin/admin_console_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/fake_community.dart';
import '../helpers/harness.dart';

const _owner = 'owner.lab@example.com';
const _user = 'student.one@example.com';

AppLocalizations _l(AppLanguage lang) => lookupAppLocalizations(lang.locale);

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _see(WidgetTester tester, Finder f) => tester.scrollUntilVisible(
  f,
  300,
  scrollable: find.byType(Scrollable).first,
);

Future<AppServices> _setup(
  WidgetTester tester,
  FakeAdminConsoleBackend lab, {
  AppLanguage language = AppLanguage.uz,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  final s = await makeServices(
    tester,
    language: language,
    backend: lab,
    community: FakeCommunityBackend(lab),
  );
  await pumpApp(tester, s, size: size, textScale: textScale);
  return s;
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await s.refreshAccess();
  await tester.pumpAndSettle();
}

/// Oddiy foydalanuvchi ro'yxatdan o'tgan va bitta shikoyat yuborgan.
Future<FakeAdminConsoleBackend> _seeded() async {
  final lab = FakeAdminConsoleBackend(adminEmails: const {_owner});
  await lab.requestCode(_user);
  await lab.verifyCode(_user, FakeLabBackend.otpCode);
  await lab.submitComplaint(
    kind: ComplaintKind.inappropriate,
    body: 'Savolda haqoratli so‘zlar bor',
    targetRef: 'community:question:q1',
  );
  await lab.signOut();
  lab.reports.add(
    ReportItem(
      kind: 'question',
      id: 'q1',
      status: ReportStatus.open,
      reports: 2,
      reporters: 2,
      reasons: const ['abuse', 'spam'],
      excerpt: 'Trombotsitlar soni haqida savol',
      questionId: 'q1',
      postDeleted: false,
      authorStatus: 'none',
      lastAt: DateTime.utc(2026, 10, 16, 9),
    ),
  );
  return lab;
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('egasi: TOTP siz panel, ko‘rsatkichlar, shikoyatni hal '
        'qilish, do‘kon havolalari (${lang.name})', (tester) async {
      final l = _l(lang);
      final lab = await _seeded();
      final s = await _setup(tester, lab, language: lang);
      await _signIn(tester, s, _owner);
      await goTo(tester, '/profile');
      await _tap(tester, find.text(l.adminTitle));
      // 2FA so'ralmaydi — panel darhol (egasi qarori), holat matni buni aytadi.
      expect(find.text(l.adminMfaTitle), findsNothing);
      expect(find.text(l.admPanelAccess), findsOneWidget);
      expect(find.byKey(const ValueKey('admin-row-stats')), findsOneWidget);
      expect(find.text(l.admComplaintsRowSub(1)), findsOneWidget);
      expect(find.text(l.admReportsRowSub(1)), findsOneWidget);
      expect(find.text(l.admEmailNote(Contact.email)), findsOneWidget);
      // Hamkorlar bu serverda yo'q — “ulanmagan”, bosilmaydi.
      await _see(tester, find.byKey(const ValueKey('admin-row-partners')));
      expect(find.text(l.admNotConnected), findsOneWidget);
      // Yuklab olishlar va sotuvlar: halol izoh + konsol havolalari.
      await _see(tester, find.text(l.admSales));
      expect(find.byKey(const ValueKey('admin-open-asc')), findsOneWidget);
      expect(find.byKey(const ValueKey('admin-open-play')), findsOneWidget);

      // Umumiy ko'rsatkichlar + 14 kunlik grafik (har ustun — semantik yorliq).
      await goTo(tester, '/profile/admin/stats');
      expect(find.text(l.admStatsAccounts), findsOneWidget);
      expect(find.text(l.admOnlineNow), findsOneWidget);
      await _see(tester, find.text(l.admChartTitle));
      await _see(tester, find.byType(NewAccountsChart));
      // Bugungi ustun: 2 ta hisob (foydalanuvchi va egasi).
      final today = DateFormat.yMMMd(lang.locale.toLanguageTag())
          .format(DateTime.parse('2026-10-17'));
      final semantics = tester.ensureSemantics();
      await tester.pump();
      expect(find.bySemanticsLabel(l.admChartBar(today, 2)), findsOneWidget);
      semantics.dispose();
      await _see(tester, find.text(l.admStatsObjects));
      expect(find.text(l.admStatsResults), findsOneWidget);

      // Ilova shikoyatlari: ro'yxat → izoh → hal qilindi → qayta ochish.
      await goTo(tester, '/profile/admin/complaints');
      expect(find.text(l.admApple12Note), findsOneWidget);
      final id = lab.complaints.single.id;
      await _tap(tester, find.byKey(ValueKey('complaint-$id')));
      expect(find.text('Savolda haqoratli so‘zlar bor'), findsOneWidget);
      expect(
        find.textContaining(l.admComplaintTarget('community:question:q1')),
        findsOneWidget,
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const ValueKey('complaint-note')),
          matching: find.byType(TextField),
        ),
        'Post o‘chirildi',
      );
      await _tap(tester, find.byKey(const ValueKey('complaint-save-note')));
      expect(lab.complaints.single.adminNote, 'Post o‘chirildi');
      await _tap(tester, find.byKey(const ValueKey('complaint-resolve')));
      expect(lab.complaints.single.status, ComplaintStatus.resolved);
      await _tap(tester, find.byKey(const ValueKey('complaint-reopen')));
      expect(lab.complaints.single.status, ComplaintStatus.open);
      expect(
        lab.audit.map((e) => e.action),
        containsAll([
          'complaint_note',
          'complaint_resolved',
          'complaint_reopened',
        ]),
      );

      // Hamjamiyat shikoyati: rad etish (tasdiq bilan).
      await goTo(tester, '/profile/admin/reports');
      expect(find.text('Trombotsitlar soni haqida savol'), findsOneWidget);
      await _tap(tester, find.text(l.admReportDismiss).first);
      expect(find.text(l.admReportDismissTitle), findsOneWidget);
      await tester.tap(find.text(l.admReportDismiss).last);
      await tester.pumpAndSettle();
      expect(lab.reports.single.status, ReportStatus.dismissed);
      expect(find.text(l.admReportsEmpty), findsOneWidget);

      // Jurnal: bajaruvchi niqoblangan email bilan.
      await goTo(tester, '/profile/admin/audit');
      expect(find.text(l.adminActionComplaintResolved), findsOneWidget);
      expect(
        find.textContaining(l.admAuditBy('ow***@example.com')),
        findsWidgets,
      );
      expect(find.textContaining(_owner), findsNothing);
    });
  }

  testWidgets('foydalanuvchi: email bo‘yicha qidiruv, rol, to‘xtatish → '
      'kirish rad (aloqa manzili bilan), qayta faollashtirish', (tester) async {
    final l = _l(AppLanguage.uz);
    final lab = await _seeded();
    final s = await _setup(tester, lab);
    await _signIn(tester, s, _owner);
    await goTo(tester, '/profile/admin/users');
    // Ro'yxat: niqoblangan email, admin belgisi.
    expect(find.text('st***@example.com'), findsOneWidget);
    expect(find.text(_user), findsNothing);
    expect(find.text(l.admUserAdminTag), findsOneWidget);
    // Noto'g'ri email — server xatosi tushunarli matn bilan.
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('admin-user-search')),
        matching: find.byType(TextField),
      ),
      'not-an-email',
    );
    await _tap(tester, find.byKey(const ValueKey('admin-user-search-button')));
    expect(find.text(l.admInvalidEmail), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('admin-user-search')),
        matching: find.byType(TextField),
      ),
      _user,
    );
    await _tap(tester, find.byKey(const ValueKey('admin-user-search-button')));
    expect(find.text('st***@example.com'), findsOneWidget);
    expect(find.text(l.admUserAdminTag), findsNothing);
    await _tap(tester, find.text('st***@example.com'));

    // Rol.
    await _tap(tester, find.byKey(const ValueKey('admin-role-teacher')));
    expect(find.text(l.admRoleChanged), findsOneWidget);
    expect(lab.audit.map((e) => e.action), contains('role_changed'));

    // To'xtatish — tasdiq bilan.
    await _tap(tester, find.byKey(const ValueKey('admin-suspend')));
    expect(find.text(l.admAccountSuspendTitle), findsOneWidget);
    await tester.tap(find.text(l.admAccountSuspend).last);
    await tester.pumpAndSettle();
    await _see(tester, find.byKey(const ValueKey('admin-reactivate')));
    expect(find.text(l.admStatusSuspended), findsWidgets);

    // To'xtatilgan hisob kira olmaydi: ilova aloqa manzilini ko'rsatadi.
    await s.auth.signOut();
    await tester.pumpAndSettle();
    await goTo(tester, '/profile/auth');
    await tester.enterText(find.byType(TextField).first, _user);
    final consent = find.text(l.authConsent);
    if (consent.evaluate().isNotEmpty) await _tap(tester, consent);
    await _tap(tester, find.text(l.authGetCode));
    await tester.enterText(
      find.byType(TextField).first,
      FakeLabBackend.otpCode,
    );
    await tester.pumpAndSettle();
    final verify = find.text(l.otpVerify);
    if (verify.evaluate().isNotEmpty &&
        find.text(l.authAccountSuspended(Contact.email)).evaluate().isEmpty) {
      await _tap(tester, verify);
    }
    expect(find.text(l.authAccountSuspended(Contact.email)), findsOneWidget);
    expect(s.auth.hasAccount, isFalse);

    // Qayta faollashtirish.
    await _signIn(tester, s, _owner);
    final userId = (await lab.adminAccounts(email: _user)).rows.single.userId;
    await goTo(tester, '/profile/admin/users/$userId');
    await _tap(tester, find.byKey(const ValueKey('admin-reactivate')));
    await tester.tap(find.text(l.admAccountReactivate).last);
    await tester.pumpAndSettle();
    expect(
      (await lab.adminAccounts(email: _user)).rows.single.status,
      AccountStatus.active,
    );
    // O'zini to'xtatib / rolini o'zgartirib bo'lmaydi.
    final me = (await lab.adminAccounts(email: _owner)).rows.single.userId;
    await goTo(tester, '/profile/admin/users/$me');
    await _see(tester, find.text(l.admRoleSelfNote));
    expect(find.byKey(const ValueKey('admin-suspend')), findsNothing);
  });

  testWidgets('oddiy foydalanuvchi panelni ochmaydi; yo‘ldan kirsa ham — '
      '“faqat admin uchun”', (tester) async {
    final l = _l(AppLanguage.uz);
    final lab = await _seeded();
    final s = await _setup(tester, lab);
    await _signIn(tester, s, _user);
    await goTo(tester, '/profile');
    expect(find.text(l.adminTitle), findsNothing);
    for (final route in [
      '/profile/admin',
      '/profile/admin/stats',
      '/profile/admin/complaints',
      '/profile/admin/users',
    ]) {
      await goTo(tester, route);
      expect(find.text(l.adminForbiddenTitle), findsOneWidget, reason: route);
    }
    await expectLater(lab.adminComplaints(), throwsA(isA<BackendException>()));
  });

  testWidgets('holatlar: yuklanmoqda → xato (qayta urinish) → bo‘sh', (
    tester,
  ) async {
    final l = _l(AppLanguage.uz);
    final lab = FakeAdminConsoleBackend(adminEmails: const {_owner});
    final s = await _setup(tester, lab);
    await _signIn(tester, s, _owner);
    lab.hold = Completer<void>();
    routerOf(tester).go('/profile/admin/complaints');
    await tester.pump();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    lab.failNext = const BackendException(BackendFailure.network);
    lab.hold!.complete();
    lab.hold = null;
    await tester.pumpAndSettle();
    expect(find.text(l.errNetwork), findsOneWidget);
    await _tap(tester, find.text(l.actionRetry));
    expect(find.text(l.admComplaintsEmpty), findsOneWidget);
  });

  group('Aloqa va shikoyat: ilova ichidagi shakl', () {
    testWidgets('mehmon va hisobli yuboradi; 6-chisi — soatiga 5 ta xabari', (
      tester,
    ) async {
      final l = _l(AppLanguage.uz);
      final lab = FakeAdminConsoleBackend(adminEmails: const {_owner});
      final s = await _setup(tester, lab);
      await goTo(tester, '/profile/contact?ref=card:hemoglobin');
      expect(find.byKey(const ValueKey('complaint-form')), findsOneWidget);
      expect(find.text(l.complaintAnonNote), findsOneWidget);
      expect(find.text(l.complaintTarget('card:hemoglobin')), findsOneWidget);
      final field = find.descendant(
        of: find.byKey(const ValueKey('complaint-text')),
        matching: find.byType(TextField),
      );
      await _see(tester, field);
      await tester.enterText(field, 'abc');
      await _tap(tester, find.byKey(const ValueKey('complaint-send')));
      expect(find.text(l.complaintTooShort), findsOneWidget);
      expect(lab.complaints, isEmpty);
      await _tap(tester, find.byKey(const ValueKey('complaint-kind-bug')));
      for (var i = 0; i < 5; i++) {
        await tester.enterText(field, 'Kalkulyator xato hisobladi $i');
        await _tap(tester, find.byKey(const ValueKey('complaint-send')));
        expect(find.text(l.complaintSent), findsOneWidget);
      }
      expect(lab.complaints, hasLength(5));
      expect(lab.complaints.first.anonymous, isTrue);
      expect(lab.complaints.first.kind, ComplaintKind.bug);
      expect(lab.complaints.first.targetRef, 'card:hemoglobin');
      await tester.enterText(field, 'Oltinchi xabar matni');
      await _tap(tester, find.byKey(const ValueKey('complaint-send')));
      expect(find.text(l.complaintRateLimited(30)), findsOneWidget);
      expect(lab.complaints, hasLength(5));

      await _signIn(tester, s, _user);
      await goTo(tester, '/profile');
      await goTo(tester, '/profile/contact');
      expect(find.text(l.complaintAnonNote), findsNothing);
      await _see(tester, field);
      await tester.enterText(field, 'Hisobim bilan yuborilgan shikoyat');
      await _tap(tester, find.byKey(const ValueKey('complaint-send')));
      expect(lab.complaints.first.anonymous, isFalse);
      // mailto zaxira yo'li ham joyida.
      await _see(tester, find.byKey(const ValueKey('contact-mail-report')));
    });

    testWidgets('server sozlanmagan build — faqat mailto (shakl yo‘q)', (
      tester,
    ) async {
      final s = await makeServices(tester);
      await pumpApp(tester, s);
      await goTo(tester, '/profile/contact');
      expect(find.byKey(const ValueKey('complaint-form')), findsNothing);
      await _see(tester, find.byKey(const ValueKey('contact-mail-report')));
    });
  });

  testWidgets('320 px va 1.3x: panel ekranlari uz/ru/en da toshmaydi', (
    tester,
  ) async {
    for (final lang in AppLanguage.values) {
      final lab = await _seeded();
      final s = await _setup(
        tester,
        lab,
        language: lang,
        size: const Size(320, 3200),
        textScale: 1.3,
      );
      await _signIn(tester, s, _owner);
      final userId = (await lab.adminAccounts(email: _user)).rows.single.userId;
      final complaintId = lab.complaints.single.id;
      for (final route in [
        '/profile/admin',
        '/profile/admin/stats',
        '/profile/admin/complaints',
        '/profile/admin/complaints/$complaintId',
        '/profile/admin/reports',
        '/profile/admin/users',
        '/profile/admin/users/$userId',
        '/profile/admin/audit',
        '/profile/admin/inbox',
        '/profile/contact',
      ]) {
        await goTo(tester, route);
        expect(tester.takeException(), isNull, reason: '$lang $route');
      }
      await tester.pumpWidget(const SizedBox());
    }
  });
}
