// Yuklashdan oldingi qisqa walk-test: faqat tugmalar bosiladi (goTo yo'q),
// ilova birinchi marta ochilgandek. Har qadamda rasm
// (tool/screenshots/out/walk/smoke_uz/NN_<qadam>.png).
//
//   flutter test tool/screenshots/walk_smoke_test.dart --update-goldens
//
// Ochilish → mehmon → rol → til (RU va qaytib UZ) → Tahlillar → glyukoza
// kartasi → Lab → kalkulyatorlar → eGFR → leykoformula (sanash) → imtihon
// (3 savol) → natija. Qulash, overflow yoki ishlamaydigan tugma — test yiqiladi.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import '../../test/helpers/learn_helpers.dart';
import 'walk_helper.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('smoke: ochilish → mehmon → … → imtihon natijasi (uz)', (
    tester,
  ) async {
    final uz = lookupAppLocalizations(const Locale('uz'));
    final ru = lookupAppLocalizations(const Locale('ru'));
    final s = await makeServices(tester, onboarded: false, role: null);
    await pumpApp(tester, s);
    final w = Walk(tester, 'smoke_uz');

    // 1. Ochilish va mehmon.
    await w.snap('ochilish');
    await w.tapText(uz.welcomeGuest);
    expect(find.text(uz.rolesTitle), findsOneWidget);
    await w.snap('rol_tanlash');

    // 2. Rol.
    await w.tapText(uz.roleLab);
    await w.tapText(uz.actionContinue);
    expect(s.settings.onboarded, isTrue);
    expect(s.settings.role, AppRole.lab);
    await w.snap('bosh_sahifa');

    // 3. Til: RU → UZ.
    await w.tap(find.byTooltip(uz.actionLanguage).hitTestable().first);
    await tester.tap(find.text('Русский').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(s.settings.language, AppLanguage.ru);
    expect(find.text(ru.navTests), findsWidgets);
    await w.snap('bosh_sahifa_ru');
    await w.tap(find.byTooltip(ru.actionLanguage).hitTestable().first);
    await tester.tap(find.text('O‘zbekcha').last, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(s.settings.language, AppLanguage.uz);

    // 4. Tahlillar → glyukoza kartasi.
    await w.tap(find.text(uz.navTests).hitTestable().last);
    await w.snap('tahlillar');
    await tapScroll(tester, 'Och qoringa plazma glyukozasi');
    expect(find.text('Och qoringa plazma glyukozasi'), findsWidgets);
    await w.snap('glyukoza_kartasi');

    // 5. Lab → kalkulyatorlar → eGFR.
    await w.tap(find.text(uz.navLab).hitTestable().last);
    await w.snap('lab');
    await tapScroll(tester, uz.featureCalculators);
    await w.snap('kalkulyatorlar');
    await tapScroll(tester, uz.calcEgfr);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '88.4');
    await tester.enterText(fields.at(1), '40');
    await tester.pumpAndSettle();
    await tapScroll(tester, uz.sexMale);
    await tapScroll(tester, uz.dilCalculate);
    expect(find.text(uz.resGfrCategory('G1')), findsOneWidget);
    await w.snap('egfr_natija');

    // 6. Lab tabining ildiziga qaytish (tabni qayta bosish) → leykoformula.
    await w.tap(find.text(uz.navLab).hitTestable().last);
    await w.tap(find.text(uz.navLab).hitTestable().last);
    await tapScroll(tester, uz.diffTitle);
    expect(find.text(uz.diffHeroTitle), findsOneWidget);
    await w.snap('leykoformula');
    await tapScroll(tester, uz.diffStartCount);
    final seg = find.byKey(const ValueKey('diff-count-segmented'));
    final lym = find.byKey(const ValueKey('diff-count-lymphocyte'));
    await tester.ensureVisible(seg);
    await tester.pumpAndSettle();
    for (var i = 0; i < 6; i++) {
      await tester.tap(seg);
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.ensureVisible(lym);
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.tap(lym);
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
    expect(s.differential.total, 10);
    expect(s.differential.count(DiffCell.segmented), 6);
    await w.snap('leykoformula_sanash');

    // 7. O'rganish → imtihon (3 savol, 5 daqiqa) → natija.
    await w.tap(find.text(uz.navLearn).hitTestable().last);
    await w.snap('organish');
    await tapScroll(tester, uz.learnExam);
    await enterField(tester, uz.examCount, '3');
    await enterField(tester, uz.examTime, '5');
    await tapScroll(tester, uz.examStart);
    final exam = s.exams.active!;
    expect(exam.length, 3);
    await w.snap('imtihon_savol');
    await answerCurrent(tester, s, exam, correct: true);
    await tapScroll(tester, uz.examNext);
    await answerCurrent(tester, s, exam, correct: false);
    await tapScroll(tester, uz.examNext);
    await answerCurrent(tester, s, exam, correct: true);
    await tester.tap(find.text(uz.examFinish).hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(uz.examFinish).hitTestable().last);
    await tester.pumpAndSettle();
    expect(find.text(uz.examResultTitle), findsWidgets);
    expect(find.text(uz.quizScore(2, 3)), findsOneWidget);
    expect(s.exams.active, isNull);
    await w.snap('imtihon_natija');
  });
}
