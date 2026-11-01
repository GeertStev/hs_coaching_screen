import 'package:flutter/material.dart';

/// Kleine lijn-iconen van het ontwerp, zelf getekend zodat ze niet van een
/// icon-font afhangen (kiosk, golden tests).
class PoolIcon extends StatelessWidget {
  const PoolIcon.chevron({super.key, required this.size, required this.color})
    : _kind = _PoolIconKind.chevron;
  const PoolIcon.repeat({super.key, required this.size, required this.color})
    : _kind = _PoolIconKind.repeat;
  const PoolIcon.check({super.key, required this.size, required this.color})
    : _kind = _PoolIconKind.check;

  final double size;
  final Color color;
  final _PoolIconKind _kind;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _PoolIconPainter(_kind, color)),
  );
}

enum _PoolIconKind { chevron, repeat, check }

class _PoolIconPainter extends CustomPainter {
  _PoolIconPainter(this.kind, this.color);

  final _PoolIconKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = s * 0.15;
    switch (kind) {
      case _PoolIconKind.chevron:
        // Pad "M5 3l5 5-5 5" in een 16×16-viewbox.
        canvas.drawPath(
          Path()
            ..moveTo(s * 5 / 16, s * 3 / 16)
            ..lineTo(s * 10 / 16, s * 8 / 16)
            ..lineTo(s * 5 / 16, s * 13 / 16),
          paint,
        );
      case _PoolIconKind.check:
        // Pad "M2.5 6.5l2.5 2.5 4.5-5" in een 12×12-viewbox.
        paint.strokeWidth = s * 2 / 14;
        canvas.drawPath(
          Path()
            ..moveTo(s * 2.5 / 12, s * 6.5 / 12)
            ..lineTo(s * 5 / 12, s * 9 / 12)
            ..lineTo(s * 9.5 / 12, s * 4 / 12),
          paint,
        );
      case _PoolIconKind.repeat:
        // Cirkelboog met pijlpunt, 20×20-viewbox.
        paint.strokeWidth = s * 2.2 / 20;
        final center = Offset(s / 2, s / 2);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: s * 6 / 20),
          -0.72,
          5.0,
          false,
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(s * 14.5 / 20, s * 2.5 / 20)
            ..lineTo(s * 14.5 / 20, s * 6 / 20)
            ..lineTo(s * 11 / 20, s * 6 / 20),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(_PoolIconPainter old) =>
      old.kind != kind || old.color != color;
}
