import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/app_text_styles.dart';
import '../../app/theme/app_colors.dart';
import '../../core/services/deck_review_schedule_service.dart';
import '../../core/services/quiz_review_schedule_service.dart';

/// Widget to display next review date for a deck or quiz
class NextReviewCard extends StatefulWidget {
  final String itemId;
  final String userId;
  final bool isDeck;

  const NextReviewCard({
    super.key,
    required this.itemId,
    required this.userId,
    required this.isDeck,
  });

  @override
  State<NextReviewCard> createState() => _NextReviewCardState();
}

class _NextReviewCardState extends State<NextReviewCard> {
  DateTime? _nextReviewDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNextReviewDate();
  }

  Future<void> _loadNextReviewDate() async {
    setState(() => _isLoading = true);

    try {
      DateTime? nextReview;
      if (widget.isDeck) {
        final service = DeckReviewScheduleService();
        nextReview = await service.getDeckNextReviewDate(
          widget.itemId,
          widget.userId,
        );
      } else {
        final service = QuizReviewScheduleService();
        nextReview = await service.getQuizNextReviewDate(
          widget.itemId,
          widget.userId,
        );
      }

      setState(() {
        _nextReviewDate = nextReview;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reviewDate = DateTime(date.year, date.month, date.day);
    final difference = reviewDate.difference(today).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return 'In $difference days';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading || _nextReviewDate == null) {
      return const SizedBox.shrink();
    }

    final isOverdue = _nextReviewDate!.isBefore(DateTime.now());
    final isToday = _nextReviewDate!.year == DateTime.now().year &&
        _nextReviewDate!.month == DateTime.now().month &&
        _nextReviewDate!.day == DateTime.now().day;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverdue
            ? (isDark
                ? AppColors.errorDark.withOpacity(0.2)
                : AppColors.error.withOpacity(0.1))
            : isToday
                ? (isDark
                    ? AppColors.success.withOpacity(0.2)
                    : AppColors.success.withOpacity(0.1))
                : colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? AppColors.error.withOpacity(0.3)
              : isToday
                  ? AppColors.success.withOpacity(0.3)
                  : colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOverdue
                  ? AppColors.error.withOpacity(0.2)
                  : isToday
                      ? AppColors.success.withOpacity(0.2)
                      : colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.schedule,
              color: isOverdue
                  ? AppColors.error
                  : isToday
                      ? AppColors.success
                      : colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Review',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(_nextReviewDate!),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isOverdue
                        ? AppColors.error
                        : isToday
                            ? AppColors.success
                            : colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isOverdue && !isToday) ...[
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('EEEE, MMM d').format(_nextReviewDate!),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

