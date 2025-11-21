import 'package:flutter/material.dart';
import '../../../app/app_text_styles.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/deck_model.dart';
import '../../../data/models/flashcard_model.dart';
import '../../../data/models/quiz_model.dart';

/// Widget for displaying a search result item
class SearchResultItem extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onTap;

  const SearchResultItem({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (item is CourseModel) {
      return _buildCourseItem(context, item as CourseModel, colorScheme);
    } else if (item is DeckModel) {
      return _buildDeckItem(context, item as DeckModel, colorScheme);
    } else if (item is QuizModel) {
      return _buildQuizItem(context, item as QuizModel, colorScheme);
    } else if (item is FlashcardModel) {
      return _buildFlashcardItem(context, item as FlashcardModel, colorScheme);
    }

    return const SizedBox.shrink();
  }

  Widget _buildCourseItem(
    BuildContext context,
    CourseModel course,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(course.colorValue).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(course.iconName ?? 'folder'),
                  color: Color(course.colorValue),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (course.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        course.description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildChip(
                          context,
                          'Course',
                          colorScheme.primary,
                          colorScheme,
                        ),
                        if (course.totalDecks > 0) ...[
                          const SizedBox(width: 8),
                          _buildChip(
                            context,
                            '${course.totalDecks} ${course.totalDecks == 1 ? 'deck' : 'decks'}',
                            colorScheme.secondary,
                            colorScheme,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeckItem(
    BuildContext context,
    DeckModel deck,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.library_books,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (deck.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        deck.description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildChip(
                          context,
                          'Deck',
                          colorScheme.secondary,
                          colorScheme,
                        ),
                        if (deck.totalCards > 0) ...[
                          const SizedBox(width: 8),
                          _buildChip(
                            context,
                            '${deck.totalCards} ${deck.totalCards == 1 ? 'card' : 'cards'}',
                            colorScheme.tertiary,
                            colorScheme,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizItem(
    BuildContext context,
    QuizModel quiz,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.quiz,
                  color: colorScheme.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (quiz.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        quiz.description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildChip(
                          context,
                          'Quiz',
                          colorScheme.secondary,
                          colorScheme,
                        ),
                        if (quiz.questionIds.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _buildChip(
                            context,
                            '${quiz.questionIds.length} ${quiz.questionIds.length == 1 ? 'question' : 'questions'}',
                            colorScheme.tertiary,
                            colorScheme,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlashcardItem(
    BuildContext context,
    FlashcardModel flashcard,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.credit_card,
                  color: colorScheme.tertiary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flashcard.frontText,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flashcard.backText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildChip(
                      context,
                      'Flashcard',
                      colorScheme.tertiary,
                      colorScheme,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'folder':
        return Icons.folder;
      case 'book':
        return Icons.book;
      case 'school':
        return Icons.school;
      case 'science':
        return Icons.science;
      case 'calculate':
        return Icons.calculate;
      case 'language':
        return Icons.language;
      case 'history':
        return Icons.history;
      case 'palette':
        return Icons.palette;
      default:
        return Icons.folder;
    }
  }
}

