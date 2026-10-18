// Ilova xaritasi (docs/APP_MAP_2026-10-18.md): bir xil narsaning bir xil
// nomi, takror vositalar orasidagi havolalar va guruh darsida tayyor taqdimot.
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/curriculum.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/home/home_screen.dart';
import 'package:labguide/features/home/search_sections.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';

const _tall = Size(390, 2400);

String _location(WidgetTester tester) =>
    routerOf(tester).state.matchedLocation;

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

  testWidgets('Lab tabi: bo‘limlar va ish vositalari sarlavhalar bilan', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '/lab');
    final l = lookupAppLocalizations(const Locale('uz'));
    double y(Finder f) => tester.getTopLeft(f).dy;
    final sections = find.text(l.labSectionsTitle);
    final tools = find.text(l.labToolsTitle);
    expect(sections, findsOneWidget);
    expect(tools, findsOneWidget);
    // Atlas bo'limlar guruhida, QC/kalibrlash — vositalar guruhida.
    final atlas = find.byKey(const ValueKey('lab-microscopy'));
    expect(y(sections), lessThan(y(find.text(l.diffTitle))));
    expect(y(atlas), lessThan(y(tools)));
    expect(y(tools), lessThan(y(find.text(l.labHeroTitle))));
    expect(y(tools), lessThan(y(find.text(l.featureQc))));
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
      'slaydlar ikkinchi tugmada', (tester) async {
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
    expect(find.byKey(const ValueKey('group-lecture-auto')), findsOneWidget);
    // Pleyer deckni asinxron yuklaydi (pumpAndSettle kerak emas).
    final btn = find.byKey(const ValueKey('group-lecture-deck'));
    await tester.ensureVisible(btn);
    await tester.pumpAndSettle();
    await tester.tap(btn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(_location(tester), '/learn/lecture/deck/${deck.id}');
  });
}
