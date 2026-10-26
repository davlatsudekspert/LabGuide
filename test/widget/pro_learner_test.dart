// Talaba Pro (D-78): imtihon simulyatsiyasi, natijalar tahlili va eksport.
// Eshik holatlari: yopiq / sinov / obuna / muddati o'tgan / oflayn kesh /
// mehmon; bayroq o'chiq — kirish nuqtalari yo'q (bepul ekran `main` kabi).
// Boshlangan simulyatsiya to'xtatilmaydi; saqlangan natijalar obunasiz ham
// ko'rinadi.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/share/file_export.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';
import '../helpers/pro_states.dart';

final uz = lookupAppLocalizations(const Locale('uz'));

const _tall = Size(390, 2600);

final _locked = find.byKey(const ValueKey('pay-locked'));

/// Tarixga [n] ta yakunlangan imtihon (paket savollari).
Future<List<ExamSession>> seedExams(
  WidgetTester tester,
  AppServices s, {
  int n = 3,
  bool simulation = false,
}) async {
  final out = <ExamSession>[];
  await tester.runAsync(() async {
    final pool = examPool(PackQuestionSource.of(s.content.pack!), const {});
    for (var k = 0; k < n; k++) {
      final session = ExamSession.build(
        id: s.exams.newId(),
        mode: ExamMode.exam,
        questions: pool.skip(k * 5).take(6).toList(),
        random: s.exams.random,
        startedAt: s.exams.now(),
        limit: const Duration(minutes: 10),
        passPercent: simulation ? 50 : null,
        simulation: simulation,
      );
      for (var i = 0; i <= k && i < session.length; i++) {
        session.goTo(i);
        session.choose(session.items[i].order.indexOf(session.items[i].correct.first));
      }
      await s.exams.start(session);
      out.add((await s.exams.finishActive())!);
    }
  });
  return out;
}

Future<void> _scrollTo(WidgetTester tester, Finder f) => tester.scrollUntilVisible(
  f,
  300,
  scrollable: find.byType(Scrollable).hitTestable().first,
);

Future<void> _tap(WidgetTester tester, Finder f) async {
  await _scrollTo(tester, f);
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('bayroq o‘chiq: imtihon ekranida Pro kirish nuqtalari yo‘q', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await seedExams(tester, s);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/exam');
    expect(find.byKey(const ValueKey('exam-sim-entry')), findsNothing);
    expect(find.byKey(const ValueKey('exam-results-entry')), findsNothing);
    expect(find.text(uz.proSimTitle), findsNothing);
  });

  for (final state in GateState.values) {
    testWidgets('simulyatsiya kirish: ${state.name} — '
        '${opens(state) ? 'ochiladi' : 'to‘lov oynasi'}', (tester) async {
      final (s, _, _) = await proApp(tester, state, plan: ProPlan.student);
      await pumpApp(tester, s, size: _tall);
      await goTo(tester, '/learn/exam');
      // Bepul imtihon rejimi o'zgarmagan va ochiq.
      expect(find.text(uz.examStart), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('exam-sim-entry')));
      if (opens(state)) {
        expect(find.byKey(const ValueKey('sim-start')), findsOneWidget);
        expect(_locked, findsNothing);
      } else {
        expect(_locked, findsOneWidget);
        expect(find.text(uz.proLockedLearner), findsOneWidget);
        expect(
          find.byKey(const ValueKey('pay-guest-note')),
          state == GateState.guest ? findsOneWidget : findsNothing,
        );
        expect(s.exams.active, isNull);
      }
    });
  }

  testWidgets('simulyatsiya: ketma-ket (xarita, belgilash, orqaga yo‘q), '
      'vaqt yoziladi, hisobot va tarix', (tester) async {
    final (s, _, _) = await proApp(tester, GateState.subscribed);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/simulation');
    await enterField(tester, uz.examCount, '3');
    await enterField(tester, uz.toifaTimeLabel, '10');
    await enterField(tester, uz.toifaPassLabel, '60');
    await _tap(tester, find.byKey(const ValueKey('sim-start')));
    final run = s.exams.active!;
    expect(run.simulation, isTrue);
    expect(run.passPercent, 60);
    expect(run.length, 3);
    expect(find.text(uz.examMap), findsNothing);
    expect(find.text(uz.examFlag), findsNothing);
    final prev = tester.widget<LgButton>(
      find.widgetWithText(LgButton, uz.examPrev),
    );
    expect(prev.onPressed, isNull, reason: 'orqaga qaytish yo‘q');
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text(uz.examNext).hitTestable());
      await tester.pumpAndSettle();
    }
    expect(s.exams.active!.index, 2);
    final finish = find.widgetWithText(LgButton, uz.examFinish).hitTestable();
    await tester.tap(finish.last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(uz.examFinish).hitTestable().last);
    await tester.pumpAndSettle();
    expect(s.exams.active, isNull);
    final done = s.exams.history.first;
    expect(done.simulation, isTrue);
    expect(done.timeAt(0), isNotNull);
    expect(find.byKey(const ValueKey('sim-report')), findsOneWidget);
    expect(find.text(uz.examPassMissed(60)), findsOneWidget);
    expect(find.text(uz.proSimAvgPerQuestion), findsOneWidget);
    // Bepul tarixda ham ko'rinadi (yashirilmaydi).
    await goTo(tester, '/learn/exam');
    await _scrollTo(tester, find.text(uz.examHistoryClear));
    expect(find.text('0%'), findsWidgets);
  });

  testWidgets('boshlangan simulyatsiya obuna tugasa ham to‘xtatilmaydi; '
      'hisobot ochiladi, yangisi — to‘lov oynasi', (tester) async {
    final (s, _, server) = await proApp(tester, GateState.subscribed);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/simulation');
    await enterField(tester, uz.examCount, '2');
    await _tap(tester, find.byKey(const ValueKey('sim-start')));
    expect(s.exams.active?.simulation, isTrue);
    // Obuna shu payt tugadi (server endi muddati o'tgan deydi).
    final now = DateTime.now().toUtc();
    server.snapshot = EntitlementSnapshot(serverTime: now, items: const []);
    await tester.runAsync(() => s.entitlements.refresh(reprobe: false));
    await tester.pumpAndSettle();
    expect(s.entitlements.isPro, isFalse);
    expect(find.text(uz.examNext), findsOneWidget, reason: 'davom etmoqda');
    await tester.tap(find.text(uz.examNext).hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(LgButton, uz.examFinish).hitTestable().last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(uz.examFinish).hitTestable().last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sim-report')), findsOneWidget);
    expect(_locked, findsNothing);
    // Yangi simulyatsiya — boshlanmaydi: tekshiruv boshlash tugmasida.
    await goTo(tester, '/learn/simulation');
    final start = find.byKey(const ValueKey('sim-start'));
    if (start.evaluate().isNotEmpty) {
      await _tap(tester, start);
      expect(_locked, findsOneWidget);
      await goTo(tester, '/learn/simulation');
    } else {
      expect(find.byKey(const ValueKey('pro-gate-closed')), findsOneWidget);
    }
    expect(s.exams.active, isNull);
    // Oldingi simulyatsiyalar ro'yxati — ko'rinadi.
    expect(find.text(uz.proSimHistory), findsOneWidget);
  });

  testWidgets('muddati o‘tgan: saqlangan simulyatsiya hisoboti va tarix '
      'ochiq; tahlil va eksport yopiq', (tester) async {
    final (s, files, _) = await proApp(tester, GateState.expired);
    final sims = await seedExams(tester, s, n: 2, simulation: true);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/simulation/result/${sims.last.id}');
    expect(find.byKey(const ValueKey('sim-report')), findsOneWidget);
    expect(_locked, findsNothing);
    await goTo(tester, '/learn/exam');
    expect(find.text('${sims.last.percent}%'), findsWidgets);
    await _tap(tester, find.byKey(const ValueKey('exam-results-entry')));
    expect(_locked, findsOneWidget);
    // To'g'ridan-to'g'ri havola bilan ham — yopiq holat, ma'lumot joyida.
    await goTo(tester, '/learn/results');
    expect(find.byKey(const ValueKey('pro-gate-closed')), findsOneWidget);
    expect(s.exams.history, hasLength(2));
    expect(files.shared, isEmpty);
  });

  for (final state in [GateState.trial, GateState.subscribed, GateState.offline]) {
    testWidgets('natijalar tahlili va eksport (${state.name}): trend, '
        'mavzular, to‘liq tarix, CSV va PDF', (tester) async {
      final (s, files, _) = await proApp(tester, state, plan: ProPlan.student);
      await seedExams(tester, s, n: 4);
      await pumpApp(tester, s, size: _tall);
      await goTo(tester, '/learn/exam');
      await _tap(tester, find.byKey(const ValueKey('exam-results-entry')));
      expect(find.byKey(const ValueKey('results-analytics')), findsOneWidget);
      expect(find.text(uz.proResultsTopics), findsOneWidget);
      for (final e in s.exams.history) {
        await _scrollTo(tester, find.byKey(ValueKey('results-row-${e.id}')));
      }
      await _tap(tester, find.byKey(const ValueKey('export-button')));
      await tester.tap(find.byKey(const ValueKey('export-csv')));
      await tester.pumpAndSettle();
      final csv = files.lastCsv()!;
      expect(csv, startsWith('finished_at,source,title,mode'));
      expect('\n'.allMatches(csv), hasLength(5), reason: 'sarlavha + 4');
      expect(files.shared.single, hasLength(2));
      expect(find.text(uz.proExportShared), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('export-button')));
      await tester.tap(find.byKey(const ValueKey('export-pdf')));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pumpAndSettle();
      final pdf = files.last(ExportFile.pdf)!;
      expect(latin1.decode(pdf.bytes.sublist(0, 8)), '%PDF-1.7');
      expect(pdf.name, endsWith('.pdf'));
    });
  }

  for (final lang in AppLanguage.values) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('maket: ${lang.name} 320 px ×2.0 ${theme.name} — '
          'simulyatsiya, hisobot, tahlil (overflow yo‘q)', (tester) async {
        final (s, _, _) = await proApp(
          tester,
          GateState.subscribed,
          language: lang,
          themeMode: theme,
        );
        final sims = await seedExams(tester, s, n: 2, simulation: true);
        await seedExams(tester, s, n: 2);
        await pumpApp(tester, s, size: const Size(320, 640), textScale: 2.0);
        for (final path in [
          '/learn/exam',
          '/learn/simulation',
          '/learn/simulation/result/${sims.last.id}',
          '/learn/results',
        ]) {
          await goTo(tester, path);
          expect(tester.takeException(), isNull, reason: path);
          for (var i = 0; i < 30; i++) {
            final scroll = find.byType(Scrollable).hitTestable();
            if (scroll.evaluate().isEmpty) break;
            await tester.drag(scroll.first, const Offset(0, -400));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '$path #$i');
          }
        }
      });
    }
  }
}
