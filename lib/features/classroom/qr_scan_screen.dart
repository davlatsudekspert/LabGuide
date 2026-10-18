// To'liq ekranli QR skaner (D-68): ramka, chiroq, ruxsat yo'q holati va
// "kodni yozish" zaxira yo'li. O'qilgan matn [parseInvite] bilan tekshiriladi
// (havola yoki xom kod); topilsa — tebranish va ekran yopiladi.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import 'invite_link.dart';
import 'qr_scanner.dart';

/// Skaner natijasi.
sealed class QrScanOutcome {
  const QrScanOutcome();
}

/// Taklif topildi.
class QrScanInvite extends QrScanOutcome {
  const QrScanInvite(this.invite);
  final InviteTarget invite;
}

/// Foydalanuvchi kodni qo'lda yozishni tanladi.
class QrScanTypeInstead extends QrScanOutcome {
  const QrScanTypeInstead();
}

/// Skanerni (ilova ustida, pastki menyusiz) ochadi. Yopilsa — null.
Future<QrScanOutcome?> openInviteScanner(BuildContext context) {
  final scanner = context.services.qrScanner;
  return Navigator.of(context, rootNavigator: true).push<QrScanOutcome>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => QrScanScreen(scanner: scanner),
    ),
  );
}

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key, required this.scanner});

  final QrScanner scanner;

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with WidgetsBindingObserver {
  late final QrCamera _camera = widget.scanner.open();
  late final StreamSubscription<String> _sub;
  bool _done = false;
  String? _lastRejected;
  bool _showNotInvite = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _camera.addListener(_changed);
    _sub = _camera.codes.listen(_onCode);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    _camera.removeListener(_changed);
    unawaited(_sub.cancel());
    unawaited(_camera.dispose());
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  /// Sozlamalardan qaytganda — ruxsat berilgan bo'lishi mumkin.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _camera.status == QrCameraStatus.permissionDenied) {
      unawaited(_camera.retry());
    }
  }

  void _onCode(String raw) {
    if (_done || !mounted) return;
    final invite = parseInvite(raw);
    if (invite == null) {
      // Bir xil begona kod qayta-qayta xabar chiqarmasin.
      if (raw == _lastRejected && _showNotInvite) return;
      _lastRejected = raw;
      _hideTimer?.cancel();
      setState(() => _showNotInvite = true);
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showNotInvite = false);
      });
      return;
    }
    _done = true;
    unawaited(HapticFeedback.mediumImpact());
    Navigator.of(context).pop(QrScanInvite(invite));
  }

  void _typeInstead() => Navigator.of(context).pop(const QrScanTypeInstead());

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final status = _camera.status;
    if (status == QrCameraStatus.permissionDenied ||
        status == QrCameraStatus.failed) {
      return _problem(context, l, denied: status != QrCameraStatus.failed);
    }
    return Scaffold(
      key: const ValueKey('qr-scan-screen'),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(child: _camera.buildPreview(context)),
          const IgnorePointer(child: _ScanFrame()),
          SafeArea(child: _controls(context, l, status)),
        ],
      ),
    );
  }

  Widget _controls(
    BuildContext context,
    AppLocalizations l,
    QrCameraStatus status,
  ) {
    final text = Theme.of(context).textTheme;
    const white = Colors.white;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: Row(
            children: [
              IconButton(
                key: const ValueKey('qr-close'),
                tooltip: l.actionClose,
                color: white,
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Spacer(),
              if (_camera.torchAvailable)
                IconButton(
                  key: const ValueKey('qr-torch'),
                  tooltip: _camera.torchOn ? l.qrScanTorchOff : l.qrScanTorchOn,
                  color: white,
                  isSelected: _camera.torchOn,
                  icon: const Icon(Icons.flashlight_off_rounded),
                  selectedIcon: const Icon(Icons.flashlight_on_rounded),
                  onPressed: _camera.toggleTorch,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l.qrScanAction,
            textAlign: TextAlign.center,
            style: text.titleLarge!.copyWith(color: white),
          ),
        ),
        const Spacer(),
        if (_showNotInvite)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: DecoratedBox(
              key: const ValueKey('qr-not-invite'),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l.qrScanNotInvite,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium!.copyWith(color: white),
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
          child: Text(
            status == QrCameraStatus.starting ? l.qrScanStarting : l.qrScanHint,
            textAlign: TextAlign.center,
            style: text.bodyMedium!.copyWith(color: white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: OutlinedButton.icon(
            key: const ValueKey('qr-type-code'),
            style: OutlinedButton.styleFrom(
              foregroundColor: white,
              side: const BorderSide(color: Colors.white70),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.keyboard_rounded),
            label: Text(l.qrScanTypeCode, textAlign: TextAlign.center),
            onPressed: _typeInstead,
          ),
        ),
      ],
    );
  }

  Widget _problem(
    BuildContext context,
    AppLocalizations l, {
    required bool denied,
  }) {
    final p = LgPalette.of(context);
    return Scaffold(
      key: ValueKey(denied ? 'qr-denied' : 'qr-failed'),
      backgroundColor: p.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                key: const ValueKey('qr-close'),
                tooltip: l.actionClose,
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LgStateView(
                  kind: StateKind.error,
                  title: denied ? l.qrScanDeniedTitle : l.qrScanFailedTitle,
                  message: denied ? l.qrScanDeniedBody : l.qrScanFailedBody,
                  actionLabel: denied ? l.qrScanOpenSettings : null,
                  onAction: denied
                      ? () => unawaited(widget.scanner.openAppSettings())
                      : null,
                  secondary: LgButton.secondary(
                    key: const ValueKey('qr-type-code'),
                    label: l.qrScanTypeCode,
                    icon: Icons.keyboard_rounded,
                    onPressed: _typeInstead,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ramka: atrof xiralashtiriladi, o'rtada burchak chiziqlari.
class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _FramePainter(), size: Size.infinite);
}

class _FramePainter extends CustomPainter {
  /// Ramka tomoni: kichik ekranda ham sig'adi.
  static Rect frameFor(Size size) {
    final side = (size.shortestSide * 0.68).clamp(160.0, 280.0);
    final c = size.center(Offset.zero);
    return Rect.fromCenter(center: c, width: side, height: side);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final frame = frameFor(size);
    final r = RRect.fromRectAndRadius(frame, const Radius.circular(20));
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(r),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    final corner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const len = 28.0;
    const rad = 20.0;
    for (final (dx, dy) in const [(0, 0), (1, 0), (0, 1), (1, 1)]) {
      final x = dx == 0 ? frame.left : frame.right;
      final y = dy == 0 ? frame.top : frame.bottom;
      final sx = dx == 0 ? 1.0 : -1.0;
      final sy = dy == 0 ? 1.0 : -1.0;
      canvas.drawPath(
        Path()
          ..moveTo(x, y + sy * (rad + len))
          ..lineTo(x, y + sy * rad)
          ..arcToPoint(
            Offset(x + sx * rad, y),
            radius: const Radius.circular(rad),
            clockwise: sx * sy > 0,
          )
          ..lineTo(x + sx * (rad + len), y),
        corner,
      );
    }
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) => false;
}
