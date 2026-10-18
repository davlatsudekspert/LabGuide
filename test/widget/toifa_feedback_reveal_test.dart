// Toifa mashqi (50 savollik mashq rejimi), mavzu bo'yicha mashq va
// “Xatolar ustida ishlash” — kichik telefonda (360×640, ×1.3, iOS) javob
// bosilgach “To'g'ri / xato” izohi ekrandan pastda qolardi: foydalanuvchi
// natijani va “Keyingi” tugmasini ko'rmasdi. Endi izoh RevealOnMount bilan
// ko'rinadigan joyga suriladi (test/widget/answer_feedback_reveal_test.dart
// bilan bir xil qoida); katta ekranda ro'yxat qimirlamaydi.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/design/widgets/reveal_on_mount.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));

const _small = Size(360, 640);

final _ios = TargetPlatformVariant.only(TargetPlatform.iOS);

void _expectFeedbackVisible(WidgetTester tester, Size size) {
  final f = find.byType(RevealOnMount);
  expect(f, findsOneWidget);
  final top = tester.getTopLeft(f).dy;
  expect(top, greaterThan(47), reason: 'sarlavha ostida emas');
  expect(
    top + 48,
    lessThanOrEqualTo(size.height - 34 - RevealOnMount.bottomReserve),
    reason: 'izoh menyu ostida yoki ekrandan pastda qoldi',
  );
}

ScrollPosition _pos(WidgetTester tester) => tester
    .state<ScrollableState>(
      find
          .descendant(
            of: find.byType(LgPage).hitTestable().first,
            matching: find.byType(Scrollable),
          )
          .first,
    )
    .position;

/// Ekrandagi savol (matni ko'rinib turgan).
ToifaTestQuestion _shown(AppServices s) => s.toifa.bank!.scorable.firstWhere(
  (q) => find.text(q.prompt('uz')).evaluate().isNotEmpty,
);

/// Oxirgi variant (eng pastdagi) bosiladi — izoh eng pastda paydo bo'ladi.
Future<void> _tapLast(WidgetTester tester, ToifaTestQuestion q) =>
    tapScroll(tester, q.option(q.optionCount - 1, 'uz'));

void main() {
  setUpAll(loadAppFonts);

  testWidgets('mashq rejimi (50 savol): izoh ko‘rinadi (360×640 ×1.3)', (
    tester,
  ) async {
    final s = await makeServices(tester);
    s.toifa.random = Random(2);
    await pumpApp(tester, s, size: _small, textScale: 1.3);
    await goTo(tester, '/learn/toifa/test');
    await tester.tap(find.byKey(const ValueKey('toifa-mode-practice')));
    await tester.pumpAndSettle();
    await tapScroll(tester, uz.toifaDrillStart);
    for (var n = 0; n < 3; n++) {
      final d = s.toifa.activeDrill!;
      await _tapLast(tester, s.toifa.bank!.test(d.ids[d.index])!);
      _expectFeedbackVisible(tester, _small);
      await tapScroll(tester, uz.quizNext);
    }
  }, variant: _ios);

  testWidgets('mavzu bo‘yicha mashq: izoh ko‘rinadi (360×640 ×1.3)', (
    tester,
  ) async {
    final s = await makeServices(tester);
    s.toifa.random = Random(3);
    await pumpApp(tester, s, size: _small, textScale: 1.3);
    await goTo(tester, '/learn/toifa/practice/mixed');
    for (var n = 0; n < 2; n++) {
      await _tapLast(tester, _shown(s));
      _expectFeedbackVisible(tester, _small);
      await tapScroll(tester, uz.quizNext);
    }
  }, variant: _ios);

  testWidgets('xatolar ustida ishlash: izoh ko‘rinadi (360×640 ×1.3)', (
    tester,
  ) async {
    final s = await makeServices(tester);
    for (final q in s.toifa.bank!.scorable.take(4)) {
      await s.quizProgress.record(q.id, correct: false);
    }
    await pumpApp(tester, s, size: _small, textScale: 1.3);
    await goTo(tester, '/learn/toifa/practice/mistakes');
    await _tapLast(tester, _shown(s));
    _expectFeedbackVisible(tester, _small);
  }, variant: _ios);

  testWidgets('katta ekran: izoh ko‘rinib tursa ro‘yxat surilmaydi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    s.toifa.random = Random(3);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '/learn/toifa/practice/mixed');
    final before = _pos(tester).pixels;
    final q = _shown(s);
    await tester.tap(find.text(q.option(q.optionCount - 1, 'uz')));
    await tester.pumpAndSettle();
    expect(find.byType(RevealOnMount), findsOneWidget);
    expect(_pos(tester).pixels, before);
  }, variant: _ios);
}
