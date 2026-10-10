// QA: Lab va O'rganish tablari — har bosishdan keyin manzil va sarlavha
// (walk_helper.dart). "Iflos" holat: boshqa tabda chuqur sahifa ochiq.
//
//   flutter test tool/screenshots/walk_qa_lab_learn_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import '../../test/helpers/learn_helpers.dart';
import 'walk_helper.dart';

final _log = <String>[];

String _where(WidgetTester tester) {
  final loc = routerOf(tester).state.matchedLocation;
  final uri = routerOf(tester).state.uri;
  final pages = find.byType(LgPage).hitTestable().evaluate();
  final title = pages.isEmpty
      ? '(LgPage yo‘q)'
      : (pages.first.widget as LgPage).title;
  return '$uri [$loc] «$title»';
}

Future<void> _step(Walk w, String what, {bool snap = true}) async {
  await w.tester.pumpAndSettle();
  final line = '${w.name}: $what -> ${_where(w.tester)}';
  _log.add(line);
  // ignore: avoid_print
  print(line);
  if (snap) await w.snap(what);
}

Future<void> _tab(Walk w, String label) async {
  await w.tester.tap(find.text(label).hitTestable().last);
  await w.tester.pumpAndSettle();
}

Future<void> _back(Walk w) async {
  final b = find.byTooltip('Back').hitTestable();
  if (b.evaluate().isNotEmpty) {
    await w.tester.tap(b.first);
  } else {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    await w.tester.binding.handlePopRoute();
  }
  await w.tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Avtomatik "hamma narsani bos" o'tishi: sahifadagi har bir LgRow / LgButton
// (onTap bor) bosiladi; natija — manzil, sarlavha, dialog/xato.

typedef _Target = ({String kind, String label});

Finder _finderFor(_Target t) => switch (t.kind) {
  'ink' => find.ancestor(
    of: find.text(t.label),
    matching: find.byWidgetPredicate((w) => w is InkWell && w.onTap != null),
  ),
  'icon' => find.byWidgetPredicate(
    (w) => w is IconButton && w.onPressed != null && w.tooltip == t.label,
  ),
  _ => find.byWidgetPredicate(
    (w) => switch (t.kind) {
      'row' => w is LgRow && w.onTap != null && w.title == t.label,
      'btn' => w is LgButton && w.onPressed != null && w.label == t.label,
      _ => false,
    },
  ),
};

/// InkWell ichidagi birinchi matn (yorliq sifatida).
String? _inkLabel(Element e) {
  String? found;
  void visit(Element c) {
    if (found != null) return;
    final w = c.widget;
    if (w is Text && (w.data ?? '').trim().isNotEmpty) {
      found = w.data;
      return;
    }
    c.visitChildren(visit);
  }

  e.visitChildren(visit);
  return found;
}

Future<void> _toTop(WidgetTester tester) async {
  final sc = _mainScroll();
  if (sc.evaluate().isEmpty) return;
  tester.state<ScrollableState>(sc.first).position.jumpTo(0);
  await tester.pumpAndSettle();
}

Finder _mainScroll() => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .hitTestable();

Future<List<_Target>> _collect(WidgetTester tester) async {
  final out = <_Target>{};
  for (var i = 0; i < 60; i++) {
    for (final e in find.byType(LgRow).hitTestable().evaluate()) {
      final r = e.widget as LgRow;
      if (r.onTap != null) out.add((kind: 'row', label: r.title));
    }
    for (final e in find.byType(LgButton).hitTestable().evaluate()) {
      final b = e.widget as LgButton;
      if (b.onPressed != null) out.add((kind: 'btn', label: b.label));
    }
    final taken = {for (final t in out) t.label};
    for (final e
        in find
            .byWidgetPredicate((w) => w is InkWell && w.onTap != null)
            .hitTestable()
            .evaluate()) {
      final label = _inkLabel(e);
      if (label != null && !taken.contains(label)) {
        out.add((kind: 'ink', label: label));
      }
    }
    for (final e
        in find
            .byWidgetPredicate(
              (w) =>
                  w is IconButton && w.onPressed != null && w.tooltip != null,
            )
            .hitTestable()
            .evaluate()) {
      out.add((kind: 'icon', label: (e.widget as IconButton).tooltip!));
    }
    final sc = _mainScroll();
    if (sc.evaluate().isEmpty) break;
    final pos = tester.state<ScrollableState>(sc.first).position;
    if (pos.pixels >= pos.maxScrollExtent) break;
    await tester.drag(sc.first, const Offset(0, -500));
    await tester.pumpAndSettle();
  }
  return out.toList();
}

int _tapped = 0;

Future<void> _crawl(
  WidgetTester tester,
  String scenario,
  List<String> pages, {
  Set<String> skip = const {},
}) async {
  for (final page in pages) {
    await goTo(tester, page);
    await _toTop(tester);
    final targets = await _collect(tester);
    _log.add(
      '$scenario: SAHIFA $page «${_where(tester)}» — '
      '${targets.length} element',
    );
    for (final t in targets) {
      if (skip.contains(t.label)) continue;
      await goTo(tester, '/home');
      await goTo(tester, page);
      final f = _finderFor(t);
      try {
        await _toTop(tester);
        if (f.hitTestable().evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            f.hitTestable(),
            300,
            scrollable: _mainScroll().first,
            maxScrolls: 60,
          );
        }
        await tester.tap(f.hitTestable().first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        _tapped++;
      } catch (e) {
        _log.add('$scenario:   ! ${t.kind} «${t.label}» bosilmadi: $e');
        continue;
      }
      final ex = tester.takeException();
      final dialog =
          find.byType(Dialog).evaluate().isNotEmpty ||
          find.byType(BottomSheet).evaluate().isNotEmpty;
      final snack = find.byType(SnackBar).evaluate().isNotEmpty;
      final line =
          '$scenario:   ${t.kind} «${t.label}» -> ${_where(tester)}'
          '${dialog ? ' [DIALOG]' : ''}${snack ? ' [SNACK]' : ''}'
          '${ex != null ? ' [XATO: $ex]' : ''}';
      _log.add(line);
      if (dialog) {
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    }
  }
}

const _labPages = [
  '/lab',
  '/lab/qc',
  '/lab/qc/new',
  '/lab/preanalytics',
  '/lab/calculators',
  '/lab/instruments',
  '/lab/calibration',
  '/lab/calibration/log',
  '/lab/differential',
  '/lab/differential/cells',
  '/lab/differential/confusions',
  '/lab/differential/count',
  '/lab/differential/history',
  '/lab/differential/interpret',
  '/lab/differential/technique',
  '/lab/differential/quiz',
  '/lab/microscopy',
  '/lab/microscopy/s/urine',
  '/lab/microscopy/s/blood',
  '/lab/microscopy/s/parasites',
  '/lab/microscopy/credits',
  '/lab/microscopy/i/u-rbc-1',
  '/lab/microscopy/quiz',
  '/lab/instruments/c/chemistry',
  '/lab/differential/cells/neutrophil_band',
  '/lab/differential/count/eyes-free',
  '/lab/calculators/nechiporenko',
  '/lab/calculators/zimnitsky',
  '/lab/calculators/light',
];

const _learnPages = [
  '/learn',
  '/learn/quiz',
  '/learn/exam',
  '/learn/reference',
  '/learn/daily',
  '/learn/toifa',
  '/learn/toifa/test',
  '/learn/toifa/practice',
  '/learn/toifa/oral',
  '/learn/toifa/mistakes',
  '/learn/toifa/progress',
  '/learn/classes',
  '/learn/lesson',
  '/learn/reference/jaundice',
];

void main() {
  setUpAll(loadAppFonts);

  testWidgets('iflos holat: Bosh sahifa → toifa / kunlik (uz)', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    tester.platformDispatcher.localesTestValue = const [Locale('uz', 'UZ')];
    await start(tester, role: AppRole.lab);
    final w = Walk(tester, 'qa_dirty_home_uz');
    // O'rganish tabida toifa mashqi ochiq qoldi.
    await goTo(tester, '/learn/toifa/practice/anemias');
    await _step(w, 'learn_toifa_mashq_ochiq');
    await _tab(w, l.navHome);
    await tapScroll(tester, l.toifaOpen);
    await _step(w, 'home_toifa_tugma');
    await _back(w);
    await _step(w, 'orqaga');
    // O'rganish tabida izohli test ochiq — Bosh sahifadagi kunlik karta.
    await goTo(tester, '/learn/quiz');
    await _tab(w, l.navHome);
    await tapScroll(tester, l.dailyStart);
    await _step(w, 'home_kunlik_tugma');
    await _back(w);
    await _step(w, 'orqaga_kunlik');
    // O'rganish tabini qayta bosish — ildiz.
    await goTo(tester, '/learn/reference/jaundice');
    await _tab(w, l.navLearn);
    await _step(w, 'learn_qayta_bosish');
    await _tab(w, l.navLearn);
    await _step(w, 'learn_qayta_bosish2', snap: false);
    // Lab ichida chuqur → Lab qayta bosish.
    await goTo(tester, '/lab/microscopy/i/u-rbc-1');
    await _tab(w, l.navLab);
    await _step(w, 'lab_qayta_bosish');
    // Android orqaga tab ildizida → Bosh sahifa.
    await _tab(w, l.navLearn);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await _step(w, 'learn_ildiz_orqaga');
  });

  testWidgets('kunlik savol: O‘rganish kartasidan to‘liq (uz)', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    tester.platformDispatcher.localesTestValue = const [Locale('uz', 'UZ')];
    await start(tester, role: AppRole.student);
    final w = Walk(tester, 'qa_daily_uz');
    await goTo(tester, '/learn');
    await tapScroll(tester, l.dailyStart);
    await _step(w, 'savol1');
    for (var i = 0; i < 5; i++) {
      await tapScroll(tester, i.isEven ? 'A' : 'B');
      if (i == 0) await _step(w, 'javob1');
      await tapScroll(tester, i == 4 ? l.dailyShowResult : l.quizNext);
    }
    await _step(w, 'natija');
    await w.scroll(600);
    await _step(w, 'natija_past');
    await w.scroll(600);
    await _step(w, 'natija_past2');
    await tapScroll(tester, l.dailyOfferYes);
    await _step(w, 'eslatma');
    await w.scroll(-5000);
    await tapScroll(tester, l.shareResult);
    await _step(w, 'ulashish');
    await tester.tapAt(const Offset(20, 80));
    await tester.pumpAndSettle();
    await _back(w);
    await _step(w, 'orqaga_learn');
  });

  for (final (role, lang, loc) in [
    (AppRole.doctor, AppLanguage.uz, const Locale('uz', 'UZ')),
    (AppRole.teacher, AppLanguage.uz, const Locale('uz', 'UZ')),
    (AppRole.student, AppLanguage.ru, const Locale('ru', 'RU')),
    (AppRole.lab, AppLanguage.en, const Locale('en', 'US')),
  ]) {
    testWidgets('rol/til: ${role.name} ${lang.name}', (tester) async {
      tester.platformDispatcher.localesTestValue = [loc];
      await start(tester, role: role, lang: lang);
      final w = Walk(tester, 'qa_role_${role.name}_${lang.name}');
      for (final p in ['/learn', '/lab']) {
        await goTo(tester, p);
        await _step(w, p.substring(1));
        await w.scroll(700);
        await _step(w, '${p.substring(1)}_past');
        await w.scroll(900);
        await _step(w, '${p.substring(1)}_past2');
      }
      // Toifa to'g'ridan-to'g'ri manzil bilan.
      await goTo(tester, '/learn/toifa');
      await _step(w, 'toifa_manzil');
      for (final p in [
        '/lab/differential',
        '/lab/microscopy',
        '/learn/exam',
        '/learn/classes',
      ]) {
        await goTo(tester, p);
        await _step(w, p.replaceAll('/', '_'));
      }
    });
  }

  testWidgets('crawl: Lab (laborant, uz)', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('uz', 'UZ')];
    await start(tester);
    await _crawl(tester, 'crawl_lab', _labPages);
    _log.add('crawl_lab: jami bosildi $_tapped');
  });

  testWidgets('crawl: O‘rganish (talaba, uz)', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('uz', 'UZ')];
    await start(tester, role: AppRole.student);
    await _crawl(tester, 'crawl_learn', _learnPages);
    _log.add('crawl_learn: jami bosildi $_tapped');
  });
  tearDownAll(() {
    // ignore: avoid_print
    print('==== QA LOG ====\n${_log.join('\n')}');
  });

  testWidgets('iflos holat: O‘rganish → Lab qatorlari (uz)', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    await start(tester, role: AppRole.student);
    final w = Walk(tester, 'qa_dirty_uz');

    // 1) Lab tabida QC ochiq qoldi.
    await goTo(tester, '/lab/qc');
    await _step(w, 'lab_qc_ochiq');
    await _tab(w, l.navLearn);
    await _step(w, 'learn');
    await tapScroll(tester, l.diffTitle);
    await _step(w, 'learn_leykoformula_qc_dan_keyin');
    await _back(w);
    await _step(w, 'orqaga');

    // 2) Lab tabida hujayra kartasi ochiq.
    await goTo(tester, '/lab/differential/cells/neutrophil_band');
    await _step(w, 'lab_hujayra_ochiq');
    await _tab(w, l.navLearn);
    await tapScroll(tester, l.diffTitle);
    await _step(w, 'learn_leykoformula_hujayradan_keyin');
    await _back(w);
    await _step(w, 'orqaga2');

    // 3) Lab tabida mikroskopiya rasmi ochiq.
    await goTo(tester, '/lab/microscopy/i/u-rbc-1');
    await _step(w, 'lab_rasm_ochiq');
    await _tab(w, l.navLearn);
    await tapScroll(tester, l.micTitle);
    await _step(w, 'learn_mikroskopiya_rasmdan_keyin');
    await _back(w);
    await _step(w, 'orqaga3');

    // 4) Lab tabida kalkulyator ochiq → mikroskopiya.
    await goTo(tester, '/lab/calculators');
    await _tab(w, l.navLearn);
    await tapScroll(tester, l.micTitle);
    await _step(w, 'learn_mikroskopiya_kalkdan_keyin');

    // 5) Lab tabida leykoformula tarixi ochiq → leykoformula.
    await goTo(tester, '/lab/differential/history');
    await _tab(w, l.navLearn);
    await tapScroll(tester, l.diffTitle);
    await _step(w, 'learn_leykoformula_tarixdan_keyin');

    // 6) Lab tabini qayta bosish — ildiz.
    await _tab(w, l.navLab);
    await _step(w, 'lab_qayta_bosish');
  });

  testWidgets('toza holat: O‘rganish qatorlari (uz)', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    tester.platformDispatcher.localesTestValue = const [Locale('uz', 'UZ')];
    await start(tester, role: AppRole.student);
    final w = Walk(tester, 'qa_learn_uz');
    await _tab(w, l.navLearn);
    await _step(w, 'learn');
    for (final row in [
      l.learnHeroCta,
      l.classesTitle,
      l.learnQuiz,
      l.learnExam,
      l.refTitle,
      l.learnLessonPlan,
    ]) {
      await tapScroll(tester, row);
      await _step(w, 'row_$row');
      await _back(w);
      await _step(w, 'orqaga_$row', snap: false);
    }
    for (final row in [l.diffTitle, l.micTitle]) {
      await _tab(w, l.navLearn);
      await tapScroll(tester, row);
      await _step(w, 'row_$row');
      await _back(w);
      await _step(w, 'orqaga_$row');
    }
  });
}
