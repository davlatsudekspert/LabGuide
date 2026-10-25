import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'device_attestor.dart';

/// Haqiqiy qurilma attestatsiyasi (7 kunlik sinov, D-77 addendum) —
/// platforma kanali `uz.labguide.app/attestation` orqali:
///
/// * **Android** (`MainActivity.kt`): Google Play Integrity API (classic
///   so'rov, `com.google.android.play:integrity`). Integrity nonce'i server
///   nonce'i va ANDROID_ID ga bog'lanadi:
///   `base64url(SHA-256("labguide-trial-v1|<nonce>|<device_id>"))` — server
///   (`cloudflare/src/attestation.ts` `integrityNonce`) xuddi shunday hisoblaydi.
/// * **iOS** (`AppDelegate.swift`): Apple DeviceCheck (`DCDevice.generateToken`);
///   `device_id` — Keychain'dagi tasodifiy UUID (ilova o'chirib qayta
///   o'rnatilganda odatda saqlanadi — kafolat emas). App Attest ishlatilmaydi.
///
/// Native kod bu muhitda qurilmada ishga tushirilmagan va iOS qismi
/// kompilyatsiya qilinmagan (NOT VERIFIED). Platforma qo'llamasa yoki kanal
/// javob bermasa [available] `false` — sinov tugmasi ko'rsatilmaydi.
class PlatformDeviceAttestor implements DeviceAttestor, PreparableAttestor {
  PlatformDeviceAttestor({
    required this.platform,
    MethodChannel? channel,
    this.cloudProjectNumber,
  }) : _channel = channel ?? const MethodChannel(channelName);

  /// Joriy platforma uchun (haqiqiy Android / iOS qurilma), boshqalarida —
  /// `null`. `dart:io` [Platform] bo'yicha (testdagi `defaultTargetPlatform`
  /// emas): widget testlarida native kanal yo'q, chaqiruv osilib qolmasin.
  static PlatformDeviceAttestor? forCurrentPlatform() {
    if (kIsWeb) return null;
    if (Platform.isAndroid) {
      return PlatformDeviceAttestor(
        platform: 'android',
        cloudProjectNumber: _projectNumber,
      );
    }
    if (Platform.isIOS) return PlatformDeviceAttestor(platform: 'ios');
    return null;
  }

  static const channelName = 'uz.labguide.app/attestation';

  /// Ixtiyoriy: Google Cloud loyiha raqami (Play Console'da bog'lanmagan
  /// bo'lsa kerak). `--dart-define=LG_PLAY_INTEGRITY_PROJECT=<raqam>`; bo'sh — yuborilmaydi.
  static const _projectRaw = String.fromEnvironment('LG_PLAY_INTEGRITY_PROJECT');
  static int? get _projectNumber => int.tryParse(_projectRaw);

  /// `android` yoki `ios` (server `attestation.platform`).
  final String platform;
  final int? cloudProjectNumber;
  final MethodChannel _channel;

  bool _supported = false;
  String? _deviceId;

  @override
  bool get available => _supported && _deviceId != null;

  @override
  Future<void> prepare() async {
    try {
      // Native javob bermasa ilova ishga tushishi to'xtab qolmasin.
      const limit = Duration(seconds: 5);
      _supported =
          await _channel.invokeMethod<bool>('isSupported').timeout(limit) ??
          false;
      _deviceId = _supported
          ? await _channel.invokeMethod<String>('deviceId').timeout(limit)
          : null;
      if (_deviceId != null && !_deviceIdRe.hasMatch(_deviceId!)) {
        _deviceId = null;
      }
    } on Object catch (e) {
      // MissingPluginException (test/desktop), PlatformException — sinov yo'q.
      debugPrint('attestation prepare: $e');
      _supported = false;
      _deviceId = null;
    }
  }

  static final _deviceIdRe = RegExp(r'^[A-Za-z0-9._:-]{8,128}$');

  /// Server bilan bir xil Integrity nonce'i (Android).
  static String integrityNonce(String serverNonce, String deviceId) {
    final d = sha256.convert(
      utf8.encode('labguide-trial-v1|$serverNonce|$deviceId'),
    );
    return base64Url.encode(d.bytes).replaceAll('=', '');
  }

  @override
  Future<DeviceAttestation> attest(String nonce) async {
    final id = _deviceId;
    if (!available || id == null) {
      throw StateError('device_attestation_not_configured');
    }
    final token = await _channel.invokeMethod<String>('attest', {
      if (platform == 'android') 'nonce': integrityNonce(nonce, id),
      'cloudProjectNumber': ?cloudProjectNumber,
    });
    if (token == null || token.isEmpty) {
      throw StateError('device_attestation_failed');
    }
    return DeviceAttestation(platform: platform, token: token, deviceId: id);
  }
}
