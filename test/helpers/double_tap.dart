import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Elementni ko'rinadigan qilib, uni bir kadr ichida ikki marta bosadi
/// (orada `pump` yo'q — tugma hali "band" ko'rinishiga o'tmagan). Ekranda
/// aylanayotgan "band" belgisi bo'lishi mumkin — `pumpAndSettle` emas.
Future<void> doubleTap(WidgetTester tester, Finder f) async {
  if (f.hitTestable().evaluate().isEmpty) {
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
  await tester.ensureVisible(f.last);
  await tester.pump();
  final at = tester.getCenter(f.hitTestable().last);
  await tester.tapAt(at);
  await tester.tapAt(at);
}

Future<void> doubleTapText(WidgetTester tester, String text) =>
    doubleTap(tester, find.text(text));

/// Pastga aylanadigan ro'yxatda [f] ko'ringuncha suradi.
Future<void> scrollToFinder(WidgetTester tester, Finder f) async {
  if (f.hitTestable().evaluate().isNotEmpty) return;
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
  await tester.pumpAndSettle();
}
