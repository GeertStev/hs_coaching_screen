import 'dart:math' as math;
import 'package:flutter/material.dart';
//import 'dart:ui' as ui;
import 'package:hs_coaching_core/sketch/sketch_element.dart';

class SketchPainter extends CustomPainter {
  const SketchPainter({
    required this.elements,
    required this.actualSize,
    required this.targetSize,
  });

  final List<SketchElement> elements;
  final Size actualSize;
  final Size targetSize;

  /// Scales an offset from the target coordinate system to the local canvas system.
  Offset _scaleToLocal(Offset targetOffset) {
    if (targetSize.isEmpty || actualSize.isEmpty) return targetOffset;
    final scaleX = actualSize.width / targetSize.width;
    final scaleY = actualSize.height / targetSize.height;
    return Offset(targetOffset.dx * scaleX, targetOffset.dy * scaleY);
  }

  /// Scales a value from the target coordinate system to the local canvas system.
  /// We use the average of the scale factors to have a consistent scaling for radii and stroke widths.
  double _scaleValueToLocal(double targetValue) {
    if (targetSize.isEmpty || actualSize.isEmpty) return targetValue;
    final scaleX = actualSize.width / targetSize.width;
    final scaleY = actualSize.height / targetSize.height;
    return targetValue * ((scaleX + scaleY) / 2.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final element in elements) {
      _drawElement(canvas, size, element);
    }
  }

  void _drawElement(Canvas canvas, Size size, SketchElement element) {
    switch (element) {
      case PathElement(:final points, :final color, :final strokeWidth):
        if (points.isEmpty) return;

        final paint = Paint()
          ..color = color
          ..strokeWidth = _scaleValueToLocal(strokeWidth.toDouble())
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        paint.style = PaintingStyle.stroke;

        final path = Path();
        final firstPoint = _scaleToLocal(points.first.offset);
        path.moveTo(firstPoint.dx, firstPoint.dy);
        for (var i = 1; i < points.length; i++) {
          final point = _scaleToLocal(points[i].offset);
          path.lineTo(point.dx, point.dy);
        }
        canvas.drawPath(path, paint);

      case ArrowElement(
        :final start,
        :final end,
        :final color,
        :final strokeWidth,
      ):
        final paint = Paint()
          ..color = color
          ..strokeWidth = _scaleValueToLocal(strokeWidth.toDouble())
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        paint.style = PaintingStyle.stroke;
        final localStart = _scaleToLocal(start);
        final localEnd = _scaleToLocal(end);

        final path = Path()
          ..moveTo(localStart.dx, localStart.dy)
          ..lineTo(localEnd.dx, localEnd.dy);

        // Draw arrow head
        final angle = math.atan2(
          localEnd.dy - localStart.dy,
          localEnd.dx - localStart.dx,
        );
        final arrowSize = _scaleValueToLocal(15.0);
        const arrowAngle = 25 * math.pi / 180;
        path.moveTo(
          localEnd.dx - arrowSize * math.cos(angle - arrowAngle),
          localEnd.dy - arrowSize * math.sin(angle - arrowAngle),
        );
        path.lineTo(localEnd.dx, localEnd.dy);
        path.lineTo(
          localEnd.dx - arrowSize * math.cos(angle + arrowAngle),
          localEnd.dy - arrowSize * math.sin(angle + arrowAngle),
        );

        canvas.drawPath(path, paint);

      case LineElement(
        :final start,
        :final end,
        :final color,
        :final strokeWidth,
      ):
        final paint = Paint()
          ..color = color
          ..strokeWidth = _scaleValueToLocal(strokeWidth.toDouble())
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        paint.style = PaintingStyle.stroke;
        final localStart = _scaleToLocal(start);
        final localEnd = _scaleToLocal(end);
        canvas.drawLine(localStart, localEnd, paint);

      case RectangleElement(
        :final start,
        :final end,
        :final color,
        :final strokeWidth,
        :final fillColor,
      ):
        final paint = Paint()
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        final localStart = _scaleToLocal(start);
        final localEnd = _scaleToLocal(end);
        final rect = Rect.fromPoints(localStart, localEnd);
        if (fillColor != null) {
          paint
            ..style = PaintingStyle.fill
            ..color = fillColor;
          canvas.drawRect(rect, paint);
        }
        paint.style = PaintingStyle.stroke;
        paint.color = color;
        paint.strokeWidth = _scaleValueToLocal(strokeWidth.toDouble());
        canvas.drawRect(rect, paint);

      case PolygonElement(
        :final points,
        :final color,
        :final strokeWidth,
        :final fillColor,
      ):
        if (points.isEmpty) return;
        final paint = Paint()
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        final path = Path();
        final firstPoint = _scaleToLocal(points.first.offset);
        path.moveTo(firstPoint.dx, firstPoint.dy);
        for (var i = 1; i < points.length; i++) {
          final point = _scaleToLocal(points[i].offset);
          path.lineTo(point.dx, point.dy);
        }
        path.close(); // Maak de vorm sluitend!

        // Teken vulling
        if (fillColor != null) {
          paint
            ..style = PaintingStyle.fill
            ..color = fillColor;
          canvas.drawPath(path, paint);
        }
        // Teken randen
        paint
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = _scaleValueToLocal(strokeWidth.toDouble());
        canvas.drawPath(path, paint);

      case CircleElement(
        :final center,
        :final radius,
        :final color,
        :final strokeWidth,
        :final fillColor,
      ):
        final paint = Paint()
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        final localCenter = _scaleToLocal(center);
        final localRadius = _scaleValueToLocal(radius);

        if (fillColor != null) {
          paint
            ..style = PaintingStyle.fill
            ..color = fillColor;
          canvas.drawCircle(localCenter, localRadius, paint);
        }
        paint.style = PaintingStyle.stroke;
        paint.color = color;
        paint.strokeWidth = _scaleValueToLocal(strokeWidth.toDouble());
        canvas.drawCircle(localCenter, localRadius, paint);

      case IconElement(
        :final position,
        :final iconId,
        :final size,
        :final rotation,
      ):
        final iconData = availableIcons[iconId];
        if (iconData == null) return;
        final localPosition = _scaleToLocal(position);
        final localSize = _scaleValueToLocal(size);

        final textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: String.fromCharCode(iconData.codePoint),
            style: TextStyle(
              fontSize: localSize,
              fontFamily: iconData.fontFamily,
              color: Colors.black, // Icons have their own color
            ),
          ),
        )..layout();

        canvas.save();
        canvas.translate(localPosition.dx, localPosition.dy);
        canvas.rotate(rotation);
        textPainter.paint(canvas, Offset(-localSize / 2, -localSize / 2));
        canvas.restore();
    }
  }

  static Rect getBoundingBox(
    SketchElement element,
    Size actualSize,
    Size targetSize,
  ) {
    // Helper to scale offsets for bounding box calculation
    Offset scale(Offset o) {
      if (actualSize.isEmpty || targetSize.isEmpty) return o;
      final scaleX = actualSize.width / targetSize.width;
      final scaleY = actualSize.height / targetSize.height;
      return Offset(o.dx * scaleX, o.dy * scaleY);
    }

    // Helper to scale values
    double scaleVal(double v) {
      if (actualSize.isEmpty || targetSize.isEmpty) return v;
      final scaleX = actualSize.width / targetSize.width;
      final scaleY = actualSize.height / targetSize.height;
      return v * ((scaleX + scaleY) / 2.0);
    }

    switch (element) {
      case PathElement(:final points, :final strokeWidth):
        if (points.isEmpty) return Rect.zero;
        var l = scale(points.first.offset).dx,
            r = l,
            t = scale(points.first.offset).dy,
            b = t;
        for (final p in points) {
          final localP = scale(p.offset);
          l = math.min(l, localP.dx);
          r = math.max(r, localP.dx);
          t = math.min(t, localP.dy);
          b = math.max(b, localP.dy);
        }
        return Rect.fromLTRB(
          l,
          t,
          r,
          b,
        ).inflate(scaleVal(strokeWidth.toDouble()));
      case ArrowElement(:final start, :final end, :final strokeWidth):
        return Rect.fromPoints(
          scale(start),
          scale(end),
        ).inflate(scaleVal(strokeWidth.toDouble()));
      case LineElement(:final start, :final end, :final strokeWidth):
        return Rect.fromPoints(
          scale(start),
          scale(end),
        ).inflate(scaleVal(strokeWidth.toDouble()));
      case RectangleElement(:final start, :final end, :final strokeWidth):
        return Rect.fromPoints(
          scale(start),
          scale(end),
        ).inflate(scaleVal(strokeWidth.toDouble()));
      case PolygonElement(:final points, :final strokeWidth):
        if (points.isEmpty) return Rect.zero;
        var l = scale(points.first.offset).dx,
            r = l,
            t = scale(points.first.offset).dy,
            b = t;
        for (final p in points) {
          final localP = scale(p.offset);
          l = math.min(l, localP.dx);
          r = math.max(r, localP.dx);
          t = math.min(t, localP.dy);
          b = math.max(b, localP.dy);
        }
        return Rect.fromLTRB(
          l,
          t,
          r,
          b,
        ).inflate(scaleVal(strokeWidth.toDouble()));
      case CircleElement(:final center, :final radius, :final strokeWidth):
        return Rect.fromCircle(
          center: scale(center),
          radius: scaleVal(radius),
        ).inflate(scaleVal(strokeWidth.toDouble()));
      case IconElement(:final position, :final size):
        // Bounding box for selection is in local space
        return Rect.fromCenter(
          center: scale(position),
          width: scaleVal(size),
          height: scaleVal(size),
        );
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) => true;
}
