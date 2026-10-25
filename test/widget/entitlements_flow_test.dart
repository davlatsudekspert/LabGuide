import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/entitlement_source.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/entitlement_service.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/core/entitlements/purchase_adapter.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/billing_fakes.dart';
import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));
final ru = lookupAppLocalizations(const Locale('ru'));

const _tall = Size(390, 2400);

/// Pro YOQILGAN build + butun pullik katalog yopilgan (D-78: katalogda faqat
/// YANGI Pro funksiyalar). Haqiqiy standart — bayroq o'chiq.
Future<AppServices> _svc(
  WidgetTester tester, {
  AppLanguage language = AppLanguage.uz,
  bool? allFeaturesOpen,
  PurchaseAdapter? purchases,
  EntitlementSource? entitlementSource,
}) => makeServices(
  tester,
  language: language,
  proEnabled: true,
  gatedFeatures: ProGatePolicy.catalog,
  allFeaturesOpen: allFeaturesOpen,
  purchases: purchases,
  entitlementSource: entitlementSource,
);

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
  FakeEntitlementSource? source,
}) async {
  final shop = FakePurchaseAdapter(available: available, proofs: proofs);
  final s = await _svc(
    tester,
    language: language,
    allFeaturesOpen: false,
    purchases: shop,
    // Standart: hisobga kirgan foydalanuvchi (D-76: mehmon xarid qilmaydi).
    entitlementSource: source ?? FakeEntitlementSource(),
  );
  return (s, shop);
}

void main() {
  testWidgets('to‘lov yoqilmagan do‘kon build: hammasi ochiq, Obuna qatori va '
      '“Hali mavjud emas” yo‘q', (tester) async {
    final s = await _svc(tester, allFeaturesOpen: false);
    await pumpApp(tester, s, size: _tall);
    expect(s.entitlements.purchasesEnabled, isFalse);
    for (var i = 0; i < 4; i++) {
      await _quickExam(tester, uz);
    }
    await goTo(tester, '/learn/exam');
    await _scrollTo(tester, find.text(uz.examHistoryClear));
    expect(find.text('0%'), findsNWidgets(4), reason: 'tarix cheklanmagan');
    expect(find.textContaining('eski natija'), findsNothing);

    // D-74: Pro yoqilgan buildda Profil'da faqat “Obuna” (ma'lumot) qatori;
    // eski “Obuna va tiklash” xarid qatori yo'q.
    await goTo(tester, '/profile');
    expect(find.text(uz.proRowTitle), findsNothing);
    expect(find.byKey(const ValueKey('profile-subscription')), findsOneWidget);

    // To'g'ridan-to'g'ri manzil bilan ham — hech qanday xarid elementi yo'q.
    await goTo(tester, '/profile/purchase');
    expect(find.text(uz.proPayAllOpen), findsOneWidget);
    expect(find.textContaining(uz.notAvailableYet), findsNothing);
    expect(find.text(uz.proPaySubscribe), findsNothing);
    expect(find.text(uz.proPayRestore), findsNothing);
    expect(find.textContaining('bosqich'), findsNothing);
  });

  testWidgets('D-78: to‘lov yoqilgach ham imtihon tarixi cheklanmaydi va '
      'yashirilmaydi (obunasiz)', (tester) async {
    final (s, shop) = await _storeBuild(tester, available: false);
    await pumpApp(tester, s, size: _tall);
    for (var i = 0; i < 5; i++) {
      await _quickExam(tester, uz);
    }
    shop.setAvailable(true);
    await tester.pumpAndSettle();
    expect(s.entitlements.gatingActive, isTrue);
    expect(s.entitlements.isPro, isFalse);
    expect(s.exams.history, hasLength(5));
    await goTo(tester, '/learn/exam');
    await _scrollTo(tester, find.text(uz.examHistoryClear));
    expect(find.text('0%'), findsNWidgets(5), reason: 'hammasi ko‘rinadi');
    expect(find.textContaining('eski natija'), findsNothing);
  });

  testWidgets('D-78: obunasiz ham bepul imtihon, mashq va atlas darhol '
      'boshlanadi (to‘lov oynasi yo‘q)', (tester) async {
    final (s, _) = await _storeBuild(tester);
    await pumpApp(tester, s, size: _tall);
    expect(s.entitlements.gatingActive, isTrue);
    expect(s.entitlements.isPro, isFalse);
    await goTo(tester, '/learn/exam');
    await enterField(tester, uz.examCount, '3');
    await enterField(tester, uz.examTime, '10');
    await tapScroll(tester, uz.examStart);
    expect(find.byKey(const ValueKey('pay-locked')), findsNothing);
    expect(s.exams.active, isNotNull, reason: 'bepul imtihon boshlandi');

    final mixed = uz.quizTopicMixed(
      s.content.pack!.quiz.length < 10 ? s.content.pack!.quiz.length : 10,
    );
    await goTo(tester, '/learn/quiz?fresh=1');
    await tapScroll(tester, mixed);
    expect(find.text(uz.quizChooseTopic), findsNothing);
    expect(find.byKey(const ValueKey('pay-locked')), findsNothing);

    await goTo(tester, '/lab/microscopy/quiz');
    final start = find.byIcon(Icons.play_arrow_rounded).hitTestable();
    await tester.ensureVisible(start.first);
    await tester.tap(start.first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('pay-locked')), findsNothing);
    expect(find.text(uz.proPurchaseTitle), findsNothing);
  });

  testWidgets(
    'to‘lov oynasi (3.1.2): do‘kon narxi, davr, sinov, shartlar, tiklash; '
    'hisob bilan xarid (to‘rt reja)',
    (tester) async {
      final server = FakeEntitlementSource();
      final (s, shop) = await _storeBuild(
        tester,
        source: server,
        proofs: const [
          PurchaseProof(
            platform: 'app_store',
            productId: BillingCatalog.specialistMonthly,
            token: '2000000777',
          ),
        ],
      );
      await pumpApp(tester, s, size: _tall);
      await goTo(tester, '/profile');
      expect(
        find.byKey(const ValueKey('profile-subscription')),
        findsOneWidget,
      );
      await goTo(tester, '/profile/purchase');

      // Ro'yxat dangasa quriladi: har element sahifa tartibida surib ko'riladi
      // (Ustoz → Mutaxassis → Premium; Talaba yashirin).
      Future<void> seen(String text) async {
        await _scrollTo(tester, find.text(text));
        expect(find.text(text), findsOneWidget, reason: text);
      }

      expect(find.text(uz.proPayStartTrial), findsNothing);
      await seen(uz.proTierNameTeacher);
      expect(find.text(uz.proFeatExamSimulation), findsWidgets);
      await seen(uz.proPayPricePer(r'$2.49', uz.proPayUnitMonth));
      await seen(uz.proPayPricePer(r'$24.99', uz.proPayUnitYear));
      await seen(uz.proTierNameSpecialist);
      final monthly = uz.proPayPricePer(r'$3.49', uz.proPayUnitMonth);
      await seen(monthly);
      // D-75: do'kon sinov taklifi (avtomatik pullik) ko'rsatilmaydi, hatto
      // do'kon qaytarsa ham — 7 kunlik sinov (D-76) faqat server sinovi.
      expect(
        find.text(uz.proPayTrial(uz.proPayDays(30), monthly)),
        findsNothing,
      );
      await seen(uz.proPayPricePer(r'$34.99', uz.proPayUnitYear));
      // Premium (D-76): hamma imkoniyat, yillik narx bor.
      await seen(uz.proTierNamePremium);
      await seen(uz.proPayPricePer(r'$4.99', uz.proPayUnitMonth));
      await seen(uz.proPayPricePer(r'$49.99', uz.proPayUnitYear));
      expect(find.text(uz.proFeatTeacherTestBuilder), findsWidgets);
      expect(find.text(uz.proFeatQcReport), findsWidgets);
      // D-78: bugungi bepul funksiyalar (Lab, atlas, mashq) va'da qilinmaydi.
      for (final old in [
        uz.proPayFeatLabCount,
        uz.proPayFeatAtlas,
        uz.proPayFeatQuestions,
        uz.proPayFeatHistory,
        uz.proPayFeatToifa,
        uz.proPayFeatGroups,
      ]) {
        expect(find.text(old), findsNothing, reason: old);
      }
      expect(find.textContaining('(test)'), findsNothing);
      // Talaba narxi — faqat tasdiqlangan talabaga (hozir tasdiq yo'q).
      expect(find.textContaining(r'$1.49'), findsNothing);
      expect(find.textContaining(r'$9.99'), findsNothing);
      expect(find.text(uz.proTierNameStudent), findsNothing);
      // Pastki qism.
      for (final t in [
        uz.proPayDisclosure('App Store'),
        uz.proPayRestore,
        uz.proPayManage,
        uz.proPayTerms,
        uz.proPayPrivacy,
      ]) {
        await seen(t);
      }
      expect(find.textContaining(uz.notAvailableYet), findsNothing);
      // Hisobga kirgan: mehmon izohi va "Hisobga kirish" tugmasi yo'q.
      expect(find.byKey(const ValueKey('pay-guest-note')), findsNothing);

      // Mutaxassis oylik — yuqoriga qaytib, o'sha panelning tugmasi bosiladi.
      await tester.scrollUntilVisible(
        find.text(monthly),
        -300,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      final specialistBuy = find.descendant(
        of: find.ancestor(
          of: find.text(monthly),
          matching: find.byType(LgPanel),
        ),
        matching: find.text(uz.proPaySubscribe),
      );
      await tester.ensureVisible(specialistBuy);
      await tester.pumpAndSettle();
      // Server xaridni tasdiqlaydi (soxta javob).
      server.snapshot = EntitlementSnapshot(
        serverTime: DateTime.now().toUtc(),
        items: [
          ServerEntitlement(
            productId: BillingCatalog.specialistMonthly,
            platform: 'app_store',
            status: EntitlementStatus.active,
            startedAt: DateTime.now().toUtc(),
            expiresAt: DateTime.now().toUtc().add(const Duration(days: 30)),
          ),
        ],
      );
      await tester.tap(specialistBuy);
      await tester.pumpAndSettle();
      expect(shop.bought.single.$1, BillingCatalog.specialistMonthly);
      expect(find.text(uz.proPaySuccess), findsOneWidget);
      expect(s.entitlements.proSource, ProSource.server);
      expect(s.entitlements.plan, ProPlan.specialist);
      expect(shop.finished, hasLength(1));
      await _scrollTo(tester, find.text(uz.proPayCurrent));
      expect(find.text(uz.proPayCurrent), findsOneWidget);
    },
  );

  testWidgets('to‘lov oynasi ru: tiklash — topilmadi, sig‘adi', (tester) async {
    final (s, _) = await _storeBuild(tester, language: AppLanguage.ru);
    await pumpApp(tester, s);
    await goTo(tester, '/profile/purchase');
    await _scrollTo(tester, find.text(ru.proTierNameTeacher));
    expect(find.text(ru.proTierNameTeacher), findsOneWidget);
    await tapScroll(tester, ru.proPayRestore);
    expect(find.text(ru.proPayNothingFound), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mehmon (D-76): obuna tugmasi yo‘q, “Hisobga kirish”; tiklash — '
      'avval kirish', (tester) async {
    final (s, shop) = await _storeBuild(
      tester,
      source: FakeEntitlementSource(user: null),
      proofs: const [
        PurchaseProof(
          platform: 'app_store',
          productId: BillingCatalog.specialistMonthly,
          token: '2000000888',
        ),
      ],
    );
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/profile/purchase');
    // Narxlar ko'rinadi (ma'lumot), lekin xarid tugmasi yo'q.
    expect(
      find.text(uz.proPayPricePer(r'$3.49', uz.proPayUnitMonth)),
      findsOneWidget,
    );
    expect(find.text(uz.proPaySubscribe), findsNothing);
    await _scrollTo(tester, find.byKey(const ValueKey('pay-guest-note')));
    expect(find.text(uz.proPayGuestNote), findsOneWidget);
    expect(find.byKey(const ValueKey('pay-sign-in')), findsOneWidget);
    await tapScroll(tester, uz.proPayRestore);
    expect(find.text(uz.proPaySignInRequired), findsOneWidget);
    expect(shop.bought, isEmpty);
    expect(s.entitlements.isPro, isFalse);
    expect(
      await s.entitlements.purchase(BillingCatalog.specialistMonthly),
      BillingOutcome.signInRequired,
    );
    expect(shop.bought, isEmpty);
  });

  testWidgets('TestFlight: hammasi ochiq, Obuna qatori yo‘q', (tester) async {
    final s = await _svc(tester);
    await pumpApp(tester, s, size: _tall);
    expect(s.entitlements.proSource, ProSource.buildOpen);
    for (var i = 0; i < 4; i++) {
      await _quickExam(tester, uz);
    }
    await goTo(tester, '/learn/exam');
    await _scrollTo(tester, find.text(uz.examHistoryClear));
    expect(find.text('0%'), findsNWidgets(4));
    await goTo(tester, '/profile');
    expect(find.text(uz.proRowTitle), findsNothing);
    expect(find.byKey(const ValueKey('profile-subscription')), findsOneWidget);
    await goTo(tester, '/profile/purchase');
    expect(find.text(uz.proPayTestBuildOpen), findsOneWidget);
    expect(find.textContaining(uz.notAvailableYet), findsNothing);
  });

  testWidgets('lokal ma’lumotni o‘chirish Pro keshini ham tozalaydi', (
    tester,
  ) async {
    final AppServices s = await _svc(tester, allFeaturesOpen: false);
    await s.deleteLocalData(const [Locale('uz')]);
    expect(s.entitlements.cached, isNull);
  });
}
