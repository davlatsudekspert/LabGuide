// Qorovul (D-71): Pro qatlami standart holda O'CHIQ. Bu fayl buzilsa — pro-next
// dagi kod bepul relizga tasodifan "yoqilgan" holda tushishi mumkin.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/build_flags.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  group('D-71: Pro standart holda o‘chiq', () {
    test('kProEnabled va BuildFlags.proEnabled standart false', () {
      expect(kProEnabled, isFalse);
      BuildFlags.debugProEnabledOverride = null;
      expect(BuildFlags.proEnabled, isFalse);
    });

    test('bayroq manbasi: defaultValue yo‘q, release buildda o‘zgarmas', () {
      final src = _read('lib/core/build_flags.dart');
      expect(
        src,
        contains(
          "const bool kProEnabled = bool.fromEnvironment('LG_PRO_ENABLED');",
        ),
        reason: 'standart qiymat (defaultValue: true) qo‘shilmasin',
      );
      expect(src, contains('kReleaseMode ? kProEnabled'));
    });

    test('CI/skriptlar LG_PRO_ENABLED ni yoqmaydi', () {
      for (final dir in ['.github', 'tool', 'scripts']) {
        final d = Directory(dir);
        if (!d.existsSync()) continue;
        for (final f
            in d
                .listSync(recursive: true)
                .whereType<File>()
                .where(
                  (f) =>
                      RegExp(r'\.(ya?ml|sh|py|dart|json|toml)$')
                          .hasMatch(f.path),
                )) {
          final text = f.readAsStringSync();
          expect(
            RegExp(r'LG_PRO_ENABLED\s*=\s*true').hasMatch(text),
            isFalse,
            reason: f.path,
          );
        }
      }
    });

    test('hech qaysi imkoniyat yopilmaydi; bepul davr o‘chiq', () {
      expect(ProGatePolicy.gated, isEmpty);
      expect(ProTrialConfig.freeTrialDays, isNull);
      expect(ProTrialConfig.enabled, isFalse);
      expect(ProTrialConfig.mechanism, ProTrialMechanism.undecided);
    });

    test('narx katalogi: egasi narxlari (D-73), uch daraja, yillik bor', () {
      final byPlan = {for (final p in ProPricing.plans) p.plan: p};
      expect(byPlan.keys.toSet(), ProPlan.values.toSet());
      expect(ProPricing.plans, hasLength(3));
      expect(byPlan[ProPlan.student]!.monthlyUsd, 1.49);
      expect(byPlan[ProPlan.student]!.yearlyUsd, 9.99);
      expect(byPlan[ProPlan.teacher]!.monthlyUsd, 2.49);
      expect(byPlan[ProPlan.teacher]!.yearlyUsd, 24.99);
      expect(byPlan[ProPlan.specialist]!.monthlyUsd, 3.49);
      expect(byPlan[ProPlan.specialist]!.yearlyUsd, 34.99);
      for (final p in ProPricing.plans) {
        expect(p.annualOffered, isTrue, reason: p.yearlyProductId);
        expect(ProPricing.yearlyOffered(p.yearlyProductId), isTrue);
        // Yillik oylikdan arzon (yillik taklif mantiqi).
        expect(p.yearlyUsd!, lessThan(p.monthlyUsd * 12));
      }
    });

    test('hech qaysi bepul imkoniyat yopilmaydi (gated faqat pullik daraja)', () {
      for (final f in Feature.values.where((f) => !f.pro)) {
        expect(ProGatePolicy.gated.contains(f), isFalse, reason: f.name);
      }
      expect(ProGatePolicy.gated, isEmpty);
    });

    test('admin grant: Pro bayrog‘isiz xizmat yo‘q, yo‘l yo‘q', () {
      BuildFlags.debugProEnabledOverride = null;
      expect(BuildFlags.proEnabled, isFalse);
      final scope = _read('lib/app/app_scope.dart');
      expect(
        scope,
        contains('BuildFlags.proEnabled && backend is ProGrantBackend'),
      );
      final router = _read('lib/app/router.dart');
      expect(
        RegExp(
          r"if \(BuildFlags\.proEnabled\)\s*GoRoute\(\s*path: 'pro-grants'",
        ).hasMatch(router),
        isTrue,
        reason: '/profile/admin/pro-grants faqat bayroq ortida',
      );
      // Admin paneldagi qator ham faqat `services.proGrants != null` da.
      final admin = _read('lib/features/admin/admin_screens.dart');
      expect(
        RegExp(
          r"if \(services\.proGrants != null\)\s*LgRow\(\s*key: const ValueKey\('admin-row-pro-grants'\)",
        ).allMatches(admin).length,
        2,
        reason: 'ikkala panel ko‘rinishida ham shartli',
      );
    });

    test('server: admin grant yo‘llari LG_BILLING_ENABLED ortida (404)', () {
      final app = _read('cloudflare/src/app.ts');
      expect(app, contains('!billingEnabled(env)'));
      expect(app, contains(r'/v1\/admin\/pro-grants'));
      // Yo'llar faqat billingRoutes ichida e'lon qilingan.
      final billing = app.substring(
        app.indexOf('const billingRoutes'),
        app.indexOf('export { billingEnabled }'),
      );
      expect(billing, contains("'/v1/admin/pro-grants'"));
      final others = app.replaceFirst(billing, '');
      expect(others.contains("r('GET', '/v1/admin/pro-grants'"), isFalse);
      expect(others.contains("r('POST', '/v1/admin/pro-grants'"), isFalse);
      expect(
        _read('cloudflare/src/http.ts'),
        contains("env.LG_BILLING_ENABLED === 'true'"),
      );
    });

    test('eski narxlar va 7/14 kunlik sinov hech qayerda faol emas', () {
      final old = RegExp(
        r'29[  ]?000|\$\s?4\.99|\$\s?6\.99|\$\s?46\.99|\b9[  ]000\s*so|'
        r'(?<![\d.])3\.99(?!\d)|(?<![\d.])5\.99(?!\d)',
      );
      final files = [
        ...Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  (f.path.endsWith('.dart') &&
                      !f.path
                          .replaceAll(r'\', '/')
                          .contains('lib/l10n/gen/')) ||
                  f.path.endsWith('.arb'),
            ),
        File('cloudflare/src/billing.ts'),
        File('cloudflare/migrations/0013_billing.sql'),
        File('cloudflare/migrations/0014_pro_grants.sql'),
        File('cloudflare/src/progrants.ts'),
      ];
      for (final f in files) {
        final m = old.firstMatch(f.readAsStringSync());
        expect(m, isNull, reason: '${f.path}: ${m?[0]}');
      }
      // Kodda sinov kunlari qotirilmagan (do'kondan o'qiladi).
      final trial = RegExp(
        r'StorePeriod\(\s*(7|14)\s*,\s*StorePeriodUnit\.day',
      );
      for (final f
          in Directory('lib')
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))) {
        expect(trial.hasMatch(f.readAsStringSync()), isFalse, reason: f.path);
      }
    });
  });
}
