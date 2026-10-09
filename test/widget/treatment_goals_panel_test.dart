// LDL-C kartasi: "Davolash maqsadi" alohida panelda, har yo'riqnoma o'z
// jadvalida; RI/DL panellari bilan aralashmaydi. Kelib chiqish panelida agent
// tekshiruvi va mutaxassis tasdig'i alohida qatorlar.
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/ui/analyte_screen.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

final en = lookupAppLocalizations(const Locale('en'));
final uz = lookupAppLocalizations(const Locale('uz'));
final ru = lookupAppLocalizations(const Locale('ru'));

const panelKey = ValueKey('treatment-goals-panel');
const guidelines = [
  'ncep-atp3-2001',
  'ncep-atp3-2004',
  'esc-eas-2019',
  'acc-aha-2018',
];

Finder inPanel(Finder f) =>
    find.descendant(of: find.byKey(panelKey), matching: f);

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'LDL-C: separate treatment-goals panel, one table per guideline',
    (tester) async {
      final s = await makeServices(tester, language: AppLanguage.en);
      await pumpApp(tester, s, size: const Size(390, 12000));
      await goTo(tester, '/tests/analyte/ldl-c');

      expect(find.byKey(panelKey), findsOneWidget);
      expect(inPanel(find.text(en.analyteTreatmentGoals)), findsOneWidget);
      expect(
        inPanel(find.text(en.analyteTreatmentGoalsNotice)),
        findsOneWidget,
      );
      expect(
        inPanel(find.text(en.analyteTreatmentGoalsNotRef)),
        findsOneWidget,
      );
      for (final id in guidelines) {
        expect(
          inPanel(find.byKey(ValueKey('treatment-goals-$id'))),
          findsOneWidget,
        );
      }
      expect(
        find.text(en.analyteGoalGuideline('ESC/EAS', '2019')),
        findsOneWidget,
      );
      expect(
        find.text(en.analyteGoalGuideline('NCEP ATP III (NHLBI)', '2001')),
        findsOneWidget,
      );
      // ESC qiymati faqat o'z jadvalida, ATP III jadvalida emas.
      Finder inTable(String id, Finder f) => find.descendant(
        of: find.byKey(ValueKey('treatment-goals-$id')),
        matching: f,
      );
      expect(
        inTable(
          'esc-eas-2019',
          find.textContaining(keepValuesTogether('< 55 mg/dL')),
        ),
        findsOneWidget,
      );
      expect(
        inTable(
          'ncep-atp3-2001',
          find.textContaining(keepValuesTogether('< 55 mg/dL')),
        ),
        findsNothing,
      );
      expect(
        inTable(
          'ncep-atp3-2001',
          find.textContaining(keepValuesTogether('< 100 mg/dL')),
        ),
        findsOneWidget,
      );

      // RI paneli o'zgarmagan va maqsadlar paneli ichida emas; DL yo'q.
      expect(find.text(en.analyteRefIntervalNone), findsOneWidget);
      expect(inPanel(find.text(en.analyteRefIntervalNone)), findsNothing);
      expect(inPanel(find.text(en.analyteRefIntervals)), findsNothing);
      expect(find.text(en.analyteDecisionLimits), findsNothing);

      // Kelib chiqishi: agent tekshiruvi ≠ mutaxassis tasdig'i.
      expect(find.text(en.analyteAgentCheck), findsOneWidget);
      expect(
        find.text(en.analyteAgentCheckValue('2026-10-09')),
        findsOneWidget,
      );
      expect(find.text(en.analyteExpertApproval), findsOneWidget);
      expect(find.text(en.analyteExpertApprovalPending), findsOneWidget);
      expect(find.text(en.analyteReviewApproved), findsNothing);
    },
  );

  test('keepValuesTogether only swaps spaces for non-breaking ones', () {
    const raw = '≥ 50% reduction and < 1.4 mmol/L (< 55 mg/dL)';
    final kept = keepValuesTogether(raw);
    expect(kept.replaceAll('\u00A0', ' ').replaceAll('\u2060', ''), raw);
    expect(kept, contains('<\u00A01.4\u00A0mmol/\u2060L'));
    expect(kept, contains('<\u00A055\u00A0mg/\u2060dL'));
  });

  testWidgets('cards without goals show no treatment-goals panel', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 8000));
    for (final id in ['hdl-c', 'triglycerides', 'glucose-plasma-fasting']) {
      await goTo(tester, '/tests/analyte/$id');
      expect(find.byKey(panelKey), findsNothing, reason: id);
      expect(find.text(en.analyteTreatmentGoals), findsNothing, reason: id);
    }
  });

  for (final (lang, l, theme) in [
    (AppLanguage.uz, uz, ThemeMode.light),
    (AppLanguage.ru, ru, ThemeMode.dark),
  ]) {
    testWidgets('320 px, text ×2 (${lang.name}): goals panel fits', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = previous);
      final s = await makeServices(tester, language: lang, themeMode: theme);
      await pumpApp(tester, s, size: const Size(320, 30000), textScale: 2);
      await goTo(tester, '/tests/analyte/ldl-c');
      FlutterError.onError = previous;
      expect(errors, isEmpty, reason: errors.map((e) => e.summary).join('\n'));
      expect(tester.takeException(), isNull);
      final panel = tester.getRect(find.byKey(panelKey));
      expect(panel.width, lessThanOrEqualTo(320));
      expect(panel.left, greaterThanOrEqualTo(0));
      expect(panel.right, lessThanOrEqualTo(320));
      for (final id in guidelines) {
        final table = tester.getRect(
          find.byKey(ValueKey('treatment-goals-$id')),
        );
        expect(table.right, lessThanOrEqualTo(panel.right), reason: id);
      }
      expect(find.text(l.analyteTreatmentGoals), findsOneWidget);
      expect(find.text(l.analyteTreatmentGoalsNotice), findsOneWidget);
      final scrollable = find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .hitTestable()
          .first;
      final agent = find.text(l.analyteAgentCheckValue('2026-10-09'));
      await tester.scrollUntilVisible(agent, 600, scrollable: scrollable);
      expect(agent, findsOneWidget);
      expect(find.text(l.analyteExpertApprovalPending), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
