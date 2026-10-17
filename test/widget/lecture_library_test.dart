// Ma'ruza bo'limi: BARCHA tayyor taqdimotlar (modul bo'yicha), qidiruv
// (lotin/kirill, ruscha, inglizcha), filtr chiplari, bo'sh holat, taqdimotni
// 3 tilda ochish, 320 px / katta shrift.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/lecture_decks.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/harness.dart';

const _tall = Size(390, 2600);

Future<DeckCatalog> _catalog(WidgetTester tester) async =>
    (await tester.runAsync(() => DeckCatalog.load(rootBundle)))!;

/// Deck faylini oldindan yuklaydi (pleyer birinchi kadrda sinxron o'qiydi).
Future<LectureDeck> _preload(
  WidgetTester tester,
  String id,
  String lang,
) async {
  final c = await _catalog(tester);
  final e = c.byId(id)!;
  return (await tester.runAsync(
    () => DeckCatalog.loadDeck(rootBundle, e, e.resolveLang(lang)),
  ))!;
}

Future<void> _search(WidgetTester tester, String q) async {
  await tester.enterText(find.byKey(const ValueKey('lecture-search')), q);
  // debounce (200 ms)
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<AppLocalizations> _open(
  WidgetTester tester, {
  AppLanguage lang = AppLanguage.uz,
  Size size = _tall,
  double textScale = 1,
  AppRole role = AppRole.teacher,
}) async {
  installDiffFakes();
  final s = await makeServices(tester, role: role, language: lang);
  await pumpApp(tester, s, size: size, textScale: textScale);
  await goTo(tester, '/learn/lecture');
  return lookupAppLocalizations(lang.locale);
}

String _plain(WidgetTester tester, Finder f) {
  final t = tester.widget<Text>(f);
  return t.data ?? t.textSpan!.toPlainText();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'ro‘yxat: hamma decklar modul bo‘yicha guruhlangan, sonlari bilan',
    (tester) async {
      final l = await _open(tester);
      final c = await _catalog(tester);
      expect(c.decks.length, 124);
      // Har deck o'z qatorida (har deck bir marta).
      for (final d in c.decks) {
        expect(
          find.byKey(ValueKey('deck-${d.id}')),
          findsOneWidget,
          reason: d.id,
        );
      }
      // 9 modul + amaliy protokollar guruhi; soni, slaydlar, tillar ko'rsatilgan.
      for (final m in c.modules) {
        final decks = c.inModule(m.n);
        expect(find.byKey(ValueKey('lecture-group-m${m.n}')), findsOneWidget);
        final slides = decks.fold<int>(0, (a, d) => a + d.slides('uz'));
        final count = _plain(
          tester,
          find.byKey(ValueKey('lecture-group-count-m${m.n}')),
        );
        expect(count, contains(l.lectureDecksCount(decks.length)));
        expect(count, contains(l.lectureSlidesCount(slides)));
        expect(count, contains('UZ'));
      }
      final protos = c.protocols;
      expect(protos.length, 26);
      expect(
        find.byKey(const ValueKey('lecture-group-protocols')),
        findsOneWidget,
      );
      expect(
        _plain(
          tester,
          find.byKey(const ValueKey('lecture-group-count-protocols')),
        ),
        contains(l.lectureDecksCount(26)),
      );
      expect(find.text(l.lectureFilterProtocols), findsWidgets);
      // d001 (muallif decki) shu ro'yxatda, faqat o'zbekcha.
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('deck-d001')),
          matching: find.textContaining('30'),
        ),
        findsOneWidget,
      );
      // Avtomatik taqdimot kirishi saqlangan.
      expect(find.byKey(const ValueKey('lecture-auto-entry')), findsOneWidget);
      expect(find.text(l.autoPresTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('o‘quvchi ham ro‘yxatni ko‘radi va taqdimotni ochadi', (
    tester,
  ) async {
    final deck = await _preload(tester, 'd012', 'uz');
    final l = await _open(tester, role: AppRole.student);
    await _tapKey(tester, 'deck-d012');
    expect(find.text(l.lectureCounter(1, deck.slides.length)), findsOneWidget);
  });

  group('qidiruv', () {
    testWidgets(
      'lotin: tahlil nomi — deck va mos slaydlar ajratib ko‘rsatiladi',
      (tester) async {
        final l = await _open(tester);
        final c = await _catalog(tester);
        await _search(tester, 'glyukoza');
        // Natijalar soni va birinchi deck (sarlavhasi “Glyukozani…” bilan boshlanadi).
        final n = DeckSearch(c).search('glyukoza', lang: 'uz').length;
        expect(
          _plain(tester, find.byKey(const ValueKey('lecture-result-count'))),
          l.lectureResultsFound(n),
        );
        expect(find.byKey(const ValueKey('result-d059')), findsOneWidget);
        // Ro'yxat rejimidagi qatorlar yo'q; faqat natijalar.
        expect(find.byKey(const ValueKey('deck-d012')), findsNothing);
        expect(find.byKey(const ValueKey('lecture-auto-entry')), findsNothing);
        // “N ta slayd mos” + mos slayd sarlavhasi.
        final hit = DeckSearch(c)
            .search('glyukoza', lang: 'uz')
            .firstWhere((h) => h.entry.id == 'd045');
        expect(
          _plain(tester, find.byKey(const ValueKey('match-count-d045'))),
          l.lectureSlidesMatch(hit.matchedSlides),
        );
        final line = find.byKey(const ValueKey('hit-d045-2'));
        expect(line, findsOneWidget);
        // Mos qism ajratilgan (alohida qalin TextSpan).
        final rich = tester.widget<Text>(
          find.descendant(of: line, matching: find.byType(Text)),
        );
        final spans = (rich.textSpan! as TextSpan).children!.cast<TextSpan>();
        final marked = spans.where(
          (s) => s.style?.fontWeight == FontWeight.w800,
        );
        expect(marked.map((s) => s.text), ['glyukoza']);
      },
    );

    testWidgets('kirill (o‘zbekcha) so‘rov ham topadi', (tester) async {
      await _open(tester);
      await _search(tester, 'глюкоза');
      expect(find.byKey(const ValueKey('result-d045')), findsOneWidget);
      expect(find.byKey(const ValueKey('result-d059')), findsOneWidget);
      // O'zbekcha ilovada slayd sarlavhasi lotinda, mos qism ajratilgan.
      expect(find.byKey(const ValueKey('hit-d045-2')), findsOneWidget);
    });

    testWidgets('apostrof farq qilmaydi: o‘zbekiston', (tester) async {
      await _open(tester);
      await _search(tester, "o'zbekiston");
      expect(find.byKey(const ValueKey('result-d002')), findsOneWidget);
    });

    testWidgets('ruscha ilova: ruscha so‘z, slayd sarlavhasi ruscha', (
      tester,
    ) async {
      final l = await _open(tester, lang: AppLanguage.ru);
      await _search(tester, 'печень');
      expect(find.byKey(const ValueKey('result-d049')), findsOneWidget);
      expect(find.textContaining('Стеатоз', findRichText: true), findsWidgets);
      final c = await _catalog(tester);
      final n = DeckSearch(c).search('печень', lang: 'ru').length;
      expect(
        _plain(tester, find.byKey(const ValueKey('lecture-result-count'))),
        l.lectureResultsFound(n),
      );
    });

    testWidgets('inglizcha ilova: inglizcha so‘z', (tester) async {
      await _open(tester, lang: AppLanguage.en);
      await _search(tester, 'fasting plasma glucose');
      expect(find.byKey(const ValueKey('result-d045')), findsOneWidget);
      expect(find.byKey(const ValueKey('hit-d045-2')), findsOneWidget);
      expect(
        find.textContaining('Fasting plasma glucose', findRichText: true),
        findsWidgets,
      );
    });

    testWidgets('boshqa tildagi so‘z: slayd topilgan tilda ochiladi', (
      tester,
    ) async {
      // O'zbekcha ilova + inglizcha so'z: deck topiladi; slaydlar EN (belgi bilan).
      final deck = await _preload(tester, 'd045', 'en');
      final l = await _open(tester);
      await _search(tester, 'fasting plasma');
      expect(find.textContaining('(EN)', findRichText: true), findsWidgets);
      await _tapKey(tester, 'hit-d045-2');
      expect(
        find.text(l.lectureCounter(3, deck.slides.length)),
        findsOneWidget,
      );
      expect(find.textContaining('Fasting plasma glucose'), findsWidgets);
    });

    testWidgets('natijani bosish — mos slayddan ochadi', (tester) async {
      final deck = await _preload(tester, 'd045', 'uz');
      final l = await _open(tester);
      await _search(tester, 'glyukoza');
      await _tapKey(tester, 'hit-d045-2');
      // “hit-d045-2”: 3-slayd (indeks 2).
      expect(
        find.text(l.lectureCounter(3, deck.slides.length)),
        findsOneWidget,
      );
      expect(find.text('Och qoringa plazma glyukozasi'), findsOneWidget);
      // Yopilganda qidiruv holati saqlanadi.
      await tester.tap(find.byTooltip(l.lectureClose));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('result-d045')), findsOneWidget);
    });

    testWidgets('bo‘sh holat va tozalash', (tester) async {
      final l = await _open(tester);
      await _search(tester, 'zzxxqq');
      expect(find.byKey(const ValueKey('lecture-empty')), findsOneWidget);
      expect(find.text(l.lectureNoResultsTitle), findsOneWidget);
      await tester.tap(find.text(l.lectureClearFilters));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('lecture-empty')), findsNothing);
      expect(find.byKey(const ValueKey('deck-d012')), findsOneWidget);
      expect(find.byKey(const ValueKey('lecture-auto-entry')), findsOneWidget);
    });

    testWidgets(
      'debounce: so‘rov 200 ms dan keyin qo‘llanadi, tozalash — darhol',
      (tester) async {
        await _open(tester);
        await tester.enterText(
          find.byKey(const ValueKey('lecture-search')),
          'glyukoza',
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          find.byKey(const ValueKey('lecture-result-count')),
          findsNothing,
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(
          find.byKey(const ValueKey('lecture-result-count')),
          findsOneWidget,
        );
        await tester.enterText(
          find.byKey(const ValueKey('lecture-search')),
          '',
        );
        await tester.pump();
        expect(
          find.byKey(const ValueKey('lecture-result-count')),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('deck-d012')), findsOneWidget);
      },
    );
  });

  group('filtr chiplari', () {
    testWidgets('modul, amaliy protokollar, hammasi', (tester) async {
      final l = await _open(tester);
      final c = await _catalog(tester);
      await _tapKey(tester, 'lecture-filter-m3');
      for (final d in c.decks) {
        final inM3 = d.kind == DeckKind.day && d.module == 3;
        expect(
          find.byKey(ValueKey('deck-${d.id}')),
          inM3 ? findsOneWidget : findsNothing,
          reason: d.id,
        );
      }
      expect(find.byKey(const ValueKey('lecture-group-m3')), findsOneWidget);
      expect(find.byKey(const ValueKey('lecture-group-m4')), findsNothing);
      // Filtr paytida o'quv dasturi mavzulari bo'limi yashirin.
      expect(find.text(l.lectureTopicsAutoTitle), findsNothing);

      await _tapKey(tester, 'lecture-filter-protocols');
      expect(
        find.byKey(const ValueKey('lecture-group-protocols')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('lecture-group-m3')), findsNothing);
      expect(
        find.byKey(const ValueKey('deck-kapillyar-qon-olish')),
        findsOneWidget,
      );

      await _tapKey(tester, 'lecture-filter-all');
      expect(find.byKey(const ValueKey('lecture-group-m3')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('lecture-group-protocols')),
        findsOneWidget,
      );
      expect(find.text(l.lectureTopicsAutoTitle), findsOneWidget);
    });

    testWidgets('til filtri: RU da faqat o‘zbekcha d001 yo‘q', (tester) async {
      await _open(tester);
      expect(find.byKey(const ValueKey('deck-d001')), findsOneWidget);
      await _tapKey(tester, 'lecture-lang-ru');
      expect(find.byKey(const ValueKey('deck-d001')), findsNothing);
      expect(find.byKey(const ValueKey('deck-d002')), findsOneWidget);
      await _tapKey(tester, 'lecture-lang-all');
      expect(find.byKey(const ValueKey('deck-d001')), findsOneWidget);
    });

    testWidgets('filtr + qidiruv birga', (tester) async {
      await _open(tester);
      await _search(tester, 'glyukoza');
      expect(find.byKey(const ValueKey('result-d045')), findsOneWidget);
      await _tapKey(tester, 'lecture-filter-protocols');
      expect(find.byKey(const ValueKey('result-d045')), findsNothing);
      expect(
        find.byKey(const ValueKey('result-glyukoza-gox-pod-fotometrik')),
        findsOneWidget,
      );
      await _tapKey(tester, 'lecture-filter-m2');
      expect(find.byKey(const ValueKey('lecture-empty')), findsOneWidget);
    });
  });

  for (final lang in AppLanguage.values) {
    testWidgets(
      'taqdimotni ochish (${lang.name}): boshi, oxiri — Adabiyotlar',
      (tester) async {
        final deck = await _preload(tester, 'd012', lang.name);
        expect(deck.lang, lang.name);
        final l = await _open(tester, lang: lang);
        await _tapKey(tester, 'deck-d012');
        final n = deck.slides.length;
        expect(find.text(l.lectureCounter(1, n)), findsOneWidget);
        expect(find.text(deck.slides.first.title), findsOneWidget);
        // Manbali taqdimotda qoralama izohi yo'q (egasi qarori); boshqa til
        // ogohlantirishi ham yo'q.
        expect(find.textContaining(l.lectureDraftNotice), findsNothing);
        expect(find.textContaining(l.lectureUzOnly), findsNothing);
        await tester.tap(find.byTooltip(l.lectureClose));
        await tester.pumpAndSettle();
        // Oxirgi slayd: Adabiyotlar.
        await goTo(tester, '/learn/lecture/deck/d012?s=9999');
        expect(find.text(l.lectureCounter(n, n)), findsOneWidget);
        expect(
          find.text(
            const {
              'uz': 'Adabiyotlar',
              'ru': 'Литература',
              'en': 'References',
            }[lang.name]!,
          ),
          findsOneWidget,
        );
      },
    );
  }

  testWidgets(
    'til yo‘q: d001 ruscha ilovada o‘zbekcha + ko‘rinadigan ogohlantirish',
    (tester) async {
      final deck = await _preload(tester, 'd001', 'ru');
      expect(deck.lang, 'uz');
      expect(deck.slides.length, 30);
      final l = await _open(tester, lang: AppLanguage.ru);
      await _tapKey(tester, 'deck-d001');
      expect(find.text(l.lectureCounter(1, 30)), findsOneWidget);
      expect(find.textContaining(l.lectureUzOnly), findsOneWidget);
    },
  );

  testWidgets('d001 o‘zbekcha ilovada ogohlantirishsiz, 30 slayd', (
    tester,
  ) async {
    await _preload(tester, 'd001', 'uz');
    final l = await _open(tester);
    await _tapKey(tester, 'deck-d001');
    expect(find.text(l.lectureCounter(1, 30)), findsOneWidget);
    expect(find.textContaining(l.lectureUzOnly), findsNothing);
  });

  testWidgets('shablonlar: rasm, jadval, savol-javob pleyerda chiziladi', (
    tester,
  ) async {
    final deck = await _preload(tester, 'd012', 'uz');
    final l = await _open(tester);
    final figure = deck.slides.indexWhere((s) => s.template == 'figure');
    final table = deck.slides.indexWhere((s) => s.template == 'table');
    final qa = deck.slides.indexWhere((s) => s.template == 'qa');
    expect([figure, table, qa], everyElement(greaterThan(0)));
    final n = deck.slides.length;

    await goTo(tester, '/learn/lecture/deck/d012?s=$figure');
    expect(find.text(l.lectureCounter(figure + 1, n)), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(find.textContaining('Sxema (mikrofoto emas)'), findsOneWidget);
    // Manba qatori har kontent slaydida.
    expect(find.byKey(const ValueKey('lecture-source')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await goTo(tester, '/learn/lecture');
    await goTo(tester, '/learn/lecture/deck/d012?s=$table');
    expect(find.text(l.lectureCounter(table + 1, n)), findsOneWidget);
    expect(find.text(deck.slides[table].rows.first.first), findsOneWidget);

    await goTo(tester, '/learn/lecture');
    await goTo(tester, '/learn/lecture/deck/d012?s=$qa');
    expect(find.text(l.lectureCounter(qa + 1, n)), findsOneWidget);
    final s = deck.slides[qa];
    expect(find.text(s.options[s.correct!]), findsOneWidget);
    expect(find.byKey(const ValueKey('lecture-answer-text')), findsNothing);
    await tester.ensureVisible(find.byKey(const ValueKey('lecture-answer')));
    await tester.tap(find.byKey(const ValueKey('lecture-answer')));
    await tester.pumpAndSettle();
    if (s.explanation != null) {
      expect(find.byKey(const ValueKey('lecture-answer-text')), findsOneWidget);
    }
  });

  testWidgets('amaliy protokol ochiladi (ruscha)', (tester) async {
    final deck = await _preload(tester, 'kapillyar-qon-olish', 'ru');
    final l = await _open(tester, lang: AppLanguage.ru);
    await _tapKey(tester, 'deck-kapillyar-qon-olish');
    expect(find.text(l.lectureCounter(1, deck.slides.length)), findsOneWidget);
    expect(find.text(deck.title!), findsWidgets);
  });

  testWidgets('noma‘lum deck — halol xato holati', (tester) async {
    final l = await _open(tester);
    await goTo(tester, '/learn/lecture/deck/yoq-deck');
    expect(find.text(l.lectureDeckLoadFailed), findsOneWidget);
  });

  testWidgets('1920×1080 proyektor: matnli taqdimot ham sig‘adi', (
    tester,
  ) async {
    final deck = await _preload(tester, 'd012', 'uz');
    final l = await _open(tester, size: const Size(1920, 1080));
    await goTo(tester, '/learn/lecture/deck/d012?s=2');
    expect(find.text(l.lectureCounter(3, deck.slides.length)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final lang in AppLanguage.values) {
    for (final (width, scale) in [(320.0, 1.3), (320.0, 2.0)]) {
      testWidgets(
        'maket: ${lang.name} ${width.toInt()} px ×$scale (ro‘yxat, qidiruv, filtr)',
        (tester) async {
          final l = await _open(
            tester,
            lang: lang,
            size: Size(width, 2600),
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          await _search(tester, 'glucose');
          expect(tester.takeException(), isNull);
          await _search(tester, 'глюкоза');
          expect(tester.takeException(), isNull);
          await _search(tester, 'zzxxqq');
          expect(find.byKey(const ValueKey('lecture-empty')), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text(l.lectureClearFilters));
          await tester.pumpAndSettle();
          await _tapKey(tester, 'lecture-filter-m7');
          await _tapKey(tester, 'lecture-lang-en');
          expect(tester.takeException(), isNull);
          await _tapKey(tester, 'lecture-filter-protocols');
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
