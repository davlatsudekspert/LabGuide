// Qorovul (D-71): Pro qatlami standart holda O'CHIQ. Bu fayl buzilsa — pro-next
// dagi kod bepul relizga tasodifan "yoqilgan" holda tushishi mumkin.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/build_flags.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';

String _read(String path) => File(path).readAsStringSync();

/// D-78: pullik amal tekshiruvi (`requireFeature` / `pushGated` /
/// `allowOrOffer`) chaqiriladigan joylar — fayl → funksiyalar.
const kGateCallSites = <String, Set<String>>{
  // Ustoz Pro (yangi ekranlar): test yaratish/tahrir/saqlash, topshirish.
  'lib/features/teacher_pro/teacher_test_screens.dart': {
    'teacherTestBuilder',
    'teacherTestAssign',
  },
  // Topshirish va taklifnoma yaratish.
  'lib/features/teacher_pro/teacher_assign_screens.dart': {'teacherTestAssign'},
  // Natijalar CSV eksporti.
  'lib/features/teacher_pro/teacher_results_screens.dart': {'teacherResults'},
  // Talaba: Ustoz testini BOSHLASH (boshlangan urinish — tekshiruvsiz).
  'lib/features/teacher_pro/student_teacher_tests_screens.dart': {
    'teacherTests',
  },
};

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

    test(
      'gated faqat pullik katalogdan (D-78); do‘kon sinov taklifi yo‘q (D-75)',
      () {
        expect(ProGatePolicy.catalog.containsAll(ProGatePolicy.gated), isTrue);
        // Do'kon kirish taklifi (avtomatik pullikka o'tadi) — yo'q.
        expect(ProTrialConfig.freeTrialDays, isNull);
        expect(ProTrialConfig.enabled, isFalse);
        expect(ProTrialConfig.storeIntroOffersAllowed, isFalse);
        // 7 kunlik sinov (D-76; D-75 dagi 30 kun bekor) — faqat server
        // beradigan, kartasiz, hamma reja uchun.
        expect(ProTrialConfig.mechanism, ProTrialMechanism.serverGranted);
        expect(ProTrialConfig.serverTrialDays, 7);
        expect(
          _read('cloudflare/src/trial.ts'),
          contains('export const TRIAL_DAYS = 7;'),
        );
      },
    );

    test(
      'narx katalogi: egasi narxlari (D-73, D-76), to‘rt reja, yillik bor',
      () {
        final byPlan = {for (final p in ProPricing.plans) p.plan: p};
        expect(byPlan.keys.toSet(), ProPlan.values.toSet());
        expect(ProPricing.plans, hasLength(4));
        expect(byPlan[ProPlan.premium]!.monthlyUsd, 4.99);
        expect(byPlan[ProPlan.premium]!.yearlyUsd, 49.99);
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
      },
    );

    test(
      'D-78: bugungi bepul funksiya yopilmaydi — eski Lab/atlas/tarix '
      'yopilishi kodda yo‘q; gate faqat ruxsat etilgan Pro kirish nuqtalarida',
      () {
        final gateCall = RegExp(
          r'\b(requireFeature|pushGated|allowOrOffer)\(\s*context,\s*'
          r'Feature\.(\w+)',
        );
        final calls = <String, Set<String>>{};
        for (final f
            in Directory('lib')
                .listSync(recursive: true)
                .whereType<File>()
                .where((f) => f.path.endsWith('.dart'))) {
          final path = f.path.replaceAll(r'\', '/');
          if (path.startsWith('lib/l10n/gen/')) continue;
          final text = f.readAsStringSync();
          for (final old in [
            'plannedLabGate',
            'labGate(',
            'historyView(',
            'historyVisibleLimit',
            'freeHistoryLimit',
          ]) {
            expect(text.contains(old), isFalse, reason: '$path: $old');
          }
          for (final m in gateCall.allMatches(text)) {
            (calls[path] ??= {}).add(m[2]!);
          }
        }
        // Har gate chaqiruvi — katalogdagi funksiya va ruxsat etilgan faylda
        // (yangi Pro ekran yoki bepul ekrandagi YANGI Pro tugma). Yangi joy
        // qo'shilsa — shu ro'yxat ongli ravishda yangilanadi (D-78).
        expect(calls, kGateCallSites);
        // Qurilgan (gated) har funksiyaning kamida bitta boshlash nuqtasi
        // bor — bo'sh pullik va'da yo'q.
        final used = {for (final v in calls.values) ...v};
        for (final f in ProGatePolicy.gated) {
          expect(used, contains(f.name), reason: '${f.name}: kirish nuqtasi');
        }
      },
    );

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
        File('cloudflare/migrations/0014_billing.sql'),
        File('cloudflare/migrations/0015_pro_grants.sql'),
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

  group(
    'D-75: soxta xarid release’da imkonsiz, sandbox/sinov standartlari',
    () {
      test(
        'BuildFlags.fakePurchases: release’da doimiy false, standart false',
        () {
          expect(kFakePurchasesRequested, isFalse);
          expect(BuildFlags.fakePurchases, isFalse);
          final src = _read('lib/core/build_flags.dart');
          expect(
            src,
            contains(
              "const bool kFakePurchasesRequested = bool.fromEnvironment('LG_FAKE_PURCHASES');",
            ),
            reason: 'defaultValue qo‘shilmasin',
          );
          expect(
            src,
            contains('!kReleaseMode && kFakePurchasesRequested && proEnabled'),
            reason: 'kReleaseMode const: release’da kod olib tashlanadi',
          );
          final fake = _read('lib/core/entitlements/debug_fake_purchases.dart');
          expect(fake, contains('if (kReleaseMode) {'));
          expect(RegExp(r'_debugOnly\(\);').allMatches(fake).length, 3);
        },
      );

      test(
        'soxta adapter faqat main.dart da va faqat fakePurchases ortida',
        () {
          for (final f
              in Directory('lib')
                  .listSync(recursive: true)
                  .whereType<File>()
                  .where((f) => f.path.endsWith('.dart'))) {
            final path = f.path.replaceAll(r'\', '/');
            if (path.endsWith('debug_fake_purchases.dart')) continue;
            final text = f.readAsStringSync();
            if (!text.contains('DebugFake')) continue;
            expect(path, 'lib/main.dart', reason: 'DebugFake* boshqa joyda');
            final uses = RegExp(r'DebugFake\w+\(').allMatches(text).length;
            final guarded = RegExp(
              r'fake\s*\?\s*DebugFake|fake \? DebugFakeDeviceAttestor|\(fake\s*\?\s*DebugFake',
            ).allMatches(text).length;
            expect(guarded, uses, reason: 'har chaqiruv `fake ?` ortida');
            expect(text, contains('final fake = BuildFlags.fakePurchases;'));
          }
        },
      );

      test(
        'CI/skriptlar va do‘kon build buyruqlari LG_FAKE_PURCHASES ni yoqmaydi',
        () {
          for (final dir in ['.github', 'tool', 'scripts', 'ios', 'android']) {
            final d = Directory(dir);
            if (!d.existsSync()) continue;
            for (final f
                in d
                    .listSync(recursive: true)
                    .whereType<File>()
                    .where(
                      (f) => RegExp(
                        r'\.(ya?ml|sh|py|dart|json|toml|gradle|kts|xcconfig)$',
                      ).hasMatch(f.path),
                    )) {
              expect(
                f.readAsStringSync().contains('LG_FAKE_PURCHASES'),
                isFalse,
                reason: f.path,
              );
            }
          }
        },
      );

      test('server standartlari: sandbox bayroqsiz rad, iOS sinovi yopiq', () {
        final billing = _read('cloudflare/src/billing.ts');
        expect(billing, contains("env.LG_BILLING_SANDBOX === 'true'"));
        expect(billing, contains("new ApiError(403, 'sandbox_not_allowed')"));
        expect(
          billing,
          contains("new ApiError(503, 'store_verifier_not_configured')"),
        );
        final trial = _read('cloudflare/src/trial.ts');
        expect(trial, contains("env.TRIAL_PLATFORMS ?? 'android'"));
        expect(trial, contains("'trial_not_available_on_platform'"));
        final toml = _read('cloudflare/wrangler.toml');
        expect(
          RegExp(r'LG_BILLING_SANDBOX\s*=\s*"true"').hasMatch(toml),
          isFalse,
        );
        expect(
          RegExp(r'LG_BILLING_ENABLED\s*=\s*"true"').hasMatch(toml),
          isFalse,
        );
      });

      test('narx yagona manbada: ilova UI va server narx qotirmaydi', () {
        // Narx faqat pro_catalog.dart da (USD) — ekranlar u yerdan yoki do'kondan.
        for (final path in [
          'lib/features/profile/subscription_screen.dart',
          'lib/features/profile/purchase_screen.dart',
          'cloudflare/src/billing.ts',
          'cloudflare/src/trial.ts',
          'cloudflare/src/tiers.ts',
        ]) {
          expect(
            RegExp(r'\b(1\.49|9\.99|2\.49|24\.99|3\.49|34\.99|4\.99|49\.99)\b')
                .hasMatch(_read(path)),
            isFalse,
            reason: path,
          );
        }
      });
    },
  );
}
