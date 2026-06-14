import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showBorder;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        side: showBorder 
          ? BorderSide(color: Theme.of(context).dividerColor.withAlpha(50)) 
          : BorderSide.none,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSizes.cardPadding),
        child: child,
      ),
    );
  }
}
