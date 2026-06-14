import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = variant == AppButtonVariant.primary;
    
    final Widget label = loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          );

    if (isPrimary) {
      return ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
        ),
        child: label,
      );
    } else {
      return TextButton(
        onPressed: loading ? null : onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          foregroundColor: isPrimary ? null : Theme.of(context).colorScheme.primary,
        ),
        child: label,
      );
    }
  }
}
