import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/auth/otp_auth.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import 'app_flow_test.dart' show tapText;

/// Demo adapter, lekin so'rovdagi tilni yozib boradi.
class _RecordingOtp extends DemoOtpAdapter {
  _RecordingOtp() : super(releaseBuild: false);
  final languages = <String?>[];

  @override
  Future<OtpRequestResult> requestCode(String email, {String? language}) {
    languages.add(language);
    return super.requestCode(email, language: language);
  }
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('kod so‘rovi ilova tilini yuboradi: ${lang.name}', (
      tester,
    ) async {
      final otp = _RecordingOtp();
      final services = await makeServices(
        tester,
        language: lang,
        onboarded: false,
        role: null,
        otpAdapter: otp,
      );
      await pumpApp(tester, services);
      await goTo(tester, '/welcome/auth');
      final l = lookupAppLocalizations(lang.locale);
      await tester.enterText(find.byType(TextField), 'lab@example.com');
      await tapText(tester, l.authConsent);
      await tapText(tester, l.authGetCode);
      expect(otp.languages, [lang.name]);
    });
  }
}
