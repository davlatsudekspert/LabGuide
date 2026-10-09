import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import 'layout_matrix.dart';

/// Kitob bilimlari qo'shilgan ekranlar (jadvallar, kartalar, leykoformula
/// texnikasi va oraliqlari) — barcha til/kenglik/shrift/mavzu
/// konfiguratsiyalarida layout xatosiz. To'liq matritsa og'ir bo'lgani
/// uchun faqat shu ekranlar alohida tekshiriladi.
const booksRoutes = [
  '/learn',
  '/learn/reference',
  '/learn/reference/anemia',
  '/learn/reference/spurious-cbc',
  '/learn/reference/jaundice',
  '/learn/reference/liver-syndromes',
  '/learn/reference/stool-parasites',
  '/learn/reference/obsolete-methods',
  '/learn/reference/missing',
  '/tests/analyte/reticulocytes',
  '/tests/analyte/mchc',
  '/tests/analyte/bilirubin-total',
  '/tests/analyte/stool-ova-parasites',
  '/tests/conditions/anemia-workup',
  '/tests/conditions/hemolytic-anemia',
  '/tests/conditions/jaundice-cholestasis',
  '/lab/differential/interpret',
  '/lab/differential/technique',
];

void main() {
  setUpAll(loadAppFonts);

  for (final c in configs()) {
    final name =
        '${c.lang.name} ${c.width.toInt()}px ×${c.textScale} ${c.theme.name}';
    testWidgets('books screens without layout errors: $name', (tester) async {
      final s = await makeServices(
        tester,
        language: c.lang,
        themeMode: c.theme,
      );
      await pumpApp(
        tester,
        s,
        size: Size(c.width, 3200),
        textScale: c.textScale,
      );
      for (final route in booksRoutes) {
        await goTo(tester, route);
        final error = tester.takeException();
        expect(error, isNull, reason: '$route → $error');
      }
    });
  }
}
