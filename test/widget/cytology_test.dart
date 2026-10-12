import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/cytology/cytology_content.dart';
import 'package:labguide/features/cytology/cytology_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

void main() {
  setUpAll(loadAppFonts);

  group('kontent', () {
    test('har element uchun rasm bor, 3 tilda matn to‘liq', () {
      for (final c in cytoCells) {
        expect(File(cytoImage(c.id)).existsSync(), true, reason: c.id);
        for (final t in [c.name, c.look, c.key, c.meaning, ?c.confuse]) {
          for (final lang in ['uz', 'ru', 'en']) {
            expect(t.of(lang).trim(), isNotEmpty, reason: '${c.id} $lang');
          }
        }
        expect(c.refs, isNotEmpty, reason: c.id);
        // Rasmdagi 1 va 2 raqamlarining izohi bo'lishi shart.
        final m = cytoMarks[c.id];
        expect(m, isNotNull, reason: c.id);
        expect(m!.marks, hasLength(2), reason: c.id);
        expect(m.refs, isNotEmpty, reason: c.id);
        for (final t in [m.method, m.caveat, ...m.marks]) {
          for (final lang in ['uz', 'ru', 'en']) {
            expect(t.of(lang).trim(), isNotEmpty, reason: '${c.id} $lang');
          }
        }
      }
      expect(cytoMarks.keys.toSet(), {for (final c in cytoCells) c.id});
      expect(File('assets/cytology/hero.png').existsSync(), true);
      expect({for (final c in cytoCells) c.id}.length, cytoCells.length);
    });

    test('tozalik darajasi: eng og‘ir belgi hal qiladi', () {
      expect(cytoDegreeOf(CytoLacto.many, CytoLeuko.single, CytoFlora.none), 1);
      expect(
        cytoDegreeOf(CytoLacto.many, CytoLeuko.moderate, CytoFlora.none),
        2,
      );
      expect(
        cytoDegreeOf(CytoLacto.few, CytoLeuko.moderate, CytoFlora.mixed),
        3,
      );
      expect(cytoDegreeOf(CytoLacto.none, CytoLeuko.single, CytoFlora.none), 4);
      expect(
        cytoDegreeOf(CytoLacto.many, CytoLeuko.single, CytoFlora.pathogenic),
        4,
      );
      expect(cytoDegrees.map((d) => d.n), [1, 2, 3, 4]);
    });

    test(
      'mashq: to‘g‘ri javob — rasmdagi element, variantlar takrorlanmaydi',
      () {
        for (var seed = 0; seed < 20; seed++) {
          final items = buildCytoQuiz(Random(seed));
          expect(items, hasLength(cytoQuizSize));
          for (final i in items) {
            final q = i.question;
            expect(q.options, hasLength(4));
            expect(
              q.options[q.correctIndex].text.of('uz'),
              i.cell.name.of('uz'),
            );
            final names = {for (final o in q.options) o.text.of('uz')};
            expect(names, hasLength(4), reason: i.cell.id);
          }
        }
      },
    );
  });

  for (final lang in AppLanguage.values) {
    testWidgets('barcha ekranlar ochiladi (${lang.name})', (tester) async {
      final s = await makeServices(tester, language: lang);
      await pumpApp(tester, s);
      final l = lookupAppLocalizations(Locale(lang.name));
      await goTo(tester, '/lab');
      await tester.scrollUntilVisible(find.text(l.cytoTitle), 200);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.cytoTitle));
      await tester.pumpAndSettle();
      expect(find.byType(CytologyScreen), findsOne);
      for (final r in ['cells', 'degree', 'bethesda', 'technique', 'quiz']) {
        await goTo(tester, '$cytoBase/$r');
        expect(tester.takeException(), isNull, reason: r);
      }
      for (final c in cytoCells) {
        await goTo(tester, '$cytoBase/cells/${c.id}');
        expect(find.text(c.name.of(lang.name)), findsWidgets, reason: c.id);
        expect(tester.takeException(), isNull, reason: c.id);
      }
    });
  }

  testWidgets('tozalik darajasi tanlovga qarab o‘zgaradi', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '$cytoBase/degree');
    final l = lookupAppLocalizations(const Locale('uz'));
    expect(find.text(l.cytoDegreeResult(1)), findsOne);
    await tester.tap(find.text(l.cytoNone).first);
    await tester.pumpAndSettle();
    expect(find.text(l.cytoDegreeResult(4)), findsOne);
  });

  testWidgets('mashq: javob berib, natijagacha', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '$cytoBase/quiz');
    final l = lookupAppLocalizations(const Locale('uz'));
    await tester.tap(find.text(l.cytoQuizStart));
    await tester.pumpAndSettle();
    for (var i = 0; i < cytoQuizSize; i++) {
      // Variant matnlari — elementlar nomlari.
      final names = [for (final c in cytoCells) c.name.of('uz')];
      final option = find.byWidgetPredicate(
        (w) => w is Text && names.contains(w.data),
      );
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(i == cytoQuizSize - 1 ? l.quizFinish : l.quizNext),
      );
      await tester.pumpAndSettle();
    }
    expect(find.text(l.quizDoneTitle), findsOne);
  });
}
