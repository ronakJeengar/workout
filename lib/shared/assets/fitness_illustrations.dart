import 'package:flutter/material.dart';
import '../../core/theme.dart';

class FitnessIllustrations {
  // Muscle Group Icons
  static IconData getMuscleIcon(String muscle) {
    final m = muscle.toLowerCase();
    if (m.contains('chest')) return Icons.fit_screen_rounded;
    if (m.contains('back')) return Icons.layers_rounded;
    if (m.contains('leg') || m.contains('glute') || m.contains('quad') || m.contains('hamstring')) return Icons.directions_walk_rounded;
    if (m.contains('shoulder')) return Icons.accessibility_new_rounded;
    if (m.contains('arm') || m.contains('bicep') || m.contains('tricep')) return Icons.fitness_center_rounded;
    if (m.contains('core') || m.contains('abs') || m.contains('abdominal')) return Icons.shield_rounded;
    return Icons.accessibility_rounded;
  }

  // Food Icons
  static IconData getFoodIcon(String foodType) {
    final f = foodType.toLowerCase();
    if (f.contains('protein') || f.contains('meat') || f.contains('chicken') || f.contains('fish')) return Icons.kebab_dining_rounded;
    if (f.contains('carb') || f.contains('oats') || f.contains('rice') || f.contains('bread')) return Icons.rice_bowl_rounded;
    if (f.contains('fat') || f.contains('oil') || f.contains('nut') || f.contains('avocado')) return Icons.cookie_rounded;
    if (f.contains('water') || f.contains('hydrate')) return Icons.water_drop_rounded;
    return Icons.restaurant_rounded;
  }

  // Recovery Icons
  static IconData getRecoveryIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('sleep') || t.contains('night')) return Icons.nightlight_round_rounded;
    if (t.contains('water') || t.contains('hydration')) return Icons.local_drink_rounded;
    if (t.contains('rest') || t.contains('rebuild')) return Icons.self_improvement_rounded;
    return Icons.favorite_rounded;
  }

  // Simple Custom Vector Placeholder for Exercises
  static Widget getExerciseIllustration(String exerciseName, {double size = 120.0}) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ExerciseIllustrationPainter(exerciseName),
        ),
      ),
    );
  }
}

class _ExerciseIllustrationPainter extends CustomPainter {
  final String exerciseName;
  _ExerciseIllustrationPainter(this.exerciseName);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.fill;

    // Draw background circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    final name = exerciseName.toLowerCase();
    final strokePaint = Paint()
      ..color = AppTheme.primaryLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final headPaint = Paint()
      ..color = AppTheme.primaryLime
      ..style = PaintingStyle.fill;

    if (name.contains('squat')) {
      // Draw Squatting Figure
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.3), 6, headPaint);
      final path = Path()
        ..moveTo(size.width * 0.5, size.height * 0.38)
        ..lineTo(size.width * 0.5, size.height * 0.55) // spine
        ..lineTo(size.width * 0.4, size.height * 0.68) // thigh down
        ..lineTo(size.width * 0.5, size.height * 0.78) // calf down
        ..lineTo(size.width * 0.55, size.height * 0.78); // foot
      canvas.drawPath(path, strokePaint);
      
      canvas.drawLine(
        Offset(size.width * 0.3, size.height * 0.42),
        Offset(size.width * 0.7, size.height * 0.42),
        strokePaint..strokeWidth = 4.0,
      );
    } else if (name.contains('bench') || name.contains('press')) {
      // Draw Bench Press Figure
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.65),
        Offset(size.width * 0.8, size.height * 0.65),
        strokePaint..color = Colors.white54..strokeWidth = 4.0,
      );
      canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.58), 5, headPaint);
      canvas.drawLine(
        Offset(size.width * 0.35, size.height * 0.62),
        Offset(size.width * 0.7, size.height * 0.62),
        strokePaint..color = AppTheme.primaryLime..strokeWidth = 3.0,
      );
      canvas.drawLine(
        Offset(size.width * 0.3, size.height * 0.4),
        Offset(size.width * 0.7, size.height * 0.4),
        strokePaint..strokeWidth = 4.0,
      );
    } else {
      // Draw Generic Barbell
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.5),
        Offset(size.width * 0.8, size.height * 0.5),
        strokePaint..strokeWidth = 5.0,
      );
      canvas.drawRect(Rect.fromLTWH(size.width * 0.22, size.height * 0.35, 8, 30), headPaint);
      canvas.drawRect(Rect.fromLTWH(size.width * 0.72, size.height * 0.35, 8, 30), headPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
