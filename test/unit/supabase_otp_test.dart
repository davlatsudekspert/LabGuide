import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labguide/core/backend/lab_backend.dart';
import 'package:labguide/core/backend/supabase_backend.dart';
import 'package:labguide/features/auth/otp_auth.dart';

/// Supabase Auth'ning HTTP javoblarini taqlid qiluvchi server: haqiqiy
/// adapter (so'rov, xato kodlari, sessiya saqlash) tarmoqsiz sinanadi.
class _FakeAuthServer {
  final requests = <http.Request>[];
  String goodCode = '123456';
  int otpStatus = 200;
  bool networkDown = false;

  static String _b64(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');

  static String jwt(String email) {
    final exp = DateTime.now().add(const Duration(hours: 1));
    return '${_b64({'alg': 'HS256', 'typ': 'JWT'})}.'
        '${_b64({'sub': 'user-1', 'email': email, 'aal': 'aal1', 'role': 'authenticated', 'exp': exp.millisecondsSinceEpoch ~/ 1000})}'
        '.c2ln';
  }

  static Map<String, Object?> session(String email) => {
    'access_token': jwt(email),
    'token_type': 'bearer',
    'expires_in': 3600,
    'expires_at':
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
        1000,
    'refresh_token': 'refresh-1',
    'user': {
      'id': 'user-1',
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': email,
      'app_metadata': <String, Object?>{},
      'user_metadata': <String, Object?>{},
      'created_at': '2026-10-09T00:00:00Z',
    },
  };

  int count(String path) => requests.where((r) => r.url.path == path).length;

  late final client = MockClient((request) async {
    requests.add(request);
    if (networkDown) throw http.ClientException('offline');
    http.Response json(int status, Object body) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );
    switch (request.url.path) {
      case '/auth/v1/otp':
        if (otpStatus == 429) {
          return json(429, {
            'code': 429,
            'error_code': 'over_email_send_rate_limit',
            'msg': 'For security purposes, you can only request this after 37 seconds.',
          });
        }
        return json(200, <String, Object?>{});
      case '/auth/v1/verify':
        final body = jsonDecode(request.body) as Map<String, Object?>;
        if (body['token'] != goodCode) {
          return json(403, {
            'code': 403,
            'error_code': 'otp_expired',
            'msg': 'Token has expired or is invalid',
          });
        }
        return json(200, session(body['email']! as String));
      case '/auth/v1/logout':
        return http.Response('', 204);
    }
    return json(404, {'msg': 'not found'});
  });
}

void main() {
  const config = BackendConfig(
    url: 'https://example.supabase.co',
    publishableKey: 'sb_publishable_test',
  );
  late _FakeAuthServer server;
  late MemorySessionStore store;
  late DateTime now;
  late SupabaseLabBackend backend;

  setUp(() {
    server = _FakeAuthServer();
    store = MemorySessionStore();
    now = DateTime(2026, 10, 9, 12);
    backend = SupabaseLabBackend(
      config,
      sessionStore: store,
      httpClient: server.client,
      clock: () => now,
    );
  });

  test('kod so‘rovi: email normallashadi, foydalanuvchi yaratiladi', () async {
    final r = await backend.requestCode('  Lab.User@Example.COM ');
    expect(r.status, OtpRequestStatus.sent);
    expect(r.validFor, const Duration(minutes: 10));
    expect(r.retryAfter, const Duration(seconds: 60));
    final body =
        jsonDecode(server.requests.single.body) as Map<String, Object?>;
    expect(body['email'], 'lab.user@example.com');
    expect(body['create_user'], isTrue);
    // Kalit faqat publishable — service role ilovada yo'q.
    expect(server.requests.single.headers['apikey'], 'sb_publishable_test');
  });

  test('noto‘g‘ri email serverga yuborilmaydi', () async {
    final r = await backend.requestCode('not-an-email');
    expect(r.status, OtpRequestStatus.invalidEmail);
    expect(server.requests, isEmpty);
  });

  test('qayta yuborish: 60 s ichida tarmoqqa chiqmaydi', () async {
    await backend.requestCode('a@example.com');
    now = now.add(const Duration(seconds: 20));
    final r = await backend.requestCode('a@example.com');
    expect(r.status, OtpRequestStatus.rateLimited);
    expect(r.retryAfter, const Duration(seconds: 40));
    expect(server.count('/auth/v1/otp'), 1);
    now = now.add(const Duration(seconds: 41));
    expect(
      (await backend.requestCode('a@example.com')).status,
      OtpRequestStatus.sent,
    );
    expect(server.count('/auth/v1/otp'), 2);
  });

  test('server 429 → kutish vaqti xabardan olinadi', () async {
    server.otpStatus = 429;
    final r = await backend.requestCode('a@example.com');
    expect(r.status, OtpRequestStatus.rateLimited);
    expect(r.retryAfter, const Duration(seconds: 37));
  });

  test(
    'internet yo‘q → “yuborilmadi”, kod yaratilgan deb hisoblanmaydi',
    () async {
      server.networkDown = true;
      expect(
        (await backend.requestCode('a@example.com')).status,
        OtpRequestStatus.failed,
      );
      expect(
        (await backend.verifyCode('a@example.com', '123456')).status,
        OtpVerifyStatus.noActiveCode,
      );
    },
  );

  test('urinishlar chegarasi: 5 ta noto‘g‘ri koddan keyin to‘xtaydi', () async {
    await backend.requestCode('a@example.com');
    for (var left = 4; left >= 1; left--) {
      final r = await backend.verifyCode('a@example.com', '000000');
      expect(r.status, OtpVerifyStatus.invalidCode);
      expect(r.attemptsLeft, left);
    }
    expect(
      (await backend.verifyCode('a@example.com', '000000')).status,
      OtpVerifyStatus.tooManyAttempts,
    );
    // Endi to'g'ri kod ham serverga yuborilmaydi — yangi kod kerak.
    expect(
      (await backend.verifyCode('a@example.com', '123456')).status,
      OtpVerifyStatus.tooManyAttempts,
    );
    expect(server.count('/auth/v1/verify'), 5);
    expect(backend.hasSession, isFalse);
  });

  test('muddat: 10 daqiqadan keyin kod eskirgan', () async {
    await backend.requestCode('a@example.com');
    now = now.add(const Duration(minutes: 10));
    expect(
      (await backend.verifyCode('a@example.com', '123456')).status,
      OtpVerifyStatus.expired,
    );
    expect(server.count('/auth/v1/verify'), 0);
  });

  test('tarmoq xatosi urinish sifatida sanalmaydi', () async {
    await backend.requestCode('a@example.com');
    server.networkDown = true;
    for (var i = 0; i < 6; i++) {
      expect(
        (await backend.verifyCode('a@example.com', '123456')).status,
        OtpVerifyStatus.failed,
      );
    }
    server.networkDown = false;
    expect(
      (await backend.verifyCode('a@example.com', '123456')).status,
      OtpVerifyStatus.verified,
    );
  });

  test('to‘g‘ri kod → sessiya saqlanadi; chiqishda o‘chadi', () async {
    await backend.requestCode('a@example.com');
    final r = await backend.verifyCode('a@example.com', '123456');
    expect(r.status, OtpVerifyStatus.verified);
    expect(backend.hasSession, isTrue);
    expect(backend.sessionEmail, 'a@example.com');
    await pumpEventQueue();
    expect(store.value, isNotNull);
    expect(store.value, contains('refresh-1'));

    // Ilova qayta ochilganda sessiya Keychain'dan tiklanadi.
    final reopened = SupabaseLabBackend(
      config,
      sessionStore: store,
      httpClient: server.client,
      clock: () => now,
    );
    await reopened.restoreSession();
    expect(reopened.hasSession, isTrue);
    expect(reopened.sessionEmail, 'a@example.com');

    await backend.signOut();
    expect(backend.hasSession, isFalse);
    expect(store.value, isNull);
    expect(server.count('/auth/v1/logout'), 1);
  });

  test('chiqish internetsiz ham qurilmadagi sessiyani o‘chiradi', () async {
    await backend.requestCode('a@example.com');
    await backend.verifyCode('a@example.com', '123456');
    await pumpEventQueue();
    server.networkDown = true;
    await backend.signOut();
    expect(backend.hasSession, isFalse);
    expect(store.value, isNull);
  });

  test('buzilgan saqlangan sessiya o‘chiriladi', () async {
    store.value = '{"broken": true}';
    await backend.restoreSession();
    expect(backend.hasSession, isFalse);
    expect(store.value, isNull);
  });
}
