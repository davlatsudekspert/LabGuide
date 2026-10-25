// Qorovul (guard) testlari: D-77 (2026-10-25, egasi qarori) — FAQAT
// `paid/pro-premium` tarmog'i. Free + Pro + Premium, bepul sinov faqat 7 kun,
// do'kondagi bepul versiya o'zgarmaydi, hech narsa egasining ruxsatisiz
// nashr qilinmaydi. D-58 qorovuli (“ilovada Pro/to'lov yo'q”) shu tarmoqda
// shu fayl bilan almashtirildi (D-58 `main` da kuchda).
//
// (a) build bayroqlarining standart holati aniq va tekshirilgan;
// (b) ARB / lib da narx literali yo'q (narx do'kondan; ma'lumot — ProPricing);
// (c) sinov uzunligi hamma joyda 7 (Dart, TypeScript, ARB, hujjat); eski
//     30 kunlik sinov matni faqat SUPERSEDED tarixda;
// (d) do'kon talablari asoslari: tiklash tugmasi, xariddan oldin narx+davr,
//     tashqi to'lov havolasi yo'q.
// Jadval: docs/GUARDS.md.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/build_flags.dart';
import 'package:labguide/core/contact.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/entitlement_service.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/billing_fakes.dart';
import '../helpers/harness.dart';

String _read(String path) => File(path).readAsStringSync();

String _norm(String path) => path.replaceAll(r'\', '/');

Map<String, String> _arb(String lang) => {
  for (final e in (jsonDecode(
    _read('lib/l10n/app_$lang.arb'),
  ) as Map).cast<String, Object?>().entries)
    if (!e.key.startsWith('@') && e.value is String) e.key: e.value! as String,
};

const _langs = ['uz', 'ru', 'en'];

Iterable<File> _files(String dir, RegExp ext) {
  final d = Directory(dir);
  if (!d.existsSync()) return const [];
  return d
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => ext.hasMatch(f.path))
      .where((f) {
        final p = _norm(f.path);
        return !p.contains('/node_modules/') &&
            !p.contains('/.dart_tool/') &&
            !p.contains('/build/') &&
            !p.contains('/__pycache__/') &&
            !p.startsWith('lib/l10n/gen/');
      });
}

/// lib/ dagi Dart fayllar (generatsiya qilingan l10n dan tashqari).
Iterable<File> _libDart() => _files('lib', RegExp(r'\.dart$'));

/// Egasi narxlari (D-73/D-76) va eski taklif narxlari (D-70/D-71/D-57).
final _ownerPrices = RegExp(
  r'(?<![\d.])(1\.49|9\.99|2\.49|24\.99|3\.49|34\.99|4\.99|49\.99|3\.99|5\.99|6\.99)(?!\d)',
);

/// Valyuta bilan yozilgan narx: Dart manbasida `\$4` (oddiy satrda `$` ni
/// ekranlash shart), `4 USD`, `12 000 so'm`, `сум`.
final _dartCurrency = RegExp(
  r"\\\$\s?\d|\d\s?(USD|UZS)\b|\b(USD|UZS)\s?\d|\d\s?so['‘ʼ’]m\b|\d\s?сум(?![а-яё])",
);

/// ARB matnidagi narx (`$4.99`, `4.99 USD`, `12 000 so'm`, `€5`).
final _arbPrice = RegExp(
  r"[$€£]\s?\d|\d\s?(usd|uzs|so['‘ʼ’]m)\b|\d\s?сум(?![а-яё])|\b(usd|uzs)\s?\d|"
  r'\d+[.,]\d{2}\s?(\$|usd)',
  caseSensitive: false,
);

/// Eski (SUPERSEDED) uzun sinov: “30 kunlik sinov”, “30-day trial”,
/// “пробный период 30 дней”, `TRIAL_DAYS = 30`.
final _trial30 = RegExp(
  r'(?<!\d)30[\s\-–]*(kun|days?|дн)[^\n]{0,40}?(sinov|trial|пробн|bepul foydalan|free access|бесплатн)|'
  r'(sinov|trial|пробн)[^\n.]{0,30}?(?<!\d)30[\s\-–]*(kun|days?|дн)|'
  r'(TRIAL_DAYS|serverTrialDays|freeTrialDays|trialDays)\s*[=:]\s*30\b',
  caseSensitive: false,
);

/// Qatorning o'zi eskirganini aytadi.
final _supersededLine = RegExp(
  r'SUPERSEDED|bekor|eskir|ESKIR|almashtiril|отмен|устар|\bEMAS\b',
  caseSensitive: false,
);

/// Qoidani o'zi ta'riflaydigan fayllar (rad etilishi kerak bo'lgan namunalar).
const _ruleFiles = {
  'tool/site/check_site.py',
  'test/guards/paid_policy_d77_guard_test.dart',
};

/// Markdown: fayl boshida (12 qator) yoki bo'lim sarlavhasi + keyingi 4
/// qatorda “SUPERSEDED” bo'lsa — tarix.
List<String> _trial30Outside(File f) {
  final path = _norm(f.path);
  if (_ruleFiles.contains(path)) return const [];
  final lines = f.readAsLinesSync();
  final md = path.endsWith('.md');
  final fileIsHistory =
      md && lines.take(12).any((l) => l.contains('SUPERSEDED'));
  var sectionIsHistory = false;
  final bad = <String>[];
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (md && line.startsWith('#')) {
      sectionIsHistory = lines
          .skip(i)
          .take(5)
          .any((l) => l.contains('SUPERSEDED'));
    }
    if (!_trial30.hasMatch(line)) continue;
    if (_supersededLine.hasMatch(line)) continue;
    if (fileIsHistory || sectionIsHistory) continue;
    bad.add('$path:${i + 1}: ${line.trim()}');
  }
  return bad;
}

void main() {
  group('D-77 (a): build bayroqlarining standart holati aniq', () {
    test('ilova bayroqlari: hammasi standart O‘CHIQ', () {
      BuildFlags.debugProEnabledOverride = null;
      BuildFlags.debugPartnerAdsOverride = null;
      // Bayroq → standart (do'kon buildi, hech qanday --dart-define yo'q).
      final defaults = <String, bool>{
        'LG_PRO_ENABLED': kProEnabled,
        'LG_FAKE_PURCHASES': kFakePurchasesRequested,
        'LG_PARTNER_ADS': kPartnerAds,
        'LG_ALL_FEATURES_OPEN': EntitlementService.buildAllFeaturesOpen,
        'proEnabled': BuildFlags.proEnabled,
        'fakePurchases': BuildFlags.fakePurchases,
        'partnerAds': BuildFlags.partnerAds,
        'storeIntroOffersAllowed': ProTrialConfig.storeIntroOffersAllowed,
        'storeTrialEnabled': ProTrialConfig.enabled,
      };
      expect(defaults.values.where((v) => v), isEmpty, reason: '$defaults');
      expect(ProGatePolicy.gated, isEmpty, reason: 'hech narsa yopilmaydi');
      expect(ProTrialConfig.freeTrialDays, isNull);
    });

    test('bool bayroqlar ro‘yxati to‘liq va hech birida defaultValue yo‘q', () {
      // Yangi bayroq qo'shilsa — shu ro'yxatga (va D-77 jadvaliga) yoziladi.
      const known = {
        'LG_PARTNER_ADS',
        'LG_PRO_ENABLED',
        'LG_FAKE_PURCHASES',
        'LG_ALL_FEATURES_OPEN',
        'LG_APPLE_SIGNIN',
      };
      final rx = RegExp(r"bool\.fromEnvironment\(\s*'([A-Z_]+)'\s*(,[^)]*)?\)");
      final found = <String>{};
      for (final f in _libDart()) {
        for (final m in rx.allMatches(f.readAsStringSync())) {
          found.add(m[1]!);
          final rest = m[2] ?? '';
          expect(
            rest.contains('defaultValue'),
            isFalse,
            reason: '${f.path}: ${m[1]} standart qiymati yashirin',
          );
        }
      }
      expect(found, known);
    });

    test(
      'server: LG_BILLING_ENABLED / SANDBOX / TRIAL_PLATFORMS o‘rnatilmagan',
      () {
        final toml = _read('cloudflare/wrangler.toml');
        for (final v in [
          'LG_BILLING_ENABLED',
          'LG_BILLING_SANDBOX',
          'TRIAL_PLATFORMS',
        ]) {
          expect(
            RegExp('^\\s*$v\\s*=', multiLine: true).hasMatch(toml),
            isFalse,
            reason: 'wrangler.toml: $v',
          );
        }
        expect(
          _read('cloudflare/src/http.ts'),
          contains(
            "export const billingEnabled = (env: Env) => env.LG_BILLING_ENABLED === 'true';",
          ),
        );
        // CI / skriptlar billingni yoqmaydi.
        for (final f in [
          ..._files('.github', RegExp(r'\.ya?ml$')),
          ..._files('tool', RegExp(r'\.(sh|py)$')),
        ]) {
          expect(
            RegExp(r'LG_BILLING_ENABLED\s*[=:]\s*"?true')
                .hasMatch(f.readAsStringSync()),
            isFalse,
            reason: f.path,
          );
        }
      },
    );

    testWidgets('standart servislar: Pro o‘chirilgan, hamma imkoniyat ochiq', (
      tester,
    ) async {
      final s = await makeServices(tester);
      expect(BuildFlags.proEnabled, isFalse);
      for (final f in Feature.values) {
        expect(s.entitlements.can(f), isTrue, reason: f.name);
      }
      // O'chirilgan servis: do'kon ham, server ham yo'q, yopish ro'yxati bo'sh.
      expect(s.entitlements.gated, isEmpty);
      expect(s.entitlements.purchasesEnabled, isFalse);
      expect(s.entitlements.offeredProducts, isEmpty);
      expect(s.proGrants, isNull);
    });
  });

  group('D-77 (b): narx literali faqat ProPricing da', () {
    test('lib/: egasi narxlari faqat pro_catalog.dart da', () {
      for (final f in _libDart()) {
        final path = _norm(f.path);
        if (path == 'lib/core/entitlements/pro_catalog.dart') continue;
        final text = f.readAsStringSync();
        final m =
            _ownerPrices.firstMatch(text) ?? _dartCurrency.firstMatch(text);
        expect(m, isNull, reason: '$path: ${m?[0]}');
      }
    });

    test('ARB: hech bir matnda narx yo‘q (uz/ru/en)', () {
      for (final lang in _langs) {
        final bad = [
          for (final e in _arb(lang).entries)
            if (_arbPrice.hasMatch(e.value) || _ownerPrices.hasMatch(e.value))
              '${e.key}: ${e.value}',
        ];
        expect(bad, isEmpty, reason: lang);
      }
    });

    test('server manbasida narx yo‘q (faqat mahsulot id)', () {
      for (final f in _files('cloudflare/src', RegExp(r'\.ts$'))) {
        final m = _ownerPrices.firstMatch(f.readAsStringSync());
        expect(m, isNull, reason: '${f.path}: ${m?[0]}');
      }
    });

    test(
      'ProPricing — D-76 narxlari; id va narx UNCONFIRMED (do‘konda yo‘q)',
      () {
        final usd = {
          for (final p in ProPricing.plans) p.plan: (p.monthlyUsd, p.yearlyUsd),
        };
        expect(usd, {
          ProPlan.student: (1.49, 9.99),
          ProPlan.teacher: (2.49, 24.99),
          ProPlan.specialist: (3.49, 34.99),
          ProPlan.premium: (4.99, 49.99),
        });
        for (final path in [
          'lib/core/entitlements/pro_catalog.dart',
          'lib/core/entitlements/billing_catalog.dart',
        ]) {
          expect(
            _read(path),
            contains('UNCONFIRMED-until-created-in-store'),
            reason: path,
          );
        }
      },
    );
  });

  group('D-77 (c): sinov uzunligi hamma joyda 7', () {
    test('Dart, TypeScript va server testi: 7', () {
      expect(ProTrialConfig.serverTrialDays, 7);
      expect(
        _read('lib/core/entitlements/pro_catalog.dart'),
        contains('static const int serverTrialDays = 7;'),
      );
      expect(
        _read('cloudflare/src/trial.ts'),
        contains('export const TRIAL_DAYS = 7;'),
      );
      expect(
        _read('cloudflare/test/trial.test.ts'),
        contains('expect(TRIAL_DAYS).toBe(7);'),
      );
    });

    test('ARB: sinov matnidagi har bir son — 7 (uz/ru/en)', () {
      final days = {
        'uz': RegExp(r'(\d+)\s*kunlik\s+(bepul\s+)?sinov'),
        'ru': RegExp(r'пробн\S*\s+период\S*\s+(на\s+)?(\d+)\s*дн'),
        'en': RegExp(r'(\d+)-day\s+(free\s+)?trial', caseSensitive: false),
      };
      for (final lang in _langs) {
        final arb = _arb(lang);
        final rx = days[lang]!;
        final note = arb['proPrivacyTrialNote']!;
        expect(rx.hasMatch(note), isTrue, reason: '$lang proPrivacyTrialNote');
        for (final e in arb.entries) {
          for (final m in rx.allMatches(e.value)) {
            final n = lang == 'ru' ? m[2] : m[1];
            expect(n, '7', reason: '$lang ${e.key}: ${e.value}');
          }
        }
      }
    });

    test(
      'D-77 qarori yozilgan: 7 kun, D-58 faqat shu tarmoqda almashtirildi',
      () {
        final decisions = _read('docs/DECISIONS.md');
        final i = decisions.indexOf('## D-77.');
        expect(i, greaterThan(0));
        final d77 = decisions.substring(i);
        expect(d77, contains('2026-10-25'));
        expect(d77, contains('faqat 7 kun'));
        expect(d77, contains('D-58'));
        expect(d77, contains('UNCONFIRMED-until-created-in-store'));
        expect(d77, contains('ruxsatisiz hech narsa nashr qilinmaydi'));
      },
    );

    test(
      'eski uzun sinov matni faqat SUPERSEDED tarixda (kod, ARB, hujjat, sayt)',
      () {
        final ext = RegExp(
          r'\.(dart|ts|arb|md|html|sql|csv|json|py|ya?ml|txt)$',
        );
        final bad = [
          for (final dir in [
            'lib',
            'cloudflare/src',
            'cloudflare/migrations',
            'cloudflare/test',
            'test',
            'tool',
            'docs',
            'site',
            'supabase',
          ])
            for (final f in _files(dir, ext)) ..._trial30Outside(f),
        ];
        expect(bad, isEmpty, reason: bad.join('\n'));
      },
    );

    test('qorovulning o‘zi ishlaydi (namuna)', () {
      expect(_trial30.hasMatch('30 kunlik bepul sinov'), isTrue);
      expect(_trial30.hasMatch('a 30-day free trial'), isTrue);
      expect(_trial30.hasMatch('пробный период на 30 дней'), isTrue);
      expect(_trial30.hasMatch('TRIAL_DAYS = 30;'), isTrue);
      expect(_trial30.hasMatch('30 kun ichida o‘chiradi'), isFalse);
      expect(_trial30.hasMatch('Last 30 days'), isFalse);
      expect(_trial30.hasMatch('730 kun (24 oy) sinov yozuvi'), isFalse);
      expect(_supersededLine.hasMatch('D-75 dagi 30 kun bekor'), isTrue);
    });
  });

  group('D-77 (d): do‘kon talablari asoslari (iOS 3.1.1/3.1.2, Play)', () {
    test('tashqi to‘lov havolasi yo‘q: Pro ekranlaridagi URL lar ruxsat ro‘yxatida', () {
      const hosts = {
        'apps.apple.com',
        'www.apple.com',
        'play.google.com',
        'labguide.nfcstore.uz',
      };
      final url = RegExp(r'''https?://([^/'"\s)]+)''');
      for (final f in [
        ..._files('lib/core/entitlements', RegExp(r'\.dart$')),
        File('lib/features/profile/purchase_screen.dart'),
        File('lib/features/profile/subscription_screen.dart'),
        File('lib/features/profile/pro_gate.dart'),
      ]) {
        for (final m in url.allMatches(f.readAsStringSync())) {
          expect(hosts, contains(m[1]), reason: '${f.path}: ${m[0]}');
        }
      }
      expect(BillingLinks.privacyPolicy, Contact.privacyPolicyUrl);
      // Ilova va ARB da boshqa to'lov tizimlari / veb-to'lov yo'q.
      final providers = RegExp(
        r'stripe\.com|paypal\.|payme\.uz|click\.uz|uzum\.uz|paynet\.uz|'
        r'apelsin\.uz|oson\.uz|/checkout|buy\.labguide|'
        r'labguide\.nfcstore\.uz/(pay|buy|pro)|\b(Stripe|PayPal|Payme|Paynet)\b',
      );
      for (final f in _libDart()) {
        final m = providers.firstMatch(f.readAsStringSync());
        expect(m, isNull, reason: '${f.path}: ${m?[0]}');
      }
      for (final lang in _langs) {
        for (final e in _arb(lang).entries) {
          expect(
            providers.hasMatch(e.value),
            isFalse,
            reason: '$lang ${e.key}',
          );
        }
      }
    });

    test('tiklash tugmasi ikkala Pro ekranida ham bor (manba)', () {
      final pay = _read('lib/features/profile/purchase_screen.dart');
      expect(pay, contains('label: l.proPayRestore'));
      expect(pay, contains('_run(context, ent.restore, restore: true)'));
      final sub = _read('lib/features/profile/subscription_screen.dart');
      expect(sub, contains("key: const ValueKey('sub-restore')"));
      expect(sub, contains('await ent.restore()'));
    });

    testWidgets(
      'Pro yoqilgan build: narx va davr xarid tugmasidan OLDIN, tiklash va '
      'Obuna ekrani yetib boriladi',
      (tester) async {
        final uz = lookupAppLocalizations(const Locale('uz'));
        final s = await makeServices(
          tester,
          proEnabled: true,
          allFeaturesOpen: false,
          purchases: FakePurchaseAdapter(),
          entitlementSource: FakeEntitlementSource(),
        );
        await pumpApp(tester, s, size: const Size(390, 2400));
        await goTo(tester, '/profile/purchase');
        final products = s.entitlements.offeredProducts;
        expect(products, isNotEmpty);
        Finder list() => find.byType(Scrollable).hitTestable().first;
        for (final p in products) {
          final unit = p.catalog!.period == BillingPeriod.year
              ? uz.proPayUnitYear
              : uz.proPayUnitMonth;
          final price = find.text(uz.proPayPricePer(p.displayPrice, unit));
          await tester.scrollUntilVisible(price, 300, scrollable: list());
          expect(price, findsOneWidget, reason: p.id);
          final buy = find.descendant(
            of: find.ancestor(of: price, matching: find.byType(LgPanel)),
            matching: find.text(uz.proPaySubscribe),
          );
          expect(buy, findsOneWidget, reason: '${p.id}: tugma narx kartasida');
          expect(
            tester.getTopLeft(price).dy,
            lessThan(tester.getTopLeft(buy).dy),
            reason: '${p.id}: narx tugmadan yuqorida',
          );
        }
        final restore = find.text(uz.proPayRestore);
        await tester.scrollUntilVisible(restore, 300, scrollable: list());
        expect(restore, findsOneWidget);
        expect(find.text(uz.proPayDisclosure('App Store')), findsOneWidget);

        // Profil → “Obuna” → tiklash.
        await goTo(tester, '/profile');
        final row = find.byKey(const ValueKey('profile-subscription'));
        await tester.scrollUntilVisible(row, 300, scrollable: list());
        await tester.tap(row);
        await tester.pumpAndSettle();
        final subRestore = find.byKey(const ValueKey('sub-restore'));
        await tester.scrollUntilVisible(subRestore, 300, scrollable: list());
        expect(subRestore, findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
