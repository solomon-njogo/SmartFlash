import 'package:flutter/foundation.dart';
import 'package:fsrs/fsrs.dart';
import '../../data/models/question_model.dart';
import '../services/fsrs_scheduler_service.dart';
import '../services/review_log_service.dart';
import '../../data/remote/supabase_client.dart';
import '../../core/utils/logger.dart';

/// Question Review Provider for managing FSRS-powered question reviews
class QuestionReviewProvider extends ChangeNotifier {
  final FSRSSchedulerService _schedulerService = FSRSSchedulerService();
  final ReviewLogService _reviewLogService = ReviewLogService();
  final SupabaseService _supabaseService = SupabaseService.instance;

  List<QuestionModel> _dueQuestions = [];
  List<QuestionModel> _newQuestions = [];
  List<QuestionModel> _learningQuestions = [];
  List<QuestionModel> _reviewQuestions = [];
  List<QuestionModel> _relearningQuestions = [];

  QuestionModel? _currentQuestion;
  bool _isLoading = false;
  String? _error;
  int _currentQuestionIndex = 0;
  bool _showAnswer = false;
  DateTime? _startTime;
  // TODO: Use response time in review log creation
  // ignore: unused_field
  double _responseTime = 0.0;
  List<String> _selectedAnswers = [];
  bool _isAnswered = false;

  /// Questions due for review
  List<QuestionModel> get dueQuestions => _dueQuestions;

  /// New questions (never reviewed)
  List<QuestionModel> get newQuestions => _newQuestions;

  /// Questions in learning phase
  List<QuestionModel> get learningQuestions => _learningQuestions;

  /// Questions in review phase
  List<QuestionModel> get reviewQuestions => _reviewQuestions;

  /// Questions in relearning phase
  List<QuestionModel> get relearningQuestions => _relearningQuestions;

  /// Currently displayed question
  QuestionModel? get currentQuestion => _currentQuestion;

  /// Whether data is loading
  bool get isLoading => _isLoading;

  /// Current error message
  String? get error => _error;

  /// Current question index in the review session
  int get currentQuestionIndex => _currentQuestionIndex;

  /// Total questions in current session
  int get totalQuestions => _dueQuestions.length;

  /// Whether answer is currently shown
  bool get showAnswer => _showAnswer;

  /// Progress percentage (0.0 to 1.0)
  double get progress =>
      totalQuestions > 0 ? _currentQuestionIndex / totalQuestions : 0.0;

  /// Whether there are more questions to review
  bool get hasMoreQuestions => _currentQuestionIndex < totalQuestions;

  /// Currently selected answers
  List<String> get selectedAnswers => _selectedAnswers;

  /// Whether current question has been answered
  bool get isAnswered => _isAnswered;

  /// Initialize the provider
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();

      _schedulerService.initialize();
      _reviewLogService.initialize();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize: $e');
      _setLoading(false);
    }
  }

  /// Load questions for review session
  Future<void> loadQuestionsForReview(String quizId) async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Load questions from local storage or API
      // For now, using empty lists
      _dueQuestions = [];
      _newQuestions = [];
      _learningQuestions = [];
      _reviewQuestions = [];
      _relearningQuestions = [];

      _currentQuestionIndex = 0;
      _showAnswer = false;
      _currentQuestion = null;
      _selectedAnswers.clear();
      _isAnswered = false;

      if (_dueQuestions.isNotEmpty) {
        _currentQuestion = _dueQuestions.first;
        _startTime = DateTime.now();
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load questions: $e');
      _setLoading(false);
    }
  }

  /// Start review session with specific questions
  void startReviewSession(List<QuestionModel> questions) {
    _dueQuestions = questions;
    _currentQuestionIndex = 0;
    _showAnswer = false;
    _currentQuestion = questions.isNotEmpty ? questions.first : null;
    _startTime = DateTime.now();
    _selectedAnswers.clear();
    _isAnswered = false;
    notifyListeners();
  }

  /// Select an answer for multiple choice questions
  void selectAnswer(String answer) {
    if (_currentQuestion == null) return;

    switch (_currentQuestion!.questionType) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        _selectedAnswers = [answer];
        break;
      case QuestionType.fillInTheBlank:
      case QuestionType.shortAnswer:
        _selectedAnswers = [answer];
        break;
      case QuestionType.matching:
        // For matching questions, handle differently
        if (!_selectedAnswers.contains(answer)) {
          _selectedAnswers.add(answer);
        }
        break;
    }

    notifyListeners();
  }

  /// Toggle answer selection for multiple choice questions
  void toggleAnswer(String answer) {
    if (_currentQuestion == null) return;

    if (_selectedAnswers.contains(answer)) {
      _selectedAnswers.remove(answer);
    } else {
      _selectedAnswers.add(answer);
    }

    notifyListeners();
  }

  /// Submit answer and show result
  Future<void> submitAnswer() async {
    if (_currentQuestion == null || _selectedAnswers.isEmpty) return;

    try {
      _setLoading(true);

      // Check if answer is correct
      final isCorrect = _currentQuestion!.areCorrectAnswers(_selectedAnswers);

      // Calculate response time
      if (_startTime != null) {
        _responseTime =
            DateTime.now().difference(_startTime!).inSeconds.toDouble();
      }

      // Convert quiz result to FSRS rating
      final rating = _schedulerService.convertQuizResultToRating(isCorrect);

      // Review the question using FSRS
      final result = _schedulerService.reviewQuestion(
        _currentQuestion!,
        rating,
      );

      // Save review log
      try {
        await _reviewLogService.saveReviewLog(result.reviewLog);
        Logger.info('Review log saved');
      } catch (e) {
        Logger.warning('Failed to save review log (non-critical): $e');
        // Continue even if review log save fails
      }

      // Save the updated question with new FSRS state
      if (result.updatedQuestion != null) {
        try {
          // Update local question state
          final questionIndex = _dueQuestions.indexWhere(
            (q) => q.id == _currentQuestion!.id,
          );
          if (questionIndex != -1) {
            _dueQuestions[questionIndex] = result.updatedQuestion!;
          }

          // Update current question reference
          _currentQuestion = result.updatedQuestion!;

          // Save to database
          await _supabaseService.updateQuestion(result.updatedQuestion!);
          Logger.info('Question FSRS state saved to database');
        } catch (e) {
          Logger.warning('Failed to save question FSRS state: $e');
          // Continue even if save fails - review log is already saved
        }
      }

      _isAnswered = true;
      _showAnswer = true;

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to submit answer: $e');
      _setLoading(false);
    }
  }

  /// Move to next question
  Future<void> nextQuestion() async {
    if (_currentQuestion == null) return;

    _currentQuestionIndex++;
    _showAnswer = false;
    _selectedAnswers.clear();
    _isAnswered = false;
    _startTime = DateTime.now();

    if (_currentQuestionIndex < _dueQuestions.length) {
      _currentQuestion = _dueQuestions[_currentQuestionIndex];
    } else {
      _currentQuestion = null;
    }

    notifyListeners();
  }

  /// Skip current question
  void skipQuestion() {
    if (_currentQuestion == null) return;

    _currentQuestionIndex++;
    _showAnswer = false;
    _selectedAnswers.clear();
    _isAnswered = false;
    _startTime = DateTime.now();

    if (_currentQuestionIndex < _dueQuestions.length) {
      _currentQuestion = _dueQuestions[_currentQuestionIndex];
    } else {
      _currentQuestion = null;
    }

    notifyListeners();
  }

  /// Get preview of next review dates for current question
  Map<Rating, DateTime> getReviewDatePreview() {
    if (_currentQuestion == null) return {};
    return _schedulerService.getQuestionReviewDatePreview(_currentQuestion!);
  }

  /// Get retrievability for current question
  double getCurrentQuestionRetrievability() {
    if (_currentQuestion == null) return 0.0;
    return _schedulerService.getQuestionRetrievability(
      _currentQuestion!,
      DateTime.now(),
    );
  }

  /// Get review statistics for current question
  ReviewStats getCurrentQuestionStats() {
    if (_currentQuestion == null) {
      return ReviewStats(
        totalReviews: 0,
        correctAnswers: 0,
        incorrectAnswers: 0,
        averageResponseTime: 0.0,
        lastReviewedAt: null,
        streak: 0,
      );
    }
    return _reviewLogService.getReviewStats(_currentQuestion!.id);
  }

  /// Reset review session
  void resetSession() {
    _currentQuestionIndex = 0;
    _showAnswer = false;
    _currentQuestion = _dueQuestions.isNotEmpty ? _dueQuestions.first : null;
    _startTime = DateTime.now();
    _selectedAnswers.clear();
    _isAnswered = false;
    notifyListeners();
  }

  /// Clear all data
  void clearData() {
    _dueQuestions.clear();
    _newQuestions.clear();
    _learningQuestions.clear();
    _reviewQuestions.clear();
    _relearningQuestions.clear();
    _currentQuestion = null;
    _currentQuestionIndex = 0;
    _showAnswer = false;
    _startTime = null;
    _selectedAnswers.clear();
    _isAnswered = false;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
