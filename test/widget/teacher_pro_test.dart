// Ustoz Pro (D-78): test yaratish, topshirish, taklifnoma, natijalar va
// talaba tomoni — UI, gate holatlari (yopiq / sinov / obuna / muddati
// o'tgan / oflayn kesh / mehmon), maxfiylik ogohlantirishi va bepul
// guruhlar o'zgarmagani. Server qoidalari: cloudflare/test/teachertests.test.ts.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/teacher_tests.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/entitlement_service.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/profile/purchase_screen.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/teacher_pro/student_teacher_tests_screens.dart';
import 'package:labguide/features/teacher_pro/teacher_pro_common.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/billing_fakes.dart';
import '../helpers/fake_backend.dart';
import '../helpers/fake_teacher_tests.dart';
import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));
final ru = lookupAppLocalizations(const Locale('ru'));
final en = lookupAppLocalizations(const Locale('en'));

const _tall = Size(390, 2400);

/// Server huquqi holatlari (D-78 / D-76).
enum Ent { free, trialTeacher, teacher, premium, student, expired, offline }

EntitlementSnapshot _snap(Ent e) {
  final now = DateTime.now().toUtc();
  ServerEntitlement store(
    String product, {
    Duration left = const Duration(days: 30),
  }) => ServerEntitlement(
    productId: product,
    platform: 'app_store',
    status: EntitlementStatus.active,
    startedAt: now.subtract(const Duration(days: 1)),
    expiresAt: now.add(left),
  );
  return EntitlementSnapshot(
    serverTime: now,
    items: switch (e) {
      Ent.free => const [],
      Ent.trialTeacher => [
        ServerEntitlement(
          productId: 'trial.teacher',
          platform: 'trial',
          source: ServerEntitlement.trialSource,
          plan: ProPlan.teacher,
          status: EntitlementStatus.active,
          startedAt: now,
          expiresAt: now.add(
            const Duration(days: ProTrialConfig.serverTrialDays),
          ),
          ownership: 'trial',
        ),
      ],
      Ent.teacher || Ent.offline => [store(BillingCatalog.teacherMonthly)],
      Ent.premium => [store(BillingCatalog.premiumMonthly)],
      Ent.student => [store(BillingCatalog.studentMonthly)],
      Ent.expired => [
        store(BillingCatalog.premiumMonthly, left: const Duration(days: -2)),
      ],
    },
  );
}

class _Env {
  _Env(this.s, this.b, this.source);
  final AppServices s;
  final FakeTeacherLabBackend b;
  final FakeEntitlementSource source;
  FakeTeacherTests get api => b.teacherTestApi;
}

/// Pro yoqilgan do'kon build: soxta do'kon va server, butun Ustoz Pro
/// katalogi yopiq ([ProGatePolicy.gated]) — huquq [ent] bo'yicha.
Future<_Env> _env(
  WidgetTester tester, {
  Ent ent = Ent.premium,
  AppLanguage language = AppLanguage.uz,
  AppRole role = AppRole.teacher,
  bool guest = false,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final b = FakeTeacherLabBackend();
  final source = FakeEntitlementSource(user: guest ? null : 'user-a')
    ..snapshot = _snap(ent);
  final s = await makeServices(
    tester,
    backend: b,
    role: role,
    language: language,
    themeMode: themeMode,
    proEnabled: true,
    allFeaturesOpen: false,
    gatedFeatures: ProGatePolicy.gated,
    purchases: FakePurchaseAdapter(),
    entitlementSource: source,
  );
  await s.entitlements.refresh();
  if (ent == Ent.offline) {
    // Ilova qayta ochildi, internet yo'q: imzolangan kesh muddati tugamagan.
    source.error = const EntitlementException(EntitlementFailure.network);
    await s.entitlements.load();
    await s.entitlements.refresh();
  }
  return _Env(s, b, source);
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.signOut();
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

const _teacher = 'ustoz@example.test';
const _student = 'talaba@example.test';
const _student2 = 'talaba2@example.test';

/// Ustoz (ro'yxatdan o'tgan) + guruh; talaba kod bilan qo'shilgan (bepul oqim).
Future<String> _group(
  WidgetTester tester,
  _Env e, {
  List<String> students = const [_student],
}) async {
  await _signIn(tester, e.s, _teacher);
  await e.b.registerTeacher();
  final g = await e.b.createGroup(
    'Lab-21 guruhi',
    displayName: 'Ustoz Karimova',
  );
  for (final st in students) {
    await _signIn(tester, e.s, st);
    await e.b.joinGroup(g.joinCode!);
  }
  await _signIn(tester, e.s, _teacher);
  return g.id;
}

TtQuestion _q(String text, int correct, {String? explanation}) => TtQuestion(
  text: text,
  options: ['$text A', '$text B', '$text C'],
  correct: correct,
  explanation: explanation,
);

/// Ustoz nomidan nashr etilgan test va topshiriq (server orqali).
Future<(String, String)> _assigned(
  _Env e,
  String groupId, {
  int attempts = 1,
  int? limit,
  Duration due = const Duration(days: 3),
}) async {
  final t = await e.api.createTeacherTest(
    TeacherTestInput(
      title: 'Gematologiya: nazorat',
      questions: [
        _q('Eritrotsit', 0, explanation: 'Izoh 1'),
        _q('Leykotsit', 1),
      ],
      published: true,
      passPercent: 50,
      timeLimitMinutes: limit,
    ),
  );
  final a = await e.api.assignTeacherTest(
    t.id,
    groupId: groupId,
    dueAt: DateTime.now().add(due),
    maxAttempts: attempts,
  );
  return (t.id, a.id);
}

bool _purchaseOpen() => find.byType(PurchaseScreen).evaluate().isNotEmpty;

void main() {
  setUpAll(loadAppFonts);

  group('Pro bayrog‘i o‘chiq (standart, bepul reliz)', () {
    testWidgets('Ustoz Pro yo‘q: servis null, Guruhlar ekranida qator yo‘q, '
        'yo‘l yo‘q', (tester) async {
      final b = FakeTeacherLabBackend();
      final s = await makeServices(tester, backend: b, role: AppRole.teacher);
      await pumpApp(tester, s, size: _tall);
      expect(s.teacherTests, isNull);
      await _signIn(tester, s, _teacher);
      await b.registerTeacher();
      await b.createGroup('Bepul guruh');
      await goTo(tester, '/learn/classes');
      expect(find.text('Bepul guruh'), findsOneWidget);
      for (final k in [
        'classes-tt-teacher',
        'classes-tt-student',
        'classes-tt-invite',
      ]) {
        expect(find.byKey(ValueKey(k)), findsNothing, reason: k);
      }
      expect(find.text(uz.ttEntrySection), findsNothing);
      await goTo(tester, TtRoutes.tests);
      expect(find.text(uz.ttTestsTitle), findsNothing);
    });
  });

  group('ustoz: test yaratish (teacherTestBuilder) — gate holatlari', () {
    for (final (ent, open) in [
      (Ent.free, false),
      (Ent.student, false),
      (Ent.expired, false),
      (Ent.trialTeacher, true),
      (Ent.teacher, true),
      (Ent.premium, true),
      (Ent.offline, true),
    ]) {
      testWidgets(
        '${ent.name}: “Yangi test” → ${open ? 'muharrir' : 'to‘lov oynasi'}',
        (tester) async {
          final e = await _env(tester, ent: ent);
          await pumpApp(tester, e.s, size: _tall);
          await _signIn(tester, e.s, _teacher);
          await e.b.registerTeacher();
          await goTo(tester, TtRoutes.tests);
          expect(e.s.entitlements.gatingActive, isTrue);
          expect(e.s.entitlements.can(Feature.teacherTestBuilder), open);
          if (ent == Ent.offline) {
            expect(e.s.entitlements.proSource, ProSource.offlineCache);
          }
          expect(
            find.text(uz.proTtLockedNote),
            open ? findsNothing : findsOneWidget,
          );
          await tester.tap(find.byKey(const ValueKey('tt-new')));
          await tester.pumpAndSettle();
          expect(_purchaseOpen(), !open);
          expect(
            find.byKey(const ValueKey('tt-field-title')),
            open ? findsOneWidget : findsNothing,
          );
          if (!open) {
            // To'lov oynasida Ustoz Pro imkoniyati ko'rsatiladi.
            expect(find.text(uz.proFeatTeacherTestBuilder), findsWidgets);
          }
        },
      );
    }

    testWidgets(
      'mehmon: Ustoz testlari — kirish taklifi, xato yo‘q; can = false',
      (tester) async {
        final e = await _env(tester, guest: true);
        await pumpApp(tester, e.s, size: _tall);
        expect(e.s.entitlements.can(Feature.teacherTestBuilder), isFalse);
        expect(e.s.entitlements.can(Feature.teacherTests), isFalse);
        for (final r in [TtRoutes.tests, TtRoutes.mine, TtRoutes.invite()]) {
          await goTo(tester, r);
          expect(find.text(uz.classesSignInTitle), findsOneWidget, reason: r);
          expect(tester.takeException(), isNull);
        }
        expect(e.api.calls, isEmpty);
      },
    );

    testWidgets(
      'obuna yo‘q, lekin avval yaratilgan testlar va natijalar ko‘rinadi '
      '(D-78 §7)',
      (tester) async {
        final e = await _env(tester);
        await pumpApp(tester, e.s, size: _tall);
        final gid = await _group(tester, e);
        final (tid, aid) = await _assigned(e, gid);
        // Obuna tugadi.
        e.source.snapshot = _snap(Ent.expired);
        await e.s.entitlements.refresh();
        expect(e.s.entitlements.can(Feature.teacherTestBuilder), isFalse);
        await goTo(tester, TtRoutes.tests);
        expect(find.text('Gematologiya: nazorat'), findsOneWidget);
        await goTo(tester, TtRoutes.test(tid));
        expect(find.text('Eritrotsit'), findsOneWidget);
        await goTo(tester, TtRoutes.results(aid));
        expect(find.text(uz.ttSummaryTitle), findsOneWidget);
        // Eksport — yangi pullik amal: to'lov oynasi, server chaqirilmaydi.
        await tapScroll(tester, uz.ttExportCsv);
        expect(_purchaseOpen(), isTrue);
        expect(e.api.calls, isNot(contains('exportTeacherResults')));
      },
    );

    testWidgets('server reja yetmasligini aytsa (client gate eskirgan) — '
        'to‘lov oynasi, forma yo‘qolmaydi', (tester) async {
      final e = await _env(tester, ent: Ent.teacher);
      e.api.allows = (_, cap) => cap != 'teacher_panel';
      await pumpApp(tester, e.s, size: _tall);
      await _signIn(tester, e.s, _teacher);
      await e.b.registerTeacher();
      await goTo(tester, TtRoutes.newTest);
      await enterField(tester, uz.ttFieldTitle, 'Server yopgan test');
      await tapScroll(tester, uz.ttSave);
      expect(e.api.calls, contains('createTeacherTest'));
      expect(_purchaseOpen(), isTrue);
      routerOf(tester).pop();
      await tester.pumpAndSettle();
      expect(find.text('Server yopgan test'), findsOneWidget);
    });
  });

  group('ustoz → talaba: to‘liq oqim', () {
    testWidgets('yaratish (o‘z savoli + ilova banki nusxasi) → nashr → '
        'topshirish → talaba ogohlantirish bilan yechadi → natija va CSV', (
      tester,
    ) async {
      final e = await _env(tester);
      await pumpApp(tester, e.s, size: _tall);
      await _group(tester, e);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      // Guruhlar → Mening testlarim.
      await goTo(tester, '/learn/classes');
      await tapScroll(tester, uz.ttEntryTeacher);
      expect(find.text(uz.ttTestsEmpty), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tt-new')));
      await tester.pumpAndSettle();
      await enterField(tester, uz.ttFieldTitle, 'Qon tahlili: 1-nazorat');
      await enterField(tester, uz.ttFieldPassPercent, '50');

      // O'z savoli (dialog).
      await tapScroll(tester, uz.ttAddQuestion);
      await tester.enterText(
        find.byKey(const ValueKey('tt-dialog-text')),
        'Gemoglobin me’yori?',
      );
      await tester.enterText(
        find.byKey(const ValueKey('tt-dialog-option-0')),
        '80 g/L',
      );
      await tester.enterText(
        find.byKey(const ValueKey('tt-dialog-option-1')),
        '130 g/L',
      );
      // Takroriy variant — rad etiladi.
      await tester.enterText(
        find.byKey(const ValueKey('tt-dialog-option-2')),
        '80 g/L',
      );
      await tester.tap(find.byKey(const ValueKey('tt-dialog-correct-1')));
      await tester.tap(find.byKey(const ValueKey('tt-dialog-done')));
      await tester.pumpAndSettle();
      expect(find.text(uz.ttErrDuplicateOptions), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('tt-dialog-option-2')),
        '200 g/L',
      );
      await tester.tap(find.byKey(const ValueKey('tt-dialog-done')));
      await tester.pumpAndSettle();
      expect(find.text('Gemoglobin me’yori?'), findsOneWidget);

      // Ilova bankidan nusxa (manba saqlanadi).
      await tapScroll(tester, uz.ttAddFromBank);
      expect(find.text(uz.ttBankTitle), findsOneWidget);
      final first = find.byType(CheckboxListTile).first;
      await tester.tap(first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tt-bank-add')));
      await tester.pumpAndSettle();
      expect(find.textContaining(uz.ttFromBank('')), findsOneWidget);

      // Nashr etilmagan bo'sh nomli test saqlanmaydi; nom bilan — saqlanadi.
      await tester.tap(find.byKey(const ValueKey('tt-publish')));
      await tester.pumpAndSettle();
      await tapScroll(tester, uz.ttSave);
      expect(find.text('Qon tahlili: 1-nazorat'), findsOneWidget);
      final saved = (await e.api.teacherTests()).single;
      expect(saved.published, isTrue);
      final full = await e.api.teacherTest(saved.id);
      expect(full.questions, hasLength(2));
      expect(full.questions![0].correct, 1);
      expect(full.questions![1].source, isNotNull, reason: 'manba saqlanadi');
      expect(full.passPercent, 50);
      // Lokal kesh — oflayn ro'yxat.
      expect(e.s.teacherTestCache.tests(e.b.userId), isNotEmpty);

      // Test → Topshirish (butun guruhga, 3 kun).
      await tapScroll(tester, 'Qon tahlili: 1-nazorat');
      await tester.tap(find.byKey(const ValueKey('tt-assign')));
      await tester.pumpAndSettle();
      expect(find.text('Lab-21 guruhi'), findsOneWidget);
      await tapScroll(tester, uz.ttAssignSubmit);
      expect(e.api.calls, contains('assignTeacherTest'));
      expect(find.text(uz.ttAssignmentsTitle), findsOneWidget);
      final aid = (await e.api.teacherAssignments()).single.id;

      // Talaba: Guruhlar → Ustoz testlari → test → ogohlantirish → yechish.
      await _signIn(tester, e.s, _student);
      await goTo(tester, '/learn/classes');
      // Guruh a'zosi — “Ustoz testlari” qatori bor.
      expect(find.byKey(const ValueKey('classes-tt-student')), findsOneWidget);
      await tapScroll(tester, uz.ttEntryStudent);
      await tapScroll(tester, 'Qon tahlili: 1-nazorat');
      expect(find.text(uz.ttVisibleNoticeTitle), findsOneWidget);
      expect(find.text(uz.ttVisibleNotice), findsOneWidget);
      await tapScroll(tester, uz.ttStart);
      expect(find.byType(TtRunScreen), findsOneWidget);
      // Javob qurilmada saqlanadi.
      await tester.tap(find.byKey(const ValueKey('tt-run-option-1')));
      await tester.pumpAndSettle();
      final run = (await e.api.myTeacherTest(aid)).openAttemptId!;
      expect(e.s.teacherTestCache.answers(run, 2), [1, -1]);
      await tester.tap(find.byKey(const ValueKey('tt-run-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tt-run-submit')));
      await tester.pumpAndSettle();
      // Birinchi topshirishdan oldin — "ustozga ko'rinadi".
      expect(find.textContaining(uz.ttSubmitVisible), findsOneWidget);
      expect(find.textContaining(uz.ttSubmitUnanswered(1)), findsOneWidget);
      await tester.tap(find.text(uz.ttSubmit).last);
      await tester.pumpAndSettle();
      expect(find.byType(TtRunScreen), findsNothing);
      expect(find.text(uz.ttSubmittedSnack(1, 2)), findsOneWidget);
      // Bitta urinish — javoblar va izoh ochiladi; ogohlantirish endi yo'q.
      expect(find.text(uz.ttVisibleNoticeTitle), findsNothing);
      expect(find.textContaining(uz.ttYourAnswer), findsWidgets);
      expect(find.byKey(const ValueKey('tt-start')), findsNothing);
      expect(e.s.teacherTestCache.answers(run, 2), isNull);

      // Ustoz: natijalar va CSV.
      await _signIn(tester, e.s, _teacher);
      await goTo(tester, TtRoutes.results(aid));
      expect(find.text(uz.classesSeat('01')), findsOneWidget);
      expect(find.textContaining('1/2 (50%)'), findsOneWidget);
      expect(find.text(uz.ttPrivacyTeacher), findsOneWidget);
      await tapScroll(tester, uz.ttExportCsv);
      expect(copied, contains('student,state,attempts'));
      expect(copied, isNot(contains('@example.test')));
      expect(find.text(uz.ttExportCopied), findsOneWidget);
    });

    testWidgets(
      'taklifnoma: ustoz yaratadi; talaba roziliksiz qo‘shila '
      'olmaydi, rozilik bilan — guruh a’zosi; rad etish hech narsa yozmaydi',
      (tester) async {
        final e = await _env(tester);
        await pumpApp(tester, e.s, size: _tall);
        await _group(tester, e, students: const []);
        await goTo(tester, TtRoutes.invites);
        await tester.tap(find.byKey(const ValueKey('tt-inv-days-30')));
        await tapScroll(tester, uz.ttInviteCreate);
        final inv = (await e.api.groupInvites((await e.b.myGroups()).single.id))
            .single;
        expect(find.text(TtInviteCode.format(inv.token)), findsOneWidget);

        await _signIn(tester, e.s, _student);
        await goTo(tester, '/learn/classes');
        await tapScroll(tester, uz.ttEntryInvite);
        await enterField(
          tester,
          uz.ttInviteCodeField,
          TtInviteCode.format(inv.token).toLowerCase(),
        );
        await tapScroll(tester, uz.ttInviteCheck);
        expect(find.text('Lab-21 guruhi'), findsOneWidget);
        expect(find.text(uz.ttInviteConsentBody), findsOneWidget);
        final accept = tester.widget<LgButton>(
          find.byKey(const ValueKey('tt-invite-accept')),
        );
        expect(accept.onPressed, isNull, reason: 'roziliksiz tugma faol emas');
        // Rad etish — server chaqirilmaydi.
        await tapScroll(tester, uz.ttInviteDecline);
        expect(e.api.calls, isNot(contains('acceptInvite')));
        expect(await e.b.myGroups(), isEmpty);

        await goTo(tester, TtRoutes.invite(inv.token));
        await tapScroll(tester, uz.ttInviteConsentCheck);
        await tapScroll(tester, uz.ttInviteAccept);
        expect(e.api.calls, contains('acceptInvite'));
        expect((await e.b.myGroups()).single.name, 'Lab-21 guruhi');
        expect(find.text(uz.ttInviteJoined), findsOneWidget);
        expect(
          find.text('Lab-21 guruhi'),
          findsWidgets,
          reason: 'guruh sahifasi',
        );
      },
    );

    testWidgets('bitta talabaga topshiriq — boshqa talaba ko‘rmaydi; guruhdagi '
        'talaba uchun Ustoz testlari qatori bor', (tester) async {
      final e = await _env(tester);
      await pumpApp(tester, e.s, size: _tall);
      final gid = await _group(
        tester,
        e,
        students: const [_student, _student2],
      );
      final members = await e.b.groupMembers(gid);
      final target = members.firstWhere((m) => !m.isTeacher);
      final t = await e.api.createTeacherTest(
        TeacherTestInput(
          title: 'Shaxsiy test',
          questions: [_q('Savol', 0)],
          published: true,
        ),
      );
      await goTo(tester, TtRoutes.assign(t.id));
      await tester.tap(find.byKey(ValueKey('tt-who-${target.userId}')));
      await tester.pumpAndSettle();
      await tapScroll(tester, uz.ttAssignSubmit);
      expect((await e.api.teacherAssignments()).single.userId, target.userId);
      await _signIn(tester, e.s, _student2);
      expect(await e.api.myTeacherTests(), isEmpty);
      await goTo(tester, TtRoutes.mine);
      expect(find.text(uz.ttMyEmpty), findsOneWidget);
      await _signIn(tester, e.s, _student);
      await goTo(tester, TtRoutes.mine);
      expect(find.text('Shaxsiy test'), findsOneWidget);
    });
  });

  group('talaba: Ustoz testini boshlash (teacherTests, learner) — gate holatlari', () {
    for (final (ent, open) in [
      (Ent.free, false),
      (Ent.expired, false),
      (Ent.student, true),
      (Ent.premium, true),
      (Ent.offline, true),
    ]) {
      testWidgets(
        '${ent.name}: “Testni boshlash” → ${open ? 'yechish' : 'to‘lov oynasi'}',
        (tester) async {
          final e = await _env(tester, ent: ent, role: AppRole.student);
          await pumpApp(tester, e.s, size: _tall);
          final gid = await _group(tester, e);
          final (_, aid) = await _assigned(e, gid);
          await _signIn(tester, e.s, _student);
          await goTo(tester, TtRoutes.myTest(aid));
          expect(find.text(uz.ttVisibleNoticeTitle), findsOneWidget);
          expect(
            find.text(uz.proTtStudentLocked),
            open ? findsNothing : findsOneWidget,
          );
          await tapScroll(tester, uz.ttStart);
          expect(_purchaseOpen(), !open);
          expect(
            find.byType(TtRunScreen),
            open ? findsOneWidget : findsNothing,
          );
          expect(e.api.calls.contains('startTeacherTest'), open);
        },
      );
    }

    testWidgets('boshlangan urinish: obuna o‘rtada tugasa ham “Davom ettirish” '
        'gate’siz, topshiriladi', (tester) async {
      final e = await _env(tester, ent: Ent.student, role: AppRole.student);
      await pumpApp(tester, e.s, size: _tall);
      final gid = await _group(tester, e);
      final (_, aid) = await _assigned(e, gid, limit: 30);
      await _signIn(tester, e.s, _student);
      await goTo(tester, TtRoutes.myTest(aid));
      await tapScroll(tester, uz.ttStart);
      expect(find.byKey(const ValueKey('tt-run-timer')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tt-run-option-0')));
      await tester.pumpAndSettle();
      // Ortga — urinish ochiq qoladi; obuna tugadi.
      routerOf(tester).pop();
      await tester.pumpAndSettle();
      e.source.snapshot = _snap(Ent.expired);
      await e.s.entitlements.refresh();
      expect(e.s.entitlements.can(Feature.teacherTests), isFalse);
      e.api.allows = (_, cap) => cap != 'learner';
      await goTo(tester, TtRoutes.mine);
      await goTo(tester, TtRoutes.myTest(aid));
      expect(find.text(uz.ttContinue), findsOneWidget);
      expect(find.text(uz.proTtStudentLocked), findsNothing);
      await tapScroll(tester, uz.ttContinue);
      expect(_purchaseOpen(), isFalse);
      expect(find.byType(TtRunScreen), findsOneWidget);
      // Qurilmada saqlangan javob qaytdi.
      final run = (await e.api.myTeacherTest(aid)).openAttemptId!;
      expect(e.s.teacherTestCache.answers(run, 2), [0, -1]);
      await tester.tap(find.byKey(const ValueKey('tt-run-submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(uz.ttSubmit).last);
      await tester.pumpAndSettle();
      expect(e.api.calls, contains('submitTeacherTest'));
      expect(find.text(uz.ttSubmittedSnack(1, 2)), findsOneWidget);
    });

    testWidgets(
      'muddat o‘tgan / urinish tugagan — boshlash tugmasi yo‘q, sabab '
      'ko‘rsatiladi',
      (tester) async {
        final e = await _env(tester, role: AppRole.student);
        await pumpApp(tester, e.s, size: _tall);
        final gid = await _group(tester, e);
        final (_, aid) = await _assigned(
          e,
          gid,
          due: const Duration(minutes: 30),
        );
        e.b.groupClock = () => DateTime.now().add(const Duration(hours: 2));
        await _signIn(tester, e.s, _student);
        await goTo(tester, TtRoutes.myTest(aid));
        expect(find.text(uz.ttCantPastDue), findsOneWidget);
        expect(find.byKey(const ValueKey('tt-start')), findsNothing);
        expect(find.text(uz.ttStateExpired), findsOneWidget);
      },
    );
  });

  group('bepul guruhlar — o‘zgarmagan (Pro yoqilgan, obunasiz)', () {
    testWidgets('guruh ochish, kod bilan qo‘shilish va bepul guruh sahifasi '
        'to‘lov oynasisiz; Ustoz Pro qatorlari qo‘shimcha', (tester) async {
      final e = await _env(tester, ent: Ent.free);
      await pumpApp(tester, e.s, size: _tall);
      await _signIn(tester, e.s, _teacher);
      await e.b.registerTeacher();
      await goTo(tester, '/learn/classes');
      // Bepul tugmalar joyida.
      expect(find.text(uz.classesCreate), findsOneWidget);
      expect(find.text(uz.classesJoin), findsOneWidget);
      await tester.tap(find.text(uz.classesCreate).first);
      await tester.pumpAndSettle();
      await enterField(tester, uz.classesGroupName, 'Bepul guruh');
      await tapScroll(tester, uz.classesCreateAction);
      expect(_purchaseOpen(), isFalse);
      final g = (await e.b.myGroups()).single;
      expect(g.name, 'Bepul guruh');
      await goTo(tester, '/learn/classes/g/${g.id}');
      expect(_purchaseOpen(), isFalse);
      expect(find.text('Bepul guruh'), findsWidgets);
      await goTo(tester, '/learn/classes');
      expect(find.byKey(const ValueKey('classes-tt-teacher')), findsOneWidget);
      expect(find.byKey(const ValueKey('classes-tt-invite')), findsOneWidget);
      // Guruhga a'zo bo'lmagan talabaga bo'sh "Ustoz testlari" qatori yo'q.
      await _signIn(tester, e.s, _student);
      await goTo(tester, '/learn/classes');
      expect(find.byKey(const ValueKey('classes-tt-student')), findsNothing);
      await e.b.joinGroup(g.joinCode!);
      // Hisob almashganda ro'yxat qayta yuklanadi (bepul ekran xatti-harakati).
      await _signIn(tester, e.s, _teacher);
      await _signIn(tester, e.s, _student);
      expect(find.byKey(const ValueKey('classes-tt-student')), findsOneWidget);
    });
  });

  group(
    'maket: 320 px, matn ×2.0, yorug‘/tungi, uz/ru/en — toshib chiqish yo‘q',
    () {
      for (final lang in AppLanguage.values) {
        for (final dark in [false, true]) {
          testWidgets('${lang.name} ${dark ? 'dark' : 'light'}', (
            tester,
          ) async {
            final l = lookupAppLocalizations(lang.locale);
            final e = await _env(
              tester,
              language: lang,
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            );
            await pumpApp(
              tester,
              e.s,
              size: const Size(320, 640),
              textScale: 2.0,
              platformBrightness: dark ? Brightness.dark : Brightness.light,
            );
            final gid = await _group(tester, e);
            final (tid, aid) = await _assigned(e, gid, limit: 20);
            await e.api.createInvite(gid);
            for (final r in [
              '/learn/classes',
              TtRoutes.tests,
              TtRoutes.test(tid),
              TtRoutes.edit(tid),
              TtRoutes.assign(tid),
              TtRoutes.invites,
              TtRoutes.results(aid),
              TtRoutes.bank,
            ]) {
              await goTo(tester, r);
              expect(tester.takeException(), isNull, reason: r);
            }
            await goTo(tester, TtRoutes.edit(tid));
            await tester.ensureVisible(find.byKey(const ValueKey('tt-q-0')));
            await tester.pumpAndSettle();
            await tester.tap(find.byKey(const ValueKey('tt-q-0')));
            await tester.pumpAndSettle();
            expect(find.text(l.ttFieldQuestion), findsOneWidget);
            expect(tester.takeException(), isNull, reason: 'savol oynasi');
            await tester.tap(find.text(l.actionCancel));
            await tester.pumpAndSettle();
            await _signIn(tester, e.s, _student);
            for (final r in [
              TtRoutes.mine,
              TtRoutes.myTest(aid),
              TtRoutes.invite(),
            ]) {
              await goTo(tester, r);
              expect(tester.takeException(), isNull, reason: r);
            }
            await goTo(tester, TtRoutes.myTest(aid));
            await tapScroll(tester, l.ttStart);
            expect(find.byType(TtRunScreen), findsOneWidget);
            expect(tester.takeException(), isNull, reason: 'run');
          });
        }
      }
    },
  );
}
