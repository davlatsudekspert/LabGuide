// Ilova ichidagi QR skaner (D-68): ustoz bergan guruh / test QR kodini
// o'qish. Kamera kadri faqat qurilmada tahlil qilinadi — rasm saqlanmaydi
// va hech qayerga yuborilmaydi; faqat o'qilgan matn [parseInvite] ga beriladi.
//
// Plagin ([MobileQrScanner], `mobile_scanner`) interfeys ortida: testlar
// soxta skaner bilan ishlaydi (plagin kanali kerak emas).
import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

/// Kamera holati.
enum QrCameraStatus {
  /// Ishga tushmoqda (ruxsat oynasi ham shu vaqtda).
  starting,

  /// Kadrlar tahlil qilinmoqda.
  running,

  /// Foydalanuvchi kameraga ruxsat bermagan.
  permissionDenied,

  /// Kamera yo'q yoki ochilmadi.
  failed,
}

/// Bitta skanerlash seansi (ekran ochiq turgan vaqt).
abstract class QrCamera implements Listenable {
  QrCameraStatus get status;

  /// Chiroq (torch) bormi va yoqiqmi.
  bool get torchAvailable;
  bool get torchOn;

  /// O'qilgan QR matnlari (xom).
  Stream<String> get codes;

  /// Kamera ko'rinishi (to'liq ekran, `BoxFit.cover`).
  Widget buildPreview(BuildContext context);

  Future<void> toggleTorch();

  /// Ruxsat berilgach (sozlamalardan qaytganda) — qayta urinish.
  Future<void> retry();

  Future<void> dispose();
}

/// Skaner manbai: platforma qo'llaydimi, seans ochish, sozlamalarni ochish.
abstract interface class QrScanner {
  /// Faqat Android va iOS (veb/desktop — tugma ko'rinmaydi).
  bool get isSupported;

  QrCamera open();

  /// Tizim sozlamalarida ilova sahifasi (kamera ruxsati uchun).
  Future<bool> openAppSettings();
}

/// `mobile_scanner` (BSD-3): Android CameraX + ML Kit, iOS AVFoundation/Vision.
class MobileQrScanner implements QrScanner {
  const MobileQrScanner();

  static const _androidPackage = 'uz.labguide.app';

  @override
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  QrCamera open() => _MobileQrCamera();

  @override
  Future<bool> openAppSettings() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await const AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:$_androidPackage',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        ).launch();
        return true;
      }
      return await launchUrl(Uri.parse('app-settings:'));
    } on Object {
      return false;
    }
  }
}

class _MobileQrCamera extends ChangeNotifier implements QrCamera {
  _MobileQrCamera() {
    _controller.addListener(notifyListeners);
    _sub = _controller.barcodes.listen((capture) {
      for (final b in capture.barcodes) {
        final raw = b.rawValue;
        if (raw != null && raw.isNotEmpty) _codes.add(raw);
      }
    });
  }

  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final _codes = StreamController<String>.broadcast();
  late final StreamSubscription<BarcodeCapture> _sub;

  @override
  QrCameraStatus get status {
    final v = _controller.value;
    return switch (v.error?.errorCode) {
      MobileScannerErrorCode.permissionDenied =>
        QrCameraStatus.permissionDenied,
      MobileScannerErrorCode.unsupported ||
      MobileScannerErrorCode.genericError => QrCameraStatus.failed,
      _ => v.isRunning ? QrCameraStatus.running : QrCameraStatus.starting,
    };
  }

  @override
  bool get torchAvailable {
    final t = _controller.value.torchState;
    return t != TorchState.unavailable;
  }

  @override
  bool get torchOn => _controller.value.torchState == TorchState.on;

  @override
  Stream<String> get codes => _codes.stream;

  @override
  Widget buildPreview(BuildContext context) => MobileScanner(
    controller: _controller,
    // Xato/ruxsat holatini ekranning o'zi chizadi (status orqali).
    errorBuilder: (context, error) => const ColoredBox(color: Colors.black),
    placeholderBuilder: (context) => const ColoredBox(color: Colors.black),
  );

  @override
  Future<void> toggleTorch() async {
    try {
      await _controller.toggleTorch();
    } on Object {
      // Chiroq yo'q/band — e'tiborsiz.
    }
  }

  @override
  Future<void> retry() async {
    try {
      await _controller.stop();
      await _controller.start();
    } on Object {
      // Holat controller.value.error orqali ko'rinadi.
    }
  }

  @override
  Future<void> dispose() async {
    _controller.removeListener(notifyListeners);
    await _sub.cancel();
    await _codes.close();
    super.dispose();
    await _controller.dispose();
  }
}
