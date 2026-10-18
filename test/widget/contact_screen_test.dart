import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/contact.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';

/// “Aloqa va shikoyat” ekrani: serversiz ochiladi, manzil bitta
/// konstantadan, nusxalash, mailto havolalari, tor ekran/katta shrift.

const _urlChannel = MethodChannel('plugins.flutter.io/url_launcher');

/// Soxta clipboard va url_launcher kanali. [launchResult] — `launch`
/// javobi (false → pochta ilovasi yo'q; null → platforma xatosi).
class _Fakes {
  _Fakes(WidgetTester tester, {bool? launchResult = true}) {
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clip = (call.arguments as Map)['text'] as String?;
      }
      return null;
    });
    messenger.setMockMethodCallHandler(_urlChannel, (call) async {
      if (call.method == 'launch') {
        launched.add((call.arguments as Map)['url'] as String);
        if (launchResult == null) {
          throw PlatformException(code: 'ACTIVITY_NOT_FOUND');
        }
        return launchResult;
      }
      return false;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
      messenger.setMockMethodCallHandler(_urlChannel, null);
    });
  }

  String? clip;
  final launched = <String>[];
}

Future<void> _openContact(
  WidgetTester tester, {
  AppLanguage lang = AppLanguage.uz,
  Size size = const Size(390, 3200),
  double textScale = 1,
  FakeLabBackend? backend,
  bool? partnerAds,
}) async {
  final s = await makeServices(
    tester,
    language: lang,
    backend: backend,
    partnerAds: partnerAds,
  );
  await pumpApp(tester, s, size: size, textScale: textScale);
  await goTo(tester, '/profile/contact');
}

AppLocalizations _l(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).last));

void main() {
  setUpAll(loadAppFonts);

  group('Contact.mailto', () {
    test('subject and body are percent-encoded (no "+")', () {
      final u = Contact.mailto(
        subject: Contact.subjectQuestion,
        body: 'Salom\nIlova: LabGuide 0.1.0',
      );
      expect(u.scheme, 'mailto');
      expect(u.path, Contact.email);
      final raw = u.toString();
      expect(
        raw,
        startsWith('mailto:${Contact.email}?subject=LabGuide%3A%20savol'),
      );
      expect(raw, isNot(contains('+')));
      expect(raw, contains('%0A'));
      expect(u.queryParameters['subject'], 'LabGuide: savol/taklif');
      expect(u.queryParameters['body'], 'Salom\nIlova: LabGuide 0.1.0');
    });

    test('three fixed subjects', () {
      expect(Contact.subjectQuestion, 'LabGuide: savol/taklif');
      expect(Contact.subjectAd, 'LabGuide: reklama');
      expect(Contact.subjectReport, 'LabGuide: shikoyat');
      expect(Contact.mailto(subject: 'x').toString(), isNot(contains('body')));
    });
  });

  for (final lang in AppLanguage.values) {
    testWidgets('opens in ${lang.name} and shows the contact email', (
      tester,
    ) async {
      _Fakes(tester);
      await _openContact(tester, lang: lang);
      final l = _l(tester);
      expect(tester.takeException(), isNull);
      expect(find.text(l.contactTitle), findsWidgets);
      expect(find.byKey(const ValueKey('contact-email')), findsOneWidget);
      expect(find.text(Contact.email), findsOneWidget);
      expect(find.text(l.contactQuestionTitle), findsOneWidget);
      // Do'kon build (LG_PARTNER_ADS o'chiq): reklama bo'limi yo'q.
      expect(find.text(l.contactAdTitle), findsNothing);
      expect(find.byKey(const ValueKey('contact-mail-ad')), findsNothing);
      expect(find.text(l.contactReportTitle), findsOneWidget);
      expect(find.text(l.contactResponseNote), findsOneWidget);
      expect(find.text(l.contactPrivacyPolicy), findsOneWidget);
    });
  }

  testWidgets('test build (partner ads on) shows the advertising section', (
    tester,
  ) async {
    _Fakes(tester);
    await _openContact(tester, partnerAds: true);
    final l = _l(tester);
    expect(find.text(l.contactAdTitle), findsOneWidget);
    expect(find.byKey(const ValueKey('contact-mail-ad')), findsOneWidget);
  });

  testWidgets('reachable from Profile without a server', (tester) async {
    _Fakes(tester);
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 3200));
    await goTo(tester, '/profile');
    final l = _l(tester);
    expect(s.backend.isConfigured, isFalse);
    // D-68 Q6: Profil → “Yordam va aloqa” → email/shikoyat.
    expect(find.text(l.contactRowTitle), findsNothing);
    await tester.tap(find.text(l.helpTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.contactRowTitle));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('contact-email')), findsOneWidget);
  });

  // Audit 2026-10-18 (tablar): ro'yxatdan o'tishda "shartlar va maxfiylik
  // siyosatini qabul qilaman" belgisi bor, lekin "Foydalanish shartlari" va
  // Profil → "Maxfiylik va ma'lumotlar" sahifalarida siyosatning o'ziga
  // havola yo'q edi (faqat "Aloqa" ichida).
  for (final (route, key) in [
    ('/profile/privacy', 'privacy-policy-link'),
    ('/terms', 'terms-privacy-link'),
  ]) {
    testWidgets('audit: $route links to the privacy policy', (tester) async {
      final fakes = _Fakes(tester);
      final s = await makeServices(tester, language: AppLanguage.ru);
      await pumpApp(tester, s, size: const Size(360, 640), textScale: 1.3);
      await goTo(tester, route);
      final row = find.byKey(ValueKey(key));
      await tester.scrollUntilVisible(row, 200);
      await tester.pumpAndSettle();
      expect(find.text(_l(tester).contactPrivacyPolicy), findsOneWidget);
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(fakes.launched, [Contact.privacyPolicyUrl]);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('copy button puts the email on the clipboard', (tester) async {
    final f = _Fakes(tester);
    await _openContact(tester);
    await tester.tap(find.byKey(const ValueKey('contact-copy')));
    await tester.pumpAndSettle();
    expect(f.clip, Contact.email);
    expect(find.text(_l(tester).contactCopied), findsOneWidget);
  });

  testWidgets('mail buttons launch well-formed mailto links', (tester) async {
    final f = _Fakes(tester);
    await _openContact(tester, partnerAds: true);
    final expected = {
      'contact-mail-question': Contact.subjectQuestion,
      'contact-mail-ad': Contact.subjectAd,
      'contact-mail-report': Contact.subjectReport,
    };
    for (final e in expected.entries) {
      await tester.tap(find.byKey(ValueKey(e.key)));
      await tester.pumpAndSettle();
    }
    expect(f.launched, hasLength(3));
    for (final (i, e) in expected.entries.indexed) {
      final raw = f.launched[i];
      final u = Uri.parse(raw);
      expect(u.scheme, 'mailto');
      expect(u.path, Contact.email);
      expect(raw, contains('subject=${Uri.encodeComponent(e.value)}'));
      expect(raw, isNot(contains('+')));
      expect(u.queryParameters['subject'], e.value);
      final body = u.queryParameters['body']!;
      // Faqat versiya va platforma; hech qanday shaxsiy ma'lumot yo'q.
      expect(body, contains('LabGuide '));
      expect(body, contains('android'));
      expect(body, isNot(contains('@')));
    }
    // Shikoyat xati bo'lim/karta nomini so'raydi.
    final report = Uri.parse(f.launched[2]).queryParameters['body']!;
    expect(report, contains('/'));
    expect(f.clip, isNull);
  });

  for (final result in [false, null]) {
    testWidgets('no mail app (${result ?? 'platform error'}) → copies', (
      tester,
    ) async {
      final f = _Fakes(tester, launchResult: result);
      await _openContact(tester);
      await tester.tap(find.byKey(const ValueKey('contact-mail-question')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(f.clip, Contact.email);
      expect(find.text(_l(tester).contactNoMailApp), findsOneWidget);
    });
  }

  testWidgets('partner form link only when a server is configured', (
    tester,
  ) async {
    _Fakes(tester);
    await _openContact(tester, partnerAds: true);
    expect(find.byKey(const ValueKey('contact-partner-link')), findsNothing);
  });

  testWidgets('store build: no partner form link even with a server', (
    tester,
  ) async {
    _Fakes(tester);
    await _openContact(tester, backend: FakeLabBackend());
    expect(find.byKey(const ValueKey('contact-partner-link')), findsNothing);
  });

  testWidgets('partner form link opens Hamkor bo‘lish when available', (
    tester,
  ) async {
    _Fakes(tester);
    await _openContact(tester, backend: FakeLabBackend(), partnerAds: true);
    final link = find.byKey(const ValueKey('contact-partner-link'));
    expect(link, findsOneWidget);
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.text(_l(tester).partnerBecome), findsWidgets);
    expect(find.byKey(const ValueKey('contact-email')), findsNothing);
  });

  for (final lang in AppLanguage.values) {
    for (final (width, scale) in [(320.0, 1.3), (320.0, 2.0), (390.0, 1.3)]) {
      testWidgets('layout: ${lang.name} ${width.toInt()}px ×$scale', (
        tester,
      ) async {
        _Fakes(tester);
        await _openContact(
          tester,
          lang: lang,
          size: Size(width, 3600),
          textScale: scale,
          backend: FakeLabBackend(),
          partnerAds: true,
        );
        expect(tester.takeException(), isNull);
        expect(find.byKey(const ValueKey('contact-email')), findsOneWidget);
        expect(find.byKey(const ValueKey('contact-copy')), findsOneWidget);
        // Gorizontal skroll yo'q: hech narsa ekran kengligidan chiqmaydi.
        final copy = tester.getRect(find.byKey(const ValueKey('contact-copy')));
        expect(copy.right, lessThanOrEqualTo(width));
        expect(copy.left, greaterThanOrEqualTo(0));
      });
    }
  }
}
