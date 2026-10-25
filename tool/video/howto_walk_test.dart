// Video qo‘llanmalar (docs/video/PLAN.md) uchun kadrlar: 10 mavzu × uz/ru/en.
// Har kadr — ilovaning haqiqiy ekrani (serversiz, haqiqiy kontent, Klassik,
// yorug‘, 390×844 @2x). Kadr nomlari tool/video/storyboards.json dagi id lar
// bilan bir xil; subtitrlar o‘sha faylda.
//
//   flock /tmp/flutter_test.lock flutter test tool/video/howto_walk_test.dart \
//     --update-goldens --name ' uz$'
//   python3 tool/video/compose.py --lang uz
//
// Kadrlar: tool/video/out/frames/<til>/<mavzu>/ (+ frames.json), gitignore.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/coprology/copro_content.dart';
import 'package:labguide/features/cytology/cytology_screens.dart';
import 'package:labguide/features/howto/howto_widgets.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import '../../test/helpers/learn_helpers.dart';
import 'video_walk.dart';

typedef _Topic =
    Future<void> Function(
      WidgetTester tester,
      AppServices s,
      VideoWalk w,
      AppLocalizations l,
      String lang,
    );

/// Yakuniy kadr: bo‘lim sahifasidagi “Qanday foydalaniladi?” oynasi.
Future<void> _howto(VideoWalk w, String route, String id) async {
  await w.go(route);
  await w.pressKey('howto-$id');
  await w.snap('howto');
}

/// 01 — Kalibrlash (+ jurnal).
Future<void> _calibration(
  WidgetTester tester,
  AppServices s,
  VideoWalk w,
  AppLocalizations l,
  String lang,
) async {
  await w.go('/lab');
  await w.show(find.byKey(const ValueKey('lab-calibration')));
  await w.snap('lab_tools');
  await w.pressKey('lab-calibration');
  await w.snap('cal_top');
  await w.pressText(l.calFromCatalog);
  final search = find.descendant(
    of: find.byType(BottomSheet),
    matching: find.byType(TextField),
  );
  await tester.enterText(search.first, 'Humalyzer 4000');
  await tester.pumpAndSettle();
  await w.snap('cal_catalog');
  // Qator sarlavhasi: “HUMAN HumaLyzer 4000” (qidiruv maydoni emas).
  await w.press(find.textContaining('HumaLyzer 4000').last);
  final analyte = s.content.pack!.analyte('glucose-plasma-fasting')!;
  final word = {'uz': 'glyukoza', 'ru': 'глюкоза', 'en': 'glucose'}[lang]!;
  final box = find.byWidgetPredicate(
    (x) => x is TextField && x.decoration?.hintText == l.calAnalyteHint,
  );
  await w.show(box);
  await tester.enterText(box, word);
  await tester.pumpAndSettle();
  await w.show(find.text(analyte.names.of(lang)));
  await w.snap('cal_analyte');
  await w.pressText(analyte.names.of(lang));
  await enterField(tester, l.calReagentRef, '10121');
  await enterField(tester, l.calIfuRevision, '2024-01');
  await w.show(find.text(l.calShowGuide));
  await w.snap('cal_reagent');
  await w.pressText(l.calShowGuide);
  await w.show(find.text(l.calRecordCreate));
  await w.scroll(-260);
  await w.snap('cal_guide');
  await w.pressText(l.calRecordCreate);
  await enterField(tester, l.calCalibratorLot, 'L-77');
  await enterField(tester, l.calLevelUnit, 'mmol/L');
  await enterField(tester, l.calLevelValue, '5,55');
  await w.show(find.text(l.calRecordSave));
  await w.snap('cal_record');
  await w.pressText(l.calRecordSave);
  await w.snap('cal_saved');
  await w.go('/lab/calibration/log');
  await w.snap('cal_log');
  await _howto(w, '/lab/calibration', 'calibration');
}

/// 02 — Sifat nazorati (Levey–Jennings, Westgard, EQA yo‘riqnomasi).
Future<void> _qc(
  WidgetTester tester,
  AppServices s,
  VideoWalk w,
  AppLocalizations l,
  String lang,
) async {
  Future<void> tall(bool on) async {
    tester.view.physicalSize = Size(390, on ? 3600 : 844) * 2;
    await tester.pumpAndSettle();
  }

  await w.go('/lab');
  await w.show(find.text(l.featureQc));
  await w.snap('lab_tools');
  await w.pressText(l.featureQc);
  await w.snap('qc_empty');
  await w.pressText(l.qcAddSet);
  final f = find.byType(TextField);
  await tall(true);
  for (final (i, v) in [
    (0, 'Glucose'),
    (1, 'mmol/L'),
    (4, '5,0'),
    (5, '0,2'),
    (8, '15'),
    (9, '0,5'),
  ]) {
    await tester.enterText(f.at(i), v);
  }
  await tall(false);
  await w.scroll(-2000);
  await w.snap('qc_form');
  await tall(true);
  await tester.tap(find.text(l.qcSave).hitTestable().last);
  await tester.pumpAndSettle();
  await tall(false);
  await w.snap('qc_set_empty');
  final runs = [
    ['5,1', '15,1'],
    ['5,5', '15,1'],
    ['5,7', '15,2'],
  ];
  for (final (i, v) in runs.indexed) {
    await tall(true);
    final lf = find.byType(TextField);
    await tester.enterText(lf.first, v[0]);
    await tester.enterText(lf.at(1), v[1]);
    await tester.tap(find.text(l.qcSaveRun).hitTestable().last);
    await tester.pumpAndSettle();
    await tall(false);
    if (i == 1) await w.snap('qc_run_warning');
  }
  await w.snap('qc_run_reject');
  await w.scroll(520);
  await w.snap('qc_chart');
  await w.go('/lab/qc');
  await w.show(find.text(l.qgEqa));
  await w.snap('qc_guides');
  await w.pressText(l.qgEqa);
  await w.snap('qc_eqa');
  await _howto(w, '/lab/qc', 'qc');
}

/// 03 — Preanalitika.
Future<void> _preanalytics(
  WidgetTester tester,
  AppServices s,
  VideoWalk w,
  AppLocalizations l,
  String lang,
) async {
  await w.go('/lab');
  await w.show(find.text(l.labPreanalytics));
  await w.snap('lab_tools');
  await w.pressText(l.labPreanalytics);
  await w.snap('pre_top');
  await w.top(find.text(l.prePatientTitle));
  await w.snap('pre_patient');
  await w.top(find.text(l.preOrderTitle));
  await w.snap('pre_tubes');
  await w.top(find.text(l.preTubeForTestTitle));
  await w.snap('pre_more');
  await _howto(w, '/lab/preanalytics', 'preanalytics');
}

/// 04 — Kalkulyatorlar.
Future<void> _calculators(
  WidgetTester tester,
  AppServices s,
  VideoWalk w,
  AppLocalizations l,
  String lang,
) async {
  await w.go('/lab');
  await w.show(find.text(l.featureCalculators));
  await w.snap('lab_tools');
  await w.pressText(l.featureCalculators);
  await w.snap('calc_list');
  await w.press(find.textContaining('eGFR').first);
  await w.snap('calc_egfr');
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), '88');
  await tester.enterText(fields.at(1), '45');
  await tester.pumpAndSettle();
  await w.show(find.text(l.sexMale));
  await w.snap('calc_egfr_input');
  await w.pressText(l.sexMale);
  await w.pressText(l.dilCalculate);
  await w.show(find.text(l.resGfrCategory('G1')));
  await w.scroll(140);
  await w.snap('calc_egfr_result');
  await w.scroll(600);
  await w.snap('calc_egfr_sources');
  await _howto(w, '/lab/calculators', 'calculators');
}

/// 05 — Apparatlar va metodikalar.
Future<void> _instruments(
  WidgetTester tester,
  AppServices s,
  VideoWalk w,
  AppLocalizations l,
  String lang,
) async {
  await w.go('/lab');
  await w.show(find.text(l.labInstruments));
  await w.snap('lab_tools');
  await w.pressText(l.labInstruments);
  await w.snap('ins_top');
  await w.press(find.byIcon(Icons.bloodtype_outlined).first);
  await w.snap('ins_makers');
  await w.press(find.byIcon(Icons.chevron_right_rounded).first);
  await w.snap('ins_models');
  await w.press(find.byIcon(Icons.chevron_right_rounded).first);
  await w.snap('ins_model');
  await w.scroll(330);
  await w.snap('ins_model_actions');
  await w.go('/lab/instruments');
  final dir = find.text(l.labDirRowTitle(l.labDirBacteriology));
  await w.show(dir);
  await w.snap('ins_directions');
  await w.press(dir);
  await w.snap('ins_dir_cards');
  final card = s.instruments.catalog!.labCard('a3-bac-vitek2-platform')!;
  await w.press(find.text(card.name.of(lang)));
  await w.snap('ins_card');
  final fig = find.byKey(const ValueKey('lab-card-schematic'));
  await w.show(fig, step: 300);
  await w.scroll(tester.getTopLeft(fig).dy - 180);
  await w.snap('ins_schematic');
  await _howto(w, '/lab/instruments', 'instruments');
}

/// 06 — Mikroskopiya atlasi (+ mashq).
Future<void> _microscopy(
  WidgetTester tester,
  AppServices s,
  VideoWalk w,
  AppLocalizations l,
  String lang,
) async {
  await w.go('/lab');
  await w.show(find.byKey(const ValueKey('lab-microscopy')));
  await w.snap('lab_sections');
  await w.pressKey('lab-microscopy');
  await w.snap('mic_top');
  final atlas = s.microscopy.atlas!;
  final urine = atlas.sections.firstWhere((x) => x.id == 'urine');
  final urineTitle = find.text(urine.name.of(lang));
  await w.show(urineTitle);
  await w.snap('mic_sections');
  await w.press(urineTitle);
  await w.snap('mic_section');
  await w.press(find.byType(Image).first);
  await w.snap('mic_image');
  await w.go('/lab/microscopy');
  final word = {'uz': 'oksalat', 'ru': 'оксалат', 'en': 'oxalate'}[lang]!;
  await tester.enterText(find.byType(TextField).first, word);
  await tester.pumpAndSettle();
  await w.snap('mic_search');
  await w.type(find.byType(TextField).first, '');
  await w.pressText(l.micQuizCta);
  await w.snap('mic_quiz_setup');
  await w.press(find.textContaining(l.micQuizStart(1).split('·').first.trim()));
  await w.snap('mic_quiz_q');
  await w.press(find.text('A').hitTestable().first);
  await w.snap('mic_quiz_answer');
  await _howto(w, '/lab/microscopy', 'microscopy');
}

/// 07 — Najas tahlili va parazitologiya.
Future<void> _coprology(
  WidgetTester tester,
  AppServices s,
  VideoWalk w,
  AppLocalizations l,
  String lang,
) async {
  await w.go('/lab');
  await w.show(find.text(l.coproTitle));
  await w.snap('lab_sections');
  await w.pressText(l.coproTitle);
  await w.snap('copro_top');
  final collect = find.text(CpL.collectTitle.of(lang));
  await w.show(collect);
  await w.snap('copro_rows');
  await w.press(collect);
  await w.snap('copro_collect');
  await w.go('/lab/coprology');
  await w.pressText(CpL.microTitle.of(lang));
  await w.snap('copro_micro');
  await w.scroll(1100);
  await w.snap('copro_micro_more');
  await w.go('/lab/coprology');
  await w.pressText(CpL.parasitesTitle.of(lang));
  await w.snap('copro_parasites');
  await w.scroll(700);
  await w.snap('copro_parasites_key');
  await _howto(w, '/lab/coprology', 'coprology');
}

/// 08 — Bilim va malakani baholash.
Future<void> _assessment(
  WidgetTester tester,
  AppServices s,
  VideoWalk w,
  AppLocalizations l,
  String lang,
) async {
  s.exams.random = Random(11);
  s.toifa.random = Random(4);
  if (lang != 'uz') {
    // Bo‘lim faqat O‘zbekiston uchun: ru/en interfeysda — Profil sozlamasi.
    await w.go('/profile');
    final uzChip = find.text(l.profileAttestationUz);
    await w.show(uzChip);
    await w.scroll(200);
    await w.snap('as_profile');
    await w.press(uzChip);
  }
  await w.go('/learn');
  final card = find.text(l.toifaTitle);
  await w.show(card);
  await w.scroll(tester.getTopLeft(card.first).dy - 260);
  await w.snap('as_learn');
  await w.go('/learn/toifa');
  await w.snap('as_hub');
  await w.show(find.text(l.toifaCatFirst));
  await w.snap('as_category');
  await w.pressText(l.toifaCatFirst);
  await w.show(find.text(l.toifaTestTitle));
  await w.snap('as_rows');
  await w.pressText(l.toifaTestTitle);
  await w.snap('as_test_setup');
  await w.pressText(l.toifaTestStart);
  await w.snap('as_test_q');
  await w.go('/learn/toifa/practice');
  await w.snap('as_practice');
  await w.pressText(l.toifaTopic('hemostasis'));
  await w.snap('as_practice_q');
  await w.press(find.text('B').hitTestable().first);
  await w.snap('as_practice_key');
  await w.go('/learn/toifa/oral');
  await w.show(find.text(l.toifaDrawTicket));
  await w.snap('as_oral');
  await w.pressText(l.toifaDrawTicket);
  await w.pressText(l.toifaShowPlans);
  await w.snap('as_ticket');
  await w.pressText(l.toifaShowPlan);
  await w.snap('as_plan');
  await w.go('/learn/toifa/progress');
  await w.snap('as_progress');
  await _howto(w, '/learn/toifa', 'assessment');
}

/// 09 — Testlar, og‘zaki savollar va natijalar (izohli test, imtihon,
/// kunlik savol).
Future<void> _tests(
  WidgetTester tester,
  AppServices s,
  VideoWalk w,
  AppLocalizations l,
  String lang,
) async {
  s.exams.random = Random(5);
  await w.go('/learn');
  await w.show(find.text(l.learnQuiz));
  await w.snap('learn_rows');
  await w.pressText(l.learnQuiz);
  await w.snap('quiz_topics');
  await w.pressText(l.quizTopicMixed(10));
  await w.snap('quiz_q');
  final option = find.byWidgetPredicate(
    (x) => x.runtimeType.toString() == 'QuizOptionButton',
  );
  await w.press(option.first);
  await w.snap('quiz_feedback');
  await w.go('/learn/exam');
  await w.snap('exam_setup');
  await enterField(tester, l.examCount, '3');
  await w.show(find.text(l.examStart));
  await w.snap('exam_ready');
  await w.pressText(l.examStart);
  await w.snap('exam_q');
  final exam = s.exams.active!;
  final src = PackQuestionSource.of(s.content.pack!);
  for (var i = 0; i < exam.length; i++) {
    final item = exam.current;
    final q = src.question(item.questionId)!;
    final idx = i == 1
        ? item.order.firstWhere((o) => !item.correct.contains(o))
        : item.correct.first;
    await w.show(find.text(q.option(idx, lang)));
    await tester.tap(find.text(q.option(idx, lang)).hitTestable().last);
    await tester.pumpAndSettle();
    if (i < exam.length - 1) {
      await w.show(find.text(l.examNext));
      await tester.tap(find.text(l.examNext).hitTestable().last);
      await tester.pumpAndSettle();
    }
  }
  await w.show(find.text(l.examFinish));
  await tester.tap(find.text(l.examFinish).hitTestable().first);
  await tester.pumpAndSettle();
  await w.snap('exam_finish');
  await w.press(find.text(l.examFinish).hitTestable().last);
  await w.snap('exam_result');
  await w.scroll(650);
  await w.snap('exam_mistakes');
  await w.go('/learn/daily');
  await w.snap('daily');
}

/// 10 — Boshqa asosiy funksiyalar (Lab bo‘limlari).
Future<void> _other(
  WidgetTester tester,
  AppServices s,
  VideoWalk w,
  AppLocalizations l,
  String lang,
) async {
  await w.go('/lab');
  await w.snap('lab_top');
  await w.go('/lab/differential');
  await w.snap('diff_hub');
  await w.pressKey('howto-differential');
  await w.snap('diff_howto');
  final close = find.descendant(
    of: find.byType(HowToSheet),
    matching: find.text(l.actionClose),
  );
  // QA: tap belgisi oynadagi “Yopish” da bo‘lsin (avval hub tugmasining
  // joyiga — oyna ustiga — tushib qolgan edi).
  await w.press(close);
  await w.pressText(l.diffStartCount);
  await w.snap('diff_count');
  await w.go('/lab/cytology');
  await w.snap('cyto_hub');
  await w.go('$cytoBase/degree');
  await w.snap('cyto_degree');
  await w.go('/lab/spermogram');
  await w.snap('sperm_hub');
  await w.go('/lab/bloodgroup');
  await w.snap('bg_hub');
  await w.go('/lab/histology');
  await w.snap('histo_hub');
  await w.go('/lab/histology/items');
  await w.snap('histo_items');
  await w.go('/lab/urinalysis');
  await w.snap('urin_hub');
  await w.go('/lab/bloodmorph');
  await w.snap('bm_hub');
  await w.go('/lab/coagulogram');
  await w.snap('coag_hub');
  await w.go('/profile');
  await w.snap('profile');
}

const _topics = <String, _Topic>{
  '01_kalibrlash': _calibration,
  '02_sifat_nazorati': _qc,
  '03_preanalitika': _preanalytics,
  '04_kalkulyatorlar': _calculators,
  '05_apparatlar': _instruments,
  '06_mikroskopiya': _microscopy,
  '07_najas_parazitologiya': _coprology,
  '08_bilim_baholash': _assessment,
  '09_testlar_natijalar': _tests,
  '10_boshqa_funksiyalar': _other,
};

void main() {
  setUpAll(loadAppFonts);
  for (final lang in AppLanguage.values) {
    for (final e in _topics.entries) {
      testWidgets('video ${e.key} ${lang.name}', (tester) async {
        final s = await startVideo(tester, lang: lang);
        final l = lookupAppLocalizations(lang.locale);
        final w = VideoWalk(tester, lang.name, e.key);
        await e.value(tester, s, w, l, lang.name);
        w.save();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
