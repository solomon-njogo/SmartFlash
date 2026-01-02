import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/app_text_styles.dart';

/// Widget for displaying quiz questions with interactive options
class QuizQuestionWidget extends StatelessWidget {
  final String question;
  final String? subtitle;
  final List<String> options;
  final List<String> selectedOptions;
  final bool isMultiSelect;
  final Function(String) onOptionSelected;
  final Function(String)? onOptionDeselected;

  const QuizQuestionWidget({
    super.key,
    required this.question,
    this.subtitle,
    required this.options,
    required this.selectedOptions,
    this.isMultiSelect = false,
    required this.onOptionSelected,
    this.onOptionDeselected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question text
        Text(
          question,
          style: AppTextStyles.headlineSmall.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 40),
        // Options
        ...options.map((option) => _buildOptionChip(
              context,
              option,
              selectedOptions.contains(option),
              colorScheme,
              isDark,
            )),
      ],
    );
  }

  Widget _buildOptionChip(
    BuildContext context,
    String option,
    bool isSelected,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            if (isSelected && isMultiSelect) {
              // Only allow deselection for multi-select questions
              onOptionDeselected?.call(option);
            } else if (!isSelected) {
              // For single-select, selecting a new option will replace the old one
              // The parent widget should handle clearing previous selection
              onOptionSelected(option);
            }
            // For single-select, if already selected, do nothing (or parent can handle)
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : isDark
                        ? AppColors.borderDarkTheme
                        : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

