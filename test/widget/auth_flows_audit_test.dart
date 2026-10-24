// Kirish oqimlari auditi (2026-10-24, docs/AUTH_FLOWS_AUDIT_2026-10-24.md):
// mehmon → hisob, qayta o'rnatishdan keyin qolgan token, hisob o'chirilgach
// qayta kirish.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'mehmon → email kodi bilan kirish: rol, til va onboarding saqlanadi',
    (tester) async {
      final b = FakeLabBackend();
      final s = await makeServices(
        tester,
        backend: b,
        role: AppRole.doctor,
        language: AppLanguage.ru,
      );
      expect(s.auth.hasAccount, isFalse);
      await s.auth.requestCode('guest.to.account@example.com');
      await s.auth.verifyCode(FakeLabBackend.otpCode);
      expect(s.auth.hasAccount, isTrue);
      expect(s.settings.role, AppRole.doctor);
      expect(s.settings.language, AppLanguage.ru);
      expect(s.settings.onboarded, isTrue);
    },
  );

  testWidgets(
    'qayta o‘rnatish: Keychain’da qolgan begona sessiya serverda yopiladi',
    (tester) async {
      final b = FakeLabBackend();
      final s = await makeServices(tester, backend: b);
      // Server sessiyasi bor (eski o'rnatishdan), ilovadagi belgi — mehmon.
      await b.requestCode('old@example.com');
      await b.verifyCode('old@example.com', FakeLabBackend.otpCode);
      expect(b.hasSession, isTrue);
      await s.auth.reconcileWithBackend();
      expect(b.callCount('signOut'), 1);
      expect(b.hasSession, isFalse);
      expect(s.auth.hasAccount, isFalse);
    },
  );

  testWidgets(
    'hisob o‘chirilgach shu email bilan qayta kirish — yangi bo‘sh hisob',
    (tester) async {
      final b = FakeLabBackend();
      final s = await makeServices(tester, backend: b);
      await s.auth.requestCode('again@example.com');
      await s.auth.verifyCode(FakeLabBackend.otpCode);
      final first = b.userId;
      await b.deleteAccount();
      await s.auth.signOut();
      await s.auth.requestCode('again@example.com');
      await s.auth.verifyCode(FakeLabBackend.otpCode);
      expect(s.auth.hasAccount, isTrue);
      expect(b.userId, isNot(first));
      expect(await b.myGroups(), isEmpty);
    },
  );
}
