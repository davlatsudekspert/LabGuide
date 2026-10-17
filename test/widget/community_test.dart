import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/community_backend.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/community/community_controller.dart';
import 'package:labguide/features/community/community_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/fake_community.dart';
import '../helpers/harness.dart';

const _owner = 'davlatsudekspert@gmail.com';
const _seedTitle =
    'Kaliy 6,8 mmol/L chiqdi, lekin bemorda hech qanday belgi yo\'q. Nima qilish kerak?';
const _seedAnswer =
    'Avval soxta giperkaliyemiyani istisno qiling, ammo vaqt yo\'qotmang.';

AppLocalizations _l(AppLanguage lang) => lookupAppLocalizations(lang.locale);

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _signOut(WidgetTester tester, AppServices s) async {
  await s.auth.signOut();
  await tester.pumpAndSettle();
}

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

Future<void> _see(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  expect(f, findsOneWidget);
}

/// Server + egasi tomonidan yozilgan (tasdiqlangan) boshlang'ich savol.
Future<(AppServices, FakeLabBackend, FakeCommunityBackend)> _setup(
  WidgetTester tester, {
  AppLanguage language = AppLanguage.uz,
}) async {
  final lab = FakeLabBackend();
  final community = FakeCommunityBackend(lab);
  await lab.requestCode(_owner);
  await lab.verifyCode(_owner, FakeLabBackend.otpCode);
  community.makeOwner(lab.userId!);
  community.seedQuestion(
    author: lab.userId!,
    title: _seedTitle,
    body: 'Natijaga ishonsa bo\'ladimi, nimani tekshirish kerak?',
    topic: 'analyte:potassium',
    answers: [_seedAnswer],
  );
  await lab.signOut();
  final s = await makeServices(
    tester,
    language: language,
    backend: lab,
    community: community,
  );
  return (s, lab, community);
}

void main() {
  setUpAll(loadAppFonts);
  tearDown(() => VerifySpecialistScreen.pickerOverride = null);

  testWidgets('server ulanmagan: hamjamiyat hech qayerda ko‘rinmaydi', (
    tester,
  ) async {
    final s = await makeServices(tester, backend: FakeLabBackend());
    expect(s.community.available, isFalse);
    await pumpApp(tester, s);
    final l = _l(AppLanguage.uz);
    expect(find.byKey(const ValueKey('community-home-card')), findsNothing);
    await goTo(tester, '/tests/analyte/potassium');
    await tester.scrollUntilVisible(
      find.text(l.analyteSources),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text(l.cmTopicLinkSub), findsNothing);
    await goTo(tester, '/profile');
    expect(find.text(l.cmMyQuestions), findsNothing);
    expect(find.text(l.cmVerifyTitle), findsNothing);
    await goTo(tester, '/profile/community');
    expect(find.text(l.supportUnavailableTitle), findsOneWidget);
    expect(find.text(l.cmAsk), findsNothing);
  });

  for (final lang in AppLanguage.values) {
    testWidgets('${lang.name}: bosh sahifa kartasi, egasi javobi, tahlil '
        'havolasi', (tester) async {
      final (s, _, _) = await _setup(tester, language: lang);
      final l = _l(lang);
      await pumpApp(tester, s);
      await _see(tester, find.byKey(const ValueKey('community-home-card')));
      expect(find.text(l.cmTitle), findsOneWidget);
      await _tap(tester, find.text(_seedTitle));
      // Egasi: “LabGuide” va qo'lda tekshirilgan belgi.
      expect(find.text('LabGuide'), findsWidgets);
      expect(find.text(l.cmBadgeManual), findsWidgets);
      expect(find.textContaining(_seedAnswer), findsOneWidget);
      // Mehmon javob yoza olmaydi.
      await _see(tester, find.text(l.cmAnswerOnlySpecialists));
      expect(find.byKey(const ValueKey('cm-answer-field')), findsNothing);
      // ru/en interfeysda o'zbekcha post — tarjima tugmasi bor.
      expect(
        find.text(l.cmTranslate),
        lang == AppLanguage.uz ? findsNothing : findsWidgets,
      );

      await goTo(tester, '/tests/analyte/potassium');
      final link = find.byKey(
        const ValueKey('community-topic-analyte:potassium'),
      );
      await _see(tester, link);
      expect(find.text(l.cmTopicLinkAnalyte(1)), findsOneWidget);
      await _tap(tester, link);
      expect(find.text(_seedTitle), findsOneWidget);
    });
  }

  testWidgets('holat kartasida ham havola: “Bu holat bo‘yicha savollar (0)”', (
    tester,
  ) async {
    final (s, _, _) = await _setup(tester);
    await pumpApp(tester, s);
    await goTo(tester, '/tests/conditions/type-2-diabetes');
    final link = find.byKey(
      const ValueKey('community-topic-condition:type-2-diabetes'),
    );
    await _see(tester, link);
    expect(
      find.text(_l(AppLanguage.uz).cmTopicLinkCondition(0)),
      findsOneWidget,
    );
  });

  testWidgets('savol berish: mehmon → kirish; kirgan → savol va '
      '“Mening savollarim”', (tester) async {
    final (s, _, _) = await _setup(tester);
    final l = _l(AppLanguage.uz);
    await pumpApp(tester, s);
    await goTo(tester, '/profile/community/ask');
    expect(find.text(l.supportSignInTitle), findsOneWidget);

    await _signIn(tester, s, 'asker@example.com');
    await goTo(tester, '/profile/community');
    await _tap(tester, find.text(l.cmAsk).first);
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('cm-ask-title')),
        matching: find.byType(TextField),
      ),
      'qisqa',
    );
    await _tap(tester, find.byKey(const ValueKey('cm-ask-send')));
    expect(find.text(l.cmErrLength), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('cm-ask-title')),
        matching: find.byType(TextField),
      ),
      'Glyukometr va laboratoriya natijasi farq qilsa?',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('cm-ask-body')),
        matching: find.byType(TextField),
      ),
      'Qaysi biriga ishonish kerak, farq qancha bo‘lsa normal?',
    );
    await _tap(tester, find.byKey(const ValueKey('cm-ask-send')));
    expect(
      find.text('Glyukometr va laboratoriya natijasi farq qilsa?'),
      findsOneWidget,
    );

    await goTo(tester, '/profile');
    await _tap(tester, find.text(l.cmMyQuestions));
    expect(
      find.text('Glyukometr va laboratoriya natijasi farq qilsa?'),
      findsOneWidget,
    );
    expect(find.text(_seedTitle), findsNothing);
  });

  for (final lang in AppLanguage.values) {
    testWidgets('${lang.name}: mutaxassis tasdiqlash — avtomatik, halol '
        'belgi; keyin javob yozadi', (tester) async {
      final (s, _, community) = await _setup(tester, language: lang);
      final l = _l(lang);
      VerifySpecialistScreen.pickerOverride = (_) async =>
          (Uint8List.fromList([0xff, 0xd8, 0xff, 0xe0, 1, 2, 3]), 'image/jpeg');
      await pumpApp(tester, s);
      await _signIn(tester, s, 'spec@example.com');
      await goTo(tester, '/profile');
      await _tap(tester, find.text(l.cmVerifyTitle));
      expect(find.text(l.cmStatusNone), findsOneWidget);
      expect(find.text(l.cmVerifyInfoTitle), findsOneWidget);
      expect(find.text(l.cmVerifyInfo), findsOneWidget);
      await _tap(tester, find.text(l.cmRoleBiochemist));
      await _tap(tester, find.byKey(const ValueKey('cm-verify-gallery')));
      await _tap(tester, find.byKey(const ValueKey('cm-verify-submit')));
      expect(community.uploads, 1);
      expect(find.text(l.cmBadgeAi), findsOneWidget);
      expect(find.text(l.cmMethodAi), findsOneWidget);
      expect(find.textContaining(l.cmRoleBiochemist), findsOneWidget);

      // Endi javob yozadi.
      await goTo(tester, '/profile/community');
      await _tap(tester, find.text(_seedTitle));
      final field = find.descendant(
        of: find.byKey(const ValueKey('cm-answer-field')),
        matching: find.byType(TextField),
      );
      await _see(tester, field);
      await tester.enterText(field, 'Gemoliz indeksini ham albatta yozing.');
      await _tap(tester, find.byKey(const ValueKey('cm-answer-send')));
      expect(
        find.text('Gemoliz indeksini ham albatta yozing.'),
        findsOneWidget,
      );
      expect(find.text(l.cmBadgeAi), findsWidgets);
    });
  }

  testWidgets('hujjat rad etildi — halol xabar; tanlash qayta ochiq', (
    tester,
  ) async {
    final (s, _, community) = await _setup(tester);
    final l = _l(AppLanguage.uz);
    community.verifyOutcome = MemberStatus.rejected;
    VerifySpecialistScreen.pickerOverride = (_) async =>
        (Uint8List.fromList([0x89, 0x50, 0x4e, 0x47, 1]), 'image/png');
    await pumpApp(tester, s);
    await _signIn(tester, s, 'x@example.com');
    await goTo(tester, '/profile/community/verify');
    await _tap(tester, find.byKey(const ValueKey('cm-verify-camera')));
    await _tap(tester, find.byKey(const ValueKey('cm-verify-submit')));
    expect(find.text(l.cmStatusRejected), findsOneWidget);
    expect(find.text(l.cmBadgeAi), findsNothing);
    expect(find.byKey(const ValueKey('cm-verify-gallery')), findsOneWidget);

    // 5 MB dan katta yoki noto'g'ri tur — serverga yuborilmaydi.
    VerifySpecialistScreen.pickerOverride = (_) async =>
        (Uint8List(5 * 1024 * 1024 + 1), 'image/jpeg');
    await _tap(tester, find.byKey(const ValueKey('cm-verify-gallery')));
    expect(find.text(l.cmErrTooLarge), findsOneWidget);
    VerifySpecialistScreen.pickerOverride = (_) async =>
        (Uint8List.fromList([1, 2]), 'application/pdf');
    await _tap(tester, find.byKey(const ValueKey('cm-verify-gallery')));
    expect(find.text(l.cmErrType), findsOneWidget);
    expect(community.uploads, 1);
  });

  testWidgets('ru: tarjima — “Машинный перевод” va “Исходный текст”', (
    tester,
  ) async {
    final (s, _, community) = await _setup(tester, language: AppLanguage.ru);
    final l = _l(AppLanguage.ru);
    await pumpApp(tester, s);
    await goTo(tester, '/profile/community');
    await _tap(tester, find.text(_seedTitle));
    await _tap(tester, find.text(l.cmTranslate).first);
    expect(find.text('[ru] $_seedTitle'), findsOneWidget);
    expect(find.text(l.cmMachineTranslation), findsOneWidget);
    expect(community.translations, 1);
    await _tap(tester, find.text(l.cmShowOriginal).first);
    expect(find.text(_seedTitle), findsOneWidget);
    expect(find.text(l.cmMachineTranslation), findsNothing);
    await _tap(tester, find.text(l.cmShowTranslation).first);
    expect(find.text('[ru] $_seedTitle'), findsOneWidget);
  });

  testWidgets('shikoyat: 3 kishi → to‘xtatildi; admin panelida tiklanadi', (
    tester,
  ) async {
    final (s, lab, community) = await _setup(tester);
    final l = _l(AppLanguage.uz);
    // Shubhali mutaxassis va uning savoli.
    await lab.requestCode('bad@example.com');
    await lab.verifyCode('bad@example.com', FakeLabBackend.otpCode);
    final bad = lab.userId!;
    community.makeSpecialist(bad);
    community.seedQuestion(
      author: bad,
      title: 'Shubhali savol matni bu yerda',
      body: 'Reklama havolasi va boshqa narsalar.',
    );
    await lab.signOut();
    await pumpApp(tester, s);
    for (final email in [
      'r1@example.com',
      'r2@example.com',
      'r3@example.com',
    ]) {
      await _signIn(tester, s, email);
      await goTo(tester, '/profile/community');
      await _tap(tester, find.text('Shubhali savol matni bu yerda'));
      await _tap(tester, find.text(l.cmReport).first);
      await tester.tap(find.text(l.cmReasonSpam));
      await tester.pumpAndSettle();
      expect(find.text(l.cmReportSent), findsOneWidget);
      await _signOut(tester, s);
    }
    await goTo(tester, '/home');
    await goTo(tester, '/profile/community');
    expect(find.text('Shubhali savol matni bu yerda'), findsNothing);

    // Oddiy foydalanuvchi admin panelini ko'rmaydi.
    await _signIn(tester, s, 'r1@example.com');
    await goTo(tester, '/profile/community');
    await goTo(tester, CommunityRoutes.admin);
    expect(find.text(l.adminForbiddenTitle), findsOneWidget);
    await _signOut(tester, s);

    // Admin: email + 2FA (aal2).
    // Moderatsiya endi admin panel ichida (profilda bitta “Admin panel”).
    await _signIn(tester, s, _owner);
    await goTo(tester, '/profile');
    expect(find.text(l.cmAdminTitle), findsNothing);
    await _tap(tester, find.text(l.adminTitle));
    await tester.enterText(
      find.byType(TextField).last,
      FakeLabBackend.totpCode,
    );
    await _tap(tester, find.text(l.adminMfaVerify));
    expect(find.text(l.admPending(1)), findsOneWidget);
    await _tap(tester, find.text(l.admReportsQueue));
    expect(find.textContaining(l.cmAdminReporters(3)), findsOneWidget);
    expect(find.textContaining('Shubhali savol'), findsOneWidget);
    await _tap(tester, find.text(l.cmAdminRestore));
    // Tasdiq oynasi: bekor qilinsa hech narsa o'zgarmaydi.
    expect(find.text(l.cmAdminRestoreTitle), findsOneWidget);
    await tester.tap(find.text(l.actionCancel));
    await tester.pumpAndSettle();
    expect(find.textContaining(l.cmAdminReporters(3)), findsOneWidget);
    await _tap(tester, find.text(l.cmAdminRestore));
    await tester.tap(find.text(l.cmAdminRestore).last);
    await tester.pumpAndSettle();
    expect(find.text(l.cmAdminEmpty), findsOneWidget);
    await goTo(tester, '/home');
    await goTo(tester, '/profile/community');
    expect(find.text('Shubhali savol matni bu yerda'), findsOneWidget);
  });

  for (final lang in [AppLanguage.uz, AppLanguage.ru, AppLanguage.en]) {
    testWidgets(
      'ishga tushirish kartasi: 2FA yo‘li, bir tugma, takror (${lang.name})',
      (tester) async {
        final (s, _, community) = await _setup(tester, language: lang);
        final l = _l(lang);
        await pumpApp(tester, s);
        await _signIn(tester, s, _owner);
        // To'g'ridan-to'g'ri havola (qo'llanmadagi yo'l — panel ichidan).
        await goTo(tester, CommunityRoutes.admin);
        // aal1: karta yo'q, 2FA yo'li va tushuntirish ko'rinadi.
        expect(find.byKey(const ValueKey('cm-launch-button')), findsNothing);
        expect(find.text(l.cmLaunchMfaHint), findsOneWidget);
        expect(find.text(l.adminMfaVerify), findsOneWidget);
        await tester.enterText(
          find.byType(TextField).last,
          FakeLabBackend.totpCode,
        );
        await _tap(tester, find.text(l.adminMfaVerify));
        // aal2: karta va bitta tugma.
        expect(find.text(l.cmLaunchTitle), findsOneWidget);
        expect(find.text(l.cmLaunchBody), findsOneWidget);
        await _tap(tester, find.byKey(const ValueKey('cm-launch-button')));
        expect(find.text(l.cmLaunchDone(2, 3)), findsOneWidget);
        expect(community.launchCalls, 1);
        await _tap(tester, find.byKey(const ValueKey('cm-launch-button')));
        expect(find.text(l.cmLaunchAlready), findsOneWidget);
        expect(find.text(l.cmLaunchDone(2, 3)), findsNothing);
      },
    );
  }

  testWidgets('ishga tushirish: egasi emaili ruxsat etilmagan — xato matni', (
    tester,
  ) async {
    final (s, _, community) = await _setup(tester);
    final l = _l(AppLanguage.uz);
    community.launchEmailAllowed = false;
    await pumpApp(tester, s);
    await _signIn(tester, s, _owner);
    await goTo(tester, '/profile');
    await _tap(tester, find.text(l.adminTitle));
    await tester.enterText(
      find.byType(TextField).last,
      FakeLabBackend.totpCode,
    );
    await _tap(tester, find.text(l.adminMfaVerify));
    await _tap(tester, find.text(l.admLaunchRow));
    await _tap(tester, find.byKey(const ValueKey('cm-launch-button')));
    expect(find.text(l.cmLaunchNotOwner), findsOneWidget);
  });

  testWidgets('eng yaxshi javob — faqat savol muallifi; ovoz — mutaxassis', (
    tester,
  ) async {
    final (s, lab, community) = await _setup(tester);
    final l = _l(AppLanguage.uz);
    await lab.requestCode('spec2@example.com');
    await lab.verifyCode('spec2@example.com', FakeLabBackend.otpCode);
    community.makeSpecialist(lab.userId!);
    await lab.signOut();
    await pumpApp(tester, s);
    // Mutaxassis: ovoz beradi, “eng yaxshi” tugmasi yo'q (muallif emas).
    await _signIn(tester, s, 'spec2@example.com');
    await goTo(tester, '/profile/community');
    await _tap(tester, find.text(_seedTitle));
    expect(find.text(l.cmMarkBest), findsNothing);
    await _tap(tester, find.text(l.cmUpvote(0)));
    expect(find.text(l.cmUpvote(1)), findsOneWidget);
    await _signOut(tester, s);
    // Muallif (egasi) eng yaxshi deb belgilaydi.
    await _signIn(tester, s, _owner);
    await goTo(tester, '/profile/community');
    await _tap(tester, find.text(_seedTitle));
    await _tap(tester, find.text(l.cmMarkBest));
    expect(find.text(l.cmBest), findsWidgets);
    expect(find.text(l.cmUnmarkBest), findsOneWidget);
  });

  group('1.2: foydalanuvchini bloklash', () {
    Future<(AppServices, String)> setupBad(WidgetTester tester) async {
      final (s, lab, community) = await _setup(tester);
      await lab.requestCode('bad@example.com');
      await lab.verifyCode('bad@example.com', FakeLabBackend.otpCode);
      community.makeSpecialist(lab.userId!);
      community.seedQuestion(
        author: lab.userId!,
        title: 'Shubhali savol matni bu yerda',
        body: 'Haqoratli matn va boshqa narsalar.',
        answers: ['Haqoratli javob matni shu yerda.'],
      );
      final ref = 'ref-${lab.userId}';
      await lab.signOut();
      await pumpApp(tester, s);
      return (s, ref);
    }

    testWidgets(
      'bloklash: post yashirinadi, qurilmada saqlanadi, qaytariladi',
      (tester) async {
        final (s, ref) = await setupBad(tester);
        final l = _l(AppLanguage.uz);
        await _signIn(tester, s, 'reader@example.com');
        await goTo(tester, '/profile/community');
        await _tap(tester, find.text('Shubhali savol matni bu yerda'));
        expect(find.text('Haqoratli javob matni shu yerda.'), findsOneWidget);

        await _tap(tester, find.text(l.cmBlock).first);
        expect(find.text(l.cmBlockConfirmTitle), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('cm-block-confirm')));
        await tester.pumpAndSettle();
        expect(find.text(l.cmBlockedDone), findsOneWidget);
        expect(s.store.getStringList(StoreKeys.communityBlocked), [ref]);
        // Savol va javob (ikkalasi ham shu muallifniki) yashirilgan.
        expect(find.text(l.cmBlockedHidden), findsWidgets);
        expect(find.text('Haqoratli javob matni shu yerda.'), findsNothing);

        // Ro'yxatda ko'rinmaydi; “bloklanganlar” bo'limi bor.
        await goTo(tester, '/profile/community');
        expect(find.text('Shubhali savol matni bu yerda'), findsNothing);
        await _see(tester, find.byKey(const ValueKey('cm-blocked-panel')));
        expect(find.text(l.cmBlockedCount(1)), findsOneWidget);

        await _tap(tester, find.byKey(const ValueKey('cm-unblock-all')));
        expect(s.store.getStringList(StoreKeys.communityBlocked), isEmpty);
        await _see(tester, find.text('Shubhali savol matni bu yerda'));
      },
    );

    testWidgets(
      'egasi (LabGuide jamoasi) bloklanmaydi, blok tugmasi chiqmaydi',
      (tester) async {
        final (s, _) = await setupBad(tester);
        final l = _l(AppLanguage.uz);
        await _signIn(tester, s, 'reader2@example.com');
        await goTo(tester, '/profile/community');
        await _tap(tester, find.text(_seedTitle));
        expect(find.text(l.cmReport), findsWidgets);
        expect(find.text(l.cmBlock), findsNothing);
      },
    );

    testWidgets('aloqa ma\'lumoti hamjamiyat ro\'yxatidan ochiladi', (
      tester,
    ) async {
      await setupBad(tester);
      final l = _l(AppLanguage.uz);
      await goTo(tester, '/profile/community');
      await _tap(tester, find.byKey(const ValueKey('cm-contact-link')));
      expect(find.text(l.contactTitle), findsWidgets);
    });

    test('controller: saqlash, o\'zini/belgisizni bloklamaslik', () async {
      final store = MemoryKeyValueStore();
      final c = CommunityController(null, store: store);
      const other = CommunityAuthor(kind: AuthorKind.member, ref: 'r1');
      const me = CommunityAuthor(
        kind: AuthorKind.member,
        ref: 'r2',
        isMe: true,
      );
      const noRef = CommunityAuthor(kind: AuthorKind.member);
      const owner = CommunityAuthor(kind: AuthorKind.owner, ref: 'r3');
      expect(c.canBlock(other), isTrue);
      expect(c.canBlock(me), isFalse);
      expect(c.canBlock(noRef), isFalse);
      expect(c.canBlock(owner), isFalse);
      await c.block(me);
      await c.block(noRef);
      await c.block(owner);
      expect(c.blockedCount, 0);
      await c.block(other);
      expect(c.isBlocked(other), isTrue);
      expect(c.isBlocked(noRef), isFalse);
      // Yangi controller (ilova qayta ochildi) blokni saqlagan.
      final again = CommunityController(null, store: store);
      expect(again.isBlocked(other), isTrue);
      again.resetInMemory();
      expect(again.blockedCount, 0);
    });
  });

  for (final lang in AppLanguage.values) {
    testWidgets('${lang.name}: qoidalar kartasi — yopiq/ochiq, eslab qolish, '
        'tasdiqlash havolasi', (tester) async {
      final (s, _, _) = await _setup(tester, language: lang);
      final l = _l(lang);
      await pumpApp(tester, s);
      await _signIn(tester, s, 'rules@example.com');
      await goTo(tester, '/profile/community');
      final card = find.byKey(const ValueKey('cm-rules-card'));
      expect(card, findsOneWidget);
      // Ro'yxatning eng tepasida (savollardan oldin), standart yopiq.
      expect(
        tester.getTopLeft(card).dy,
        lessThan(tester.getTopLeft(find.text(_seedTitle)).dy),
      );
      expect(find.text(l.cmRulesTitle), findsOneWidget);
      expect(find.text(l.cmRulesIntro), findsOneWidget);
      expect(find.text(l.cmRulesH1), findsNothing);
      expect(s.store.getBool(StoreKeys.communityRulesOpen), isNull);

      await tester.tap(find.byKey(const ValueKey('cm-rules-toggle')));
      await tester.pumpAndSettle();
      expect(s.store.getBool(StoreKeys.communityRulesOpen), isTrue);
      for (final t in [
        l.cmRulesH1,
        l.cmRulesA1,
        l.cmRulesH2,
        l.cmRulesB4,
        l.cmRulesH3,
        l.cmRulesC3,
        l.cmRulesH4,
        l.cmRulesD1,
        l.cmRulesD3,
        l.cmRulesOutro,
      ]) {
        await _see(tester, find.text(t));
      }
      // “Profil → Mutaxassis tasdiqlash” — bosiladigan havola.
      await _see(
        tester,
        find.textContaining(l.cmRulesD2Link, findRichText: true),
      );
      await tester.tapOnText(find.textRange.ofSubstring(l.cmRulesD2Link));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('cm-verify-country')), findsOneWidget);
      // Orqaga qaytganda holat saqlangan (qurilma bo'yicha).
      await goTo(tester, '/profile/community');
      expect(find.text(l.cmRulesH1), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('cm-rules-toggle')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('cm-rules-toggle')));
      await tester.pumpAndSettle();
      expect(s.store.getBool(StoreKeys.communityRulesOpen), isFalse);
      expect(find.text(l.cmRulesH1), findsNothing);
    });

    testWidgets('${lang.name}: savol berish ekranida qoidalar havolasi', (
      tester,
    ) async {
      final (s, _, _) = await _setup(tester, language: lang);
      final l = _l(lang);
      await pumpApp(tester, s);
      await _signIn(tester, s, 'rules2@example.com');
      await goTo(tester, '/profile/community/ask');
      await _tap(tester, find.byKey(const ValueKey('cm-rules-link')));
      await _see(tester, find.text(l.cmRulesH4));
      await tester.tapOnText(find.textRange.ofSubstring(l.cmRulesD2Link));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('cm-verify-country')), findsOneWidget);
    });
  }
}
