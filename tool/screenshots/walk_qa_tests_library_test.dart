// QA: Tahlillar (/tests) va Kutubxona (/library) — har bir bosiladigan
// element foydalanuvchi kabi bosiladi; har bosishdan keyin manzil, sarlavha
// va rasm (out/walk/qa_*/...).
//
//   flutter test tool/screenshots/walk_qa_tests_library_test.dart \
//     --update-goldens --concurrency=1
//
// Natijalar jurnali: tool/screenshots/out/walk/qa_log.txt
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/content/ui/conditions_screens.dart';
import 'package:labguide/features/content/ui/content_widgets.dart';
import 'package:labguide/features/reference/reference_content.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/tools/calc_info.dart';
import 'package:labguide/features/tools/clinical_calc_screens.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import '../../test/helpers/library_fixtures.dart';
import 'walk_helper.dart';

final _log = StringBuffer();
int _taps = 0;

String _loc(WidgetTester t) => routerOf(t).state.uri.toString();

String _title(WidgetTester t) {
  final f = find.byType(LgPage).hitTestable();
  if (f.evaluate().isEmpty) return '?';
  return t.widget<LgPage>(f.first).title;
}

void _rec(WidgetTester t, String what, {String? expect}) {
  _taps++;
  final loc = _loc(t);
  final ok = expect == null
      ? ''
      : (loc == expect || loc.startsWith(expect)
            ? ' OK'
            : ' !!! kutilgan=$expect');
  _log.writeln('[$_taps] $what -> $loc | "${_title(t)}"$ok');
}

Finder _vScroll() {
  final all = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );
  final hit = all.hitTestable();
  if (hit.evaluate().isNotEmpty) return hit.first;
  final page = find.byType(LgPage).hitTestable();
  if (page.evaluate().isNotEmpty) {
    return find.descendant(of: page.first, matching: all).first;
  }
  return find.descendant(of: find.byType(LgPage).last, matching: all).first;
}

Future<void> _scrollTo(WidgetTester t, Finder f, {double step = 250}) async {
  for (var i = 0; i < 200 && f.evaluate().isEmpty; i++) {
    await t.drag(_vScroll(), Offset(0, -step));
    await t.pump();
  }
  await t.ensureVisible(f.first);
  await t.pumpAndSettle();
}

Future<void> _back(WidgetTester t, AppLocalizations l) async {
  await t.tap(find.byTooltip(l.actionBack).hitTestable().first);
  await t.pumpAndSettle();
}

Future<void> _tab(WidgetTester t, String label) async {
  await t.tap(find.text(label).hitTestable().last);
  await t.pumpAndSettle();
}

/// Kartadagi har bir havola: bosib, manzilni yozib, qaytish.
Future<void> _auditCard(
  WidgetTester t,
  AppLocalizations l,
  ContentPack pack,
  Analyte a,
  String lang, {
  Walk? w,
}) async {
  final cardLoc = '/tests/analyte/${a.id}';
  expect(_loc(t), cardLoc);
  final links = <(String, Finder, String)>[
    for (final id in a.related)
      if (pack.analyte(id) case final r?)
        (
          'bog‘liq: ${r.names.of(lang)}',
          find.widgetWithText(AnalyteRow, r.names.of(lang)),
          '/tests/analyte/${r.id}',
        ),
    if (a.conversion != null)
      ('birlik', find.text(l.analyteConvertUnits), '$cardLoc/units'),
    for (final c in calculatorsByAnalyte[a.id] ?? const <ClinicalCalc>[])
      (
        'kalkulyator ${c.name}',
        find.text(calcTitle(c, l)),
        '/lab/calculators/${calcRoute(c)}',
      ),
    for (final r in refTopicsForAnalyte(a.id))
      (
        'jadval ${r.id}',
        find.text(r.title.of(lang)),
        '/learn/reference/${r.id}',
      ),
    (
      'kalibrovka',
      find.text(l.analyteMethodCalibration),
      '/lab/calibration?analyte=${a.id}',
    ),
    (
      'mashq',
      find.text(l.analytePractice),
      pack.quiz.any((q) => q.topicIds.contains(a.id))
          ? '$cardLoc/quiz'
          : '/learn/quiz',
    ),
  ];
  for (final (name, f, want) in links) {
    await _scrollTo(t, f);
    await t.tap(f.first);
    await t.pumpAndSettle();
    _rec(t, '${a.id}: $name', expect: want);
    if (_loc(t).startsWith('/tests/')) {
      await _back(t, l);
    } else {
      await _tab(t, l.navTests);
    }
    final back = _loc(t);
    if (back != cardLoc) {
      _log.writeln('   !!! qaytishda $back (kutilgan $cardLoc)');
    }
  }
  // Saqlash (ikki marta: qo'shish / olib tashlash).
  await _scrollTo(t, find.text(l.analyteSave), step: -250);
  await t.tap(find.text(l.analyteSave));
  await t.pumpAndSettle();
  _rec(t, '${a.id}: saqlash');
  await w?.snap('saqlash_${a.id}');
  final savedNow = find.text(l.analyteSavedToast).evaluate().isNotEmpty;
  if (!savedNow) _log.writeln('   !!! saqlash toasti yo‘q');
  await t.tap(find.text(l.analyteSaved));
  await t.pumpAndSettle();
  // Manba havolasi (testda tashqi ilova yo'q → nusxalanadi).
  final withUrl = [
    for (final id in a.sourceIds)
      if (pack.source(id) case final s? when s.url != null) s,
  ];
  if (withUrl.isNotEmpty) {
    final f = find.textContaining(withUrl.first.title);
    await _scrollTo(t, f);
    await t.tap(f.first);
    // Platforma kanali (url_launcher) haqiqiy async'da javob beradi.
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await t.pumpAndSettle();
    _rec(t, '${a.id}: manba');
    await w?.snap('manba_${a.id}');
    if (find.text(l.linkCopied).evaluate().isEmpty) {
      _log.writeln('   !!! manba bosilganda hech narsa (nusxa toasti yo‘q)');
    }
  }
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
    setUpPdfiumForTests();
  });

  tearDownAll(() {
    final f = File('tool/screenshots/out/walk/qa_log.txt')
      ..createSync(recursive: true);
    f.writeAsStringSync('Jami bosish: $_taps\n$_log');
  });

  testWidgets('A: har guruhdan 2 ta karta — barcha havolalar', (t) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await start(t);
    final pack = s.content.pack!;
    _log.writeln('== A: kartalar ==');
    Walk? w = Walk(t, 'qa_card_uz');
    await goTo(t, '/tests');
    for (final g in pack.groups) {
      final inGroup = pack.analytes.where((a) => a.group == g.id).take(2);
      for (final a in inGroup) {
        await goTo(t, '/tests');
        await goTo(t, '/tests/analyte/${a.id}');
        await _auditCard(t, l, pack, a, 'uz', w: w);
        w = null;
      }
    }
  });

  testWidgets('B: Tahlillar ro‘yxati — qidiruv, guruhlar (uz)', (t) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await start(t);
    final pack = s.content.pack!;
    final w = Walk(t, 'qa_tests_uz');
    _log.writeln('== B: ro‘yxat ==');
    await _tab(t, l.navTests);
    _rec(t, 'tab Tahlillar', expect: '/tests');
    await w.snap('tahlillar');
    await t.enterText(find.byType(TextField).first, 'kaliy');
    await w.snap('qidiruv_kaliy');
    await t.enterText(find.byType(TextField).first, 'diabet');
    await w.snap('qidiruv_diabet');
    await t.tap(find.byTooltip(l.testsClearSearch));
    await t.pumpAndSettle();
    _rec(t, 'qidiruvni tozalash (X)');
    await t.enterText(find.byType(TextField).first, 'zzqq');
    await w.snap('bosh_natija');
    await w.tapText(l.testsClearSearch);
    _rec(t, 'bo‘sh holat: tozalash tugmasi');
    await w.snap('tozalandi');
    for (final g in pack.groups) {
      final chip = find.text(g.names.of('uz')).hitTestable();
      if (chip.evaluate().isEmpty) {
        await t.dragUntilVisible(
          find.text(g.names.of('uz')),
          find.byType(SingleChildScrollView).first,
          const Offset(-120, 0),
        );
        await t.pumpAndSettle();
      }
      await t.tap(find.text(g.names.of('uz')).first);
      await t.pumpAndSettle();
      _rec(t, 'guruh ${g.id}');
      final n = pack.analytes.where((a) => a.group == g.id).length;
      final shown = find.text(l.testsResultCount(n)).evaluate().isNotEmpty;
      if (!shown) _log.writeln('   !!! ${g.id}: son $n ko‘rsatilmadi');
    }
    await w.snap('oxirgi_guruh');
    // Kasalliklar kirish qatori → ro'yxat → holat → karta.
    await goTo(t, '/tests');
    await w.scroll(-3000);
    await t.tap(find.byType(ConditionsEntryRow));
    await t.pumpAndSettle();
    _rec(t, 'kasalliklar qatori', expect: '/tests/conditions');
    await w.snap('kasalliklar');
    await w.tapText('2-tip qandli diabet');
    _rec(t, 'holat diabet');
    await w.snap('diabet');
    await t.tap(find.text('HbA1c (glikirlangan gemoglobin)').first);
    await t.pumpAndSettle();
    _rec(t, 'diabet → HbA1c', expect: '/tests/conditions/');
    await w.snap('hba1c');
    await _back(t, l);
    await _back(t, l);
    await _back(t, l);
    _rec(t, 'orqaga ×3', expect: '/tests');
    // Lipid: LDL-C maqsad paneli.
    await goTo(t, '/tests/analyte/ldl-c');
    await _scrollTo(t, find.byKey(const ValueKey('treatment-goals-panel')));
    await w.snap('ldl_maqsad');
    // Tab qayta bosish: kartadan → ro'yxat ildizi.
    await _tab(t, l.navTests);
    _rec(t, 'Tahlillar tabini qayta bosish', expect: '/tests');
  });

  testWidgets('C: iflos holat — boshqa tablarda chuqur sahifa', (t) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await makeServices(t, bundle: LibraryTestBundle());
    await pumpApp(t, s);
    final w = Walk(t, 'qa_dirty_uz');
    _log.writeln('== C: iflos holat ==');
    // Tahlillar tabida Kaliy, Lab tabida QC, O'rganishda jadval ochiq.
    await goTo(t, '/tests');
    await goTo(t, '/tests/analyte/potassium');
    await goTo(t, '/lab');
    await goTo(t, '/lab/qc');
    await goTo(t, '/learn');
    await goTo(t, '/learn/reference');
    await goTo(t, '/library');
    await w.snap('kutubxona');
    // Saqlanganlar bo'sh → "Tahlillar".
    await w.tapText(lookupAppLocalizations(const Locale('uz')).featureSaved);
    _rec(t, 'Saqlanganlar', expect: '/library/saved');
    await w.snap('saqlangan_bosh');
    // Bo'sh holat tugmasi (pastki “Tahlillar” tabi emas).
    await w.tap(
      find.descendant(
        of: find.byType(LgStateView),
        matching: find.text(l.featureTests),
      ),
    );
    _rec(t, 'Saqlanganlar bo‘sh → Tahlillar', expect: '/tests');
    if (_loc(t) != '/tests') _log.writeln('   !!! oxirgi karta ochildi');
    await w.snap('saqlangan_tahlillar');
    // Tahlil kartasidan Lab/O'rganish havolalari (Lab'da QC ochiq).
    await goTo(t, '/tests/analyte/creatinine');
    final egfr = find.text(calcTitle(ClinicalCalc.egfr, l));
    await _scrollTo(t, egfr);
    await t.tap(egfr);
    await t.pumpAndSettle();
    _rec(
      t,
      'kreatinin → eGFR (Lab’da QC ochiq)',
      expect: '/lab/calculators/${calcRoute(ClinicalCalc.egfr)}',
    );
    await w.snap('egfr');
    await _tab(t, l.navTests);
    final cal = find.text(l.analyteMethodCalibration);
    await _scrollTo(t, cal);
    await t.tap(cal);
    await t.pumpAndSettle();
    _rec(
      t,
      'kreatinin → kalibrovka',
      expect: '/lab/calibration?analyte=creatinine',
    );
    await w.snap('kalibrovka');
    // Lab ichida kalkulyator ro'yxati ochiq bo'lsa ham.
    await goTo(t, '/lab/calculators');
    await goTo(t, '/tests');
    await goTo(t, '/tests/analyte/creatinine');
    await w.snap('kreatinin_qayta');
    await _scrollTo(t, egfr);
    await t.tap(egfr);
    await t.pumpAndSettle();
    _rec(
      t,
      'kreatinin → eGFR (Lab’da kalk. ro‘yxati)',
      expect: '/lab/calculators/${calcRoute(ClinicalCalc.egfr)}',
    );
    // Saqlangan karta Kutubxonada; Tahlillar tabi buzilmaydi.
    await s.bookmarks.toggle('glucose-plasma-fasting');
    await goTo(t, '/library/saved');
    await t.tap(find.byType(AnalyteRow).first);
    await t.pumpAndSettle();
    _rec(
      t,
      'saqlangan glyukoza',
      expect: '/library/saved/analyte/glucose-plasma-fasting',
    );
    await w.snap('saqlangan_karta');
    final rel = find.byType(AnalyteRow);
    await _scrollTo(t, rel);
    await t.tap(rel.first);
    await t.pumpAndSettle();
    _rec(t, 'saqlangan karta → bog‘liq', expect: '/library/saved/analyte/');
    await _back(t, l);
    await _back(t, l);
    _rec(t, 'orqaga ×2', expect: '/library/saved');
    await _tab(t, l.navLibrary);
    _rec(t, 'Kutubxona tabini qayta bosish', expect: '/library');
    // Manba havolasi: tashqi ilova yo'q → havola nusxalanadi.
    await goTo(t, '/tests');
    await goTo(t, '/tests/analyte/glucose-plasma-fasting');
    final src = find.textContaining('Blood Glucose Test');
    await _scrollTo(t, src);
    await t.tap(src.first);
    await t.runAsync(() => Future<void>.delayed(const Duration(seconds: 1)));
    await t.pumpAndSettle();
    _rec(t, 'manba MedlinePlus');
    if (find.text(l.linkCopied).evaluate().isEmpty) {
      _log.writeln('   !!! manba: nusxa toasti yo‘q');
    }
    await w.snap('manba');
  });

  testWidgets('D: Kutubxona — bo‘limlar (rollar)', (t) async {
    for (final role in AppRole.values) {
      final l = lookupAppLocalizations(const Locale('uz'));
      final s = await makeServices(t, role: role, bundle: LibraryTestBundle());
      await pumpApp(t, s);
      final w = Walk(t, 'qa_library_${role.name}');
      _log.writeln('== D: ${role.name} ==');
      await goTo(t, '/library');
      await w.snap('kutubxona');
      final rows = find.byType(LgRow).evaluate().toList();
      final titles = [for (final e in rows) (e.widget as LgRow).title];
      for (final title in titles) {
        await goTo(t, '/library');
        await _scrollTo(t, find.text(title));
        await t.tap(find.text(title).first);
        await t.pumpAndSettle();
        _rec(t, '${role.name}: $title');
        await w.snap('b_${titles.indexOf(title)}');
      }
      // Qidiruv kirish.
      await goTo(t, '/library');
      await _scrollTo(t, find.text(l.libSearchEntry), step: -250);
      await w.tap(find.text(l.libSearchEntry));
      _rec(
        t,
        '${role.name}: qidiruv kirish',
        expect: '/library/books?search=1',
      );
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    }
  });

  testWidgets('E: Kutubxona — material turlari va import', (t) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await makeServices(t, bundle: LibraryTestBundle());
    await pumpApp(t, s);
    final w = Walk(t, 'qa_library_items');
    _log.writeln('== E: materiallar ==');
    final pack = s.content.pack!;
    final seen = <String>{};
    for (final item in pack.library) {
      final kind =
          '${item.access.name}/${item.file != null}/'
          '${item.filePack != null}/${item.url != null}/${item.importState.name}';
      if (!seen.add(kind)) continue;
      await goTo(t, '/library/books');
      await goTo(t, '/library/books/item/${item.id}');
      _rec(t, 'material ${item.id} ($kind)');
      await w.snap('m_${seen.length}');
    }
    await goTo(t, '/library/intake');
    await w.snap('import');
    final support = find.byType(LgButton).hitTestable();
    if (support.evaluate().isNotEmpty) {
      await t.tap(support.last);
      await t.pumpAndSettle();
      _rec(t, 'import → yozish', expect: '/profile/support/new');
      await w.snap('import_yozish');
      await _back(t, l);
      _rec(t, 'orqaga', expect: '/library/intake');
    }
    await goTo(t, '/library/packs');
    await w.snap('paketlar');
    await goTo(t, '/library/books/item/yoq-material');
    await w.snap('topilmadi');
    await w.tapText(l.libBackToCatalog);
    _rec(t, 'topilmadi → katalogga', expect: '/library/books');
  });

  testWidgets('F: ru / en qisqa', (t) async {
    for (final lang in [AppLanguage.ru, AppLanguage.en]) {
      final l = lookupAppLocalizations(lang.locale);
      final s = await makeServices(
        t,
        language: lang,
        bundle: LibraryTestBundle(),
      );
      await pumpApp(t, s);
      final w = Walk(t, 'qa_${lang.name}');
      _log.writeln('== F: ${lang.name} ==');
      await goTo(t, '/tests');
      await w.snap('tahlillar');
      await goTo(t, '/tests/analyte/ldl-c');
      await w.snap('ldl');
      await _scrollTo(t, find.byKey(const ValueKey('treatment-goals-panel')));
      await w.snap('ldl_maqsad');
      await goTo(t, '/library');
      await w.snap('kutubxona');
      await goTo(t, '/library/saved');
      await w.snap('saqlangan');
      await goTo(t, '/library/books');
      await w.snap('katalog');
      _rec(t, '${lang.name} ok ${l.navTests}');
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    }
  });
}
