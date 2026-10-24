// “Obuna” ekrani (D-74): faqat Pro bayrog'i yoqilgan buildda Profil'dan.
// Bayroq o'chiq — qator ham, yo'l ham yo'q (Profil `main` bilan bir xil).
// Rejalar va narxlar katalog MA'LUMOTIDAN, ochadigan narsa matritsadan
// (hech narsa yopilmagan — “hozircha hamma imkoniyat bepul”), holat, sinov
// qoidasi (bir telefonga bir marta), xaridni tiklash; 320px va 1.3 matn
// o'lchami uch tilda.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/features/profile/subscription_screen.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/billing_fakes.dart';
import '../helpers/harness.dart';

AppLocalizations _l(AppLanguage lang) => lookupAppLocalizations(lang.locale);

Map<String, Object?> _item(String source, String plan, {int days = 30}) {
  final now = DateTime.now().toUtc();
  return {
    'product_id': source == 'trial' ? 'trial.$plan' : 'admin_grant.$plan',
    'platform': source,
    'source': source,
    'plan': plan,
    'status': 'active',
    'started_at': now.toIso8601String(),
    'expires_at': now.add(Duration(days: days, minutes: 1)).toIso8601String(),
    'ownership': source == 'trial' ? 'trial' : 'granted',
    'environment': 'production',
  };
}

Future<AppServices> _svc(
  WidgetTester tester, {
  bool? proEnabled = true,
  AppLanguage language = AppLanguage.uz,
  FakeEntitlementSource? source,
}) => makeServices(
  tester,
  language: language,
  proEnabled: proEnabled,
  allFeaturesOpen: false,
  purchases: FakePurchaseAdapter(),
  entitlementSource: source ?? FakeEntitlementSource(user: null),
);

void main() {
  testWidgets('bayroq o‘chiq (standart): Profil’da “Obuna” yo‘q, yo‘l yo‘q', (
    tester,
  ) async {
    final s = await _svc(tester, proEnabled: null);
    await pumpApp(tester, s, size: const Size(390, 2400));
    final uz = _l(AppLanguage.uz);
    await goTo(tester, '/profile');
    expect(find.byKey(const ValueKey('profile-subscription')), findsNothing);
    expect(find.text(uz.proSubRowSub), findsNothing);
    await goTo(tester, '/profile/subscription');
    expect(find.byType(SubscriptionScreen), findsNothing);
    tester.takeException();
  });

  testWidgets('bayroq yoqilgan: Profil → Obuna; rejalar, narxlar, bepul '
      'holat, sinov qoidasi, tiklash', (tester) async {
    final s = await _svc(tester);
    await s.entitlements.start();
    await pumpApp(tester, s, size: const Size(390, 2600));
    final uz = _l(AppLanguage.uz);
    await goTo(tester, '/profile');
    final row = find.byKey(const ValueKey('profile-subscription'));
    await tester.scrollUntilVisible(
      row,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.byType(SubscriptionScreen), findsOneWidget);

    expect(find.text(uz.proSubAllFree), findsOneWidget);
    expect(find.text(uz.proSubStatusFree), findsOneWidget);
    for (final spec in ProPricing.plans) {
      final panel = find.byKey(ValueKey('sub-plan-${spec.plan.name}'));
      expect(panel, findsOneWidget);
      final m = uz.proPayPricePer(
        '\$${spec.monthlyUsd.toStringAsFixed(2)}',
        uz.proPayUnitMonth,
      );
      final y = uz.proPayPricePer(
        '\$${spec.yearlyUsd!.toStringAsFixed(2)}',
        uz.proPayUnitYear,
      );
      expect(
        find.descendant(
          of: panel,
          matching: find.text('${uz.proPayPlanMonthly}: $m'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: panel,
          matching: find.text('${uz.proPayPlanYearly}: $y'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: panel, matching: find.text(uz.proSubNothingGated)),
        findsOneWidget,
      );
    }
    // Narxlar katalogdan: 1.49 / 9.99, 2.49 / 24.99, 3.49 / 34.99.
    expect(find.textContaining(r'$1.49'), findsOneWidget);
    expect(find.textContaining(r'$34.99'), findsOneWidget);
    // Talaba — faqat talaba tomoni; Ustoz paneli emas (matritsa).
    final student = find.byKey(const ValueKey('sub-plan-student'));
    expect(
      find.descendant(
        of: student,
        matching: find.text(uz.proSubUnlocks(uz.proSubCapLearner)),
      ),
      findsOneWidget,
    );
    expect(find.text(uz.proSubTrialOncePerPhone), findsOneWidget);
    expect(find.text(uz.proSubTrialGuest), findsOneWidget);
    expect(find.text(uz.proPayRestore), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('holat: sinov (qolgan kunlar) va admin bergan', (tester) async {
    final src = FakeEntitlementSource()
      ..snapshot = EntitlementSnapshot.fromJson({
        'server_time': DateTime.now().toUtc().toIso8601String(),
        'items': [_item('trial', 'teacher', days: 12)],
        'trial_used': true,
      });
    final s = await _svc(tester, source: src);
    await s.entitlements.start();
    await pumpApp(tester, s, size: const Size(390, 2400));
    final uz = _l(AppLanguage.uz);
    await goTo(tester, '/profile/subscription');
    expect(
      find.text(uz.proSubStatusTrial(uz.proPayTierTeacher, uz.proPayDays(12))),
      findsOneWidget,
    );

    src.snapshot = EntitlementSnapshot.fromJson({
      'server_time': DateTime.now().toUtc().toIso8601String(),
      'items': [_item('admin_grant', 'specialist')],
    });
    await s.entitlements.refresh(reprobe: false);
    await tester.pumpAndSettle();
    final status = tester.widget<Text>(
      find.byKey(const ValueKey('sub-status')),
    );
    expect(status.data, startsWith('${uz.proPayTierSpecialist} — '));
    expect(find.text(uz.proSubTrialGuest), findsNothing);
    expect(find.text(uz.proSubTrialUsed), findsOneWidget);
  });

  testWidgets('Maxfiylik: Pro sinov izohi faqat bayroq yoqilganda', (
    tester,
  ) async {
    final off = await _svc(tester, proEnabled: null);
    await pumpApp(tester, off, size: const Size(390, 2400));
    await goTo(tester, '/profile/privacy');
    expect(find.byKey(const ValueKey('privacy-pro-trial')), findsNothing);

    final on = await _svc(tester);
    await pumpApp(tester, on, size: const Size(390, 2400));
    await goTo(tester, '/profile/privacy');
    expect(find.text(_l(AppLanguage.uz).proPrivacyTrialNote), findsOneWidget);
  });

  for (final lang in AppLanguage.values) {
    testWidgets('320px, matn 1.3 — ${lang.name}: toshish yo‘q', (tester) async {
      final s = await _svc(tester, language: lang);
      await s.entitlements.start();
      await pumpApp(tester, s, size: const Size(320, 640), textScale: 1.3);
      await goTo(tester, '/profile/subscription');
      final l = _l(lang);
      expect(find.text(l.proSubTitle), findsWidgets);
      final list = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('sub-restore')),
        200,
        scrollable: list,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
