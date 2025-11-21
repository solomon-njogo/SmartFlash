import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/ai_generation_provider.dart';
import '../../../core/providers/ai_review_provider.dart';
import '../../../core/providers/deck_provider.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen for reviewing AI-generated content before accepting
class AIContentReviewScreen extends StatefulWidget {
  const AIContentReviewScreen({super.key});

  @override
  State<AIContentReviewScreen> createState() => _AIContentReviewScreenState();
}

class _AIContentReviewScreenState extends State<AIContentReviewScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _deckNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reviewProvider = context.read<AIReviewProvider>();
      final generationProvider = context.read<AIGenerationProvider>();

      // Set the generation provider so review provider can access the generated content
      reviewProvider.setGenerationProvider(generationProvider);
      reviewProvider.startReview();

      // Set default deck name
      if (generationProvider.selectedMaterial != null) {
        _deckNameController.text =
            '${generationProvider.selectedMaterial!.name} - ${generationProvider.generationType == GenerationType.flashcards ? 'Flashcards' : 'Quiz'}';
      }
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _deckNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Generated Content'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Consumer2<AIGenerationProvider, AIReviewProvider>(
        builder: (context, generationProvider, reviewProvider, child) {
          final theme = Theme.of(context);

          if (!generationProvider.hasGeneratedContent) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No content to review',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please generate content first',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Content Preview
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child:
                      generationProvider.generationType ==
                              GenerationType.flashcards
                          ? _buildFlashcardsPreview(
                            generationProvider,
                            reviewProvider,
                            context,
                          )
                          : _buildQuizPreview(
                            generationProvider,
                            reviewProvider,
                            context,
                          ),
                ),
              ),

              // Action Buttons
              _buildActionButtons(generationProvider, reviewProvider, context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFlashcardsPreview(
    AIGenerationProvider generationProvider,
    AIReviewProvider reviewProvider,
    BuildContext context,
  ) {
    final flashcards = generationProvider.generatedFlashcards ?? [];
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    if (flashcards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No flashcards generated',
              style: AppTextStyles.titleMedium.copyWith(color: textColor),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.style_outlined, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Generated Flashcards',
                style: AppTextStyles.titleLarge.copyWith(color: textColor),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${flashcards.length}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...flashcards.asMap().entries.map((entry) {
          final index = entry.key;
          final flashcard = entry.value;
          final isSelected = reviewProvider.selectedFlashcardIndices.contains(
            index,
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.primary.withOpacity(isDark ? 0.2 : 0.1)
                      : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected
                        ? AppColors.primary
                        : theme.colorScheme.outline.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => reviewProvider.toggleFlashcardSelection(index),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged:
                                (_) => reviewProvider.toggleFlashcardSelection(
                                  index,
                                ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Card ${index + 1}',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              flashcard.difficulty.name.toUpperCase(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.question_mark_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Front',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              flashcard.frontText,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 18,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Back',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              flashcard.backText,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: textColor,
                                height: 1.5,
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
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQuizPreview(
    AIGenerationProvider generationProvider,
    AIReviewProvider reviewProvider,
    BuildContext context,
  ) {
    final quiz = generationProvider.generatedQuiz;
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;

    if (quiz == null || quiz.questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No quiz generated',
              style: AppTextStyles.titleMedium.copyWith(color: textColor),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.quiz, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      quiz.name,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (quiz.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  quiz.description!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Questions',
                style: AppTextStyles.titleMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${quiz.questions.length}',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...quiz.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          final isSelected = reviewProvider.selectedQuestionIndices.contains(
            index,
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.primary.withOpacity(isDark ? 0.2 : 0.1)
                      : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected
                        ? AppColors.primary
                        : theme.colorScheme.outline.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => reviewProvider.toggleQuestionSelection(index),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged:
                                (_) => reviewProvider.toggleQuestionSelection(
                                  index,
                                ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Question ${index + 1}',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          question.questionText,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: textColor,
                            height: 1.5,
                          ),
                        ),
                      ),
                      if (question.options.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Options',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...question.options.map((option) {
                          final isCorrect = question.correctAnswers.contains(
                            option,
                          );
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color:
                                  isCorrect
                                      ? AppColors.success.withOpacity(0.15)
                                      : theme.colorScheme.surfaceVariant
                                          .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isCorrect
                                        ? AppColors.success.withOpacity(0.3)
                                        : theme.colorScheme.outline.withOpacity(
                                          0.2,
                                        ),
                                width: isCorrect ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (isCorrect)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                if (isCorrect) const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: textColor,
                                      height: 1.5,
                                      fontWeight:
                                          isCorrect
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      if (question.explanation != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.info.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    size: 18,
                                    color: AppColors.info,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Explanation',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.info,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                question.explanation!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: textColor,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons(
    AIGenerationProvider generationProvider,
    AIReviewProvider reviewProvider,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSaving = reviewProvider.status == ReviewStatus.saving;
    final isRegenerating = reviewProvider.status == ReviewStatus.regenerating;
    final selectedCount =
        generationProvider.generationType == GenerationType.flashcards
            ? reviewProvider.selectedFlashcardIndices.length
            : reviewProvider.selectedQuestionIndices.length;
    final totalCount =
        generationProvider.generationType == GenerationType.flashcards
            ? (generationProvider.generatedFlashcards?.length ?? 0)
            : (generationProvider.generatedQuiz?.questions.length ?? 0);

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Deck name input (only for flashcards)
            if (generationProvider.generationType ==
                GenerationType.flashcards) ...[
              TextField(
                controller: _deckNameController,
                decoration: InputDecoration(
                  labelText: 'Deck Name',
                  hintText: 'Enter deck name',
                  prefixIcon: const Icon(Icons.folder_outlined),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                ),
                enabled: !isSaving && !isRegenerating,
              ),
              const SizedBox(height: 16),
            ],

            // Selection summary and controls
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selectedCount == 0
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            selectedCount == 0
                                ? AppColors.success.withOpacity(0.3)
                                : AppColors.info.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selectedCount == 0
                              ? Icons.check_circle_outline
                              : Icons.autorenew,
                          size: 18,
                          color:
                              selectedCount == 0
                                  ? AppColors.success
                                  : AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            selectedCount == 0
                                ? 'All $totalCount items will be saved'
                                : '$selectedCount of $totalCount selected for regeneration',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed:
                      (isSaving || isRegenerating)
                          ? null
                          : () {
                            if (generationProvider.generationType ==
                                GenerationType.flashcards) {
                              reviewProvider.selectAllFlashcards();
                            } else {
                              reviewProvider.selectAllQuestions();
                            }
                          },
                  icon: const Icon(Icons.select_all, size: 20),
                  label: const Text('All'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed:
                      (isSaving || isRegenerating)
                          ? null
                          : () => reviewProvider.deselectAll(),
                  icon: const Icon(Icons.deselect, size: 20),
                  label: const Text('None'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Action Button - Save all if nothing selected, Regenerate if items selected
            SizedBox(
              width: double.infinity,
              child:
                  selectedCount == 0
                      ? ElevatedButton.icon(
                        onPressed:
                            (isSaving || isRegenerating)
                                ? null
                                : () async {
                                  if (isSaving) return;

                                  try {
                                    final userId =
                                        Supabase
                                            .instance
                                            .client
                                            .auth
                                            .currentUser
                                            ?.id;
                                    if (userId == null) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please sign in to continue',
                                            ),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    bool success = false;
                                    const uuid = Uuid();
                                    if (generationProvider.generationType ==
                                        GenerationType.flashcards) {
                                      final courseId =
                                          generationProvider.courseId ??
                                          generationProvider
                                              .selectedMaterial
                                              ?.courseId;
                                      success = await reviewProvider
                                          .acceptFlashcards(
                                            deckId: uuid.v4(),
                                            deckName:
                                                _deckNameController
                                                        .text
                                                        .isNotEmpty
                                                    ? _deckNameController.text
                                                    : 'AI Generated Deck',
                                            createdBy: userId,
                                            courseId: courseId,
                                          );
                                    } else {
                                      success = await reviewProvider.acceptQuiz(
                                        createdBy: userId,
                                      );
                                    }

                                    if (success && mounted) {
                                      if (generationProvider.generationType ==
                                          GenerationType.flashcards) {
                                        final deckProvider =
                                            Provider.of<DeckProvider>(
                                              context,
                                              listen: false,
                                            );
                                        await deckProvider.refreshDecks();
                                      }

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  generationProvider
                                                              .generationType ==
                                                          GenerationType
                                                              .flashcards
                                                      ? 'Deck created successfully!'
                                                      : 'Quiz created successfully!',
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: AppColors.success,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    } else if (mounted) {
                                      if (reviewProvider.status ==
                                          ReviewStatus.failed) {
                                        final errorMessage =
                                            reviewProvider.error ??
                                            'Failed to save content. Please try again.';
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(
                                                  Icons.error_outline,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(errorMessage),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: AppColors.error,
                                            duration: const Duration(
                                              seconds: 5,
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.error_outline,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'An error occurred: ${e.toString()}',
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: AppColors.error,
                                          duration: const Duration(seconds: 5),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                        icon:
                            isSaving
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.check_circle_outline),
                        label: Text(
                          isSaving
                              ? 'Saving...'
                              : generationProvider.generationType ==
                                  GenerationType.flashcards
                              ? 'Create Deck'
                              : 'Create Quiz',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      )
                      : OutlinedButton.icon(
                        onPressed:
                            (isSaving || isRegenerating)
                                ? null
                                : () async {
                                  // Show feedback dialog for regeneration
                                  final feedbackController =
                                      TextEditingController();
                                  final feedback = await showDialog<String>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text(
                                            'Regenerate Selected Items',
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'What should be improved for the selected ${generationProvider.generationType == GenerationType.flashcards ? "flashcards" : "questions"}?',
                                                style: AppTextStyles.bodyMedium,
                                              ),
                                              const SizedBox(height: 16),
                                              TextField(
                                                controller: feedbackController,
                                                autofocus: true,
                                                decoration: InputDecoration(
                                                  labelText: 'Feedback',
                                                  hintText:
                                                      'Provide feedback to improve the selected items...',
                                                  border:
                                                      const OutlineInputBorder(),
                                                ),
                                                maxLines: 3,
                                                onSubmitted: (value) {
                                                  Navigator.pop(
                                                    context,
                                                    value.trim().isNotEmpty
                                                        ? value.trim()
                                                        : 'Improve the selected items',
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                final feedbackText =
                                                    feedbackController.text
                                                        .trim();
                                                Navigator.pop(
                                                  context,
                                                  feedbackText.isNotEmpty
                                                      ? feedbackText
                                                      : 'Improve the selected items',
                                                );
                                              },
                                              child: const Text('Regenerate'),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (feedback == null || feedback.isEmpty)
                                    return;

                                  reviewProvider.setFeedback(feedback);
                                  await reviewProvider.rejectAndRegenerate();

                                  if (mounted &&
                                      reviewProvider.status !=
                                          ReviewStatus.failed) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(
                                              Icons.autorenew,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Regenerating selected items...',
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: AppColors.info,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                        icon:
                            isRegenerating
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.autorenew),
                        label: Text(
                          isRegenerating
                              ? 'Regenerating...'
                              : 'Regenerate Selected ($selectedCount)',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
            ),

            const SizedBox(height: 12),

            // Reject with Feedback
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(
                0.3,
              ),
              collapsedBackgroundColor: theme.colorScheme.surfaceVariant
                  .withOpacity(0.3),
              title: Row(
                children: [
                  Icon(
                    Icons.refresh,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Regenerate with Feedback',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              children: [
                TextField(
                  controller: _feedbackController,
                  decoration: InputDecoration(
                    labelText: 'What should be improved?',
                    hintText:
                        'Provide feedback to help improve the generated content...',
                    prefixIcon: const Icon(Icons.feedback_outlined),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  maxLines: 3,
                  enabled: !isSaving && !isRegenerating,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        (isSaving || isRegenerating)
                            ? null
                            : () async {
                              if (_feedbackController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Please provide feedback',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                                return;
                              }

                              reviewProvider.setFeedback(
                                _feedbackController.text.trim(),
                              );
                              await reviewProvider.rejectAndRegenerate();

                              if (mounted &&
                                  reviewProvider.status !=
                                      ReviewStatus.failed) {
                                _feedbackController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(
                                          Icons.autorenew,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Regenerating with your feedback...',
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppColors.info,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                    icon:
                        isRegenerating
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.autorenew),
                    label: Text(
                      isRegenerating ? 'Regenerating...' : 'Regenerate',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
