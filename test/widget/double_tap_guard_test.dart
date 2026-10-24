// Ikki marta bosish himoyasi (2026-10-24 auth auditi, 2-talab): tugmani tez
// ikki marta bosish amalni ikki marta bajarmaydi. Har testda birinchi so'rov
// soxta serverda "yo'lda" ushlab turiladi (FakeLabBackend.inFlight), ikkinchi
// bosish shu paytda keladi; natija — serverga aynan BITTA chaqiruv.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/auth/otp_auth.dart';
import 'package:labguide/core/single_flight.dart';
import 'package:labguide/features/auth/social_auth.dart';
import 'package:labguide/features/learn/classes_screens.dart'
    show submitAssignmentSession, SubmitOutcome;
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/double_tap.dart';
import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';
import '../helpers/social_fakes.dart';

final uz = lookupAppLocalizations(const Locale('uz'));

const _tall = Size(390, 1600);

/// Ushlab turilgan so'rovni qo'yib yuboradi va ekranni tinchlantiradi.
Future<void> release(WidgetTester tester, FakeLabBackend b) async {
  b.inFlight?.complete();
  b.inFlight = null;
  await tester.pumpAndSettle();
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.signOut();
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await s.refreshAccess();
  await tester.pumpAndSettle();
}

/// Qayta yuborish kutishsiz (testda soat haqiqiy `DateTime.now`).
class _NoCooldownBackend extends FakeLabBackend {
  @override
  Future<OtpRequestResult> requestCode(String email, {String? language}) async {
    final r = await super.requestCode(email, language: language);
    return OtpRequestResult(r.status, validFor: r.validFor);
  }
}

/// Saqlash "yo'lda" turadi (qurilma xotirasiga yozish sekin bo'lgandek).
class _SlowStore extends MemoryKeyValueStore {
  Completer<void>? hold;

  @override
  Future<void> setString(String key, String value) async {
    final h = hold;
    if (h != null) await h.future;
    return super.setString(key, value);
  }
}

/// Soxta Google: server javobi qo'lda qo'yib yuborilguncha kutadi.
class _HeldSocialBackend extends FakeSocialBackend {
  Completer<void>? hold;

  @override
  Future<SocialSignInResult> socialSignIn(SocialCredential credential) async {
    final h = hold;
    if (h != null) await h.future;
    return super.socialSignIn(credential);
  }
}

void main() {
  setUpAll(loadAppFonts);
  setUp(SingleFlight.reset);

  group('kirish', () {
    testWidgets('“Kod olish” ikki marta — bitta kod so‘rovi', (tester) async {
      final b = FakeLabBackend();
      final s = await makeServices(tester, backend: b);
      await pumpApp(tester, s);
      await goTo(tester, '/profile/auth');
      await enterField(tester, uz.authEmailLabel, 'a@example.com');
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      b.inFlight = Completer<void>();
      await doubleTapText(tester, uz.authGetCode);
      await tester.pump();
      expect(b.callCount('requestCode'), 1);
      await release(tester, b);
      expect(b.callCount('requestCode'), 1);
      expect(find.text(uz.otpTitle), findsOneWidget);
    });

    testWidgets(
      'kod tekshirish: avtomatik (6 raqam) + tugma — bitta tekshiruv',
      (tester) async {
        final b = FakeLabBackend();
        final s = await makeServices(tester, backend: b);
        await pumpApp(tester, s);
        await goTo(tester, '/profile/auth');
        await enterField(tester, uz.authEmailLabel, 'a@example.com');
        await tester.tap(find.byType(Checkbox));
        await tapScroll(tester, uz.authGetCode);
        b.inFlight = Completer<void>();
        // 6-raqam kiritilganda o'zi tekshiradi; tugma ham ikki marta bosiladi.
        await tester.enterText(find.byType(TextField).first, '123456');
        await doubleTapText(tester, uz.otpVerify);
        await tester.pump();
        expect(b.callCount('verifyCode'), 1);
        await release(tester, b);
        expect(b.callCount('verifyCode'), 1);
        expect(s.auth.hasAccount, isTrue);
      },
    );

    testWidgets('“Kodni qayta yuborish” ikki marta — bitta yangi kod', (
      tester,
    ) async {
      final b = _NoCooldownBackend();
      final s = await makeServices(tester, backend: b);
      await pumpApp(tester, s);
      await goTo(tester, '/profile/auth');
      await enterField(tester, uz.authEmailLabel, 'a@example.com');
      await tester.tap(find.byType(Checkbox));
      await tapScroll(tester, uz.authGetCode);
      expect(b.callCount('requestCode'), 1);
      b.inFlight = Completer<void>();
      await doubleTapText(tester, uz.otpResend);
      await tester.pump();
      expect(b.callCount('requestCode'), 2);
      await release(tester, b);
      expect(b.callCount('requestCode'), 2);
    });

    testWidgets('Google ikki marta — bitta oyna va bitta server kirishi', (
      tester,
    ) async {
      final server = _HeldSocialBackend();
      final google = FakeSocialProvider(SocialProvider.google);
      final s = await makeServices(
        tester,
        socialAuth: SocialAuthService(providers: [google], backend: server),
      );
      await pumpApp(tester, s);
      await goTo(tester, '/profile/auth');
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      server.hold = Completer<void>();
      await doubleTap(tester, find.byKey(const ValueKey('social-google')));
      await tester.pump();
      expect(google.calls, 1);
      server.hold!.complete();
      await tester.pumpAndSettle();
      expect(google.calls, 1);
      expect(server.signIns, hasLength(1));
    });

    testWidgets('“Mehmon sifatida” ikki marta — rol ekrani bitta', (
      tester,
    ) async {
      final s = await makeServices(tester, onboarded: false, role: null);
      await pumpApp(tester, s);
      await goTo(tester, '/welcome');
      await doubleTapText(tester, uz.welcomeGuest);
      await tester.pumpAndSettle();
      expect(find.text(uz.rolesTitle), findsOneWidget);
      // Orqaga bir marta — Welcome (ikkinchi rol sahifasi yo'q).
      routerOf(tester).pop();
      await tester.pumpAndSettle();
      expect(find.text(uz.rolesTitle), findsNothing);
    });
  });

  group('profil', () {
    testWidgets('chiqish ikki marta — bitta dialog', (tester) async {
      final b = FakeLabBackend();
      final s = await makeServices(tester, backend: b);
      await pumpApp(tester, s);
      await _signIn(tester, s, 'a@example.com');
      await goTo(tester, '/profile');
      await doubleTapText(tester, uz.profileSignOut);
      await tester.pumpAndSettle();
      expect(find.text(uz.profileSignOutTitle), findsOneWidget);
      await tester.tap(find.text(uz.profileSignOut).last);
      await tester.pumpAndSettle();
      expect(b.callCount('signOut'), 1);
      expect(find.text(uz.profileSignOutTitle), findsNothing);
    });

    testWidgets(
      'hamma qurilmalardan chiqish: bitta so‘rov, bu qurilmada ham chiqiladi',
      (tester) async {
        final b = FakeLabBackend();
        final s = await makeServices(tester, backend: b);
        await pumpApp(tester, s);
        await _signIn(tester, s, 'a@example.com');
        await goTo(tester, '/profile');
        await doubleTap(
          tester,
          find.byKey(const ValueKey('profile-sign-out-all')),
        );
        await tester.pumpAndSettle();
        expect(find.text(uz.profileSignOutAllBody), findsOneWidget);
        b.inFlight = Completer<void>();
        await doubleTap(
          tester,
          find.byKey(const ValueKey('sign-out-all-confirm')),
        );
        await tester.pump();
        expect(b.callCount('signOutEverywhere'), 1);
        await release(tester, b);
        expect(b.callCount('signOutEverywhere'), 1);
        expect(s.auth.hasAccount, isFalse);
        expect(b.hasSession, isFalse);
      },
    );

    testWidgets('mehmonda “hamma qurilmalardan chiqish” ko‘rinmaydi', (
      tester,
    ) async {
      final s = await makeServices(tester, backend: FakeLabBackend());
      await pumpApp(tester, s);
      await goTo(tester, '/profile');
      expect(find.byKey(const ValueKey('profile-sign-out-all')), findsNothing);
    });

    testWidgets('hisobni o‘chirish ikki marta — bitta dialog, bitta so‘rov', (
      tester,
    ) async {
      final b = FakeLabBackend();
      final s = await makeServices(tester, backend: b);
      await pumpApp(tester, s);
      await _signIn(tester, s, 'a@example.com');
      await goTo(tester, '/profile/privacy');
      await doubleTapText(tester, uz.accountDelete);
      await tester.pumpAndSettle();
      expect(find.text(uz.accountDeleteTitle), findsOneWidget);
      b.inFlight = Completer<void>();
      await doubleTapText(tester, uz.actionDelete);
      await tester.pump();
      expect(b.callCount('deleteAccount'), 1);
      await release(tester, b);
      expect(b.callCount('deleteAccount'), 1);
      expect(s.auth.hasAccount, isFalse);
    });
  });

  group('guruhlar', () {
    Future<({String gid, String code})> prepare(
      WidgetTester tester,
      AppServices s,
      FakeLabBackend b,
    ) async {
      await _signIn(tester, s, 'teacher@example.com');
      await b.registerTeacher();
      final g = await b.createGroup('Biokimyo');
      return (gid: g.id, code: g.joinCode!);
    }

    testWidgets('guruh yaratish ikki marta — bitta guruh', (tester) async {
      final b = FakeLabBackend();
      final s = await makeServices(tester, backend: b, role: AppRole.teacher);
      await pumpApp(tester, s, size: _tall);
      await _signIn(tester, s, 'teacher@example.com');
      await b.registerTeacher();
      await s.refreshAccess();
      await goTo(tester, '/learn/classes');
      await tapScroll(tester, uz.classesCreate);
      await enterField(tester, uz.classesGroupName, 'Biokimyo 2-kurs');
      b.inFlight = Completer<void>();
      await doubleTapText(tester, uz.classesCreateAction);
      await tester.pump();
      expect(b.callCount('createGroup'), 1);
      await release(tester, b);
      expect(await b.myGroups(), hasLength(1));
    });

    testWidgets('kod bilan qo‘shilish ikki marta — bitta so‘rov', (
      tester,
    ) async {
      final b = FakeLabBackend();
      final s = await makeServices(tester, backend: b);
      await pumpApp(tester, s, size: _tall);
      final t = await prepare(tester, s, b);
      await _signIn(tester, s, 'student@example.com');
      await goTo(tester, '/learn/classes/join');
      await tester.enterText(find.byType(TextField).first, t.code);
      await enterField(tester, uz.classesDisplayName, 'Aliyev Anvar');
      b.inFlight = Completer<void>();
      await doubleTapText(tester, uz.classesJoinAction);
      await tester.pump();
      expect(b.callCount('joinGroup'), 1);
      await release(tester, b);
      expect(b.callCount('joinGroup'), 1);
      expect(find.text(uz.classesYouStudent), findsOneWidget);
    });

    testWidgets(
      'QR havola (/j?c=) bilan qo‘shilish ikki marta — bitta so‘rov',
      (tester) async {
        final b = FakeLabBackend();
        final s = await makeServices(tester, backend: b);
        await pumpApp(tester, s, size: _tall);
        final t = await prepare(tester, s, b);
        await _signIn(tester, s, 'student@example.com');
        await goTo(tester, '/j?c=${t.code}');
        await enterField(tester, uz.classesDisplayName, 'Talaba');
        b.inFlight = Completer<void>();
        await doubleTapText(tester, uz.classesJoinAction);
        await tester.pump();
        expect(b.callCount('joinGroup'), 1);
        await release(tester, b);
        expect(b.callCount('joinGroup'), 1);
      },
    );

    testWidgets(
      'talabani chiqarish va guruhni o‘chirish — bitta dialog, bitta so‘rov',
      (tester) async {
        final b = FakeLabBackend();
        final s = await makeServices(tester, backend: b);
        await pumpApp(tester, s, size: _tall);
        final t = await prepare(tester, s, b);
        await _signIn(tester, s, 's1@example.com');
        await b.joinGroup(t.code, displayName: 'Birinchi T.');
        await _signIn(tester, s, 'teacher@example.com');
        await goTo(tester, '/learn/classes/g/${t.gid}');
        await doubleTap(tester, find.byTooltip(uz.classesRemove));
        await tester.pumpAndSettle();
        expect(find.text(uz.classesRemoveTitle('Birinchi T.')), findsOneWidget);
        await doubleTapText(tester, uz.classesRemoveAction);
        await tester.pumpAndSettle();
        expect(b.callCount('removeMember'), 1);
        expect(find.text(uz.classesRemoveTitle('Birinchi T.')), findsNothing);

        await doubleTap(tester, find.byKey(const ValueKey('group-delete')));
        await tester.pumpAndSettle();
        expect(
          find.text(uz.classesDeleteGroupTitle('Biokimyo')),
          findsOneWidget,
        );
        b.inFlight = Completer<void>();
        await doubleTapText(tester, uz.classesDeleteGroupAction);
        await tester.pump();
        expect(b.callCount('deleteGroup'), 1);
        await release(tester, b);
        expect(b.callCount('deleteGroup'), 1);
        expect(await b.myGroups(), isEmpty);
      },
    );

    testWidgets('umumiy test berish ikki marta — guruhga bitta topshiriq', (
      tester,
    ) async {
      final b = FakeLabBackend();
      final s = await makeServices(tester, backend: b, role: AppRole.teacher);
      await pumpApp(tester, s, size: _tall);
      final t = await prepare(tester, s, b);
      await s.refreshAccess();
      await goTo(tester, '/learn/classes/g/${t.gid}');
      await tapScroll(tester, uz.classesGiveGeneralTest);
      await tapScroll(tester, 'Buyrak funksiyasi · 8');
      await enterField(tester, uz.examCount, '3');
      b.inFlight = Completer<void>();
      await doubleTapText(tester, uz.classesSendAssignment);
      await tester.pump();
      expect(b.callCount('createAssignment'), 1);
      await release(tester, b);
      expect(b.callCount('createAssignment'), 1);
      expect(await b.assignments(t.gid), hasLength(1));
    });

    testWidgets(
      'javoblarni yuborish: bir vaqtdagi ikki chaqiruv — bitta so‘rov, ikkalasi “yuborildi”',
      (tester) async {
        final b = FakeLabBackend();
        final s = await makeServices(tester, backend: b);
        await pumpApp(tester, s, size: _tall);
        final t = await prepare(tester, s, b);
        final qs = s.content.pack!.quiz.take(3).toList();
        final aid = await b.createAssignment(
          groupId: t.gid,
          title: 'Topshiriq 1',
          questionIds: [for (final q in qs) q.id],
          correctIndexes: [for (final q in qs) q.correctIndex],
        );
        await _signIn(tester, s, 'student@example.com');
        await b.joinGroup(t.code, displayName: 'Talaba');
        await goTo(tester, '/learn/classes/g/${t.gid}/a/$aid');
        await tapScroll(tester, uz.classesStart);
        final run = s.exams.assignmentSession(aid, b.userId)!;
        await answerCurrent(tester, s, run, correct: true);
        await tester.runAsync(() => s.exams.finishAssignment(run));
        b.inFlight = Completer<void>();
        final first = submitAssignmentSession(s, run);
        final second = submitAssignmentSession(s, run);
        await tester.pump();
        expect(b.callCount('submitAssignment'), 1);
        b.inFlight!.complete();
        b.inFlight = null;
        final outcomes = await tester.runAsync(
          () => Future.wait([first, second]),
        );
        expect(outcomes, [SubmitOutcome.sent, SubmitOutcome.sent]);
        expect(b.callCount('submitAssignment'), 1);
        expect(await b.submissions(aid), hasLength(1));
      },
    );
  });

  testWidgets('kalibrlash yozuvi: “Saqlash” ikki marta — bitta yozuv', (
    tester,
  ) async {
    final store = _SlowStore();
    final s = await makeServices(tester, store: store);
    final mine = await tester.runAsync(
      () => s.instruments.addFromCatalog('human-humalyzer-4000'),
    );
    await pumpApp(tester, s);
    await goTo(
      tester,
      '/lab/calibration?mine=${mine!.id}&analyte=glucose-plasma-fasting',
    );
    await enterField(tester, uz.calReagentRef, '10121');
    await enterField(tester, uz.calIfuRevision, '2024-01');
    await tapScroll(tester, uz.calShowGuide);
    await tapScroll(tester, uz.calRecordCreate);
    await enterField(tester, uz.calCalibratorLot, 'L-77');
    await enterField(tester, uz.calLevelUnit, 'mmol/L');
    await enterField(tester, uz.calLevelValue, '5,55');
    store.hold = Completer<void>();
    await doubleTapText(tester, uz.calRecordSave);
    await tester.pump();
    store.hold!.complete();
    store.hold = null;
    await tester.pumpAndSettle();
    expect(s.instruments.records, hasLength(1));
  });
}
