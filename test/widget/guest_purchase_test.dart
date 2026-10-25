import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/core/entitlements/guest_entitlements.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/core/entitlements/purchase_adapter.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/billing_fakes.dart';
import '../helpers/guest_fakes.dart';
import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

/// To'lov oynasi: mehmon (hisobsiz) xarid va tiklash — Apple 5.1.1(v)
/// (D-77 addendum). Do'kon va server soxta.
final uz = lookupAppLocalizations(const Locale('uz'));
const _tall = Size(390, 2600);

const _proof = PurchaseProof(
  platform: 'app_store',
  productId: BillingCatalog.specialistMonthly,
  token: '2000000999',
);

EntitlementSnapshot _guestSnap({bool signIn = false}) => EntitlementSnapshot(
  serverTime: DateTime.now().toUtc(),
  items: signIn
      ? const []
      : [
          ServerEntitlement(
            productId: BillingCatalog.specialistMonthly,
            platform: 'app_store',
            status: EntitlementStatus.active,
            source: ServerEntitlement.guestStoreSource,
            startedAt: DateTime.now().toUtc(),
            expiresAt: DateTime.now().toUtc().add(const Duration(days: 30)),
          ),
        ],
  guestTokens: signIn ? const [] : const ['g1.p.s'],
  signInRequired: signIn,
  offlineUntil: DateTime.now().toUtc().add(const Duration(days: 7)),
);

Future<void> _scrollTo(WidgetTester tester, Finder f) =>
    tester.scrollUntilVisible(
      f,
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  Future<(FakeGuestSource, FakePurchaseAdapter, dynamic)> build(
    WidgetTester tester, {
    GuestPolicy? policy = const GuestPolicy(
      purchasePlans: {ProPlan.student, ProPlan.specialist},
    ),
  }) async {
    final shop = FakePurchaseAdapter(proofs: const [_proof]);
    final src = FakeGuestSource(user: null, policy: policy)
      ..guestReply = _guestSnap();
    final s = await makeServices(
      tester,
      proEnabled: true,
      allFeaturesOpen: false,
      gatedFeatures: {...Feature.values},
      purchases: shop,
      entitlementSource: src,
    );
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/profile/purchase');
    return (src, shop, s);
  }

  testWidgets('mehmon: Mutaxassis — xarid tugmasi bor; Ustoz / Premium — '
      '“hisobga kiring”; xarid → server (mehmon) → tasdiq', (tester) async {
    final (src, shop, _) = await build(tester);
    await _scrollTo(tester, find.byKey(const ValueKey('pay-guest-buy-note')));
    expect(find.text(uz.proPayGuestBuyNote), findsOneWidget);
    expect(find.text(uz.proPayGuestNote), findsNothing);
    final buy = find.byKey(
      const ValueKey('pay-buy-${BillingCatalog.specialistMonthly}'),
    );
    await _scrollTo(tester, buy);
    expect(buy, findsOneWidget);
    // Ustoz rejasi (ustoz paneli — faqat hisob bilan): xarid tugmasi yo'q, izoh bor.
    final teacherNote = find.byKey(
      const ValueKey('pay-account-only-${BillingCatalog.teacherMonthly}'),
    );
    // Ustoz kartasi Mutaxassisdan yuqorida — tepaga aylantiriladi.
    await tester.scrollUntilVisible(
      teacherNote,
      -300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(teacherNote, findsOneWidget);
    expect(
      find.byKey(const ValueKey('pay-buy-${BillingCatalog.teacherMonthly}')),
      findsNothing,
    );
    await _scrollTo(tester, buy);
    await tester.tap(buy);
    await tester.pumpAndSettle();
    expect(find.text(uz.proPaySuccess), findsOneWidget);
    expect(shop.bought.single, (BillingCatalog.specialistMonthly, null));
    expect(src.guestVerifies, hasLength(1));
    expect(src.verified, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mehmon: “Xaridlarni tiklash” — tiklandi; bog‘langan xarid — '
      'hisobga kirish', (tester) async {
    final (src, _, _) = await build(tester);
    await tapScroll(tester, uz.proPayRestore);
    expect(find.text(uz.proPayRestored), findsOneWidget);
    expect(src.guestVerifies.single.$3, isTrue);
    src.guestReply = _guestSnap(signIn: true);
    await tester.pump(const Duration(seconds: 5));
    await tapScroll(tester, uz.proPayRestore);
    expect(find.text(uz.proPaySignInRequired), findsWidgets);
  });

  testWidgets('server mehmon siyosatini bermasa — eski izoh (D-76)', (
    tester,
  ) async {
    await build(tester, policy: null);
    await _scrollTo(tester, find.byKey(const ValueKey('pay-guest-note')));
    expect(find.text(uz.proPayGuestNote), findsOneWidget);
    expect(find.text(uz.proPaySubscribe), findsNothing);
  });
}
