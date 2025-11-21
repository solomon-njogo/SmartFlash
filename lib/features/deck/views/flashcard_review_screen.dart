import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fsrs/fsrs.dart' hide State;
import 'package:go_router/go_router.dart';
import '../../../core/providers/flashcard_provider.dart';
import '../../../core/providers/flashcard_review_provider.dart';
import '../../../app/app_text_styles.dart';

/// Screen for reviewing/studying flashcards
class FlashcardReviewScreen extends StatefulWidget {
  final String deckId;
  final String? flashcardId; // Optional: start with specific flashcard

  const FlashcardReviewScreen({
    super.key,
    required this.deckId,
    this.flashcardId,
  });

  @override
  State<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends State<FlashcardReviewScreen> {
  bool _isFlipped = false;
  FlashcardReviewProvider? _reviewProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFlashcards();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reviewProvider = Provider.of<FlashcardReviewProvider>(
      context,
      listen: false,
    );
  }

  Future<void> _loadFlashcards() async {
    final flashcardProvider = Provider.of<FlashcardProvider>(
      context,
      listen: false,
    );
    final reviewProvider = Provider.of<FlashcardReviewProvider>(
      context,
      listen: false,
    );

    final flashcards = await flashcardProvider.getFlashcardsByDeckIdAsync(
      widget.deckId,
    );

    if (flashcards.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No flashcards found in this deck')),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    // Filter to specific flashcard if provided, otherwise use all
    final cardsToReview =
        widget.flashcardId != null
            ? flashcards.where((f) => f.id == widget.flashcardId).toList()
            : flashcards;

    await reviewProvider.startReviewSession(cardsToReview, widget.deckId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: const Text('Study Flashcards'),
      ),
      body: Consumer<FlashcardReviewProvider>(
        builder: (context, reviewProvider, child) {
          if (reviewProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reviewProvider.currentCard == null) {
            return _buildCompletionScreen(context, reviewProvider);
          }

          return Column(
            children: [
              // Progress indicator
              _buildProgressBar(context, reviewProvider),

              // Flashcard content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildFlashcardContent(context, reviewProvider),
                  ),
                ),
              ),

              // Navigation buttons (always visible during session)
              if (!reviewProvider.isSessionCompleted)
                _buildNavigationButtons(context, reviewProvider),

              // Action buttons
              _buildActionButtons(context, reviewProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    FlashcardReviewProvider reviewProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = reviewProvider.progress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Card ${reviewProvider.currentCardIndex + 1} of ${reviewProvider.totalCards}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardContent(
    BuildContext context,
    FlashcardReviewProvider reviewProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final card = reviewProvider.currentCard!;

    return GestureDetector(
      onTap: () {
        if (!reviewProvider.showAnswer) {
          reviewProvider.showCardAnswer();
          setState(() {
            _isFlipped = true;
          });
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Container(
          key: ValueKey(_isFlipped),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 300),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!reviewProvider.showAnswer) ...[
                Text(
                  'Front',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  card.frontText,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Tap to reveal answer',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else ...[
                Text(
                  'Back',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  card.backText,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    FlashcardReviewProvider reviewProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!reviewProvider.showAnswer) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              reviewProvider.showCardAnswer();
              setState(() {
                _isFlipped = true;
              });
            },
            icon: const Icon(Icons.visibility),
            label: const Text('Show Answer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          Text(
            'How well did you know this?',
            style: AppTextStyles.titleMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRatingButton(
                  context,
                  'Again',
                  Rating.again,
                  Colors.red,
                  reviewProvider,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRatingButton(
                  context,
                  'Hard',
                  Rating.hard,
                  Colors.orange,
                  reviewProvider,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRatingButton(
                  context,
                  'Good',
                  Rating.good,
                  Colors.green,
                  reviewProvider,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRatingButton(
                  context,
                  'Easy',
                  Rating.easy,
                  Colors.blue,
                  reviewProvider,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingButton(
    BuildContext context,
    String label,
    Rating rating,
    Color color,
    FlashcardReviewProvider reviewProvider,
  ) {
    return ElevatedButton(
      onPressed: () async {
        final currentIndex = reviewProvider.currentCardIndex;
        final totalCards = reviewProvider.totalCards;
        final wasLastCard = !reviewProvider.canGoToNext;
        
        print('📊 [FlashcardReview] Rating card ${currentIndex + 1}/$totalCards');
        print('📊 [FlashcardReview] Rating: $label, wasLastCard: $wasLastCard, canGoToNext: ${reviewProvider.canGoToNext}');

        await reviewProvider.rateCard(rating);
        setState(() {
          _isFlipped = false;
        });

        // Wait a bit for state to update
        await Future.delayed(const Duration(milliseconds: 100));

        print('📊 [FlashcardReview] After rating - isSessionCompleted: ${reviewProvider.isSessionCompleted}, canGoToNext: ${reviewProvider.canGoToNext}, currentCard: ${reviewProvider.currentCard?.id}');

        // If this was the last card, show submission dialog
        // Check if session is completed (all cards reviewed)
        if (wasLastCard) {
          print('📊 [FlashcardReview] This was the last card, checking if session completed...');
          // For the last card, we know it's completed after rating, so show dialog directly
          // The session should be completed if we just rated the last card
          if (reviewProvider.isSessionCompleted || !reviewProvider.canGoToNext) {
            print('📊 [FlashcardReview] Session completed! Showing submission dialog');
            await _showSubmissionDialog(context, reviewProvider);
          } else {
            print('📊 [FlashcardReview] Session not completed yet, waiting...');
            // Wait a bit more and check again
            await Future.delayed(const Duration(milliseconds: 200));
            if (reviewProvider.isSessionCompleted || !reviewProvider.canGoToNext) {
              print('📊 [FlashcardReview] Session completed after wait! Showing submission dialog');
              await _showSubmissionDialog(context, reviewProvider);
            } else {
              print('📊 [FlashcardReview] ERROR: Session still not completed after wait. Forcing dialog...');
              // Force show dialog if we're on the last card
              await _showSubmissionDialog(context, reviewProvider);
            }
          }
        } else if (reviewProvider.canGoToNext) {
          print('📊 [FlashcardReview] Moving to next card');
          // Note: rateCard() already moves to the next card, so no need to call goToNextCard() again
          // Small delay to show the rating was registered
          await Future.delayed(const Duration(milliseconds: 300));
          setState(() {
            _isFlipped = false;
          });
        } else {
          print('📊 [FlashcardReview] No action taken - isSessionCompleted: ${reviewProvider.isSessionCompleted}');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    FlashcardReviewProvider reviewProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed:
                reviewProvider.canGoToPrevious
                    ? () {
                      reviewProvider.goToPreviousCard();
                      setState(() {
                        _isFlipped = reviewProvider.showAnswer;
                      });
                    }
                    : null,
            icon: Icon(Icons.arrow_back),
            tooltip: 'Previous card',
            color: colorScheme.onSurface,
          ),
          Text(
            'Card ${reviewProvider.currentCardIndex + 1} of ${reviewProvider.totalCards}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          IconButton(
            onPressed:
                reviewProvider.canGoToNext
                    ? () {
                      reviewProvider.goToNextCard();
                      setState(() {
                        _isFlipped = reviewProvider.showAnswer;
                      });
                    }
                    : null,
            icon: Icon(Icons.arrow_forward),
            tooltip: 'Next card',
            color: colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  Future<void> _showSubmissionDialog(
    BuildContext context,
    FlashcardReviewProvider reviewProvider,
  ) async {
    print('📊 [FlashcardReview] _showSubmissionDialog called');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final attempt = reviewProvider.currentAttempt;

    if (attempt == null) {
      print('📊 [FlashcardReview] Cannot show dialog: attempt is null');
      return;
    }
    
    print('📊 [FlashcardReview] Showing submission dialog for attempt: ${attempt.id}');

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Complete Study Session?',
              style: AppTextStyles.titleLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'ve reviewed all ${attempt.totalCards} flashcards.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                        context,
                        'Again',
                        '${attempt.cardsAgain}',
                        Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        context,
                        'Hard',
                        '${attempt.cardsHard}',
                        Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        context,
                        'Good',
                        '${attempt.cardsGood}',
                        Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        context,
                        'Easy',
                        '${attempt.cardsEasy}',
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Submit your results?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Review Again',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Save attempt results
      await reviewProvider.saveAttemptResults();

      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Navigate to results screen using GoRouter
        context.pushReplacement(
          '/deck-attempt-results',
          extra: reviewProvider.currentAttempt!,
        );
      }
    }
  }

  Widget _buildCompletionScreen(
    BuildContext context,
    FlashcardReviewProvider reviewProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final attempt = reviewProvider.currentAttempt;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'Review Complete!',
              style: AppTextStyles.headlineMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve reviewed all flashcards in this deck.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (attempt != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                      context,
                      'Cards Studied',
                      '${attempt.cardsStudied}/${attempt.totalCards}',
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      context,
                      'Again',
                      '${attempt.cardsAgain}',
                      Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      context,
                      'Hard',
                      '${attempt.cardsHard}',
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      context,
                      'Good',
                      '${attempt.cardsGood}',
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      context,
                      'Easy',
                      '${attempt.cardsEasy}',
                      Colors.blue,
                    ),
                    if (attempt.totalTimeSeconds > 0) ...[
                      const SizedBox(height: 8),
                      _buildStatRow(
                        context,
                        'Time Spent',
                        _formatDuration(
                          Duration(seconds: attempt.totalTimeSeconds),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.done),
              label: const Text('Done'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value, [
    Color? valueColor,
  ]) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor ?? colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  @override
  void dispose() {
    // Abandon attempt if user exits before viewing summary (i.e., before completing all cards)
    // Use saved provider reference instead of accessing through context (which is unsafe in dispose)
    if (_reviewProvider != null) {
      // Only abandon if attempt exists, is in progress, and session is not completed
      if (_reviewProvider!.currentAttempt != null &&
          _reviewProvider!.currentAttempt!.isInProgress &&
          !_reviewProvider!.isSessionCompleted) {
        _reviewProvider!.abandonAttempt();
      }
    }
    super.dispose();
  }
}
