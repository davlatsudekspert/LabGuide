import 'package:labguide/features/auth/social_auth.dart';

/// Soxta Google/Apple provayderi: tizim oynasi o'rniga berilgan natija.
class FakeSocialProvider implements SocialIdentityProvider {
  FakeSocialProvider(
    this.provider, {
    this.supported = true,
    this.cancel = false,
    this.error,
    this.code = 'apple-auth-code',
  });

  @override
  final SocialProvider provider;
  bool supported;

  /// true: foydalanuvchi oynani yopadi (`null`).
  bool cancel;

  /// Berilsa — plagin xatosi.
  Object? error;
  String? code;
  int calls = 0;

  @override
  bool get isSupported => supported;

  @override
  Future<SocialCredential?> authenticate() async {
    calls++;
    if (error != null) throw error!;
    if (cancel) return null;
    return SocialCredential(
      provider: provider,
      idToken: 'id-token-${provider.name}-$calls',
      rawNonce: generateRawNonce(),
      authorizationCode: provider == SocialProvider.apple ? code : null,
    );
  }
}

/// Soxta server: `/v1/auth/providers`, kirish va o'chirish.
class FakeSocialBackend implements SocialLoginBackend {
  FakeSocialBackend({
    this.status = const SocialServerStatus(
      google: true,
      apple: true,
      appleWeb: true,
    ),
    this.linked = const {},
  });

  /// `null` — server javob bermaydi.
  SocialServerStatus? status;
  Set<SocialProvider> linked;
  SocialSignInResult result = const SocialSignInResult(
    SocialSignInStatus.success,
    email: 'ab***@example.com',
  );
  final signIns = <SocialCredential>[];
  final deletions = <String?>[];
  int statusCalls = 0;

  @override
  Future<SocialServerStatus?> socialStatus() async {
    statusCalls++;
    return status;
  }

  @override
  Future<SocialSignInResult> socialSignIn(SocialCredential credential) async {
    signIns.add(credential);
    return result;
  }

  @override
  Future<Set<SocialProvider>> linkedProviders() async => linked;

  @override
  Future<void> deleteAccountWithApple(String? appleAuthorizationCode) async {
    deletions.add(appleAuthorizationCode);
  }
}
