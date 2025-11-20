import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/ai_generation_provider.dart';
import '../../../core/providers/ai_review_provider.dart';
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
    final reviewProvider = context.read<AIReviewProvider>();
    final generationProvider = context.read<AIGenerationProvider>();
    reviewProvider.startReview();
    
    // Set default deck name
    if (generationProvider.selectedMaterial != null) {
      _deckNameController.text = 
          '${generationProvider.selectedMaterial!.name} - ${generationProvider.generationType == GenerationType.flashcards ? 'Flashcards' : 'Quiz'}';
    }
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
      ),
      body: Consumer2<AIGenerationProvider, AIReviewProvider>(
        builder: (context, generationProvider, reviewProvider, child) {
          if (!generationProvider.hasGeneratedContent) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'No content to review',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Content Preview
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: generationProvider.generationType == GenerationType.flashcards
                      ? _buildFlashcardsPreview(generationProvider, reviewProvider)
                      : _buildQuizPreview(generationProvider, reviewProvider),
                ),
              ),

              // Action Buttons
              _buildActionButtons(generationProvider, reviewProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFlashcardsPreview(
    AIGenerationProvider generationProvider,
    AIReviewProvider reviewProvider,
  ) {
    final flashcards = generationProvider.generatedFlashcards ?? [];

    if (flashcards.isEmpty) {
      return const Center(child: Text('No flashcards generated'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generated Flashcards (${flashcards.length})',
          style: AppTextStyles.titleLarge,
        ),
        const SizedBox(height: 16),
        ...flashcards.asMap().entries.map((entry) {
          final index = entry.key;
          final flashcard = entry.value;
          final isSelected = reviewProvider.selectedFlashcardIndices.contains(index);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            child: InkWell(
              onTap: () => reviewProvider.toggleFlashcardSelection(index),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) => reviewProvider.toggleFlashcardSelection(index),
                        ),
                        Text(
                          'Card ${index + 1}',
                          style: AppTextStyles.titleMedium,
                        ),
                        const Spacer(),
                        Chip(
                          label: Text(flashcard.difficulty.name),
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Front:',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flashcard.frontText,
                      style: AppTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Back:',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flashcard.backText,
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuizPreview(
    AIGenerationProvider generationProvider,
    AIReviewProvider reviewProvider,
  ) {
    final quiz = generationProvider.generatedQuiz;

    if (quiz == null || quiz.questions.isEmpty) {
      return const Center(child: Text('No quiz generated'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          quiz.name,
          style: AppTextStyles.titleLarge,
        ),
        if (quiz.description != null) ...[
          const SizedBox(height: 8),
          Text(
            quiz.description!,
            style: AppTextStyles.bodyMedium,
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Questions (${quiz.questions.length})',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 12),
        ...quiz.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          final isSelected = reviewProvider.selectedQuestionIndices.contains(index);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            child: InkWell(
              onTap: () => reviewProvider.toggleQuestionSelection(index),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) => reviewProvider.toggleQuestionSelection(index),
                        ),
                        Text(
                          'Question ${index + 1}',
                          style: AppTextStyles.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.questionText,
                      style: AppTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    if (question.options.isNotEmpty) ...[
                      Text(
                        'Options:',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...question.options.map((option) {
                        final isCorrect = question.correctAnswers.contains(option);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              if (isCorrect)
                                const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                              if (isCorrect) const SizedBox(width: 8),
                              Expanded(child: Text(option)),
                            ],
                          ),
                        );
                      }),
                    ],
                    if (question.explanation != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Explanation:',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        question.explanation!,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons(
    AIGenerationProvider generationProvider,
    AIReviewProvider reviewProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Deck name input (for flashcards)
          if (generationProvider.generationType == GenerationType.flashcards) ...[
            TextField(
              controller: _deckNameController,
              decoration: const InputDecoration(
                labelText: 'Deck Name',
                border: OutlineInputBorder(),
                hintText: 'Enter deck name',
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Select All / Deselect All
          Row(
            children: [
              TextButton(
                onPressed: () {
                  if (generationProvider.generationType == GenerationType.flashcards) {
                    reviewProvider.selectAllFlashcards();
                  } else {
                    reviewProvider.selectAllQuestions();
                  }
                },
                child: const Text('Select All'),
              ),
              TextButton(
                onPressed: () => reviewProvider.deselectAll(),
                child: const Text('Deselect All'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Accept Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: reviewProvider.status == ReviewStatus.saving
                  ? null
                  : () async {
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Not authenticated')),
                        );
                        return;
                      }

                      bool success = false;
                      if (generationProvider.generationType == GenerationType.flashcards) {
                        success = await reviewProvider.acceptFlashcards(
                          deckId: 'deck_${DateTime.now().millisecondsSinceEpoch}',
                          deckName: _deckNameController.text.isNotEmpty
                              ? _deckNameController.text
                              : 'AI Generated Deck',
                          createdBy: userId,
                        );
                      } else {
                        success = await reviewProvider.acceptQuiz(
                          deckId: 'deck_${DateTime.now().millisecondsSinceEpoch}',
                          createdBy: userId,
                        );
                      }

                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Content saved successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        Navigator.pop(context);
                        Navigator.pop(context); // Go back to generation screen too
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(reviewProvider.status == ReviewStatus.failed
                                ? 'Failed to save content'
                                : 'Saving...'),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: reviewProvider.status == ReviewStatus.saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Accept & Save',
                      style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                    ),
            ),
          ),

          const SizedBox(height: 8),

          // Reject with Feedback
          ExpansionTile(
            title: const Text('Reject & Regenerate'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _feedbackController,
                      decoration: const InputDecoration(
                        labelText: 'Feedback for improvement',
                        border: OutlineInputBorder(),
                        hintText: 'What should be improved?',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: reviewProvider.status == ReviewStatus.regenerating
                            ? null
                            : () async {
                                if (_feedbackController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please provide feedback'),
                                    ),
                                  );
                                  return;
                                }

                                reviewProvider.setFeedback(_feedbackController.text);
                                await reviewProvider.rejectAndRegenerate();

                                if (mounted && reviewProvider.status != ReviewStatus.failed) {
                                  _feedbackController.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Regenerating with your feedback...'),
                                    ),
                                  );
                                }
                              },
                        child: reviewProvider.status == ReviewStatus.regenerating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Regenerate'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

