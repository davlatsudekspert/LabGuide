// Sinfxona: ustoz va ikki talaba — kirish → guruh → kod/QR → qo'shilish →
// mavzu → ma'ruza → savol-javob → test → natijalar; uz/ru/en, 390x844.
//
//   flutter test tool/screenshots/walk_classroom_test.dart --update-goldens
// Rasmlar: tool/screenshots/out/walk/classroom_<til>/
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/diff_device_fakes.dart';
import '../../test/helpers/fake_backend.dart';
import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

const _topic = 'd003-L';

extension on Walk {
  Future<void> tapScroll(String text) async {
    final f = find.text(text);
    if (f.hitTestable().evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        f.hitTestable(),
        250,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .hitTestable()
            .first,
      );
    }
    await tap(f.hitTestable().last);
  }
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.signOut();
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _snackGone(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('sinfxona (${lang.name})', (tester) async {
      installDiffFakes();
      final l = lookupAppLocalizations(lang.locale);
      final b = FakeLabBackend();
      final s = await start(
        tester,
        lang: lang,
        role: AppRole.teacher,
        backend: b,
      );
      final w = Walk(tester, 'classroom_${lang.name}');

      // Hisobsiz: halol taklif.
      await goTo(tester, '/learn/classes');
      await w.snap('01_mehmon');

      await _signIn(tester, s, 'ustoz@example.com');
      await b.registerTeacher();
      await goTo(tester, '/learn/classes');
      await w.snap('02_guruhlar_bosh');
      await w.tapScroll(l.classesCreate);
      await w.snap('03_yaratish');
      await w.enter(l.classesGroupName, 'KLD-1');
      await w.tapScroll(l.classesCreateAction);
      await w.snap('04_guruh_kod_qr');
      await _snackGone(tester);
      final g = (await b.myGroups()).single;

      // Ikki talaba (biri taxallus bilan).
      await _signIn(tester, s, 's1@example.com');
      await goTo(tester, '/learn/classes');
      await w.snap('05_talaba_bosh');
      await goTo(tester, '/learn/classes/join');
      await w.snap('06_qoshilish_bosh');
      await w.enter(l.classesCode, 'ZZZZZZZZ');
      await w.tapScroll(l.classesJoinAction);
      await w.snap('07_notogri_kod');
      await goTo(tester, '/learn/classes/join?code=${g.joinCode}');
      await w.snap('08_qoshilish_kod_bilan');
      await w.tapScroll(l.classesJoinAction);
      await w.snap('09_qoshildi');
      await _signIn(tester, s, 's2@example.com');
      await b.joinGroup(g.joinCode!, displayName: 'Lola');

      // Ustoz: jadval, mavzu.
      await _signIn(tester, s, 'ustoz@example.com');
      await goTo(tester, '/learn/classes/g/${g.id}');
      await w.snap('10_ustoz_guruh');
      await goTo(tester, '/learn/classes/g/${g.id}/plan');
      await w.snap('11_jadval');

      // Talaba: mavzu hali yopiq / ochilmagan.
      await _signIn(tester, s, 's1@example.com');
      await goTo(tester, '/learn/classes/g/${g.id}');
      await w.snap('12_talaba_mavzu_yoq');
      await goTo(tester, '/learn/classes/g/${g.id}/t/$_topic');
      await w.snap('13_talaba_yopiq_mavzu');

      await _signIn(tester, s, 'ustoz@example.com');
      await goTo(tester, '/learn/classes/g/${g.id}/t/$_topic');
      await w.snap('14_mavzu_yopiq');
      await w.tapScroll(l.classroomOpenTopic);
      await w.snap('15_mavzu_ochildi');
      await w.tapScroll(l.classroomMarkDone);
      await w.snap('16_maruza_otildi');

      // Talaba: ma'ruza bosqichi.
      await _signIn(tester, s, 's1@example.com');
      await goTo(tester, '/learn/classes/g/${g.id}/t/$_topic');
      await w.snap('17_talaba_maruza');

      await _signIn(tester, s, 'ustoz@example.com');
      await goTo(tester, '/learn/classes/g/${g.id}/t/$_topic');
      await w.tapScroll(l.classroomOralOpen);
      await w.snap('18_savol_javob');
      await w.tapScroll(l.classroomOralAsked);
      await w.snap('18b_soraldi');
      await goTo(tester, '/learn/classes/g/${g.id}/t/$_topic');
      await w.tapScroll(l.classroomMarkDone);
      await w.snap('19_savol_javob_tugadi');
      await w.tapScroll(l.classroomTestPrepare);
      await w.snap('20_test_tayyorlash');
      await w.tapScroll(l.examMinutes(10));
      await w.tapScroll(l.classroomPickAll);
      await w.snap('21_test_tanlandi');
      final picked = tester
          .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
          .where((c) => c.value == true)
          .length;
      await w.tapScroll(l.classroomTestStart(picked));
      await w.snap('22_test_boshlandi');
      final a = (await b.assignments(g.id)).single;

      for (final (email, wrong) in [
        ('s1@example.com', false),
        ('s2@example.com', true),
      ]) {
        await _signIn(tester, s, email);
        await goTo(tester, '/learn/classes/g/${g.id}/t/$_topic');
        if (!wrong) await w.snap('23_talaba_test_kutmoqda');
        await w.tapScroll(a.title);
        if (!wrong) await w.snap('24_test_boshlash');
        await w.tapScroll(l.classesStart);
        final run = s.exams.assignmentSession(a.id, b.userId)!;
        if (!wrong) await w.snap('25_savol');
        for (var i = 0; i < run.length; i++) {
          final item = run.current;
          final q = ClassQuestionSource.of(
            s.content.pack!,
            s.toifa.bank,
          ).question(item.questionId)!;
          final idx = (wrong && i.isOdd)
              ? item.order.firstWhere((o) => !item.correct.contains(o))
              : item.correct.single;
          await w.tapScroll(q.option(idx, lang.name));
          if (i < run.length - 1) await w.tapScroll(l.examNext);
        }
        await w.tapScroll(l.examFinish);
        if (!wrong) await w.snap('26_topshirish_tasdiq');
        await tester.tap(find.text(l.examFinish).hitTestable().last);
        await tester.pumpAndSettle();
        await w.snap(wrong ? '28_talaba2_natija' : '27_talaba1_natija');
      }

      await _signIn(tester, s, 'ustoz@example.com');
      await goTo(tester, '/learn/classes/g/${g.id}/t/$_topic');
      await w.snap('29_ustoz_test_holati');
      await w.tapScroll(l.classroomTestResults);
      await w.snap('30_ustoz_natijalar');
      await w.scroll(700);
      await w.snap('31_ustoz_natijalar_past');
      await goTo(tester, '/learn/classes/g/${g.id}/t/$_topic');
      await w.tapScroll(l.classroomTestFinish);
      await w.snap('32_yakunlash_tasdiq');
      await tester.tap(find.text(l.classroomTestFinish).hitTestable().last);
      await tester.pumpAndSettle();
      await w.snap('33_test_yakunlandi');
      // exam_session import faqat tur uchun
      expect(ExamSession, isNotNull);
    });
  }
}
