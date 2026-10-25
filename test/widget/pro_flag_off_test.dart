// D-71: Pro qatlami `BuildFlags.proEnabled` ortida. Bayroq o'chiq (standart)
// bo'lsa ilova `main` (bepul reliz) bilan bir xil: to'lov oynasi yo'q, do'kon
// plagini ishga tushmaydi, serverga billing so'rovi ketmaydi, hech narsa
// yopilmaydi.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/build_flags.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/features/profile/purchase_screen.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/billing_fakes.dart';
import '../helpers/harness.dart';

final uz = lookupAppLocalizations(const Locale('uz'));

void main() {
  testWidgets(
    'proEnabled=false (standart): obuna qatori, to‘lov yo‘li, do‘kon va '
    'server yo‘q; hamma imkoniyat ochiq',
    (tester) async {
      final shop = FakePurchaseAdapter();
      final server = FakeEntitlementSource();
      // Hatto "to'lov tayyor" soxta do'kon/server berilsa ham, bayroq
      // o'chiq bo'lsa ular e'tiborsiz qoladi.
      final s = await makeServices(
        tester,
        purchases: shop,
        entitlementSource: server,
        allFeaturesOpen: false,
      );
      expect(BuildFlags.proEnabled, isFalse);
      await pumpApp(tester, s);

      final ent = s.entitlements;
      expect(ent.purchasesEnabled, isFalse);
      expect(ent.gatingActive, isFalse);
      for (final f in Feature.values) {
        expect(ent.can(f), isTrue, reason: f.name);
      }
      // Do'kon ishga tushmagan, serverga so'rov ketmagan.
      expect(shop.inits, 0);
      expect(server.probes, 0);

      await goTo(tester, '/profile');
      expect(find.text(uz.proRowTitle), findsNothing);
      expect(find.text(uz.proSubRowSub), findsNothing);
      expect(find.byKey(const ValueKey('profile-subscription')), findsNothing);
      expect(find.byIcon(Icons.workspace_premium_outlined), findsNothing);

      // To'lov oynasi yo'li ro'yxatda yo'q.
      await goTo(tester, '/profile/purchase');
      expect(find.byType(PurchaseScreen), findsNothing);
      expect(find.text(uz.proPaySubscribe), findsNothing);
      expect(find.text(uz.proPayRestore), findsNothing);
      tester.takeException(); // noma'lum yo'l xato sahifasi
    },
  );

  testWidgets(
    'proEnabled=true, lekin yopiladigan imkoniyat ro‘yxati bo‘sh (standart): '
    'to‘lov ishlasa ham hech narsa yopilmaydi',
    (tester) async {
      final shop = FakePurchaseAdapter();
      final s = await makeServices(
        tester,
        proEnabled: true,
        purchases: shop,
        entitlementSource: FakeEntitlementSource(user: null),
        allFeaturesOpen: false,
      );
      await s.entitlements.start();
      await pumpApp(tester, s, size: const Size(390, 2400));
      final ent = s.entitlements;
      expect(ent.purchasesEnabled, isTrue);
      expect(ent.gatingActive, isTrue);
      expect(ent.gated, isEmpty);
      for (final f in Feature.values) {
        expect(ent.can(f), isTrue, reason: f.name);
      }
      expect(shop.inits, 1);
      await goTo(tester, '/profile');
      // D-74: “Obuna” qatori (rejalar, holat, tiklash) — bayroq yoqilgan buildda.
      expect(
        find.byKey(const ValueKey('profile-subscription')),
        findsOneWidget,
      );
    },
  );
}
