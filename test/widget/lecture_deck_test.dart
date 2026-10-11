// Tayyor taqdimot (assets/lectures): 1-mavzu Ma'ruza rejimida — uz/ru/en.
// Qoralama holati halol ko'rsatiladi, ustoz izohi faqat tugma bilan ochiladi.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/lecture_decks.dart';
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
      final deck = (await tester.runAsync(
        () => LectureDecks.forTopic(rootBundle, 'd001-P'),
      ))!;
      final n = deck.slides.length;
      final s = await makeServices(
        tester,
        role: AppRole.teacher,
        language: lang,
      );
      await pumpApp(tester, s, size: _tall);

      await goTo(tester, '/learn/lecture');
      expect(
        find.textContaining(l.lectureDeckReady(n)),
        findsNWidgets(2), // amaliy (d001-P) va ma'ruza (d001-L)
      );

      await goTo(tester, '/learn/lecture/d001-P');
      expect(find.text(l.lectureCounter(1, n)), findsOneWidget);
      Finder slideImage(int k) => find.byKey(ValueKey(deck.slides[k].image));
      expect(slideImage(0), findsOneWidget);
      // "Qoralama" yozuvi slayd rasmining o'zida; alohida ogohlantirish yo'q.
      expect(deck.draft, isTrue);
      expect(find.textContaining(l.lectureDraftNotice), findsNothing);
      expect(
        find.textContaining(l.lectureUzOnly),
        lang == AppLanguage.uz ? findsNothing : findsOneWidget,
      );

      // Ustoz izohi: yashirin, tugma bilan ochiladi va keyingi slaydda ham
      // ochiq qoladi.
      final withNote = deck.slides.indexWhere((d) => d.note != null);
      for (var i = 0; i < withNote; i++) {
        await tester.tap(find.text(l.lectureNext));
        await tester.pumpAndSettle();
      }
      final slide = deck.slides[withNote];
      expect(slideImage(withNote), findsOneWidget);
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
      expect(slideImage(n - 1), findsOneWidget);
      await tester.tap(find.text(l.lectureNext));
      await tester.pumpAndSettle();
      expect(find.text(l.lectureCounter(n, n)), findsOneWidget);
    });
  }

  testWidgets('tayyor taqdimotsiz mavzu — avtomatik slaydlar', (tester) async {
    installDiffFakes();
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await makeServices(tester, role: AppRole.teacher);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/lecture/d003-L');
    expect(find.textContaining(l.lectureDraftNotice), findsNothing);
    expect(find.byTooltip(l.lectureNotesShow), findsNothing);
    expect(find.textContaining(' / '), findsWidgets);
  });

  testWidgets('yotiq ekran (TV): slayd to‘liq, chetini bosib o‘tish', (
    tester,
  ) async {
    installDiffFakes();
    final l = lookupAppLocalizations(const Locale('uz'));
    final deck = (await tester.runAsync(
      () => LectureDecks.forTopic(rootBundle, 'd001-P'),
    ))!;
    final s = await makeServices(tester, role: AppRole.teacher);
    await pumpApp(tester, s, size: const Size(960, 540));
    await goTo(tester, '/learn/lecture/d001-P');
    final img = find.byKey(ValueKey(deck.slides.first.image));
    expect(img, findsOneWidget);
    // Rasm deyarli butun balandlikni egallaydi.
    expect(tester.getSize(img).height, greaterThan(400));
    expect(find.text(l.lectureNext), findsNothing);
    await tester.tapAt(const Offset(900, 270));
    await tester.pumpAndSettle();
    expect(find.text(l.lectureCounter(2, deck.slides.length)), findsOneWidget);
    await tester.tapAt(const Offset(60, 270));
    await tester.pumpAndSettle();
    expect(find.text(l.lectureCounter(1, deck.slides.length)), findsOneWidget);
    await tester.tap(find.byTooltip(l.lectureNext));
    await tester.pumpAndSettle();
    final withNote = deck.slides.indexWhere((d) => d.note != null);
    for (var k = 1; k < withNote; k++) {
      await tester.tap(find.byTooltip(l.lectureNext));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byTooltip(l.lectureNotesShow));
    await tester.pumpAndSettle();
    expect(find.text(deck.slides[withNote].note!), findsOneWidget);
  });
}
