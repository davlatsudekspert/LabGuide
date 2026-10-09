import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';

final _l = lookupAppLocalizations(const Locale('uz'));

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('server ulanmagan: tekshiruv navbati yopiq', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s);
    await goTo(tester, '/library/review');
    expect(find.text(_l.supportUnavailableTitle), findsOneWidget);
    expect(find.text(_l.rvTabCards), findsNothing);
  });

  testWidgets('“Ustoz” roli tekshiruv huquqini bermaydi', (tester) async {
    final backend = FakeLabBackend();
    final s = await makeServices(
      tester,
      backend: backend,
      role: AppRole.teacher,
    );
    await pumpApp(tester, s);
    await _signIn(tester, s, 'teacher@example.com');
    await goTo(tester, '/library/review');
    expect(find.text(_l.rvGateTitle), findsOneWidget);
    expect(find.textContaining(_l.rvTabCards), findsNothing);
    await goTo(tester, '/library/review/analyte/glucose-plasma-fasting');
    expect(find.text(_l.rvGateTitle), findsOneWidget);
    expect(find.text(_l.rvSubmit), findsNothing);
  });

  testWidgets(
    'tekshiruvchi: qaror yozadi, izoh majburiy, karta holati o‘zgarmaydi',
    (tester) async {
      final backend = FakeLabBackend();
      final s = await makeServices(tester, backend: backend);
      await pumpApp(tester, s);
      await _signIn(tester, s, 'reviewer@example.com');
      backend.grantReviewer('reviewer@example.com');
      await goTo(tester, '/library/review');
      expect(find.textContaining(_l.rvTabCards), findsOneWidget);
      final glucose = s.content.pack!
          .analyte('glucose-plasma-fasting')!
          .names
          .of('uz');
      expect(find.text(glucose), findsOneWidget);
      expect(find.text('${_l.rvNotSeen} · ${_l.rvCount(0)}'), findsWidgets);

      await _tap(tester, find.text(glucose));
      expect(find.text(_l.rvNoHistory), findsOneWidget);
      // “O'zgartirish kerak” — izohsiz yuborilmaydi.
      await _tap(tester, find.text(_l.rvChanges));
      await _tap(tester, find.text(_l.rvSubmit));
      expect(find.text(_l.rvCommentRequired), findsOneWidget);
      expect(await backend.contentReviews(), isEmpty);
      final field = find.byType(TextField).last;
      await tester.ensureVisible(field);
      await tester.enterText(
        field,
        'Qaror chegarasiga ADA 2025 sahifasi kerak',
      );
      await _tap(tester, find.text(_l.rvSubmit));
      expect(find.text(_l.rvSubmitted), findsOneWidget);
      final reviews = await backend.contentReviews();
      expect(reviews.single.decision, ReviewDecision.changes);
      expect(reviews.single.contentVersion, s.content.pack!.contentVersion);
      expect(
        find.textContaining('${_l.rvYou} · ${_l.rvDecisionChanges}'),
        findsOneWidget,
      );
      // Qaror kartani avtomatik “tekshirilgan” qilmaydi.
      expect(
        s.content.pack!.analyte('glucose-plasma-fasting')!.isReviewerApproved,
        isFalse,
      );

      routerOf(tester).pop();
      await tester.pumpAndSettle();
      expect(
        find.text('${_l.rvMine(_l.rvDecisionChanges)} · ${_l.rvCount(1)}'),
        findsOneWidget,
      );
      // Savollar bo'limi.
      await _tap(tester, find.textContaining(_l.rvTabQuestions));
      expect(find.byIcon(Icons.quiz_outlined), findsWidgets);
    },
  );

  testWidgets('admin hisobi (reviewer emas) faqat ko‘radi', (tester) async {
    final backend = FakeLabBackend();
    final s = await makeServices(tester, backend: backend);
    await pumpApp(tester, s);
    await _signIn(tester, s, 'davlatsudekspert@gmail.com');
    await goTo(tester, '/library/review/quiz/dilution-equation');
    expect(find.text(_l.rvAdminReadOnly), findsOneWidget);
    expect(find.text(_l.rvSubmit), findsNothing);
  });

  testWidgets('kartada kelib chiqishi: tayyorlagan va manbalar sanasi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s);
    await goTo(tester, '/tests/analyte/glucose-plasma-fasting');
    final scrollable = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .hitTestable()
        .first;
    await tester.scrollUntilVisible(
      find.text(_l.analyteEditorial),
      300,
      scrollable: scrollable,
    );
    expect(find.text(_l.analytePreparedBy), findsOneWidget);
    expect(find.text(_l.analyteSourcesChecked), findsOneWidget);
    expect(find.text(_l.analyteReviewPending), findsWidgets);
  });
}
