import 'package:flutter/material.dart';

import '../../../domain/entities/detected_object.dart';

class DetectionOverlay extends StatelessWidget {
  const DetectionOverlay({super.key, required this.objects});

  final List<DetectedObject> objects;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: DetectionPainter(objects));
  }
}

class DetectionPainter extends CustomPainter {
  DetectionPainter(this.objects);

  final List<DetectedObject> objects;

  @override
  void paint(Canvas canvas, Size size) {
    for (final object in objects) {
      final rect = Rect.fromLTRB(
        object.x1n * size.width,
        object.y1n * size.height,
        object.x2n * size.width,
        object.y2n * size.height,
      );
      final color = object.isCar ? const Color(0xFF4ADE80) : const Color(0xFF38BDF8);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = object.isCar ? 3 : 2
        ..color = color;
      canvas.drawRect(rect, paint);
      final label = TextPainter(
        text: TextSpan(
          text: '${object.labelEs} ${object.confidencePct.round()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final bg = Paint()..color = color.withValues(alpha: 0.85);
      canvas.drawRect(
        Rect.fromLTWH(rect.left, rect.top - 18, label.width + 8, 18),
        bg,
      );
      label.paint(canvas, Offset(rect.left + 4, rect.top - 17));
    }
  }

  @override
  bool shouldRepaint(covariant DetectionPainter oldDelegate) =>
      oldDelegate.objects != objects;
}
