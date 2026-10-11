// Hamjamiyat (D-43) — foydalanuvchi sifatida (walk_helper.dart): mehmon,
// mutaxassis tasdig'i, savol-javob, tarjima, admin moderatsiyasi.
//
//   flutter test tool/screenshots/walk_community_test.dart --update-goldens
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/community_backend.dart';
import 'package:labguide/features/community/community_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/fake_backend.dart';
import '../../test/helpers/fake_community.dart';
import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

const _owner = 'davlatsudekspert@gmail.com';

/// Egasi tasdiqlagan seed (cloudflare/seed/community_seed.json).
Future<(AppServices, FakeCommunityBackend, List<String>)> _start(
  WidgetTester tester, {
  AppLanguage lang = AppLanguage.uz,
  ThemeMode theme = ThemeMode.light,
}) async {
  final lab = FakeLabBackend();
  final community = FakeCommunityBackend(lab);
  await lab.requestCode(_owner);
  await lab.verifyCode(_owner, FakeLabBackend.otpCode);
  community.makeOwner(lab.userId!);
  final seed = jsonDecode(
    File('cloudflare/seed/community_seed.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final ids = <String>[];
  for (final q in (seed['questions']! as List).cast<Map<String, Object?>>()) {
    ids.add(
      community.seedQuestion(
        author: lab.userId!,
        title: q['title']! as String,
        body: q['body']! as String,
        topic: q['topic'] as String?,
        answers: [
          for (final a in (q['answers']! as List).cast<Map<String, Object?>>())
            a['body']! as String,
        ],
      ),
    );
  }
  await lab.signOut();
  final s = await makeServices(
    tester,
    language: lang,
    themeMode: theme,
    backend: lab,
    community: community,
  );
  await pumpApp(tester, s);
  return (s, community, ids);
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('mehmon (uz): bosh sahifa → savol → tahlil havolasi', (
    tester,
  ) async {
    final (s, _, ids) = await _start(tester);
    final w = Walk(tester, 'community_guest_uz');
    await goTo(tester, '/home');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('community-home-card')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await w.scroll(250);
    await w.snap('home_card');
    await goTo(tester, CommunityRoutes.question(ids[0]));
    await w.snap('question_top');
    await w.scroll(600);
    await w.snap('question_answer');
    await w.scroll(900);
    await w.snap('question_bottom');
    await goTo(tester, '/tests/analyte/potassium');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('community-topic-analyte:potassium')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await w.snap('analyte_link');
    await goTo(tester, '/profile/community?topic=analyte%3Apotassium');
    await w.snap('topic_list');
    expect(s.community.available, isTrue);
  });

  for (final lang in [AppLanguage.ru, AppLanguage.en]) {
    testWidgets('${lang.name}: tarjima va asl matn', (tester) async {
      final (_, _, ids) = await _start(tester, lang: lang);
      final l = lookupAppLocalizations(lang.locale);
      final w = Walk(tester, 'community_translate_${lang.name}');
      await goTo(tester, CommunityRoutes.question(ids[1]));
      await w.snap('before');
      await w.tap(find.text(l.cmTranslate).first);
      await w.snap('translated');
      await w.tap(find.text(l.cmShowOriginal).first);
      await w.snap('original');
    });
  }

  testWidgets('mutaxassis (uz, qorong‘i): tasdiqlash → javob', (tester) async {
    final (s, _, ids) = await _start(tester, theme: ThemeMode.dark);
    final l = lookupAppLocalizations(const Locale('uz'));
    VerifySpecialistScreen.pickerOverride = (_) async =>
        (File('assets/images/logo_mark.png').readAsBytesSync(), 'image/png');
    addTearDown(() => VerifySpecialistScreen.pickerOverride = null);
    final w = Walk(tester, 'community_specialist_uz');
    await _signIn(tester, s, 'spec@example.com');
    await goTo(tester, '/profile');
    await tester.scrollUntilVisible(
      find.text(l.cmVerifyTitle),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await w.snap('profile_rows');
    await goTo(tester, CommunityRoutes.verify);
    await w.snap('verify_form');
    await w.scroll(500);
    await w.snap('verify_form_bottom');
    await w.tap(find.byKey(const ValueKey('cm-verify-gallery')));
    await w.snap('verify_picked');
    await w.tap(find.byKey(const ValueKey('cm-verify-submit')));
    await w.snap('verify_done');
    await goTo(tester, CommunityRoutes.question(ids[0]));
    await w.scroll(1500);
    await w.snap('answer_form');
    await goTo(tester, CommunityRoutes.ask(topic: 'analyte:hba1c'));
    await w.snap('ask_form');
  });

  testWidgets('admin (uz): to‘xtatilgan foydalanuvchi', (tester) async {
    final (s, community, _) = await _start(tester);
    final w = Walk(tester, 'community_admin_uz');
    await community.lab.requestCode('bad@example.com');
    await community.lab.verifyCode('bad@example.com', FakeLabBackend.otpCode);
    final bad = community.lab.userId!;
    community.makeSpecialist(bad);
    final qid = community.seedQuestion(
      author: bad,
      title: 'Arzon reagentlar — bizning saytda chegirma!',
      body: 'Reklama matni, savol emas.',
    );
    await community.lab.signOut();
    for (final e in ['r1@example.com', 'r2@example.com', 'r3@example.com']) {
      await community.lab.requestCode(e);
      await community.lab.verifyCode(e, FakeLabBackend.otpCode);
      await community.report(
        kind: PostKind.question,
        id: qid,
        reason: ReportReason.spam,
      );
      await community.lab.signOut();
    }
    await _signIn(tester, s, _owner);
    await goTo(tester, CommunityRoutes.admin);
    await tester.enterText(
      find.byType(TextField).last,
      FakeLabBackend.totpCode,
    );
    await w.tap(
      find.text(lookupAppLocalizations(const Locale('uz')).adminMfaVerify),
    );
    await w.snap('suspended_list');
  });
}
