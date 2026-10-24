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

    test('narx katalogi: TAKLIF qiymatlar, yillik narx belgilanmagan', () {
      final byTier = {
        for (final p in ProPricing.plans) (p.tier, p.student): p.monthlyUsd,
      };
      expect(byTier[(ProTier.pro, true)], 1.49); // Talaba
      expect(byTier[(ProTier.pro, false)], 3.99); // Oddiy
      expect(byTier[(ProTier.teacher, false)], 5.99); // Ustoz
      for (final p in ProPricing.plans) {
        expect(p.yearlyUsd, isNull, reason: p.yearlyProductId);
        expect(ProPricing.yearlyOffered(p.yearlyProductId), isFalse);
      }
    });

    test('eski narxlar va 7/14 kunlik sinov hech qayerda faol emas', () {
      final old = RegExp(
        r'29[  ]?000|\$\s?4\.99|\$\s?6\.99|\$\s?34\.99|\$\s?46\.99|'
        r'\$\s?9\.99|\b9[  ]000\s*so',
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
