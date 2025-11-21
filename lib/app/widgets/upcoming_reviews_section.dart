import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/app_text_styles.dart';
import '../../app/theme/app_colors.dart';
import '../../app/router.dart';
import '../../core/services/deck_review_schedule_service.dart';
import '../../core/services/quiz_review_schedule_service.dart';

/// Widget to display upcoming reviews section
class UpcomingReviewsSection extends StatefulWidget {
  final String userId;

  const UpcomingReviewsSection({super.key, required this.userId});

  @override
  State<UpcomingReviewsSection> createState() => _UpcomingReviewsSectionState();
}

class _UpcomingReviewsSectionState extends State<UpcomingReviewsSection> {
  final DeckReviewScheduleService _deckService = DeckReviewScheduleService();
  final QuizReviewScheduleService _quizService = QuizReviewScheduleService();

  List<Map<String, dynamic>> _upcomingReviews = [];
  bool _isLoading = true;
  bool _isExpanded = true;
  bool _hasLoadedOnce = false;
  DateTime? _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    _loadUpcomingReviews();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when widget becomes visible again (e.g., returning from review)
    // Only refresh if we've loaded once and it's been at least 1 second since last refresh
    if (_hasLoadedOnce && mounted) {
      final now = DateTime.now();
      if (_lastRefreshTime == null ||
          now.difference(_lastRefreshTime!).inSeconds > 1) {
        _loadUpcomingReviews();
      }
    }
  }

  /// Public method to refresh upcoming reviews
  Future<void> refresh() async {
    await _loadUpcomingReviews();
  }

  Future<void> _loadUpcomingReviews() async {
    setState(() => _isLoading = true);

    try {
      final deckReviews = await _deckService.getUpcomingDeckReviews(
        widget.userId,
        limit: 5,
      );
      final quizReviews = await _quizService.getUpcomingQuizReviews(
        widget.userId,
        limit: 5,
      );

      // Combine and format reviews
      final List<Map<String, dynamic>> allReviews = [];

      for (final review in deckReviews) {
        allReviews.add({...review, 'type': 'deck'});
      }

      for (final review in quizReviews) {
        allReviews.add({...review, 'type': 'quiz'});
      }

      // Sort by next_review_date
      allReviews.sort((a, b) {
        final dateA = DateTime.parse(a['next_review_date'] as String);
        final dateB = DateTime.parse(b['next_review_date'] as String);
        return dateA.compareTo(dateB);
      });

      // Take top 5
      setState(() {
        _upcomingReviews = allReviews.take(5).toList();
        _isLoading = false;
        _hasLoadedOnce = true;
        _lastRefreshTime = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasLoadedOnce = true;
        _lastRefreshTime = DateTime.now();
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
      return DateFormat('MMM d').format(date);
    }
  }

  void _onReviewTap(Map<String, dynamic> review) {
    if (review['type'] == 'deck') {
      final deckId = review['deck_id'] as String;
      // Navigate directly to flashcard review session
      AppNavigation.goFlashcardReview(context, deckId: deckId);
    } else if (review['type'] == 'quiz') {
      final quizId = review['quiz_id'] as String;
      // Navigate directly to quiz taking screen (starts from question one)
      AppNavigation.goQuizTaking(context, quizId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_upcomingReviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Reviews',
                style: AppTextStyles.titleLarge.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: colorScheme.onBackground,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                tooltip: _isExpanded ? 'Collapse' : 'Expand',
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child:
              _isExpanded
                  ? SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _upcomingReviews.length,
                      itemBuilder: (context, index) {
                        final review = _upcomingReviews[index];
                        return _ReviewCard(
                          review: review,
                          onTap: () => _onReviewTap(review),
                          formatDate: _formatDate,
                        );
                      },
                    ),
                  )
                  : const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final VoidCallback onTap;
  final String Function(DateTime) formatDate;

  const _ReviewCard({
    required this.review,
    required this.onTap,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final nextReviewDateStr = review['next_review_date'] as String?;
    if (nextReviewDateStr == null) return const SizedBox.shrink();

    final nextReviewDate = DateTime.parse(nextReviewDateStr);
    final isOverdue = nextReviewDate.isBefore(DateTime.now());
    final isToday =
        nextReviewDate.year == DateTime.now().year &&
        nextReviewDate.month == DateTime.now().month &&
        nextReviewDate.day == DateTime.now().day;

    final type = review['type'] as String;
    final isDeck = type == 'deck';

    final itemData =
        isDeck
            ? review['decks'] as Map<String, dynamic>?
            : review['quizzes'] as Map<String, dynamic>?;

    if (itemData == null) return const SizedBox.shrink();

    final name = itemData['name'] as String? ?? 'Untitled';
    final dueCount =
        isDeck
            ? (review['cards_due_count'] as int? ?? 0)
            : (review['questions_due_count'] as int? ?? 0);

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isOverdue
                      ? (isDark
                          ? AppColors.errorDark.withOpacity(0.2)
                          : AppColors.error.withOpacity(0.1))
                      : isToday
                      ? (isDark
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.success.withOpacity(0.1))
                      : colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isOverdue
                        ? AppColors.error.withOpacity(0.3)
                        : isToday
                        ? AppColors.success.withOpacity(0.3)
                        : colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isDeck
                                ? colorScheme.primary.withOpacity(0.1)
                                : colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isDeck ? Icons.style : Icons.quiz,
                        size: 20,
                        color:
                            isDeck
                                ? colorScheme.primary
                                : colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isOverdue
                                ? AppColors.error.withOpacity(0.2)
                                : isToday
                                ? AppColors.success.withOpacity(0.2)
                                : colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formatDate(nextReviewDate),
                        style: AppTextStyles.bodySmall.copyWith(
                          color:
                              isOverdue
                                  ? AppColors.error
                                  : isToday
                                  ? AppColors.success
                                  : colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (dueCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$dueCount ${isDeck ? 'cards' : 'questions'}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
