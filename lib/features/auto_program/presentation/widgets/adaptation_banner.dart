import 'package:flutter/material.dart';
import '../../../../shared/constants/app_sizes.dart';
import '../../../../core/theme.dart';

class AdaptationBanner extends StatelessWidget {
  final String adaptationReason;

  const AdaptationBanner({
    super.key,
    required this.adaptationReason,
  });

  IconData _getIcon(String reason) {
    final lower = reason.toLowerCase();
    if (lower.contains('fatigue') || lower.contains('critical') || lower.contains('overtraining')) {
      return Icons.warning_amber_rounded;
    }
    if (lower.contains('overload') || lower.contains('progression') || lower.contains('increased')) {
      return Icons.rocket_launch_rounded;
    }
    if (lower.contains('plateau') || lower.contains('swap') || lower.contains('variation')) {
      return Icons.swap_horizontal_circle_outlined;
    }
    return Icons.info_outline;
  }

  Color _getColor(String reason) {
    final lower = reason.toLowerCase();
    if (lower.contains('fatigue') || lower.contains('critical') || lower.contains('overtraining')) {
      return const Color(0xFFEF4444); // Red
    }
    if (lower.contains('overload') || lower.contains('progression') || lower.contains('increased')) {
      return AppTheme.primaryLime;
    }
    if (lower.contains('plateau') || lower.contains('swap') || lower.contains('variation')) {
      return const Color(0xFF38BDF8); // Cyan
    }
    return Colors.white54;
  }

  @override
  Widget build(BuildContext context) {
    final lines = adaptationReason
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: lines.map((line) {
        final color = _getColor(line);
        final icon = _getIcon(line);

        return Container(
          margin: const EdgeInsets.only(bottom: AppSizes.s),
          padding: const EdgeInsets.all(AppSizes.m),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(color: color.withAlpha(50), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: AppSizes.m),
              Expanded(
                child: Text(
                  line,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
