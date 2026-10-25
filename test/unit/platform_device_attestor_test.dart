import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/entitlements/platform_device_attestor.dart';

/// Haqiqiy attestator (D-77 addendum) — platforma kanali soxta (native kod
/// testda yo'q). Native Kotlin/Swift bu yerda ishga tushmaydi (NOT RUN).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(PlatformDeviceAttestor.channelName);
  final calls = <MethodCall>[];

  void mock(Future<Object?> Function(MethodCall c) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (c) {
          calls.add(c);
          return handler(c);
        });
  }

  setUp(calls.clear);
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  test('integrityNonce: server (attestation.ts) bilan bir xil test vektori', () {
    expect(
      PlatformDeviceAttestor.integrityNonce('n' * 43, 'abcdef0123456789'),
      '61MO6Z5mYqT12cPPFzBUdWbBo8x-1wBxyZZ0L6HKnkI',
    );
  });

  test('Android: prepare → available; attest — bog‘langan nonce, device_id', () async {
    mock((c) async => switch (c.method) {
      'isSupported' => true,
      'deviceId' => 'abcdef0123456789',
      'attest' => 'integrity.token.value',
      _ => null,
    });
    final a = PlatformDeviceAttestor(platform: 'android', channel: channel);
    expect(a.available, isFalse, reason: 'prepare dan oldin — yo‘q');
    await a.prepare();
    expect(a.available, isTrue);
    final r = await a.attest('n' * 43);
    expect(r.platform, 'android');
    expect(r.token, 'integrity.token.value');
    expect(r.deviceId, 'abcdef0123456789');
    final attest = calls.lastWhere((c) => c.method == 'attest');
    expect((attest.arguments as Map)['nonce'], '61MO6Z5mYqT12cPPFzBUdWbBo8x-1wBxyZZ0L6HKnkI');
    expect(r.toJson('n' * 43), {
      'platform': 'android',
      'token': 'integrity.token.value',
      'nonce': 'n' * 43,
      'device_id': 'abcdef0123456789',
    });
  });

  test('iOS: DeviceCheck — nonce yuborilmaydi (token nonce’ni bog‘lamaydi)', () async {
    mock((c) async => switch (c.method) {
      'isSupported' => true,
      'deviceId' => '3f2c9a8e-1d4b-4c6a-9e2f-0a1b2c3d4e5f',
      'attest' => 'ZGV2aWNlY2hlY2stdG9rZW4=',
      _ => null,
    });
    final a = PlatformDeviceAttestor(platform: 'ios', channel: channel);
    await a.prepare();
    final r = await a.attest('m' * 43);
    expect(r.platform, 'ios');
    expect((calls.last.arguments as Map).containsKey('nonce'), isFalse);
  });

  test('qo‘llamaydi / plagin yo‘q / noto‘g‘ri device_id — available false, attest xato', () async {
    mock((c) async => c.method == 'isSupported' ? false : null);
    final a = PlatformDeviceAttestor(platform: 'android', channel: channel);
    await a.prepare();
    expect(a.available, isFalse);
    await expectLater(a.attest('n' * 43), throwsStateError);

    // Kanal umuman yo'q (MissingPluginException).
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    final b = PlatformDeviceAttestor(platform: 'android', channel: channel);
    await b.prepare();
    expect(b.available, isFalse);

    mock((c) async => switch (c.method) {
      'isSupported' => true,
      'deviceId' => 'bad id with spaces',
      _ => null,
    });
    final d = PlatformDeviceAttestor(platform: 'android', channel: channel);
    await d.prepare();
    expect(d.available, isFalse);
  });

  test('native xato (PlatformException) — attest xato tashlaydi, token bo‘sh bo‘lsa ham', () async {
    mock((c) async {
      if (c.method == 'attest') {
        throw PlatformException(code: 'integrity_failed');
      }
      return c.method == 'isSupported' ? true : 'abcdef0123456789';
    });
    final a = PlatformDeviceAttestor(platform: 'android', channel: channel);
    await a.prepare();
    await expectLater(a.attest('n' * 43), throwsA(isA<PlatformException>()));
    mock((c) async => switch (c.method) {
      'isSupported' => true,
      'deviceId' => 'abcdef0123456789',
      'attest' => '',
      _ => null,
    });
    final b = PlatformDeviceAttestor(platform: 'android', channel: channel);
    await b.prepare();
    await expectLater(b.attest('n' * 43), throwsStateError);
  });
}
