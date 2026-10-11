// Admin panel → "Tekshiruv navbati": navbat admin panel ichida
// (/profile/admin/review) ochiladi, boshqa tabga o'tib bo'sh sahifa
// chiqarmaydi; karta sahifasi ham shu yo'l ostida — uz/ru/en.
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:labguide/features/review/review_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/fake_community.dart';
import '../helpers/harness.dart';

const _owner = 'davlatsudekspert@gmail.com';

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Ko'rinib turgan [screen] sahifasining yo'li (push qilingan sahifa ham).
String _location<T extends Widget>(WidgetTester tester) =>
    GoRouterState.of(tester.element(find.byType(T).hitTestable().first)).uri
        .toString();

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('admin paneldan tekshiruv navbati ochiladi (${lang.name})', (
      tester,
    ) async {
      final l = lookupAppLocalizations(lang.locale);
      final lab = FakeAdminTeamBackend();
      final s = await makeServices(
        tester,
        language: lang,
        backend: lab,
        community: FakeCommunityBackend(lab),
      );
      await pumpApp(tester, s);
      await s.auth.requestCode(_owner);
      await s.auth.verifyCode(FakeLabBackend.otpCode);
      await tester.pumpAndSettle();
      await goTo(tester, '/profile/admin');
      await tester.enterText(
        find.byType(TextField).last,
        FakeLabBackend.totpCode,
      );
      await _tap(tester, find.text(l.adminMfaVerify));

      final pack = s.content.pack!;
      final cards = pack.analytes.where((a) => !a.isReviewerApproved).toList();
      final questions = pack.quiz.where((q) => q.isDraft).length;
      expect(cards, isNotEmpty);
      await _tap(tester, find.byKey(const ValueKey('admin-row-review')));

      expect(_location<ReviewQueueScreen>(tester), '/profile/admin/review');
      expect(find.text(l.libReview).hitTestable(), findsOneWidget);
      // Haqiqiy sonlar: tekshirilmagan kartalar va qoralama savollar.
      expect(
        find.text('${l.rvTabCards} · ${cards.length}').hitTestable(),
        findsOneWidget,
      );
      expect(find.text('${l.rvTabQuestions} · $questions'), findsOneWidget);
      // Admin — faqat ko'radi (tekshiruvchi vakolati alohida beriladi).
      expect(find.text(l.rvAdminReadOnly), findsOneWidget);

      final code = lang.locale.languageCode;
      final first = cards.first.names.of(code);
      await _tap(tester, find.text(first));
      expect(
        _location<ReviewItemScreen>(tester),
        '/profile/admin/review/analyte/${cards.first.id}',
      );
      expect(find.text(first).hitTestable(), findsWidgets);
    });
  }
}
