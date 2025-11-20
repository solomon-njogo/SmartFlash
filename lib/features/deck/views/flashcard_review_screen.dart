import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fsrs/fsrs.dart' hide State;
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFlashcards();
    });
  }

  Future<void> _loadFlashcards() async {
    final flashcardProvider = Provider.of<FlashcardProvider>(context, listen: false);
    final reviewProvider = Provider.of<FlashcardReviewProvider>(context, listen: false);

    final flashcards = await flashcardProvider.getFlashcardsByDeckIdAsync(widget.deckId);
    
    if (flashcards.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No flashcards found in this deck'),
          ),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    // Filter to specific flashcard if provided, otherwise use all
    final cardsToReview = widget.flashcardId != null
        ? flashcards.where((f) => f.id == widget.flashcardId).toList()
        : flashcards;

    reviewProvider.startReviewSession(cardsToReview);
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

              // Action buttons
              _buildActionButtons(context, reviewProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, FlashcardReviewProvider reviewProvider) {
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
          return ScaleTransition(
            scale: animation,
            child: child,
          );
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
        await reviewProvider.rateCard(rating);
        setState(() {
          _isFlipped = false;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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

  Widget _buildCompletionScreen(
    BuildContext context,
    FlashcardReviewProvider reviewProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
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
}

