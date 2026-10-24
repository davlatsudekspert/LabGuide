// 6–10-videolar uchun umumiy yordamchilar (frames_test.dart dagi shaxsiy
// yordamchilarning ochiq nusxasi + Hamjamiyat/rol sozlamalari).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/fake_backend.dart';
import '../../test/helpers/fake_community.dart';
import '../../test/helpers/harness.dart';
import 'rec.dart';

const phone = Size(360, 640);

Finder vertical() => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .hitTestable()
    .first;

Finder vis(String text) => find.text(text).hitTestable().last;

/// Sahifani tepaga qaytarib, keyin [f] ko'ringunicha pastga suradi.
Future<Finder> reveal(WidgetTester tester, Finder f, {bool center = true}) async {
  if (f.hitTestable().evaluate().isEmpty) {
    await tester.drag(vertical(), const Offset(0, 6000));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      f.hitTestable(),
      200,
      scrollable: vertical(),
    );
  }
  await tester.pumpAndSettle();
  if (center) await centerOn(tester, f.hitTestable().last);
  return f.hitTestable().last;
}

Future<void> tapR(WidgetTester tester, Finder f) async {
  final t = await reveal(tester, f);
  await tester.tap(t);
  await tester.pumpAndSettle();
}

Future<void> setH(WidgetTester tester, double h) async {
  tester.view.physicalSize = Size(360, h) * 3;
  await tester.pumpAndSettle();
}

Future<void> signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.signOut();
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> precacheLogos(WidgetTester tester) async {
  await tester.runAsync(() async {
    final ctx = tester.element(find.byType(Scaffold).first);
    for (final p in ['logo_mark', 'logo_mark_large']) {
      await precacheImage(AssetImage('assets/images/$p.png'), ctx);
    }
    await precacheImage(const AssetImage('assets/images/hero_schematic.webp'), ctx);
    for (final n in ['chemistry', 'hematology', 'immunoassay', 'urinalysis']) {
      await precacheImage(AssetImage('assets/instruments/img/$n.png'), ctx);
    }
  });
}

/// Hamjamiyat (egasi tasdiqlagan seed) bilan ilova; guruhsiz (mehmon).
Future<(AppServices, FakeCommunityBackend, List<String>)> startCommunity(
  WidgetTester tester, {
  AppRole role = AppRole.doctor,
  bool onboarded = true,
  bool languageChosen = true,
}) async {
  final lab = FakeLabBackend();
  final community = FakeCommunityBackend(lab);
  const owner = 'davlatsudekspert@gmail.com';
  await lab.requestCode(owner);
  await lab.verifyCode(owner, FakeLabBackend.otpCode);
  // ignore: invalid_use_of_visible_for_testing_member
  community.makeOwner(lab.userId!);
  final seed =
      jsonDecode(File('cloudflare/seed/community_seed.json').readAsStringSync())
          as Map<String, Object?>;
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
    backend: lab,
    community: community,
    role: onboarded ? role : null,
    onboarded: onboarded,
    languageChosen: languageChosen,
  );
  await pumpApp(tester, s, size: phone);
  await precacheLogos(tester);
  return (s, community, ids);
}

/// Yorliq (label) bo'yicha maydonni to'ldirish.
Future<void> enterField(WidgetTester tester, String label, String value) async {
  final field = find.descendant(
    of: find
        .ancestor(of: find.text(label).last, matching: find.byType(Column))
        .first,
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field.first);
  await tester.enterText(field.first, value);
  await tester.pumpAndSettle();
}

Finder fieldOf(String label) => find.descendant(
  of: find
      .ancestor(of: find.text(label).last, matching: find.byType(Column))
      .first,
  matching: find.byType(TextField),
);
