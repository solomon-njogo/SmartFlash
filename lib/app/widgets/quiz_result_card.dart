import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/question_model.dart';

class QuizResultCard extends StatelessWidget {
  final QuestionModel question;
  final int selectedAnswerIndex;
  final bool isCorrect;
  final VoidCallback onNext;

  const QuizResultCard({
    super.key,
    required this.question,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Result indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isCorrect ? AppColors.success : AppColors.error,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isCorrect ? 'Correct!' : 'Incorrect',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Question and answer content
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
                    
                    // Answer options with results
                    Text(
                      'Answers:',
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
                          final isCorrectAnswer = index == question.correctAnswerIndex;
                          
                          Color backgroundColor;
                          Color borderColor;
                          IconData? icon;
                          Color iconColor;
                          
                          if (isCorrectAnswer) {
                            backgroundColor = AppColors.success.withOpacity(0.1);
                            borderColor = AppColors.success;
                            icon = Icons.check_circle;
                            iconColor = AppColors.success;
                          } else if (isSelected && !isCorrect) {
                            backgroundColor = AppColors.error.withOpacity(0.1);
                            borderColor = AppColors.error;
                            icon = Icons.cancel;
                            iconColor = AppColors.error;
                          } else {
                            backgroundColor = AppColors.surfaceVariant;
                            borderColor = AppColors.border;
                            icon = null;
                            iconColor = AppColors.textSecondary;
                          }
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                border: Border.all(
                                  color: borderColor,
                                  width: 2,
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
                                      color: borderColor,
                                    ),
                                    child: icon != null
                                        ? Icon(
                                            icon,
                                            color: iconColor,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      question.options[index],
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: isCorrectAnswer || (isSelected && !isCorrect)
                                            ? borderColor
                                            : AppColors.textPrimary,
                                        fontWeight: isCorrectAnswer || (isSelected && !isCorrect)
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Explanation
                    if (question.explanation.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.info.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: AppColors.info,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Explanation',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.info,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.explanation,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
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
          
          const SizedBox(height: 16),
          
          // Next button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Question'),
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
}