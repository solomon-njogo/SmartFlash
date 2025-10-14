import 'package:flutter/foundation.dart';
import '../../data/models/question_model.dart';
import '../../data/models/review_log_model.dart';
import '../services/fsrs_scheduler_service.dart';
import '../services/review_log_service.dart';
import '../../data/local/hive_service.dart';

class QuestionReviewProvider with ChangeNotifier {
  final FSRSSchedulerService _schedulerService = FSRSSchedulerService();
  final ReviewLogService _reviewLogService = ReviewLogService();
  final HiveService _hiveService = HiveService();

  List<QuestionModel> _dueQuestions = [];
  QuestionModel? _currentQuestion;
  int _currentIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  bool _isRevealed = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<QuestionModel> get dueQuestions => _dueQuestions;
  QuestionModel? get currentQuestion => _currentQuestion;
  int get currentIndex => _currentIndex;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  bool get isAnswered => _isAnswered;
  bool get isRevealed => _isRevealed;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNextQuestion => _currentIndex < _dueQuestions.length - 1;
  bool get hasPreviousQuestion => _currentIndex > 0;
  int get totalQuestions => _dueQuestions.length;
  int get remainingQuestions => _dueQuestions.length - _currentIndex;
  bool get isCorrectAnswer => 
    _currentQuestion != null && 
    _selectedAnswerIndex != null && 
    _currentQuestion!.isCorrectAnswer(_selectedAnswerIndex!);

  /// Initialize the quiz session
  Future<void> initializeQuizSession({String? quizId}) async {
    _setLoading(true);
    _clearError();

    try {
      // Get due questions
      if (quizId != null) {
        _dueQuestions = _hiveService.getQuestionsByQuiz(quizId)
            .where((question) => question.isDueForReview)
            .toList();
      } else {
        _dueQuestions = _hiveService.getDueQuestions();
      }

      // Shuffle the questions for better learning
      _dueQuestions.shuffle();

      if (_dueQuestions.isNotEmpty) {
        _currentQuestion = _dueQuestions.first;
        _currentIndex = 0;
        _selectedAnswerIndex = null;
        _isAnswered = false;
        _isRevealed = false;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize quiz session: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Select an answer
  void selectAnswer(int answerIndex) {
    if (_isAnswered) return;
    
    _selectedAnswerIndex = answerIndex;
    _isAnswered = true;
    notifyListeners();
  }

  /// Submit the answer and review the question
  Future<void> submitAnswer() async {
    if (_currentQuestion == null || _selectedAnswerIndex == null || _isRevealed) return;

    _setLoading(true);
    _clearError();

    try {
      // Check if answer is correct
      final isCorrect = _currentQuestion!.isCorrectAnswer(_selectedAnswerIndex!);
      
      // Create review log using FSRS scheduler (auto-convert quiz result to rating)
      final reviewLog = _schedulerService.reviewQuestionFromQuiz(_currentQuestion!, isCorrect);
      
      // Update the question with new FSRS state
      final updatedQuestion = _currentQuestion!.copyWith(
        fsrsState: reviewLog.cardState,
        updatedAt: DateTime.now(),
      );

      // Save to local storage
      await _hiveService.saveQuestion(updatedQuestion);
      await _reviewLogService.saveReviewLog(reviewLog);

      // Update the current question in the list
      _dueQuestions[_currentIndex] = updatedQuestion;
      _currentQuestion = updatedQuestion;

      _isRevealed = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to submit answer: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Move to the next question
  void nextQuestion() {
    if (hasNextQuestion) {
      _currentIndex++;
      _currentQuestion = _dueQuestions[_currentIndex];
      _selectedAnswerIndex = null;
      _isAnswered = false;
      _isRevealed = false;
      notifyListeners();
    }
  }

  /// Move to the previous question
  void previousQuestion() {
    if (hasPreviousQuestion) {
      _currentIndex--;
      _currentQuestion = _dueQuestions[_currentIndex];
      _selectedAnswerIndex = null;
      _isAnswered = false;
      _isRevealed = false;
      notifyListeners();
    }
  }

  /// Skip the current question
  void skipQuestion() {
    nextQuestion();
  }

  /// Reset the quiz session
  void resetSession() {
    _dueQuestions.clear();
    _currentQuestion = null;
    _currentIndex = 0;
    _selectedAnswerIndex = null;
    _isAnswered = false;
    _isRevealed = false;
    _clearError();
    notifyListeners();
  }

  /// Get quiz statistics for the current session
  Map<String, dynamic> getSessionStats() {
    final totalQuestions = _dueQuestions.length;
    final answeredQuestions = _currentIndex;
    final remainingQuestions = totalQuestions - _currentIndex;
    
    // Calculate accuracy for answered questions
    int correctAnswers = 0;
    for (int i = 0; i < answeredQuestions; i++) {
      final question = _dueQuestions[i];
      // This is a simplified calculation - in a real app, you'd track this properly
      if (question.fsrsState?.reps != null && question.fsrsState!.reps > 0) {
        correctAnswers++; // Simplified: assume if reviewed, it was correct
      }
    }
    
    final accuracy = answeredQuestions > 0 ? correctAnswers / answeredQuestions : 0.0;
    
    return {
      'totalQuestions': totalQuestions,
      'answeredQuestions': answeredQuestions,
      'remainingQuestions': remainingQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
      'progress': totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0,
    };
  }

  /// Get questions by status
  List<QuestionModel> getQuestionsByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return _dueQuestions.where((question) => question.isNew).toList();
      case 'learning':
        return _dueQuestions.where((question) => question.isLearning).toList();
      case 'review':
        return _dueQuestions.where((question) => question.isReview).toList();
      case 'relearning':
        return _dueQuestions.where((question) => question.isRelearning).toList();
      default:
        return _dueQuestions;
    }
  }

  /// Filter questions by difficulty
  List<QuestionModel> getQuestionsByDifficulty(int difficulty) {
    return _dueQuestions.where((question) => question.difficulty == difficulty).toList();
  }

  /// Search questions by content
  List<QuestionModel> searchQuestions(String query) {
    if (query.isEmpty) return _dueQuestions;
    
    final lowercaseQuery = query.toLowerCase();
    return _dueQuestions.where((question) =>
      question.question.toLowerCase().contains(lowercaseQuery) ||
      question.explanation.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  /// Get the correct answer index for the current question
  int? getCorrectAnswerIndex() {
    return _currentQuestion?.correctAnswerIndex;
  }

  /// Check if the selected answer is correct
  bool isSelectedAnswerCorrect() {
    return _currentQuestion != null && 
           _selectedAnswerIndex != null && 
           _currentQuestion!.isCorrectAnswer(_selectedAnswerIndex!);
  }

  // Private helper methods
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