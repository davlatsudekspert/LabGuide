import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/backend/partner_models.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';
import '../helpers/partner_fixtures.dart';

/// Hamkor (reklama) ekranlari to'ldirilgan holatda — layout matritsasi
/// (`layout_matrix_test.dart`) sozlanmagan buildda ularni bo'sh/halol
/// holatda tekshiradi; bu yerda haqiqiy hamkor, ariza va admin
/// (aal2) bilan: 3 til × tor/katta shrift/qorong'i/planshet.
const _routes = [
  '/lab',
  '/lab/instruments/c/chemistry',
  '/lab/instruments/m/mindray-bs-240',
  '/lab/partners/partner-test-1',
  '/lab/partners/partner-long',
  '/profile',
  '/profile/partnership',
  '/profile/admin',
  '/profile/admin/partners',
  '/profile/admin/partners/new',
  '/profile/admin/partners/partner-long',
  '/profile/admin/partners/partner-test-1/stats',
  '/profile/admin/partner-requests',
];

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    for (final (width, scale, theme) in [
      (320.0, 2.0, ThemeMode.light),
      (390.0, 1.35, ThemeMode.dark),
      (430.0, 1.0, ThemeMode.light),
      (820.0, 1.35, ThemeMode.light),
    ]) {
      testWidgets('partners: ${lang.name} ${width.toInt()}px ×$scale '
          '${theme.name}', (tester) async {
        final backend = FakeLabBackend()
          ..seedPartner(testPartner())
          ..seedPartner(
            testPartner(
              id: 'partner-long',
              name:
                  'Laboratoriya Uskunalari va Diagnostika Servisi '
                  'Sinov Hamkor MChJ',
              kind: PartnerKind.service,
              telegram: null,
              phone: null,
              regions: uzRegionCodes.skip(1).toList(),
              links: const [
                PartnerLink(
                  target: PartnerLinkTarget.model,
                  catalogId: 'mindray-bs-480',
                  registrationNo: 'TEST-LONG-REGISTRATION-NUMBER-0002',
                ),
                PartnerLink(
                  target: PartnerLinkTarget.maker,
                  catalogId: 'roche',
                ),
              ],
            ),
          );
        final s = await makeServices(
          tester,
          language: lang,
          themeMode: theme,
          backend: backend,
        );
        await s.auth.requestCode('davlatsudekspert@gmail.com');
        await s.auth.verifyCode(FakeLabBackend.otpCode);
        await backend.mfaVerify(
          factorId: 'totp-1',
          code: FakeLabBackend.totpCode,
        );
        await backend.createPartnerRequest(
          const PartnerRequestDraft(
            company: 'Sinov Ariza MChJ',
            contactName: 'Aliyev A.',
            phone: '+998 90 123-45-67',
            products: 'Mindray BS-240',
            message: 'Hamkorlik shartlari?',
          ),
        );
        await pumpApp(tester, s, size: Size(width, 3200), textScale: scale);
        for (final route in _routes) {
          await goTo(tester, route);
          final error = tester.takeException();
          expect(error, isNull, reason: '$route → $error');
        }
      });
    }
  }
}
