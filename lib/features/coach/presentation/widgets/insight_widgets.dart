import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_sizes.dart';
import '../../../../core/theme.dart';
import '../../domain/fatigue_model.dart';
import '../../../progress/providers/progress_provider.dart';

// ==========================================
// FATIGUE METER WIDGET
// ==========================================
class FatigueMeter extends StatelessWidget {
  final FatigueModel fatigue;

  const FatigueMeter({
    super.key,
    required this.fatigue,
  });

  Color _getFatigueColor(double score) {
    if (score >= 0.8) return const Color(0xFFEF4444); // Red
    if (score >= 0.6) return const Color(0xFFF97316); // Orange
    if (score >= 0.3) return const Color(0xFFEAB308); // Yellow
    return AppTheme.primaryLime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = fatigue.fatigueScore;
    final color = _getFatigueColor(score);

    return Column(
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: CustomPaint(
            painter: _GaugePainter(
              progress: score,
              color: color,
              backgroundColor: Colors.white12,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    '${(score * 100).toInt()}%',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'FATIGUE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.s),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: color.withAlpha(60), width: 1),
          ),
          child: Text(
            fatigue.recoveryState.name.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 8;
    const startAngle = -math.pi * 1.25;
    const sweepAngle = math.pi * 1.5;

    // Draw background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Draw active arc
    if (progress > 0) {
      final activePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * progress.clamp(0.0, 1.0),
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

// ==========================================
// VOLUME TREND MINI CHART WIDGET
// ==========================================
class VolumeTrendMiniChart extends ConsumerWidget {
  const VolumeTrendMiniChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(volumeTrendProvider);

    return trendAsync.when(
      data: (points) {
        if (points.isEmpty) {
          return const SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'NO VOLUME DATA',
                style: TextStyle(fontSize: 10, color: Colors.white30),
              ),
            ),
          );
        }

        final volumes = points.map((p) => p.volume).toList();
        final maxVol = volumes.reduce(math.max);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _VolumeBarsPainter(
                  volumes: volumes,
                  maxVolume: maxVol,
                  barColor: AppTheme.primaryLime,
                  emptyBarColor: Colors.white.withAlpha(20),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.s),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '30 DAYS AGO',
                  style: TextStyle(fontSize: 8, color: Colors.white.withAlpha(100), fontWeight: FontWeight.bold),
                ),
                Text(
                  'TODAY',
                  style: TextStyle(fontSize: 8, color: Colors.white.withAlpha(100), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryLime)),
      ),
      error: (_, __) => const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'ERROR CHARGING DATA',
            style: TextStyle(fontSize: 10, color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}

class _VolumeBarsPainter extends CustomPainter {
  final List<double> volumes;
  final double maxVolume;
  final Color barColor;
  final Color emptyBarColor;

  _VolumeBarsPainter({
    required this.volumes,
    required this.maxVolume,
    required this.barColor,
    required this.emptyBarColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = volumes.length;
    final totalSpacing = size.width * 0.25; // 25% of width as spacing
    final spacing = totalSpacing / (barCount - 1);
    final barWidth = (size.width - totalSpacing) / barCount;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      final vol = volumes[i];
      final double normalizedHeight;
      if (maxVolume > 0) {
        // Map 0 to max volume onto height. Ensure minimum bar height for training days.
        normalizedHeight = vol > 0 
            ? math.max(4.0, (vol / maxVolume) * size.height)
            : 2.0; // 2px indicator for non-training days
      } else {
        normalizedHeight = 2.0;
      }

      final x = i * (barWidth + spacing);
      final y = size.height - normalizedHeight;

      paint.color = vol > 0 ? barColor : emptyBarColor;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, normalizedHeight),
        const Radius.circular(2),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VolumeBarsPainter oldDelegate) {
    return oldDelegate.maxVolume != maxVolume ||
        oldDelegate.volumes != volumes ||
        oldDelegate.barColor != barColor ||
        oldDelegate.emptyBarColor != emptyBarColor;
  }
}

// ==========================================
// CONSISTENCY SCORE RING WIDGET
// ==========================================
class ConsistencyScoreRing extends StatelessWidget {
  final double score; // 0.0 - 1.0

  const ConsistencyScoreRing({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayScore = (score * 100).toInt();

    return Column(
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: CustomPaint(
            painter: _RingPainter(
              progress: score,
              ringColor: const Color(0xFF38BDF8), // Cyan for consistency
              trackColor: Colors.white12,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    '$displayScore%',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'CONSISTENCY',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.white.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.s),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8).withAlpha(25),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: const Color(0xFF38BDF8).withAlpha(60), width: 1),
          ),
          child: Text(
            score >= 0.75 ? 'OPTIMAL' : (score >= 0.5 ? 'MODERATE' : 'LOW'),
            style: const TextStyle(
              color: Color(0xFF38BDF8),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 8;
    const startAngle = -math.pi / 2; // Top
    final sweepAngle = math.pi * 2 * progress.clamp(0.0, 1.0);

    // Draw background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw active arc
    if (progress > 0) {
      final ringPaint = Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.trackColor != trackColor;
  }
}
