import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/entitlement_service.dart';
import 'package:labguide/core/entitlements/purchase_adapter.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/billing_fakes.dart';
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

/// Do'kon build (LG_ALL_FEATURES_OPEN=false) + soxta do'kon va server.
Future<(AppServices, FakePurchaseAdapter)> _storeBuild(
  WidgetTester tester, {
  bool available = true,
  AppLanguage language = AppLanguage.uz,
  List<PurchaseProof> proofs = const [],
}) async {
  final shop = FakePurchaseAdapter(available: available, proofs: proofs);
  final s = await makeServices(
    tester,
    language: language,
    allFeaturesOpen: false,
    purchases: shop,
    // Mehmon (hisobsiz) — xarid uchun hisob talab qilinmaydi.
    entitlementSource: FakeEntitlementSource(user: null),
  );
  return (s, shop);
}

void main() {
  testWidgets(
    'to‘lov yoqilmagan do‘kon build: hammasi ochiq, Obuna qatori va '
    '“Hali mavjud emas” yo‘q',
    (tester) async {
      final s = await makeServices(tester, allFeaturesOpen: false);
      await pumpApp(tester, s, size: _tall);
      expect(s.entitlements.purchasesEnabled, isFalse);
      for (var i = 0; i < 4; i++) {
        await _quickExam(tester, uz);
      }
      await goTo(tester, '/learn/exam');
      await _scrollTo(tester, find.text(uz.examHistoryClear));
      expect(find.text('0%'), findsNWidgets(4), reason: 'tarix cheklanmagan');
      expect(find.textContaining('eski natija'), findsNothing);

      await goTo(tester, '/profile');
      expect(find.text(uz.profilePurchase), findsNothing);

      // To'g'ridan-to'g'ri manzil bilan ham — hech qanday xarid elementi yo'q.
      await goTo(tester, '/profile/purchase');
      expect(find.text(uz.payAllOpen), findsOneWidget);
      expect(find.textContaining(uz.notAvailableYet), findsNothing);
      expect(find.text(uz.paySubscribe), findsNothing);
      expect(find.text(uz.payRestore), findsNothing);
      expect(find.textContaining('bosqich'), findsNothing);
    },
  );

  testWidgets('to‘lov yoqilgach: tarixda oxirgi 3 ta, eskilari saqlangan', (
    tester,
  ) async {
    final (s, shop) = await _storeBuild(tester, available: false);
    await pumpApp(tester, s, size: _tall);
    // Mahsulotlar hali yuklanmagan — imtihon ochiq.
    for (var i = 0; i < 5; i++) {
      await _quickExam(tester, uz);
    }
    shop.setAvailable(true);
    await tester.pumpAndSettle();
    expect(s.entitlements.gatingActive, isTrue);
    expect(s.exams.history, hasLength(5), reason: 'hech narsa o‘chmagan');
    await goTo(tester, '/learn/exam');
    await _scrollTo(tester, find.text(uz.examHistoryHidden(2, 3)));
    expect(find.text(uz.examHistoryHidden(2, 3)), findsOneWidget);
    expect(find.text('0%'), findsNWidgets(3));
  });

  testWidgets('Pro imkoniyat: boshlashdan OLDIN to‘lov oynasi, test boshlanmaydi', (
    tester,
  ) async {
    final (s, _) = await _storeBuild(tester);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/exam');
    await enterField(tester, uz.examCount, '3');
    await enterField(tester, uz.examTime, '10');
    await tapScroll(tester, uz.examStart);
    expect(find.text(uz.payLockedPro), findsOneWidget);
    expect(s.exams.active, isNull);
  });

  testWidgets('mashq va atlas: yangi raund Pro, to‘lov yoqilmasa ochiq', (
    tester,
  ) async {
    final (s, shop) = await _storeBuild(tester, available: false);
    await pumpApp(tester, s, size: _tall);
    final mixed = uz.quizTopicMixed(
      s.content.pack!.quiz.length < 10 ? s.content.pack!.quiz.length : 10,
    );
    // To'lov yoqilmagan — mashq darhol boshlanadi.
    await goTo(tester, '/learn/quiz');
    await tapScroll(tester, mixed);
    expect(find.text(uz.quizChooseTopic), findsNothing);
    expect(find.text(uz.payLockedPro), findsNothing);

    shop.setAvailable(true);
    await goTo(tester, '/learn/quiz?fresh=1');
    await tapScroll(tester, mixed);
    expect(find.text(uz.payLockedPro), findsOneWidget);

    await goTo(tester, '/lab/microscopy/quiz');
    final start = find.byIcon(Icons.play_arrow_rounded).hitTestable();
    await tester.ensureVisible(start.first);
    await tester.tap(start.first);
    await tester.pumpAndSettle();
    expect(find.text(uz.payLockedPro), findsOneWidget);
  });

  testWidgets(
    'to‘lov oynasi (3.1.2): do‘kon narxi, davr, sinov, shartlar, tiklash; '
    'mehmon xarid qiladi',
    (tester) async {
      final (s, shop) = await _storeBuild(
        tester,
        proofs: const [
          PurchaseProof(
            platform: 'app_store',
            productId: BillingCatalog.proMonthly,
            token: '2000000777',
          ),
        ],
      );
      await pumpApp(tester, s, size: _tall);
      await goTo(tester, '/profile');
      expect(find.text(uz.profilePurchase), findsOneWidget);
      await goTo(tester, '/profile/purchase');

      final monthly = uz.payPricePer(r'$4.99', uz.payUnitMonth);
      expect(find.text(monthly), findsOneWidget);
      expect(find.text(uz.payTrial(uz.payDays(7), monthly)), findsOneWidget);
      expect(find.text(uz.payPricePer(r'$34.99', uz.payUnitYear)), findsOneWidget);
      final teacher = uz.payPricePer(r'$9.99', uz.payUnitMonth);
      expect(find.text(teacher), findsOneWidget);
      expect(find.text(uz.payTrial(uz.payDays(14), teacher)), findsOneWidget);
      // Talaba narxi — faqat tasdiqlangan talabaga (hozir tasdiq yo'q).
      expect(find.textContaining(r'$1.49'), findsNothing);
      expect(find.text(uz.payTierPro), findsWidgets);
      expect(find.text(uz.payTierTeacher), findsOneWidget);
      expect(find.text(uz.payFeatExam), findsOneWidget);
      expect(find.text(uz.payFeatLecture), findsOneWidget);
      expect(find.textContaining('PDF'), findsNothing);
      // Pastki qism (ro'yxat dangasa quriladi — surib ko'riladi).
      for (final t in [
        uz.payDisclosure('App Store'),
        uz.payRestore,
        uz.payManage,
        uz.payTerms,
        uz.payPrivacy,
      ]) {
        await _scrollTo(tester, find.text(t));
        expect(find.text(t), findsOneWidget);
      }
      expect(find.textContaining(uz.notAvailableYet), findsNothing);

      // Oylik Pro (birinchi reja) — yuqoriga qaytib bosiladi.
      await tester.scrollUntilVisible(
        find.text(monthly),
        -300,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      await tester.ensureVisible(find.text(uz.payStartTrial).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(uz.payStartTrial).first);
      await tester.pumpAndSettle();
      expect(shop.bought.single.$1, BillingCatalog.proMonthly);
      expect(find.text(uz.paySuccess), findsOneWidget);
      expect(s.entitlements.proSource, ProSource.store);
      expect(shop.finished, hasLength(1));
      await _scrollTo(tester, find.text(uz.payCurrent));
      expect(find.text(uz.payCurrent), findsOneWidget);
    },
  );

  testWidgets('to‘lov oynasi ru: tiklash — topilmadi, sig‘adi', (tester) async {
    final (s, _) = await _storeBuild(tester, language: AppLanguage.ru);
    await pumpApp(tester, s);
    await goTo(tester, '/profile/purchase');
    await _scrollTo(tester, find.text(ru.payTierTeacher));
    expect(find.text(ru.payTierTeacher), findsOneWidget);
    await tapScroll(tester, ru.payRestore);
    expect(find.text(ru.payNothingFound), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TestFlight: hammasi ochiq, Obuna qatori yo‘q', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _tall);
    expect(s.entitlements.proSource, ProSource.buildOpen);
    for (var i = 0; i < 4; i++) {
      await _quickExam(tester, uz);
    }
    await goTo(tester, '/learn/exam');
    await _scrollTo(tester, find.text(uz.examHistoryClear));
    expect(find.text('0%'), findsNWidgets(4));
    await goTo(tester, '/profile');
    expect(find.text(uz.profilePurchase), findsNothing);
    await goTo(tester, '/profile/purchase');
    expect(find.text(uz.payTestBuildOpen), findsOneWidget);
    expect(find.textContaining(uz.notAvailableYet), findsNothing);
  });

  testWidgets('lokal ma’lumotni o‘chirish Pro keshini ham tozalaydi', (
    tester,
  ) async {
    final AppServices s = await makeServices(tester, allFeaturesOpen: false);
    await s.deleteLocalData(const [Locale('uz')]);
    expect(s.entitlements.cached, isNull);
  });
}
