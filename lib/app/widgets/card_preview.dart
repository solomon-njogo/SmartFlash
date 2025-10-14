import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/flashcard_model.dart';

class CardPreview extends StatelessWidget {
  final FlashcardModel flashcard;
  final bool isRevealed;
  final VoidCallback onReveal;

  const CardPreview({
    super.key,
    required this.flashcard,
    required this.isRevealed,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Card status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(flashcard.statusText),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              flashcard.statusText,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Card content
          Expanded(
            child: Card(
              elevation: 4,
              shadowColor: AppColors.shadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Front side
                    Text(
                      'Front',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      flashcard.front,
                      style: AppTextStyles.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    
                    if (isRevealed) ...[
                      const SizedBox(height: 32),
                      Container(
                        height: 1,
                        color: AppColors.border,
                      ),
                      const SizedBox(height: 32),
                      
                      // Back side
                      Text(
                        'Back',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        flashcard.back,
                        style: AppTextStyles.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Reveal button
          if (!isRevealed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onReveal,
                icon: const Icon(Icons.visibility),
                label: const Text('Reveal Answer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return AppColors.cardNew;
      case 'learning':
        return AppColors.cardLearning;
      case 'review':
        return AppColors.cardReview;
      case 'relearning':
        return AppColors.cardRelearning;
      default:
        return AppColors.textSecondary;
    }
  }
}