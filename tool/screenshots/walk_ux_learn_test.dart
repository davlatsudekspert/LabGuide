// Talaba/laborant sifatida O'rganish: viktorina oqimi uch tilda.
//   flutter test tool/screenshots/walk_ux_learn_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import '../../test/helpers/learn_helpers.dart';
import 'walk_helper.dart';

Future<void> pick(WidgetTester tester) async {
  final f = find.byWidgetPredicate(
    (w) => w.runtimeType.toString() == '_OptionButton',
  );
  await tester.ensureVisible(f.first);
  await tester.pumpAndSettle();
  await tester.tap(f.first);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  for (final (lang, code, role) in [
    (AppLanguage.uz, 'uz', AppRole.student),
    (AppLanguage.ru, 'ru', AppRole.student),
    (AppLanguage.en, 'en', AppRole.lab),
  ]) {
    testWidgets('quiz oqimi $code', (tester) async {
      final l = lookupAppLocalizations(Locale(code));
      final s = await start(tester, lang: lang, role: role);
      final w = Walk(tester, 'ux_learn_$code');
      await goTo(tester, '/learn');
      await w.snap('home');
      await w.scroll(600);
      await w.snap('home2');
      await goTo(tester, '/learn/quiz');
      await w.snap('picker');
      await w.scroll(500);
      await w.snap('picker2');
      await tapScroll(tester, l.quizTopicMixed(10));
      await w.snap('q1');
      final q = s.content.pack!.quiz.length;
      expect(q, greaterThan(0));
      await pick(tester);
      await w.snap('q1_answered');
      await w.scroll(500);
      await w.snap('q1_answered2');
      // Qolgan savollarga ketma-ket javob (har safar birinchi variant).
      for (var i = 0; i < 9; i++) {
        await tapScroll(tester, i == 0 ? l.quizNext : l.quizNext);
        await pick(tester);
      }
      await w.snap('q10_answered');
      await tapScroll(tester, l.quizFinish);
      await w.snap('result');
      await w.scroll(600);
      await w.snap('result2');
      await w.scroll(3000);
      await w.snap('result_end');
    });
  }
}
