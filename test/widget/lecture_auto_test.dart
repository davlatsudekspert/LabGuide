// Avtomatik taqdimot (D-47): tanlash → ko'rish (tartib, olib tashlash) →
// Ma'ruza pleyeri; uz/ru/en; yotiq 1920×1080 (televizor) va 320 px / 1.3×.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/classroom/auto_deck.dart';
import 'package:labguide/features/classroom/lecture_slide.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/billing_fakes.dart';
import '../helpers/diff_device_fakes.dart';
import '../helpers/harness.dart';

const _tall = Size(390, 2400);

AutoDeck _deck(AppServices s, AppLocalizations l, AutoDeckSpec spec) =>
    buildAutoDeck(
      l: l,
      pack: s.content.pack!,
      spec: spec,
      curriculum: s.curriculum.curriculum,
      atlas: s.microscopy.atlas,
    );

/// Kalit bo'yicha: kerak bo'lsa suradi (ro'yxat dangasa quriladi), so'ng bosadi.
Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _next(WidgetTester tester, AppLocalizations l) async {
  await tester.tap(find.text(l.lectureNext));
  await tester.pumpAndSettle();
}

/// Pleyerni to'g'ridan-to'g'ri ochish (yig'ilgan deck bilan).
Future<void> _play(WidgetTester tester, List<LectureSlide> slides) async {
  routerOf(tester).go('/learn/lecture/auto/play', extra: slides);
  await tester.pumpAndSettle();
}

/// Pleyerdagi barcha slaydlarni aylanib chiqadi; har birida manba ko'rinadi,
/// overflow yo'q (test oynasi ushlaydi). [fits] — televizorda scrollsiz sig'ish.
Future<void> _walk(
  WidgetTester tester,
  AppLocalizations l,
  List<LectureSlide> slides, {
  bool fits = false,
  List<String>? misfit,
}) async {
  final size = tester.view.physicalSize / tester.view.devicePixelRatio;
  for (var i = 0; i < slides.length; i++) {
    expect(find.text(l.lectureCounter(i + 1, slides.length)), findsOneWidget);
    final s = slides[i];
    // Manba har slaydda ko'rinadi va ekran ichida.
    final source = find.byKey(const ValueKey('lecture-source'));
    expect(source, findsOneWidget, reason: 'manba: ${s.title}');
    expect(tester.getRect(source).right, lessThanOrEqualTo(size.width + 0.5));
    if (s.template == SlideTemplate.qa) {
      await tester.ensureVisible(find.byKey(const ValueKey('lecture-answer')));
      await tester.tap(find.byKey(const ValueKey('lecture-answer')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('lecture-answer-text')), findsOneWidget);
    }
    if (fits) {
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      if (position.maxScrollExtent > 1) {
        misfit?.add(s.title);
      }
    }
    expect(tester.takeException(), isNull, reason: s.title);
    if (i < slides.length - 1) await _next(tester, l);
  }
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('tahlillar → ko‘rish → pleyer (${lang.name})', (tester) async {
      installDiffFakes();
      final l = lookupAppLocalizations(lang.locale);
      final s = await makeServices(
        tester,
        role: AppRole.teacher,
        language: lang,
      );
      await pumpApp(tester, s, size: _tall);

      // Ma'ruza ro'yxatida kirish qatori.
      await goTo(tester, '/learn/lecture');
      expect(find.text(l.autoPresTitle), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('lecture-auto-entry')));
      await tester.pumpAndSettle();
      expect(find.text(l.autoPresPickerSub), findsOneWidget);
      // Hech narsa tanlanmagan — davom etib bo'lmaydi.
      expect(find.text(l.autoPresPickFirst), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('auto-mode-tests')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'glucose');
      await tester.pumpAndSettle();
      final glucose = find.byKey(
        const ValueKey('auto-analyte-glucose-plasma-fasting'),
      );
      expect(glucose, findsOneWidget);
      await tester.tap(glucose);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'ldl');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('auto-analyte-ldl-c')));
      await tester.pumpAndSettle();
      expect(
        find.text(l.autoPresSelectedCount(2, autoMaxAnalytes)),
        findsOneWidget,
      );
      expect(find.text(l.autoPresPickFirst), findsNothing);

      final expected = _deck(
        s,
        l,
        const AutoDeckSpec(analyteIds: ['glucose-plasma-fasting', 'ldl-c']),
      );
      final n = expected.slides.length;
      await _tapKey(tester, 'auto-preview');

      // Ko'rish: slaydlar soni, tartib, olib tashlash, qaytarish.
      expect(find.text(l.autoPresPreviewTitle), findsWidgets);
      expect(find.text(l.autoPresSlideCount(n)), findsOneWidget);
      final first = expected.slides[0];
      final second = expected.slides[1];
      double top(AutoSlide a) =>
          tester.getTopLeft(find.byKey(ValueKey('auto-row-${a.id}'))).dy;
      expect(top(first), lessThan(top(second)));
      await tester.tap(find.byKey(ValueKey('auto-down-${first.id}')));
      await tester.pumpAndSettle();
      expect(top(second), lessThan(top(first)));

      final removed = expected.slides[3];
      await tester.tap(find.byKey(ValueKey('auto-remove-${removed.id}')));
      await tester.pumpAndSettle();
      expect(find.text(l.autoPresSlideCount(n - 1)), findsOneWidget);
      expect(find.byKey(ValueKey('auto-row-${removed.id}')), findsNothing);
      await _tapKey(tester, 'auto-restore');
      expect(find.text(l.autoPresSlideCount(n)), findsOneWidget);
      expect(find.byKey(ValueKey('auto-row-${removed.id}')), findsOneWidget);

      // Savol slaydlarining birini olib tashlab boshlaymiz.
      final qa = expected.slides.firstWhere(
        (a) => a.kind == AutoSlideKind.quiz,
      );
      await _tapKey(tester, 'auto-remove-${qa.id}');
      expect(find.text(l.autoPresSlideCount(n - 1)), findsOneWidget);

      final kept = [
        for (final a in expected.slides)
          if (a.id != qa.id) a,
      ]..swap(0, 1);
      final finalSlides = assembleAutoDeck(l, expected, kept);
      await _tapKey(tester, 'auto-start');

      // Pleyer: yig'ilgan slaydlar (tartib o'zgargan, manbalar slaydi oxirida).
      expect(
        find.text(l.lectureCounter(1, finalSlides.length)),
        findsOneWidget,
      );
      expect(find.text(finalSlides.first.title), findsOneWidget);
      expect(finalSlides.last.title, startsWith(l.analyteSources));
      await _walk(tester, l, finalSlides);
      expect(find.text(finalSlides.last.title), findsOneWidget);
    });
  }

  testWidgets('mavzu bo‘yicha: tanlash → ko‘rish (ru)', (tester) async {
    installDiffFakes();
    final l = lookupAppLocalizations(const Locale('ru'));
    final s = await makeServices(
      tester,
      role: AppRole.teacher,
      language: AppLanguage.ru,
    );
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/lecture/auto');
    final module = s.curriculum.curriculum!.moduleOf(
      s.curriculum.curriculum!.topic('d007-P')!,
    )!;
    await _tapKey(tester, 'auto-module-${module.id}');
    await _tapKey(tester, 'auto-topic-d007-P');
    expect(find.byKey(const ValueKey('auto-topic-chosen')), findsOneWidget);
    await _tapKey(tester, 'auto-preview');
    final expected = _deck(s, l, const AutoDeckSpec(topicId: 'd007-P'));
    expect(
      find.text(l.autoPresSlideCount(expected.slides.length)),
      findsOneWidget,
    );
    expect(expected.slides.first.slide.title, isNot(l.autoPresDeckTitleTests));
    expect(
      find.textContaining(expected.slides.first.slide.title),
      findsWidgets,
    );
  });

  testWidgets('mazmun yetmasa — bo‘sh holat, boshlash yo‘q', (tester) async {
    installDiffFakes();
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await makeServices(tester, role: AppRole.teacher);
    await pumpApp(tester, s, size: _tall);
    routerOf(tester).go(
      '/learn/lecture/auto/preview',
      extra: const AutoDeckSpec(analyteIds: ['no-such-card']),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('auto-empty')), findsOneWidget);
    expect(find.text(l.autoPresEmptyTitle), findsOneWidget);
    expect(find.text(l.autoPresEmptyBody), findsOneWidget);
    expect(find.byKey(const ValueKey('auto-start')), findsNothing);
  });

  testWidgets('Ustoz Pro: bepul foydalanuvchi uchun yopiq (do‘kon build)', (
    tester,
  ) async {
    installDiffFakes();
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await makeServices(
      tester,
      role: AppRole.teacher,
      allFeaturesOpen: false,
      purchases: FakePurchaseAdapter(available: true),
      entitlementSource: FakeEntitlementSource(user: null),
    );
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/lecture');
    await tester.tap(find.byKey(const ValueKey('lecture-auto-entry')));
    await tester.pumpAndSettle();
    expect(find.text(l.payLockedTeacher), findsOneWidget);
    expect(find.text(l.autoPresPickerSub), findsNothing);
  });

  group('televizor 1920×1080', () {
    for (final lang in AppLanguage.values) {
      // Butun taqdimot (mavzu, umumiy preanalitika, atlas, savollar,
      // manbalar): hech bir slayd scrollsiz sig'maslik yoki kesilmasin.
      testWidgets('butun taqdimot sig‘adi, kesilmaydi (${lang.name})', (
        tester,
      ) async {
        installDiffFakes();
        final l = lookupAppLocalizations(lang.locale);
        final s = await makeServices(
          tester,
          role: AppRole.teacher,
          language: lang,
        );
        await pumpApp(tester, s, size: const Size(1920, 1080), notch: false);
        final deck = _deck(
          s,
          l,
          const AutoDeckSpec(
            topicId: 'd027-P',
            includeGeneralPreanalytics: true,
          ),
        );
        expect({
          for (final a in deck.slides) a.slide.template,
        }, SlideTemplate.values.toSet());
        final slides = assembleAutoDeck(l, deck, deck.slides);
        await _play(tester, slides);
        final misfit = <String>[];
        await _walk(tester, l, slides, fits: true, misfit: misfit);
        expect(misfit, isEmpty, reason: 'televizorda scroll kerak: $misfit');
      });
    }
  });

  group('tor ekran 320 px, 1.3× shrift', () {
    for (final lang in AppLanguage.values) {
      testWidgets('tanlash, ko‘rish va slaydlar (${lang.name})', (
        tester,
      ) async {
        installDiffFakes();
        final l = lookupAppLocalizations(lang.locale);
        final s = await makeServices(
          tester,
          role: AppRole.teacher,
          language: lang,
        );
        await pumpApp(tester, s, size: const Size(320, 640), textScale: 1.3);
        // Tanlash ekrani (ikkala rejim).
        await goTo(tester, '/learn/lecture/auto');
        expect(tester.takeException(), isNull);
        await _tapKey(tester, 'auto-mode-tests');
        await tester.enterText(find.byType(TextField), 'glucose');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final deck = _deck(
          s,
          l,
          const AutoDeckSpec(
            topicId: 'd027-P',
            includeGeneralPreanalytics: true,
          ),
        );
        // Ko'rish ekrani.
        routerOf(tester).go(
          '/learn/lecture/auto/preview',
          extra: const AutoDeckSpec(
            topicId: 'd027-P',
            includeGeneralPreanalytics: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.text(l.autoPresSlideCount(deck.slides.length)),
          findsOneWidget,
        );

        // Butun taqdimot: har slayd (hamma shablon) 320 px da kesilmaydi.
        final slides = assembleAutoDeck(l, deck, deck.slides);
        await _play(tester, slides);
        await _walk(tester, l, slides);
      });
    }
  });
}

extension<T> on List<T> {
  void swap(int a, int b) {
    final t = this[a];
    this[a] = this[b];
    this[b] = t;
  }
}
