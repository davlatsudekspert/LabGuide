import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labguide/core/backend/cloudflare_backend.dart';
import 'package:labguide/core/backend/supabase_backend.dart'
    show MemorySessionStore;
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/auth/auth_controller.dart';
import 'package:labguide/features/auth/otp_auth.dart';
import 'package:labguide/features/auth/social_auth.dart';
import 'package:labguide/features/auth/ui/social_buttons.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/social_fakes.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('nonce', () {
    test('hashNonce — sha256 hex (server shuni solishtiradi)', () {
      expect(
        hashNonce('abc'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('xom nonce: 43 belgi, URL-xavfsiz, har safar boshqa', () {
      final a = generateRawNonce();
      final b = generateRawNonce();
      expect(a, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
      expect(a, isNot(b));
    });
  });

  group('tugma ko‘rinishi: platforma va build sozlamasi', () {
    test('Google: client ID yo‘q — hech qachon; Android yetarli; iOS yana iOS ID', () {
      const none = SocialAuthConfig();
      const web = SocialAuthConfig(googleClientId: 'web.apps.googleusercontent.com');
      const both = SocialAuthConfig(
        googleClientId: 'web.apps.googleusercontent.com',
        googleIosClientId: 'ios.apps.googleusercontent.com',
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(GoogleIdentityProvider(none).isSupported, isFalse);
      expect(GoogleIdentityProvider(web).isSupported, isTrue);
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(GoogleIdentityProvider(none).isSupported, isFalse);
      expect(GoogleIdentityProvider(web).isSupported, isFalse);
      expect(GoogleIdentityProvider(both).isSupported, isTrue);
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(GoogleIdentityProvider(both).isSupported, isFalse);
    });

    test('Apple: iOS/macOS — entitlement bayrog‘i bilan; Android — Services ID bilan', () {
      final redirect = Uri.parse('https://api.example.test/v1/auth/apple/callback');
      const off = SocialAuthConfig();
      const on = SocialAuthConfig(appleSignIn: true);
      const service = SocialAuthConfig(appleServiceId: 'uz.labguide.app.service');
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(AppleIdentityProvider(off).isSupported, isFalse);
      expect(AppleIdentityProvider(on).isSupported, isTrue);
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(AppleIdentityProvider(on).isSupported, isTrue);
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(AppleIdentityProvider(on).isSupported, isFalse);
      expect(AppleIdentityProvider(service).isSupported, isFalse);
      expect(
        AppleIdentityProvider(service, androidRedirect: redirect).isSupported,
        isTrue,
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(AppleIdentityProvider(on).isSupported, isFalse);
    });

    test('build sozlamasi berilmagan test: hech narsa ko‘rinmaydi', () async {
      final service = SocialAuthService.fromEnvironment(backend: FakeSocialBackend());
      expect(await service.available(), isEmpty);
    });
  });

  group('SocialAuthService.available', () {
    test('server yoqqan va qurilma qo‘llaydigan tugmalar; Apple birinchi', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final backend = FakeSocialBackend();
      final s = SocialAuthService(
        providers: [
          FakeSocialProvider(SocialProvider.apple),
          FakeSocialProvider(SocialProvider.google),
        ],
        backend: backend,
      );
      expect(await s.available(), [SocialProvider.apple, SocialProvider.google]);
      // Muvaffaqiyatli javob keshlanadi.
      await s.available();
      expect(backend.statusCalls, 1);
    });

    test('server o‘chirgan yoki platforma qo‘llamaydigan tugma yashiriladi', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final backend = FakeSocialBackend(
        status: const SocialServerStatus(google: true),
      );
      final s = SocialAuthService(
        providers: [
          FakeSocialProvider(SocialProvider.apple),
          FakeSocialProvider(SocialProvider.google),
        ],
        backend: backend,
      );
      expect(await s.available(), [SocialProvider.google]);

      final s2 = SocialAuthService(
        providers: [
          FakeSocialProvider(SocialProvider.apple, supported: false),
          FakeSocialProvider(SocialProvider.google, supported: false),
        ],
        backend: backend,
      );
      final before = backend.statusCalls;
      expect(await s2.available(), isEmpty);
      // Qo‘llanmaydigan qurilmada serverga murojaat ham yo‘q.
      expect(backend.statusCalls, before);
    });

    test('server javob bermasa — tugma yo‘q, keyin qayta uriniladi', () async {
      final backend = FakeSocialBackend()..status = null;
      final s = SocialAuthService(
        providers: [FakeSocialProvider(SocialProvider.google)],
        backend: backend,
      );
      expect(await s.available(), isEmpty);
      backend.status = const SocialServerStatus(google: true);
      expect(await s.available(), [SocialProvider.google]);
    });

    test('serverga ulanmagan build (backend yo‘q) — tugma yo‘q', () async {
      final s = SocialAuthService(
        providers: [FakeSocialProvider(SocialProvider.google)],
      );
      expect(await s.available(), isEmpty);
    });

    test('Android’da Apple faqat server veb-oqimni yoqqan bo‘lsa', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final backend = FakeSocialBackend(
        status: const SocialServerStatus(apple: true),
      );
      final apple = FakeSocialProvider(SocialProvider.apple);
      final s = SocialAuthService(providers: [apple], backend: backend);
      expect(await s.available(), isEmpty);
      final web = SocialAuthService(
        providers: [apple],
        backend: FakeSocialBackend(
          status: const SocialServerStatus(apple: true, appleWeb: true),
        ),
      );
      expect(await web.available(), [SocialProvider.apple]);
    });
  });

  group('kirish', () {
    test('muvaffaqiyat: server chaqiriladi, sessiya saqlanadi', () async {
      final store = MemoryKeyValueStore();
      final backend = FakeSocialBackend();
      final google = FakeSocialProvider(SocialProvider.google);
      final auth = AuthController(
        store,
        const UnconfiguredOtpAdapter(),
        social: SocialAuthService(providers: [google], backend: backend),
      );
      final r = await auth.signInWithSocial(SocialProvider.google);
      expect(r.status, SocialSignInStatus.success);
      expect(auth.hasAccount, isTrue);
      expect(auth.session, isA<EmailSession>());
      expect((auth.session! as EmailSession).email, 'ab***@example.com');
      expect(backend.signIns.single.idToken, 'id-token-google-1');
      expect(store.getString(StoreKeys.session), 'email:ab***@example.com');
    });

    test('bekor qilish jim: xato ham, sessiya ham, server chaqiruvi ham yo‘q', () async {
      final backend = FakeSocialBackend();
      final apple = FakeSocialProvider(SocialProvider.apple, cancel: true);
      final auth = AuthController(
        MemoryKeyValueStore(),
        const UnconfiguredOtpAdapter(),
        social: SocialAuthService(providers: [apple], backend: backend),
      );
      final r = await auth.signInWithSocial(SocialProvider.apple);
      expect(r.status, SocialSignInStatus.cancelled);
      expect(auth.hasAccount, isFalse);
      expect(backend.signIns, isEmpty);
    });

    test('plagin xatosi — failed, hisob ochilmaydi', () async {
      final backend = FakeSocialBackend();
      final apple = FakeSocialProvider(
        SocialProvider.apple,
        error: const SocialAuthException('apple: failed'),
      );
      final auth = AuthController(
        MemoryKeyValueStore(),
        const UnconfiguredOtpAdapter(),
        social: SocialAuthService(providers: [apple], backend: backend),
      );
      expect(
        (await auth.signInWithSocial(SocialProvider.apple)).status,
        SocialSignInStatus.failed,
      );
      expect(auth.hasAccount, isFalse);
    });

    test('server rad etsa — hisob ochilmaydi (email tasdiqlanmagan)', () async {
      final backend = FakeSocialBackend()
        ..result = const SocialSignInResult(SocialSignInStatus.emailNotVerified);
      final auth = AuthController(
        MemoryKeyValueStore(),
        const UnconfiguredOtpAdapter(),
        social: SocialAuthService(
          providers: [FakeSocialProvider(SocialProvider.google)],
          backend: backend,
        ),
      );
      final r = await auth.signInWithSocial(SocialProvider.google);
      expect(r.status, SocialSignInStatus.emailNotVerified);
      expect(auth.hasAccount, isFalse);
    });

    test('qo‘llanmaydigan provayder — unavailable (o‘lik tugma bosilsa ham)', () async {
      final auth = AuthController(
        MemoryKeyValueStore(),
        const UnconfiguredOtpAdapter(),
        social: SocialAuthService(
          providers: [FakeSocialProvider(SocialProvider.google, supported: false)],
          backend: FakeSocialBackend(),
        ),
      );
      expect(
        (await auth.signInWithSocial(SocialProvider.google)).status,
        SocialSignInStatus.unavailable,
      );
    });
  });

  group('CloudflareLabBackend: Google / Apple', () {
    const config = ApiConfig(url: 'https://api.example.test');
    late List<http.Request> requests;
    late Map<String, (int, Object?)> responses;
    late MemorySessionStore store;
    late CloudflareLabBackend backend;

    setUp(() {
      requests = [];
      responses = {};
      store = MemorySessionStore();
      backend = CloudflareLabBackend(
        config,
        sessionStore: store,
        clock: () => DateTime.utc(2026, 10, 10),
        httpClient: MockClient((r) async {
          requests.add(r);
          final hit = responses['${r.method} ${r.url.path}'];
          if (hit == null) return http.Response('{"error":"not_found"}', 404);
          return http.Response(
            hit.$2 == null ? '' : jsonEncode(hit.$2),
            hit.$1,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
    });

    SocialCredential credential(SocialProvider p) => SocialCredential(
      provider: p,
      idToken: 'idt',
      rawNonce: 'raw-nonce-0123456789',
    );

    test('providers holati o‘qiladi; xato/offlayn — null', () async {
      responses['GET /v1/auth/providers'] = (
        200,
        {'google': true, 'apple': false, 'apple_web': false},
      );
      final s = await backend.socialStatus();
      expect(s!.google, isTrue);
      expect(s.apple, isFalse);
      responses['GET /v1/auth/providers'] = (503, {'error': 'not_configured'});
      expect(await backend.socialStatus(), isNull);
    });

    test('Google kirishi: id_token + xom nonce yuboriladi, sessiya saqlanadi', () async {
      responses['POST /v1/auth/google'] = (
        200,
        {
          'token': 'tok-g',
          'user_id': 'u-g',
          'expires_at': '2026-12-01T00:00:00.000Z',
          'email': 'lab@example.com',
          'email_masked': 'la***@example.com',
        },
      );
      final r = await backend.socialSignIn(credential(SocialProvider.google));
      expect(r.status, SocialSignInStatus.success);
      expect(r.email, 'lab@example.com');
      expect(backend.hasSession, isTrue);
      expect(backend.userId, 'u-g');
      final body = jsonDecode(requests.single.body) as Map;
      expect(body, {'id_token': 'idt', 'nonce': 'raw-nonce-0123456789'});
      expect(requests.single.headers.containsKey('authorization'), isFalse);
      expect(await store.read(), contains('tok-g'));
    });

    test('tokenda email bo‘lmasa niqoblangani ko‘rsatiladi, sessiya emaili bo‘sh', () async {
      responses['POST /v1/auth/apple'] = (
        200,
        {
          'token': 'tok-a',
          'user_id': 'u-a',
          'expires_at': '2026-12-01T00:00:00.000Z',
          'email': null,
          'email_masked': 'ab***@privaterelay.appleid.com',
        },
      );
      final r = await backend.socialSignIn(credential(SocialProvider.apple));
      expect(r.status, SocialSignInStatus.success);
      expect(r.email, 'ab***@privaterelay.appleid.com');
      expect(backend.sessionEmail, isNull);
    });

    test('xato kodlari holatga aylanadi va sessiya ochilmaydi', () async {
      Future<SocialSignInStatus> fail(int status, Object body) async {
        responses['POST /v1/auth/google'] = (status, body);
        final r = await backend.socialSignIn(credential(SocialProvider.google));
        expect(backend.hasSession, isFalse);
        return r.status;
      }

      expect(
        await fail(403, {'error': 'email_not_verified'}),
        SocialSignInStatus.emailNotVerified,
      );
      expect(
        await fail(400, {'error': 'email_required'}),
        SocialSignInStatus.emailRequired,
      );
      expect(
        await fail(503, {'error': 'not_configured'}),
        SocialSignInStatus.unavailable,
      );
      expect(
        await fail(429, {'error': 'rate_limited', 'retry_after': 42}),
        SocialSignInStatus.rateLimited,
      );
      expect(await fail(401, {'error': 'invalid_token'}), SocialSignInStatus.failed);
      expect(await fail(401, {'error': 'replayed_token'}), SocialSignInStatus.failed);
      expect(await fail(500, {'error': 'internal'}), SocialSignInStatus.failed);
    });

    test('linkedProviders va Apple bilan hisobni o‘chirish (kod serverga ketadi)', () async {
      responses['POST /v1/auth/apple'] = (
        200,
        {
          'token': 'tok-a',
          'user_id': 'u-a',
          'expires_at': '2026-12-01T00:00:00.000Z',
          'email_masked': 'ab***@example.com',
        },
      );
      await backend.socialSignIn(credential(SocialProvider.apple));
      responses['GET /v1/me'] = (200, {'identities': ['apple', 'google', 'x']});
      expect(
        await backend.linkedProviders(),
        {SocialProvider.apple, SocialProvider.google},
      );
      responses['DELETE /v1/me'] = (204, null);
      await backend.deleteAccountWithApple('auth-code-1');
      final del = requests.last;
      expect(del.method, 'DELETE');
      expect(jsonDecode(del.body), {'apple_authorization_code': 'auth-code-1'});
      expect(backend.hasSession, isFalse);
    });

    test('kodsiz o‘chirish — tanasiz DELETE', () async {
      responses['POST /v1/auth/google'] = (
        200,
        {
          'token': 'tok-g',
          'user_id': 'u-g',
          'expires_at': '2026-12-01T00:00:00.000Z',
          'email_masked': 'ab***@example.com',
        },
      );
      await backend.socialSignIn(credential(SocialProvider.google));
      responses['DELETE /v1/me'] = (204, null);
      await backend.deleteAccountWithApple(null);
      expect(requests.last.body, isEmpty);
    });
  });

  group('Google G belgisi', () {
    test('SVG yo‘l o‘qigich: M/c/C/l/H/h/V/s/z va yopiq kontur', () {
      final p = parseSvgPath('M0 0h10v10H0z');
      expect(p.getBounds(), const Rect.fromLTRB(0, 0, 10, 10));
      final c = parseSvgPath('M0 0c1 0 2 1 2 2s1 2 2 2l-1-1z');
      expect(c.getBounds().width, greaterThan(0));
      expect(() => parseSvgPath('M0 0A1 1 0 0 1 2 2'), throwsFormatException);
    });
  });
}
