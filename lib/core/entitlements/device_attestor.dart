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
  });

  /// `ios` yoki `android`.
  final String platform;

  /// iOS — App Attest assertion yoki DeviceCheck tokeni; Android — Play
  /// Integrity tokeni (server bergan nonce bilan).
  final String token;

  /// iOS App Attest kalit id si (bo'lsa).
  final String? keyId;

  Map<String, Object?> toJson(String nonce) => {
    'platform': platform,
    'token': token,
    'nonce': nonce,
    if (keyId != null) 'key_id': keyId,
  };
}

/// Bepul sinov uchun qurilma attestatsiyasi (ilova tomoni). Haqiqiy
/// amalga oshirish (iOS DeviceCheck / App Attest, Android Play Integrity)
/// bu tarmoqda YO'Q: native plaginlar va Apple/Google sozlamalari egasi
/// tomonidan qilinadi (docs/PRO_TRIAL_ABUSE_NOTES.md).
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
