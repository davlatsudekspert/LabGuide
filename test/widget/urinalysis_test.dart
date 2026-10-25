import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/microscopy/microscopy_atlas.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/tools/calc_info.dart';
import 'package:labguide/features/urinalysis/urinalysis_content.dart';
import 'package:labguide/features/urinalysis/urinalysis_logic.dart';
import 'package:labguide/features/urinalysis/urinalysis_screens.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

const _langs = ['uz', 'ru', 'en'];

void _full(LocalizedText t, String reason) {
  for (final lang in _langs) {
    expect(t.values[lang]?.trim(), isNotEmpty, reason: '$reason $lang');
  }
}

void _fact(UrFact f, String reason) {
  _full(f.text, reason);
  expect(f.refs, isNotEmpty, reason: reason);
  for (final r in f.refs) {
    expect(r.locator.trim(), isNotEmpty, reason: reason);
    expect(UrSources.all, contains(r.source), reason: reason);
  }
}

MicroAtlas _atlas() => MicroAtlas.fromJson(
  (jsonDecode(File('assets/microscopy/atlas.json').readAsStringSync()) as Map)
      .cast<String, Object?>(),
);

const _routes = ['collect', 'physical', 'strip', 'sediment', 'reader', 'quiz'];

/// O'qish qoidalarining mustaqil ta'rifi (mantiq bilan solishtirish uchun).
Set<UrCombo> _expectedCombos(Set<UrFinding> s) {
  bool has(UrFinding f) => s.contains(f);
  final pyuria = has(UrFinding.leukocyteEsterase) || has(UrFinding.wbc);
  final glom = has(UrFinding.dysmorphicRbc) || has(UrFinding.rbcCast);
  return {
    if (has(UrFinding.blood) &&
        !has(UrFinding.rbc) &&
        !has(UrFinding.dysmorphicRbc))
      UrCombo.bloodWithoutRbc,
    if (glom) UrCombo.glomerularPattern,
    if (has(UrFinding.rbc) && !has(UrFinding.protein) && !glom)
      UrCombo.urologicPattern,
    if (has(UrFinding.nitrite) && has(UrFinding.leukocyteEsterase))
      UrCombo.nitriteAndLe,
    if (pyuria && !has(UrFinding.nitrite)) UrCombo.leWithoutNitrite,
    if (has(UrFinding.squamous) &&
        (has(UrFinding.bacteria) ||
            pyuria ||
            has(UrFinding.rbc) ||
            has(UrFinding.blood)))
      UrCombo.contamination,
    if (has(UrFinding.alkalinePh) &&
        (has(UrFinding.nitrite) || has(UrFinding.bacteria)))
      UrCombo.ureaseAlkaline,
  };
}

void main() {
  setUpAll(loadAppFonts);

  group('kontent', () {
    test('hamma matn 3 tilda, har da’voda manba va joy bor', () {
      for (final t in UrL.all) {
        _full(t, 'UrL');
      }
      for (final g in UrGroup.values) {
        _full(UrL.groups[g]!, g.name);
      }
      for (final s in [...urCollectSections, ...urPhysicalSections]) {
        _full(s.title, 'section');
        expect(s.facts, isNotEmpty);
        for (final f in s.facts) {
          _fact(f, s.title.of('en'));
        }
      }
      for (final f in [
        ...urStripGeneral,
        ...urSedimentIntro,
        urSedimentCrystalsNote,
      ]) {
        _fact(f, 'general');
      }
      // Test-chiziq: talab qilingan 10 maydoncha.
      expect(
        {for (final p in urPads) p.id},
        {
          'ph',
          'protein',
          'glucose',
          'ketones',
          'bilirubin',
          'urobilinogen',
          'blood',
          'nitrite',
          'leukocytes',
          'sg',
        },
      );
      for (final p in urPads) {
        _full(p.name, p.id);
        for (final f in p.facts) {
          _fact(f, p.id);
        }
      }
      expect({for (final e in urElements) e.id}.length, urElements.length);
      for (final e in urElements) {
        _full(e.name, e.id);
        expect(e.look, isNotEmpty, reason: e.id);
        for (final f in e.facts) {
          _fact(f, e.id);
        }
        for (final p in e.pics) {
          if (p.panel case final panel?) {
            _full(panel, e.id);
            _full(urPanelNote(panel), e.id);
          }
        }
        expect(urElement(e.id), same(e));
      }
      for (final g in UrGroup.values) {
        expect(urElements.where((e) => e.group == g), isNotEmpty);
      }
      expect(urFindingInfo.keys.toSet(), UrFinding.values.toSet());
      for (final MapEntry(key: f, value: info) in urFindingInfo.entries) {
        _full(info.label, f.name);
        _fact(info.note, f.name);
        if (info.element case final id?) {
          expect(urElement(id), isNotNull, reason: f.name);
        }
      }
      expect(urComboInfo.keys.toSet(), UrCombo.values.toSet());
      for (final MapEntry(key: c, value: f) in urComboInfo.entries) {
        _fact(f, c.name);
      }
      for (final q in urQuizItems) {
        _full(q.prompt, q.id);
        _full(q.basis, q.id);
        expect(q.options, hasLength(4), reason: q.id);
        for (final o in q.options) {
          _full(o, q.id);
        }
        expect(q.refs, isNotEmpty, reason: q.id);
        for (final r in q.refs) {
          expect(UrSources.all, contains(r.source), reason: q.id);
        }
      }
      expect({for (final q in urQuizItems) q.id}.length, urQuizItems.length);
      for (final s in UrSources.all) {
        expect(s.url, startsWith('https://'), reason: s.id);
        expect(s.citation, isNotEmpty);
      }
      expect(
        {for (final s in UrSources.all) s.id}.length,
        UrSources.all.length,
      );
    });

    test('JSST lokatorlari sahifa bilan, "p. N" formatida', () {
      final all = [
        for (final s in [...urCollectSections, ...urPhysicalSections])
          ...s.facts,
        ...urStripGeneral,
        for (final p in urPads) ...p.facts,
        for (final e in urElements) ...e.facts,
      ];
      for (final r in urRefsOf(all)) {
        if (r.source != UrSources.who2003) continue;
        expect(r.locator, matches(RegExp(r'p\. \d')), reason: r.locator);
        expect(localizePages(r.locator, (p) => '$p-bet'), contains('-bet'));
      }
    });

    test('rasmlar: atlasda bor, nomi kartaga mos, fayli bor', () {
      final atlas = _atlas();
      expect(File(urinCardImage).existsSync(), true);
      final png = File(urinCardImage).readAsBytesSync();
      expect(png.sublist(1, 4), 'PNG'.codeUnits);
      for (final e in urElements) {
        for (final pic in e.pics) {
          final img = atlas.image(pic.atlasId);
          expect(img, isNotNull, reason: pic.atlasId);
          expect(img!.entityId, pic.atlasEntity, reason: pic.atlasId);
          expect(img.asset, urAtlasAsset(pic.atlasId));
          expect(File(img.asset).existsSync(), true, reason: img.asset);
          expect(img.author.trim(), isNotEmpty);
          expect(microLicenses.containsKey(img.license), true);
          final entity = atlas.entity(img.entityId)!;
          if (pic.panel case final panel?) {
            // Panel harfi atlasdagi asl izohda shu nom bilan bor.
            final letter = RegExp(r'^\(([a-d])\)').firstMatch(panel.of('en'))!;
            expect(img.caption.text, contains('(${letter[1]})'));
            expect(img.quizCue, isNull);
          } else {
            // Butun maydon rasmi: atlas turi nomi karta nomini o'z ichiga oladi.
            expect(
              entity.name.of('en').toLowerCase(),
              contains(e.name.of('en').toLowerCase()),
              reason: '${e.id} ↔ ${entity.id}',
            );
          }
          // Nomi faqat manba izohiga tayangan rasm mashqqa kirmaydi.
          if (img.labelNote != null) expect(e.quiz, false, reason: e.id);
        }
      }
      // Panel izohlari aynan to'g'ri harfga: a — RTE, b — loyqa-jigarrang,
      // c — leykotsitar, d — eritrotsitar.
      final panels = {
        for (final e in urElements)
          for (final p in e.pics)
            if (p.panel != null) e.id: p.panel!.of('en').substring(0, 3),
      };
      expect(panels, {
        'cast_epithelial': '(a)',
        'cast_granular': '(b)',
        'cast_wbc': '(c)',
        'cast_rbc': '(d)',
      });
    });

    test('mashq: rasm to‘g‘ri, variantlar takrorsiz, savollar noyob', () {
      final atlas = _atlas();
      final pool = urPictureQuizPool();
      expect(pool, isNotEmpty);
      for (final e in pool) {
        // Rasmli savolda faqat atlas "mashqqa yaroqli" deb belgilagan rasm.
        for (final p in e.pics.where((p) => p.panel == null)) {
          final img = atlas.image(p.atlasId)!;
          expect(img.quizCue, isNotNull, reason: p.atlasId);
          expect(img.labelNote, isNull, reason: p.atlasId);
        }
      }
      for (final e in urElements.where((e) => e.quiz)) {
        expect(urPictureDistractors.containsKey(e.id), true, reason: e.id);
      }
      for (final MapEntry(key: id, value: ds) in urPictureDistractors.entries) {
        expect(urElement(id), isNotNull, reason: id);
        expect(ds, hasLength(3), reason: id);
        expect({id, ...ds}.length, 4, reason: id);
        for (final d in ds) {
          final de = urElement(d)!;
          expect(
            de.group,
            urElement(id)!.group == UrGroup.cells
                ? anyOf(UrGroup.cells, UrGroup.organisms)
                : urElement(id)!.group,
            reason: '$id → $d',
          );
        }
      }
      expect(
        pool.length + urQuizItems.length,
        greaterThanOrEqualTo(urQuizSize),
      );
      for (var seed = 0; seed < 30; seed++) {
        final qs = buildUrQuiz(Random(seed));
        expect(qs, hasLength(urQuizSize));
        expect({for (final q in qs) q.question.id}.length, qs.length);
        for (final q in qs) {
          final qq = q.question;
          expect(qq.options, hasLength(4));
          for (final lang in _langs) {
            expect(
              {for (final o in qq.options) o.text.of(lang)}.length,
              4,
              reason: '${qq.id} $lang',
            );
          }
          if (q.isPicture) {
            final e = q.element!;
            expect(qq.options[qq.correctIndex].text, same(e.name));
            expect(
              e.pics.any((p) => p.atlasId == q.atlasId && p.panel == null),
              true,
            );
            expect(atlas.image(q.atlasId!)!.quizCue, isNotNull);
          } else {
            final item = urQuizItems.firstWhere((i) => i.id == qq.id);
            expect(qq.options[qq.correctIndex].text, same(item.options.first));
            expect(qq.basis, same(item.basis));
          }
        }
      }
    });

    test('o‘qish: barcha birikmalar (2^20) mustaqil ta’rifga mos', () {
      final values = UrFinding.values;
      expect(values.length, 20);
      for (var mask = 0; mask < 1 << values.length; mask++) {
        final s = <UrFinding>{
          for (var i = 0; i < values.length; i++)
            if (mask & (1 << i) != 0) values[i],
        };
        final r = readUrinalysis(s);
        expect(r.findings.length, s.length);
        expect(r.isEmpty, s.isEmpty);
        final combos = r.combos.toSet();
        if (combos.length != r.combos.length ||
            !_setEquals(combos, _expectedCombos(s))) {
          fail('mask $mask: ${r.combos} != ${_expectedCombos(s)}');
        }
        // Bo'sh tanlovda hech narsa ko'rsatilmaydi.
        if (s.isEmpty && r.combos.isNotEmpty) fail('empty → combos');
      }
      // Tartib: enum tartibida (barqaror ko'rinish).
      final r = readUrinalysis({UrFinding.bacteria, UrFinding.blood});
      expect(r.findings, [UrFinding.blood, UrFinding.bacteria]);
    });
  });

  for (final lang in AppLanguage.values) {
    testWidgets('barcha ekranlar ochiladi (${lang.name})', (tester) async {
      final s = await makeServices(tester, language: lang);
      await pumpApp(tester, s, size: const Size(390, 1600));
      final l = lookupAppLocalizations(Locale(lang.name));
      await goTo(tester, '/lab');
      final card = find.text(l.urinLabCardBody);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.byType(UrinalysisScreen), findsOne);
      // D-65: "Manbalar" paneli — muallif, yil, «nom» (qoralama emas).
      final delanghe = find.text(
        l.sourceLine(
          'Delanghe J, Speeckaert M, 2014, '
          '«Preanalytical requirements of urinalysis»',
        ),
      );
      expect(delanghe, findsOne);
      for (final r in _routes) {
        await goTo(tester, '$urinBase/$r');
        expect(tester.takeException(), isNull, reason: r);
        expect(delanghe, r == 'quiz' ? findsNothing : findsOne, reason: r);
      }
      for (final e in urElements) {
        await goTo(tester, urElementRoute(e.id));
        expect(find.text(e.name.of(lang.name)), findsWidgets, reason: e.id);
        if (e.pics.isEmpty) {
          expect(find.byKey(const ValueKey('urin-no-photo')), findsOne);
        } else {
          expect(
            find.byKey(ValueKey('urin-pic-${e.pics.first.atlasId}')),
            findsOne,
            reason: e.id,
          );
        }
        expect(tester.takeException(), isNull, reason: e.id);
      }
      await goTo(tester, '$urinBase/sediment/unknown');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tor ekran (320 px, ru): toshib ketish yo‘q', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.ru);
    await pumpApp(tester, s, size: const Size(320, 6000));
    for (final r in [
      '',
      for (final r in _routes) '/$r',
      for (final e in urElements) '/sediment/${e.id}',
    ]) {
      await goTo(tester, '$urinBase$r');
      expect(tester.takeException(), isNull, reason: r);
    }
    // O'qish: hamma topilma belgilangan — eng uzun natija ham sig'adi.
    await goTo(tester, '$urinBase/reader');
    for (final f in UrFinding.values) {
      final chip = find.byKey(ValueKey('urin-find-${f.name}'));
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const ValueKey('urin-reader-referral')), findsOne);
    expect(tester.takeException(), isNull);
    // Mashq savoli va javobdan keyingi izoh.
    await goTo(tester, '$urinBase/quiz');
    await tester.tap(find.byKey(const ValueKey('urin-quiz-start')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('urin-opt-0')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('o‘qish: belgilash → izoh, birikma, yo‘llanma; tozalash', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 3000));
    await goTo(tester, '$urinBase/reader');
    expect(find.byKey(const ValueKey('urin-reader-empty')), findsOne);
    for (final f in [UrFinding.nitrite, UrFinding.leukocyteEsterase]) {
      await tester.tap(find.byKey(ValueKey('urin-find-${f.name}')));
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const ValueKey('urin-res-nitrite')), findsOne);
    expect(find.byKey(const ValueKey('urin-combo-nitriteAndLe')), findsOne);
    expect(
      find.byKey(const ValueKey('urin-combo-leWithoutNitrite')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('urin-reader-referral')), findsOne);
    expect(
      find.textContaining(urComboInfo[UrCombo.nitriteAndLe]!.text.of('uz')),
      findsOne,
    );
    await tester.tap(find.byKey(const ValueKey('urin-reader-reset')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('urin-reader-empty')), findsOne);
  });

  testWidgets('mashq: javob berib, natijagacha', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '$urinBase/quiz');
    final l = lookupAppLocalizations(const Locale('uz'));
    await tester.tap(find.byKey(const ValueKey('urin-quiz-start')));
    await tester.pumpAndSettle();
    for (var i = 0; i < urQuizSize; i++) {
      await tester.tap(find.byKey(const ValueKey('urin-opt-0')));
      await tester.pumpAndSettle();
      final next = find.byKey(const ValueKey('urin-quiz-next'));
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text(l.quizDoneTitle), findsOne);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kartada atlas rasmi, muallif va atlasga havola', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 4000));
    final atlas = s.microscopy.atlas!;
    await goTo(tester, urElementRoute('cryst_triple'));
    final img = atlas.image('u-cryst-triple-1')!;
    expect(find.text(img.author), findsOne);
    expect(find.text(img.license), findsWidgets);
    await tester.tap(
      find.byKey(const ValueKey('urin-open-atlas-u-cryst-triple-1')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining(img.caption.text), findsWidgets);
    // Nomi faqat manba izohiga tayangan rasm: atlas eslatmasi ko'rinadi.
    await goTo(tester, urElementRoute('cryst_caox'));
    final caox = atlas.image('u-cryst-caox-1')!;
    expect(find.text(caox.labelNote!.of('uz')), findsOne);
    // Panel rasmi: qaysi panel ekanligi yozilgan.
    await goTo(tester, urElementRoute('cast_rbc'));
    final panel = urElement('cast_rbc')!.pics.first.panel!;
    expect(find.text(urPanelNote(panel).of('uz')), findsOne);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lab: siydik tahlili kartasi gistologiyadan keyin, ochiladi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2000));
    // Bo‘lim sahifasi tepasida “Qanday foydalaniladi?” qatori bor — oxirgi
    // kartalar ham quriladigan bo‘lishi uchun ekran balandroq.
    final l = lookupAppLocalizations(const Locale('uz'));
    await goTo(tester, '/lab');
    expect(find.text(l.urinTitle), findsOne);
    expect(find.text(l.urinLabCardBody), findsOne);
    final histo = tester.getTopLeft(find.text(l.histoTitle)).dy;
    final urin = tester.getTopLeft(find.text(l.urinTitle)).dy;
    expect(urin, greaterThan(histo));
    await tester.ensureVisible(find.text(l.urinTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.urinTitle));
    await tester.pumpAndSettle();
    expect(find.byType(UrinalysisScreen), findsOne);
    // Bog'liq kalkulyator va kartalar havola sifatida (nusxa emas).
    expect(find.byKey(const ValueKey('urin-calc-nechiporenko')), findsOne);
    expect(find.byKey(const ValueKey('urin-calc-addis-kakovsky')), findsOne);
    for (final id in urinAnalyteIds) {
      expect(find.byKey(ValueKey('urin-card-$id')), findsOne, reason: id);
    }
    await tester.tap(find.byKey(const ValueKey('urin-calc-nechiporenko')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

bool _setEquals<T>(Set<T> a, Set<T> b) =>
    a.length == b.length && a.containsAll(b);
