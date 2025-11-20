import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/quiz_provider.dart';
import '../../../data/models/question_model.dart';
import '../../../app/app_text_styles.dart';

/// Screen for taking a quiz
class QuizTakingScreen extends StatefulWidget {
  final String quizId;

  const QuizTakingScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  List<String> _selectedAnswers = [];
  bool _showFeedback = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startQuiz();
    });
  }

  Future<void> _startQuiz() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final success = await quizProvider.startQuiz(widget.quizId);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(quizProvider.error ?? 'Failed to start quiz'),
          backgroundColor: Colors.red,
        ),
      );
      context.pop();
    } else if (mounted) {
      _loadCurrentQuestionAnswers();
    }
  }

  void _loadCurrentQuestionAnswers() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final question = quizProvider.currentQuestion;
    if (question != null) {
      _selectedAnswers = quizProvider.getUserAnswers(question.id);
      _showFeedback = quizProvider.isCurrentQuestionAnswered;
    }
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
        title: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            return Text(
              quizProvider.currentQuiz?.name ?? 'Quiz',
              style: AppTextStyles.titleLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            );
          },
        ),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (quizProvider.currentQuestion == null) {
            return const Center(child: Text('No questions available'));
          }

          return Column(
            children: [
              // Progress indicator
              _buildProgressBar(context, quizProvider),

              // Question content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildQuestionContent(context, quizProvider),
                ),
              ),

              // Navigation buttons
              _buildNavigationButtons(context, quizProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, QuizProvider quizProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = quizProvider.progressPercentage / 100;

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
                'Question ${quizProvider.currentQuestionIndex + 1} of ${quizProvider.questions.length}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${quizProvider.progressPercentage.toInt()}%',
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

  Widget _buildQuestionContent(
    BuildContext context,
    QuizProvider quizProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final question = quizProvider.currentQuestion!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question text
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            question.questionText,
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Answer options
        if (question.questionType == QuestionType.multipleChoice ||
            question.questionType == QuestionType.trueFalse)
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedAnswers.contains(option);
            final isCorrect = question.correctAnswers.contains(option);
            final showCorrect = _showFeedback && isCorrect;
            final showWrong = _showFeedback && isSelected && !isCorrect;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionButton(
                context,
                option,
                index,
                isSelected,
                showCorrect,
                showWrong,
                quizProvider,
              ),
            );
          }),

        // Feedback section
        if (_showFeedback) ...[
          const SizedBox(height: 24),
          _buildFeedbackSection(context, question, quizProvider),
        ],
      ],
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String option,
    int index,
    bool isSelected,
    bool showCorrect,
    bool showWrong,
    QuizProvider quizProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor = colorScheme.surface;
    Color borderColor = colorScheme.outline.withOpacity(0.2);
    Color textColor = colorScheme.onSurface;

    if (showCorrect) {
      backgroundColor = Colors.green.withOpacity(0.2);
      borderColor = Colors.green;
      textColor = Colors.green;
    } else if (showWrong) {
      backgroundColor = Colors.red.withOpacity(0.2);
      borderColor = Colors.red;
      textColor = Colors.red;
    } else if (isSelected) {
      backgroundColor = colorScheme.primaryContainer;
      borderColor = colorScheme.primary;
      textColor = colorScheme.onPrimaryContainer;
    }

    return InkWell(
      onTap: _showFeedback ? null : () => _selectAnswer(option, quizProvider),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected || showCorrect || showWrong
                    ? borderColor
                    : Colors.transparent,
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
              ),
              child: isSelected || showCorrect || showWrong
                  ? Icon(
                      showCorrect
                          ? Icons.check
                          : showWrong
                              ? Icons.close
                              : Icons.circle,
                      size: 16,
                      color: showCorrect || showWrong
                          ? Colors.white
                          : textColor,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: textColor,
                  fontWeight: isSelected || showCorrect || showWrong
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(
    BuildContext context,
    QuestionModel question,
    QuizProvider quizProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userAnswers = quizProvider.getUserAnswers(question.id);
    final isCorrect = _checkAnswer(question, userAnswers);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                isCorrect ? 'Correct!' : 'Incorrect',
                style: AppTextStyles.titleMedium.copyWith(
                  color: isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (question.explanation != null) ...[
            const SizedBox(height: 16),
            Text(
              'Explanation:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question.explanation!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _checkAnswer(QuestionModel question, List<String> userAnswers) {
    final correctAnswers = question.correctAnswers
        .map((a) => a.toLowerCase().trim())
        .toList();
    final userAnswersNormalized =
        userAnswers.map((a) => a.toLowerCase().trim()).toList();

    if (correctAnswers.length != userAnswersNormalized.length) {
      return false;
    }

    correctAnswers.sort();
    userAnswersNormalized.sort();

    return correctAnswers.toString() == userAnswersNormalized.toString();
  }

  void _selectAnswer(String answer, QuizProvider quizProvider) {
    setState(() {
      final question = quizProvider.currentQuestion!;
      if (question.questionType == QuestionType.multipleChoice) {
        if (_selectedAnswers.contains(answer)) {
          _selectedAnswers.remove(answer);
        } else {
          _selectedAnswers.add(answer);
        }
      } else {
        // Single choice (true/false, etc.)
        _selectedAnswers = [answer];
      }
    });
  }

  Future<void> _submitAnswer(QuizProvider quizProvider) async {
    if (_selectedAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an answer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await quizProvider.submitAnswer(_selectedAnswers);
    if (success) {
      setState(() {
        _showFeedback = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(quizProvider.error ?? 'Failed to submit answer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    QuizProvider quizProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLastQuestion =
        quizProvider.currentQuestionIndex == quizProvider.questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: quizProvider.canGoToPrevious
                    ? () {
                        setState(() {
                          _showFeedback = false;
                          _selectedAnswers = [];
                        });
                        quizProvider.goToPreviousQuestion();
                        _loadCurrentQuestionAnswers();
                      }
                    : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Submit/Next button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (!_showFeedback) {
                    // Submit answer first
                    await _submitAnswer(quizProvider);
                  } else {
                    // Move to next question or show submit dialog
                    if (isLastQuestion) {
                      _showSubmitDialog(context, quizProvider);
                    } else {
                      setState(() {
                        _showFeedback = false;
                        _selectedAnswers = [];
                      });
                      quizProvider.goToNextQuestion();
                      _loadCurrentQuestionAnswers();
                    }
                  }
                },
                icon: Icon(_showFeedback
                    ? (isLastQuestion ? Icons.check : Icons.arrow_forward)
                    : Icons.send),
                label: Text(_showFeedback
                    ? (isLastQuestion ? 'Submit Quiz' : 'Next')
                    : 'Submit Answer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSubmitDialog(
    BuildContext context,
    QuizProvider quizProvider,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Submit Quiz?',
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to submit your quiz? You cannot change your answers after submitting.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
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

    if (confirmed == true && mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Complete quiz attempt
      final completedAttempt = await quizProvider.completeQuiz();

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        if (completedAttempt != null) {
          // Navigate to results screen
          context.pushReplacement(
            '/quiz-results',
            extra: completedAttempt,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                quizProvider.error ?? 'Failed to complete quiz',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

