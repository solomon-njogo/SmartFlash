import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/question_model.dart';

class QuizQuestionCard extends StatelessWidget {
  final QuestionModel question;
  final int? selectedAnswerIndex;
  final Function(int) onAnswerSelected;
  final VoidCallback onSubmit;
  final bool isAnswered;

  const QuizQuestionCard({
    super.key,
    required this.question,
    this.selectedAnswerIndex,
    required this.onAnswerSelected,
    required this.onSubmit,
    required this.isAnswered,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Question status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(question.statusText),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              question.statusText,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Question content
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Text(
                      'Question',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.question,
                      style: AppTextStyles.headlineSmall,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Answer options
                    Text(
                      'Choose an answer:',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Expanded(
                      child: ListView.builder(
                        itemCount: question.options.length,
                        itemBuilder: (context, index) {
                          final isSelected = selectedAnswerIndex == index;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () => onAnswerSelected(index),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.primary.withOpacity(0.1)
                                      : AppColors.surfaceVariant,
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected 
                                            ? AppColors.primary
                                            : AppColors.border,
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        question.options[index],
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: isSelected 
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                          fontWeight: isSelected 
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Submit button
          if (isAnswered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.check),
                label: const Text('Submit Answer'),
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