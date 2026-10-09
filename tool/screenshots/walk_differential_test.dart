// Leykoformula — laborant (uz), laborant (ru, qorong‘i, katta shrift) va
// talaba (en) sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_differential_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

Future<void> back(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back_rounded).hitTestable().last);
  await tester.pumpAndSettle();
}

/// Dangasa ro'yxatda pastdagi elementni topib bosish.
Future<void> tapLazy(WidgetTester tester, Walk w, String text) async {
  final f = find.text(text);
  await reveal(tester, f);
  await w.tap(f.last);
}

Future<void> reveal(WidgetTester tester, Finder f) async {
  if (f.hitTestable().evaluate().isNotEmpty) return;
  final list = find
      .byWidgetPredicate(
        (x) => x is Scrollable && x.axisDirection == AxisDirection.down,
      )
      .hitTestable()
      .first;
  // Avval tepaga, so'ng pastga qarab qidiriladi.
  await tester.drag(list, const Offset(0, 6000));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(f, 250, scrollable: list);
  await tester.pumpAndSettle();
}

Finder button(DiffCell c) => find.byKey(ValueKey('diff-count-${c.name}'));

/// Sxemalarni oldindan dekod qilish (rasmlar bo'sh chiqmasin).
Future<void> precacheCells(WidgetTester tester) async {
  await tester.runAsync(() async {
    final ctx = tester.element(find.byType(Scaffold).first);
    for (final id in [...cellGuides.map((c) => c.id), 'hero']) {
      await precacheImage(AssetImage(cellImage(id)), ctx);
    }
  });
}

/// Taqsimot bo'yicha bosish (tez: har bosishdan keyin faqat pump).
Future<void> tapMany(WidgetTester tester, Map<DiffCell, int> plan) async {
  for (final MapEntry(key: c, value: n) in plan.entries) {
    await reveal(tester, button(c));
    await tester.ensureVisible(button(c));
    await tester.pumpAndSettle();
    for (var i = 0; i < n; i++) {
      await tester.tap(button(c));
      await tester.pump(const Duration(milliseconds: 20));
    }
  }
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('laborant: bosh sahifa → leykoformula → sanash → tarix (uz)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await start(tester);
    await precacheCells(tester);
    final w = Walk(tester, 'differential_lab_uz');
    await w.snap('bosh_sahifa');
    await w.tap(find.text(l.diffTitle).last);
    await w.snap('leykoformula_bosh');
    await w.scroll(700);
    await w.snap('leykoformula_bolimlar');
    await w.scroll(1200);
    await w.snap('leykoformula_manbalar');
    await w.scroll(-3000);
    await w.tap(find.text(l.diffCellsTitle).last);
    await w.snap('hujayralar_royxati');
    await w.scroll(1300);
    await w.snap('hujayralar_pasti');
    await w.tap(find.text('Blast').last);
    await w.snap('blast_tepa');
    await w.scroll(700);
    await w.snap('blast_belgilar');
    await back(tester);
    await w.scroll(-3000);
    await w.tap(find.text('Tayoqcha yadroli neytrofil').last);
    await w.snap('tayoqcha_tepa');
    await w.scroll(800);
    await w.snap('tayoqcha_belgilar');
    await back(tester);
    await back(tester);
    await w.tap(find.text(l.diffConfusionsTitle).last);
    await w.snap('adashtiriladiganlar');
    await w.scroll(800);
    await w.snap('adashtiriladiganlar_jadval');
    await back(tester);
    // Hisoblagich.
    await w.scroll(-3000);
    await w.tap(find.text(l.diffStartCount).last);
    await w.snap('hisoblagich_bosh');
    await tapMany(tester, {
      DiffCell.segmented: 30,
      DiffCell.lymphocyte: 12,
      DiffCell.band: 2,
    });
    await w.scroll(-3000);
    await w.snap('hisoblagich_44');
    // Uzoq bosish: −1.
    await tester.longPress(button(DiffCell.band));
    await w.snap('uzoq_bosish_tayoqcha_1');
    await reveal(tester, find.text(l.diffWbcLabel));
    await w.enter(l.diffWbcLabel, '7,5');
    await w.snap('wbc_kiritildi');
    await tapMany(tester, {
      DiffCell.segmented: 29,
      DiffCell.lymphocyte: 18,
      DiffCell.monocyte: 6,
      DiffCell.eosinophil: 3,
      DiffCell.basophil: 1,
    });
    // 100 da to'xtaydi: ortiqcha bosish qo'shilmaydi.
    await reveal(tester, button(DiffCell.segmented));
    await tester.tap(button(DiffCell.segmented));
    await tester.pump();
    await w.scroll(-3000);
    await w.snap('yuz_tugadi');
    expect(s.differential.total, 100);
    await w.scroll(900);
    await w.snap('natija_jadvali');
    await reveal(tester, find.text(l.diffLabelField));
    await w.enter(l.diffLabelField, '12-namuna');
    await w.tap(find.text(l.diffSave).last);
    await w.snap('saqlandi');
    await w.tap(find.text(l.diffCopy).last);
    await w.snap('nusxalandi');
    await w.tap(find.text(l.diffHistoryTitle).last);
    await w.snap('tarix');
    await w.tap(find.textContaining('12-namuna').last);
    await w.snap('tarix_yozuvi');
    // Ilovani qayta ochish: tarix va qoralama qurilmada saqlangan.
    final again = await makeServices(
      tester,
      store: s.store as MemoryKeyValueStore,
    );
    await pumpApp(tester, again);
    await precacheCells(tester);
    await goTo(tester, '/lab/differential/history');
    await w.snap('qayta_ochilgandan_keyin_tarix');
    expect(again.differential.history, hasLength(1));
  });

  testWidgets(
    'laborant: Lab tabi → talqin, texnika, sanash (ru, qorong‘i, 1.35)',
    (tester) async {
      final l = lookupAppLocalizations(const Locale('ru'));
      await start(
        tester,
        lang: AppLanguage.ru,
        theme: ThemeMode.dark,
        textScale: 1.35,
      );
      await precacheCells(tester);
      final w = Walk(tester, 'differential_lab_ru_dark_large');
      await w.tapText(l.navLab);
      await w.snap('lab_tab');
      await w.tap(find.text(l.diffTitle).first);
      await w.snap('leykoformula');
      await tapLazy(tester, w, l.diffInterpretTitle);
      await w.snap('talqin_tepa');
      await w.scroll(900);
      await w.snap('talqin_chapga_siljish');
      await w.scroll(2500);
      await w.snap('talqin_davomi');
      await w.scroll(6000);
      await w.snap('talqin_referens');
      await back(tester);
      await tapLazy(tester, w, l.diffTechniqueTitle);
      await w.snap('texnika_tepa');
      await w.scroll(1400);
      await w.snap('texnika_boyash');
      await w.scroll(1600);
      await w.snap('texnika_sanash');
      await w.scroll(2500);
      await w.snap('texnika_xatolar');
      await back(tester);
      await tapLazy(tester, w, l.diffCounterTitle);
      await w.snap('hisoblagich');
      await tapMany(tester, {DiffCell.monocyte: 4, DiffCell.other: 1});
      await w.scroll(-3000);
      await w.snap('hisoblagich_5');
      await tapLazy(tester, w, l.diffUndo);
      await w.scroll(1200);
      await w.snap('bekor_qilish_va_natija');
    },
  );

  testWidgets('student: Learn → differential → quiz (en)', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    await start(tester, lang: AppLanguage.en, role: AppRole.student);
    await precacheCells(tester);
    final w = Walk(tester, 'differential_student_en');
    await w.tapText(l.navLearn);
    await w.scroll(500);
    await w.snap('learn_tab');
    await w.tap(find.text(l.diffTitle).last);
    await w.snap('differential_home');
    await tapLazy(tester, w, l.diffQuizTitle);
    await w.snap('quiz_intro');
    await w.tap(find.text(l.diffQuizStart).last);
    await w.snap('quiz_q1');
    // Birinchi variant — to'g'ri yoki noto'g'ri, izoh ko'rinadi.
    await w.scroll(500);
    final names = {for (final c in cellGuides) c.name.of('en')};
    await w.tap(
      find
          .byWidgetPredicate((x) => x is Text && names.contains(x.data))
          .hitTestable()
          .first,
    );
    await w.snap('quiz_q1_answered');
    await w.tap(find.text(l.quizNext).last);
    await w.snap('quiz_q2');
    await back(tester);
    await w.scroll(-3000);
    await tapLazy(tester, w, l.diffCellsTitle);
    await w.snap('cells_list');
    await tapLazy(tester, w, 'Monocyte');
    await w.snap('monocyte');
    await w.scroll(800);
    await w.snap('monocyte_features');
  });
}
