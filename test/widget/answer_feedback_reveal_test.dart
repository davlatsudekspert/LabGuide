// Audit 2026-10-18 (tablar, docs/AUDIT_2026-10-18_TABS.md):
// kichik telefonda (360×640, ×1.3, iOS fizikasi) javob bosilgach
// "To'g'ri / xato" izohi ekrandan pastda qolardi — foydalanuvchi natijani
// ko'rmasdi va har savolda qo'lda surishi kerak edi. Endi izoh avtomatik
// ko'rinadigan joyga suriladi; katta ekranda ro'yxat qimirlamaydi.
// (Toifa mashqi — boshqa agent doirasida; bu yerda tegilmagan.)
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/design/widgets/reveal_on_mount.dart';
import 'package:labguide/features/learn/learn_screens.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));

const _small = Size(360, 640);

final _ios = TargetPlatformVariant.only(TargetPlatform.iOS);

/// Izohli testda birinchi variantni bosish (harfsiz tugmalar).
Future<void> _tapFirstOption(WidgetTester tester) async {
  final f = find.byType(QuizOptionButton).first;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Izoh (RevealOnMount) boshi ekranning ko'rinadigan qismida — suzuvchi
/// menyudan yuqorida.
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

void main() {
  setUpAll(loadAppFonts);

  testWidgets('izohli test: javobdan keyin izoh ko‘rinadi (360×640 ×1.3)', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _small, textScale: 1.3);
    await goTo(tester, '/learn/quiz');
    await tapScroll(tester, uz.quizTopicMixed(10));
    for (var n = 0; n < 2; n++) {
      await _tapFirstOption(tester);
      _expectFeedbackVisible(tester, _small);
      await tapScroll(tester, uz.quizNext);
    }
  }, variant: _ios);

  testWidgets('kunlik savollar: javobdan keyin izoh ko‘rinadi (360×640 ×1.3)', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _small, textScale: 1.3);
    await goTo(tester, '/learn/daily');
    await tapScroll(tester, 'A');
    _expectFeedbackVisible(tester, _small);
  }, variant: _ios);

  testWidgets('katta ekran: izoh ko‘rinib tursa ro‘yxat surilmaydi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '/learn/quiz');
    await tapScroll(tester, uz.quizTopicMixed(10));
    final before = _pos(tester).pixels;
    await _tapFirstOption(tester);
    expect(find.byType(RevealOnMount), findsOneWidget);
    expect(_pos(tester).pixels, before);
  }, variant: _ios);
}
