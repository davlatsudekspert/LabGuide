import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Google va Apple bilan kirish (D-56) — email-kod kirishi yoniga ikkinchi usul.
///
/// Ilova faqat provayderdan ID token oladi va serverga yuboradi; imzo, `aud`,
/// `iss`, `exp`, `email_verified` va nonce tekshiruvi **serverda**
/// (`cloudflare/src/social.ts`). Ilova hech qanday token yoki parolni
/// saqlamaydi (sessiya tokeni — mavjud xavfsiz omborda).
enum SocialProvider { apple, google }

/// Build vaqtidagi sozlama (repoda yo'q, `--dart-define`):
///
///   LG_GOOGLE_CLIENT_ID      — Google "Web application" OAuth client ID
///                              (serverClientId; Worker'dagi GOOGLE_CLIENT_IDS
///                              ro'yxatida ham bo'lishi shart). Bo'sh — Google
///                              tugmasi yo'q.
///   LG_GOOGLE_IOS_CLIENT_ID  — Google "iOS" OAuth client ID (faqat iOS).
///   LG_APPLE_SIGNIN          — true: iOS/macOS build'da `Sign in with Apple`
///                              entitlement bor (CI faqat shunda true qiladi).
///   LG_APPLE_SERVICE_ID      — Android uchun Apple Services ID (ixtiyoriy).
@immutable
class SocialAuthConfig {
  const SocialAuthConfig({
    this.googleClientId = '',
    this.googleIosClientId = '',
    this.appleSignIn = false,
    this.appleServiceId = '',
  });

  static const fromEnvironment = SocialAuthConfig(
    googleClientId: String.fromEnvironment('LG_GOOGLE_CLIENT_ID'),
    googleIosClientId: String.fromEnvironment('LG_GOOGLE_IOS_CLIENT_ID'),
    appleSignIn: bool.fromEnvironment('LG_APPLE_SIGNIN'),
    appleServiceId: String.fromEnvironment('LG_APPLE_SERVICE_ID'),
  );

  final String googleClientId;
  final String googleIosClientId;
  final bool appleSignIn;
  final String appleServiceId;
}

/// Provayder bergan, serverga yuboriladigan natija.
@immutable
class SocialCredential {
  const SocialCredential({
    required this.provider,
    required this.idToken,
    required this.rawNonce,
    this.authorizationCode,
  });

  final SocialProvider provider;
  final String idToken;

  /// Xom nonce: provayderga sha256(hex) berilgan, serverga xomligicha ketadi.
  final String rawNonce;

  /// Faqat Apple: hisobni o'chirishda tokenni bekor qilish uchun.
  final String? authorizationCode;
}

class SocialAuthException implements Exception {
  const SocialAuthException(this.message);
  final String message;
  @override
  String toString() => 'SocialAuthException($message)';
}

/// Bitta provayder (plagin ustida yupqa qatlam). Testlarda soxtasi bilan
/// almashtiriladi.
abstract interface class SocialIdentityProvider {
  SocialProvider get provider;

  /// Bu platformada va shu build sozlamasi bilan ishlay oladimi. Tarmoqqa
  /// chiqmaydi; server holati alohida ([SocialLoginBackend.socialStatus]).
  bool get isSupported;

  /// Tizim oynasini ochadi. Foydalanuvchi bekor qilsa — `null` (jim). Haqiqiy
  /// xatoda [SocialAuthException].
  Future<SocialCredential?> authenticate();
}

/// Server tomoni (`/v1/auth/providers`, `/v1/auth/google|apple`).
@immutable
class SocialServerStatus {
  const SocialServerStatus({
    this.google = false,
    this.apple = false,
    this.appleWeb = false,
  });

  final bool google;
  final bool apple;

  /// Apple veb-oqimi (Android) uchun Services ID sozlanganmi.
  final bool appleWeb;
}

enum SocialSignInStatus {
  success,

  /// Foydalanuvchi tizim oynasini yopdi — xato emas, jim.
  cancelled,
  emailNotVerified,
  emailRequired,
  rateLimited,

  /// Provayder yoki server hozir mavjud emas / sozlanmagan.
  unavailable,
  failed,

  /// Admin hisobni to'xtatgan — kirish rad etildi.
  accountSuspended,
}

@immutable
class SocialSignInResult {
  const SocialSignInResult(this.status, {this.email, this.retryAfter});

  final SocialSignInStatus status;

  /// Ekranda ko'rsatiladigan email (tokendagi yoki niqoblangan).
  final String? email;
  final Duration? retryAfter;
}

abstract interface class SocialLoginBackend {
  /// Server qaysi provayderlarni yoqqan; javob bo'lmasa — `null`.
  Future<SocialServerStatus?> socialStatus();

  Future<SocialSignInResult> socialSignIn(SocialCredential credential);

  /// Hisobga bog'langan provayderlar (`GET /v1/me` → identities).
  Future<Set<SocialProvider>> linkedProviders();

  /// Hisobni o'chiradi; [appleAuthorizationCode] bo'lsa server Apple
  /// tokenini bekor qiladi (App Store 5.1.1(v)).
  Future<void> deleteAccountWithApple(String? appleAuthorizationCode);
}

/// Qaysi tugmalar ko'rinadi — **yagona qoida** (App Store 4.8). Har bir
/// kirish ekrani shu ro'yxatni ishlatadi ([SocialAuthService.available] va
/// [SocialSignInButtons] ham shu funksiyadan o'tadi).
///
/// iOS'da Google tugmasi faqat maxfiylikni saqlovchi "Sign in with Apple"
/// ham ko'rinsa chiqadi: `googleVisible = googleAvailable &&
/// (platform != iOS || appleVisible)`. Apple bo'lmasa iOS'da Google ham
/// yashiriladi — email-kod kirishi qoladi (u 4.8 dagi "emailni yashirish"
/// shartiga javob bermaydi, shuning uchun Apple o'rnini bosmaydi).
/// Android o'zgarmaydi: Google mustaqil, Apple — faqat sozlangan bo'lsa.
/// Tartib: Apple birinchi.
List<SocialProvider> visibleSocialProviders({
  required TargetPlatform platform,
  required bool appleAvailable,
  required bool googleAvailable,
}) {
  final appleVisible = appleAvailable;
  final googleVisible =
      googleAvailable && (platform != TargetPlatform.iOS || appleVisible);
  if (googleAvailable && !googleVisible) {
    debugPrint(
      'social: iOS — Sign in with Apple yo\'q, shuning uchun Google tugmasi '
      'ham yashirildi (App Store 4.8). LG_APPLE_SIGNIN va entitlement\'ni '
      'tekshiring.',
    );
  }
  return [
    if (appleVisible) SocialProvider.apple,
    if (googleVisible) SocialProvider.google,
  ];
}

/// Ilovadagi yagona kirish nuqtasi: qaysi tugmalar ko'rinadi va kirish.
class SocialAuthService {
  SocialAuthService({
    this.providers = const [],
    this.backend,
    this.statusTimeout = const Duration(seconds: 6),
  });

  /// Ilova sozlamasidan (`--dart-define`) va joriy serverdan.
  factory SocialAuthService.fromEnvironment({
    required Object? backend,
    Uri? appleAndroidRedirect,
  }) {
    const config = SocialAuthConfig.fromEnvironment;
    return SocialAuthService(
      providers: [
        AppleIdentityProvider(config, androidRedirect: appleAndroidRedirect),
        GoogleIdentityProvider(config),
      ],
      backend: backend is SocialLoginBackend ? backend : null,
    );
  }

  /// Hech qanday provayder yo'q (sozlanmagan build, testlar).
  SocialAuthService.none() : this();

  /// Tugmalar tartibi: Apple birinchi (HIG: kamida Google kabi ko'zga tashlanadi).
  final List<SocialIdentityProvider> providers;
  final SocialLoginBackend? backend;
  final Duration statusTimeout;

  List<SocialProvider>? _available;

  SocialIdentityProvider? provider(SocialProvider p) {
    for (final x in providers) {
      if (x.provider == p) return x;
    }
    return null;
  }

  /// Ko'rsatiladigan tugmalar: platforma + build sozlamasi + server yoqqan.
  /// Server javob bermasa — hech narsa ko'rsatilmaydi (o'lik tugma yo'q);
  /// keyingi ochilishda qayta uriniladi.
  Future<List<SocialProvider>> available() async {
    final cached = _available;
    if (cached != null) return cached;
    final b = backend;
    final local = providers.where((p) => p.isSupported).toList();
    if (b == null || local.isEmpty) return const [];
    SocialServerStatus? status;
    try {
      status = await b.socialStatus().timeout(statusTimeout);
    } on Object catch (e) {
      debugPrint('social status: ${e.runtimeType}');
    }
    if (status == null) return const [];
    final android = defaultTargetPlatform == TargetPlatform.android;
    final out = visibleSocialProviders(
      platform: defaultTargetPlatform,
      appleAvailable:
          local.any((p) => p.provider == SocialProvider.apple) &&
          status.apple &&
          (!android || status.appleWeb),
      googleAvailable:
          local.any((p) => p.provider == SocialProvider.google) &&
          status.google,
    );
    return _available = out;
  }

  Future<SocialSignInResult> signIn(SocialProvider which) async {
    final b = backend;
    final p = provider(which);
    if (b == null || p == null || !p.isSupported) {
      return const SocialSignInResult(SocialSignInStatus.unavailable);
    }
    final SocialCredential? credential;
    try {
      credential = await p.authenticate();
    } on Object catch (e) {
      debugPrint('social authenticate: ${e.runtimeType}');
      return const SocialSignInResult(SocialSignInStatus.failed);
    }
    if (credential == null) {
      return const SocialSignInResult(SocialSignInStatus.cancelled);
    }
    try {
      return await b.socialSignIn(credential);
    } on Object catch (e) {
      debugPrint('social sign in: ${e.runtimeType}');
      return const SocialSignInResult(SocialSignInStatus.failed);
    }
  }
}

// ---------------------------------------------------------------- nonce
/// Xavfsiz tasodifiy xom nonce (base64url, 43 belgi).
String generateRawNonce([Random? random]) {
  final r = random ?? Random.secure();
  final bytes = List<int>.generate(32, (_) => r.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}

/// Provayderga beriladigan qiymat: sha256(xom nonce), hex. Server tokendagi
/// `nonce` ni xuddi shu bilan solishtiradi.
String hashNonce(String raw) => sha256.convert(utf8.encode(raw)).toString();

// ---------------------------------------------------------------- Apple
class AppleIdentityProvider implements SocialIdentityProvider {
  AppleIdentityProvider(this.config, {this.androidRedirect});

  final SocialAuthConfig config;

  /// Android veb-oqimi: Worker'dagi `/v1/auth/apple/callback`.
  final Uri? androidRedirect;

  @override
  SocialProvider get provider => SocialProvider.apple;

  /// iOS/macOS: entitlement bor build (`LG_APPLE_SIGNIN`). Android: faqat
  /// Services ID va qaytish manzili sozlangan bo'lsa. Boshqa platformalar — yo'q.
  @override
  bool get isSupported {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return config.appleSignIn;
      case TargetPlatform.android:
        return config.appleServiceId.isNotEmpty && androidRedirect != null;
      default:
        return false;
    }
  }

  @override
  Future<SocialCredential?> authenticate() async {
    final raw = generateRawNonce();
    try {
      final c = await SignInWithApple.getAppleIDCredential(
        // Faqat email: ism kerak emas va so'ralmaydi (ma'lumotni minimallashtirish).
        scopes: const [AppleIDAuthorizationScopes.email],
        nonce: hashNonce(raw),
        webAuthenticationOptions:
            defaultTargetPlatform == TargetPlatform.android
            ? WebAuthenticationOptions(
                clientId: config.appleServiceId,
                redirectUri: androidRedirect!,
              )
            : null,
      );
      final token = c.identityToken;
      if (token == null || token.isEmpty) {
        throw const SocialAuthException('no identity token');
      }
      return SocialCredential(
        provider: SocialProvider.apple,
        idToken: token,
        rawNonce: raw,
        authorizationCode: c.authorizationCode,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      throw SocialAuthException('apple: ${e.code.name}');
    } on SignInWithAppleException catch (e) {
      throw SocialAuthException('apple: ${e.runtimeType}');
    }
  }
}

// --------------------------------------------------------------- Google
class GoogleIdentityProvider implements SocialIdentityProvider {
  GoogleIdentityProvider(this.config);

  final SocialAuthConfig config;

  Future<void>? _init;
  String? _rawNonce;

  @override
  SocialProvider get provider => SocialProvider.google;

  /// Android: `LG_GOOGLE_CLIENT_ID` yetarli. iOS: yana iOS client ID kerak.
  /// Sozlamasiz hech qachon tugma ko'rsatilmaydi.
  @override
  bool get isSupported {
    if (kIsWeb || config.googleClientId.isEmpty) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return true;
      case TargetPlatform.iOS:
        return config.googleIosClientId.isNotEmpty;
      default:
        return false;
    }
  }

  /// Plagin `initialize` ni bir marta chaqirishni talab qiladi, nonce esa
  /// shunda beriladi — shuning uchun nonce jarayon uchun bitta; qayta
  /// ishlatishga qarshi server har tokenni alohida (sub+iat+nonce) belgilaydi.
  Future<void> _ensureInit() {
    final started = _init;
    if (started != null) return started;
    final raw = _rawNonce = generateRawNonce();
    final init = GoogleSignIn.instance
        .initialize(
          clientId: defaultTargetPlatform == TargetPlatform.iOS
              ? config.googleIosClientId
              : null,
          serverClientId: config.googleClientId,
          nonce: hashNonce(raw),
        )
        .catchError((Object e) {
          // Muvaffaqiyatsiz boshlanish keyingi urinishni to'smasin.
          _init = null;
          throw e;
        });
    return _init = init;
  }

  @override
  Future<SocialCredential?> authenticate() async {
    try {
      await _ensureInit();
      final google = GoogleSignIn.instance;
      if (!google.supportsAuthenticate()) {
        throw const SocialAuthException('google: authenticate unsupported');
      }
      final account = await google.authenticate();
      final token = account.authentication.idToken;
      // Hisob qurilmada "kirib" qolmasin: keyingi safar yana tanlash oynasi.
      unawaited(google.signOut().catchError((Object _) {}));
      if (token == null || token.isEmpty) {
        throw const SocialAuthException('google: no id token');
      }
      return SocialCredential(
        provider: SocialProvider.google,
        idToken: token,
        rawNonce: _rawNonce!,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw SocialAuthException('google: ${e.code.name}');
    }
  }
}
