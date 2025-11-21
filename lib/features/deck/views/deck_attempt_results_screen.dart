import 'package:flutter/material.dart';
import '../../../data/models/deck_attempt_model.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/widgets/next_review_card.dart';

/// Results screen showing deck attempt performance
class DeckAttemptResultsScreen extends StatelessWidget {
  final DeckAttemptModel attempt;

  const DeckAttemptResultsScreen({
    super.key,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: Text(
          'Study Results',
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Study Session Complete!',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Great job completing all ${attempt.totalCards} flashcards!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Performance stats card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Summary',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStatRow(
                      context,
                      'Cards Studied',
                      '${attempt.cardsStudied}/${attempt.totalCards}',
                      Icons.style,
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      context,
                      'Again',
                      '${attempt.cardsAgain}',
                      Icons.refresh,
                      Colors.red,
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      context,
                      'Hard',
                      '${attempt.cardsHard}',
                      Icons.trending_down,
                      Colors.orange,
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      context,
                      'Good',
                      '${attempt.cardsGood}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      context,
                      'Easy',
                      '${attempt.cardsEasy}',
                      Icons.star,
                      Colors.blue,
                    ),
                    if (attempt.totalTimeSeconds > 0) ...[
                      const Divider(height: 24),
                      _buildStatRow(
                        context,
                        'Time Spent',
                        _formatDuration(Duration(seconds: attempt.totalTimeSeconds)),
                        Icons.timer,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Performance message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getPerformanceColor(attempt.successPercentage)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getPerformanceColor(attempt.successPercentage)
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPerformanceIcon(attempt.successPercentage),
                      color: _getPerformanceColor(attempt.successPercentage),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _getPerformanceMessage(attempt.successPercentage),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Next review card
              NextReviewCard(
                itemId: attempt.deckId,
                userId: attempt.userId,
                isDeck: true,
              ),
              const SizedBox(height: 32),

              // Done button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.done),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, [
    Color? valueColor,
  ]) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          icon,
          color: valueColor ?? colorScheme.onSurfaceVariant,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
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

  Color _getPerformanceColor(double successPercentage) {
    if (successPercentage >= 90) return Colors.green;
    if (successPercentage >= 70) return Colors.blue;
    if (successPercentage >= 50) return Colors.orange;
    return Colors.red;
  }

  IconData _getPerformanceIcon(double successPercentage) {
    if (successPercentage >= 90) return Icons.emoji_events;
    if (successPercentage >= 70) return Icons.thumb_up;
    if (successPercentage >= 50) return Icons.trending_up;
    return Icons.school;
  }

  String _getPerformanceMessage(double successPercentage) {
    if (successPercentage >= 90) {
      return 'Excellent work! You\'ve mastered this deck!';
    } else if (successPercentage >= 70) {
      return 'Great job! Keep practicing to improve further.';
    } else if (successPercentage >= 50) {
      return 'Good effort! Review the cards you found difficult.';
    } else {
      return 'Keep practicing! Review the deck again to improve.';
    }
  }
}
