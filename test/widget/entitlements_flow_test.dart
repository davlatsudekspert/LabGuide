import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/entitlements/entitlement_service.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));
final ru = lookupAppLocalizations(const Locale('ru'));

const _tall = Size(390, 2400);

/// Imtihonni UI orqali boshlab, javobsiz yakunlash.
Future<void> _quickExam(WidgetTester tester, AppLocalizations l) async {
  await goTo(tester, '/learn/exam');
  await enterField(tester, l.examCount, '3');
  await enterField(tester, l.examTime, '10');
  await tapScroll(tester, l.examStart);
  await tapScroll(tester, l.examFinish);
  await tester.tap(find.text(l.examFinish).hitTestable().last);
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder f) =>
    tester.scrollUntilVisible(
      f,
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );

void main() {
  testWidgets('bepul rejim: imtihon tarixida oxirgi 3 ta, eskilari saqlangan', (
    tester,
  ) async {
    final s = await makeServices(tester, allFeaturesOpen: false);
    await pumpApp(tester, s, size: _tall);
    expect(s.entitlements.isPro, isFalse);
    for (var i = 0; i < 5; i++) {
      await _quickExam(tester, uz);
    }
    expect(s.exams.history, hasLength(5), reason: 'hech narsa o‘chmagan');
    await goTo(tester, '/learn/exam');
    await _scrollTo(tester, find.text(uz.examHistoryHidden(2, 3)));
    expect(find.text(uz.examHistoryHidden(2, 3)), findsOneWidget);
    expect(find.text('0%'), findsNWidgets(3));
  });

  testWidgets('TestFlight/debug: tarix to‘liq, yashirilgan natija yo‘q', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _tall);
    expect(s.entitlements.proSource, ProSource.buildOpen);
    for (var i = 0; i < 4; i++) {
      await _quickExam(tester, uz);
    }
    await goTo(tester, '/learn/exam');
    await _scrollTo(tester, find.text(uz.examHistoryClear));
    expect(find.text('0%'), findsNWidgets(4));
    expect(find.textContaining('eski natija'), findsNothing);
  });

  testWidgets('Obuna ekrani: halol holat, to‘lov oynasi yo‘q', (tester) async {
    final open = await makeServices(tester);
    await pumpApp(tester, open, size: _tall);
    await goTo(tester, '/profile/purchase');
    expect(find.text(uz.purchaseStatusAllOpen), findsOneWidget);
    expect(find.textContaining(uz.notAvailableYet), findsNWidgets(2));
  });

  testWidgets('Obuna ekrani: do‘kon build (bepul), ru', (tester) async {
    final s = await makeServices(
      tester,
      language: AppLanguage.ru,
      allFeaturesOpen: false,
    );
    await pumpApp(tester, s);
    await goTo(tester, '/profile/purchase');
    expect(find.text(ru.purchaseStatusFree), findsOneWidget);
    expect(find.text(ru.purchaseStatusBillingOff), findsOneWidget);
    expect(find.text(ru.purchaseStatusAllOpen), findsNothing);
    expect(s.entitlements.purchasesEnabled, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lokal ma’lumotni o‘chirish Pro keshini ham tozalaydi', (
    tester,
  ) async {
    final AppServices s = await makeServices(tester, allFeaturesOpen: false);
    await s.deleteLocalData(const [Locale('uz')]);
    expect(s.entitlements.cached, isNull);
  });
}
