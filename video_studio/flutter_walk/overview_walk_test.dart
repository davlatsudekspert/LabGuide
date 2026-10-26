// LabGuide video studio — REAL app frames for the overview video
// "LabGuide for the specialist, the teacher and the student"
// (docs/video/overview/).
//
// Two kinds of walk, each for uz / ru / en:
//   * "overview walk"       no server, guest — role homes, the test card,
//                           instruments, Learn tab, the daily set, a topic quiz
//                           and an exam (all the app's own flows);
//   * "overview class walk" the app's own widget-test fake server
//                           (test/helpers/fake_backend.dart): a teacher opens a
//                           class (code + QR), sets a test with per-student
//                           variants, students submit, the teacher sees the
//                           results. Class names are DEMO data.
// Frames go to public/frames/<lang>/ov_a and ov_b; scripts/overview_frames.py
// merges them with frames reused from earlier videos into .../overview.
//
//   cd /home/user/wt-audit
//   flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
//     /home/user/wt-video/video_studio/flutter_walk/overview_walk_test.dart --update-goldens
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/classroom/qr_code_view.dart';
import 'package:labguide/features/classroom/topic_test_screens.dart' show AssignedTestsCard;
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/learn/learn_screens.dart' show QuizOptionButton;
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'file:///home/user/wt-audit/test/helpers/diff_device_fakes.dart';
import 'file:///home/user/wt-audit/test/helpers/fake_backend.dart';
import 'file:///home/user/wt-audit/test/helpers/harness.dart';
import 'file:///home/user/wt-audit/test/helpers/learn_helpers.dart';
import 'walk_kit.dart';

const _src = 'video_studio/flutter_walk/overview_walk_test.dart';
const _deck = 'd013';
const _analyte = 'glucose-plasma-fasting';

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.signOut();
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _role(WidgetTester tester, AppServices s, AppRole r) async {
  await s.settings.setRole(r);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    // ------------------------------------------------------------ no server
    testWidgets('overview walk ${lang.name}', (tester) async {
      final code = lang.name;
      final l = lookupAppLocalizations(lang.locale);
      installDiffFakes();
      final s = await makeServices(tester, language: lang, role: AppRole.lab);
      await pumpApp(tester, s, ratio: 2);
      final w = Walk(tester, code, 'ov_a', source: _src);

      // 1. Role homes (the home screen follows the role).
      for (final (id, role) in [
        ('home_lab', AppRole.lab),
        ('home_teacher', AppRole.teacher),
        ('home_student', AppRole.student),
      ]) {
        await _role(tester, s, role);
        await goTo(tester, '/home');
        await w.toTop();
        await w.snap(id);
      }

      // 2. The test card: units, thresholds with sources (publisher names
      //    stay out of the viewport).
      await _role(tester, s, AppRole.lab);
      await goTo(tester, '/tests/analyte/$_analyte');
      await w.bring(find.text(l.analyteAtAGlance), at: 150);
      await w.snap('ref_glance', marks: {'glance': find.text(l.analyteAtAGlance)});
      await w.bring(find.text(l.analyteDecisionLimits), at: 150);
      await w.snap('ref_limits', marks: {'limits': find.text(l.analyteDecisionLimits)});

      // 3. Lab hub and the instrument catalog.
      await goTo(tester, '/lab');
      await w.toTop();
      await w.snap('lab_home');
      await goTo(tester, '/lab/instruments');
      await w.toTop();
      await w.snap('inst_list');

      // Qualification-category practice (for the laboratory specialist; shown
      // for Uzbekistan: the region setting is forced so every language walks it).
      await s.settings.setAttestationRegion(AttestationRegion.uz);
      await goTo(tester, '/learn/toifa');
      await w.toTop();
      await w.snap('toifa_hub');

      // 4. Student: Learn tab, daily set, topic quiz, exam.
      await _role(tester, s, AppRole.student);
      await goTo(tester, '/learn');
      await w.toTop();
      await w.snap('learn_student');
      await goTo(tester, '/learn/daily');
      await w.toTop();
      await w.snap('daily');

      await goTo(tester, '/learn/quiz');
      await w.snap('quiz_topics');
      // A random mixed set. The answer's source line may name a publisher:
      // the video dims everything below the answer (named crop, brandOk).
      final quiz = s.content.pack!.quiz;
      await goTo(tester, '/learn/quiz');
      await tapScroll(tester, l.quizTopicMixed(10));
      final q = quiz.firstWhere(
        (q) => find.text(q.prompt.of(code)).evaluate().isNotEmpty,
      );
      await tapScroll(tester, q.options[q.correctIndex].text.of(code));
      await w.toTop();
      double? cutY;
      for (final e in find.byType(RichText).evaluate()) {
        final t = (e.widget as RichText).text.toPlainText();
        if (!denyBrands.any(t.contains)) continue;
        final box = e.renderObject as RenderBox;
        final top = (box.localToGlobal(Offset.zero)).dy;
        if (top > 0 && (cutY == null || top < cutY)) cutY = top;
      }
      final bottom = (cutY ?? 780) - 6;
      await w.snap('quiz_a', brandOk: true, marks: {'answer': find.byType(QuizOptionButton).first});
      (w.frames.last['marks']! as Map)['crop'] = [0.0, 84.0, 390.0, bottom - 84];

      // Exam: 5 questions, 10 minutes (the app's own form), all answered.
      await goTo(tester, '/learn/exam');
      await enterField(tester, l.examCount, '5');
      await tapScroll(tester, l.examMinutes(10));
      await w.snap('exam_setup');
      await tapScroll(tester, l.examStart);
      final exam = s.exams.active!;
      await w.toTop();
      await w.snap('exam_run');
      for (var i = 0; i < exam.length; i++) {
        final item = exam.current;
        final qq = PackQuestionSource.of(s.content.pack!).question(item.questionId)!;
        final correct = i != 1; // one deliberate miss: results show review
        final idx = correct
            ? item.correct.single
            : item.order.firstWhere((o) => !item.correct.contains(o));
        await tapScroll(tester, qq.option(idx, code));
        if (i < exam.length - 1) await tapScroll(tester, l.examNext);
      }
      await tapScroll(tester, l.examFinish);
      await tester.tap(find.text(l.examFinish).hitTestable().last);
      await tester.pumpAndSettle();
      await w.toTop();
      await w.snap('exam_result');

      w.record['shown'] = w.visibleTexts();
      w.save();
      expect(tester.takeException(), isNull);
    });

    // ------------------------------------------------------- fake class server
    testWidgets('overview class walk ${lang.name}', (tester) async {
      final code = lang.name;
      final l = lookupAppLocalizations(lang.locale);
      installDiffFakes();
      final b = FakeLabBackend();
      final s = await makeServices(tester, language: lang, role: AppRole.teacher, backend: b);
      await pumpApp(tester, s, ratio: 2);
      final w = Walk(tester, code, 'ov_b', source: _src);
      final groupName = switch (code) {
        'ru' => 'Гематология, группа А',
        'uz' => 'Gematologiya, A guruh',
        _ => 'Hematology, group A',
      };

      await _signIn(tester, s, 'teacher@example.com');
      await b.registerTeacher();
      final g = await b.createGroup(groupName);
      await _role(tester, s, AppRole.teacher);

      // 1. Teacher: the class with its invite code and QR.
      await goTo(tester, '/learn/classes/g/${g.id}');
      await w.toTop();
      await w.snap('t_group', marks: {'qr': find.byType(QrCodeView)});

      // 2. Teacher: set a test from a lecture deck; per-student variants.
      await goTo(tester, '/learn/lecture/test/$_deck/assign');
      final field = find.byType(TextField).first;
      await tester.ensureVisible(field);
      await tester.enterText(field, '5');
      await tester.pumpAndSettle();
      final toggle = find.byKey(const ValueKey('assign-variant'));
      await w.bring(toggle, at: 330);
      await w.snap('t_assign', marks: {'variant': toggle});
      final send = find.byKey(const ValueKey('assign-send'));
      await tester.ensureVisible(send);
      await tester.pumpAndSettle();
      await tester.tap(send);
      await tester.pumpAndSettle();
      final a = (await b.assignments(g.id)).single;
      final key = await b.assignmentKey(a.id);

      // 3. Two students solve through the server API (as the app's own tests).
      for (final (email, rightN) in [('v1@example.com', 5), ('v2@example.com', 3)]) {
        await _signIn(tester, s, email);
        await b.joinGroup(g.joinCode!);
        await b.startAssignment(a.id);
        final mine = a.questionIdsFor(b.userId);
        final answers = [
          for (var i = 0; i < mine.length; i++)
            i < rightN ? key[a.questionIds.indexOf(mine[i])] : (key[a.questionIds.indexOf(mine[i])] + 1) % 2,
        ];
        await b.submitAssignment(a.id, answers, questionIds: mine);
      }

      // 4. A third student joins with the code (QR link fills it) and sees the test.
      await _signIn(tester, s, 'v3@example.com');
      await _role(tester, s, AppRole.student);
      await goTo(tester, '/learn/classes/join?code=${g.joinCode}');
      await w.toTop();
      await w.snap('s_join', marks: {'code': find.byType(TextField).first});
      await tapScroll(tester, l.classesJoinAction);
      await goTo(tester, '/home');
      await w.toTop();
      final card = find.byKey(const ValueKey('assigned-tests'));
      await w.bring(card, at: 300);
      await w.snap('s_assigned', marks: {'card': card});
      await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
      await w.toTop();
      await w.snap('s_start');

      // 5. Teacher: results per student and per question.
      await _signIn(tester, s, 'teacher@example.com');
      await _role(tester, s, AppRole.teacher);
      await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
      await w.toTop();
      await w.snap('t_results');
      final stud = find.text(l.classesColStudent);
      await w.bring(stud, at: 260);
      await w.snap('t_students', marks: {'students': stud});
      final byQ = find.text(l.classesByQuestion);
      await w.bring(byQ, at: 200);
      await w.snap('t_byq', marks: {'byq': byQ});

      w.record['shown'] = w.visibleTexts();
      w.save();
      expect(tester.takeException(), isNull);
    });
  }
}
