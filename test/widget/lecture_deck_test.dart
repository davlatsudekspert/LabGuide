// Tayyor taqdimot (assets/lectures): 1-mavzu Ma'ruza rejimida — uz/ru/en.
// Qoralama holati halol ko'rsatiladi, ustoz izohi faqat tugma bilan ochiladi.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/lecture_decks.dart';
import 'package:labguide/features/classroom/lecture_screens.dart'
    show lectureTopicRedirect;
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/harness.dart';

const _tall = Size(390, 2400);

void main() {
  setUpAll(loadAppFonts);

  test(
    'asset: har deck mavjud mavzuga biriktirilgan, slaydlar to‘liq',
    () async {
      final decks = await LectureDecks.all(rootBundle);
      final cur = jsonDecode(
        File('assets/curriculum/curriculum.json').readAsStringSync(),
      ) as Map<String, Object?>;
      final ids = {
        for (final m in (cur['modules']! as List).cast<Map<String, Object?>>())
          for (final t in (m['topics']! as List).cast<Map<String, Object?>>())
            t['id']! as String,
      };
      expect(decks.keys, containsAll(['d001-P', 'd001-L']));
      // Tarjimalar (index.json → translations): ru/en, bir xil slaydlar soni.
      for (final lang in ['ru', 'en']) {
        final t = (await LectureDecks.forTopic(
          rootBundle,
          'd001-L',
          lang: lang,
        ))!;
        expect(t.lang, lang);
        expect(t.slides.length, decks['d001-L']!.slides.length);
        expect(t.topics, decks['d001-L']!.topics);
      }
      for (final MapEntry(:key, :value) in decks.entries) {
        expect(ids, contains(key));
        expect(value.draft, isTrue, reason: 'tekshirilmagan — qoralama');
        expect(value.slides.length, greaterThan(10));
        for (final s in value.slides) {
          expect(s.title.trim(), isNotEmpty);
          // Slayd PPTX ko'rinishida — rasm assets'da bo'lishi shart.
          expect(s.image, isNotNull, reason: s.title);
          expect(File(s.image!).existsSync(), isTrue, reason: s.image);
        }
      }
    },
  );

  for (final lang in AppLanguage.values) {
    testWidgets('1-mavzu: tayyor taqdimot (${lang.name})', (tester) async {
      installDiffFakes();
      final l = lookupAppLocalizations(lang.locale);
      // uz — rasmli muallif decki; ru/en — uning tarjimasi (matn shablonida).
      final deck = (await tester.runAsync(
        () => LectureDecks.forTopic(rootBundle, 'd001-P', lang: lang.name),
      ))!;
      expect(deck.lang, lang.name);
      final pictures = lang == AppLanguage.uz;
      final n = deck.slides.length;
      final s = await makeServices(
        tester,
        role: AppRole.teacher,
        language: lang,
      );
      await pumpApp(tester, s, size: _tall);

      await goTo(tester, '/learn/lecture');
      // D-68 (Q1): ro'yxatda tayyor taqdimot bitta qator (d001) — mavzular
      // avtomatik slaydlar bilan ikkinchi marta sanalmaydi.
      expect(find.byKey(const ValueKey('deck-d001')), findsOneWidget);

      // Eski mavzu manzili tayyor deckka yo'naltiriladi. Deck fayli oldindan
      // keshga (pleyer uni asinxron yuklaydi).
      final entry = DeckCatalog.peek(rootBundle)!.byId('d001')!;
      await tester.runAsync(
        () => DeckCatalog.loadDeck(
          rootBundle,
          entry,
          entry.resolveLang(lang.name),
        ),
      );
      await goTo(tester, '/learn/lecture/d001-P');
      expect(routerOf(tester).state.uri.toString(), '/learn/lecture/deck/d001');
      expect(find.text(l.lectureCounter(1, n)), findsOneWidget);
      Finder slideView(int k) => pictures
          ? find.byKey(ValueKey(deck.slides[k].image))
          : find.text(deck.slides[k].title);
      expect(slideView(0), findsWidgets);
      // uz: "Qoralama" yozuvi slayd rasmining o'zida; ru/en (rasmsiz) —
      // halol ogohlantirish slaydda. "Faqat o'zbekcha" endi yo'q.
      expect(deck.draft, isTrue);
      expect(
        find.textContaining(l.lectureDraftNotice),
        pictures ? findsNothing : findsOneWidget,
      );
      expect(find.textContaining(l.lectureUzOnly), findsNothing);

      // Ustoz izohi: yashirin, tugma bilan ochiladi va keyingi slaydda ham
      // ochiq qoladi.
      final withNote = deck.slides.indexWhere((d) => d.note != null);
      for (var i = 0; i < withNote; i++) {
        await tester.tap(find.text(l.lectureNext));
        await tester.pumpAndSettle();
      }
      final slide = deck.slides[withNote];
      expect(slideView(withNote), findsWidgets);
      expect(find.text(slide.note!), findsNothing);
      await tester.tap(find.byTooltip(l.lectureNotesShow));
      await tester.pumpAndSettle();
      expect(find.text(slide.note!), findsOneWidget);
      expect(find.text(l.lectureTeacherNote), findsOneWidget);
      await tester.tap(find.byTooltip(l.lectureNotesHide));
      await tester.pumpAndSettle();
      expect(find.text(slide.note!), findsNothing);

      // Oxirgi slayd — "Oldinga" o'chiq.
      for (var i = withNote; i < n - 1; i++) {
        await tester.tap(find.text(l.lectureNext));
        await tester.pumpAndSettle();
      }
      expect(find.text(l.lectureCounter(n, n)), findsOneWidget);
      expect(slideView(n - 1), findsWidgets);
      await tester.tap(find.text(l.lectureNext));
      await tester.pumpAndSettle();
      expect(find.text(l.lectureCounter(n, n)), findsOneWidget);
    });
  }

  test('mavzu → tayyor deck yo‘naltirish; deck yo‘q bo‘lsa — null', () {
    final catalog = DeckCatalog.parse(
      File('assets/lectures/index_v2.json').readAsStringSync(),
    );
    expect(lectureTopicRedirect(catalog, 'd003-L'), '/learn/lecture/deck/d003');
    expect(lectureTopicRedirect(catalog, 'd001-P'), '/learn/lecture/deck/d001');
    expect(lectureTopicRedirect(catalog, 'yoq-mavzu'), isNull);
    expect(lectureTopicRedirect(null, 'd003-L'), isNull);
    // O'quv dasturining har mavzusi uchun tayyor deck bor (D-68, Q1).
    final cur = jsonDecode(
      File('assets/curriculum/curriculum.json').readAsStringSync(),
    ) as Map<String, Object?>;
    for (final m in (cur['modules']! as List).cast<Map<String, Object?>>()) {
      for (final t in (m['topics']! as List).cast<Map<String, Object?>>()) {
        expect(catalog.byTopic(t['id']! as String), isNotNull, reason: '$t');
      }
    }
  });

  testWidgets('tayyor taqdimotsiz mavzu — avtomatik slaydlar (zaxira)', (
    tester,
  ) async {
    installDiffFakes();
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await makeServices(
      tester,
      role: AppRole.teacher,
      bundle: _NoDecksBundle(),
    );
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/lecture/d003-L');
    expect(routerOf(tester).state.uri.toString(), '/learn/lecture/d003-L');
    expect(find.textContaining(l.lectureDraftNotice), findsNothing);
    expect(find.byTooltip(l.lectureNotesShow), findsNothing);
    expect(find.textContaining(' / '), findsWidgets);
  });

  testWidgets(
    'keng ekran (TV): slayd paneli yonida; to‘liq ekranda chetini bosib o‘tish',
    (tester) async {
      installDiffFakes();
      final l = lookupAppLocalizations(const Locale('uz'));
      final deck = (await tester.runAsync(
        () => LectureDecks.forTopic(rootBundle, 'd001-P'),
      ))!;
      final n = deck.slides.length;
      final s = await makeServices(tester, role: AppRole.teacher);
      await pumpApp(tester, s, size: const Size(960, 540));
      await goTo(tester, '/learn/lecture/deck/d001');
      final img = find.byKey(ValueKey(deck.slides.first.image));
      expect(img, findsOneWidget);
      // Keng ekran: slayd + yon panel (aylantirish shart emas).
      expect(find.text(l.lectureNext), findsOneWidget);
      expect(find.text(l.lectureCounter(1, n)), findsOneWidget);

      // To'liq ekran: yotiq ekranda so'ralmaydi; faqat slayd.
      await tester.tap(find.byKey(const ValueKey('lecture-fullscreen')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('lecture-rotate-dialog')), findsNothing);
      expect(
        find.byKey(const ValueKey('lecture-presentation')),
        findsOneWidget,
      );
      expect(tester.getRect(img).height, greaterThan(500));
      expect(find.text(l.lectureNext), findsNothing);
      await tester.tapAt(const Offset(900, 270));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('lecture-canvas-1')), findsOneWidget);
      await tester.tapAt(const Offset(60, 270));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('lecture-canvas-0')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('lecture-fullscreen-exit')));
      await tester.pumpAndSettle();
      expect(find.text(l.lectureCounter(1, n)), findsOneWidget);

      // Ustoz izohi — yon panelda.
      final withNote = deck.slides.indexWhere((d) => d.note != null);
      for (var k = 0; k < withNote; k++) {
        await tester.tap(find.text(l.lectureNext));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byTooltip(l.lectureNotesShow));
      await tester.pumpAndSettle();
      expect(find.text(deck.slides[withNote].note!), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

/// Katalogda birorta deck yo'q bundle — avtomatik slaydlar zaxirasini
/// sinash uchun (haqiqiy katalogda har mavzuning decki bor).
class _NoDecksBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == DeckCatalog.indexPath) {
      final j =
          jsonDecode(await rootBundle.loadString(key)) as Map<String, Object?>;
      j['decks'] = <Object>[];
      final bytes = utf8.encode(jsonEncode(j));
      return ByteData.sublistView(Uint8List.fromList(bytes));
    }
    return rootBundle.load(key);
  }
}
