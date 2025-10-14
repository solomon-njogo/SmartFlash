import 'package:flutter/foundation.dart';

/// Simple quiz model for now
class QuizModel {
  final String id;
  final String deckId;
  final DateTime startTime;
  DateTime? endTime;
  int score;
  int totalQuestions;
  int correctAnswers;
  int incorrectAnswers;
  final List<dynamic> questions;
  String status;

  QuizModel({
    required this.id,
    required this.deckId,
    required this.startTime,
    this.endTime,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.questions,
    required this.status,
  });
}

/// Quiz provider for managing quiz and study session state
class QuizProvider extends ChangeNotifier {
  QuizModel? _currentQuiz;
  List<QuizModel> _quizHistory = [];
  bool _isLoading = false;
  String? _error;
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _studyResults = {};

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

  QuizProvider() {
    _loadQuizHistory();
  }

  /// Load quiz history from storage
  Future<void> _loadQuizHistory() async {
    try {
      _setLoading(true);
      _clearError();

      // Mock data for now
      _quizHistory = [];
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Start a new quiz session
  Future<bool> startQuiz(String deckId) async {
    try {
      _setLoading(true);
      _clearError();

      // Create a new quiz instance
      _currentQuiz = QuizModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        deckId: deckId,
        startTime: DateTime.now(),
        endTime: null,
        score: 0,
        totalQuestions: 0,
        correctAnswers: 0,
        incorrectAnswers: 0,
        questions: [],
        status: 'inProgress',
      );

      _currentQuestionIndex = 0;
      _studyResults = {};
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Answer a question
  Future<void> answerQuestion(
    String questionId,
    String answer,
    bool isCorrect,
  ) async {
    if (_currentQuiz == null) return;

    try {
      // Update quiz statistics
      if (isCorrect) {
        _currentQuiz!.correctAnswers++;
      } else {
        _currentQuiz!.incorrectAnswers++;
      }

      _currentQuiz!.totalQuestions++;

      // Calculate score
      _currentQuiz!.score =
          (_currentQuiz!.correctAnswers / _currentQuiz!.totalQuestions * 100)
              .round();

      // Store answer in study results
      _studyResults[questionId] = {
        'answer': answer,
        'isCorrect': isCorrect,
        'timestamp': DateTime.now().toIso8601String(),
      };

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Move to next question
  void nextQuestion() {
    if (_currentQuiz != null) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Move to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Complete the quiz
  Future<bool> completeQuiz() async {
    if (_currentQuiz == null) return false;

    try {
      _setLoading(true);
      _clearError();

      _currentQuiz!.endTime = DateTime.now();
      _currentQuiz!.status = 'completed';

      // Save quiz to history
      _quizHistory.insert(0, _currentQuiz!);

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
    notifyListeners();
  }

  /// Get quiz statistics
  Map<String, dynamic> getQuizStatistics() {
    if (_quizHistory.isEmpty) {
      return {
        'totalQuizzes': 0,
        'averageScore': 0,
        'totalQuestions': 0,
        'correctAnswers': 0,
        'incorrectAnswers': 0,
      };
    }

    final totalQuizzes = _quizHistory.length;
    final totalScore = _quizHistory.fold(0, (sum, quiz) => sum + quiz.score);
    final averageScore = totalQuizzes > 0 ? totalScore / totalQuizzes : 0;

    final totalQuestions = _quizHistory.fold(
      0,
      (sum, quiz) => sum + quiz.totalQuestions,
    );
    final correctAnswers = _quizHistory.fold(
      0,
      (sum, quiz) => sum + quiz.correctAnswers,
    );
    final incorrectAnswers = _quizHistory.fold(
      0,
      (sum, quiz) => sum + quiz.incorrectAnswers,
    );

    return {
      'totalQuizzes': totalQuizzes,
      'averageScore': averageScore.round(),
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
    };
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
