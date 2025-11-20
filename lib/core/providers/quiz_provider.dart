import 'package:flutter/foundation.dart';
import '../../data/models/quiz_model.dart';
import 'course_provider.dart';

/// Quiz provider for managing quiz and study session state
class QuizProvider extends ChangeNotifier {
  List<QuizModel> _quizzes = [];
  QuizModel? _currentQuiz;
  List<QuizModel> _quizHistory = [];
  bool _isLoading = false;
  String? _error;
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _studyResults = {};

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

  QuizProvider() {
    _loadQuizzes();
  }

  /// Load quizzes from storage
  Future<void> _loadQuizzes() async {
    try {
      _setLoading(true);
      _clearError();

      // To do
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Get quizzes by course ID
  List<QuizModel> getQuizzesByCourseId(String courseId) {
    return _quizzes.where((quiz) {
      // Check if quiz belongs to any deck in the course
      final courseProvider = CourseProvider();
      final course = courseProvider.getCourseById(courseId);
      if (course == null) return false;

      return course.quizIds.contains(quiz.id);
    }).toList();
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

      final quiz = getQuizById(quizId);
      if (quiz == null) {
        _setError('Quiz not found');
        return false;
      }

      _currentQuiz = quiz;
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
