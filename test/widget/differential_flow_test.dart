import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/differential/differential_entry_points.dart';
import 'package:labguide/features/differential/differential_quiz.dart';
import 'package:labguide/features/differential/differential_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations_en.dart';
import 'package:labguide/l10n/gen/app_localizations_uz.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

final en = AppLocalizationsEn();
final uz = AppLocalizationsUz();

Finder _button(DiffCell c) => find.byKey(ValueKey('diff-count-${c.name}'));

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f.first);
  await tester.pumpAndSettle();
  await tester.tap(f.hitTestable().first);
  await tester.pumpAndSettle();
}

Future<void> _tapTimes(WidgetTester tester, DiffCell c, int n) async {
  await tester.ensureVisible(_button(c));
  await tester.pumpAndSettle();
  for (var i = 0; i < n; i++) {
    await tester.tap(_button(c));
    await tester.pump(const Duration(milliseconds: 10));
  }
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('hisoblagich 100 da to\'xtaydi, mutlaq sonlar, tarix', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 3000));
    await goTo(tester, '/lab/differential/count');

    await _tapTimes(tester, DiffCell.segmented, 60);
    await _tapTimes(tester, DiffCell.lymphocyte, 30);
    await _tapTimes(tester, DiffCell.band, 3);
    // Uzoq bosish — −1.
    await tester.longPress(_button(DiffCell.band));
    await tester.pumpAndSettle();
    expect(s.differential.count(DiffCell.band), 2);
    await _tapTimes(tester, DiffCell.monocyte, 8);
    // 60 + 30 + 2 + 8 = 100 → to'xtadi; keyingi bosish qo'shilmaydi.
    expect(s.differential.total, 100);
    expect(find.text(en.diffDoneTitle(100)), findsWidgets);
    await _tapTimes(tester, DiffCell.eosinophil, 3);
    expect(s.differential.total, 100);
    expect(s.differential.count(DiffCell.eosinophil), 0);
    expect(find.text(en.diffBlocked), findsOneWidget);

    // Mutlaq son: WBC 8 → segment 0,6 × 8 = 4,8.
    expect(find.text(en.diffAbsNeedWbc), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find
            .ancestor(
              of: find.text(en.diffWbcLabel),
              matching: find.byType(Column),
            )
            .first,
        matching: find.byType(TextField),
      ),
      '8',
    );
    await tester.pumpAndSettle();
    expect(s.differential.wbc, 8);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('2.4'), findsOneWidget);

    // Nusxalash.
    await _tap(tester, find.text(en.diffCopy));
    expect(copied, contains('Segmented neutrophil: 60 (60%) — 4.8 ×10⁹/L'));
    expect(copied, contains(en.diffWbcLine('8')));

    // Saqlash → tarix.
    await _tap(tester, find.text(en.diffSave));
    expect(s.differential.history, hasLength(1));
    expect(s.store.getString(StoreKeys.differentialHistory), isNotNull);
    await goTo(tester, '/lab/differential/history');
    expect(find.textContaining('Segs 60'), findsOneWidget);
    await _tap(tester, find.textContaining('Segs 60'));
    expect(find.text('4.8'), findsOneWidget);
    await _tap(tester, find.text(en.actionDelete));
    expect(s.differential.history, isEmpty);
    expect(find.text(en.diffHistoryEmptyTitle), findsOneWidget);

    // Lokal ma'lumotlarni o'chirish — qoralama ham o'chadi.
    await s.differential.save();
    await tester.runAsync(() => s.deleteLocalData(const [Locale('en')]));
    expect(s.differential.history, isEmpty);
    expect(s.differential.total, 0);
    expect(s.store.getString(StoreKeys.differentialDraft), isNull);
  });

  testWidgets('tarix: visibleLimit faqat ko\'rsatishni cheklaydi', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    s.differential.tap(DiffCell.lymphocyte);
    for (var i = 0; i < 5; i++) {
      await s.differential.save(label: 'S$i');
    }
    final (shown, hidden) = visibleHistory(s.differential.history, 2);
    expect(shown, hasLength(2));
    expect(hidden, 3);
    expect(visibleHistory(s.differential.history, null).$2, 0);
    // Ma'lumot to'liq saqlangan.
    expect(s.differential.history, hasLength(5));
    // Odatiy yo'l: cheklov yo'q (hozir hamma narsa ochiq).
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '/lab/differential/history');
    expect(find.textContaining('· S'), findsNWidgets(5));
    expect(find.textContaining('more results'), findsNothing);
  });

  testWidgets('kengaytirilgan mashqqa kirish nuqtasi', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '/lab/differential/quiz');
    await _tap(tester, find.text(en.diffQuizExtended(diffExtendedQuizSize)));
    expect(find.text(en.diffQuizExtendedIntro), findsOneWidget);
    expect(DiffEntryPoints.pdfExportAvailable, isFalse);
  });

  testWidgets('tarixni tozalash tasdiq bilan', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    s.differential
      ..tap(DiffCell.lymphocyte)
      ..tap(DiffCell.eosinophil);
    await s.differential.save();
    await s.differential.save();
    await pumpApp(tester, s, size: const Size(390, 2000));
    await goTo(tester, '/lab/differential/history');
    await _tap(tester, find.text(en.diffHistoryClear));
    expect(find.text(en.diffHistoryClearBody(2)), findsOneWidget);
    await _tap(tester, find.text(en.actionDelete).last);
    expect(s.differential.history, isEmpty);
    expect(find.text(en.diffHistoryEmptyTitle), findsOneWidget);
  });

  testWidgets('kirish nuqtalari: Lab tabi tepasida, laborant bosh sahifasi, '
      'talabaning O‘rganish tabi', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2400));
    expect(find.text(uz.diffTitle), findsOneWidget);
    await _tap(tester, find.text(uz.diffTitle));
    expect(find.text(uz.diffHeroTitle), findsOneWidget);

    await goTo(tester, '/lab');
    // Leykoformula kartasi Lab tabidagi birinchi element.
    final card = tester.getTopLeft(find.text(uz.diffTitle));
    final hero = tester.getTopLeft(find.text(uz.labHeroTitle));
    expect(card.dy, lessThan(hero.dy));

    await s.settings.setRole(AppRole.student);
    await goTo(tester, '/learn');
    await _tap(tester, find.text(uz.diffTitle));
    expect(find.text(uz.diffHeroTitle), findsOneWidget);
  });

  testWidgets('blast sahifasida "shifokorga yuboring" ogohlantirishi', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '/lab/differential/cells/blast');
    expect(find.text(en.diffReferTitle), findsOneWidget);
    expect(find.text(en.diffSchematicCaption), findsWidgets);
    await goTo(tester, '/lab/differential/cells/monocyte');
    expect(find.text(en.diffReferTitle), findsNothing);
    // Sxema yonida atlasdagi litsenziyali haqiqiy mikrofoto.
    await goTo(tester, '/lab/differential/cells/basophil');
    expect(find.text(en.diffRealSmear), findsOneWidget);
    expect(find.text('CDC PHIL'), findsOneWidget);
    // Kontent paketidagi bazofil kartasiga havola.
    expect(find.text(en.diffRelatedCards), findsOneWidget);
    await goTo(tester, '/lab/differential/cells/blast');
    expect(find.text(en.diffRealSmear), findsNothing);
  });

  testWidgets('mashq: javob, izoh, natija', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '/lab/differential/quiz');
    await _tap(tester, find.text(en.diffQuizStart));
    final names = {for (final c in cellGuides) c.name.of('en')};
    for (var i = 0; i < 12; i++) {
      await _tap(
        tester,
        find.byWidgetPredicate((w) => w is Text && names.contains(w.data)),
      );
      expect(
        find.text(en.quizCorrect).evaluate().length +
            find.text(en.quizIncorrect).evaluate().length,
        1,
      );
      await _tap(tester, find.text(i == 11 ? en.quizFinish : en.quizNext));
    }
    expect(find.text(en.quizDoneTitle), findsOneWidget);
  });
}
