// 22 yo‘nalishli katalog: barcha ommaviy kartalar 320 px / 1.3 shriftda
// overflow'siz; platforma kartasida “sinf” qatori (models bo‘sh); caveat qatori;
// har bir NEEDS_SOURCE stub chuqur havolada ham ko‘rinmaydi (uz/ru/en).
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/instruments/lab_direction_card.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets(
      'yo‘nalishlar ro‘yxati va barcha kartalar: 320px ×1.3 (${lang.name})',
      (tester) async {
        final s = await makeServices(tester, language: lang);
        await tester.runAsync(s.instruments.ensureCatalog);
        await pumpApp(tester, s, size: const Size(320, 6000), textScale: 1.3);
        final catalog = s.instruments.catalog!;
        final dirs = catalog.publicLabDirections;
        expect(dirs.length, greaterThanOrEqualTo(14));
        final l = lookupAppLocalizations(lang.locale);

        await goTo(tester, '/lab/instruments');
        expect(tester.takeException(), isNull, reason: 'instruments list');
        expect(find.text(l.labDirSection), findsWidgets);

        for (final d in dirs) {
          await goTo(tester, '/lab/instruments/d/${d.name}');
          expect(tester.takeException(), isNull, reason: 'direction ${d.name}');
        }
        for (final c in catalog.publicLabCards) {
          await goTo(tester, '/lab/instruments/lc/${c.id}');
          expect(tester.takeException(), isNull, reason: c.id);
          final texts = tester
              .widgetList<Text>(find.byType(Text))
              .map((w) => w.data ?? w.textSpan?.toPlainText() ?? '')
              .join('\n');
          // models bo‘sh platforma: “sinf/texnologiya” qatori (har til).
          final needsClass = c.kind == LabCardKind.platform && c.models.isEmpty;
          expect(
            texts.contains(l.labDirPlatformClassNote),
            needsClass,
            reason: '${c.id} class note',
          );
          // Caveat: ma'lumotdan boshqariladi, tilga mos.
          if (c.sourceCaveat != null) {
            expect(
              texts.contains(c.sourceCaveat!.of(lang.name)),
              isTrue,
              reason: '${c.id} caveat ${lang.name}',
            );
          }
          expect(texts.contains('NEEDS_'), isFalse, reason: c.id);
        }
      },
    );

    testWidgets(
      'har bir stub: chuqur havola va yo‘nalish ekranida yo‘q (${lang.name})',
      (tester) async {
        final s = await makeServices(tester, language: lang);
        await tester.runAsync(s.instruments.ensureCatalog);
        await pumpApp(tester, s);
        final catalog = s.instruments.catalog!;
        final l = lookupAppLocalizations(lang.locale);
        final stubs = catalog.labCards.where((c) => !c.isPublic).toList();
        expect(stubs.length, 19);
        for (final st in stubs) {
          await goTo(tester, '/lab/instruments/lc/${st.id}');
          expect(
            find.text(l.instNoResultsTitle),
            findsOneWidget,
            reason: st.id,
          );
          expect(find.text(st.name.of(lang.name)), findsNothing, reason: st.id);
          await goTo(tester, '/lab/instruments/d/${st.direction.name}');
          expect(find.text(st.name.of(lang.name)), findsNothing, reason: st.id);
        }
      },
    );
  }
}
