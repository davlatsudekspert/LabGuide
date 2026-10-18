import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/cytology/cytology_content.dart';
import 'package:labguide/features/cytology/cytology_more.dart';
import 'package:labguide/features/cytology/cytology_more_screens.dart';
import 'package:labguide/features/cytology/cytology_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/spermogram/spermogram_screens.dart';
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
      // Leykotsitlar ko'p — laktobatsillalar ko'p bo'lsa ham norma emas.
      expect(
        cytoDegreeOf(CytoLacto.many, CytoLeuko.moderate, CytoFlora.none),
        3,
      );
      expect(
        cytoDegreeOf(CytoLacto.many, CytoLeuko.single, CytoFlora.mixed),
        2,
      );
      expect(
        cytoDegreeOf(CytoLacto.few, CytoLeuko.moderate, CytoFlora.mixed),
        3,
      );
      // II darajaning o'z matni: "laktobatsillalar kamroq ... leykotsitlar
      // yakka" — kam laktobatsilla + yakka leykotsit II (audit #19).
      expect(cytoDegreeOf(CytoLacto.few, CytoLeuko.single, CytoFlora.mixed), 2);
      expect(cytoDegreeOf(CytoLacto.few, CytoLeuko.single, CytoFlora.none), 2);
      expect(
        cytoDegreeOf(CytoLacto.few, CytoLeuko.single, CytoFlora.pathogenic),
        4,
      );
      expect(cytoDegreeOf(CytoLacto.none, CytoLeuko.single, CytoFlora.none), 4);
      expect(
        cytoDegreeOf(CytoLacto.many, CytoLeuko.single, CytoFlora.pathogenic),
        4,
      );
      expect(cytoDegrees.map((d) => d.n), [1, 2, 3, 4]);
    });

    test('Bethesda: 2014 toifalari, HSIL yo‘naltiruvchi emas, manbalar', () {
      final codes = [for (final b in bethesdaItems) b.code];
      expect(codes, containsAll(['AGC, favor neoplastic', 'Adenocarcinoma']));
      expect(codes.toSet(), hasLength(codes.length));
      for (final b in bethesdaItems) {
        expect(b.refs, isNotEmpty, reason: b.code);
        for (final t in [b.name, b.meaning]) {
          for (final lang in ['uz', 'ru', 'en']) {
            expect(t.of(lang).trim(), isNotEmpty, reason: '${b.code} $lang');
          }
        }
      }
      final hsil = bethesdaItems.firstWhere((b) => b.code == 'HSIL');
      expect(hsil.meaning.of('en'), contains('clinician decides'));
      expect(hsil.meaning.of('en'), contains('ASCCP 2019'));
      // AGC: ASCCP 2019 G.1 — endometrial namuna 35+ yoki xavf oshganda
      // (audit #12).
      final agc = bethesdaItems.firstWhere((b) => b.code == 'AGC');
      expect(agc.meaning.of('en'), contains('35 or older'));
      expect(agc.meaning.of('en'), contains('endometrial sampling'));
      expect(agc.meaning.of('ru'), contains('35 лет'));
      expect(agc.meaning.of('uz'), contains('35 yosh'));
      expect(agc.refs.map((r) => r.locator), contains('Section G.1'));
    });

    test('qo‘shimcha sahifalar: 3 tilda matn to‘liq, manbalar bor', () {
      void full(LocalizedText t, String why) {
        for (final lang in ['uz', 'ru', 'en']) {
          expect(t.of(lang).trim(), isNotEmpty, reason: '$why $lang');
        }
      }

      for (final f in [
        ...cytoAdequacy,
        ...cytoArtefacts,
        ...cytoReactiveTypes,
        ...cytoMaturation,
      ]) {
        full(f.title, f.title.of('en'));
        full(f.body, f.title.of('en'));
        expect(f.refs, isNotEmpty, reason: f.title.of('en'));
      }
      expect(cytoCompareHeads, hasLength(3));
      for (final r in cytoCompare) {
        full(r.feature, r.feature.of('en'));
        expect(r.cells, hasLength(cytoCompareHeads.length));
        // Reaktiv va ASC-US ustunlari har qatorda to'ldirilgan.
        expect(r.cells[0], isNotNull, reason: r.feature.of('en'));
        expect(r.cells[1], isNotNull, reason: r.feature.of('en'));
        for (final c in r.cells) {
          if (c != null) full(c, r.feature.of('en'));
        }
        expect(r.refs, isNotEmpty, reason: r.feature.of('en'));
      }
      for (final s in cytoOtherSystems) {
        full(s.title, s.title.of('en'));
        full(s.system, s.title.of('en'));
        if (s.note case final n?) full(n, s.title.of('en'));
        expect(s.categories, isNotEmpty);
        for (final c in s.categories) {
          full(c, s.title.of('en'));
        }
        expect(s.refs, isNotEmpty, reason: s.title.of('en'));
      }
      for (final refs in [
        cytoAdequacyRefs,
        cytoReactiveRefs,
        cytoMaturationRefs,
      ]) {
        expect(refs, isNotEmpty);
      }
      // Manba id lari takrorlanmaydi.
      final ids = [for (final s in CytoSources.all) s.id];
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('yetilish indeksi: foizlar arifmetikasi', () {
      final a = cytoMaturationIndex(0, 35, 65)!;
      expect(a.parabasal, 0);
      expect(a.intermediate, 35);
      expect(a.superficial, 65);
      final b = cytoMaturationIndex(1, 1, 1)!;
      expect(b.parabasal, closeTo(33.333, 0.001));
      expect(b.parabasal + b.intermediate + b.superficial, closeTo(100, 1e-9));
      final c = cytoMaturationIndex(90, 10, 0)!;
      expect(c.parabasal, 90);
      expect(c.superficial, 0);
      final d = cytoMaturationIndex(3, 0, 1)!;
      expect(d.parabasal, 75);
      expect(d.superficial, 25);
      expect(cytoMaturationIndex(0, 0, 0), isNull);
      expect(cytoMaturationIndex(-1, 5, 5), isNull);
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
      await tester.tap(find.text(l.cytoTitle));
      await tester.pumpAndSettle();
      expect(find.byType(CytologyScreen), findsOne);
      for (final r in ['cells', 'degree', 'bethesda', 'technique', 'quiz']) {
        await goTo(tester, '$cytoBase/$r');
        expect(tester.takeException(), isNull, reason: r);
      }
      for (final (r, type, title) in [
        ('adequacy', CytoAdequacyScreen, l.cytoAdequacyTitle),
        ('reactive', CytoReactiveScreen, l.cytoReactiveTitle),
        ('maturation', CytoMaturationScreen, l.cytoMaturationTitle),
        ('other', CytoOtherScreen, l.cytoOtherTitle),
      ]) {
        await goTo(tester, '$cytoBase/$r');
        expect(find.byType(type), findsOne, reason: r);
        expect(find.text(title), findsWidgets, reason: r);
        expect(find.text(l.sourcesDisclaimer), findsWidgets, reason: r);
        expect(tester.takeException(), isNull, reason: r);
      }
      for (final c in cytoCells) {
        await goTo(tester, '$cytoBase/cells/${c.id}');
        expect(find.text(c.name.of(lang.name)), findsWidgets, reason: c.id);
        expect(tester.takeException(), isNull, reason: c.id);
      }
    });
  }

  testWidgets('Lab: rasmli kartalar, spermogramma sahifasi ochiladi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 1600));
    final l = lookupAppLocalizations(const Locale('uz'));
    await goTo(tester, '/lab');
    expect(find.text(l.cytoLabCardBody), findsOne);
    expect(find.text(l.spermLabCardBody), findsOne);
    await tester.tap(find.text(l.spermTitle));
    await tester.pumpAndSettle();
    expect(find.byType(SpermogramScreen), findsOne);
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('yetilish indeksi hisoblagichi foizlarni ko‘rsatadi', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 3200));
    await goTo(tester, '$cytoBase/maturation');
    final l = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l.cytoMiEmpty), findsOne);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1');
    await tester.enterText(fields.at(1), '1');
    await tester.enterText(fields.at(2), '2');
    await tester.pumpAndSettle();
    expect(find.text('25 : 25 : 50'), findsOne);
    expect(find.text(l.cytoMiTotal(4)), findsOne);
    expect(tester.takeException(), isNull);
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

  test('tibbiy ko‘rib chiqish 2026-10-18: gonokokk va Parij tizimi', () {
    // CDC 2021: Gram surtma faqat simptomli erkaklarda diagnostik.
    final gono = cytoCell('gonococcus')!.meaning;
    expect(gono.values['en'], contains('symptomatic men'));
    expect(gono.values['ru'], contains('с симптомами'));
    expect(gono.values['uz'], contains('Simptomli'));
    // TPS 2.0 (Wojcik 2026, Table 2): Non-urothelial toifasi ham bor.
    final paris = cytoOtherSystems.first.categories;
    expect(paris, hasLength(6));
    expect(paris.last.values['en'], startsWith('Non-urothelial'));
  });

  test('adabiyot tekshiruvi 2026-10-18: tozalik darajasi va AGC-FN', () {
    // Har darajaga pH oralig'i manbalarda yo'q — jadvalda pH yo'q.
    for (final d in cytoDegrees) {
      for (final lang in ['uz', 'ru', 'en']) {
        expect(d.picture.of(lang), isNot(contains('pH')), reason: lang);
      }
    }
    // Manba qatorlari: ROAG 2019 (Heurlein — tarixiy), Kurbonova 2023
    // (Hay–Ison), Ison–Hay 2002; har biri 3 tilda va "Manba/Источник/Source".
    expect(cytoDegreeCites, hasLength(4));
    for (final c in cytoDegreeCites.take(3)) {
      expect(c.of('uz'), startsWith('Manba:'));
      expect(c.of('ru'), startsWith('Источник:'));
      expect(c.of('en'), startsWith('Source:'));
    }
    expect(cytoDegreeCites[0].of('ru'), contains('Heurlein (1910)'));
    expect(cytoDegreeCites[0].of('ru'), contains('историческое значение'));
    expect(cytoDegreeCites[1].of('uz'), contains('70-b.'));
    expect(cytoDegreeCites[1].of('uz'), contains('Hay–Ison'));
    expect(
      [for (final r in cytoDegreeRefs) r.source.id],
      containsAll([
        CytoSources.roag2019.id,
        CytoSources.kurbonova2023.id,
        CytoSources.isonHay2002.id,
      ]),
    );
    // AGC-FN ruscha atamasi — RF KR 597 (2024); Grigoruk 2024 varianti ham.
    final agc = bethesdaItems.firstWhere(
      (b) => b.code == 'AGC, favor neoplastic',
    );
    expect(agc.name.of('ru'), contains('похожие на неопластичные'));
    expect(agc.name.of('ru'), isNot(contains('подозрительные на опухолевые')));
    expect(agc.cites, hasLength(2));
    expect(agc.cites[0].of('ru'), contains('ID 597'));
    expect(agc.cites[1].of('ru'), contains('подозрительные на аденокарциному'));
    expect(agc.cites[1].of('ru'), contains('с. 103'));
  });

  testWidgets('tozalik darajasi ekranida manba qatorlari ko‘rinadi', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.ru);
    await pumpApp(tester, s, size: const Size(390, 6000));
    await goTo(tester, '$cytoBase/degree');
    expect(find.byKey(const ValueKey('cyto-degree-cites')), findsOne);
    expect(find.text(cytoDegreeCites.first.of('ru')), findsOne);
    expect(find.textContaining('pH 4,0'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
