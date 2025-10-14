import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/flashcard_review_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/rating_button.dart';
import '../widgets/card_preview.dart';

class StudySessionScreen extends StatefulWidget {
  final String? deckId;
  final String? deckName;

  const StudySessionScreen({
    super.key,
    this.deckId,
    this.deckName,
  });

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlashcardReviewProvider>().initializeReviewSession(
        deckId: widget.deckId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName ?? 'Study Session'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Consumer<FlashcardReviewProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<FlashcardReviewProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      provider.initializeReviewSession(deckId: widget.deckId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.dueFlashcards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Cards Due',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All cards are up to date! Come back later for more reviews.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Back to Decks'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: AppTextStyles.labelMedium,
                        ),
                        Text(
                          '${provider.currentIndex + 1} / ${provider.totalCards}',
                          style: AppTextStyles.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: provider.totalCards > 0 
                          ? (provider.currentIndex + 1) / provider.totalCards 
                          : 0,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ],
                ),
              ),
              
              // Card content
              Expanded(
                child: provider.currentCard != null
                    ? CardPreview(
                        flashcard: provider.currentCard!,
                        isRevealed: provider.isRevealed,
                        onReveal: () => provider.revealAnswer(),
                      )
                    : const SizedBox.shrink(),
              ),
              
              // Rating buttons (only shown when revealed)
              if (provider.isRevealed) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'How well did you remember this?',
                        style: AppTextStyles.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: RatingButton(
                              rating: 1,
                              label: AppConstants.ratingLabels[1]!,
                              description: AppConstants.ratingDescriptions[1]!,
                              color: AppColors.ratingAgain,
                              onPressed: () => _rateCard(provider, 1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RatingButton(
                              rating: 2,
                              label: AppConstants.ratingLabels[2]!,
                              description: AppConstants.ratingDescriptions[2]!,
                              color: AppColors.ratingHard,
                              onPressed: () => _rateCard(provider, 2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RatingButton(
                              rating: 3,
                              label: AppConstants.ratingLabels[3]!,
                              description: AppConstants.ratingDescriptions[3]!,
                              color: AppColors.ratingGood,
                              onPressed: () => _rateCard(provider, 3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RatingButton(
                              rating: 4,
                              label: AppConstants.ratingLabels[4]!,
                              description: AppConstants.ratingDescriptions[4]!,
                              color: AppColors.ratingEasy,
                              onPressed: () => _rateCard(provider, 4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              
              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (provider.hasPreviousCard)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: provider.previousCard,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                        ),
                      ),
                    if (provider.hasPreviousCard) const SizedBox(width: 8),
                    if (provider.hasNextCard)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: provider.nextCard,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _rateCard(FlashcardReviewProvider provider, int rating) async {
    await provider.reviewCard(rating);
    
    if (provider.hasNextCard) {
      provider.nextCard();
    } else {
      // Session completed
      _showSessionCompleteDialog(provider);
    }
  }

  void _showSessionCompleteDialog(FlashcardReviewProvider provider) {
    final stats = provider.getSessionStats();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You reviewed ${stats['reviewedCards']} cards'),
            const SizedBox(height: 8),
            Text('Progress: ${(stats['progress'] * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}