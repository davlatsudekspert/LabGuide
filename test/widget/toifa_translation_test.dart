import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';
import 'package:labguide/features/toifa/toifa_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

const _tall = Size(390, 3000);

String _sha(String s) => sha256.convert(utf8.encode(s)).toString();

Future<ToifaBank> _bank() async {
  final c = ToifaController(MemoryKeyValueStore(), bundle: rootBundle);
  await c.ensureLoaded();
  return c.bank!;
}

void main() {
  setUpAll(loadAppFonts);

  group('tarjima ma’lumotlari', () {
    test('har savolda ru/en tarjima bor, variant va reja soni mos', () async {
      final bank = await _bank();
      expect(bank.tests.length, 488);
      for (final q in bank.tests) {
        for (final lang in toifaTranslationLangs) {
          final t = q.translations[lang];
          expect(t, isNotNull, reason: '${q.id}/$lang');
          expect(t!.text.trim(), isNotEmpty, reason: '${q.id}/$lang');
          expect(t.options.length, q.options.length, reason: '${q.id}/$lang');
          expect(t.options.every((o) => o.trim().isNotEmpty), true);
          expect(t.note != null, q.keyCheck.note != null, reason: q.id);
        }
      }
      for (final q in bank.oral) {
        for (final lang in toifaTranslationLangs) {
          final t = q.translations[lang];
          expect(t, isNotNull, reason: '${q.id}/$lang');
          expect(t!.text.trim(), isNotEmpty, reason: '${q.id}/$lang');
          expect(t.plan.length, q.plan.length, reason: '${q.id}/$lang');
          final l = q.localized(lang);
          expect(l.isTranslated, true);
          expect(l.originalQuestion.text, q.text);
          expect(l.plan.length, q.plan.length);
        }
        expect(q.localized('uz'), same(q));
      }
    });

    test(
      'kalit, variantlar soni va rasmiy matn asl nusxa bilan bir xil',
      () async {
        final bank = await _bank();
        final snap = jsonDecode(
          File('test/fixtures/toifa_official_snapshot.json').readAsStringSync(),
        ) as Map<String, Object?>;
        final tests = (snap['tests']! as Map).cast<String, Map<String, Object?>>();
        final oral = (snap['oral']! as Map).cast<String, String>();
        expect(bank.tests.map((q) => q.id).toSet(), tests.keys.toSet());
        expect(bank.oral.map((q) => q.id).toSet(), oral.keys.toSet());
        for (final q in bank.tests) {
          final s = tests[q.id]!;
          expect(q.key, (s['key']! as List).cast<int>(), reason: q.id);
          expect(q.optionCount, s['n'], reason: q.id);
          expect(
            _sha('${q.text}\u0001${q.options.join('\u0002')}'),
            s['h'],
            reason: q.id,
          );
          expect(q.officialPrompt, q.text);
          expect(q.prompt('uz'), q.text);
        }
        for (final q in bank.oral) {
          expect(
            _sha('${q.text}\u0001${q.plan.join('\u0002')}'),
            oral[q.id],
            reason: q.id,
          );
        }
      },
    );

    test('ru/en prompt tarjimani, uz — asl matnni qaytaradi', () async {
      final q = (await _bank()).tests.first;
      expect(q.prompt('ru'), q.translations['ru']!.text);
      expect(q.prompt('en'), q.translations['en']!.text);
      expect(q.prompt('uz'), q.text);
      expect(q.option(0, 'en'), q.translations['en']!.options[0]);
      expect(q.option(0, 'uz'), q.options[0]);
      expect(q.hasTranslation('ru'), true);
      expect(q.hasTranslation('uz'), false);
    });
  });

  for (final (lang, locale, l) in [
    (AppLanguage.ru, const Locale('ru', 'UZ'), 'ru'),
    (AppLanguage.en, const Locale('uz', 'UZ'), 'en'),
  ]) {
    final loc = lookupAppLocalizations(Locale(l));

    testWidgets('$l: amaliyot — tarjima, belgi va asl matnni ochish', (
      tester,
    ) async {
      final s = await makeServices(tester, language: lang);
      tester.platformDispatcher.localesTestValue = [locale];
      await pumpApp(tester, s, size: _tall);
      await goTo(tester, '/learn/toifa/practice/hemostasis');
      final bank = s.toifa.bank!;
      final q = bank.scorable
          .where((q) => q.topic == 'hemostasis')
          .firstWhere((q) => find.text(q.prompt(l)).evaluate().isNotEmpty);
      expect(find.text(q.prompt(l)), findsOne);
      expect(find.text(q.text), findsNothing);
      expect(find.text(loc.toifaUzbekOnly), findsWidgets);
      expect(find.text(loc.toifaShowOriginal), findsOne);

      await tapScroll(tester, loc.toifaShowOriginal);
      expect(find.byKey(const ValueKey('toifa-original-text')), findsOne);
      expect(find.text(q.text), findsOne);
      expect(find.text(loc.toifaHideOriginal), findsOne);

      // Baholash o'zgarmaydi: noto'g'ri variant (tarjima matni) — xato.
      final wrong = List.generate(
        q.optionCount,
        (i) => i,
      ).firstWhere((i) => !q.key.contains(i));
      await tapScroll(tester, q.option(wrong, l));
      expect(s.quizProgress.statFor(q.id)!.lastCorrect, false);
    });

    testWidgets('$l: og‘zaki savol — tarjima va asl matn', (tester) async {
      final s = await makeServices(tester, language: lang);
      tester.platformDispatcher.localesTestValue = [locale];
      await pumpApp(tester, s, size: const Size(390, 6000));
      await goTo(tester, '/learn/toifa/oral/q/kdl-o-001');
      final q = s.toifa.bank!.oralQuestion('kdl-o-001')!;
      expect(find.text(q.localized(l).text), findsWidgets);
      expect(find.text(loc.toifaUzbekOnly), findsWidgets);
      await tapScroll(tester, loc.toifaShowOriginal);
      expect(find.byKey(const ValueKey('toifa-original-text')), findsOne);
      expect(find.text(q.text), findsWidgets);
    });
  }
}
