// “Obuna” ekrani (D-74): faqat Pro bayrog'i yoqilgan buildda Profil'dan.
// Bayroq o'chiq — qator ham, yo'l ham yo'q (Profil `main` bilan bir xil).
// Rejalar va narxlar katalog MA'LUMOTIDAN, ochadigan narsa matritsadan
// (hech narsa yopilmagan — “hozircha hamma imkoniyat bepul”), holat, sinov
// qoidasi (bir telefonga bir marta), xaridni tiklash; 320px va 1.3 matn
// o'lchami uch tilda.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/entitlement_service.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/features/profile/subscription_screen.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/billing_fakes.dart';
import '../helpers/fake_backend.dart';
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
  FakePurchaseAdapter? purchases,
  bool attest = false,
}) => makeServices(
  tester,
  language: language,
  proEnabled: proEnabled,
  allFeaturesOpen: false,
  backend: FakeLabBackend(),
  purchases: purchases ?? FakePurchaseAdapter(),
  entitlementSource: source ?? FakeEntitlementSource(user: null),
  attestor: attest ? FakeDeviceAttestor() : null,
);

Future<void> _signIn(WidgetTester tester, AppServices s) async {
  await s.auth.requestCode('trial.user@example.test');
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('bayroq o‘chiq (standart): Profil’da “Obuna” yo‘q, yo‘l yo‘q', (
    tester,
  ) async {
    final s = await _svc(tester, proEnabled: null);
    await pumpApp(tester, s, size: const Size(390, 4800));
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
    await pumpApp(tester, s, size: const Size(390, 5000));
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

    // D-78: qurilgan pullik funksiyalar bor — "hammasi bepul" izohi yo'q.
    expect(find.text(uz.proSubAllFree), findsNothing);
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
      // D-78: har reja learner funksiyalarini ochadi; Mutaxassis Pro faqat
      // Mutaxassis va Premium'da.
      expect(
        find.descendant(of: panel, matching: find.text(uz.proSubNothingGated)),
        findsNothing,
      );
      expect(
        find.descendant(
          of: panel,
          matching: find.text('• ${uz.proFeatResultsAnalytics}'),
        ),
        findsOneWidget,
      );
      final lab = spec.plan == ProPlan.specialist || spec.plan == ProPlan.premium;
      expect(
        find.descendant(of: panel, matching: find.text('• ${uz.proFeatQcReport}')),
        lab ? findsOneWidget : findsNothing,
        reason: spec.plan.name,
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
    // D-76 matritsasi: Mutaxassis — Talaba + Lab (ustoz panelisiz);
    // Premium — hammasi; Ustoz — Talaba + ustoz paneli (Lab'siz).
    String unlocks(List<String> caps) => uz.proSubUnlocks(caps.join(', '));
    for (final (plan, caps) in [
      ('teacher', [uz.proSubCapLearner, uz.proSubCapTeacherPanel]),
      ('specialist', [uz.proSubCapLearner, uz.proCapLabPro]),
      (
        'premium',
        [uz.proSubCapLearner, uz.proSubCapTeacherPanel, uz.proCapLabPro],
      ),
    ]) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey('sub-plan-$plan')),
          matching: find.text(unlocks(caps)),
        ),
        findsOneWidget,
        reason: plan,
      );
    }
    expect(find.textContaining(r'$4.99'), findsOneWidget);
    expect(find.textContaining(r'$49.99'), findsOneWidget);
    expect(find.text(uz.proSubTrialTitle(7)), findsOneWidget);
    // Server bu platformada sinov taklif qilmaydi (standart): qoida va sinov
    // matni ko'rsatilmaydi, faqat oddiy izoh (mehmon).
    expect(find.text(uz.proSubTrialOncePerPhone), findsNothing);
    expect(find.text(uz.proSubTrialGuest), findsOneWidget);
    expect(find.text(uz.proPayRestore), findsOneWidget);
    // Do'kon qoidalari (D-75): boshqarish/bekor qilish, shartlar, maxfiylik.
    for (final k in ['sub-manage', 'sub-terms', 'sub-privacy', 'sub-without']) {
      expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
    }
    // Boshqa to'lov usuli / web narx yo'q.
    expect(find.textContaining('http'), findsNothing);
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
    await pumpApp(tester, s, size: const Size(390, 4800));
    final uz = _l(AppLanguage.uz);
    await goTo(tester, '/profile/subscription');
    expect(
      find.text(uz.proSubStatusTrial(uz.proTierNameTeacher, uz.proPayDays(12))),
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
    expect(status.data, startsWith('${uz.proTierNameSpecialist} — '));
    expect(find.text(uz.proSubTrialGuest), findsNothing);
    expect(find.text(uz.proSubTrialUsed), findsOneWidget);
  });

  testWidgets('Maxfiylik: Pro sinov izohi faqat bayroq yoqilganda', (
    tester,
  ) async {
    final off = await _svc(tester, proEnabled: null);
    await pumpApp(tester, off, size: const Size(390, 4800));
    await goTo(tester, '/profile/privacy');
    expect(find.byKey(const ValueKey('privacy-pro-trial')), findsNothing);

    final on = await _svc(tester);
    await pumpApp(tester, on, size: const Size(390, 4800));
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

  group('D-75: sinov tugmasi faqat imkoniyat so‘rovi + attestatsiya bilan', () {
    testWidgets('server sinovni taklif qilmaydi (iOS standart): tugma yo‘q, '
        'oddiy izoh', (tester) async {
      final src = FakeEntitlementSource(trialOffered: false);
      final s = await _svc(tester, source: src, attest: true);
      await s.entitlements.start();
      await pumpApp(tester, s, size: const Size(390, 5000));
      await _signIn(tester, s);
      await goTo(tester, '/profile/subscription');
      final uz = _l(AppLanguage.uz);
      expect(find.text(uz.proSubTrialNotOnPlatform), findsOneWidget);
      expect(find.byKey(const ValueKey('sub-trial-body')), findsNothing);
      for (final p in ProPlan.values) {
        expect(find.byKey(ValueKey('sub-trial-start-${p.name}')), findsNothing);
      }
    });

    testWidgets('attestatsiya sozlanmagan (production standart): tugma yo‘q', (
      tester,
    ) async {
      final src = FakeEntitlementSource(trialOffered: true);
      final s = await _svc(tester, source: src);
      await s.entitlements.start();
      await pumpApp(tester, s, size: const Size(390, 5000));
      await goTo(tester, '/profile/subscription');
      final uz = _l(AppLanguage.uz);
      expect(find.text(uz.proSubTrialNotActive), findsOneWidget);
      expect(
        find.byKey(const ValueKey('sub-trial-start-student')),
        findsNothing,
      );
    });

    testWidgets('Android + soxta attestatsiya: matn, tasdiq oynasi, sinov '
        'boshlanadi; hech qanday xarid boshlanmaydi', (tester) async {
      final src = FakeEntitlementSource(
        trialOffered: true,
        platform: 'play_store',
      );
      final shop = FakePurchaseAdapter();
      final s = await _svc(tester, source: src, purchases: shop, attest: true);
      await s.entitlements.start();
      await pumpApp(tester, s, size: const Size(390, 5200));
      await _signIn(tester, s);
      await goTo(tester, '/profile/subscription');
      final uz = _l(AppLanguage.uz);
      expect(
        find.text(uz.proSubTrialBody(ProTrialConfig.serverTrialDays)),
        findsOneWidget,
      );
      expect(find.text(uz.proSubTrialOncePerPhone), findsOneWidget);
      expect(ProTrialConfig.serverTrialDays, 7);
      // To'rt reja uchun ham sinov tugmasi (D-76: Premium qo'shildi).
      for (final p in ProPlan.values) {
        expect(
          find.byKey(ValueKey('sub-trial-start-${p.name}')),
          findsOneWidget,
          reason: p.name,
        );
      }
      final start = find.byKey(const ValueKey('sub-trial-start-student'));
      await tester.ensureVisible(start);
      await tester.pumpAndSettle();
      await tester.tap(start);
      await tester.pumpAndSettle();
      // Tasdiq: tugash sanasi, to'lov usuli yo'q, pul yechilmaydi.
      final body = tester.widget<Text>(
        find.byKey(const ValueKey('sub-trial-confirm-body')),
      );
<<<<<<< HEAD
      expect(body.data, startsWith('${uz.proPayTierStudent}: '));
=======
      expect(body.data, startsWith('${uz.proTierNameStudent} '));
>>>>>>> paid/feat
      expect(body.data, contains('pul yechilmaydi'));
      await tester.tap(find.byKey(const ValueKey('sub-trial-confirm')));
      await tester.pumpAndSettle();
      expect(src.trialStarts, [ProPlan.student]);
      expect(s.entitlements.proSource, ProSource.trial);
      // Sinov kodi do'kon xaridini boshlamaydi, tranzaksiya yakunlamaydi.
      expect(shop.bought, isEmpty);
      expect(shop.finished, isEmpty);
      expect(
        find.byKey(const ValueKey('sub-trial-start-student')),
        findsNothing,
      );
    });
  });

  testWidgets('Pro tugadi: “Pro tugadi, bepul imkoniyatlar ishlaydi”; '
      'faqat qurilgan pullik funksiyalar yopiq (D-78)', (tester) async {
    final past = DateTime.now().toUtc().subtract(const Duration(days: 1));
    final src = FakeEntitlementSource()
      ..snapshot = EntitlementSnapshot.fromJson({
        'server_time': DateTime.now().toUtc().toIso8601String(),
        'items': [
          {
            ..._item('trial', 'student'),
            'status': 'expired',
            'expires_at': past.toIso8601String(),
          },
        ],
        'trial_used': true,
      });
    final s = await _svc(tester, source: src);
    await s.entitlements.start();
    await pumpApp(tester, s, size: const Size(390, 4800));
    await goTo(tester, '/profile/subscription');
    final uz = _l(AppLanguage.uz);
    expect(find.text(uz.proSubStatusFree), findsOneWidget);
    expect(find.byKey(const ValueKey('sub-ended')), findsOneWidget);
    // D-78: muddati o'tgach faqat qurilgan (gated) pullik funksiyalar yopiq;
    // qolgan hamma narsa (bugungi bepul funksiyalar katalogda ham yo'q) ochiq.
    for (final f in Feature.values) {
      expect(
        s.entitlements.can(f),
        !ProGatePolicy.gated.contains(f),
        reason: f.name,
      );
    }
  });
}
