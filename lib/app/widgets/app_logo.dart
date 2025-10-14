import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Reusable app logo widget that displays the official app logo (white flash on blue)
class AppLogo extends StatelessWidget {
  /// The size of the square logo widget
  final double size;

  /// Optional corner radius for rounded rectangle presentation
  final double borderRadius;

  /// Optional background color behind the logo (defaults to app primary)
  final Color? backgroundColor;

  const AppLogo({
    super.key,
    this.size = 120,
    this.borderRadius = 20,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? AppColors.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.flash_on,
          size: size * 0.5,
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }
}
