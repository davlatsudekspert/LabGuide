// O'rganish sahifasining yig'ilgan sarlavhasi tor ekranda ham qirqilmasin
// (QA 2026-10-10: ru/en da "…" bilan kesilardi).
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('${lang.name}: collapsed Learn title fits at 360 px', (
      tester,
    ) async {
      final s = await makeServices(tester, language: lang);
      await pumpApp(tester, s, size: const Size(360, 780));
      await goTo(tester, '/learn');
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      final l = lookupAppLocalizations(Locale(lang.name));
      final titles = find.text(l.learnTitle);
      expect(titles, findsWidgets);
      for (final e in titles.evaluate()) {
        final p = e.renderObject! as RenderParagraph;
        expect(p.didExceedMaxLines, isFalse, reason: l.learnTitle);
      }
    });
  }
}
