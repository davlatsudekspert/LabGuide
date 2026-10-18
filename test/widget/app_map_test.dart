// Ilova xaritasi (docs/APP_MAP_2026-10-18.md): bir xil narsaning bir xil
// nomi, takror vositalar orasidagi havolalar va guruh darsida tayyor taqdimot.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/curriculum.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/home/home_screen.dart';
import 'package:labguide/features/home/resume_history.dart';
import 'package:labguide/features/learn/learn_screens.dart'
    show kLabSectionQuizzes;
import 'package:labguide/features/home/search_sections.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';

const _tall = Size(390, 2400);

String _location(WidgetTester tester) => routerOf(tester).state.matchedLocation;

Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  group('nomlar: bir manzil — bir nom (uz/ru/en)', () {
    for (final lang in AppLanguage.values) {
      test('preanalitika va izohli test (${lang.name})', () {
        final l = lookupAppLocalizations(lang.locale);
        for (final role in [AppRole.doctor, AppRole.lab]) {
          final tile = RoleHome.of(
            role,
            l,
          ).actions.singleWhere((a) => a.location == '/lab/preanalytics');
          expect(tile.label, l.labPreanalytics, reason: role.name);
        }
        // Ekran sarlavhasi va qidiruvdagi bo'lim nomi ham shu.
        expect(l.preTitle, l.labPreanalytics);
        final section = kSearchSections.singleWhere(
          (s) => s.route == '/lab/preanalytics',
        );
        expect(section.title(l), l.labPreanalytics);
        // Talaba: "Test" emas — O'rganish tabidagi nomi bilan.
        final quiz = RoleHome.of(
          AppRole.student,
          l,
        ).actions.singleWhere((a) => a.location == '/learn/quiz');
        expect(quiz.label, l.learnQuiz);
        // Kalibrlash kartasi "Apparatlar va metodikalar" bilan
        // adashtirilmaydi.
        expect(l.labHeroTitle, l.featureCalibration);
        expect(l.labCalculatorsSub, l.homeTileCalculators);
      });
    }
  });

  testWidgets('Lab tabi: avval ish vositalari, so‘ng bo‘limlar va atlaslar '
      '(D-68 Q2)', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '/lab');
    final l = lookupAppLocalizations(const Locale('uz'));
    double y(Finder f) => tester.getTopLeft(f).dy;
    final sections = find.text(l.labSectionsTitle);
    final tools = find.text(l.labToolsTitle);
    expect(sections, findsOneWidget);
    expect(tools, findsOneWidget);
    // Vositalar guruhi birinchi; ichida Leykoformula birinchi, so'ng
    // kalibrlash, QC, preanalitika, kalkulyatorlar.
    expect(y(tools), lessThan(y(sections)));
    final diff = y(find.text(l.diffTitle));
    expect(y(tools), lessThan(diff));
    for (final t in [
      l.labHeroTitle,
      l.featureQc,
      l.labPreanalytics,
      l.featureCalculators,
      l.labInstruments,
    ]) {
      expect(diff, lessThan(y(find.text(t))), reason: t);
      expect(y(find.text(t)), lessThan(y(sections)), reason: t);
    }
    // Rasmli bo'limlar va atlas — ikkinchi guruhda.
    final atlas = find.byKey(const ValueKey('lab-microscopy'));
    expect(y(sections), lessThan(y(find.text(l.cytoTitle))));
    expect(y(sections), lessThan(y(atlas)));
    await _tapKey(tester, 'lab-microscopy');
    expect(_location(tester), '/lab/microscopy');
  });

  testWidgets('leykoformula hisoblagichi ↔ mutlaq sonlar kalkulyatori', (
    tester,
  ) async {
    installDiffFakes();
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/lab/differential');
    await _tapKey(tester, 'diff-abs-calc');
    expect(_location(tester), '/lab/calculators/differential');
    await _tapKey(tester, 'mc-diff-counter');
    expect(_location(tester), '/lab/differential/count');
  });

  testWidgets('guruh darsi: Ma’ruza tayyor taqdimotni ochadi, avtomatik '
      'slaydlar tugmasi yo‘q (D-68 Q1)', (tester) async {
    installDiffFakes();
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.teacher);
    s.curriculum.use(
      Curriculum.parse(
        File('test/fixtures/curriculum_sample.json').readAsStringSync(),
      ),
    );
    await pumpApp(tester, s, size: _tall);
    await s.auth.signOut();
    await s.auth.requestCode('teacher@example.com');
    await s.auth.verifyCode(FakeLabBackend.otpCode);
    await tester.pumpAndSettle();
    await b.registerTeacher();
    final g = await b.createGroup('Guruh');
    const topic = 'd008-L';
    await b.openTopic(g.id, topic);
    final catalog = (await tester.runAsync(
      () => DeckCatalog.load(s.curriculum.bundle ?? rootBundle),
    ))!;
    final deck = catalog.byTopic(topic)!;

    await goTo(tester, '/learn/classes/g/${g.id}/t/$topic');
    expect(find.byKey(const ValueKey('group-lecture-auto')), findsNothing);
    // Pleyer deckni asinxron yuklaydi (pumpAndSettle kerak emas).
    final btn = find.byKey(const ValueKey('group-lecture-deck'));
    await tester.ensureVisible(btn);
    await tester.pumpAndSettle();
    await tester.tap(btn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(_location(tester), '/learn/lecture/deck/${deck.id}');
  });

  // --- D-68: egasi savollari Q1–Q8 bo'yicha qarorlar -----------------------

  group('Q3: “Davom ettirish” yozuvi (router manzilidan)', () {
    test('manzil → yozuv', () {
      ResumeEntry? e(String loc) => resumeEntryFor(Uri.parse(loc));
      expect(
        e('/learn/lecture/deck/d012?s=4'),
        const ResumeEntry(ResumeKind.deck, 'd012'),
      );
      expect(
        e('/learn/lecture/test/d012'),
        const ResumeEntry(ResumeKind.topicTest, 'd012'),
      );
      expect(e('/lab/qc/set/abc'), const ResumeEntry(ResumeKind.section, 'qc'));
      expect(
        e('/lab/differential'),
        const ResumeEntry(ResumeKind.section, 'differential'),
      );
      expect(
        e('/lab/calculators/dilution'),
        const ResumeEntry(ResumeKind.section, 'calculators'),
      );
      expect(e('/home'), isNull);
      expect(e('/lab'), isNull);
      expect(e('/tests/analyte/potassium'), isNull);
    });

    test('saqlash formati: kind:id; buzuq yozuv — e’tiborsiz', () {
      for (final x in const [
        ResumeEntry(ResumeKind.deck, 'd001'),
        ResumeEntry(ResumeKind.topicTest, 'kapillyar-qon-olish'),
        ResumeEntry(ResumeKind.section, 'microscopy'),
      ]) {
        expect(ResumeEntry.decode(x.encode()), x);
      }
      expect(ResumeEntry.decode(null), isNull);
      expect(ResumeEntry.decode('deck:'), isNull);
      expect(ResumeEntry.decode('nima:d001'), isNull);
      expect(ResumeEntry.decode('section:yoq-bolim'), isNull);
    });

    test('hero 1-plitkani takrorlamaydi; talabada “Kunlik savol” plitkasi '
        'yo‘q', () {
      final l = lookupAppLocalizations(const Locale('uz'));
      for (final role in [AppRole.doctor, AppRole.student]) {
        final h = RoleHome.of(role, l);
        expect(
          h.heroLocation,
          isNot(h.actions.first.location),
          reason: '$role',
        );
        expect(h.heroCta, isNot(h.actions.first.label), reason: '$role');
      }
      expect(RoleHome.of(AppRole.doctor, l).heroLocation, '/tests?search=1');
      final student = RoleHome.of(AppRole.student, l);
      expect(student.heroLocation, '/learn/daily');
      expect(
        student.actions.where((a) => a.location == '/learn/daily'),
        isEmpty,
      );
    });
  });

  testWidgets('Q3: laborant (uz) hero — bugungi toifa, so‘ng oxirgi '
      'taqdimotni davom ettirish', (tester) async {
    installDiffFakes();
    tester.platformDispatcher.localesTestValue = const [Locale('uz', 'UZ')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final s = await makeServices(tester, role: AppRole.lab);
    await pumpApp(tester, s, size: _tall);
    final l = lookupAppLocalizations(const Locale('uz'));
    final cta = find.byKey(const ValueKey('home-hero-cta'));
    expect(
      find.descendant(of: cta, matching: find.text(l.homeHeroLabToifaCta)),
      findsOneWidget,
    );
    // Taqdimot ochiladi → bosh sahifada “Davom ettirish” shu taqdimotga.
    final catalog = (await tester.runAsync(
      () => DeckCatalog.load(rootBundle),
    ))!;
    final deck = catalog.byId('d012')!;
    // Pleyer deck faylini asinxron yuklaydi — oldindan keshga.
    await tester.runAsync(
      () => DeckCatalog.loadDeck(rootBundle, deck, deck.resolveLang('uz')),
    );
    await goTo(tester, '/learn/lecture/deck/d012');
    await goTo(tester, '/home');
    expect(
      find.descendant(of: cta, matching: find.text(l.homeResumeCta)),
      findsOneWidget,
    );
    expect(find.text(l.homeResumeBody(deck.title('uz'))), findsOneWidget);
    expect(s.store.getString(StoreKeys.homeResume), 'deck:d012');
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();
    await tester.tap(cta);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(routerOf(tester).state.uri.path, '/learn/lecture/deck/d012');
  });

  testWidgets('Q5: “Dars rejasi” faqat ustozga', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    for (final role in AppRole.values) {
      final s = await makeServices(tester, role: role);
      await pumpApp(tester, s, size: const Size(390, 4000));
      await goTo(tester, '/learn');
      expect(
        find.byKey(const ValueKey('learn-lesson-plan')),
        role == AppRole.teacher ? findsOneWidget : findsNothing,
        reason: role.name,
      );
      expect(
        find.text(l.learnLessonPlan),
        role == AppRole.teacher ? findsOneWidget : findsNothing,
      );
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('Q8: O‘rganish tabida mashqi bor har Lab bo‘limining mashqi', (
    tester,
  ) async {
    installDiffFakes();
    final s = await makeServices(tester, role: AppRole.student);
    await pumpApp(tester, s, size: const Size(390, 4000));
    final l = lookupAppLocalizations(const Locale('uz'));
    expect(kLabSectionQuizzes.map((q) => q.id), [
      'differential',
      'microscopy',
      'cytology',
      'spermogram',
      'bloodgroup',
      'histology',
      'urinalysis',
      'bloodmorph',
    ]);
    for (final q in kLabSectionQuizzes) {
      await goTo(tester, '/learn');
      final row = find.byKey(ValueKey('learn-section-quiz-${q.id}'));
      expect(
        find.descendant(
          of: row,
          matching: find.text(l.learnSectionQuizRow(q.title(l))),
        ),
        findsOneWidget,
      );
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(_location(tester), q.route, reason: q.id);
      expect(tester.takeException(), isNull, reason: q.id);
    }
    expect(find.text(l.learnSectionQuizzesTitle), findsNothing); // Lab tabida
  });

  test('Q7: atlasdagi bo‘lim — “Qon parazitlari (bezgak)” (3 tilda)', () {
    final atlas = jsonDecode(
      File('assets/microscopy/atlas.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final section = (atlas['sections']! as List)
        .cast<Map<String, Object?>>()
        .singleWhere((x) => x['id'] == 'parasites');
    expect(section['name'], {
      'uz': 'Qon parazitlari (bezgak)',
      'ru': 'Кровяные паразиты (малярия)',
      'en': 'Blood parasites (malaria)',
    });
  });

  testWidgets('Q6: Profil — bitta “Yordam va aloqa”, ichida ikki yo‘l', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 3200));
    final l = lookupAppLocalizations(const Locale('uz'));
    await goTo(tester, '/profile');
    expect(find.text(l.helpTitle), findsOneWidget);
    expect(find.text(l.supportTitle), findsNothing);
    expect(find.text(l.contactRowTitle), findsNothing);
    await _tapKey(tester, 'profile-help');
    expect(_location(tester), '/profile/help');
    await _tapKey(tester, 'help-support');
    expect(_location(tester), '/profile/support');
    await goTo(tester, '/profile/help');
    await _tapKey(tester, 'help-contact');
    expect(_location(tester), '/profile/contact');
  });
}
