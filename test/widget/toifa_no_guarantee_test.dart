// Toifa tayyorgarligi: "imtihonda aynan shu savollar tushishiga kafolat yo'q"
// yozuvi — bo'lim bosh sahifasida va testni boshlash ekranida (uz/ru/en).
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

const _tall = Size(390, 2400);

void main() {
  setUpAll(loadAppFonts);

  test('yozuv uch tilda bor va kafolat bermasligini aytadi', () {
    final uz = lookupAppLocalizations(const Locale('uz')).toifaNoGuaranteeNote;
    final ru = lookupAppLocalizations(const Locale('ru')).toifaNoGuaranteeNote;
    final en = lookupAppLocalizations(const Locale('en')).toifaNoGuaranteeNote;
    expect(uz, contains('kafolat'));
    expect(ru, contains('Гарантии'));
    expect(en, contains('no guarantee'));
    expect({uz, ru, en}.length, 3);
  });

  testWidgets('bo‘lim bosh sahifasi va test boshlash ekranida ko‘rinadi', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/toifa');
    expect(find.text(l.toifaNoGuaranteeNote), findsOneWidget);
    await goTo(tester, '/learn/toifa/test');
    expect(find.text(l.toifaNoGuaranteeNote), findsOneWidget);
    expect(find.byKey(const ValueKey('toifa-no-guarantee')), findsOneWidget);
  });
}
