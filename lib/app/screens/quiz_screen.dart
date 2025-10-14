import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/question_review_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../widgets/quiz_question_card.dart';
import '../widgets/quiz_result_card.dart';

class QuizScreen extends StatefulWidget {
  final String? quizId;
  final String? quizName;

  const QuizScreen({
    super.key,
    this.quizId,
    this.quizName,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestionReviewProvider>().initializeQuizSession(
        quizId: widget.quizId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizName ?? 'Quiz'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Consumer<QuestionReviewProvider>(
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
      body: Consumer<QuestionReviewProvider>(
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
                      provider.initializeQuizSession(quizId: widget.quizId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.dueQuestions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 64,
                    color: AppColors.info,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Questions Available',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'There are no questions due for review in this quiz.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Back to Quizzes'),
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
                          '${provider.currentIndex + 1} / ${provider.totalQuestions}',
                          style: AppTextStyles.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: provider.totalQuestions > 0 
                          ? (provider.currentIndex + 1) / provider.totalQuestions 
                          : 0,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ],
                ),
              ),
              
              // Question content
              Expanded(
                child: provider.currentQuestion != null
                    ? provider.isRevealed
                        ? QuizResultCard(
                            question: provider.currentQuestion!,
                            selectedAnswerIndex: provider.selectedAnswerIndex!,
                            isCorrect: provider.isCorrectAnswer,
                            onNext: provider.nextQuestion,
                          )
                        : QuizQuestionCard(
                            question: provider.currentQuestion!,
                            selectedAnswerIndex: provider.selectedAnswerIndex,
                            onAnswerSelected: provider.selectAnswer,
                            onSubmit: provider.submitAnswer,
                            isAnswered: provider.isAnswered,
                          )
                    : const SizedBox.shrink(),
              ),
              
              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (provider.hasPreviousQuestion)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: provider.previousQuestion,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                        ),
                      ),
                    if (provider.hasPreviousQuestion) const SizedBox(width: 8),
                    if (provider.hasNextQuestion)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: provider.nextQuestion,
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
}