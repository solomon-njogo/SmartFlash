import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/quiz_attempt_model.dart';
import '../../../data/models/question_model.dart';
import '../../../data/remote/supabase_client.dart';
import '../../../app/app_text_styles.dart';

/// Results screen showing quiz attempt performance
class QuizResultsScreen extends StatefulWidget {
  final QuizAttemptModel attempt;

  const QuizResultsScreen({
    super.key,
    required this.attempt,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  List<QuestionModel> _questions = [];
  Map<String, List<String>> _userAnswers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    try {
      final supabaseService = SupabaseService.instance;

      // Load questions
      _questions = await supabaseService.getQuizQuestions(widget.attempt.quizId);
      _questions.sort((a, b) => a.order.compareTo(b.order));

      // Load answers
      final answers = await supabaseService.getAttemptAnswers(widget.attempt.id);
      for (final answer in answers) {
        _userAnswers[answer.questionId] = answer.userAnswers;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load quiz data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          title: Text(
            'Quiz Results',
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: Text(
          'Quiz Results',
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
                    color: _getScoreColor(widget.attempt.scorePercentage)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.attempt.scorePercentage >= 70
                        ? Icons.check_circle
                        : Icons.info,
                    size: 60,
                    color: _getScoreColor(widget.attempt.scorePercentage),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Quiz Completed!',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You scored ${widget.attempt.scorePercentage.toStringAsFixed(1)}%',
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      'Total Questions',
                      '${widget.attempt.totalQuestions}',
                      Icons.quiz,
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      context,
                      'Correct Answers',
                      '${widget.attempt.correctAnswers}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      context,
                      'Incorrect Answers',
                      '${widget.attempt.totalQuestions - widget.attempt.correctAnswers}',
                      Icons.cancel,
                      Colors.red,
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      context,
                      'Score',
                      '${widget.attempt.scorePercentage.toStringAsFixed(1)}%',
                      Icons.star,
                      _getScoreColor(widget.attempt.scorePercentage),
                    ),
                    if (widget.attempt.totalTimeSeconds > 0) ...[
                      const Divider(height: 24),
                      _buildStatRow(
                        context,
                        'Time Spent',
                        _formatDuration(
                          Duration(seconds: widget.attempt.totalTimeSeconds),
                        ),
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
                  color: _getScoreColor(widget.attempt.scorePercentage)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getScoreColor(widget.attempt.scorePercentage)
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPerformanceIcon(widget.attempt.scorePercentage),
                      color: _getScoreColor(widget.attempt.scorePercentage),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _getPerformanceMessage(widget.attempt.scorePercentage),
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

              // Questions review
              if (_questions.isNotEmpty) ...[
                Text(
                  'Question Review',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  final userAnswers = _userAnswers[question.id] ?? [];
                  final isCorrect = _checkAnswer(question, userAnswers);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildQuestionReviewCard(
                      context,
                      question,
                      index + 1,
                      userAnswers,
                      isCorrect,
                    ),
                  );
                }),
                const SizedBox(height: 32),
              ],

              // Done button
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/home');
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
    Color? iconColor,
  ]) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 16),
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
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionReviewCard(
    BuildContext context,
    QuestionModel question,
    int questionNumber,
    List<String> userAnswers,
    bool isCorrect,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Question $questionNumber',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isCorrect ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.questionText,
            style: AppTextStyles.bodyLarge.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (userAnswers.isNotEmpty) ...[
            Text(
              'Your Answer:',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            ...userAnswers.map((answer) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $answer',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                )),
          ] else ...[
            Text(
              'Your Answer: Not answered',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.red,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Correct Answer:',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          ...question.correctAnswers.map((answer) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $answer',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.green,
                  ),
                ),
              )),
          if (question.explanation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explanation:',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.explanation!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
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

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  IconData _getPerformanceIcon(double score) {
    if (score >= 90) return Icons.emoji_events;
    if (score >= 70) return Icons.thumb_up;
    if (score >= 50) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  String _getPerformanceMessage(double score) {
    if (score >= 90) {
      return 'Excellent work! You have a strong understanding of this material.';
    } else if (score >= 70) {
      return 'Good job! You have a solid grasp of the concepts.';
    } else if (score >= 50) {
      return 'Keep practicing! Review the material and try again.';
    } else {
      return 'Don\'t give up! Review the material and practice more.';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

