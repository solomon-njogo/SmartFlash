import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// Progress indicator for onboarding flow
/// Implements the Endowed Progress Effect (starts above 0%)
class OnboardingProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const OnboardingProgressIndicator({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.borderDarkLight
            : AppColors.borderLight,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

