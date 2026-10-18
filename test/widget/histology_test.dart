import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/histology/histology_content.dart';
import 'package:labguide/features/histology/histology_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/tools/calc_info.dart';
import 'package:labguide/features/tools/sources_panel.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

const _langs = ['uz', 'ru', 'en'];

void _full(LocalizedText t, String reason) {
  for (final lang in _langs) {
    expect(t.values[lang]?.trim(), isNotEmpty, reason: '$reason $lang');
  }
}

void _fact(HistoFact f, String reason) {
  _full(f.text, reason);
  expect(f.refs, isNotEmpty, reason: reason);
  for (final r in f.refs) {
    expect(r.locator.trim(), isNotEmpty, reason: reason);
    expect(HistoSources.all, contains(r.source), reason: reason);
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

const _routes = ['items', 'stains', 'quiz', 'credits'];

void main() {
  setUpAll(loadAppFonts);

  group('kontent', () {
    test('hamma matn 3 tilda, har da’voda manba va joy bor', () {
      expect(File(histoCardImage).existsSync(), true);
      expect({for (final i in histoItems) i.id}.length, histoItems.length);
      for (final item in histoItems) {
        _full(item.name, item.id);
        expect(item.look, isNotEmpty, reason: item.id);
        for (final f in item.facts) {
          _fact(f, item.id);
        }
        expect(item.refs, isNotEmpty, reason: item.id);
      }
      // Har guruhda kamida bitta karta; M2 a'zolari — jigar va buyrak.
      for (final g in HistoGroup.values) {
        expect(histoItems.where((i) => i.group == g), isNotEmpty);
        _full(HisL.groups[g]!, g.name);
      }
      expect(
        {
          for (final i in histoItems.where((i) => i.group == HistoGroup.organ))
            i.id,
        },
        {'liver', 'kidney'},
      );
      for (final s in histoStains) {
        _full(s.name, s.id);
        expect(s.facts, isNotEmpty, reason: s.id);
        for (final f in s.facts) {
          _fact(f, s.id);
        }
      }
      for (final t in [
        HisL.subtitle,
        HisL.photoNote,
        HisL.atlasTitle,
        HisL.atlasSub,
        HisL.stainsTitle,
        HisL.stainsSub,
        HisL.quizTitle,
        HisL.quizSub,
        HisL.creditsTitle,
        HisL.creditsSub,
        HisL.creditsIntro,
        HisL.classification,
        HisL.lookTitle,
        HisL.keyTitle,
        HisL.functionTitle,
        HisL.whereTitle,
        HisL.confuseTitle,
        HisL.imageTitle,
        HisL.stain,
        HisL.stainNotStated,
        HisL.captionTitle,
        HisL.checked,
        HisL.fileTitle,
        HisL.noPhoto,
        HisL.resized,
        HisL.stainsIntro,
        HisL.stainExample,
        HisL.quizPrompt,
        HisL.quizIntro,
        HisL.quizStart,
        HisL.quizImageLabel,
      ]) {
        _full(t, 'HisL');
      }
      for (final s in HistoSources.all) {
        expect(s.url, startsWith('https://'), reason: s.id);
        expect(s.citation, isNotEmpty);
      }
      expect(
        {for (final s in HistoSources.all) s.id}.length,
        HistoSources.all.length,
      );
    });

    test('har rasm fayli bor, o‘lchami to‘g‘ri, muallif va litsenziya bor', () {
      const allowed = {
        'CC0 1.0',
        'CC BY 4.0',
        'CC BY-SA 2.0',
        'CC BY-SA 3.0',
        'CC BY-SA 4.0',
      };
      final images = histoAllImages();
      // 20 ta karta rasmi + PAS namunasi.
      expect(
        images.length,
        histoItems.where((i) => i.image != null).length + 1,
      );
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
        expect(img.author.trim(), isNotEmpty, reason: img.file);
        expect(allowed, contains(img.license), reason: img.file);
        expect(img.licenseUrl, startsWith('https://creativecommons.org/'));
        expect(img.caption.trim(), isNotEmpty, reason: img.file);
        expect(img.commonsTitle, isNot(startsWith('File:')));
        expect(
          img.sourcePage,
          startsWith('https://commons.wikimedia.org/wiki/'),
        );
        _full(img.captionTr, img.file);
        if (img.stain case final s?) _full(s, img.file);
        if (img.labels case final s?) _full(s, img.file);
      }
      // Bo'limning yangi rasmlari jami ≤ 15 MB.
      final dir = Directory('assets/histology');
      final all = dir
          .listSync(recursive: true)
          .whereType<File>()
          .fold<int>(0, (s, f) => s + f.lengthSync());
      expect(all, lessThan(15 * 1024 * 1024));
      expect(total, lessThanOrEqualTo(all));
      // Rasmsiz karta bo'lsa — mashqqa kirmaydi.
      for (final i in histoItems.where((i) => i.image == null)) {
        expect(histoQuizPool(), isNot(contains(i)));
      }
    });

    test('bo‘yoq faqat fayl sahifasida yozilganda ko‘rsatiladi', () {
      // Berkshire fayllarida bo'yoq yozilmagan → null.
      for (final i in histoItems) {
        final img = i.image;
        if (img == null) continue;
        final stated =
            img.caption.contains('H&E') ||
            img.caption.contains('Reticulin') ||
            img.caption.contains('PAS');
        expect(img.stain != null, stated, reason: i.id);
      }
      expect(histoPasImage.stain, isNotNull);
    });

    test('mashq: to‘g‘ri javob — ko‘rsatilgan rasm, variantlar takrorsiz', () {
      final pool = histoQuizPool();
      expect(pool.length, greaterThanOrEqualTo(histoQuizSize));
      for (final MapEntry(key: id, value: ds) in histoDistractors.entries) {
        expect(histoItem(id), isNotNull, reason: id);
        expect(ds, hasLength(3), reason: id);
        expect({id, ...ds}.length, 4, reason: id);
        for (final d in ds) {
          expect(histoItem(d), isNotNull, reason: '$id → $d');
        }
      }
      for (final i in histoItems.where((i) => i.image != null && i.quiz)) {
        expect(histoDistractors.containsKey(i.id), true, reason: i.id);
      }
      for (var seed = 0; seed < 20; seed++) {
        final qs = buildHistoQuiz(Random(seed));
        expect(qs, hasLength(histoQuizSize));
        expect({for (final q in qs) q.item.id}.length, qs.length);
        for (final q in qs) {
          expect(q.item.image, isNotNull);
          expect(q.item.quiz, true);
          expect(q.question.options, hasLength(4));
          for (final lang in _langs) {
            expect(
              {for (final o in q.question.options) o.text.of(lang)}.length,
              4,
              reason: '${q.item.id} $lang',
            );
          }
          // To'g'ri javob — aynan ko'rsatilgan rasmning nomi.
          expect(
            q.question.options[q.question.correctIndex].text,
            same(q.item.name),
          );
          expect(q.question.basis, same(q.item.key.text));
        }
      }
    });
  });

  for (final lang in AppLanguage.values) {
    testWidgets('barcha ekranlar ochiladi (${lang.name})', (tester) async {
      final s = await makeServices(tester, language: lang);
      await pumpApp(tester, s, size: const Size(390, 1600));
      final l = lookupAppLocalizations(Locale(lang.name));
      await goTo(tester, '/lab');
      final card = find.text(l.histoLabCardBody);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.byType(HistologyScreen), findsOne);
      expect(
        find.text(
          l.sourceLine(shortCitation(HistoSources.umich, citePage: l.citePage)),
        ),
        findsOne,
      );
      for (final r in _routes) {
        await goTo(tester, '$histoBase/$r');
        expect(tester.takeException(), isNull, reason: r);
      }
      for (final i in histoItems) {
        await goTo(tester, '$histoBase/items/${i.id}');
        expect(find.text(i.name.of(lang.name)), findsWidgets, reason: i.id);
        // Rasm sahifa boshida; muallif bloki pastda (ro'yxat dangasa
        // quriladi) — u alohida testda tekshiriladi.
        expect(
          find.byKey(ValueKey('histo-photo-${i.image!.file}')),
          findsOne,
          reason: i.id,
        );
        expect(tester.takeException(), isNull, reason: i.id);
      }
      await goTo(tester, '$histoBase/items/unknown');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tor ekran (320 px, ru): toshib ketish yo‘q', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.ru);
    await pumpApp(tester, s, size: const Size(320, 4000));
    for (final r in [
      '',
      for (final r in _routes) '/$r',
      for (final i in histoItems) '/items/${i.id}',
    ]) {
      await goTo(tester, '$histoBase$r');
      expect(tester.takeException(), isNull, reason: r);
    }
    // Mashq savoli va javobdan keyingi izoh ham sig'adi.
    await goTo(tester, '$histoBase/quiz');
    await tester.tap(find.byKey(const ValueKey('histo-quiz-start')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('histo-opt-0')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('kartada rasm, bo‘yoq, belgilar va manba ko‘rinadi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '$histoBase/items/liver');
    final liver = histoItem('liver')!;
    expect(find.byKey(const ValueKey('histo-photo-liver')), findsOne);
    expect(find.text(liver.image!.stain!.of('uz')), findsWidgets);
    expect(find.text(HisL.lookTitle.of('uz')), findsOne);
    expect(find.textContaining(liver.look.first.text.of('uz')), findsOne);
    expect(find.text(liver.image!.author), findsOne);
    expect(find.textContaining(HistoSources.boyd2020.citation), findsWidgets);
    // Bo'yog'i yozilmagan rasm — "manbada ko'rsatilmagan".
    await goTo(tester, '$histoBase/items/simple_columnar');
    expect(find.text(HisL.stainNotStated.of('uz')), findsWidgets);
    // Rasmni kattalashtirib ko'rish va yopish.
    await tester.tap(find.byKey(const ValueKey('histo-photo-simple_columnar')));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOne);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
  });

  testWidgets('mashq: javob berib, natijagacha', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '$histoBase/quiz');
    final l = lookupAppLocalizations(const Locale('uz'));
    await tester.tap(find.byKey(const ValueKey('histo-quiz-start')));
    await tester.pumpAndSettle();
    for (var i = 0; i < histoQuizSize; i++) {
      // Savolda rasm bor (nomi ekran o'quvchiga aytilmaydi).
      expect(find.byType(HistoPhoto), findsOne);
      expect(
        tester.widget<HistoPhoto>(find.byType(HistoPhoto)).semanticLabel,
        HisL.quizImageLabel.of('uz'),
      );
      await tester.tap(find.byKey(const ValueKey('histo-opt-0')));
      await tester.pumpAndSettle();
      final next = find.text(
        i == histoQuizSize - 1 ? l.quizFinish : l.quizNext,
      );
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text(l.quizDoneTitle), findsOne);
  });

  testWidgets('Lab: gistologiya kartasi qon guruhidan keyin, ochiladi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 1600));
    final l = lookupAppLocalizations(const Locale('uz'));
    await goTo(tester, '/lab');
    expect(find.text(l.histoTitle), findsOne);
    expect(find.text(l.histoLabCardBody), findsOne);
    final blood = tester.getTopLeft(find.text(l.bloodGroupTitle)).dy;
    final histo = tester.getTopLeft(find.text(l.histoTitle)).dy;
    expect(histo, greaterThan(blood));
    await tester.ensureVisible(find.text(l.histoTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.histoTitle));
    await tester.pumpAndSettle();
    expect(find.byType(HistologyScreen), findsOne);
    expect(tester.takeException(), isNull);
  });

  test('CalcRef lokatorlari sahifa formatida', () {
    // "p. 17" → interfeysda "17-bet" (localizePages).
    for (final i in histoItems) {
      for (final r in i.refs.where((r) => r.source == HistoSources.umich)) {
        expect(r.locator, matches(RegExp(r'^p\. \d')), reason: i.id);
        expect(localizePages(r.locator, (p) => '$p-bet'), contains('-bet'));
      }
    }
  });

  test('tibbiy ko‘rib chiqish 2026-10-18: LFB asosan miyelin', () {
    final lfb = histoStains.firstWhere((s) => s.id == 'luxol').facts.first;
    expect(lfb.text.values['en'], startsWith('Stains mainly myelin'));
    expect(lfb.text.values['ru'], contains('в основном миелин'));
    expect(lfb.text.values['uz'], contains('asosan miyelinni'));
  });

  test(
    'adabiyot tekshiruvi 2026-10-18: o‘zbekcha atamalar darslik bo‘yicha',
    () {
      HistoItem item(String id) => histoItems.firstWhere((i) => i.id == id);
      // Zokirova 2025, 28–30-b.: "o'zgaruvchan epiteliy".
      final tr = item('transitional');
      expect(tr.name.of('uz'), 'O‘zgaruvchan epiteliy');
      expect(
        tr.look.first.text.of('uz'),
        contains('Manba: Zokirova N.B., 2025'),
      );
      expect(tr.look.first.text.of('ru'), contains('Источник: Zokirova'));
      expect(tr.look.first.text.of('en'), contains('Source: Zokirova'));
      expect(
        tr.refs.map((r) => r.source.id),
        contains(HistoSources.zokirova2025.id),
      );
      for (final i in histoItems) {
        for (final f in [
          ...i.look,
          i.key,
          i.function,
          if (i.where != null) i.where!,
          if (i.confuse != null) i.confuse!,
        ]) {
          expect(f.text.of('uz'), isNot(contains('O‘tuvchi epiteliy')));
        }
      }
      // Jiyak (cho'tkasimon hoshiya) — 118-b.
      final kidneyFacts = [for (final i in histoItems) ...i.look]
          .where((f) => f.text.of('uz').contains('Proksimal kanalchalar'));
      expect(kidneyFacts.single.text.of('uz'), contains('jiyak'));
      expect(kidneyFacts.single.text.of('uz'), contains('118-b.'));
    },
  );
}
