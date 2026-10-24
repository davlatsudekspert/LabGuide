// Audit 2026-10-24 (kirish): kirish/onboardingdan oldin ochilgan QR taklifi
// faqat xotirada edi — email ilovasiga o'tganda OS ilovani yopsa yo'qolardi.
// Endi omborda (24 soat) saqlanadi, ishlatilgach yoki chiqishda o'chadi.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

const _join = '/learn/classes/join?code=ABCD2345&a=a1';

void main() {
  late MemoryKeyValueStore store;
  late DateTime now;

  SettingsController controller() => SettingsController(
    store,
    systemLocales: const [Locale('uz')],
    clock: () => now,
  );

  setUp(() {
    store = MemoryKeyValueStore();
    now = DateTime(2026, 10, 24, 9);
  });

  test('kalit StoreKeys.all da (PrefsKeyValueStore allowList)', () {
    expect(StoreKeys.all, contains(StoreKeys.pendingInvite));
  });

  test('jarayon o‘lsa ham saqlanadi: yangi controller o‘qiydi', () async {
    await controller().setPendingInvite(_join);
    // Ilova qayta ishga tushdi — yangi obyekt, o'sha ombor.
    expect(controller().pendingInvite, _join);
  });

  test('takePendingInvite bir marta beradi va o‘chiradi', () async {
    final s = controller();
    await s.setPendingInvite(_join);
    expect(s.takePendingInvite(), _join);
    await pumpEventQueue();
    expect(s.takePendingInvite(), isNull);
    expect(store.getString(StoreKeys.pendingInvite), isNull);
  });

  test('24 soatdan keyin eskiradi va o‘chiriladi', () async {
    await controller().setPendingInvite(_join);
    now = now.add(const Duration(hours: 23, minutes: 59));
    expect(controller().pendingInvite, _join);
    now = now.add(const Duration(minutes: 1));
    expect(controller().pendingInvite, isNull);
    await pumpEventQueue();
    expect(store.getString(StoreKeys.pendingInvite), isNull);
  });

  test('chiqish (resetOnboarding) taklifni o‘chiradi', () async {
    final s = controller();
    await s.completeOnboarding();
    await s.setPendingInvite(_join);
    await s.resetOnboarding();
    expect(s.pendingInvite, isNull);
    expect(store.getString(StoreKeys.pendingInvite), isNull);
  });

  test('faqat qo‘shilish yo‘li; buzilgan yozuv — null', () async {
    final s = controller();
    await s.setPendingInvite('/profile/admin');
    expect(store.getString(StoreKeys.pendingInvite), isNull);
    await store.setString(StoreKeys.pendingInvite, '{"loc":"/home","at":1}');
    expect(s.pendingInvite, isNull);
    await store.setString(StoreKeys.pendingInvite, 'not json');
    expect(s.pendingInvite, isNull);
    await pumpEventQueue();
    expect(store.getString(StoreKeys.pendingInvite), isNull);
  });
}
