import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/microscopy/microscopy_screens.dart';
import 'package:labguide/features/microscopy/microscopy_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

/// Talaba sifatida: atlas → bo'lim → rasm → to'liq ekran → orqaga;
/// “Bu nima?” mashqi → javob → natija.
Future<void> _tap(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      250,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .hitTestable()
          .first,
    );
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('atlas → bo‘lim → rasm → kattalashtirish → orqaga', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await makeServices(tester, role: AppRole.student);
    // Baland ekran: kartaning hamma bloklari quriladi.
    await pumpApp(tester, s, size: const Size(390, 3000));
    await goTo(tester, '/lab/microscopy');
    expect(find.byType(MicroscopyScreen), findsOneWidget);
    expect(find.text(l.micQuizCta), findsOneWidget);

    await _tap(tester, find.text('Periferik qon surtmasi'));
    expect(find.byType(MicroSectionScreen), findsOneWidget);
    await _tap(tester, find.text('Bazofil'));
    expect(find.byType(MicroImageScreen), findsOneWidget);
    // Asl izoh, tarjima, litsenziya, manba, eslatma.
    expect(find.text(l.micEduTag), findsOneWidget);
    expect(find.textContaining('basophilic leukocyte'), findsOneWidget);
    expect(find.text(l.micTranslation), findsOneWidget);
    expect(find.text('CDC/ Dr. F. Gilbert'), findsOneWidget);
    expect(find.text(l.micSourcePage), findsOneWidget);
    expect(find.text(l.micDraftTag), findsOneWidget);
    expect(find.text('1000X'), findsOneWidget);
    expect(find.text(l.micNotStated), findsOneWidget); // bo'yoq yozilmagan

    await _tap(tester, find.text(l.micZoom).first);
    expect(find.byType(MicroViewer), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    await _tap(tester, find.byTooltip(l.micZoomIn));
    await _tap(tester, find.byTooltip(l.micClose));
    expect(find.byType(MicroViewer), findsNothing);
    expect(find.byType(MicroImageScreen), findsOneWidget);
  });

  testWidgets('qidiruv: rasmsiz tur halol ko‘rsatiladi', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s);
    await goTo(tester, '/lab/microscopy');
    await tester.enterText(find.byType(TextField).first, 'squamous');
    await tester.pumpAndSettle();
    expect(find.byType(MicroGapCard), findsOneWidget);
    await _tap(tester, find.text(l.micGapWhy));
    expect(find.text(l.micNoImageYet), findsWidgets);
    expect(find.textContaining('2026-10-09'), findsOneWidget);
  });

  testWidgets('“Bu nima?”: boshlash → javob → keyingi → natija saqlanadi', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final store = MemoryKeyValueStore();
    final s = await makeServices(tester, store: store);
    await pumpApp(tester, s);
    await goTo(tester, '/lab/microscopy/quiz?section=parasites');
    expect(find.text(l.micQuizNoBest), findsOneWidget);
    await _tap(tester, find.textContaining('Boshlash'));
    expect(find.text(l.micQuizProgress(1, 2)), findsOneWidget);
    for (var i = 0; i < 2; i++) {
      // Birinchi variantni tanlaymiz — javob darhol ko'rinadi.
      await _tap(tester, find.text('A'));
      expect(
        find.text(l.micQuizCorrect).evaluate().length +
            find.textContaining('To‘g‘ri javob:').evaluate().length,
        1,
      );
      await _tap(tester, find.text(i == 0 ? l.quizNext : l.quizFinish));
    }
    expect(find.text(l.quizMistakes), findsOneWidget);
    expect(s.microscopy.best('parasites')!.total, 2);
    expect(store.getString(StoreKeys.microscopyQuiz), isNotNull);
  });
}
