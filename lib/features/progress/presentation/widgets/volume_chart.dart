import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../domain/volume_point.dart';

class VolumeChart extends StatelessWidget {
  final List<VolumePoint> points;

  const VolumeChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 120),
      painter: _VolumePainter(points, AppTheme.primaryLime),
    );
  }
}

class _VolumePainter extends CustomPainter {
  final List<VolumePoint> points;
  final Color color;

  _VolumePainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withAlpha(100), color.withAlpha(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    double maxVolume = 0;
    for (var p in points) {
      if (p.volume > maxVolume) maxVolume = p.volume;
    }
    if (maxVolume == 0) maxVolume = 1;

    final path = Path();
    final fillPath = Path();

    final double stepX = size.width / (points.length > 1 ? points.length - 1 : 1);

    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      final double y = size.height - (points[i].volume / maxVolume * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      
      if (i == points.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _VolumePainter oldDelegate) => oldDelegate.points != points;
}
