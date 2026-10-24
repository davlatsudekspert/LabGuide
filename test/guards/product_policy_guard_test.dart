// Qorovul (guard) testlari: egasining mahsulot qarorlari.
//
// D-58 (Pro/to'lov yo'q), hamkor reklamasi o'chiq, maxfiylik havolasi,
// hamjamiyat qoidalari (NCII, so'z filtri xabari), hisobni o'chirish,
// mavzu (Klassik standart + Ivory). Jadval: docs/GUARDS.md.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Brightness;

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/build_flags.dart';
import 'package:labguide/core/contact.dart';
import 'package:labguide/design/themes.dart';

String _read(String path) => File(path).readAsStringSync();

Map<String, String> _arb(String lang) => {
  for (final e in (jsonDecode(
    _read('lib/l10n/app_$lang.arb'),
  ) as Map).cast<String, Object?>().entries)
    if (!e.key.startsWith('@') && e.value is String) e.key: e.value! as String,
};

Iterable<File> _libDart() =>
    Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.replaceAll(r'\', '/').contains('lib/l10n/gen/'));

/// To'lov / obuna / Pro so'zlari (uz, ru, en). Kirill uchun `\b` ishlamaydi
/// (Dart RegExp `\b` — ASCII), shuning uchun o'zaklar.
final _payWords = RegExp(
  r'\bpro\b|subscri|purchas|obuna|подписк|покупк|paywall|premium|премиум|'
  r"to['‘ʼ’]?lov|оплат|(?<!бес)платн|payment|\bprices?\b|\bnarx|тариф|"
  r"\btarif|\$\s?\d|\d\s?(usd|so['‘ʼ’]m|сум)\b",
  caseSensitive: false,
);

/// Kontent holati emas, balki boshqa narsa haqida (2026-10-18):
/// * hamkor (reklama) narxi — reklama UI do'kon buildida kompilyatsiyadan
///   chiqarilgan (LG_PARTNER_ADS=false), hamkor bilan kelishuv haqida;
/// * admin paneli statistikasi — "Sotuvlar: 0 (to'lov yo'q)".
const _payAllow = {'partnerPriceTitle', 'partnerPriceBody', 'admSales'};

void main() {
  // pro-next (D-71): Pro kodi mavjud, lekin `BuildFlags.proEnabled == false`
  // (standart) bo'lganda ilova D-58 bilan bir xil — paywall yo'q. `main` dagi
  // qat'iy D-58 qorovuli bu yerda "bayroq ortidagi Pro" qorovuliga aylandi.
  group(
    'D-58/D-71: proEnabled=false bo‘lsa ilovada Pro / to‘lov / obuna yo‘q',
    () {
      test('standart: Pro bayrog‘i o‘chiq', () {
        BuildFlags.debugProEnabledOverride = null;
        expect(BuildFlags.proEnabled, isFalse);
      });

      test(
        'ARB: `pro*` kalitlaridan tashqari matnlarda to‘lov so‘zlari yo‘q',
        () {
          for (final lang in ['uz', 'ru', 'en']) {
            final bad = [
              for (final e in _arb(lang).entries)
                if (!e.key.startsWith('pro') &&
                    !_payAllow.contains(e.key) &&
                    _payWords.hasMatch(e.value))
                  '${e.key}: ${e.value}',
            ];
            expect(bad, isEmpty, reason: lang);
          }
        },
      );

      test('`pro*` kalitlari uch tilda bir xil; ichida narx raqami yo‘q', () {
        final keys = {
          for (final lang in ['uz', 'ru', 'en'])
            lang: _arb(lang).keys.where((k) => k.startsWith('pro')).toSet(),
        };
        expect(keys['uz'], isNotEmpty);
        expect(keys['ru'], keys['uz']);
        expect(keys['en'], keys['uz']);
        for (final lang in ['uz', 'ru', 'en']) {
          for (final e in _arb(
            lang,
          ).entries.where((e) => e.key.startsWith('pro'))) {
            expect(
              RegExp(
                r"\$\s?\d|\d\s?(usd|so['‘ʼ’]m|сум)\b",
                caseSensitive: false,
              ).hasMatch(e.value),
              isFalse,
              reason: '$lang ${e.key}: narx ilovada qotirilmaydi',
            );
          }
        }
      });

      test(
        'ruxsat ro‘yxatidagi kalitlar hali mavjud (eskirgan istisno yo‘q)',
        () {
          final uz = _arb('uz');
          for (final k in _payAllow) {
            expect(uz.containsKey(k), isTrue, reason: k);
          }
        },
      );

      test('Pro kodi faqat ruxsat etilgan fayllarda (oqib chiqmasin)', () {
        // Pro qatlami shu fayllarda; boshqa hech qaysi lib/ fayli xarid
        // plaginiga, paywall/ProScreen/isPro ga tegmaydi.
        const allowed = [
          'lib/core/entitlements/',
          'lib/features/profile/purchase_screen.dart',
          'lib/features/profile/pro_gate.dart',
        ];
        final code = RegExp(
          r'in_app_purchase|purchases_flutter|InAppPurchase|SKPayment|'
          r'Paywall|ProScreen|ProPlan|isPro\b|proUnlocked|subscriptionStatus',
        );
        for (final f in _libDart()) {
          final path = f.path.replaceAll(r'\', '/');
          if (allowed.any(path.contains)) continue;
          final m = code.firstMatch(f.readAsStringSync());
          expect(m, isNull, reason: '${f.path}: ${m?[0]}');
        }
      });

      test('xarid plaginlari faqat in_app_purchase* (boshqa SDK yo‘q)', () {
        final pubspec = _read('pubspec.yaml');
        for (final p in [
          'purchases_flutter',
          'revenuecat',
          'flutter_inapp_purchase',
          'pay:',
        ]) {
          expect(pubspec.contains(p), isFalse, reason: p);
        }
      });

      test('plagin faqat entitlements/ da import qilinadi va main.dart faqat '
          'bayroq ortida ishga tushiradi', () {
        for (final f in _libDart()) {
          final path = f.path.replaceAll(r'\', '/');
          if (path.startsWith('lib/core/entitlements/')) continue;
          expect(
            f.readAsStringSync().contains('package:in_app_purchase'),
            isFalse,
            reason: path,
          );
        }
        final main = _read('lib/main.dart');
        expect(
          main,
          contains(
            'if (BuildFlags.proEnabled) unawaited(services.entitlements.start());',
          ),
        );
        expect(
          main,
          contains('BuildFlags.proEnabled\n        ? EntitlementService('),
        );
        expect(main, contains(': EntitlementService.disabled()'));
      });

      test(
        'marshrut: /profile/purchase faqat `if (BuildFlags.proEnabled)` ichida',
        () {
          final router = _read('lib/app/router.dart');
          expect(
            RegExp(
              r"if \(BuildFlags\.proEnabled\)\s+GoRoute\(\s+path: 'purchase'",
            ).hasMatch(router),
            isTrue,
          );
          expect(RegExp(r"path: 'purchase'").allMatches(router), hasLength(1));
          for (final p in [
            "path: 'pro'",
            "'/pro'",
            'paywall',
            'subscription',
            'billing',
          ]) {
            expect(router.contains(p), isFalse, reason: p);
          }
        },
      );

      test('Profil: obuna qatori `BuildFlags.proEnabled` ortida', () {
        final profile = _read('lib/features/profile/profile_screens.dart');
        expect(
          RegExp(r'if \(BuildFlags\.proEnabled &&\s+\(ent\.purchasesEnabled')
              .hasMatch(profile),
          isTrue,
        );
      });

      test('iOS: In-App Purchase imkoniyati yoqilmagan', () {
        for (final path in [
          'ios/Runner/Runner.entitlements',
          'ios/Runner/Info.plist',
        ]) {
          final f = File(path);
          if (!f.existsSync()) continue;
          expect(f.readAsStringSync(), isNot(contains('in-app-payments')));
        }
      });
    },
  );

  group('hamkor reklamasi (LG_PARTNER_ADS)', () {
    test('standart build: bayroq o‘chiq, release buildda o‘zgarmas', () {
      expect(kPartnerAds, isFalse);
      BuildFlags.debugPartnerAdsOverride = null;
      expect(BuildFlags.partnerAds, isFalse);
      final src = _read('lib/core/build_flags.dart');
      expect(
        src,
        contains(
          "const bool kPartnerAds = bool.fromEnvironment('LG_PARTNER_ADS');",
        ),
        reason: 'standart qiymat (defaultValue) qo‘shilmasin',
      );
      expect(src, contains('kReleaseMode ? kPartnerAds'));
    });
  });

  group('maxfiylik va aloqa', () {
    test('maxfiylik siyosati havolasi — labguide.nfcstore.uz/privacy/', () {
      expect(Contact.privacyPolicyUrl, 'https://labguide.nfcstore.uz/privacy/');
      expect(Contact.email, 'labguide@nfcstore.uz');
      expect(
        _read('lib/features/profile/contact_screen.dart'),
        contains('Contact.privacyPolicyUrl'),
      );
      // Audit 2026-10-18 (tablar): Profil → Maxfiylik va Foydalanish
      // shartlari sahifalarida ham siyosat havolasi bor.
      expect(
        _read('lib/features/profile/profile_screens.dart'),
        contains('Contact.privacyPolicyUrl'),
      );
      expect(
        _read('lib/features/auth/ui/auth_screens.dart'),
        contains('Contact.privacyPolicyUrl'),
      );
    });

    test('hisobni o‘chirish ilovada bor (Apple 5.1.1(v), D-63)', () {
      final uz = _arb('uz');
      expect(uz['accountDelete'], 'Hisobni o‘chirish');
      expect(
        _read('lib/features/profile/profile_screens.dart'),
        contains('l.accountDelete'),
      );
    });
  });

  group('hamjamiyat (D-62, Apple 1.2)', () {
    test('qoidalarda NCII (intim rasmlar) taqiqi — uch tilda', () {
      expect(_arb('uz')['cmRulesC2'], contains('roziligisiz'));
      expect(_arb('uz')['cmRulesC2'], contains('intim'));
      expect(_arb('ru')['cmRulesC2'], contains('интимных'));
      expect(_arb('ru')['cmRulesC2'], contains('без согласия'));
      expect(_arb('en')['cmRulesC2'], contains('intimate'));
      expect(_arb('en')['cmRulesC2'], contains('without the person’s consent'));
      expect(
        _read('lib/features/community/community_rules.dart'),
        contains('l.cmRulesC2'),
      );
    });

    test('so‘z filtri xatosi tushunarli matnga aylanadi', () {
      for (final lang in ['uz', 'ru', 'en']) {
        expect(_arb(lang)['cmErrAbusive'], isNotEmpty, reason: lang);
      }
      final screens = _read('lib/features/community/community_screens.dart');
      expect(screens, contains("'abusive_language'"));
      expect(screens, contains('l.cmErrAbusive'));
      expect(File('cloudflare/data/abuse_words.json').existsSync(), isTrue);
    });
  });

  group('mavzu (D-64)', () {
    test('Klassik standart, Ivory mavjud', () {
      expect(LgThemeId.values.map((t) => t.name), ['classic', 'ivory']);
      expect(LgThemeId.tryParse('nonsense'), isNull);
      final settings = _read('lib/features/settings/settings_controller.dart');
      expect(RegExp(r'\?\?\s*LgThemeId\.classic').hasMatch(settings), isTrue);
      for (final b in Brightness.values) {
        expect(LgThemeId.classic.palette(b), isNotNull);
        expect(LgThemeId.ivory.palette(b), isNotNull);
      }
    });
  });
}
