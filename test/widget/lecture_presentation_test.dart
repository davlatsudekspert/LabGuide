// Ma'ruza pleyeri — 16:9 taqdimot (D-59): tik telefonda slayd kartasi +
// panel (320 px / 1.3× shrift, uz/ru/en, overflow yo'q), surish bilan
// o'tish, to'liq manbalar oynasi, to'liq ekran (gorizontal holat so'rovi,
// eslab qolish, chiqishda tiklash), ekranga uzatish yo'riqnomasi,
// taqdimotchi ko'rinishi, tungi mavzu. Golden'siz.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/design/theme.dart';
import 'package:labguide/features/classroom/lecture_canvas.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/lecture_decks.dart';
import 'package:labguide/features/classroom/lecture_present.dart';
import 'package:labguide/features/classroom/lecture_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/harness.dart';

const _phone = Size(390, 844);

Future<LectureDeck> _preload(
  WidgetTester tester,
  String id,
  String lang,
) async {
  final c = (await tester.runAsync(() => DeckCatalog.load(rootBundle)))!;
  final e = c.byId(id)!;
  return (await tester.runAsync(
    () => DeckCatalog.loadDeck(rootBundle, e, e.resolveLang(lang)),
  ))!;
}

/// SystemChrome chaqiruvlari (ekran holati, tizim panellari).
List<MethodCall> _platformCalls(WidgetTester tester) {
  final calls = <MethodCall>[];
  final m = tester.binding.defaultBinaryMessenger;
  m.setMockMethodCallHandler(SystemChannels.platform, (c) async {
    calls.add(c);
    return null;
  });
  addTearDown(() => m.setMockMethodCallHandler(SystemChannels.platform, null));
  return calls;
}

List<Object?> _orientations(List<MethodCall> calls) => [
  for (final c in calls)
    if (c.method == 'SystemChrome.setPreferredOrientations') c.arguments,
];

List<Object?> _uiModes(List<MethodCall> calls) => [
  for (final c in calls)
    if (c.method == 'SystemChrome.setEnabledSystemUIMode') c.arguments,
];

const _landscape = [
  'DeviceOrientation.landscapeLeft',
  'DeviceOrientation.landscapeRight',
];

Future<AppLocalizations> _open(
  WidgetTester tester,
  String location, {
  AppLanguage lang = AppLanguage.uz,
  Size size = _phone,
  double textScale = 1,
  MemoryKeyValueStore? store,
  ThemeMode theme = ThemeMode.light,
}) async {
  installDiffFakes();
  final s = await makeServices(
    tester,
    role: AppRole.teacher,
    language: lang,
    store: store,
    themeMode: theme,
  );
  await pumpApp(tester, s, size: size, textScale: textScale);
  await goTo(tester, '/learn/lecture');
  await goTo(tester, location);
  return lookupAppLocalizations(lang.locale);
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Finder _canvas(int i) => find.byKey(ValueKey('lecture-canvas-$i'));

/// Vizual shablonlar (D-60): raqam kartalari, chegaralar, qadamlar, ikki
/// ustun, tasnif, misol.
const _visualTemplates = [
  'stats',
  'range',
  'steps',
  'split',
  'tree',
  'example',
];

/// Slayd yangi vizual bilan chiziladimi: yangi shablon, yon rasm yoki
/// sarlavha rasmi.
bool _isVisual(DeckSlide s) =>
    _visualTemplates.contains(s.template) ||
    (s.figure != null && s.template != 'figure');

/// Slayd matni uzunligi (eng og'ir holatni tanlash uchun).
int _textLen(DeckSlide s) =>
    s.title.length +
    s.bullets.fold<int>(0, (a, b) => a + b.length) +
    s.cols.fold<int>(
      0,
      (a, c) => a + c.$3.fold<int>(0, (x, y) => x + y.length),
    ) +
    (s.example?.length ?? 0) +
    ((s.range?['rows'] as List?)?.length ?? 0) * 60;

/// Tilning barcha decklari (muallif decki d001 — rasmli slaydlar — tashqari).
Future<List<LectureDeck>> _allDecks(WidgetTester tester, String lang) async {
  final c = (await tester.runAsync(() => DeckCatalog.load(rootBundle)))!;
  final out = <LectureDeck>[];
  await tester.runAsync(() async {
    for (final e in c.decks) {
      if (!e.languages.contains(lang) || e.files.containsKey(lang)) continue;
      out.add(await DeckCatalog.loadDeck(rootBundle, e, lang));
    }
  });
  return out;
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets(
      'tik telefon 320 px ×1.3 (${lang.name}): hamma shablon sig‘adi',
      (tester) async {
        final deck = await _preload(tester, 'd012', lang.name);
        final sl = deck.slides;
        final picks = <int>{
          0,
          1,
          sl.indexWhere((s) => s.template == 'bullets' && s.source != null),
          sl.indexWhere((s) => s.template == 'table'),
          sl.indexWhere((s) => s.template == 'figure'),
          sl.indexWhere((s) => s.template == 'qa'),
          sl.length - 1,
        }..remove(-1);
        final l = await _open(
          tester,
          '/learn/lecture/deck/d012',
          lang: lang,
          size: const Size(320, 640),
          textScale: 1.3,
        );
        for (final k in picks.toList()..sort()) {
          await goTo(tester, '/learn/lecture');
          await goTo(tester, '/learn/lecture/deck/d012?s=$k');
          expect(_canvas(k), findsOneWidget, reason: '#$k');
          // Karta ekran kengligida va 16:9.
          final r = tester.getRect(_canvas(k));
          expect(r.right, lessThanOrEqualTo(320.5));
          expect(r.width / r.height, closeTo(16 / 9, 0.02));
          expect(find.text(l.lectureCounter(k + 1, sl.length)), findsOneWidget);
          if (sl[k].template == 'qa') {
            await _tap(tester, find.byKey(const ValueKey('lecture-answer')));
            final opt = sl[k].options[sl[k].correct!];
            expect(find.text(opt), findsOneWidget);
          }
          if (sl[k].source != null) {
            expect(
              find.byKey(const ValueKey('lecture-source')),
              findsOneWidget,
            );
          }
          expect(tester.takeException(), isNull, reason: '#$k ${sl[k].title}');
        }
        // To'liq ekran tugmasi va uzatish tugmasi tor ekranda ham sig'adi.
        expect(
          find.byKey(const ValueKey('lecture-fullscreen')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('lecture-cast')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'uzun band (eGFR) — 16:9 da kamida 26 px; manbalar oynasi to‘liq',
    (tester) async {
      final deck = await _preload(tester, 'd057', 'uz');
      final k = deck.slides.indexWhere(
        (s) =>
            s.bullets.any((b) => b.contains('sistatin C bo‘yicha')) &&
            s.refs.isNotEmpty,
      );
      expect(k, greaterThan(0));
      final slide = deck.slides[k];
      final l = await _open(tester, '/learn/lecture/deck/d057?s=$k');
      expect(_canvas(k), findsOneWidget);
      // Kanvasdagi band shrifti (1280 kenglikda) ≥ 26 px.
      final rich = find.descendant(
        of: _canvas(k),
        matching: find.byWidgetPredicate(
          (w) =>
              w is RichText &&
              w.text.toPlainText().contains('sistatin C bo‘yicha'),
        ),
      );
      expect(rich, findsOneWidget);
      // Text.rich: ildiz span — DefaultTextStyle, band shrifti ichki spanda.
      final root = tester.widget<RichText>(rich).text as TextSpan;
      final size = (root.children!.first as TextSpan).style!.fontSize!;
      expect(size, greaterThanOrEqualTo(26));

      // Manba qatori → to'liq ro'yxat: har yozuv kesilmagan, bo'lim/sahifa bilan.
      await _tap(tester, find.byKey(const ValueKey('lecture-source')));
      expect(
        find.byKey(const ValueKey('lecture-source-sheet')),
        findsOneWidget,
      );
      expect(find.text(l.lectureSourcesTitle), findsOneWidget);
      final bib = deck.bibliography;
      for (final (j, r) in slide.refs.indexed) {
        final f = find.byKey(ValueKey('lecture-source-ref-$j'));
        await tester.scrollUntilVisible(
          f,
          120,
          scrollable: find.descendant(
            of: find.byKey(const ValueKey('lecture-source-sheet')),
            matching: find.byType(Scrollable),
          ),
        );
        final shown = tester.widget<Text>(f);
        expect(shown.data, bib[r.index]);
        expect(shown.maxLines, isNull);
        expect(shown.overflow, isNot(TextOverflow.ellipsis));
        expect(bib[r.index].contains('…'), isFalse);
        for (final loc in r.locators) {
          expect(find.text(l.lectureSourceLocator(loc)), findsWidgets);
        }
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('surish: chapga — oldinga, o‘ngga — orqaga; klaviatura ← →', (
    tester,
  ) async {
    final deck = await _preload(tester, 'd012', 'uz');
    final l = await _open(tester, '/learn/lecture/deck/d012');
    final n = deck.slides.length;
    final card = find.byKey(const ValueKey('lecture-slide-card'));
    await tester.fling(card, const Offset(-300, 0), 1200);
    await tester.pumpAndSettle();
    expect(_canvas(1), findsOneWidget);
    expect(find.text(l.lectureCounter(2, n)), findsOneWidget);
    await tester.fling(card, const Offset(-300, 0), 1200);
    await tester.pumpAndSettle();
    expect(_canvas(2), findsOneWidget);
    await tester.fling(card, const Offset(300, 0), 1200);
    await tester.pumpAndSettle();
    expect(_canvas(1), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(_canvas(2), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(_canvas(1), findsOneWidget);
  });

  testWidgets('to‘liq ekran: so‘raydi → Ha → gorizontal; chiqishda tiklanadi', (
    tester,
  ) async {
    final calls = _platformCalls(tester);
    final l = await _open(tester, '/learn/lecture/deck/d012');
    await _tap(tester, find.byKey(const ValueKey('lecture-fullscreen')));
    expect(find.byKey(const ValueKey('lecture-rotate-dialog')), findsOneWidget);
    expect(find.text(l.lectureRotateTitle), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('lecture-rotate-yes')));
    expect(find.byKey(const ValueKey('lecture-presentation')), findsOneWidget);
    expect(_orientations(calls), [_landscape]);
    expect(_uiModes(calls), ['SystemUiMode.immersiveSticky']);
    // Faqat slayd: panel tugmalari yo'q; o'ng yarmini bosish — oldinga.
    expect(find.text(l.lectureNext), findsNothing);
    await tester.tapAt(const Offset(350, 422));
    await tester.pumpAndSettle();
    expect(_canvas(1), findsOneWidget);
    await tester.tapAt(const Offset(40, 422));
    await tester.pumpAndSettle();
    expect(_canvas(0), findsOneWidget);
    // Chiqish (tugma): ekran holati va panellar tiklanadi.
    await _tap(tester, find.byKey(const ValueKey('lecture-fullscreen-exit')));
    expect(find.byKey(const ValueKey('lecture-presentation')), findsNothing);
    expect(find.text(l.lectureNext), findsOneWidget);
    expect(_orientations(calls).last, <Object?>[]);
    expect(_uiModes(calls).last, 'SystemUiMode.edgeToEdge');

    // Orqaga tugmasi ham faqat to'liq ekrandan chiqaradi (ma'ruza ochiq qoladi).
    await _tap(tester, find.byKey(const ValueKey('lecture-fullscreen')));
    await _tap(tester, find.byKey(const ValueKey('lecture-rotate-yes')));
    expect(find.byKey(const ValueKey('lecture-presentation')), findsOneWidget);
    final calls0 = calls.length;
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('lecture-presentation')), findsNothing);
    expect(find.text(l.lectureNext), findsOneWidget);
    expect(_orientations(calls.sublist(calls0)).last, <Object?>[]);
    // Esc ham chiqaradi.
    await _tap(tester, find.byKey(const ValueKey('lecture-fullscreen')));
    await _tap(tester, find.byKey(const ValueKey('lecture-rotate-yes')));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('lecture-presentation')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'to‘liq ekran: Yo‘q — aylantirmaydi; ma‘ruzani yopish ham tiklaydi',
    (tester) async {
      final calls = _platformCalls(tester);
      await _open(tester, '/learn/lecture/deck/d012');
      await _tap(tester, find.byKey(const ValueKey('lecture-fullscreen')));
      await _tap(tester, find.byKey(const ValueKey('lecture-rotate-no')));
      expect(
        find.byKey(const ValueKey('lecture-presentation')),
        findsOneWidget,
      );
      // Gorizontalga majburlanmadi; slayd tik ekranda ham to'liq kenglikda.
      expect(_orientations(calls), isEmpty);
      expect(tester.getRect(_canvas(0)).width, closeTo(390, 0.5));
      // Ma'ruzadan butunlay chiqish (dispose) — tiklanadi.
      await goTo(tester, '/learn/lecture');
      expect(_orientations(calls).last, <Object?>[]);
      expect(_uiModes(calls).last, 'SystemUiMode.edgeToEdge');
    },
  );

  testWidgets('eslab qolish: “Qayta so‘ramaslik” → keyingi safar so‘ralmaydi', (
    tester,
  ) async {
    final calls = _platformCalls(tester);
    final store = MemoryKeyValueStore();
    final l = await _open(tester, '/learn/lecture/deck/d012', store: store);
    await _tap(tester, find.byKey(const ValueKey('lecture-fullscreen')));
    await _tap(tester, find.byKey(const ValueKey('lecture-rotate-remember')));
    await _tap(tester, find.byKey(const ValueKey('lecture-rotate-yes')));
    expect(store.getString(StoreKeys.lectureOrientation), 'landscape');
    await _tap(tester, find.byKey(const ValueKey('lecture-fullscreen-exit')));
    calls.clear();
    await _tap(tester, find.byKey(const ValueKey('lecture-fullscreen')));
    expect(find.byKey(const ValueKey('lecture-rotate-dialog')), findsNothing);
    expect(find.byKey(const ValueKey('lecture-presentation')), findsOneWidget);
    expect(_orientations(calls), [_landscape]);
    await _tap(tester, find.byKey(const ValueKey('lecture-fullscreen-exit')));

    // Menyu: "Aylantirmaslik" → so'ralmaydi va aylantirmaydi; "Doim so'rash".
    await _tap(tester, find.byKey(const ValueKey('lecture-more')));
    expect(find.text(l.lectureOrientationMenu), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('lecture-orient-keep')));
    expect(store.getString(StoreKeys.lectureOrientation), 'keep');
    calls.clear();
    await _tap(tester, find.byKey(const ValueKey('lecture-fullscreen')));
    expect(find.byKey(const ValueKey('lecture-rotate-dialog')), findsNothing);
    expect(_orientations(calls), isEmpty);
    await _tap(tester, find.byKey(const ValueKey('lecture-fullscreen-exit')));
    await _tap(tester, find.byKey(const ValueKey('lecture-more')));
    await _tap(tester, find.byKey(const ValueKey('lecture-orient-ask')));
    expect(store.getString(StoreKeys.lectureOrientation), isNull);
    await _tap(tester, find.byKey(const ValueKey('lecture-fullscreen')));
    expect(find.byKey(const ValueKey('lecture-rotate-dialog')), findsOneWidget);
  });

  testWidgets('ekranga uzatish: yo‘riqnoma, sozlama, so‘ng taqdimot', (
    tester,
  ) async {
    final calls = _platformCalls(tester);
    var opened = 0;
    var result = false;
    LecturePresentation.openCastSettings = () async {
      opened++;
      return result;
    };
    addTearDown(() => LecturePresentation.openCastSettings = () async => false);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final l = await _open(tester, '/learn/lecture/deck/d012');
    await _tap(tester, find.byKey(const ValueKey('lecture-cast')));
    expect(find.byKey(const ValueKey('lecture-cast-sheet')), findsOneWidget);
    expect(find.text(l.lectureCastStepsAndroid), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('lecture-cast-settings')));
    expect(opened, 1);
    // Ochilmasa — halol izoh, yo'riqnoma qoladi.
    expect(find.text(l.lectureCastSettingsFailed), findsOneWidget);
    result = true;
    await _tap(tester, find.byKey(const ValueKey('lecture-cast-start')));
    // Uzatishda ham ekran holati so'raladi (gorizontal tavsiya).
    expect(find.text(l.lectureRotateCastBody), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('lecture-rotate-yes')));
    expect(find.byKey(const ValueKey('lecture-presentation')), findsOneWidget);
    expect(_orientations(calls), [_landscape]);
    await _tap(tester, find.byKey(const ValueKey('lecture-fullscreen-exit')));
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await _tap(tester, find.byKey(const ValueKey('lecture-cast')));
    expect(find.text(l.lectureCastStepsIos), findsOneWidget);
    expect(find.byKey(const ValueKey('lecture-cast-settings')), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('taqdimotchi rejimi: keyingi slayd, vaqt, katta tugmalar', (
    tester,
  ) async {
    _platformCalls(tester);
    final deck = await _preload(tester, 'd012', 'uz');
    final n = deck.slides.length;
    final l = await _open(
      tester,
      '/learn/lecture/deck/d012',
      size: const Size(1280, 800),
    );
    await _tap(tester, find.byKey(const ValueKey('lecture-more')));
    await _tap(tester, find.byKey(const ValueKey('lecture-menu-presenter')));
    // Yotiq ekran — so'ralmaydi.
    expect(find.byKey(const ValueKey('lecture-presenter')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('lecture-presenter-next')),
      findsOneWidget,
    );
    expect(find.text(l.lectureCounter(1, n)), findsOneWidget);
    expect(
      find.byKey(const ValueKey('lecture-presenter-timer')),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 2));
    await _tap(tester, find.text(l.lectureNext));
    expect(_canvas(1), findsOneWidget);
    expect(find.text(l.lectureCounter(2, n)), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('lecture-presenter-exit')));
    expect(find.byKey(const ValueKey('lecture-presenter')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('yotiq telefon (to‘liq ekransiz): slayd va kichik tugmalar', (
    tester,
  ) async {
    final deck = await _preload(tester, 'd012', 'ru');
    final l = await _open(
      tester,
      '/learn/lecture/deck/d012',
      lang: AppLanguage.ru,
      size: const Size(844, 390),
    );
    final n = deck.slides.length;
    expect(_canvas(0), findsOneWidget);
    await _tap(tester, find.byTooltip(l.lectureNext));
    expect(find.text(l.lectureCounter(2, n)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Har deckdagi har vizual slayd (yangi shablonlar, yon rasm, sarlavha
  // rasmi) to'liq ekran o'lchamida — 1280×720 — overflow'siz: uz/ru/en,
  // kunduzgi/tungi. Kanvas har doim 1280×720 da joylashib, keyin teng
  // masshtablanadi, shuning uchun 320 px kartada ham joylashuv aynan shu.
  for (final lang in AppLanguage.values) {
    for (final b in Brightness.values) {
      testWidgets('vizual shablonlar 1280×720 (${lang.name}, ${b.name})', (
        tester,
      ) async {
        final decks = await _allDecks(tester, lang.name);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1280, 720);
        addTearDown(tester.view.reset);
        final at = ValueNotifier<(int, int)>((0, 0));
        await tester.pumpWidget(
          MaterialApp(
            theme: buildLgTheme(b),
            locale: lang.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: ValueListenableBuilder<(int, int)>(
              valueListenable: at,
              builder: (context, v, _) {
                final d = decks[v.$1];
                final slides = deckLectureSlides(context, d);
                return Center(
                  child: SizedBox(
                    width: 1280,
                    height: 720,
                    child: SlideCanvas(
                      key: ValueKey('vis-${v.$1}-${v.$2}'),
                      slide: slides[v.$2],
                      number: v.$2 + 1,
                      total: slides.length,
                      deckTitle: d.title,
                    ),
                  ),
                );
              },
            ),
          ),
        );
        final seen = <String, int>{};
        for (final (di, d) in decks.indexed) {
          for (final (si, s) in d.slides.indexed) {
            if (!_isVisual(s)) continue;
            at.value = (di, si);
            await tester.pump();
            final key =
                s.figure != null && !_visualTemplates.contains(s.template)
                ? '${s.template}+figure'
                : s.template;
            seen[key] = (seen[key] ?? 0) + 1;
            expect(
              tester.takeException(),
              isNull,
              reason: '${d.id}.${lang.name}#$si ${s.template} ${s.title}',
            );
          }
        }
        // Har yangi shablon kamida bir marta chizildi.
        for (final t in _visualTemplates) {
          expect(seen[t] ?? 0, greaterThan(0), reason: '$t: $seen');
        }
        expect(seen['title+figure'] ?? 0, greaterThan(50), reason: '$seen');
        expect(seen['bullets+figure'] ?? 0, greaterThan(10), reason: '$seen');
      });
    }
  }

  // Tik telefon kartasi (320 px, ×1.3 shrift): har yangi shablonning eng uzun
  // matnli slaydi ilova ichida — overflow'siz, karta 16:9 va ekranga sig'adi.
  for (final lang in AppLanguage.values) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('vizual shablonlar 320 px (${lang.name}, ${theme.name})', (
        tester,
      ) async {
        final decks = await _allDecks(tester, lang.name);
        final picks = <String, (String, int)>{};
        final best = <String, int>{};
        for (final d in decks) {
          for (final (i, s) in d.slides.indexed) {
            if (!_isVisual(s)) continue;
            final k = _visualTemplates.contains(s.template)
                ? s.template
                : '${s.template}+figure';
            final n = _textLen(s);
            if (n > (best[k] ?? -1)) {
              best[k] = n;
              picks[k] = (d.id!, i);
            }
          }
        }
        expect(picks.keys, containsAll(_visualTemplates));
        await _open(
          tester,
          '/learn/lecture',
          lang: lang,
          size: const Size(320, 640),
          textScale: 1.3,
          theme: theme,
        );
        for (final MapEntry(key: t, value: (id, k)) in picks.entries) {
          await goTo(tester, '/learn/lecture');
          await goTo(tester, '/learn/lecture/deck/$id?s=$k');
          expect(_canvas(k), findsOneWidget, reason: '$t $id#$k');
          final r = tester.getRect(_canvas(k));
          expect(r.left, greaterThanOrEqualTo(-0.5), reason: '$t $id#$k');
          expect(r.right, lessThanOrEqualTo(320.5), reason: '$t $id#$k');
          expect(r.width / r.height, closeTo(16 / 9, 0.02));
          expect(tester.takeException(), isNull, reason: '$t $id#$k');
        }
      });
    }
  }

  testWidgets('raqam kartasi va chegaralar: matn bandlardan, sonlar kartadan', (
    tester,
  ) async {
    final decks = await _allDecks(tester, 'uz');
    // stats: kartadagi qiymat va yorliq — bandlar matnining bo'lagi
    var n = 0;
    for (final d in decks) {
      for (final s in d.slides) {
        if (s.template != 'stats') continue;
        final text = s.bullets.join('\n');
        for (final st in s.stats) {
          expect(text, contains(st[0]));
          expect(text, contains(st[1]));
          n++;
        }
      }
    }
    expect(n, greaterThan(50));
    // range: d045 (glyukoza) — kanvasda diagramma va kartadagi qiymatlar
    final d = decks.firstWhere(
      (d) => d.slides.any((s) => s.template == 'range'),
    );
    final k = d.slides.indexWhere((s) => s.template == 'range');
    await _open(
      tester,
      '/learn/lecture/deck/${d.id}?s=$k',
      size: const Size(1280, 800),
    );
    expect(_canvas(k), findsOneWidget);
    final rows = d.slides[k].range!['rows']! as List;
    for (final r in rows.cast<List<Object?>>()) {
      for (final t in [r[5], r[6]].whereType<String>()) {
        expect(
          find.descendant(of: _canvas(k), matching: find.textContaining(t)),
          findsWidgets,
          reason: t,
        );
      }
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('tungi mavzu: barcha shablonlar xatosiz chiziladi', (
    tester,
  ) async {
    final deck = await _preload(tester, 'd012', 'uz');
    await _open(tester, '/learn/lecture/deck/d012', theme: ThemeMode.dark);
    for (final t in ['title', 'bullets', 'table', 'figure', 'qa']) {
      final k = deck.slides.indexWhere((s) => s.template == t);
      await goTo(tester, '/learn/lecture');
      await goTo(tester, '/learn/lecture/deck/d012?s=$k');
      expect(_canvas(k), findsOneWidget, reason: t);
      expect(tester.takeException(), isNull, reason: t);
    }
  });
}
