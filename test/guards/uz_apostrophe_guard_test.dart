import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// L10N audit 2026-10-24: the Uzbek convention is o‘ / g‘ = U+2018 and
/// tutuq = U+2019. No ASCII in-word apostrophe may remain in uz ARB values.
/// (The same rule is applied to content by tool/l10n/normalize_uz_apostrophes.py.)
void main() {
  final inWord = RegExp(r"(?<=[A-Za-z])'(?=[A-Za-z])");
  // English clitics are not Uzbek apostrophes (e.g. "doesn't").
  final clitic = RegExp(r"(?<=[A-Za-z])'(?:s|t|d|m|re|ve|ll)\b");

  test('app_uz.arb values have no ASCII in-word apostrophe', () {
    final arb = jsonDecode(File('lib/l10n/app_uz.arb').readAsStringSync())
        as Map<String, dynamic>;
    final bad = <String>[];
    arb.forEach((k, v) {
      if (k.startsWith('@') || v is! String) return;
      final t = v.replaceAll(clitic, '');
      if (inWord.hasMatch(t)) bad.add(k);
    });
    expect(bad, isEmpty, reason: 'ASCII apostrophe in uz keys: $bad');
  });

  test('app_uz.arb has no wrong o’ / g’ (U+2019 after o/g) forms', () {
    final arb = jsonDecode(File('lib/l10n/app_uz.arb').readAsStringSync())
        as Map<String, dynamic>;
    final wrong = RegExp('(?<=[oOgG])’(?=[a-zA-Z])');
    final bad = <String>[];
    arb.forEach((k, v) {
      if (k.startsWith('@') || v is! String) return;
      if (wrong.hasMatch(v)) bad.add(k);
    });
    // Reported by the audit only for kdl_oral; ARB must stay clean.
    expect(bad, isEmpty, reason: 'o’/g’ with tutuq in uz keys: $bad');
  });

  test('normalizer script is present and idempotent on the repo (--check)', () {
    final r = Process.runSync(
        'python3', ['tool/l10n/normalize_uz_apostrophes.py', '--check', '-q']);
    if (r.exitCode == 127) return; // python missing in this environment
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
  });
}
