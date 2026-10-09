import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/library/library_screens.dart';
import 'package:labguide/features/packs/packs_controller.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations_en.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

final en = AppLocalizationsEn();

/// Real fayl yozish soxta vaqtda tugamaydi — shart bajarilguncha haqiqiy
/// vaqtda kutadi.
Future<void> waitFor(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 100 && !done(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  expect(done(), isTrue);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('core pack first; the test pack downloads, installs, removes', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 2200));
    await goTo(tester, '/library/packs');

    // Ilova ichidagi paket: haqiqiy versiya, hajm, tillar, internetsiz.
    final m = s.content.manifest!;
    expect(find.text(en.packsBuiltIn), findsOneWidget);
    expect(
      find.text(
        en.packsMeta(m.version, formatBytes(m.totalSize), 'UZ · RU · EN'),
      ),
      findsOneWidget,
    );
    expect(find.text(en.packsOffline), findsOneWidget);
    expect(find.text(en.packsCoreState), findsOneWidget);

    // Katalog: sinov paketi aniq belgilangan, klinik deb ko'rsatilmaydi.
    await waitFor(tester, () => s.packs.catalogState == CatalogState.ready);
    final entry = s.packs.catalog!.entries.single;
    expect(find.text(en.packsStatusTest), findsOneWidget);
    expect(find.text(en.packsStatusReviewed), findsNothing);
    // Rejalashtirilganlar — o'chirilgan tugmalarsiz, ixcham ro'yxat.
    expect(find.text(en.packsPlanned), findsOneWidget);
    expect(find.text(en.notAvailableYet), findsNothing);

    await tester.tap(find.text(en.packsDownload(formatBytes(entry.size))));
    await waitFor(tester, () => s.packs.installed(entry.packId) != null);
    await tester.pump();
    expect(
      find.text(
        en.packsInstalledVersion(entry.version, formatBytes(entry.size)),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text(en.packsRemove));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.packsRemove).last);
    await waitFor(tester, () => s.packs.installed(entry.packId) == null);
    await tester.pump();
    expect(
      find.text(en.packsDownload(formatBytes(entry.size))),
      findsOneWidget,
    );
  });
}
