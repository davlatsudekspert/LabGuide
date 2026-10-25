import 'package:flutter/foundation.dart';

/// Qurilma attestatsiyasi natijasi (D-74): serverga yuboriladi va u yerda
/// `DeviceAttestationVerifier` tekshiradi. Ilova hech qanday qurilma id sini
/// o'zi saqlamaydi.
@immutable
class DeviceAttestation {
  const DeviceAttestation({
    required this.platform,
    required this.token,
    this.keyId,
    this.deviceId,
  });

  /// `ios` yoki `android`.
  final String platform;

  /// iOS — App Attest assertion yoki DeviceCheck tokeni; Android — Play
  /// Integrity tokeni (server bergan nonce bilan).
  final String token;

  /// iOS App Attest kalit id si (bo'lsa).
  final String? keyId;

  /// Ilova darajasidagi qurilma belgisi (D-77 addendum): Android — ANDROID_ID
  /// (Play Integrity nonce'iga bog'langan), iOS — Keychain'dagi tasodifiy
  /// UUID. Server faqat HMAC holida saqlaydi.
  final String? deviceId;

  Map<String, Object?> toJson(String nonce) => {
    'platform': platform,
    'token': token,
    'nonce': nonce,
    if (keyId != null) 'key_id': keyId,
    if (deviceId != null) 'device_id': deviceId,
  };
}

/// Bepul sinov uchun qurilma attestatsiyasi (ilova tomoni). Haqiqiy:
/// `PlatformDeviceAttestor` (platform_device_attestor.dart — Android Play
/// Integrity, iOS DeviceCheck, platforma kanali orqali). Qurilmada
/// sinalmagan (NOT VERIFIED); docs/PRO_TRIAL_ABUSE_NOTES.md.
abstract interface class DeviceAttestor {
  /// Attestatsiya ishlay oladimi. `false` — sinov tugmasi ko'rsatilmaydi.
  bool get available;

  /// Server bergan [nonce] bilan attestatsiya.
  Future<DeviceAttestation> attest(String nonce);
}

/// Standart: sozlanmagan — sinov boshlanmaydi.
class UnconfiguredDeviceAttestor implements DeviceAttestor {
  const UnconfiguredDeviceAttestor();

  @override
  bool get available => false;

  @override
  Future<DeviceAttestation> attest(String nonce) async =>
      throw StateError('device_attestation_not_configured');
}

/// Ishga tushishda asinxron tayyorlanadigan attestator (platforma qo'llashini
/// so'rash). `EntitlementService.start` chaqiradi; shundan keyin
/// [DeviceAttestor.available] aniq.
abstract interface class PreparableAttestor {
  Future<void> prepare();
}
