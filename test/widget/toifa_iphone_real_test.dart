// Toifa — iPhone (390×844, iOS fizikasi), haqiqiy bank: mashq rejimidagi
// 50 savolning HAMMASI ekrandan javoblanadi (har savol ko'rinadi, darhol
// to'g'ri/xato), yarmida ilova qayta ochiladi; natija va “Ertaga davom
// etamizmi?” taklifi. Og'zaki bilet: 5 savol, yozuvsiz, bilet o'rtasida
// ilova qayta ochilsa — shu savoldan davom.
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';
import 'package:labguide/features/toifa/toifa_controller.dart';
import 'package:labguide/features/toifa/toifa_daily.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));
const _iphone = Size(390, 844);

Future<void> _answer(WidgetTester tester, ToifaController t, bool ok) async {
  final d = t.activeDrill!;
  final q = t.bank!.test(d.ids[d.index])!;
  final key = d.keys[d.index];
  expect(find.text(q.text), findsWidgets, reason: q.id);
  final idx = ok
      ? key
      : List.generate(q.optionCount, (i) => i).firstWhere((i) => i != key);
  await tapScroll(tester, q.options[idx]);
}

Future<AppServices> _app(WidgetTester tester, MemoryKeyValueStore store) async {
  final s = await makeServices(tester, store: store);
  await pumpApp(tester, s, size: _iphone);
  return s;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('mashq rejimi: 50 savol ekrandan, qayta ochilganda davom, '
      'natija va “ertaga” taklifi (iPhone)', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final store = MemoryKeyValueStore();
    var s = await _app(tester, store);
    s.toifa.random = Random(18);
    await goTo(tester, '/learn/toifa/test');
    await tester.tap(find.byKey(const ValueKey('toifa-mode-practice')));
    await tester.pumpAndSettle();
    await tapScroll(tester, uz.toifaDrillStart);
    final n = s.toifa.activeDrill!.length;
    expect(n, ToifaFormat.testSize);
    for (var i = 0; i < n; i++) {
      if (i == 25) {
        // Ilova yopilib, qayta ochildi.
        await tester.pumpWidget(const SizedBox());
        s = await _app(tester, store);
        expect(s.toifa.activeDrill!.answeredCount, 25);
        await goTo(tester, '/learn/toifa/test');
        await tapScroll(tester, uz.examResume);
      }
      final ok = i % 5 != 0;
      await _answer(tester, s.toifa, ok);
      expect(
        find.text(ok ? uz.toifaPracticeRight : uz.toifaPracticeWrong),
        findsOne,
      );
      expect(find.text(uz.examQuestionMissing), findsNothing);
      await tapScroll(tester, i == n - 1 ? uz.quizFinish : uz.quizNext);
    }
    final d = s.toifa.drill!;
    expect(d.finished, isTrue);
    expect(d.correctCount, 40);
    expect(s.toifa.todayStats, const ToifaDay(answered: 50, correct: 40));
    expect(s.toifa.todayGoalMet, isTrue);
    expect(find.byKey(const ValueKey('toifa-reminder-offer')), findsOne);
    expect(find.text(uz.toifaOfferTitle), findsOne);
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('bilet: 5 savol, bilet o‘rtasida qayta ochilsa davom (iPhone)', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final store = MemoryKeyValueStore();
    var s = await _app(tester, store);
    s.toifa.random = Random(5);
    await s.toifa.setCategory(ToifaCategory.first);
    await goTo(tester, '/learn/toifa/oral');
    await tapScroll(tester, uz.toifaDrawTicket);
    final ids = s.toifa.ticket!.ids;
    expect(ids, hasLength(ToifaFormat.ticketSize));
    // Yozuv maydoni yo'q.
    expect(find.byType(TextField), findsNothing);
    await tapScroll(tester, uz.toifaShowPlans);
    for (var i = 0; i < ids.length; i++) {
      if (i == 2) {
        await tester.pumpWidget(const SizedBox());
        s = await _app(tester, store);
        expect(s.toifa.ticket!.ratings.length, 2);
        await goTo(tester, '/learn/toifa/oral');
      }
      final q = s.toifa.bank!.oralQuestion(s.toifa.ticket!.currentId)!;
      expect(find.text(q.text), findsWidgets, reason: q.id);
      await tapScroll(tester, uz.toifaShowPlan);
      expect(find.text(q.plan.first), findsWidgets, reason: q.id);
      await tapScroll(tester, OralRating.knew.label(uz));
    }
    expect(s.toifa.ticket!.done, isTrue);
    expect(find.text(uz.toifaTicketDone), findsOne);
    expect(s.toifa.todayStats.tickets, 1);
    expect(find.text(uz.toifaOfferTitle), findsOne);
    expect(find.byType(TextField), findsNothing);
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });
}
