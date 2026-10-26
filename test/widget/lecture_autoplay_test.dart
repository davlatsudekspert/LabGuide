// Ma'ruza pleyeri: «Avto / Qo'lda» varaqlash. Soxta vaqt (tester.pump) bilan:
// avto o'tish, bosilganda pauza / davom, qo'lda varaqlash pauzaga qo'yadi,
// oxirgi slaydda to'xtash, ekrandan chiqqanda taymer qolmasligi, fonga
// o'tish, tanlovni eslab qolish, 320 dp / katta shrift / tungi mavzu,
// «harakatni kamaytirish». «Qo'lda» — avvalgidek.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/classroom/lecture_autoplay.dart';
import 'package:labguide/features/classroom/lecture_slide.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/harness.dart';

const _phone = Size(390, 844);
const _landscape = Size(800, 400);

List<LectureSlide> _slides(int n) => [
  for (var i = 1; i <= n; i++)
    LectureSlide(title: 'Slayd $i', bullets: ['Band $i.1', 'Band $i.2']),
];

class _Ctx {
  _Ctx(this.l, this.store, this.awake);
  final AppLocalizations l;
  final MemoryKeyValueStore store;
  final RecordingScreenAwake awake;
}

Future<_Ctx> _open(
  WidgetTester tester, {
  int slides = 4,
  AppLanguage lang = AppLanguage.uz,
  Size size = _phone,
  double textScale = 1,
  ThemeMode theme = ThemeMode.light,
  Brightness platformBrightness = Brightness.light,
  bool reduceMotion = false,
  MemoryKeyValueStore? store,
}) async {
  final fakes = installDiffFakes();
  final st = store ?? MemoryKeyValueStore();
  final s = await makeServices(
    tester,
    role: AppRole.teacher,
    language: lang,
    store: st,
    themeMode: theme,
  );
  await pumpApp(
    tester,
    s,
    size: size,
    textScale: textScale,
    platformBrightness: platformBrightness,
    reduceMotion: reduceMotion,
  );
  routerOf(tester).go('/learn/lecture/auto/play', extra: _slides(slides));
  await tester.pumpAndSettle();
  return _Ctx(lookupAppLocalizations(lang.locale), st, fakes.awake);
}

Finder _key(String k) => find.byKey(ValueKey(k));
Finder _counter(_Ctx c, int i, int n) => find.text(c.l.lectureCounter(i, n));

Future<void> _tapKey(WidgetTester tester, String k) async {
  await tester.ensureVisible(_key(k));
  await tester.pump();
  await tester.tap(_key(k));
  await tester.pump();
}

/// Slayd kartasi (tik / keng ekran) — bosish pauza / davom.
Future<void> _tapCard(WidgetTester tester) async {
  await tester.tap(_key('lecture-slide-card'));
  await tester.pump();
}

Future<void> _autoOn(WidgetTester tester) =>
    _tapKey(tester, 'lecture-auto-toggle');

/// Uzbekcha «Qo'lda» (U+2018).
const _manualUz = 'Qo‘lda';

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

void main() {
  setUpAll(loadAppFonts);

  group('Qo‘lda (standart) — avvalgidek', () {
    testWidgets('taymer yo‘q, bosish o‘tkazmaydi, saqlashga yozilmaydi', (
      tester,
    ) async {
      final c = await _open(tester);
      expect(find.text(_manualUz), findsOneWidget);
      expect(find.text('Avto'), findsNothing);
      expect(find.text(c.l.lectureAutoPause), findsNothing);
      expect(_key('lecture-auto-speed'), findsNothing);
      expect(_counter(c, 1, 4), findsOneWidget);

      await tester.pump(const Duration(minutes: 5));
      expect(_counter(c, 1, 4), findsOneWidget);

      // Kartani bosish hech narsa qilmaydi; «Oldinga» ishlaydi.
      await _tapCard(tester);
      expect(_counter(c, 1, 4), findsOneWidget);
      expect(find.text(c.l.lectureAutoPause), findsNothing);
      await tester.tap(find.text(c.l.lectureNext));
      await tester.pump();
      expect(_counter(c, 2, 4), findsOneWidget);
      expect(find.text(c.l.lectureAutoPause), findsNothing);

      expect(c.store.snapshot.keys, isNot(contains(StoreKeys.lectureAutoMode)));
      // Mavjud xatti-harakat: ekran butun umri davomida uyg'oq.
      expect(c.awake.calls, [true]);
    });
  });

  group('Avto', () {
    testWidgets('standart 30 soniya: o‘zi keyingisiga o‘tadi', (tester) async {
      final c = await _open(tester);
      await _autoOn(tester);
      expect(find.text('Avto'), findsOneWidget);
      expect(find.text(c.l.lectureAutoSeconds(30)), findsOneWidget);
      expect(c.store.getString(StoreKeys.lectureAutoMode), 'auto');
      // Ekran uyg'oq (Avto yoqilganda aniq yoqiladi).
      expect(c.awake.calls.last, isTrue);

      await tester.pump(const Duration(seconds: 29));
      expect(_counter(c, 1, 4), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(_counter(c, 2, 4), findsOneWidget);
      // Hisob har slaydda qaytadan boshlanadi.
      await tester.pump(const Duration(seconds: 29));
      expect(_counter(c, 2, 4), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(_counter(c, 3, 4), findsOneWidget);
    });

    for (final sec in [15, 60]) {
      testWidgets('tezlik $sec soniya saqlanadi va ishlaydi', (tester) async {
        final c = await _open(tester);
        await _autoOn(tester);
        await _tapKey(tester, 'lecture-auto-speed');
        await tester.pumpAndSettle();
        await tester.tap(_key('lecture-auto-speed-$sec'));
        await tester.pumpAndSettle();
        expect(find.text(c.l.lectureAutoSeconds(sec)), findsOneWidget);
        expect(c.store.getString(StoreKeys.lectureAutoSeconds), '$sec');

        await tester.pump(Duration(seconds: sec - 1));
        expect(_counter(c, 1, 4), findsOneWidget);
        await tester.pump(const Duration(seconds: 1));
        expect(_counter(c, 2, 4), findsOneWidget);
      });
    }

    testWidgets('ekranni bosish — pauza (belgi), qayta bosish — davom', (
      tester,
    ) async {
      final c = await _open(tester);
      await _autoOn(tester);
      await tester.pump(const Duration(seconds: 10));

      await _tapCard(tester);
      expect(find.text(c.l.lectureAutoPause), findsOneWidget);
      expect(_key('lecture-auto-resume'), findsOneWidget);
      await tester.pump(const Duration(minutes: 5));
      expect(_counter(c, 1, 4), findsOneWidget);

      await _tapCard(tester);
      expect(find.text(c.l.lectureAutoPause), findsNothing);
      // Hisob davom etganda boshidan.
      await tester.pump(const Duration(seconds: 29));
      expect(_counter(c, 1, 4), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(_counter(c, 2, 4), findsOneWidget);
    });

    testWidgets(
      'pauza belgisi bosilsa ham davom etadi (maslahat: davom etish)',
      (tester) async {
        final c = await _open(tester);
        await _autoOn(tester);
        await _tapKey(tester, 'lecture-auto-pause');
        expect(find.text(c.l.lectureAutoPause), findsOneWidget);
        expect(find.byTooltip(c.l.lectureAutoResume), findsOneWidget);
        await _tapKey(tester, 'lecture-auto-resume');
        expect(find.text(c.l.lectureAutoPause), findsNothing);
        await tester.pump(const Duration(seconds: 30));
        expect(_counter(c, 2, 4), findsOneWidget);
      },
    );

    testWidgets('qo‘lda varaqlash (tugma, surish, klavish) pauzaga qo‘yadi', (
      tester,
    ) async {
      final c = await _open(tester);
      await _autoOn(tester);
      await tester.pump(const Duration(seconds: 5));
      await tester.tap(find.text(c.l.lectureNext));
      await tester.pump();
      expect(_counter(c, 2, 4), findsOneWidget);
      expect(find.text(c.l.lectureAutoPause), findsOneWidget);
      await tester.pump(const Duration(minutes: 2));
      expect(_counter(c, 2, 4), findsOneWidget);

      // Pauzada qo'lda varaqlash — pauzada qoladi.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_counter(c, 3, 4), findsOneWidget);
      expect(find.text(c.l.lectureAutoPause), findsOneWidget);

      // Davom etganda yangi hisob; surish ham pauzaga qo'yadi.
      await _tapKey(tester, 'lecture-auto-resume');
      await tester.fling(
        _key('lecture-slide-card'),
        const Offset(-300, 0),
        1000,
      );
      await tester.pump();
      expect(_counter(c, 4, 4), findsOneWidget);
    });

    testWidgets('oxirgi slaydda to‘xtaydi, boshiga qaytmaydi, Avto o‘chadi', (
      tester,
    ) async {
      final c = await _open(tester, slides: 3);
      await _autoOn(tester);
      await tester.pump(const Duration(seconds: 30));
      await tester.pump(const Duration(seconds: 30));
      expect(_counter(c, 3, 3), findsOneWidget);
      // Avto o'chdi: tugma «Qo'lda», pauza belgisi yo'q.
      expect(find.text(_manualUz), findsOneWidget);
      expect(find.text('Avto'), findsNothing);
      expect(find.text(c.l.lectureAutoPause), findsNothing);
      await tester.pump(const Duration(minutes: 10));
      expect(_counter(c, 3, 3), findsOneWidget);
      // Saqlangan tanlov o'zgarmaydi (foydalanuvchi nima tanlagan bo'lsa).
      expect(c.store.getString(StoreKeys.lectureAutoMode), 'auto');
    });

    testWidgets('bitta slaydli deck: Avto darhol o‘chadi', (tester) async {
      final c = await _open(tester, slides: 1);
      await _autoOn(tester);
      await tester.pump();
      expect(find.text(_manualUz), findsOneWidget);
      await tester.pump(const Duration(minutes: 1));
      expect(_counter(c, 1, 1), findsOneWidget);
    });

    testWidgets('«Avto»ni o‘chirish — taymer yo‘q, tanlov o‘chadi', (
      tester,
    ) async {
      final c = await _open(tester);
      await _autoOn(tester);
      await _autoOn(tester);
      expect(find.text(_manualUz), findsOneWidget);
      expect(c.store.snapshot.keys, isNot(contains(StoreKeys.lectureAutoMode)));
      await tester.pump(const Duration(minutes: 2));
      expect(_counter(c, 1, 4), findsOneWidget);
    });
  });

  group('hayot sikli', () {
    testWidgets(
      'ekrandan chiqilganda taymer qolmaydi, ekran uyg‘oqligi tugaydi',
      (tester) async {
        final c = await _open(tester);
        await _autoOn(tester);
        await tester.pump(const Duration(seconds: 10));
        routerOf(tester).go('/learn/lecture');
        await tester.pumpAndSettle();
        expect(c.awake.calls.last, isFalse);
        // Taymer bekor qilingan: test shu yerda tugaydi (vaqt o'tkazilmaydi) —
        // qolgan taymer bo'lsa, freymvork «Timer is still pending» deydi.
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('fonga o‘tish: taymer bekor, pauza, qaytganda pauzada qoladi', (
      tester,
    ) async {
      final c = await _open(tester);
      addTearDown(
        () => tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        ),
      );
      await _autoOn(tester);
      await tester.pump(const Duration(seconds: 10));
      // Fonda kadrlar chizilmaydi — holat qaytgandan keyin ko'rinadi.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      expect(c.awake.calls.last, isFalse);
      await tester.pump(const Duration(minutes: 5));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(c.awake.calls.last, isTrue);
      expect(_counter(c, 1, 4), findsOneWidget);
      expect(find.text(c.l.lectureAutoPause), findsOneWidget);
      await tester.pump(const Duration(minutes: 5));
      expect(_counter(c, 1, 4), findsOneWidget);
      await _tapKey(tester, 'lecture-auto-resume');
      await tester.pump(const Duration(seconds: 30));
      expect(_counter(c, 2, 4), findsOneWidget);
    });

    testWidgets('inactive (masalan, tizim oynasi) ham pauzaga qo‘yadi', (
      tester,
    ) async {
      final c = await _open(tester);
      addTearDown(
        () => tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        ),
      );
      await _autoOn(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.text(c.l.lectureAutoPause), findsOneWidget);
      await tester.pump(const Duration(minutes: 2));
      expect(_counter(c, 1, 4), findsOneWidget);
    });

    testWidgets('fonga o‘tish «Qo‘lda»da ekran holatiga tegmaydi', (
      tester,
    ) async {
      final c = await _open(tester);
      addTearDown(
        () => tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        ),
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(c.awake.calls, [true]);
    });

    testWidgets('ustida boshqa oyna (tezlik menyusi) ochiq — o‘tmaydi', (
      tester,
    ) async {
      final c = await _open(tester);
      await _autoOn(tester);
      await _tapKey(tester, 'lecture-auto-speed');
      await tester.pump(const Duration(seconds: 30));
      expect(_counter(c, 1, 4), findsOneWidget);
      await tester.tapAt(const Offset(5, 300));
      await tester.pumpAndSettle();
      expect(find.text(c.l.lectureAutoPause), findsOneWidget);
    });
  });

  group('saqlash', () {
    testWidgets('keyingi ochilishda Avto va tezlik eslab qolinadi', (
      tester,
    ) async {
      final store = MemoryKeyValueStore();
      var c = await _open(tester, store: store);
      await _autoOn(tester);
      await _tapKey(tester, 'lecture-auto-speed');
      await tester.pumpAndSettle();
      await tester.tap(_key('lecture-auto-speed-60'));
      await tester.pumpAndSettle();
      routerOf(tester).go('/learn/lecture');
      await tester.pumpAndSettle();

      // Yangi ochilish: o'sha ombor.
      routerOf(tester).go('/learn/lecture/auto/play', extra: _slides(4));
      await tester.pumpAndSettle();
      c = _Ctx(c.l, store, c.awake);
      expect(find.text('Avto'), findsOneWidget);
      expect(find.text(c.l.lectureAutoSeconds(60)), findsOneWidget);
      await tester.pump(const Duration(seconds: 59));
      expect(_counter(c, 1, 4), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(_counter(c, 2, 4), findsOneWidget);
    });

    testWidgets('buzuq qiymat — standart (Qo‘lda, 30)', (tester) async {
      final store = MemoryKeyValueStore({
        StoreKeys.lectureAutoMode: 'zzz',
        StoreKeys.lectureAutoSeconds: '7',
      });
      final c = await _open(tester, store: store);
      expect(find.text(_manualUz), findsOneWidget);
      await _autoOn(tester);
      expect(find.text(c.l.lectureAutoSeconds(30)), findsOneWidget);
    });
  });

  group('yotiq ekran va to‘liq ekran', () {
    testWidgets('yotiq: Qo‘lda — chekka bosish o‘tkazadi; Avto — pauza', (
      tester,
    ) async {
      final c = await _open(tester, size: _landscape);
      // Qo'lda: o'ng chet — keyingi (avvalgidek).
      await tester.tapAt(const Offset(760, 200));
      await tester.pump();
      expect(_counter(c, 2, 4), findsOneWidget);

      await _autoOn(tester);
      await tester.tapAt(const Offset(760, 200));
      await tester.pump();
      // O'tmadi, pauza.
      expect(_counter(c, 2, 4), findsOneWidget);
      expect(find.text(c.l.lectureAutoPause), findsOneWidget);
      await tester.tapAt(const Offset(760, 200));
      await tester.pump();
      expect(find.text(c.l.lectureAutoPause), findsNothing);
      await tester.pump(const Duration(seconds: 30));
      expect(_counter(c, 3, 4), findsOneWidget);
    });

    testWidgets('to‘liq ekran: Qo‘lda — yarmini bosish o‘tkazadi', (
      tester,
    ) async {
      _platformCalls(tester);
      final c = await _open(tester, size: _landscape);
      await _tapKey(tester, 'lecture-fullscreen');
      await tester.pumpAndSettle();
      expect(_key('lecture-presentation'), findsOneWidget);
      await tester.tapAt(const Offset(600, 200));
      await tester.pump();
      expect(_key('lecture-canvas-1'), findsOneWidget);
      await tester.tapAt(const Offset(100, 200));
      await tester.pump();
      expect(_key('lecture-canvas-0'), findsOneWidget);
      expect(find.text(c.l.lectureAutoPause), findsNothing);
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('to‘liq ekran: Avto — bosish pauza / davom, o‘tkazmaydi', (
      tester,
    ) async {
      _platformCalls(tester);
      final c = await _open(tester, size: _landscape);
      await _autoOn(tester);
      await _tapKey(tester, 'lecture-fullscreen');
      await tester.pumpAndSettle();
      expect(_key('lecture-presentation'), findsOneWidget);

      await tester.tapAt(const Offset(600, 200));
      await tester.pump();
      expect(_key('lecture-canvas-0'), findsOneWidget);
      expect(find.text(c.l.lectureAutoPause), findsOneWidget);
      // Chrom yashirilsa ham pauza belgisi ko'rinib turadi.
      await tester.pump(const Duration(seconds: 4));
      expect(find.text(c.l.lectureAutoPause), findsOneWidget);
      final fade = tester.widget<AnimatedOpacity>(
        find
            .ancestor(
              of: find.text(c.l.lectureAutoPause),
              matching: find.byType(AnimatedOpacity),
            )
            .first,
      );
      expect(fade.opacity, 1);

      await tester.tapAt(const Offset(600, 200));
      await tester.pump();
      expect(find.text(c.l.lectureAutoPause), findsNothing);
      await tester.pump(const Duration(seconds: 30));
      expect(_key('lecture-canvas-1'), findsOneWidget);
      // Chiqish: taymer qolmasin.
      await _tapKey(tester, 'lecture-fullscreen-exit');
      await tester.pumpAndSettle();
    });

    testWidgets('taqdimotchi ko‘rinishida ham boshqaruv bor', (tester) async {
      _platformCalls(tester);
      final c = await _open(tester, size: _landscape);
      await _tapKey(tester, 'lecture-more');
      await tester.pumpAndSettle();
      await tester.tap(_key('lecture-menu-presenter'));
      await tester.pumpAndSettle();
      expect(_key('lecture-presenter'), findsOneWidget);
      await _autoOn(tester);
      await tester.pump(const Duration(seconds: 30));
      expect(find.text(c.l.lectureCounter(2, 4)), findsWidgets);
      await tester.tap(find.text(c.l.lectureNext));
      await tester.pump();
      expect(find.text(c.l.lectureAutoPause), findsOneWidget);
      await tester.pump(const Duration(minutes: 1));
      expect(find.text(c.l.lectureCounter(3, 4)), findsWidgets);
    });
  });

  group('harakatni kamaytirish', () {
    for (final reduce in [true, false]) {
      testWidgets('to‘liq ekran tugmalari so‘nishi (kamaytirish=$reduce)', (
        tester,
      ) async {
        _platformCalls(tester);
        await _open(tester, size: _landscape, reduceMotion: reduce);
        await _tapKey(tester, 'lecture-fullscreen');
        await tester.pumpAndSettle();
        final fades = tester.widgetList<AnimatedOpacity>(
          find.descendant(
            of: _key('lecture-presentation'),
            matching: find.byType(AnimatedOpacity),
          ),
        );
        expect(fades, isNotEmpty);
        for (final f in fades) {
          expect(
            f.duration,
            reduce ? Duration.zero : const Duration(milliseconds: 250),
          );
        }
        await tester.pump(const Duration(seconds: 4));
      });
    }
  });

  group('sig‘ish va qulaylik', () {
    for (final lang in AppLanguage.values) {
      for (final (name, size, scale, dark) in [
        ('320 dp', const Size(320, 640), 1.0, false),
        ('320 dp, 2× shrift, tungi', const Size(320, 640), 2.0, true),
        ('yotiq 568×320, 1.3×', const Size(568, 320), 1.3, true),
        ('planshet 1024×768', const Size(1024, 768), 1.0, false),
      ]) {
        testWidgets('${lang.name}: $name — toshib ketmaydi, tugmalar ≥ 48 dp', (
          tester,
        ) async {
          final c = await _open(
            tester,
            lang: lang,
            size: size,
            textScale: scale,
            theme: dark ? ThemeMode.dark : ThemeMode.light,
            platformBrightness: dark ? Brightness.dark : Brightness.light,
          );
          void targets(List<String> keys) {
            for (final k in keys) {
              final r = tester.getRect(_key(k));
              expect(r.width, greaterThanOrEqualTo(47.9), reason: k);
              expect(r.height, greaterThanOrEqualTo(47.9), reason: k);
              expect(
                r.right,
                lessThanOrEqualTo(size.width + 0.5),
                reason: '$k ekrandan chiqdi',
              );
            }
          }

          targets(['lecture-auto-toggle']);
          await _autoOn(tester);
          targets([
            'lecture-auto-toggle',
            'lecture-auto-speed',
            'lecture-auto-pause',
          ]);
          // Pauzada.
          await _tapKey(tester, 'lecture-auto-pause');
          targets(['lecture-auto-toggle', 'lecture-auto-resume']);
          expect(find.text(c.l.lectureAutoPause), findsOneWidget);
          // Tezlik menyusi ochiq.
          await _tapKey(tester, 'lecture-auto-speed');
          await tester.pumpAndSettle();
          for (final s in LectureAutoPrefs.speeds) {
            expect(_key('lecture-auto-speed-$s'), findsOneWidget);
          }
          await tester.tapAt(const Offset(2, 2));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('ekran o‘qish yorliqlari (Semantics)', (tester) async {
      final handle = tester.ensureSemantics();
      final c = await _open(tester);
      expect(
        find.bySemanticsLabel(
          RegExp('${c.l.lectureAutoToggleLabel}: $_manualUz'),
        ),
        findsOneWidget,
      );
      await _autoOn(tester);
      expect(
        find.bySemanticsLabel(RegExp('${c.l.lectureAutoToggleLabel}: Avto')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(c.l.lectureAutoSpeedTitle)),
        findsWidgets,
      );
      expect(find.byTooltip(c.l.lectureAutoPause), findsOneWidget);
      await _tapKey(tester, 'lecture-auto-pause');
      expect(
        tester.getSemantics(_key('lecture-auto-resume')),
        matchesSemantics(
          label: c.l.lectureAutoPause,
          hint: c.l.lectureAutoResume,
          isButton: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('matnlar', () {
    test('uz/ru/en: yangi kalitlar bor, uz da ASCII tutuq yo‘q', () {
      for (final lang in AppLanguage.values) {
        final l = lookupAppLocalizations(lang.locale);
        for (final t in [
          l.lectureAutoModeAuto,
          l.lectureAutoModeManual,
          l.lectureAutoPause,
          l.lectureAutoResume,
          l.lectureAutoSeconds(15),
          l.lectureAutoToggleLabel,
          l.lectureAutoSpeedTitle,
        ]) {
          expect(t.trim(), isNotEmpty, reason: lang.name);
          if (lang == AppLanguage.uz) expect(t, isNot(contains("'")));
        }
      }
      final uz = lookupAppLocalizations(AppLanguage.uz.locale);
      expect(uz.lectureAutoModeManual, _manualUz);
      expect(uz.lectureAutoSeconds(30), '30 soniya');
      final en = lookupAppLocalizations(AppLanguage.en.locale);
      expect(en.lectureAutoSeconds(30), '30 seconds');
      final ru = lookupAppLocalizations(AppLanguage.ru.locale);
      expect(ru.lectureAutoSeconds(15), '15 секунд');
      expect(ru.lectureAutoSeconds(60), '60 секунд');
    });
  });
}
