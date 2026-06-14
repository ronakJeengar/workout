import 'package:flutter/material.dart';
import '../../../../shared/constants/app_sizes.dart';
import '../../../../core/theme.dart';
import '../../domain/coach_recommendation.dart';

class CoachCard extends StatefulWidget {
  final CoachRecommendation recommendation;
  final VoidCallback? onTap;

  const CoachCard({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  @override
  State<CoachCard> createState() => _CoachCardState();
}

class _CoachCardState extends State<CoachCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (widget.recommendation.type) {
      case CoachRecommendationType.insight:
        return Icons.insights_rounded;
      case CoachRecommendationType.warning:
        return Icons.warning_amber_rounded;
      case CoachRecommendationType.suggestion:
        return Icons.psychology_rounded;
      case CoachRecommendationType.achievement:
        return Icons.emoji_events_rounded;
    }
  }

  Color _getTypeColor() {
    switch (widget.recommendation.type) {
      case CoachRecommendationType.warning:
        return const Color(0xFFEF4444); // Red
      case CoachRecommendationType.insight:
        return AppTheme.primaryLime;
      case CoachRecommendationType.suggestion:
        return const Color(0xFF38BDF8); // Cyan
      case CoachRecommendationType.achievement:
        return const Color(0xFFFBBF24); // Amber
    }
  }

  LinearGradient _getGradient() {
    // Elegant, premium gradient combinations based on recommendation intensity
    switch (widget.recommendation.intensity) {
      case RecommendationIntensity.low:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B), // Slate 800
            Color(0xFF0F172A), // Slate 900
          ],
        );
      case RecommendationIntensity.medium:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF311042), // Dark violet
            Color(0xFF15051E), // Extremely dark violet
          ],
        );
      case RecommendationIntensity.high:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF362E00), // Dark Lime tint
            Color(0xFF1A1700), // Darker Lime tint
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = _getTypeColor();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.m),
          decoration: BoxDecoration(
            gradient: _getGradient(),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(
              color: iconColor.withAlpha(40),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.cardPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.s),
                      decoration: BoxDecoration(
                        color: iconColor.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIcon(),
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSizes.cardPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.recommendation.title.toUpperCase(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    letterSpacing: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.s,
                                  vertical: AppSizes.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: iconColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.recommendation.intensity.name.toUpperCase(),
                                  style: TextStyle(
                                    color: iconColor,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            widget.recommendation.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withAlpha(200),
                              height: 1.4,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
