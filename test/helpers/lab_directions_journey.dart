// Foydalanuvchi yo'li: Toifa bo'limi → uchta yo'nalish (Laboratoriya ishi,
// Toksikologik laboratoriya, Laboratoriya diagnostikasi). Har yo'nalishda 20
// savolning hammasi ekrandan javoblanadi (to'g'ri/xato), natija ko'rinadi;
// iPhone o'lchamida. Til bo'yicha alohida fayl: uz va ru bitta jarayonda
// ketma-ket ishlamaydi (til holati testlar orasida qoladi).
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/toifa/lab_ishi_direction.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';
import 'learn_helpers.dart';

const _iphone = Size(390, 1400);

/// Asset'lar haqiqiy IO bilan o'qiladi — yuklanish tugaguncha kutadi.
Future<void> _loaded(WidgetTester tester) async {
  for (var k = 0; k < 60; k++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
  }
  await tester.pumpAndSettle();
}

void runDirectionJourneys(
  AppLanguage lang,
  String correct,
  String wrong,
  String next,
  String result,
) {
  setUpAll(loadAppFonts);
  for (final d in LabDirection.values) {
    testWidgets('${d.name} / ${lang.name}: 20 savol ekrandan, natija', (
      tester,
    ) async {
      final store = MemoryKeyValueStore();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      });
      final s = await makeServices(tester, store: store, language: lang);
      await pumpApp(tester, s, size: _iphone);
      await goTo(tester, '/learn/toifa');
      await _loaded(tester);
      final title = labDirectionTitle(
        tester.element(find.byType(Scaffold).first),
        d,
      );
      final row = find.text(title);
      final scroller = find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first;
      await tester.scrollUntilVisible(row, 200, scrollable: scroller);
      // Pastki panel qatorni yopmasligi uchun kerak bo'lsa yana suramiz.
      for (var k = 0; k < 10 && row.hitTestable().evaluate().isEmpty; k++) {
        await tester.drag(scroller, Offset(0, k.isEven ? -140 : 60));
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(
        row.hitTestable(),
        findsWidgets,
        reason: 'qator ko‘rinmayapti: ${row.evaluate().length} ta, '
            '${row.evaluate().isEmpty ? '' : tester.getRect(row.first)}',
      );
      await tester.tap(row.first);
      await tester.pump();
      await _loaded(tester);
      expect(find.textContaining('1 / 20'), findsWidgets);

      var right = 0;
      for (var i = 0; i < labIshiSessionSize; i++) {
        // Birinchi variantni (A) tanlaymiz — natija kalitga bog'liq.
        final opt = find.textContaining('A) ');
        expect(opt, findsWidgets, reason: 'savol ${i + 1}');
        await tester.ensureVisible(opt.first);
        await tester.tap(opt.first);
        await tester.pumpAndSettle();
        final gotRight = find.text(correct).evaluate().isNotEmpty;
        final gotWrong = find.textContaining(wrong).evaluate().isNotEmpty;
        expect(gotRight != gotWrong, isTrue, reason: 'savol ${i + 1}');
        if (gotRight) right++;
        await tapScroll(tester, i == labIshiSessionSize - 1 ? result : next);
      }
      expect(find.text('$right / 20'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
