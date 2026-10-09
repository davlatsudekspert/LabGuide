// Tekshiruv navbati — tekshiruvchi va “Ustoz” sifatida (walk_helper.dart).
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/fake_backend.dart';
import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

Future<void> signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('tekshiruvchi (uz)', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final backend = FakeLabBackend();
    final s = await start(tester, backend: backend, role: AppRole.doctor);
    await signIn(tester, s, 'reviewer@example.com');
    backend.grantReviewer('reviewer@example.com');
    final w = Walk(tester, 'review_uz');
    await goTo(tester, '/library/review');
    await w.snap('navbat_kartalar');
    final glucose = s.content.pack!
        .analyte('glucose-plasma-fasting')!
        .names
        .of('uz');
    await w.tapText(glucose);
    await w.snap('karta_korib_chiqish');
    await w.scroll(600);
    await w.snap('karta_qaror_formasi');
    await w.tapText(l.rvChanges);
    await tester.enterText(
      find.byType(TextField).last,
      'Qaror chegarasiga manba sahifasi kerak',
    );
    await w.snap('izoh_yozildi');
    await w.tapText(l.rvSubmit);
    await w.snap('qaror_yozildi');
    routerOf(tester).pop();
    await w.snap('navbat_holat');
    await w.scroll(-3000);
    await w.tap(find.textContaining(l.rvTabQuestions).first);
    await w.snap('navbat_savollar');
    await w.tap(find.byIcon(Icons.quiz_outlined).first);
    await w.snap('savol_korib_chiqish');
  });

  testWidgets('ustoz — ruxsat yo‘q (ru, qorong‘i, katta shrift)', (
    tester,
  ) async {
    final backend = FakeLabBackend();
    final s = await start(
      tester,
      backend: backend,
      role: AppRole.teacher,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
    );
    await signIn(tester, s, 'teacher@example.com');
    final w = Walk(tester, 'review_teacher_ru');
    await goTo(tester, '/library/review');
    await w.snap('ruxsat_yoq');
  });
}
