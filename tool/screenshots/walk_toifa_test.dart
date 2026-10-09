// Toifa imtihoniga tayyorgarlik — foydalanuvchi sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_toifa_test.dart --update-goldens
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import '../../test/helpers/learn_helpers.dart';
import 'walk_helper.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('toifa — laboratoriya mutaxassisi (uz, yorug‘)', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    tester.platformDispatcher.localesTestValue = const [Locale('uz', 'UZ')];
    final s = await start(tester);
    s.exams.random = Random(11);
    s.toifa.random = Random(4);
    final w = Walk(tester, 'toifa_uz');
    await w.snap('bosh_sahifa');
    await w.scroll(700);
    await w.snap('bosh_sahifa_toifa_karta');
    await tapScroll(tester, l.toifaOpen);
    await w.snap('hub');
    await tapScroll(tester, l.toifaCatFirst);
    await w.snap('hub_toifa_tanlandi');
    await w.scroll(600);
    await w.snap('hub_pasti');
    await w.scroll(-2000);
    await tapScroll(tester, l.toifaTestTitle);
    await w.snap('test_sozlama');
    await w.scroll(500);
    await w.snap('test_sozlama_pasti');
    await tapScroll(tester, '70%');
    await tapScroll(tester, l.toifaTestStart);
    await w.snap('test_savol1');
    // Bir nechta savolga javob: birinchi variant.
    for (var i = 0; i < 3; i++) {
      await w.tap(find.text('A').hitTestable().first);
      await tapScroll(tester, l.examNext);
    }
    await w.snap('test_savol4');
    final session = s.exams.active!;
    for (var i = 0; i < session.length; i++) {
      session
        ..goTo(i)
        ..choose(
          i.isEven
              ? session.items[i].correct.first
              : (session.items[i].correct.first + 1) %
                    session.items[i].order.length,
        );
    }
    session.goTo(session.length - 1);
    await s.exams.save(session);
    await tester.pumpAndSettle();
    await tapScroll(tester, l.examFinish);
    await w.snap('yakunlash_oynasi');
    await w.tap(find.text(l.examFinish).hitTestable().last);
    await w.snap('natija');
    await w.scroll(700);
    await w.snap('natija_mavzular');
    await w.scroll(900);
    await w.snap('natija_xatolar');
    // Bahsli kalitli savol natijasi.
    final bank = s.toifa.bank!;
    final disputed = ExamSession.build(
      id: 'bahsli',
      mode: ExamMode.exam,
      questions: [bank.test('kdl-t-121')!, bank.test('kdl-t-262')!],
      random: Random(1),
      startedAt: s.exams.now(),
      sourceId: ToifaQuestionSource.sourceId,
      shuffleOptions: false,
    );
    disputed
      ..goTo(disputed.items.indexWhere((i) => i.questionId == 'kdl-t-121'))
      ..choose(2);
    await s.exams.start(disputed);
    await s.exams.finishActive();
    await goTo(tester, '/learn/toifa/test/result/bahsli');
    await w.scroll(650);
    await w.snap('bahsli_kalit');
    await w.scroll(600);
    await w.snap('bahsli_kalit2');

    await goTo(tester, '/learn/toifa/practice');
    await w.snap('mashq_mavzular');
    await tapScroll(tester, l.toifaTopic('hemostasis'));
    await w.snap('mashq_savol');
    await w.tap(find.text('B').hitTestable().first);
    await w.snap('mashq_javob');
    await w.scroll(600);
    await w.snap('mashq_javob_pasti');

    await goTo(tester, '/learn/toifa/oral');
    await w.snap('ogzaki_kirish');
    await w.scroll(500);
    await tapScroll(tester, l.toifaDrawTicket);
    await w.snap('bilet_tayyorlanish');
    await w.scroll(900);
    await w.snap('bilet_tayyorlanish_pasti');
    await tapScroll(tester, l.toifaShowPlans);
    await w.snap('bilet_savol1');
    await tapScroll(tester, l.toifaShowPlan);
    await w.snap('bilet_reja');
    await w.scroll(800);
    await w.snap('bilet_reja_pasti');
    await w.scroll(1500);
    await w.snap('bilet_baholash');
    await tapScroll(tester, l.toifaRateKnew);
    for (final r in [l.toifaRateUnknown, l.toifaRatePartial, l.toifaRateKnew]) {
      await tapScroll(tester, l.toifaShowPlan);
      await tapScroll(tester, r);
    }
    await w.snap('bilet_savol5');
    await tapScroll(tester, l.toifaShowPlan);
    await tapScroll(tester, l.toifaRateUnknown);
    await w.snap('bilet_yakun');
    await w.scroll(700);
    await w.snap('bilet_yakun_pasti');

    await goTo(tester, '/learn/toifa/mistakes');
    await w.snap('xatolar');
    await w.scroll(1500);
    await w.snap('xatolar_pasti');
    await goTo(tester, '/learn/toifa/progress');
    await w.snap('rivojlanish');
    await w.scroll(700);
    await w.snap('rivojlanish_mavzular');
    // Orqaga: hub — holatlar yangilangan.
    await goTo(tester, '/learn/toifa');
    await w.snap('hub_yakunda');
    await goTo(tester, '/learn');
    await w.snap('organish_tab');
  });

  testWidgets('toifa — ru interfeys, UZ mintaqa, qorong‘i, katta shrift', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    tester.platformDispatcher.localesTestValue = const [Locale('ru', 'UZ')];
    final s = await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
    );
    s.toifa.random = Random(9);
    final w = Walk(tester, 'toifa_ru_dark');
    await goTo(tester, '/learn');
    await w.snap('organish');
    await w.scroll(500);
    await w.snap('organish_karta');
    await tapScroll(tester, l.toifaOpen);
    await w.snap('hub');
    await tapScroll(tester, l.toifaCatHighest);
    await w.scroll(500);
    await w.snap('hub_pasti');
    await goTo(tester, '/learn/toifa/test');
    await w.snap('test_sozlama');
    await goTo(tester, '/learn/toifa/oral');
    await w.scroll(600);
    await tapScroll(tester, l.toifaDrawTicket);
    await w.snap('bilet');
    await tapScroll(tester, l.toifaShowPlans);
    await tapScroll(tester, l.toifaShowPlan);
    await w.snap('reja');
    await w.scroll(900);
    await w.snap('reja_pasti');
    await w.scroll(2000);
    await w.snap('baholash');
    await goTo(tester, '/learn/toifa/practice/hemostasis');
    await w.tap(find.text('A').hitTestable().first);
    await w.snap('mashq_javob');
    await w.scroll(700);
    await w.snap('mashq_javob_pasti');
    await goTo(tester, '/learn/toifa/progress');
    await w.snap('rivojlanish');
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/home');
    await tester.pumpAndSettle();
    await w.scroll(900);
    await w.snap('bosh_sahifa_karta');
  });
}
