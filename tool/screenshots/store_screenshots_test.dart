// App Store / Google Play uchun ekran rasmlari: 6.9" iPhone (1290×2796),
// uch tilda (uz 8 ta, ru/en 7 tadan; toifa faqat uz). CI testlariga kirmaydi.
//
//   flutter test tool/screenshots/store_screenshots_test.dart --update-goldens
//
// Natija: tool/screenshots/out/store/<til>/NN_nom.png (gitignore qilingan).
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/auth/ui/welcome_screen.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/qc/qc_model.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:labguide/l10n/gen/app_localizations_en.dart';
import 'package:labguide/l10n/gen/app_localizations_ru.dart';
import 'package:labguide/l10n/gen/app_localizations_uz.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import '../../test/helpers/learn_helpers.dart';

/// 430×932 pt × 3 = 1290×2796 px (App Store 6.9" o'lchamlaridan biri).
const _size = Size(430, 932);

typedef StoreShot = ({
  String name,
  String route,
  Future<void> Function(WidgetTester t, AppLocalizations l, AppServices s)? act,
});

Future<void> _tap(WidgetTester t, String text) async {
  final f = find.text(text);
  await t.ensureVisible(f.first);
  await t.pumpAndSettle();
  await t.tap(f.hitTestable().first);
  await t.pumpAndSettle();
}

/// Element ekranning berilgan nisbiy joyiga (0 — tepa, 1 — past) suriladi.
Future<void> _align(WidgetTester t, Finder f, double alignment) async {
  await Scrollable.ensureVisible(t.element(f), alignment: alignment);
  await t.pumpAndSettle();
}

/// Leykoformula hisoblagichida 100 ta hujayra sanash (tez bosish).
Future<void> _countDifferential(WidgetTester t, AppLocalizations l) async {
  final plan = {
    DiffCell.segmented: 58,
    DiffCell.band: 3,
    DiffCell.lymphocyte: 28,
    DiffCell.monocyte: 7,
    DiffCell.eosinophil: 3,
    DiffCell.basophil: 1,
  };
  final list = find
      .byWidgetPredicate(
        (x) => x is Scrollable && x.axisDirection == AxisDirection.down,
      )
      .hitTestable()
      .first;
  for (final MapEntry(key: c, value: n) in plan.entries) {
    final b = find.byKey(ValueKey('diff-count-${c.name}'));
    if (b.hitTestable().evaluate().isEmpty) {
      await t.scrollUntilVisible(b, 250, scrollable: list);
    }
    await t.ensureVisible(b);
    await t.pumpAndSettle();
    for (var i = 0; i < n; i++) {
      await t.tap(b);
      await t.pump(const Duration(milliseconds: 20));
    }
  }
  await t.pumpAndSettle();
  await enterField(t, l.diffWbcLabel, '7,5');
  // “100 ta hujayra sanaldi” xabari yo'qolsin.
  await t.pump(const Duration(seconds: 6));
  await t.pumpAndSettle();
  await _align(t, find.text(l.diffWbcLabel).first, 0.02);
}

final _shots = <StoreShot>[
  (name: '01_home', route: '/home', act: null),
  (
    name: '02_analyte_glucose',
    route: '/tests/analyte/glucose-plasma-fasting',
    act: (t, l, s) async {
      final list = find.descendant(
        of: find.byType(ListView).last,
        matching: find.byType(Scrollable),
      );
      await t.scrollUntilVisible(
        find.text(l.analyteDecisionLimits),
        300,
        scrollable: list.first,
      );
      await t.scrollUntilVisible(
        find.text(l.analyteSources),
        300,
        scrollable: list.first,
      );
      await _align(t, find.text(l.analyteSources), 0.30);
    },
  ),
  (
    name: '03_leukoformula',
    route: '/lab/differential/count',
    act: (t, l, s) async {
      await t.runAsync(() async {
        final ctx = t.element(find.byType(Scaffold).first);
        for (final id in [...cellGuides.map((c) => c.id), 'hero']) {
          await precacheImage(AssetImage(cellImage(id)), ctx);
        }
      });
      await t.pumpAndSettle();
      await _countDifferential(t, l);
    },
  ),
  (
    name: '04_daily_result',
    route: '/learn/daily',
    act: (t, l, s) async {
      if (find.text(l.dailyStart).evaluate().isNotEmpty) {
        await tapScroll(t, l.dailyStart);
      }
      for (var i = 0; i < 5; i++) {
        await tapScroll(t, i.isEven ? 'A' : 'B');
        await tapScroll(t, i == 4 ? l.dailyShowResult : l.quizNext);
      }
    },
  ),
  (name: '05_reference', route: '/learn/reference', act: null),
  (
    name: '06_egfr',
    route: '/lab/calculators/egfr',
    act: (t, l, s) async {
      final f = find.byType(TextField);
      await t.enterText(f.at(0), '97');
      await t.enterText(f.at(1), '54');
      await _tap(t, l.sexFemale);
      await _tap(t, l.dilCalculate);
      await _align(t, find.textContaining('mL/min/1.73 m²').first, 0.85);
    },
  ),
  (
    name: '07_qc',
    route: '/lab/qc',
    act: (t, l, s) async {
      final set = await t.runAsync(
        () => s.qc.addSet(
          name: switch (l.localeName) {
            'ru' => 'Глюкоза',
            'en' => 'Glucose',
            _ => 'Glyukoza',
          },
          unit: 'mmol/L',
          targetSource: QcTargetSource.laboratory,
          levels: [
            (label: '1', lot: 'GL-2611', mean: 5.5, sd: 0.15),
            (label: '2', lot: 'GH-2611', mean: 16.0, sd: 0.45),
          ],
        ),
      );
      final values = [
        (5.52, 15.9),
        (5.41, 16.3),
        (5.60, 15.7),
        (5.47, 16.1),
        (5.58, 16.5),
        (5.66, 16.2),
        (5.39, 15.8),
        (5.83, 16.6),
        (5.87, 16.95),
      ];
      for (final (i, (a, b)) in values.indexed) {
        await t.runAsync(
          () => s.qc.addRun(set!.id, {
            'L1': a,
            'L2': b,
          }, at: DateTime(2026, 10, 1 + i, 8, 30)),
        );
      }
      await goTo(t, '/lab/qc/set/${set!.id}');
      await _align(t, find.text(l.qcLatestRun), 0.0);
      await t.drag(find.byType(Scrollable).hitTestable().first, const Offset(0, -270));
      await t.pumpAndSettle();
    },
  ),
  (name: '08_toifa', route: '/learn/toifa', act: null),
];

void main() {
  setUpAll(loadAppFonts);

  for (final (lang, l) in <(AppLanguage, AppLocalizations)>[
    (AppLanguage.uz, AppLocalizationsUz()),
    (AppLanguage.ru, AppLocalizationsRu()),
    (AppLanguage.en, AppLocalizationsEn()),
  ]) {
    for (final shot in _shots) {
      // Toifa tayyorgarligi faqat O'zbekiston (uz) uchun.
      if (shot.name == '08_toifa' && lang != AppLanguage.uz) continue;
      testWidgets('${lang.name} ${shot.name}', (tester) async {
        final s = await makeServices(tester, language: lang);
        await pumpApp(tester, s, size: _size);
        if (shot.route != '/home') await goTo(tester, shot.route);
        await tester.runAsync(() async {
          final ctx = tester.element(find.byType(Scaffold).first);
          await precacheImage(kHeroImage, ctx);
        });
        await tester.pumpAndSettle();
        if (shot.act != null) await shot.act!(tester, l, s);
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(LabGuideApp),
          matchesGoldenFile('out/store/${lang.name}/${shot.name}.png'),
        );
      });
    }
  }
}
