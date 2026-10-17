import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/home/global_search.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<void> type(WidgetTester tester, String q) async {
    await tester.enterText(find.byType(TextField).first, q);
    await tester.pumpAndSettle();
  }

  testWidgets('bosh sahifa qidiruvi: lotin, kirill, ruscha va apparat', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2400));
    final l = lookupAppLocalizations(const Locale('uz'));
    await goTo(tester, '/home');
    await tester.tap(find.byType(HomeSearchField));
    await tester.pumpAndSettle();
    expect(find.byType(GlobalSearchScreen), findsOne);
    expect(find.text(l.searchPrompt), findsOne);

    await type(tester, 'kreatinin');
    expect(find.textContaining(l.featureTests), findsWidgets);
    // O'zbek kirill va ruscha so'rov ham shu tahlilni topadi.
    await type(tester, 'креатинин');
    expect(find.textContaining(l.featureTests), findsWidgets);
    await type(tester, 'Mindray');
    expect(find.textContaining(l.labInstruments), findsWidgets);
    await type(tester, 'zzzqqq');
    expect(find.text(l.testsEmptyTitle), findsOne);
    expect(tester.takeException(), isNull);
  });

  for (final role in AppRole.values) {
    testWidgets('bosh sahifa ${role.name}: qidiruv va tezkor tugmalar '
        'birinchi ekranda', (tester) async {
      final s = await makeServices(tester);
      await s.settings.setRole(role);
      await pumpApp(tester, s, size: const Size(390, 844));
      await goTo(tester, '/home');
      expect(find.byType(HomeSearchField).hitTestable(), findsOne);
      expect(tester.takeException(), isNull);
    });
  }
}
