import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

/// Android: 3 tugmali tizim paneli (xavfsiz hudud 48) ilova menyusi ustiga
/// chiqmasin — menyuning pastki cheti tizim paneli tepasida bo'lsin.
/// iOS'da esa menyu home indikatori ustida (yarim xavfsiz hudud) suzadi.
void main() {
  setUpAll(loadAppFonts);

  for (final (platform, inset, name) in [
    (TargetPlatform.android, 48.0, 'Android 3 tugma'),
    (TargetPlatform.android, 16.0, 'Android jest'),
    (TargetPlatform.iOS, 34.0, 'iOS home indikatori'),
  ]) {
    testWidgets('$name: menyu tizim paneli ustida', (tester) async {
      // Platforma o'zgaruvchisi test tanasi ichida qaytarilishi shart.
      debugDefaultTargetPlatformOverride = platform;
      try {
        await _check(tester, platform, inset);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}

Future<void> _check(
  WidgetTester tester,
  TargetPlatform platform,
  double inset,
) async {
  final s = await makeServices(tester);
  const ratio = 3.0;
  await pumpApp(tester, s, notch: false, ratio: ratio);
  tester.view.padding = FakeViewPadding(top: 24 * ratio, bottom: inset * ratio);
  await tester.pumpAndSettle();
  final tab = find.byKey(const ValueKey('nav-tab-0'));
  expect(tab, findsOneWidget);
  final bottom = tester.getBottomRight(tab).dy;
  final screen = tester.view.physicalSize.height / ratio;
  final required = platform == TargetPlatform.android ? inset : inset / 2;
  expect(screen - bottom, greaterThanOrEqualTo(required));
}
