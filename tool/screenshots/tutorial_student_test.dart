// Qo'llanma videosi “Talaba: testga qo'shilish” uchun kadrlar (uz, Klassik,
// 390x844 @3x). Soxta server (FakeLabBackend): ustoz guruh va variantli
// mavzu testini ilova orqali tayyorlaydi (kadrsiz), so'ng talaba O'rganish →
// Guruh va topshiriqlar (birinchi ekranda) → QR skaner (soxta kamera kadri:
// ustoz telefonidagi Test QR) → taxallus so'raladi → test (“Muddat: …”) →
// topshirish → natija izohi; ustoz yakunlagach — javoblar.
// Muqobil yo'l: “Kod bilan qo'shilish” (kod + taxallus) — alohida talaba;
// guruh sahifasidagi “Taxallusim” qatori.
//
//   flutter test tool/screenshots/tutorial_student_test.dart --update-goldens
//   python3 tool/screenshots/tutorial_compose.py student
//
// Kadrlar: tool/screenshots/out/tutorial/student/ (+ frames.json).
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/classroom/invite_link.dart';
import 'package:labguide/features/classroom/qr_code_view.dart';
import 'package:labguide/features/classroom/qr_scanner.dart';
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/diff_device_fakes.dart';
import '../../test/helpers/fake_backend.dart';
import '../../test/helpers/fake_qr_scanner.dart';
import '../../test/helpers/harness.dart';
import '../../test/helpers/learn_helpers.dart';
import 'tutorial_helper.dart';
import 'walk_helper.dart';

const _deck = 'd013';
const _teacher = 'ustoz@example.com';

/// Soxta kamera: qora fon o'rniga — ustoz telefonida ochiq Test QR.
class _CameraScanner extends FakeQrScanner {
  String link = '';
  String code = '';

  @override
  QrCamera open() {
    opened++;
    return last = _Camera(this);
  }
}

class _Camera extends FakeQrCamera {
  _Camera(this.owner) : super(QrCameraStatus.running, torchAvailable: true);
  final _CameraScanner owner;

  @override
  Widget buildPreview(BuildContext context) => DecoratedBox(
    key: const ValueKey('fake-qr-preview'),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5B5148), Color(0xFF2E2A26), Color(0xFF453C33)],
      ),
    ),
    child: Center(
      child: Transform.rotate(
        angle: -0.05,
        // Ustoz telefoni (ekranida Test QR).
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(34),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 30),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F3EE),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Mavzu testi: Anemiyalar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF17463C),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                  child: QrCodeView(
                    data: owner.link,
                    semanticLabel: 'QR',
                    size: 220,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${owner.code.substring(0, 4)} ${owner.code.substring(4)}',
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF17463C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.signOut();
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('qo‘llanma: talaba testga qo‘shiladi (uz)', (tester) async {
    installDiffFakes();
    final l = lookupAppLocalizations(const Locale('uz'));
    final b = FakeLabBackend();
    final scanner = _CameraScanner();
    final s = await start(
      tester,
      role: AppRole.teacher,
      backend: b,
      qrScanner: scanner,
    );

    // --- Tayyorgarlik (kadrsiz): ustoz guruh ochadi, variantli test beradi.
    await _signIn(tester, s, _teacher);
    await b.registerTeacher();
    final g = await b.createGroup('Gematologiya 2-kurs');
    for (final (email, nick) in [
      ('lola@example.com', 'Lola'),
      ('bobur@example.com', 'Bobur'),
    ]) {
      await b.actAs(email, () => b.joinGroup(g.joinCode!, displayName: nick));
    }
    await goTo(tester, '/learn/lecture/test/$_deck/assign');
    await tester.tap(find.text('5').hitTestable());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('assign-due-d1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('assign-due-d1')));
    await tester.tap(find.byKey(const ValueKey('assign-reveal-after')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('assign-send')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('assign-send')));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    final a = (await b.assignments(g.id)).single;
    scanner
      ..code = g.joinCode!
      ..link = inviteUrl(g.joinCode!, assignmentId: a.id);

    // --- Talaba (hisobga kirgan, rol — talaba).
    await s.settings.setRole(AppRole.student);
    await _signIn(tester, s, 'madina@example.com');
    final w = TutorialWalk(tester, 'student');

    // 1. O'rganish → Guruh va topshiriqlar.
    await goTo(tester, '/learn');
    await w.snap('organish');
    await w.tapKey('learn-classes');
    await w.snap('guruhlar');

    // 2. QR kodni skanerlash.
    await w.tapKey('classes-scan', scrolledStep: 'guruhlar_scroll');
    await w.snap('skaner', settle: false);
    scanner.last!.emit(scanner.link);
    await tester.pump();
    await tester.pumpAndSettle();

    // 3. Birinchi marta: taxallus so'raladi (ixtiyoriy) → Qo'shilish.
    expect(find.byKey(const ValueKey('join-ask-nick')), findsOneWidget);
    expect(await b.myGroups(), isEmpty, reason: 'hali qo‘shilmadi');
    await w.snap('taxallus_sorov');
    await tester.enterText(find.byType(TextField).last, 'Madina');
    await tester.pumpAndSettle();
    await w.snap('taxallus_yozildi');
    await w.tapKey('join-submit', scrolledStep: 'taxallus_scroll');
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await w.snap('test_ochildi');

    // 4. Test: Boshlash → savollar → Yakunlash.
    await w.tapText(l.classesStart);
    await w.snap('savol_1');
    // Vaqt chegarasiz, muddatli test: taymer emas, “Muddat: 19-okt, 23:59”.
    expect(find.byKey(const ValueKey('exam-deadline-date')), findsOneWidget);
    final run = s.exams.assignmentSession(a.id, b.userId)!;
    for (var i = 0; i < run.length; i++) {
      final item = run.current;
      final q = ClassQuestionSource.of(
        s.content.pack!,
        s.toifa.bank,
      ).question(item.questionId)!;
      final idx = i == 1
          ? item.order.firstWhere((o) => !item.correct.contains(o))
          : item.correct.single;
      // Kadrdagi savollar (1–2) — belgi bilan; qolganlari kadrsiz.
      if (i < 2) {
        await w.tapText(
          q.option(idx, 'uz'),
          scrolledStep: 'savol_${i + 1}_scroll',
        );
        await w.snap('savol_${i + 1}_tanlandi');
      } else {
        await tapScroll(tester, q.option(idx, 'uz'));
      }
      if (i < run.length - 1) {
        if (i < 2) {
          await w.tapText(l.examNext, scrolledStep: 'savol_${i + 1}_keyingi');
        } else {
          await tapScroll(tester, l.examNext);
        }
        if (i == 0) await w.snap('savol_2');
      }
    }
    await w.snap('oxirgi_savol');
    await w.tapText(l.examFinish, scrolledStep: 'oxirgi_scroll');
    await w.snap('yakunlash_tasdiq');
    await w.tap(find.text(l.examFinish).hitTestable().last);
    await tester.pump(const Duration(seconds: 5));
    await w.snap('natija');

    await w.scroll(380);
    await w.snap('natija_past');
    expect(find.textContaining('ustoz testni yakunlaganda'), findsOneWidget);

    // 6. Muqobil: Kod bilan qo'shilish (kod + taxallus) — boshqa talaba.
    await _signIn(tester, s, 'aziz@example.com');
    await goTo(tester, '/learn/classes');
    await w.snap('kod_guruhlar');
    await w.tapText(l.classesJoin);
    await w.snap('kod_bosh');
    await tester.enterText(
      find.byKey(const ValueKey('join-code')),
      g.joinCode!,
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Aziz');
    await tester.pumpAndSettle();
    await w.snap('kod_taxallus');
    await w.tapKey('join-submit');
    await tester.pump(const Duration(seconds: 5));
    await w.snap('kod_guruh');
    expect(find.byKey(const ValueKey('group-nickname')), findsOneWidget);

    // 5. Ustoz testni yakunlaydi → javoblar ochiladi.
    await b.actAs(_teacher, () => b.closeAssignment(a.id));
    await _signIn(tester, s, 'madina@example.com');
    await goTo(tester, '/learn/classes');
    await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
    await w.snap('javoblar_ochildi');
    await w.scroll(560);
    await w.snap('xatolar_tahlili');

    w.save();
    await goTo(tester, '/learn');
  });
}
