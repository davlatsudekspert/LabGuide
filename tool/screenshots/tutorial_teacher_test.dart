// Qo'llanma videosi “Ustoz: testni boshlash” uchun kadrlar (uz, Klassik,
// 390x844 @3x; katta ekran — 1920x1080). Soxta server (FakeLabBackend):
// uch talaba boshqa “qurilmadan” qo'shiladi va topshiradi (actAs).
//
//   flutter test tool/screenshots/tutorial_teacher_test.dart --update-goldens
//   python3 tool/screenshots/tutorial_compose.py teacher
//
// Kadrlar: tool/screenshots/out/tutorial/teacher/ (+ frames.json).
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/diff_device_fakes.dart';
import '../../test/helpers/fake_backend.dart';
import '../../test/helpers/harness.dart';
import 'tutorial_helper.dart';
import 'walk_helper.dart';

const _deck = 'd013';
const _teacher = 'ustoz@example.com';

/// Talaba (boshqa qurilmada) testni yechadi: [wrong] ta xato bilan.
Future<void> _studentSubmits(
  FakeLabBackend b,
  String email,
  GroupAssignment a,
  List<int> key, {
  required int wrong,
}) => b.actAs(email, () async {
  final st = await b.startAssignment(a.id);
  final ids = st.questionIds ?? a.questionIds;
  final answers = [
    for (final (i, q) in ids.indexed)
      () {
        final c = key[a.questionIds.indexOf(q)];
        return i < wrong ? (c == 0 ? 1 : 0) : c;
      }(),
  ];
  await b.submitAssignment(a.id, answers, questionIds: ids);
});

/// Talaba [minutes] daqiqa oldin testni ochgan (vaqt ustunida ko'rinadi).
Future<void> _studentStarts(
  FakeLabBackend b,
  String email,
  String assignmentId,
  int minutes,
) async {
  final now = DateTime.now();
  b.groupClock = () => now.subtract(Duration(minutes: minutes));
  await b.actAs(email, () => b.startAssignment(assignmentId));
  b.groupClock = DateTime.now;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('qo‘llanma: ustoz testni boshlaydi (uz)', (tester) async {
    installDiffFakes();
    final l = lookupAppLocalizations(const Locale('uz'));
    final b = FakeLabBackend();
    final s = await start(tester, role: AppRole.lab, backend: b);
    await s.auth.requestCode(_teacher);
    await s.auth.verifyCode(FakeLabBackend.otpCode);
    await tester.pumpAndSettle();
    final w = TutorialWalk(tester, 'teacher');

    // 1. Profil → rol “Ustoz”.
    await goTo(tester, '/profile/role');
    await w.snap('rol');
    await w.tapText(l.roleTeacher);
    await w.snap('rol_ustoz');
    await w.tapText(l.actionContinue);

    // 2. O'rganish → Guruh va topshiriqlar → Guruh yaratish.
    await goTo(tester, '/learn');
    await w.snap('organish');
    await w.tapText(l.classesTitle);
    await w.snap('guruhlar');
    await w.tapText(l.classesCreate);
    await w.snap('ustoz_royxat');
    await w.tapText(l.classesTeacherRegister);
    await w.snap('guruh_nomi_bosh');
    await tester.enterText(find.byType(TextField).first, 'Gematologiya 2-kurs');
    await tester.pumpAndSettle();
    await w.snap('guruh_nomi');
    await w.tapText(l.classesCreateAction);
    await tester.pump(const Duration(seconds: 5));
    await w.snap('guruh_kod_qr');
    final g = (await b.myGroups()).single;

    // 3. Talabalar QR/kod bilan qo'shiladi (boshqa qurilmalar).
    for (final (email, nick) in [
      ('lola@example.com', 'Lola'),
      ('bobur@example.com', 'Bobur'),
      ('aziz@example.com', 'Aziz'),
    ]) {
      await b.actAs(email, () => b.joinGroup(g.joinCode!, displayName: nick));
    }
    await goTo(tester, '/learn');
    await goTo(tester, '/learn/classes/g/${g.id}');
    await w.snap('guruh_talabalar');

    // 4. Mavzu testi → Guruhga topshirish.
    await goTo(tester, '/learn/lecture');
    await w.snap('maruza_royxat');
    final badge = find.byKey(const ValueKey('deck-test-$_deck'));
    await tester.scrollUntilVisible(
      badge,
      300,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    await tester.pumpAndSettle();
    await w.snap('maruza_mavzu');
    await w.tap(badge);
    await w.snap('mavzu_testi');
    await w.tapKey('topic-test-assign');
    await w.snap('topshirish_bosh');
    await w.tapText('5');
    await w.snap('topshirish_5_savol');
    await w.scroll(330);
    await w.snap('variant_muddat');
    await w.tapKey('assign-due-d1');
    await w.tapKey('assign-reveal-after');
    await w.snap('muddat_natija_sozlandi');
    await w.tapKey('assign-send');
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    final a = (await b.assignments(g.id)).single;
    final sent = find.byKey(ValueKey('sent-${a.id}'));
    await tester.ensureVisible(sent);
    await tester.pumpAndSettle();
    await w.snap('yuborildi');
    // “Yuborilganlar” qatorini bosish (root navigator ustidan push) debug
    // rejimida “duplicate page key” assertion beradi — docs/TUTORIAL_VIDEOS.md.
    // Qo'llanmada: guruh sahifasi → topshiriq.
    await goTo(tester, '/learn/classes/g/${g.id}');
    await w.snap('guruh_topshiriq');
    await w.tap(find.text(a.title).hitTestable());

    // 5. Topshiriq sahifasi → Test QR.
    await w.snap('topshiriq_ustoz');
    await w.tapKey('assignment-test-qr');
    await w.snap('test_qr');
    await w.tapText(l.actionClose);

    // 6. Talabalar yechadi va topshiradi — natijalar o'zi yangilanadi.
    final key = await b.assignmentKey(a.id);
    final base = '/learn/classes/g/${g.id}/a/${a.id}';
    await _studentStarts(b, 'lola@example.com', a.id, 7);
    await _studentStarts(b, 'aziz@example.com', a.id, 6);
    await _studentStarts(b, 'bobur@example.com', a.id, 5);
    await _studentSubmits(b, 'lola@example.com', a, key, wrong: 0);
    await tester.pump(const Duration(seconds: 11));
    await w.scroll(430);
    await w.snap('natija_1');
    await _studentSubmits(b, 'aziz@example.com', a, key, wrong: 1);
    await tester.pump(const Duration(seconds: 11));
    await w.scroll(-430);
    await w.snap('natija_2');

    // 7. Katta ekran (proyektor, 1920x1080) — jonli.
    w.markTap(tester.getCenter(find.byKey(const ValueKey('assignment-board'))));
    Future<void> tv(bool on) async {
      tester.view.devicePixelRatio = on ? 1.0 : 3.0;
      tester.view.physicalSize = on
          ? const Size(1920, 1080)
          : const Size(390, 844) * 3;
      tester.view.padding = on
          ? FakeViewPadding.zero
          : const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
      await tester.pumpAndSettle();
    }

    await tv(true);
    await goTo(tester, '$base/board');
    await w.snap('katta_ekran');
    await _studentSubmits(b, 'bobur@example.com', a, key, wrong: 2);
    await tester.pump(const Duration(seconds: 6));
    await w.snap('katta_ekran_3');
    await tv(false);
    // Yangi holat bilan qayta ochiladi (3 / 3).
    await goTo(tester, '/learn/classes/g/${g.id}');
    await goTo(tester, base);

    // 8. Testni yakunlash → eng qiyin savollar.
    await w.snap('yakunlashdan_oldin');
    await w.tapKey('assignment-close');
    await w.snap('yakunlash_tasdiq');
    await w.tap(find.text(l.classroomTestFinish).hitTestable().last);
    await tester.pump(const Duration(seconds: 5));
    await w.snap('yakunlandi');
    await w.scroll(650);
    await w.snap('taqsimot_eng_qiyin');
    await tv(true);
    await goTo(tester, '$base/board');
    await w.snap('katta_ekran_eng_qiyin');
    await tv(false);
    w.save();
    await goTo(tester, '/learn');
  });
}
