// Qorovul (guard) testlari: repozitoriy reyestrlari va CI.
//
// Egasi talabi: "har bir qilingan ishga test — qorovul, qilingan narsalar
// o'zgarib/buzilib qolmasin". Bu fayl hujjat va konfiguratsiya darajasidagi
// kelishuvlarni ushlaydi: qaror raqamlari, migratsiya raqamlari, ARB yozuvi
// siyosati va ci.yml dagi build bayroqlari. Jadval: docs/GUARDS.md.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

Map<String, Object?> _arb(String lang) =>
    (jsonDecode(_read('lib/l10n/app_$lang.arb')) as Map)
        .cast<String, Object?>();

/// ci.yml dagi har bir `flutter build ...` buyrug'i (qator davomi `\` bilan).
List<String> _flutterBuildCommands(String yml) {
  final lines = yml.split('\n');
  final out = <String>[];
  for (var i = 0; i < lines.length; i++) {
    if (!lines[i].trimLeft().startsWith('flutter build ')) continue;
    final b = StringBuffer(lines[i]);
    var j = i;
    while (lines[j].trimRight().endsWith(r'\') && j + 1 < lines.length) {
      j++;
      b.writeln(lines[j]);
    }
    out.add(b.toString());
  }
  return out;
}

/// ci.yml dagi bitta job matni (`  name:` dan keyingi job boshigacha).
String _job(String yml, String name) {
  final start = yml.indexOf('\n  $name:\n');
  expect(start, isNonNegative, reason: 'ci.yml da `$name` job yo‘q');
  final rest = yml.substring(start + 1);
  final next = RegExp(r'\n  [a-z_]+:\n').firstMatch(rest.substring(3));
  return next == null ? rest : rest.substring(0, next.start + 3);
}

void main() {
  group('docs/DECISIONS.md', () {
    final text = _read('docs/DECISIONS.md');
    final ids = [
      for (final m in RegExp(
        r'^## D-(\d+)([a-z]?)\. ',
        multiLine: true,
      ).allMatches(text))
        (n: int.parse(m[1]!), suffix: m[2]!),
    ];

    test('qaror raqamlari takrorlanmaydi', () {
      final keys = [for (final i in ids) '${i.n}${i.suffix}'];
      final dup = <String>{};
      final seen = <String>{};
      for (final k in keys) {
        if (!seen.add(k)) dup.add(k);
      }
      expect(dup, isEmpty, reason: 'takroriy qaror raqamlari: $dup');
    });

    test('D-01 … oxirgisigacha uzilishsiz; qarorlar o‘chirilmaydi', () {
      final numbers = {for (final i in ids) i.n};
      final max = numbers.reduce((a, b) => a > b ? a : b);
      // 2026-10-18 holati: D-01 … D-66 (+ D-47a). Eski qaror o'chirilmaydi —
      // bekor qilinsa, yangi qaror yoziladi (masalan, D-58 Pro'ni bekor qildi).
      expect(max, greaterThanOrEqualTo(66));
      expect(ids.length, greaterThanOrEqualTo(67));
      expect([
        for (var n = 1; n <= max; n++)
          if (!numbers.contains(n)) n,
      ], isEmpty);
    });

    test('asosiy egasi qarorlari matnda turibdi', () {
      for (final h in [
        "## D-58. Pro/to'lov ilovadan olib tashlandi",
        '## D-59. Ma\'ruza — haqiqiy 16:9 taqdimot',
        '## D-60. Toifa: 50 savollik test',
        '## D-62. Hamjamiyat moderatsiyasi',
        "## D-63. Egasi admin panelida hisobni email bo'yicha o'chirish",
        '## D-64. Tanlanadigan ilova mavzusi: Klassik va Ivory',
        '## D-65. "Qoralama / tekshirilmagan" belgilari o\'rniga adabiyot',
        '## D-66. Variantli mavzu testi',
      ]) {
        expect(text, contains(h));
      }
    });
  });

  group('migratsiyalar', () {
    test('Cloudflare D1: 4 xonali raqam, takrorsiz, uzilishsiz (0007 — '
        'olib tashlangan billing, qayta ishlatilmaydi)', () {
      final names =
          Directory('cloudflare/migrations')
              .listSync()
              .whereType<File>()
              .map((f) => f.uri.pathSegments.last)
              .where((n) => n.endsWith('.sql'))
              .toList()
            ..sort();
      final re = RegExp(r'^(\d{4})_[a-z0-9_]+\.sql$');
      final numbers = <int>[];
      for (final n in names) {
        final m = re.firstMatch(n);
        expect(m, isNotNull, reason: 'nom formati: $n');
        numbers.add(int.parse(m![1]!));
      }
      expect(numbers.toSet().length, numbers.length, reason: '$names');
      // 0007_billing.sql D-58 bilan olib tashlangan (0010 izohi): raqam
      // band — yangi migratsiya unga qo'yilmaydi.
      const retired = {7};
      expect(numbers.toSet().intersection(retired), isEmpty);
      final max = numbers.last;
      expect(max, greaterThanOrEqualTo(12));
      expect(
        [
          for (var i = 1; i <= max; i++)
            if (!numbers.contains(i) && !retired.contains(i)) i,
        ],
        isEmpty,
        reason: 'raqamlar uzilmasin: $names',
      );
      expect(
        _read('cloudflare/migrations/0010_assignment_deck.sql'),
        contains('0007'),
        reason: 'band raqam izohi o‘chmasin',
      );
      // 0013 — asosiy liniya (`0013_admin_step_up`, avval qo'llanishi
      // mumkin); Pro migratsiyalari undan keyin 0014–0017 (audit birlashmasi).
      // Qo'llangan raqam boshqa faylga berilmasin.
      for (final n in const [
        '0013_admin_step_up.sql',
        '0014_billing.sql',
        '0015_pro_grants.sql',
        '0016_pro_trials.sql',
        '0017_billing_notifications.sql',
      ]) {
        expect(names, contains(n), reason: 'migratsiya raqami o‘zgarmasin: $n');
      }
    });

    test('Supabase: 14 xonali vaqt belgisi, takrorsiz', () {
      final names =
          Directory('supabase/migrations')
              .listSync()
              .whereType<File>()
              .map((f) => f.uri.pathSegments.last)
              .where((n) => n.endsWith('.sql'))
              .toList()
            ..sort();
      final re = RegExp(r'^(\d{14})_[a-z0-9_]+\.sql$');
      final stamps = <String>[];
      for (final n in names) {
        final m = re.firstMatch(n);
        expect(m, isNotNull, reason: 'nom formati: $n');
        stamps.add(m![1]!);
      }
      expect(stamps.toSet().length, stamps.length, reason: '$names');
      expect(names.length, greaterThanOrEqualTo(11));
    });
  });

  group('ARB', () {
    test('uz va en qiymatlarida kirill harfi yo‘q (o‘zbekcha — lotin)', () {
      final cyr = RegExp(r'[Ѐ-ӿ]');
      for (final lang in ['uz', 'en']) {
        final bad = [
          for (final e in _arb(lang).entries)
            if (!e.key.startsWith('@') &&
                e.value is String &&
                cyr.hasMatch(e.value! as String))
              e.key,
        ];
        expect(bad, isEmpty, reason: '$lang: $bad');
      }
    });

    test('uz/ru/en kalitlari bir xil (arb_parity_test bilan birga)', () {
      Set<String> keys(String lang) => {
        for (final k in _arb(lang).keys)
          if (!k.startsWith('@')) k,
      };
      final uz = keys('uz');
      expect(keys('ru').difference(uz), isEmpty);
      expect(uz.difference(keys('ru')), isEmpty);
      expect(keys('en').difference(uz), isEmpty);
      expect(uz.difference(keys('en')), isEmpty);
    });
  });

  group('.github/workflows/ci.yml', () {
    final yml = _read('.github/workflows/ci.yml');

    test('hamkor reklamasi har bir CI buildida o‘chiq (LG_PARTNER_ADS)', () {
      expect(yml, contains("  LG_PARTNER_ADS: 'false'\n"));
      // Hech bir qadam bayroqni `true` qilmaydi (GITHUB_ENV orqali ham).
      expect(
        RegExp(
          r'''LG_PARTNER_ADS\s*[:=]\s*["']?true''',
          caseSensitive: false,
        ).hasMatch(yml),
        isFalse,
      );
      expect(RegExp(r'LG_PARTNER_ADS=[^\n]*GITHUB_ENV').hasMatch(yml), isFalse);
      final builds = _flutterBuildCommands(yml);
      // apk, appbundle, ios (imzosiz), ipa, ios --config-only.
      expect(builds.length, greaterThanOrEqualTo(5));
      for (final b in builds) {
        expect(
          b,
          contains(r'--dart-define=LG_PARTNER_ADS="$LG_PARTNER_ADS"'),
          reason: b,
        );
      }
    });

    test('Sign in with Apple: entitlement qarori va IPA tekshiruvi', () {
      expect(
        yml,
        contains(r"LG_APPLE_SIGNIN: ${{ vars.LG_APPLE_SIGNIN || 'false' }}"),
      );
      expect(yml, contains('- name: Sign in with Apple — entitlement qarori'));
      expect(yml, contains(r'if [ "$LG_APPLE_SIGNIN" != true ]; then'));
      expect(yml, contains("grep -q 'com.apple.developer.applesignin'"));
      expect(yml, contains("if os.environ.get('LG_APPLE_SIGNIN') == 'true':"));
      for (final b in _flutterBuildCommands(yml)) {
        expect(b, contains('--dart-define=LG_APPLE_SIGNIN='), reason: b);
      }
      // Imzosiz iOS build: entitlement yo'q — tugma ham yo'q.
      final unsigned = _flutterBuildCommands(yml)
          .firstWhere((b) => b.contains('--no-codesign'));
      expect(unsigned, contains('--dart-define=LG_APPLE_SIGNIN=false'));
    });

    test('Android release imzosi faqat qo‘lda ishga tushirilganda '
        '(audit 2026-10-17, #8)', () {
      expect(
        RegExp(
          r"- name: Android imzo kaliti \(ixtiyoriy\)\n\s+if: github\.event_name == 'workflow_dispatch'",
        ).hasMatch(yml),
        isTrue,
      );
    });

    test('tests job barcha qorovul qatlamlarini ishga tushiradi', () {
      final tests = _job(yml, 'tests');
      for (final cmd in [
        'flutter analyze',
        'flutter test',
        "python -m unittest discover -s tool/slides -p 'test_*.py'",
        'python tool/site/check_site.py',
        'python tool/site/check_site.py --self-test',
        'python -m unittest discover -s tool/site',
        'python -m unittest discover -s tool/ai/tests',
      ]) {
        expect(tests, contains(cmd), reason: cmd);
      }
      final worker = _job(yml, 'worker');
      expect(worker, contains('npm run typecheck'));
      expect(worker, contains('npm test'));
      // Worker testlari push/PR da ham ishlaydi (faqat play_listing'da emas).
      expect(worker, contains("if: inputs.mode != 'play_listing'"));
    });
  });
}
