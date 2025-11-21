import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/quiz_attempt_model.dart';
import '../../../data/models/deck_attempt_model.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/models/deck_model.dart' as data_models;
import '../../../core/services/course_review_service.dart';
import '../../../core/services/quiz_attempt_service.dart';
import '../../../core/services/deck_attempt_service.dart';
import '../../../core/providers/quiz_provider.dart';
import '../../../core/providers/deck_provider.dart';
import '../../../data/remote/supabase_client.dart';
import '../../../data/models/question_model.dart';
import '../../../data/models/flashcard_model.dart';
import '../../../data/models/quiz_attempt_answer_model.dart';
import '../../../data/models/deck_attempt_card_result.dart';

/// Screen to display review history for a course
class CourseReviewHistoryScreen extends StatefulWidget {
  final String courseId;

  const CourseReviewHistoryScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseReviewHistoryScreen> createState() =>
      _CourseReviewHistoryScreenState();
}

class _CourseReviewHistoryScreenState
    extends State<CourseReviewHistoryScreen> with SingleTickerProviderStateMixin {
  final CourseReviewService _reviewService = CourseReviewService();

  late TabController _tabController;
  List<QuizAttemptModel> _quizAttempts = [];
  List<DeckAttemptModel> _deckAttempts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReviewHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReviewHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      final quizAttempts = await _reviewService.getCourseQuizAttempts(
        widget.courseId,
        userId,
      );
      final deckAttempts = await _reviewService.getCourseDeckAttempts(
        widget.courseId,
        userId,
      );

      setState(() {
        _quizAttempts = quizAttempts;
        _deckAttempts = deckAttempts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
        title: Text(
          'Review History',
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.quiz),
              text: 'Quizzes',
            ),
            Tab(
              icon: Icon(Icons.library_books),
              text: 'Decks',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading review history',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadReviewHistory,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReviewHistory,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildQuizAttemptsTab(),
                      _buildDeckAttemptsTab(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildQuizAttemptsTab() {
    if (_quizAttempts.isEmpty) {
      return _buildEmptyState(
        Icons.quiz,
        'No Quiz Attempts',
        'You haven\'t completed any quizzes for this course yet.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _quizAttempts.length,
      itemBuilder: (context, index) {
        final attempt = _quizAttempts[index];
        return _QuizAttemptCard(attempt: attempt);
      },
    );
  }

  Widget _buildDeckAttemptsTab() {
    if (_deckAttempts.isEmpty) {
      return _buildEmptyState(
        Icons.library_books,
        'No Deck Attempts',
        'You haven\'t completed any deck reviews for this course yet.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _deckAttempts.length,
      itemBuilder: (context, index) {
        final attempt = _deckAttempts[index];
        return _DeckAttemptCard(attempt: attempt);
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display a quiz attempt card
class _QuizAttemptCard extends StatefulWidget {
  final QuizAttemptModel attempt;

  const _QuizAttemptCard({required this.attempt});

  @override
  State<_QuizAttemptCard> createState() => _QuizAttemptCardState();
}

class _QuizAttemptCardState extends State<_QuizAttemptCard> {
  bool _isExpanded = false;
  QuizModel? _quiz;
  List<QuestionModel> _questions = [];
  List<QuizAttemptAnswerModel> _answers = [];
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _loadQuizDetails();
  }

  Future<void> _loadQuizDetails() async {
    if (!_isExpanded) return;

    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      _quiz = quizProvider.getQuizById(widget.attempt.quizId);

      if (_quiz == null) {
        final supabaseService = SupabaseService.instance;
        final quizzes = await supabaseService.getCourseQuizzes(
          _quiz?.courseId ?? '',
        );
        _quiz = quizzes.firstWhere(
          (q) => q.id == widget.attempt.quizId,
          orElse: () => quizzes.first,
        );
      }

      final supabaseService = SupabaseService.instance;
      _questions = await supabaseService.getQuizQuestions(widget.attempt.quizId);

      final quizAttemptService = QuizAttemptService();
      _answers = await quizAttemptService.getAttemptAnswers(widget.attempt.id);

      // Sort answers by order
      _answers.sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final score = widget.attempt.scorePercentage;
    final isGoodScore = score >= 70;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          if (_isExpanded && _questions.isEmpty) {
            _loadQuizDetails();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.quiz,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _quiz?.name ?? 'Quiz',
                          style: AppTextStyles.cardTitle.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, y • h:mm a')
                              .format(widget.attempt.completedAt ?? widget.attempt.startedAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isGoodScore
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${score.toStringAsFixed(0)}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isGoodScore ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.check_circle,
                    '${widget.attempt.correctAnswers}/${widget.attempt.totalQuestions}',
                    colorScheme,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.timer,
                    _formatDuration(widget.attempt.totalTime),
                    colorScheme,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.repeat,
                    'Attempt #${widget.attempt.attemptNumber}',
                    colorScheme,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                if (_isLoadingDetails)
                  const Center(child: CircularProgressIndicator())
                else if (_questions.isNotEmpty)
                  ..._buildAnswerDetails()
                else
                  Text(
                    'Unable to load answer details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnswerDetails() {
    final widgets = <Widget>[];

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final answer = _answers.firstWhere(
        (a) => a.questionId == question.id,
        orElse: () => _answers.isNotEmpty
            ? _answers[0]
            : QuizAttemptAnswerModel(
                id: '',
                attemptId: widget.attempt.id,
                questionId: question.id,
                userAnswers: [],
                isCorrect: false,
                answeredAt: DateTime.now(),
                timeSpentSeconds: 0,
                order: i,
              ),
      );

      if (i > 0) {
        widgets.add(const SizedBox(height: 16));
      }

      widgets.add(
        _QuestionAnswerCard(
          question: question,
          answer: answer,
          questionNumber: i + 1,
        ),
      );
    }

    return widgets;
  }

  Widget _buildInfoChip(
    IconData icon,
    String text,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
}

/// Widget to display question and answer details
class _QuestionAnswerCard extends StatelessWidget {
  final QuestionModel question;
  final QuizAttemptAnswerModel answer;
  final int questionNumber;

  const _QuestionAnswerCard({
    required this.question,
    required this.answer,
    required this.questionNumber,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCorrect = answer.isCorrect;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCorrect ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Q$questionNumber',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                size: 20,
                color: isCorrect ? AppColors.success : AppColors.error,
              ),
              const Spacer(),
              Text(
                '${answer.timeSpentSeconds}s',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.questionText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (answer.userAnswers.isNotEmpty) ...[
            Text(
              'Your answer:',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            ...answer.userAnswers.map(
              (ans) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $ans',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Correct answer:',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          ...question.correctAnswers.map(
            (ans) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $ans',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (question.explanation != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                question.explanation!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget to display a deck attempt card
class _DeckAttemptCard extends StatefulWidget {
  final DeckAttemptModel attempt;

  const _DeckAttemptCard({required this.attempt});

  @override
  State<_DeckAttemptCard> createState() => _DeckAttemptCardState();
}

class _DeckAttemptCardState extends State<_DeckAttemptCard> {
  bool _isExpanded = false;
  data_models.DeckModel? _deck;
  List<FlashcardModel> _flashcards = [];
  List<DeckAttemptCardResult> _cardResults = [];
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _loadDeckDetails();
  }

  Future<void> _loadDeckDetails() async {
    if (!_isExpanded) return;

    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final deckProvider = Provider.of<DeckProvider>(context, listen: false);
      _deck = deckProvider.getDeckById(widget.attempt.deckId);

      if (_deck == null) {
        final supabaseService = SupabaseService.instance;
        final decks = await supabaseService.getCourseDecks(_deck?.courseId ?? '');
        _deck = decks.firstWhere(
          (d) => d.id == widget.attempt.deckId,
          orElse: () => decks.first,
        );
      }

      final supabaseService = SupabaseService.instance;
      _flashcards = await supabaseService.getDeckFlashcards(widget.attempt.deckId);

      final deckAttemptService = DeckAttemptService();
      _cardResults = await deckAttemptService.getAttemptCardResults(
        widget.attempt.id,
      );

      // Sort card results by order
      _cardResults.sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final successPercentage = widget.attempt.successPercentage;
    final isGoodPerformance = successPercentage >= 70;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          if (_isExpanded && _flashcards.isEmpty) {
            _loadDeckDetails();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.library_books,
                      color: colorScheme.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _deck?.name ?? 'Deck',
                          style: AppTextStyles.cardTitle.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, y • h:mm a')
                              .format(widget.attempt.completedAt ?? widget.attempt.startedAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isGoodPerformance
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${successPercentage.toStringAsFixed(0)}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isGoodPerformance
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.style,
                    '${widget.attempt.cardsStudied}/${widget.attempt.totalCards}',
                    colorScheme,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.timer,
                    _formatDuration(widget.attempt.totalTime),
                    colorScheme,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.repeat,
                    'Attempt #${widget.attempt.attemptNumber}',
                    colorScheme,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildRatingDistribution(colorScheme),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                if (_isLoadingDetails)
                  const Center(child: CircularProgressIndicator())
                else if (_flashcards.isNotEmpty)
                  ..._buildCardDetails()
                else
                  Text(
                    'Unable to load card details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingDistribution(ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (widget.attempt.cardsAgain > 0)
          _buildRatingChip('Again', widget.attempt.cardsAgain, AppColors.error),
        if (widget.attempt.cardsHard > 0)
          _buildRatingChip('Hard', widget.attempt.cardsHard, AppColors.warning),
        if (widget.attempt.cardsGood > 0)
          _buildRatingChip('Good', widget.attempt.cardsGood, AppColors.success),
        if (widget.attempt.cardsEasy > 0)
          _buildRatingChip('Easy', widget.attempt.cardsEasy, AppColors.info),
      ],
    );
  }

  Widget _buildRatingChip(String label, int count, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $count',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCardDetails() {
    final widgets = <Widget>[];

    for (int i = 0; i < _cardResults.length; i++) {
      final cardResult = _cardResults[i];
      final flashcard = _flashcards.firstWhere(
        (f) => f.id == cardResult.flashcardId,
        orElse: () => _flashcards.isNotEmpty
            ? _flashcards[0]
            : FlashcardModel(
                id: '',
                deckId: widget.attempt.deckId,
                frontText: 'Card not found',
                backText: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
      );

      if (i > 0) {
        widgets.add(const SizedBox(height: 12));
      }

      widgets.add(
        _CardResultCard(
          flashcard: flashcard,
          cardResult: cardResult,
          cardNumber: i + 1,
        ),
      );
    }

    return widgets;
  }

  Widget _buildInfoChip(
    IconData icon,
    String text,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
}

/// Widget to display card result details
class _CardResultCard extends StatelessWidget {
  final FlashcardModel flashcard;
  final DeckAttemptCardResult cardResult;
  final int cardNumber;

  const _CardResultCard({
    required this.flashcard,
    required this.cardResult,
    required this.cardNumber,
  });

  Color _getRatingColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'again':
        return AppColors.error;
      case 'hard':
        return AppColors.warning;
      case 'good':
        return AppColors.success;
      case 'easy':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getRatingLabel(String rating) {
    switch (rating.toLowerCase()) {
      case 'again':
        return 'Again';
      case 'hard':
        return 'Hard';
      case 'good':
        return 'Good';
      case 'easy':
        return 'Easy';
      default:
        return rating;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ratingColor = _getRatingColor(cardResult.rating);
    final ratingLabel = _getRatingLabel(cardResult.rating);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ratingColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ratingColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ratingColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Card $cardNumber',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ratingLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: ratingColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${cardResult.timeSpentSeconds}s',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Front:',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            flashcard.frontText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Back:',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            flashcard.backText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

