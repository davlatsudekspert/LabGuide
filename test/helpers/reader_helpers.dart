import 'package:flutter_test/flutter_test.dart';

/// PDFium alohida isolate'da ishlaydi: soxta vaqt (fake async) uni
/// kutmaydi, `pumpAndSettle` esa yuklanish spinneri tufayli tugamaydi.
/// Shu sabab haqiqiy vaqt bilan kutib, kadr chizib turamiz.
Future<void> pumpReal(WidgetTester tester, {int frames = 12}) async {
  for (var i = 0; i < frames; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> waitUntil(
  WidgetTester tester,
  bool Function() done, {
  Duration timeout = const Duration(seconds: 20),
  String? reason,
}) async {
  final end = DateTime.now().add(timeout);
  while (true) {
    await pumpReal(tester, frames: 1);
    if (done()) return;
    if (DateTime.now().isAfter(end)) {
      throw TestFailure('timeout: ${reason ?? 'condition'}');
    }
  }
}

Future<void> waitForFinder(WidgetTester tester, Finder finder) => waitUntil(
  tester,
  () => finder.evaluate().isNotEmpty,
  reason: finder.toString(),
);

/// O'quvchi ochiq paytda bosish (pumpAndSettle'siz).
Future<void> tapReader(WidgetTester tester, Finder finder) async {
  await tester.tap(finder.hitTestable().last);
  await pumpReal(tester);
}
