import 'package:material_ui/material_ui.dart';
import 'package:qr/qr.dart';

/// Matn QR kodi (guruh taklif kodi). Mavzudan qat'i nazar oq fonda qora
/// modullar — kamera har doim o'qiy olsin.
class QrCodeView extends StatelessWidget {
  const QrCodeView({
    super.key,
    required this.data,
    required this.semanticLabel,
    this.size = 180,
  });

  final String data;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = QrImage(
      QrCode(
        payload: QrPayload.fromString(data),
        errorCorrectLevel: QrErrorCorrectLevel.medium,
      ),
    );
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size / 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomPaint(painter: _QrPainter(image)),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.image);

  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    final n = image.moduleCount;
    final cell = size.shortestSide / n;
    final paint = Paint()
      ..color = Colors.black
      ..isAntiAlias = false;
    for (var x = 0; x < n; x++) {
      for (var y = 0; y < n; y++) {
        if (image.isDark(y, x)) {
          // Qo'shni kvadratlar orasida tirqish qolmasin.
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell + 0.5, cell + 0.5),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.image != image;
}
