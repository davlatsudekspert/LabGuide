// Admin STEP-UP (2026-10-24 auth auditi, 1b): xavfli amal → server
// `step_up_required` → ilova kod oynasini ko'rsatadi → tasdiqlansa amal BIR
// marta davom etadi. Bekor qilinsa — amal bajarilmaydi, tushunarli xabar.
// Ikki marta bosish — bitta tasdiq oynasi va bitta so'rov.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/admin_console.dart';
import 'package:labguide/core/single_flight.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/double_tap.dart';
import '../helpers/fake_backend.dart';
import '../helpers/fake_community.dart';
import '../helpers/harness.dart';

const _owner = 'owner.lab@example.com';
const _user = 'student.one@example.com';

final l = lookupAppLocalizations(const Locale('uz'));

Future<(AppServices, FakeAdminConsoleBackend, String)> _open(
  WidgetTester tester,
) async {
  final lab = FakeAdminConsoleBackend(adminEmails: const {_owner})
    ..requireStepUp = true;
  await lab.requestCode(_user);
  await lab.verifyCode(_user, FakeLabBackend.otpCode);
  await lab.signOut();
  final s = await makeServices(
    tester,
    backend: lab,
    community: FakeCommunityBackend(lab),
  );
  await pumpApp(tester, s, size: const Size(390, 1400));
  await s.auth.requestCode(_owner);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await s.refreshAccess();
  await tester.pumpAndSettle();
  final id = (await lab.adminAccounts(email: _user)).rows.single.userId;
  await goTo(tester, '/profile/admin/users/$id');
  return (s, lab, id);
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await scrollToFinder(tester, f);
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Step-up oynasi ochiq paytda orqadagi tugma "band" (aylanadi) —
/// `pumpAndSettle` tugamaydi; bir necha kadr yetarli.
Future<void> _frames(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _code(WidgetTester tester, String code) async {
  await tester.enterText(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    ),
    code,
  );
  await tester.tap(find.byKey(const ValueKey('step-up-confirm')));
  await _frames(tester);
}

void main() {
  setUpAll(loadAppFonts);
  setUp(SingleFlight.reset);

  testWidgets('to‘xtatish: kod so‘raladi → noto‘g‘ri kod xato → to‘g‘ri kod → '
      'amal bir marta bajariladi', (tester) async {
    final (_, lab, _) = await _open(tester);
    await _tapKey(tester, 'admin-suspend');
    await tester.tap(find.text(l.admAccountSuspend).last);
    await _frames(tester);
    // Step-up oynasi: niqoblangan email bilan.
    expect(find.text(l.stepUpTitle), findsOneWidget);
    expect(find.text(l.stepUpBodyEmail('ow***@example.com')), findsOneWidget);
    expect(lab.stepUpRequests, 1);
    await _code(tester, '111111');
    expect(find.text(l.otpInvalid(4)), findsOneWidget);
    await _code(tester, FakeAdminConsoleBackend.stepUpCode);
    expect(find.text(l.stepUpTitle), findsNothing);
    expect(lab.stepUpVerifies, 2);
    expect(lab.callCount('adminSuspendAccount'), 1);
    expect(
      (await lab.adminAccounts(email: _user)).rows.single.status,
      AccountStatus.suspended,
    );
    expect(lab.audit.map((e) => e.action), contains('step_up_verified'));
  });

  testWidgets(
    'bekor qilinsa — amal bajarilmaydi, “yangi tasdiq kerak” xabari',
    (tester) async {
      final (_, lab, _) = await _open(tester);
      await _tapKey(tester, 'admin-community-suspend');
      await tester.tap(find.text(l.admCommunitySuspend).last);
      await _frames(tester);
      expect(find.text(l.stepUpTitle), findsOneWidget);
      await tester.tap(find.text(l.actionCancel).last);
      await tester.pumpAndSettle();
      expect(find.text(l.stepUpCancelled), findsOneWidget);
      expect(lab.communityStatus.values, isNot(contains('suspended')));
      expect(lab.audit.map((e) => e.action), contains('step_up_required'));
    },
  );

  testWidgets('sessiyalarni bekor qilish: ikki marta bosish — bitta dialog; '
      'step-up bilan bitta so‘rov', (tester) async {
    final (_, lab, id) = await _open(tester);
    lab.sessionsByUser[id] = 3;
    final f = find.byKey(const ValueKey('admin-revoke-sessions'));
    await scrollToFinder(tester, f);
    await doubleTap(tester, f);
    await tester.pumpAndSettle();
    expect(find.text(l.admRevokeSessionsBody), findsOneWidget);
    await tester.tap(find.text(l.admRevokeSessions).last);
    await _frames(tester);
    await _code(tester, FakeAdminConsoleBackend.stepUpCode);
    expect(lab.callCount('adminRevokeSessions'), 1);
    expect(find.text(l.admRevokeSessionsDone(3)), findsOneWidget);
    expect(lab.sessionsByUser, isEmpty);
  });

  testWidgets('hisobni o‘chirish: tasdiq tugmasi ikki marta — bitta so‘rov', (
    tester,
  ) async {
    final (_, lab, _) = await _open(tester);
    lab.requireStepUp = false;
    final field = find.byKey(const ValueKey('admin-delete-email'));
    await scrollToFinder(tester, field);
    await tester.enterText(
      find.descendant(of: field, matching: find.byType(TextField)),
      _user,
    );
    await tester.pumpAndSettle();
    await doubleTap(tester, find.byKey(const ValueKey('admin-delete-account')));
    await tester.pumpAndSettle();
    expect(find.text(l.admDeleteConfirmTitle), findsOneWidget);
    await doubleTap(tester, find.text(l.admDeleteButton));
    await tester.pumpAndSettle();
    expect(lab.callCount('adminDeleteAccount'), 1);
    expect(lab.deletedByAdmin, hasLength(1));
  });
}
