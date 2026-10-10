// O'rganishdagi "Leykoformula" / "Mikroskopiya atlasi" qatorlari va Bosh
// sahifadagi toifa tugmasi yorliqdagi bo'limning o'zini ochadi — boshqa tabda
// o'sha bo'lim ichida oxirgi ochiq qolgan sahifani (hujayra kartasi, rasm,
// mashq) emas.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/shell.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations_uz.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = AppLocalizationsUz();

String _loc(WidgetTester tester) => routerOf(tester).state.matchedLocation;

Future<void> _tab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).hitTestable().last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  test('branchUnder(exact): faqat aynan shu sahifa', () {
    final m = TabMemory()
      ..record(2, Uri.parse('/lab/differential/cells/neutrophil_band'))
      ..record(4, Uri.parse('/learn/toifa'));
    expect(m.branchUnder('/lab/differential'), 2);
    expect(m.branchUnder('/lab/differential', exact: true), isNull);
    expect(m.branchUnder('/learn/toifa', exact: true), 4);
  });

  for (final (deep, row, target) in [
    (
      '/lab/differential/cells/neutrophil_band',
      uz.diffTitle,
      '/lab/differential',
    ),
    ('/lab/differential/history', uz.diffTitle, '/lab/differential'),
    ('/lab/microscopy/i/u-rbc-1', uz.micTitle, '/lab/microscopy'),
  ]) {
    testWidgets('O‘rganish «$row»: Lab tabida $deep ochiq bo‘lsa ham', (
      tester,
    ) async {
      final s = await makeServices(
        tester,
        language: AppLanguage.uz,
        role: AppRole.student,
      );
      await pumpApp(tester, s);
      await goTo(tester, deep);
      expect(_loc(tester), deep);
      await _tab(tester, uz.navLearn);
      await tapScroll(tester, row);
      expect(_loc(tester), target);
    });
  }

  testWidgets('O‘rganish «Leykoformula»: Lab aynan bo‘limda — stek saqlanadi', (
    tester,
  ) async {
    final s = await makeServices(
      tester,
      language: AppLanguage.uz,
      role: AppRole.student,
    );
    await pumpApp(tester, s);
    // Haqiqiy yo'l: Lab → Leykoformula (push), so'ng O'rganish.
    await _tab(tester, uz.navLab);
    await tapScroll(tester, uz.diffTitle);
    expect(_loc(tester), '/lab/differential');
    await _tab(tester, uz.navLearn);
    await tapScroll(tester, uz.diffTitle);
    expect(_loc(tester), '/lab/differential');
    await tester.tap(find.byTooltip(uz.actionBack));
    await tester.pumpAndSettle();
    expect(_loc(tester), '/lab');
  });

  testWidgets('Bosh sahifa toifa tugmasi: O‘rganishda mashq ochiq bo‘lsa ham '
      'toifa bo‘limi', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('uz', 'UZ')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final s = await makeServices(tester, language: AppLanguage.uz);
    await pumpApp(tester, s);
    await goTo(tester, '/learn/toifa/practice/anemias');
    await _tab(tester, uz.navHome);
    await tapScroll(tester, uz.toifaOpen);
    expect(_loc(tester), '/learn/toifa');
  });
}
