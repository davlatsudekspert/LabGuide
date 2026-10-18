/// Ichak parazitlari tuxum/sistalarining ilova o'z vektor sxemalari (foto
/// emas) va nisbiy o'lcham diagrammasi. Chizma faqat manbada tasvirlangan
/// asosiy belgilarni ko'rsatadi (shakl, qobiq, tiqin, ilmoqlar, yadrolar);
/// o'lcham va rang — shartli.
library;

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../design/tokens.dart';
import 'copro_content.dart';

/// Bitta parazit sxemasi.
class CpSchematic extends StatelessWidget {
  const CpSchematic({super.key, required this.shape, this.size = 120});

  final CpShape shape;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    return SizedBox(
      width: size,
      height: size * 0.75,
      child: CustomPaint(
        painter: _EggPainter(
          shape,
          ink: p.ink,
          sub: p.sub,
          shell: p.amber,
          fill: p.soft,
          accent: p.brand,
        ),
      ),
    );
  }
}

class _EggPainter extends CustomPainter {
  _EggPainter(
    this.shape, {
    required this.ink,
    required this.sub,
    required this.shell,
    required this.fill,
    required this.accent,
  });

  final CpShape shape;
  final Color ink;
  final Color sub;
  final Color shell;
  final Color fill;
  final Color accent;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;

  Paint _fill(Color c) => Paint()..color = c;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = math.min(size.width, size.height / 0.75) / 120;
    switch (shape) {
      case CpShape.ascaris:
        // Qalin, g'adir-budur (mamillyar) tashqi qavat, ichida bitta massa.
        final r = Rect.fromCenter(center: c, width: 84 * s, height: 66 * s);
        canvas.drawOval(r, _fill(shell.withValues(alpha: 0.35)));
        for (var i = 0; i < 22; i++) {
          final a = i / 22 * 2 * math.pi;
          final pt = Offset(
            c.dx + math.cos(a) * 42 * s,
            c.dy + math.sin(a) * 33 * s,
          );
          canvas.drawCircle(pt, 4.2 * s, _fill(shell.withValues(alpha: 0.8)));
        }
        canvas.drawOval(r.deflate(8 * s), _fill(fill));
        canvas.drawOval(r.deflate(8 * s), _stroke(ink, 2 * s));
        canvas.drawCircle(c, 15 * s, _fill(sub.withValues(alpha: 0.45)));
      case CpShape.enterobius:
        // Asimmetrik oval: bir tomoni yassi; ichida o'ralgan lichinka.
        final path = Path()
          ..moveTo(c.dx - 44 * s, c.dy + 6 * s)
          ..quadraticBezierTo(c.dx - 40 * s, c.dy - 26 * s, c.dx, c.dy - 26 * s)
          ..quadraticBezierTo(
            c.dx + 44 * s,
            c.dy - 24 * s,
            c.dx + 44 * s,
            c.dy + 4 * s,
          )
          ..quadraticBezierTo(c.dx + 40 * s, c.dy + 14 * s, c.dx, c.dy + 14 * s)
          ..quadraticBezierTo(
            c.dx - 40 * s,
            c.dy + 16 * s,
            c.dx - 44 * s,
            c.dy + 6 * s,
          )
          ..close();
        canvas.drawPath(path, _fill(fill));
        canvas.drawPath(path, _stroke(ink, 2.4 * s));
        final larva = Path()
          ..moveTo(c.dx - 28 * s, c.dy + 2 * s)
          ..cubicTo(
            c.dx - 20 * s,
            c.dy - 20 * s,
            c.dx + 30 * s,
            c.dy - 20 * s,
            c.dx + 28 * s,
            c.dy - 2 * s,
          )
          ..cubicTo(
            c.dx + 24 * s,
            c.dy + 8 * s,
            c.dx - 10 * s,
            c.dy + 6 * s,
            c.dx - 6 * s,
            c.dy - 6 * s,
          );
        canvas.drawPath(larva, _stroke(sub, 4 * s));
      case CpShape.hymenolepis:
        // Ikki qavat qobiq, qutb iplari, olti ilmoqli onkosfera.
        final outer = Rect.fromCenter(center: c, width: 80 * s, height: 66 * s);
        canvas.drawOval(outer, _fill(fill));
        canvas.drawOval(outer, _stroke(ink, 1.6 * s));
        final inner = Rect.fromCenter(center: c, width: 46 * s, height: 38 * s);
        for (final side in [-1.0, 1.0]) {
          final pole = Offset(c.dx + side * 23 * s, c.dy);
          for (var i = 0; i < 3; i++) {
            final bend = (i - 1) * 9 * s;
            final f = Path()
              ..moveTo(pole.dx, pole.dy)
              ..quadraticBezierTo(
                pole.dx + side * 10 * s,
                pole.dy + bend * 2,
                pole.dx + side * 6 * s,
                pole.dy + bend * 2.6,
              );
            canvas.drawPath(f, _stroke(sub, 1.2 * s));
          }
        }
        canvas.drawOval(inner, _stroke(ink, 2.2 * s));
        _hooks(canvas, c, s);
      case CpShape.giardia:
        // Oval, qo'sh devor, 4 yadro va bo'ylama fibril.
        final r = Rect.fromCenter(
          center: c,
          width: 64 * s,
          height: 86 * s * 0.75,
        );
        canvas.drawOval(r, _fill(fill));
        canvas.drawOval(r, _stroke(ink, 2.2 * s));
        canvas.drawOval(r.deflate(4 * s), _stroke(sub, 1 * s));
        for (final (dx, dy) in [
          (-9.0, -14.0),
          (9.0, -14.0),
          (-9.0, -2.0),
          (9.0, -2.0),
        ]) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(c.dx + dx * s, c.dy + dy * s),
              width: 9 * s,
              height: 7 * s,
            ),
            _stroke(accent, 1.6 * s),
          );
        }
        final fib = Path()
          ..moveTo(c.dx - 2 * s, c.dy - 22 * s)
          ..cubicTo(
            c.dx + 8 * s,
            c.dy,
            c.dx - 8 * s,
            c.dy + 8 * s,
            c.dx + 2 * s,
            c.dy + 24 * s,
          );
        canvas.drawPath(fib, _stroke(sub, 1.6 * s));
      case CpShape.entamoeba:
        // Dumaloq sista, 4 yadro (kichik markaziy kariosoma), to'mtoq
        // xromatoid tanacha.
        canvas.drawCircle(c, 32 * s, _fill(fill));
        canvas.drawCircle(c, 32 * s, _stroke(ink, 2 * s));
        for (final (dx, dy) in [
          (-12.0, -11.0),
          (12.0, -11.0),
          (-12.0, 11.0),
          (12.0, 11.0),
        ]) {
          final n = Offset(c.dx + dx * s, c.dy + dy * s);
          canvas.drawCircle(n, 6 * s, _stroke(accent, 1.6 * s));
          canvas.drawCircle(n, 1.6 * s, _fill(accent));
        }
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: 26 * s, height: 6 * s),
            Radius.circular(3 * s),
          ),
          _fill(sub.withValues(alpha: 0.8)),
        );
      case CpShape.trichuris:
        // Bochkasimon, qalin qobiq, ikki qutbida tiqin.
        final r = Rect.fromCenter(center: c, width: 76 * s, height: 38 * s);
        canvas.drawRRect(
          RRect.fromRectAndRadius(r, Radius.circular(18 * s)),
          _fill(shell.withValues(alpha: 0.6)),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(r.deflate(5 * s), Radius.circular(14 * s)),
          _fill(fill),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(r, Radius.circular(18 * s)),
          _stroke(ink, 2 * s),
        );
        for (final side in [-1.0, 1.0]) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(c.dx + side * 41 * s, c.dy),
              width: 10 * s,
              height: 14 * s,
            ),
            _fill(fill),
          );
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(c.dx + side * 41 * s, c.dy),
              width: 10 * s,
              height: 14 * s,
            ),
            _stroke(ink, 1.4 * s),
          );
        }
      case CpShape.taenia:
        // Dumaloq, juda qalin radial chiziqli qobiq, olti ilmoqli onkosfera.
        canvas.drawCircle(c, 32 * s, _fill(shell.withValues(alpha: 0.55)));
        for (var i = 0; i < 48; i++) {
          final a = i / 48 * 2 * math.pi;
          canvas.drawLine(
            Offset(c.dx + math.cos(a) * 22 * s, c.dy + math.sin(a) * 22 * s),
            Offset(c.dx + math.cos(a) * 31 * s, c.dy + math.sin(a) * 31 * s),
            _stroke(ink.withValues(alpha: 0.55), 1 * s),
          );
        }
        canvas.drawCircle(c, 32 * s, _stroke(ink, 2 * s));
        canvas.drawCircle(c, 21 * s, _fill(fill));
        canvas.drawCircle(c, 21 * s, _stroke(ink, 1.4 * s));
        _hooks(canvas, c, s);
    }
  }

  /// Olti ilmoq (uch juft), yelpig'ichsimon.
  void _hooks(Canvas canvas, Offset c, double s) {
    for (var i = 0; i < 3; i++) {
      final a = -math.pi / 2 + (i - 1) * 0.5;
      for (final side in [-1.0, 1.0]) {
        final start = Offset(c.dx + side * 3 * s, c.dy + 6 * s);
        final end = Offset(
          start.dx + math.cos(a) * 12 * s * side.sign + side * 2 * s,
          start.dy + math.sin(a) * 12 * s,
        );
        canvas.drawLine(start, end, _stroke(accent, 1.6 * s));
      }
    }
  }

  @override
  bool shouldRepaint(_EggPainter old) =>
      old.shape != shape || old.ink != ink || old.fill != fill;
}

/// Nisbiy o'lcham: har parazit uchun manbadagi uzunlik oralig'i, eritrotsit
/// bilan solishtirib (shkala chiziqli, µm).
class CpSizeChart extends StatelessWidget {
  const CpSizeChart({
    super.key,
    required this.rows,
    required this.unit,
    this.max = 80,
  });

  /// (nom, oraliq).
  final List<(String, CpSize)> rows;
  final String unit;
  final double max;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    String fmt(double v) =>
        v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (name, r) in rows)
          Semantics(
            label: '$name: ${fmt(r.min)}–${fmt(r.max)} $unit',
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name · ${fmt(r.min)}–${fmt(r.max)} $unit',
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: 3),
                    LayoutBuilder(
                      builder: (context, box) {
                        final w = box.maxWidth;
                        final left = w * (r.min / max).clamp(0.0, 1.0);
                        final width = (w * ((r.max - r.min) / max)).clamp(
                          3.0,
                          w - left,
                        );
                        return SizedBox(
                          height: 10,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: p.soft,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: left,
                                width: width,
                                top: 0,
                                bottom: 0,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: p.brand,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        Text('0 — ${fmt(max)} $unit', style: text.labelSmall),
      ],
    );
  }
}
