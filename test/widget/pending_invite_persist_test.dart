// Audit 2026-10-24: QR taklifi (`/j?c=..`) onboarding/kirishdan oldin
// ochilsa, OS ilovani yopib qo'ysa ham (email ilovasiga o'tilganda) taklif
// yo'qolmaydi; 24 soatdan keyin eskiradi; ishlatilgach o'chadi.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/learn/classes_screens.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';

const _tall = Size(390, 1800);

void main() {
  setUpAll(loadAppFonts);

  Future<MemoryKeyValueStore> openInviteThenKill(WidgetTester tester) async {
    final store = MemoryKeyValueStore();
    final s = await makeServices(
      tester,
      store: store,
      backend: FakeLabBackend(),
      onboarded: false,
      role: null,
    );
    await pumpApp(tester, s, size: _tall);
    routerOf(tester).go('/j?c=ABCD2345&a=a1');
    await tester.pumpAndSettle();
    expect(find.byType(JoinGroupScreen), findsNothing);
    expect(store.getString(StoreKeys.pendingInvite), isNotNull);
    // OS ilovani yopdi: daraxt ham, xotiradagi holat ham yo'q.
    await tester.pumpWidget(const SizedBox());
    return store;
  }

  testWidgets('ilova qayta ochilib onboarding tugasa — qo‘shilish ekrani', (
    tester,
  ) async {
    final store = await openInviteThenKill(tester);
    final s = await makeServices(
      tester,
      store: store,
      backend: FakeLabBackend(),
      onboarded: false,
      role: null,
    );
    await pumpApp(tester, s, size: _tall);
    await s.settings.completeOnboarding();
    await tester.pumpAndSettle();
    expect(find.byType(JoinGroupScreen), findsOneWidget);
    final uri = routerOf(tester).routeInformationProvider.value.uri;
    expect(uri.path, '/learn/classes/join');
    expect(uri.queryParameters, {'code': 'ABCD2345', 'a': 'a1'});
    // Ishlatildi — o'chirildi.
    expect(store.getString(StoreKeys.pendingInvite), isNull);
  });

  testWidgets('24 soatdan keyin — taklif ochilmaydi, bosh sahifa', (
    tester,
  ) async {
    final store = await openInviteThenKill(tester);
    final later = DateTime.now().add(const Duration(hours: 25));
    final s = await makeServices(
      tester,
      store: store,
      backend: FakeLabBackend(),
      onboarded: false,
      role: null,
      clock: () => later,
    );
    await pumpApp(tester, s, size: _tall);
    await s.settings.completeOnboarding();
    await tester.pumpAndSettle();
    expect(find.byType(JoinGroupScreen), findsNothing);
    expect(routerOf(tester).state.matchedLocation, '/home');
  });
}
