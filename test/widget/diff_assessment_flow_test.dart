import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:labguide/features/differential/diff_assessment.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/differential/diff_assessment_screens.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('baho: past/yuqori belgisi, Talqin topilmasi (${lang.name})', (
      tester,
    ) async {
      final s = await makeServices(tester, language: lang);
      final l = lookupAppLocalizations(Locale(lang.name));
      // 20 neytrofil, 80 limfotsit, WBC 10 → neytrofil 2,0 (me'yor),
      // limfotsit 8,0 (yuqori) — limfotsitoz.
      for (var i = 0; i < 20; i++) {
        s.differential.tap(DiffCell.segmented);
      }
      for (var i = 0; i < 80; i++) {
        s.differential.tap(DiffCell.lymphocyte);
      }
      s.differential.setWbc(10);
      await pumpApp(tester, s, size: const Size(390, 4000));
      await goTo(tester, '/lab/differential/count');
      expect(find.byType(DiffAssessmentPanel), findsOne);
      expect(find.text(l.diffAssessTitle), findsOne);
      expect(find.text(l.diffFlagHigh), findsOne);
      final lympho = diffFindings.firstWhere((f) => f.id == 'lymphocytosis');
      expect(
        find.text(l.diffAssessMaySuggest(findingLabel(lympho, lang.name))),
        findsOne,
      );
      expect(
        find.byKey(const ValueKey('diff-assess-all-normal')),
        findsNothing,
      );
      expect(find.text(l.diffAssessReferBody), findsNothing);
      expect(tester.takeException(), isNull);

      // Blanka me'yorlari sahifasi.
      await tester.ensureVisible(find.text(l.diffLimitsTitle));
      await tester.tap(find.text(l.diffLimitsTitle));
      await tester.pumpAndSettle();
      expect(find.byType(DiffLimitsScreen), findsOne);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tugallanmagan sanash: baho yo‘q, izoh bor (audit #3)', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.ru);
    final l = lookupAppLocalizations(const Locale('ru'));
    // Bitta tayoqcha bosildi — ilgari "Повышено / сдвиг влево" chiqardi.
    s.differential.tap(DiffCell.band);
    s.differential.setWbc(6);
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '/lab/differential/count');
    expect(find.text(l.diffAssessIncomplete(1, 100)), findsOne);
    expect(find.text(l.diffFlagHigh), findsNothing);
    expect(find.text(l.diffFlagLow), findsNothing);
    expect(find.byKey(const ValueKey('diff-assess-all-normal')), findsNothing);
    expect(find.byKey(const ValueKey('diff-assess-refer')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('blast bilan: yo‘llash bor, “hammasi me’yorda” yo‘q (audit #4)', (
    tester,
  ) async {
    final s = await makeServices(tester);
    const counts = {
      DiffCell.segmented: 58,
      DiffCell.band: 2,
      DiffCell.lymphocyte: 30,
      DiffCell.monocyte: 5,
      DiffCell.eosinophil: 3,
      DiffCell.basophil: 1,
      DiffCell.other: 1,
    };
    for (final e in counts.entries) {
      for (var i = 0; i < e.value; i++) {
        s.differential.tap(e.key);
      }
    }
    s.differential.setWbc(6);
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '/lab/differential/count');
    expect(find.byKey(const ValueKey('diff-assess-refer')), findsOne);
    expect(find.byKey(const ValueKey('diff-assess-all-normal')), findsNothing);
    expect(find.byKey(const ValueKey('diff-assess-incomplete')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('rus tilida topilma bosh kelishikda, kichik harf bilan (audit #15)', () {
    final ru = lookupAppLocalizations(const Locale('ru'));
    final neutropenia = diffFindings.firstWhere((f) => f.id == 'neutropenia');
    expect(
      ru.diffAssessMaySuggest(findingLabel(neutropenia, 'ru')),
      'Возможная трактовка: нейтропения',
    );
    expect(findingLabel(neutropenia, 'en'), 'Neutropenia');
  });

  testWidgets('me’yorni o‘zgartirish bahoni o‘zgartiradi, qaytarish', (
    tester,
  ) async {
    final s = await makeServices(tester);
    final l = lookupAppLocalizations(const Locale('uz'));
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '/lab/differential/limits');
    final fields = find.byType(TextField);
    // 2-indeks — limfotsitlar pastki chegarasi (neytrofillar 2 ta maydon).
    await tester.enterText(fields.at(2), '9');
    await tester.pumpAndSettle();
    expect(find.text(l.diffLimitsInvalid), findsOne);
    expect(
      s.differential.limits[DiffMeasure.lymphocytes],
      diffDefaultLimits[DiffMeasure.lymphocytes],
    );
    await tester.enterText(fields.at(2), '');
    await tester.pumpAndSettle();
    expect(s.differential.limits[DiffMeasure.lymphocytes]!.low, isNull);
    await tester.ensureVisible(find.text(l.diffLimitsReset));
    await tester.tap(find.text(l.diffLimitsReset));
    await tester.pumpAndSettle();
    expect(s.differential.limits, diffDefaultLimits);
    expect(tester.takeException(), isNull);
  });

  // ---- Talqin: har bir topilma o'z kartasiga olib boradi (?finding=<id>)
  Finder card(String id) => find.byKey(ValueKey('diff-finding-$id'));

  /// Qurilgan (ro'yxat dangasa) topilma kartalaridan ajratilganlar.
  List<String> outlinedIds(WidgetTester t) => [
    for (final w in t.widgetList<LgPanel>(find.byType(LgPanel)))
      if (w.outlined && w.key is ValueKey<String>)
        (w.key! as ValueKey<String>).value.replaceFirst('diff-finding-', ''),
  ];

  /// Kartaning boshi ko'rinadigan oynada: yuqorida va pastki menyudan
  /// yetarlicha yuqori (qatlam ostida ham, ekran tagida ham emas).
  void expectOnScreen(WidgetTester t, String id) {
    final r = t.getRect(card(id));
    final nav = t.getRect(find.byKey(const ValueKey('nav-pill')));
    expect(r.top, greaterThan(0), reason: '$id top');
    expect(r.top, lessThan(nav.top - 40), reason: '$id is not below the fold');
  }

  /// Dangasa ro'yxatda [f] qurilguncha suradi va ekranning o'rtasiga
  /// keltiradi (pastki menyu bosishga xalaqit bermasin).
  Future<void> reveal(WidgetTester t, Finder f) async {
    await t.scrollUntilVisible(
      f,
      300,
      scrollable: find
          .descendant(
            of: find.byType(LgPage).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await Scrollable.ensureVisible(t.element(f), alignment: 0.4);
    await t.pumpAndSettle();
  }

  /// Eng yuqori (ko'rinib turgan) sahifaning manzili.
  Uri topUri(WidgetTester t) =>
      GoRouterState.of(t.element(find.byType(LgPage).last)).uri;

  Future<void> seedLymphocytosis(AppServices s) async {
    for (var i = 0; i < 20; i++) {
      s.differential.tap(DiffCell.segmented);
    }
    for (var i = 0; i < 80; i++) {
      s.differential.tap(DiffCell.lymphocyte);
    }
    s.differential.setWbc(10);
  }

  testWidgets("baho kartasi o'z topilmasiga olib boradi va uni ajratadi", (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.uz);
    final l = lookupAppLocalizations(const Locale('uz'));
    await seedLymphocytosis(s);
    await pumpApp(tester, s, size: const Size(390, 844));
    await goTo(tester, '/lab/differential/count');
    final link = find.byKey(const ValueKey('diff-finding-link-lymphocytosis'));
    await reveal(tester, link);
    // Umumiy "Talqin" tugmasi ham joyida.
    expect(find.text(l.diffInterpretTitle), findsOne);
    await tester.tap(link);
    await tester.pumpAndSettle();
    final uri = topUri(tester);
    expect(uri.path, '/lab/differential/interpret');
    expect(uri.queryParameters['finding'], 'lymphocytosis');
    expect(outlinedIds(tester), ['lymphocytosis']);
    expectOnScreen(tester, 'lymphocytosis');
    expect(tester.takeException(), isNull);
  });

  testWidgets('umumiy Talqin tugmasi: hech narsa ajratilmaydi', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.uz);
    final l = lookupAppLocalizations(const Locale('uz'));
    await seedLymphocytosis(s);
    await pumpApp(tester, s, size: const Size(390, 844));
    await goTo(tester, '/lab/differential/count');
    final generic = find.text(l.diffInterpretTitle);
    await reveal(tester, generic);
    await tester.tap(generic);
    await tester.pumpAndSettle();
    final uri = topUri(tester);
    expect(uri.path, '/lab/differential/interpret');
    expect(uri.hasQuery, isFalse);
    expect(outlinedIds(tester), isEmpty);
  });

  for (final f in diffFindings) {
    testWidgets("?finding=${f.id}: o'sha karta ko'rinadi va ajratiladi", (
      tester,
    ) async {
      final s = await makeServices(tester);
      await pumpApp(tester, s, size: const Size(390, 844));
      await goTo(tester, '/lab/differential/interpret?finding=${f.id}');
      expect(outlinedIds(tester), [f.id]);
      expectOnScreen(tester, f.id);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets("noma'lum ?finding= e'tiborga olinmaydi", (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 844));
    await goTo(tester, '/lab/differential/interpret?finding=nope');
    expect(outlinedIds(tester), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ruscha interfeys: havola va orqaga qaytish', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.ru);
    final l = lookupAppLocalizations(const Locale('ru'));
    await seedLymphocytosis(s);
    await pumpApp(tester, s, size: const Size(390, 844));
    await goTo(tester, '/lab/differential/count');
    final link = find.byKey(const ValueKey('diff-finding-link-lymphocytosis'));
    await reveal(tester, link);
    expect(
      find.descendant(of: link, matching: find.text(l.diffAssessAboutFinding)),
      findsOne,
    );
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(outlinedIds(tester), ['lymphocytosis']);
    routerOf(tester).pop();
    await tester.pumpAndSettle();
    expect(find.byType(DiffAssessmentPanel), findsOne);
  });
}
