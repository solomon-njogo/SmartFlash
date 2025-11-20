import 'package:flutter/foundation.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../../data/remote/supabase_client.dart';
import '../services/quiz_attempt_service.dart';
import '../utils/logger.dart';

/// Quiz provider for managing quiz and study session state
class QuizProvider extends ChangeNotifier {
  List<QuizModel> _quizzes = [];
  QuizModel? _currentQuiz;
  List<QuizModel> _quizHistory = [];
  bool _isLoading = false;
  String? _error;
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _studyResults = {};

  // Quiz taking state
  List<QuestionModel> _questions = [];
  QuizAttemptModel? _currentAttempt;
  Map<String, List<String>> _userAnswers = {}; // questionId -> answers
  Map<String, DateTime> _questionStartTimes = {}; // questionId -> start time
  Map<String, bool> _answeredQuestions = {}; // questionId -> isAnswered

  final QuizAttemptService _quizAttemptService = QuizAttemptService();
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// List of all quizzes
  List<QuizModel> get quizzes => _quizzes;

  /// Current quiz being studied
  QuizModel? get currentQuiz => _currentQuiz;

  /// Quiz history
  List<QuizModel> get quizHistory => _quizHistory;

  /// Whether data is loading
  bool get isLoading => _isLoading;

  /// Current error message
  String? get error => _error;

  /// Current question index
  int get currentQuestionIndex => _currentQuestionIndex;

  /// Study results
  Map<String, dynamic> get studyResults => _studyResults;

  /// Current questions for the quiz
  List<QuestionModel> get questions => _questions;

  /// Current quiz attempt
  QuizAttemptModel? get currentAttempt => _currentAttempt;

  /// Get current question
  QuestionModel? get currentQuestion {
    if (_currentQuestionIndex >= 0 &&
        _currentQuestionIndex < _questions.length) {
      return _questions[_currentQuestionIndex];
    }
    return null;
  }

  /// Check if current question is answered
  bool get isCurrentQuestionAnswered {
    final question = currentQuestion;
    if (question == null) return false;
    return _answeredQuestions[question.id] ?? false;
  }

  /// Get user answers for a question
  List<String> getUserAnswers(String questionId) {
    return _userAnswers[questionId] ?? [];
  }

  /// Check if can go to previous question
  bool get canGoToPrevious => _currentQuestionIndex > 0;

  /// Check if can go to next question
  bool get canGoToNext => _currentQuestionIndex < _questions.length - 1;

  /// Check if all questions are answered
  bool get areAllQuestionsAnswered {
    if (_questions.isEmpty) return false;
    return _questions.every((q) => _answeredQuestions[q.id] ?? false);
  }

  /// Get progress percentage
  double get progressPercentage {
    if (_questions.isEmpty) return 0.0;
    final answeredCount = _answeredQuestions.values.where((v) => v).length;
    return (answeredCount / _questions.length) * 100;
  }

  QuizProvider() {
    _loadQuizzes();
  }

  /// Load quizzes from storage
  Future<void> _loadQuizzes() async {
    try {
      _setLoading(true);
      _clearError();

      final supabaseService = SupabaseService.instance;

      // Check if user is authenticated
      if (!supabaseService.isAuthenticated) {
        Logger.info('User not authenticated, skipping quiz load');
        _quizzes = [];
        notifyListeners();
        return;
      }

      final userId = supabaseService.currentUserId;
      if (userId == null) {
        Logger.warning('User ID is null, skipping quiz load');
        _quizzes = [];
        notifyListeners();
        return;
      }

      // Fetch quizzes from database
      _quizzes = await supabaseService.getUserQuizzes(userId);

      Logger.info('Loaded ${_quizzes.length} quizzes from database');
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to load quizzes: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Get quizzes by course ID
  /// Filters quizzes directly by courseId
  List<QuizModel> getQuizzesByCourseId(String courseId) {
    try {
      final matchingQuizzes =
          _quizzes.where((quiz) => quiz.courseId == courseId).toList();

      Logger.info(
        'Found ${matchingQuizzes.length} quizzes for course $courseId',
      );

      return matchingQuizzes;
    } catch (e) {
      Logger.error('Failed to get quizzes by course ID: $e');
      return [];
    }
  }

  /// Get quizzes by course ID (async version that queries database if needed)
  Future<List<QuizModel>> getQuizzesByCourseIdAsync(String courseId) async {
    try {
      // First try local cache
      final cached = getQuizzesByCourseId(courseId);
      if (cached.isNotEmpty) {
        return cached;
      }

      // Fallback: query database directly
      Logger.info(
        'No local quizzes found, querying database for course quizzes: $courseId',
      );
      final supabaseService = SupabaseService.instance;
      if (!supabaseService.isAuthenticated) return [];

      final quizzes = await supabaseService.getCourseQuizzes(courseId);

      // Update local cache with results, avoiding duplicates
      if (quizzes.isNotEmpty) {
        final existingIds = _quizzes.map((q) => q.id).toSet();
        final newQuizzes =
            quizzes.where((q) => !existingIds.contains(q.id)).toList();
        if (newQuizzes.isNotEmpty) {
          _quizzes.addAll(newQuizzes);
          notifyListeners();
        }
      }

      return quizzes;
    } catch (e) {
      Logger.error('Failed to get quizzes by course ID (async): $e');
      return [];
    }
  }

  /// Get quiz count for a course
  int getQuizCountByCourseId(String courseId) {
    return getQuizzesByCourseId(courseId).length;
  }

  /// Get quiz by ID
  QuizModel? getQuizById(String quizId) {
    try {
      return _quizzes.firstWhere((quiz) => quiz.id == quizId);
    } catch (e) {
      return null;
    }
  }

  /// Start a new quiz session
  Future<bool> startQuiz(String quizId) async {
    try {
      _setLoading(true);
      _clearError();
      Logger.info('Starting quiz: $quizId');

      final quiz = getQuizById(quizId);
      if (quiz == null) {
        Logger.warning('Quiz not found: $quizId');
        _setError('Quiz not found');
        return false;
      }

      // Load questions for the quiz
      Logger.info('Loading questions for quiz: $quizId');
      _questions = await _supabaseService.getQuizQuestions(quizId);

      if (_questions.isEmpty) {
        Logger.warning('No questions found for quiz: $quizId');
        _setError('This quiz has no questions');
        return false;
      }

      // Sort questions by order
      _questions.sort((a, b) => a.order.compareTo(b.order));

      // Create quiz attempt
      final userId = _supabaseService.currentUserId;
      if (userId == null) {
        Logger.error('User not authenticated');
        _setError('User not authenticated');
        return false;
      }

      Logger.info('Creating quiz attempt');
      _currentAttempt = await _quizAttemptService.createAttempt(
        quizId: quizId,
        userId: userId,
        totalQuestions: _questions.length,
      );

      _currentQuiz = quiz;
      _currentQuestionIndex = 0;
      _studyResults = {};
      _userAnswers = {};
      _questionStartTimes = {};
      _answeredQuestions = {};

      // Record start time for first question
      if (_questions.isNotEmpty) {
        _questionStartTimes[_questions[0].id] = DateTime.now();
      }

      Logger.info(
        'Quiz started successfully with ${_questions.length} questions',
      );
      notifyListeners();
      return true;
    } catch (e) {
      Logger.error('Failed to start quiz: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load questions for current quiz
  Future<void> loadQuestions() async {
    if (_currentQuiz == null) {
      Logger.warning('No current quiz to load questions for');
      return;
    }

    try {
      _setLoading(true);
      _clearError();
      Logger.info('Loading questions for quiz: ${_currentQuiz!.id}');

      _questions = await _supabaseService.getQuizQuestions(_currentQuiz!.id);
      _questions.sort((a, b) => a.order.compareTo(b.order));

      Logger.info('Loaded ${_questions.length} questions');
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to load questions: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Submit answer for current question
  Future<bool> submitAnswer(List<String> answers) async {
    if (_currentAttempt == null || currentQuestion == null) {
      Logger.warning('Cannot submit answer: no current attempt or question');
      return false;
    }

    try {
      final question = currentQuestion!;
      final questionId = question.id;

      // Check if already answered
      if (_answeredQuestions[questionId] ?? false) {
        Logger.info('Question already answered, skipping');
        return true;
      }

      // Calculate if answer is correct
      final isCorrect = _checkAnswer(question, answers);

      // Calculate time spent
      final startTime = _questionStartTimes[questionId] ?? DateTime.now();
      final timeSpent = DateTime.now().difference(startTime).inSeconds;

      // Save answer
      Logger.info('Saving answer for question: $questionId');
      await _quizAttemptService.saveAnswer(
        attemptId: _currentAttempt!.id,
        questionId: questionId,
        userAnswers: answers,
        isCorrect: isCorrect,
        timeSpentSeconds: timeSpent,
        order: _currentQuestionIndex,
      );

      // Update attempt
      _currentAttempt = await _quizAttemptService.updateAttemptWithAnswer(
        attempt: _currentAttempt!,
        isCorrect: isCorrect,
        timeSpentSeconds: timeSpent,
      );

      // Store answer locally
      _userAnswers[questionId] = answers;
      _answeredQuestions[questionId] = true;

      Logger.info('Answer submitted successfully. Correct: $isCorrect');
      notifyListeners();
      return true;
    } catch (e) {
      Logger.error('Failed to submit answer: $e');
      _setError(e.toString());
      return false;
    }
  }

  /// Check if answer is correct
  bool _checkAnswer(QuestionModel question, List<String> userAnswers) {
    final correctAnswers =
        question.correctAnswers.map((a) => a.toLowerCase().trim()).toList();
    final userAnswersNormalized =
        userAnswers.map((a) => a.toLowerCase().trim()).toList();

    if (correctAnswers.length != userAnswersNormalized.length) {
      return false;
    }

    // Sort both lists for comparison
    correctAnswers.sort();
    userAnswersNormalized.sort();

    return correctAnswers.toString() == userAnswersNormalized.toString();
  }

  /// Go to previous question
  void goToPreviousQuestion() {
    if (!canGoToPrevious) {
      Logger.warning('Cannot go to previous question');
      return;
    }

    _currentQuestionIndex--;
    final question = currentQuestion;
    if (question != null && !_questionStartTimes.containsKey(question.id)) {
      _questionStartTimes[question.id] = DateTime.now();
    }
    Logger.info('Moved to previous question. Index: $_currentQuestionIndex');
    notifyListeners();
  }

  /// Go to next question
  void goToNextQuestion() {
    if (!canGoToNext) {
      Logger.warning('Cannot go to next question');
      return;
    }

    _currentQuestionIndex++;
    final question = currentQuestion;
    if (question != null && !_questionStartTimes.containsKey(question.id)) {
      _questionStartTimes[question.id] = DateTime.now();
    }
    Logger.info('Moved to next question. Index: $_currentQuestionIndex');
    notifyListeners();
  }

  /// Go to specific question by index
  void goToQuestion(int index) {
    if (index < 0 || index >= _questions.length) {
      Logger.warning('Invalid question index: $index');
      return;
    }

    _currentQuestionIndex = index;
    final question = currentQuestion;
    if (question != null && !_questionStartTimes.containsKey(question.id)) {
      _questionStartTimes[question.id] = DateTime.now();
    }
    Logger.info('Moved to question at index: $index');
    notifyListeners();
  }

  /// Complete quiz attempt
  Future<QuizAttemptModel?> completeQuiz() async {
    if (_currentAttempt == null) {
      Logger.warning('No current attempt to complete');
      return null;
    }

    try {
      _setLoading(true);
      _clearError();
      Logger.info('Completing quiz attempt: ${_currentAttempt!.id}');

      final completed = await _quizAttemptService.completeAttempt(
        _currentAttempt!,
      );
      _currentAttempt = completed;

      Logger.info(
        'Quiz completed successfully. Score: ${completed.scorePercentage}%',
      );
      notifyListeners();
      return completed;
    } catch (e) {
      Logger.error('Failed to complete quiz: $e');
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get score summary
  Map<String, dynamic> getScoreSummary() {
    if (_currentAttempt == null) {
      return {'totalQuestions': 0, 'correctAnswers': 0, 'scorePercentage': 0.0};
    }

    return {
      'totalQuestions': _currentAttempt!.totalQuestions,
      'correctAnswers': _currentAttempt!.correctAnswers,
      'incorrectAnswers':
          _currentAttempt!.totalQuestions - _currentAttempt!.correctAnswers,
      'scorePercentage': _currentAttempt!.scorePercentage,
    };
  }

  /// Refresh quizzes from storage
  Future<void> refreshQuizzes() async {
    await _loadQuizzes();
  }

  /// Create a new quiz
  Future<bool> createQuiz(QuizModel quiz) async {
    try {
      _setLoading(true);
      _clearError();

      _quizzes.add(quiz);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing quiz
  Future<bool> updateQuiz(QuizModel quiz) async {
    try {
      _setLoading(true);
      _clearError();

      final index = _quizzes.indexWhere((q) => q.id == quiz.id);
      if (index != -1) {
        _quizzes[index] = quiz;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a quiz
  Future<bool> deleteQuiz(String quizId) async {
    try {
      _setLoading(true);
      _clearError();

      _quizzes.removeWhere((quiz) => quiz.id == quizId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset current quiz
  void resetQuiz() {
    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _studyResults = {};
    _questions = [];
    _currentAttempt = null;
    _userAnswers = {};
    _questionStartTimes = {};
    _answeredQuestions = {};
    Logger.info('Quiz reset');
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear error manually
  void clearError() {
    _clearError();
  }
}
