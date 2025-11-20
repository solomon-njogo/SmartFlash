import 'package:flutter/foundation.dart';
import '../../data/models/quiz_model.dart';
import '../../data/remote/supabase_client.dart';
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
