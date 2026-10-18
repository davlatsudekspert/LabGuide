import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/bloodmorph/bloodmorph_content.dart';
import 'package:labguide/features/bloodmorph/bloodmorph_logic.dart';
import 'package:labguide/features/bloodmorph/bloodmorph_screens.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

const _langs = ['uz', 'ru', 'en'];

void _full(LocalizedText t, String reason) {
  for (final lang in _langs) {
    expect(t.values[lang]?.trim(), isNotEmpty, reason: '$reason $lang');
  }
}

void _fact(BmFact f, String reason) {
  _full(f.text, reason);
  expect(f.refs, isNotEmpty, reason: reason);
  for (final r in f.refs) {
    expect(r.locator.trim(), isNotEmpty, reason: reason);
    expect(BmSources.all, contains(r.source), reason: reason);
  }
}

/// JPEG o'lchami (SOF0/SOF2 segmentidan).
(int, int) _jpegSize(Uint8List b) {
  expect(b[0] == 0xFF && b[1] == 0xD8, true, reason: 'JPEG emas');
  var i = 2;
  while (i < b.length) {
    if (b[i] != 0xFF) {
      i++;
      continue;
    }
    final marker = b[i + 1];
    final len = (b[i + 2] << 8) | b[i + 3];
    if (marker == 0xC0 || marker == 0xC2) {
      final h = (b[i + 5] << 8) | b[i + 6];
      final w = (b[i + 7] << 8) | b[i + 8];
      return (w, h);
    }
    i += 2 + len;
  }
  fail('SOF topilmadi');
}

const _routes = [
  'normal',
  'rbc',
  'platelets',
  'retic',
  'anemia',
  'quality',
  'quiz',
  'credits',
];

/// BmL dagi barcha matnlar (3 tilda bo'lishi shart).
final _uiTexts = <LocalizedText>[
  BmL.subtitle,
  BmL.draftNote,
  BmL.photoNote,
  BmL.normalTitle,
  BmL.normalSub,
  BmL.findingsTitle,
  BmL.findingsSub,
  BmL.plateletsTitle,
  BmL.plateletsSub,
  BmL.reticTitle,
  BmL.reticSub,
  BmL.anemiaTitle,
  BmL.anemiaSub,
  BmL.qualityTitle,
  BmL.qualitySub,
  BmL.quizTitle,
  BmL.quizSub,
  BmL.creditsTitle,
  BmL.creditsSub,
  BmL.creditsIntro,
  ...BmL.groups.values,
  BmL.akaTitle,
  BmL.seeTitle,
  BmL.pointsTitle,
  BmL.notDiagnosis,
  BmL.confuseTitle,
  BmL.referTitle,
  BmL.imageTitle,
  BmL.stain,
  BmL.stainNotStated,
  BmL.captionTitle,
  BmL.checked,
  BmL.resized,
  BmL.noPhoto,
  BmL.relatedCards,
  BmL.leukoLinkTitle,
  BmL.leukoLinkSub,
  BmL.normalPlatelets,
  BmL.schemeTitle,
  BmL.schemeLabel,
  BmL.calcLink,
  BmL.calcLinkSub,
  BmL.workedTitle,
  BmL.workedInput,
  BmL.workedPercent,
  BmL.workedAbsolute,
  BmL.workedCorrected,
  BmL.anemiaIntro,
  BmL.populationTitle,
  ...BmL.populations.values,
  BmL.fieldHb,
  BmL.fieldMcv,
  BmL.fieldRdw,
  BmL.fieldRdwUpper,
  BmL.rdwUpperHint,
  BmL.fieldFerritin,
  BmL.inflammation,
  BmL.fieldRetic,
  BmL.invalid,
  BmL.resultTitle,
  BmL.emptyHint,
  BmL.anaemicYes,
  BmL.anaemicNo,
  BmL.cutoffLabel,
  ...BmL.mcvClasses.values,
  BmL.rdwHigh,
  BmL.rdwNormal,
  BmL.rdwUnknown,
  BmL.patternTitle,
  BmL.differentialsTitle,
  BmL.clueTitle,
  BmL.ferritinTitle,
  BmL.ferritinLow,
  BmL.ferritinNotLow,
  BmL.ferritinNoCutoff,
  BmL.ferritinInflNote,
  BmL.reticTitleShort,
  ...BmL.reticBands.values,
  BmL.ageNote,
  BmL.redFlag,
  BmL.helperRefer,
  BmL.tableLink,
  BmL.tableLinkSub,
  BmL.quizIntro,
  BmL.quizStart,
  BmL.quizPrompt,
  BmL.quizImageLabel,
];

List<BmFinding> get _allFindings => [...bmFindings, ...bmPlatelets];

void main() {
  setUpAll(loadAppFonts);

  group('kontent', () {
    test('hamma matn 3 tilda, har da’voda manba va joy bor', () {
      expect(File(bmCardImage).existsSync(), true);
      expect(File(bmSchemeImage).existsSync(), true);
      final ids = {for (final f in _allFindings) f.id};
      expect(ids.length, _allFindings.length);
      for (final f in _allFindings) {
        _full(f.name, f.id);
        if (f.aka case final a?) _full(a, f.id);
        expect(f.see, isNotEmpty, reason: f.id);
        for (final x in f.facts) {
          _fact(x, f.id);
        }
        expect(bmFinding(f.id), same(f));
      }
      expect(bmFinding('unknown'), isNull);
      // Har eritrotsit guruhida kamida bitta karta; trombotsitlar alohida.
      for (final g in BmGroup.values) {
        expect(
          _allFindings.where((f) => f.group == g),
          isNotEmpty,
          reason: '$g',
        );
        _full(BmL.groups[g]!, g.name);
      }
      expect(bmPlatelets.every((f) => f.group == BmGroup.platelet), true);
      expect(bmFindings.any((f) => f.group == BmGroup.platelet), false);
      for (final s in [
        ...bmNormalSections,
        ...bmQualitySections,
        ...bmReticSections,
      ]) {
        _full(s.title, s.id);
        expect(s.facts, isNotEmpty, reason: s.id);
        for (final f in s.facts) {
          _fact(f, s.id);
        }
      }
      for (final f in bmPlateletIntro) {
        _fact(f, 'platelet-intro');
      }
      _fact(bmReferGeneral, 'refer');
      for (final t in _uiTexts) {
        _full(t, 'BmL');
      }
      for (final MapEntry(key: k, value: p) in bmPatterns.entries) {
        _full(p.pattern, '$k');
        _full(p.differentials, '$k');
        _full(p.clue, '$k');
      }
      // Takami Table 3: 3 × 2 = 6 qator.
      expect(bmPatterns.length, 6);
      for (final c in BmMcvClass.values) {
        _full(bmMcvOnly[c]!, c.name);
        for (final rdw in [true, false]) {
          expect(bmPatterns[(c, rdw)], isNotNull);
        }
      }
      for (final r in bmHelperRefs) {
        expect(BmSources.all, contains(r.source));
        expect(r.locator, isNotEmpty);
      }
      for (final s in BmSources.all) {
        expect(s.citation, isNotEmpty);
        // Bosma kitob — havolasiz; qolganlari https.
        if (s.url case final u?) {
          expect(u, startsWith('https://'), reason: s.id);
        }
      }
      expect(
        {for (final s in BmSources.all) s.id}.length,
        BmSources.all.length,
      );
    });

    test('har rasm fayli bor, o‘lchami to‘g‘ri, muallif va litsenziya bor', () {
      const allowed = {
        'CC0 1.0',
        'CC BY 2.0',
        'CC BY 3.0',
        'CC BY 4.0',
        'CC BY-SA 3.0',
        'CC BY-SA 4.0',
      };
      final images = bmAllImages();
      expect(images, isNotEmpty);
      var total = 0;
      for (final img in images) {
        final f = File(img.asset);
        expect(f.existsSync(), true, reason: img.asset);
        final bytes = f.readAsBytesSync();
        total += bytes.length;
        expect(_jpegSize(bytes), (img.width, img.height), reason: img.file);
        expect(img.width, lessThanOrEqualTo(900), reason: img.file);
        // Faqat kichraytirilgan: nisbat asl fayl bilan bir xil.
        expect(
          (img.width / img.height - img.originalWidth / img.originalHeight)
              .abs(),
          lessThan(0.01),
          reason: img.file,
        );
        expect(img.width, lessThanOrEqualTo(img.originalWidth));
        expect(img.author.trim(), isNotEmpty, reason: img.file);
        expect(allowed, contains(img.license), reason: img.file);
        expect(img.licenseUrl, startsWith('https://creativecommons.org/'));
        expect(img.caption.trim(), isNotEmpty, reason: img.file);
        expect(img.commonsTitle, isNot(startsWith('File:')));
        expect(
          img.sourcePage,
          startsWith('https://commons.wikimedia.org/wiki/File%3A'),
        );
        _full(img.captionTr, img.file);
        if (img.stain case final s?) _full(s, img.file);
      }
      // Papkadagi har rasm ilovada ishlatiladi (ortiqcha fayl yo'q).
      final onDisk = {
        for (final f in Directory('assets/bloodmorph/img').listSync())
          f.uri.pathSegments.last,
      };
      expect(onDisk, {for (final i in images) '${i.file}.jpg'});
      // Bo'limning rasmlari jami ≤ 15 MB.
      final all = Directory('assets/bloodmorph')
          .listSync(recursive: true)
          .whereType<File>()
          .fold<int>(0, (s, f) => s + f.lengthSync());
      expect(all, lessThan(15 * 1024 * 1024));
      expect(total, lessThanOrEqualTo(all));
      // Rasmsiz karta mashqqa kirmaydi.
      for (final f in _allFindings.where((f) => f.image == null)) {
        expect(bmQuizPool(), isNot(contains(f)));
      }
    });

    test('mashq: to‘g‘ri javob — ko‘rsatilgan rasm, variantlar takrorsiz', () {
      final pool = bmQuizPool();
      expect(pool.length, greaterThanOrEqualTo(bmPictureQuizSize));
      expect(bmKnowledge.length, greaterThanOrEqualTo(bmKnowledgeQuizSize));
      for (final MapEntry(key: id, value: ds) in bmDistractors.entries) {
        expect(bmFinding(id), isNotNull, reason: id);
        expect(ds, hasLength(3), reason: id);
        expect({id, ...ds}.length, 4, reason: id);
        for (final d in ds) {
          expect(bmFinding(d), isNotNull, reason: '$id → $d');
        }
      }
      for (final f in _allFindings.where((f) => f.image != null && f.quiz)) {
        expect(bmDistractors.containsKey(f.id), true, reason: f.id);
      }
      expect({for (final k in bmKnowledge) k.id}.length, bmKnowledge.length);
      for (final k in bmKnowledge) {
        _full(k.prompt, k.id);
        _fact(k.basis, k.id);
        expect(k.options, hasLength(4), reason: k.id);
        expect(k.correct, inInclusiveRange(0, 3), reason: k.id);
        for (final o in k.options) {
          _full(o, k.id);
        }
        for (final lang in _langs) {
          expect({for (final o in k.options) o.of(lang)}.length, 4);
        }
      }
      for (var seed = 0; seed < 30; seed++) {
        final qs = buildBmQuiz(Random(seed));
        expect(qs, hasLength(bmPictureQuizSize + bmKnowledgeQuizSize));
        expect({for (final q in qs) q.question.id}.length, qs.length);
        final pics = qs.where((q) => q.finding != null).toList();
        expect(pics, hasLength(bmPictureQuizSize));
        for (final q in qs) {
          expect(q.question.options, hasLength(4));
          for (final lang in _langs) {
            expect(
              {for (final o in q.question.options) o.text.of(lang)}.length,
              4,
              reason: '${q.question.id} $lang',
            );
          }
          final correct = q.question.options[q.question.correctIndex].text;
          if (q.finding case final f?) {
            expect(f.image, isNotNull);
            expect(f.quiz, true);
            // To'g'ri javob — aynan ko'rsatilgan rasmning nomi.
            expect(correct, same(f.name));
            expect(q.question.basis, same(f.see.first.text));
          } else {
            final k = bmKnowledge.firstWhere(
              (k) => 'bm-k-${k.id}' == q.question.id,
            );
            expect(correct, same(k.options[k.correct]));
          }
        }
      }
    });
  });

  group('anemiya yordamchisi mantiqi', () {
    test('JSST 2024 Hb chegaralari (Table 2)', () {
      const expected = {
        BmPopulation.child6to23m: 105,
        BmPopulation.child24to59m: 110,
        BmPopulation.child5to11y: 115,
        BmPopulation.girl12to14y: 120,
        BmPopulation.boy12to14y: 120,
        BmPopulation.woman15to65: 120,
        BmPopulation.man15to65: 130,
        BmPopulation.pregnantT1: 110,
        BmPopulation.pregnantT2: 105,
        BmPopulation.pregnantT3: 110,
      };
      expect(expected.keys.toSet(), BmPopulation.values.toSet());
      for (final MapEntry(key: p, value: c) in expected.entries) {
        expect(bmHbCutoff(p), c, reason: p.name);
      }
    });

    test('JSST 2020 ferritin chegaralari (Table 1)', () {
      for (final p in BmPopulation.values) {
        final healthy = bmFerritinCutoff(p, inflammation: false);
        final infl = bmFerritinCutoff(p, inflammation: true);
        switch (p) {
          case BmPopulation.child6to23m || BmPopulation.child24to59m:
            expect((healthy, infl), (12, 30), reason: p.name);
          case BmPopulation.pregnantT1:
            expect((healthy, infl), (15, null), reason: p.name);
          case BmPopulation.pregnantT2 || BmPopulation.pregnantT3:
            expect((healthy, infl), (null, null), reason: p.name);
          default:
            expect((healthy, infl), (15, 70), reason: p.name);
        }
      }
    });

    test('MCV, RDW va retikulotsit chegaralari', () {
      expect(bmMcvClass(79.9), BmMcvClass.micro);
      expect(bmMcvClass(80), BmMcvClass.normo);
      expect(bmMcvClass(100), BmMcvClass.normo);
      expect(bmMcvClass(100.1), BmMcvClass.macro);
      expect(bmReticBand(80.1), BmReticBand.high);
      expect(bmReticBand(80), BmReticBand.between);
      expect(bmReticBand(20), BmReticBand.between);
      expect(bmReticBand(19.9), BmReticBand.veryLow);
      for (final f in BmField.values) {
        final (lo, hi) = bmFieldRange(f);
        expect(bmFieldValid(f, lo), true);
        expect(bmFieldValid(f, hi), true);
        expect(bmFieldValid(f, hi + 1), false);
        expect(bmFieldValid(f, lo - 1), false);
        expect(bmFieldValid(f, double.nan), false);
      }
    });

    test('barcha kombinatsiyalar: natija manba jadvaliga mos', () {
      const hbs = [null, 60.0, 104.9, 105.0, 119.9, 120.0, 129.9, 130.0, 160.0];
      const mcvs = [null, 62.0, 79.9, 80.0, 90.0, 100.0, 100.1, 118.0];
      const rdws = [null, 12.0, 14.5, 14.6, 19.0];
      const uppers = [null, 14.5];
      const ferritins = [null, 5.0, 11.9, 12.0, 14.9, 15.0, 29.9, 69.9, 70.0];
      const retics = [null, 10.0, 19.9, 20.0, 50.0, 80.0, 80.1, 150.0];
      var n = 0;
      for (final p in BmPopulation.values) {
        for (final hb in hbs) {
          for (final mcv in mcvs) {
            for (final rdw in rdws) {
              for (final up in uppers) {
                for (final infl in [false, true]) {
                  for (final fer in ferritins) {
                    for (final ret in retics) {
                      n++;
                      final r = bmAssessAnemia(
                        BmAnemiaInput(
                          population: p,
                          hb: hb,
                          mcv: mcv,
                          rdw: rdw,
                          rdwUpper: up,
                          ferritin: fer,
                          inflammation: infl,
                          retic: ret,
                        ),
                      );
                      expect(r.hbCutoff, bmHbCutoff(p));
                      expect(r.anaemic, hb == null ? null : hb < bmHbCutoff(p));
                      expect(
                        r.mcvClass,
                        mcv == null
                            ? null
                            : mcv < 80
                            ? BmMcvClass.micro
                            : mcv > 100
                            ? BmMcvClass.macro
                            : BmMcvClass.normo,
                      );
                      expect(
                        r.rdwHigh,
                        rdw == null || up == null ? null : rdw > up,
                      );
                      final cut = bmFerritinCutoff(p, inflammation: infl);
                      expect(r.ferritinCutoff, cut);
                      expect(
                        r.ferritinLow,
                        fer == null || cut == null ? null : fer < cut,
                      );
                      expect(
                        r.reticBand,
                        ret == null
                            ? null
                            : ret > 80
                            ? BmReticBand.high
                            : ret < 20
                            ? BmReticBand.veryLow
                            : BmReticBand.between,
                      );
                      if (r.hasPattern) {
                        expect(
                          bmPatterns[(r.mcvClass!, r.rdwHigh!)],
                          isNotNull,
                        );
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      expect(n, greaterThan(100000));
    });

    test('retikulotsit misoli: manba formulasi bo‘yicha', () {
      final ex = bmWorkedExample();
      // 15 / 500 × 100 = 3 %; 3,0 × 3 × 10 = 90 ×10⁹/L; 3 × 30 / 45 = 2 %.
      expect(ex.percent, closeTo(3.0, 1e-9));
      expect(ex.absolute, closeTo(90.0, 1e-9));
      expect(ex.corrected, closeTo(2.0, 1e-9));
    });
  });

  for (final lang in AppLanguage.values) {
    testWidgets('barcha ekranlar ochiladi (${lang.name})', (tester) async {
      final s = await makeServices(tester, language: lang);
      await pumpApp(tester, s, size: const Size(390, 1600));
      final l = lookupAppLocalizations(Locale(lang.name));
      await goTo(tester, '/lab');
      final card = find.text(l.bloodMorphLabCardBody);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.byType(BloodMorphScreen), findsOne);
      expect(find.text(BmL.draftNote.of(lang.name)), findsOne);
      for (final r in _routes) {
        await goTo(tester, '$bmBase/$r');
        expect(tester.takeException(), isNull, reason: r);
      }
      for (final f in bmFindings) {
        await goTo(tester, '$bmBase/rbc/${f.id}');
        expect(find.text(f.name.of(lang.name)), findsWidgets, reason: f.id);
        if (f.image case final img?) {
          expect(
            find.byKey(ValueKey('bm-photo-${img.file}')),
            findsOne,
            reason: f.id,
          );
        }
        expect(tester.takeException(), isNull, reason: f.id);
      }
      await goTo(tester, '$bmBase/rbc/unknown');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tor ekran (320 px, ru): toshib ketish yo‘q', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.ru);
    await pumpApp(tester, s, size: const Size(320, 6000));
    for (final r in [
      '',
      for (final r in _routes) '/$r',
      for (final f in bmFindings) '/rbc/${f.id}',
    ]) {
      await goTo(tester, '$bmBase$r');
      expect(tester.takeException(), isNull, reason: r);
    }
    // Yordamchi natijasi (eng uzun matnlar bilan) ham sig'adi.
    await goTo(tester, '$bmBase/anemia');
    await tester.enterText(find.byKey(const ValueKey('bm-in-hb')), '95');
    await tester.enterText(find.byKey(const ValueKey('bm-in-mcv')), '72');
    await tester.enterText(find.byKey(const ValueKey('bm-in-rdw')), '18');
    await tester.enterText(find.byKey(const ValueKey('bm-in-rdwUpper')), '15');
    await tester.enterText(find.byKey(const ValueKey('bm-in-ferritin')), '8');
    await tester.enterText(find.byKey(const ValueKey('bm-in-retic')), '50');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bm-pattern')), findsOne);
    expect(tester.takeException(), isNull);
    // Mashq savoli va javobdan keyingi izoh ham sig'adi.
    await goTo(tester, '$bmBase/quiz');
    await tester.tap(find.byKey(const ValueKey('bm-quiz-start')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bm-opt-0')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('yordamchi: kiritish → guruh, ferritin, retikulotsit', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '$bmBase/anemia');
    expect(find.text(BmL.emptyHint.of('uz')), findsOne);
    await tester.tap(find.byKey(const ValueKey('bm-pop-man15to65')));
    await tester.enterText(find.byKey(const ValueKey('bm-in-hb')), '110');
    await tester.enterText(find.byKey(const ValueKey('bm-in-mcv')), '108');
    await tester.pumpAndSettle();
    // RDW chegarasi yo'q — faqat MCV bo'yicha.
    expect(find.byKey(const ValueKey('bm-mcv-only')), findsOne);
    expect(find.text(BmL.anaemicYes.of('uz')), findsOne);
    expect(find.text(BmL.mcvClasses[BmMcvClass.macro]!.of('uz')), findsOne);
    await tester.enterText(find.byKey(const ValueKey('bm-in-rdw')), '17');
    await tester.enterText(
      find.byKey(const ValueKey('bm-in-rdwUpper')),
      '14,5',
    );
    await tester.pumpAndSettle();
    expect(
      find.text(bmPatterns[(BmMcvClass.macro, true)]!.pattern.of('uz')),
      findsOne,
    );
    await tester.enterText(find.byKey(const ValueKey('bm-in-ferritin')), '40');
    await tester.pumpAndSettle();
    expect(find.text(BmL.ferritinNotLow.of('uz')), findsOne);
    await tester.tap(find.byKey(const ValueKey('bm-inflammation')));
    await tester.pumpAndSettle();
    expect(find.text(BmL.ferritinLow.of('uz')), findsOne);
    await tester.enterText(find.byKey(const ValueKey('bm-in-retic')), '10');
    await tester.pumpAndSettle();
    expect(find.text(BmL.reticBands[BmReticBand.veryLow]!.of('uz')), findsOne);
    // Noto'g'ri qiymat — xato matni, natija yo'qolmaydi.
    await tester.enterText(find.byKey(const ValueKey('bm-in-hb')), '9999');
    await tester.pumpAndSettle();
    expect(find.text(BmL.invalid.of('uz')), findsOne);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kartada rasm, muallif, manba ko‘rinadi; kattalashtirish', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 5000));
    final f = bmFinding('schistocytes')!;
    await goTo(tester, '$bmBase/rbc/${f.id}');
    expect(find.text(BmL.seeTitle.of('uz')), findsOne);
    expect(find.text(BmL.notDiagnosis.of('uz')), findsOne);
    expect(find.text(f.image!.author), findsOne);
    expect(find.text(f.image!.license), findsOne);
    expect(find.textContaining(BmSources.adewoyin2014.citation), findsWidgets);
    await tester.tap(find.byKey(ValueKey('bm-photo-${f.image!.file}')));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOne);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
    // Rasmsiz karta — "rasm topilmadi" belgisi.
    await goTo(tester, '$bmBase/rbc/macrocytes');
    expect(find.text(BmL.noPhoto.of('uz')), findsOne);
    // Trombotsitlar: uchala karta va leykoformula havolasi.
    await goTo(tester, '$bmBase/platelets');
    for (final p in bmPlatelets) {
      expect(find.byKey(ValueKey('bm-plt-${p.id}')), findsOne);
    }
    // Ro'yxat dangasa quriladi — havolagacha aylantiramiz.
    final leuko = find.byKey(const ValueKey('bm-leuko-link'));
    await tester.scrollUntilVisible(
      leuko,
      600,
      scrollable: find.byType(Scrollable).first,
    );
    expect(leuko, findsOne);
    await tester.tap(leuko);
    await tester.pumpAndSettle();
    expect(find.byType(BmPlateletsScreen), findsNothing);
    expect(tester.takeException(), isNull);
    // Retikulotsitlar: mavjud kalkulyatorga havola ochiladi.
    await goTo(tester, '$bmBase/retic');
    final calc = find.byKey(const ValueKey('bm-retic-calc'));
    await tester.ensureVisible(calc);
    await tester.tap(calc);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(BmReticScreen), findsNothing);
  });

  testWidgets('mashq: javob berib, natijagacha', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '$bmBase/quiz');
    final l = lookupAppLocalizations(const Locale('uz'));
    await tester.tap(find.byKey(const ValueKey('bm-quiz-start')));
    await tester.pumpAndSettle();
    const total = bmPictureQuizSize + bmKnowledgeQuizSize;
    for (var i = 0; i < total; i++) {
      if (i < bmPictureQuizSize) {
        // Savolda rasm bor (nomi ekran o'quvchiga aytilmaydi).
        expect(find.byType(BmPhoto), findsOne);
        expect(
          tester.widget<BmPhoto>(find.byType(BmPhoto)).semanticLabel,
          BmL.quizImageLabel.of('uz'),
        );
      } else {
        expect(find.byType(BmPhoto), findsNothing);
      }
      await tester.tap(find.byKey(const ValueKey('bm-opt-0')));
      await tester.pumpAndSettle();
      final next = find.text(i == total - 1 ? l.quizFinish : l.quizNext);
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text(l.quizDoneTitle), findsOne);
  });

  testWidgets('Lab: qon morfologiyasi kartasi gistologiyadan keyin, ochiladi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 1600));
    final l = lookupAppLocalizations(const Locale('uz'));
    await goTo(tester, '/lab');
    expect(find.text(l.bloodMorphTitle), findsOne);
    expect(find.text(l.bloodMorphLabCardBody), findsOne);
    final histo = tester.getTopLeft(find.text(l.histoTitle)).dy;
    final morph = tester.getTopLeft(find.text(l.bloodMorphTitle)).dy;
    expect(morph, greaterThan(histo));
    await tester.ensureVisible(find.text(l.bloodMorphTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.bloodMorphTitle));
    await tester.pumpAndSettle();
    expect(find.byType(BloodMorphScreen), findsOne);
    expect(tester.takeException(), isNull);
  });

  test('tibbiy ko‘rib chiqish 2026-10-18: trombotsit/eritrotsit nisbati', () {
    // "1 per 500–1000 red cells" (WHO 2003 9.14) contradicts its own
    // reference range; replaced with Adewoyin 2014 (7–15 per x100 field).
    for (final f in bmPlateletIntro) {
      for (final v in f.text.values.values) {
        expect(v, isNot(contains('500–1000')));
      }
    }
    final estimate = bmPlateletIntro[1].text.values;
    expect(estimate['en'], contains('7–15'));
    expect(estimate['ru'], contains('15–20 ×10⁹/л'));
    expect(estimate['uz'], contains('15–20 ×10⁹/L'));
  });
}
