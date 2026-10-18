import 'dart:async';

import 'package:labguide/features/classroom/qr_scanner.dart';
import 'package:material_ui/material_ui.dart';

/// Soxta QR skaner: plagin kanali kerak emas; test [FakeQrCamera.emit]
/// bilan "o'qilgan" matn beradi va holatni o'zgartiradi.
class FakeQrScanner implements QrScanner {
  FakeQrScanner({
    this.isSupported = true,
    this.initialStatus = QrCameraStatus.running,
    this.torchAvailable = true,
  });

  @override
  final bool isSupported;
  final QrCameraStatus initialStatus;
  final bool torchAvailable;

  /// Oxirgi ochilgan seans.
  FakeQrCamera? last;
  int opened = 0;
  int settingsOpened = 0;

  @override
  QrCamera open() {
    opened++;
    return last = FakeQrCamera(initialStatus, torchAvailable: torchAvailable);
  }

  @override
  Future<bool> openAppSettings() async {
    settingsOpened++;
    return true;
  }
}

class FakeQrCamera extends ChangeNotifier implements QrCamera {
  FakeQrCamera(this._status, {required this.torchAvailable});

  QrCameraStatus _status;
  bool _torch = false;
  bool disposed = false;
  int retries = 0;
  final _codes = StreamController<String>.broadcast(sync: true);

  @override
  final bool torchAvailable;

  @override
  QrCameraStatus get status => _status;

  set status(QrCameraStatus s) {
    _status = s;
    notifyListeners();
  }

  @override
  bool get torchOn => _torch;

  @override
  Stream<String> get codes => _codes.stream;

  /// Kamera shu matnli QR ni "ko'rdi".
  void emit(String raw) => _codes.add(raw);

  @override
  Widget buildPreview(BuildContext context) =>
      const ColoredBox(key: ValueKey('fake-qr-preview'), color: Colors.black);

  @override
  Future<void> toggleTorch() async {
    _torch = !_torch;
    notifyListeners();
  }

  @override
  Future<void> retry() async => retries++;

  @override
  Future<void> dispose() async {
    disposed = true;
    await _codes.close();
    super.dispose();
  }
}
