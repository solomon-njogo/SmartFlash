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

      // Sample quiz data for all courses
      _quizzes = [
        // Computer Science 101 Quizzes
        QuizModel(
          id: 'cs101_quiz1',
          name: 'Programming Fundamentals Quiz',
          description: 'Test your knowledge of basic programming concepts',
          deckId: 'cs101_deck1',
          questionIds: [
            'cs101_q1',
            'cs101_q2',
            'cs101_q3',
            'cs101_q4',
            'cs101_q5',
          ],
          status: QuizStatus.published,
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          updatedAt: DateTime.now().subtract(const Duration(days: 20)),
          timeLimit: const Duration(minutes: 30),
          totalQuestions: 5,
          totalPoints: 50,
          isRandomized: true,
          allowRetake: true,
          maxAttempts: 3,
          showCorrectAnswers: true,
          showExplanations: true,
          showScore: true,
          tags: ['programming', 'fundamentals', 'cs101'],
          category: 'Technology',
          subject: 'Computer Science',
          difficulty: 2,
          totalAttempts: 12,
          averageScore: 78.5,
          averageTime: const Duration(minutes: 22),
          lastTakenAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        QuizModel(
          id: 'cs101_quiz2',
          name: 'Data Structures Assessment',
          description:
              'Evaluate your understanding of arrays, linked lists, and trees',
          deckId: 'cs101_deck2',
          questionIds: ['cs101_q6', 'cs101_q7', 'cs101_q8', 'cs101_q9'],
          status: QuizStatus.published,
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 15)),
          timeLimit: const Duration(minutes: 45),
          totalQuestions: 4,
          totalPoints: 40,
          isRandomized: false,
          allowRetake: true,
          maxAttempts: 2,
          showCorrectAnswers: true,
          showExplanations: true,
          showScore: true,
          tags: ['data-structures', 'algorithms', 'cs101'],
          category: 'Technology',
          subject: 'Computer Science',
          difficulty: 3,
          totalAttempts: 8,
          averageScore: 72.0,
          averageTime: const Duration(minutes: 35),
          lastTakenAt: DateTime.now().subtract(const Duration(days: 1)),
        ),

        // Biology Advanced Quizzes
        QuizModel(
          id: 'bio_adv_quiz1',
          name: 'Cell Biology Mastery Test',
          description: 'Comprehensive test on cell structure and function',
          deckId: 'bio_adv_deck1',
          questionIds: [
            'bio_q1',
            'bio_q2',
            'bio_q3',
            'bio_q4',
            'bio_q5',
            'bio_q6',
          ],
          status: QuizStatus.published,
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 22)),
          updatedAt: DateTime.now().subtract(const Duration(days: 18)),
          timeLimit: const Duration(minutes: 40),
          totalQuestions: 6,
          totalPoints: 60,
          isRandomized: true,
          allowRetake: true,
          maxAttempts: 0, // Unlimited
          showCorrectAnswers: true,
          showExplanations: true,
          showScore: true,
          tags: ['cell-biology', 'biology', 'advanced'],
          category: 'Science',
          subject: 'Biology',
          difficulty: 4,
          totalAttempts: 15,
          averageScore: 85.2,
          averageTime: const Duration(minutes: 32),
          lastTakenAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),

        // World History Quizzes
        QuizModel(
          id: 'hist_quiz1',
          name: 'Ancient Civilizations Quiz',
          description: 'Test your knowledge of ancient Egypt, Greece, and Rome',
          deckId: 'hist_deck1',
          questionIds: ['hist_q1', 'hist_q2', 'hist_q3', 'hist_q4'],
          status: QuizStatus.published,
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 18)),
          updatedAt: DateTime.now().subtract(const Duration(days: 12)),
          timeLimit: const Duration(minutes: 25),
          totalQuestions: 4,
          totalPoints: 40,
          isRandomized: false,
          allowRetake: true,
          maxAttempts: 5,
          showCorrectAnswers: true,
          showExplanations: true,
          showScore: true,
          tags: ['ancient-history', 'civilizations', 'world-history'],
          category: 'Social Science',
          subject: 'History',
          difficulty: 2,
          totalAttempts: 20,
          averageScore: 88.0,
          averageTime: const Duration(minutes: 18),
          lastTakenAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        QuizModel(
          id: 'hist_quiz2',
          name: 'Medieval Period Assessment',
          description: 'Evaluate understanding of medieval Europe and Asia',
          deckId: 'hist_deck2',
          questionIds: ['hist_q5', 'hist_q6', 'hist_q7', 'hist_q8', 'hist_q9'],
          status: QuizStatus.published,
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10)),
          timeLimit: const Duration(minutes: 35),
          totalQuestions: 5,
          totalPoints: 50,
          isRandomized: true,
          allowRetake: true,
          maxAttempts: 3,
          showCorrectAnswers: true,
          showExplanations: true,
          showScore: true,
          tags: ['medieval-history', 'europe', 'asia', 'world-history'],
          category: 'Social Science',
          subject: 'History',
          difficulty: 3,
          totalAttempts: 12,
          averageScore: 76.5,
          averageTime: const Duration(minutes: 28),
          lastTakenAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        QuizModel(
          id: 'hist_quiz3',
          name: 'Modern World History Test',
          description: 'Comprehensive test on 20th century world events',
          deckId: 'hist_deck3',
          questionIds: [
            'hist_q10',
            'hist_q11',
            'hist_q12',
            'hist_q13',
            'hist_q14',
            'hist_q15',
          ],
          status: QuizStatus.published,
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
          updatedAt: DateTime.now().subtract(const Duration(days: 8)),
          timeLimit: const Duration(minutes: 50),
          totalQuestions: 6,
          totalPoints: 60,
          isRandomized: true,
          allowRetake: true,
          maxAttempts: 2,
          showCorrectAnswers: true,
          showExplanations: true,
          showScore: true,
          tags: ['modern-history', '20th-century', 'world-events'],
          category: 'Social Science',
          subject: 'History',
          difficulty: 4,
          totalAttempts: 8,
          averageScore: 82.3,
          averageTime: const Duration(minutes: 42),
          lastTakenAt: DateTime.now().subtract(const Duration(days: 1)),
        ),

        // Mathematics Quizzes
        QuizModel(
          id: 'math_quiz1',
          name: 'Algebra Fundamentals Quiz',
          description:
              'Test your algebra skills including equations and functions',
          deckId: 'math_deck1',
          questionIds: ['math_q1', 'math_q2', 'math_q3', 'math_q4', 'math_q5'],
          status: QuizStatus.published,
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
          updatedAt: DateTime.now().subtract(const Duration(days: 9)),
          timeLimit: const Duration(minutes: 30),
          totalQuestions: 5,
          totalPoints: 50,
          isRandomized: true,
          allowRetake: true,
          maxAttempts: 0, // Unlimited
          showCorrectAnswers: true,
          showExplanations: true,
          showScore: true,
          tags: ['algebra', 'equations', 'functions', 'mathematics'],
          category: 'Mathematics',
          subject: 'Mathematics',
          difficulty: 2,
          totalAttempts: 25,
          averageScore: 79.6,
          averageTime: const Duration(minutes: 24),
          lastTakenAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        QuizModel(
          id: 'math_quiz2',
          name: 'Calculus Challenge',
          description:
              'Advanced calculus problems including derivatives and integrals',
          deckId: 'math_deck3',
          questionIds: ['math_q6', 'math_q7', 'math_q8', 'math_q9', 'math_q10'],
          status: QuizStatus.published,
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 6)),
          timeLimit: const Duration(minutes: 60),
          totalQuestions: 5,
          totalPoints: 50,
          isRandomized: false,
          allowRetake: true,
          maxAttempts: 2,
          showCorrectAnswers: true,
          showExplanations: true,
          showScore: true,
          tags: ['calculus', 'derivatives', 'integrals', 'advanced-math'],
          category: 'Mathematics',
          subject: 'Mathematics',
          difficulty: 5,
          totalAttempts: 6,
          averageScore: 68.3,
          averageTime: const Duration(minutes: 52),
          lastTakenAt: DateTime.now().subtract(const Duration(days: 3)),
        ),

        // Spanish Language Quizzes
        QuizModel(
          id: 'spanish_quiz1',
          name: 'Spanish Vocabulary Test',
          description: 'Test your Spanish vocabulary and common phrases',
          deckId: 'spanish_deck1',
          questionIds: ['spanish_q1', 'spanish_q2', 'spanish_q3', 'spanish_q4'],
          status: QuizStatus.published,
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          timeLimit: const Duration(minutes: 20),
          totalQuestions: 4,
          totalPoints: 40,
          isRandomized: true,
          allowRetake: true,
          maxAttempts: 0, // Unlimited
          showCorrectAnswers: true,
          showExplanations: true,
          showScore: true,
          tags: ['spanish', 'vocabulary', 'language-learning', 'beginner'],
          category: 'Language',
          subject: 'Spanish',
          difficulty: 1,
          totalAttempts: 18,
          averageScore: 91.7,
          averageTime: const Duration(minutes: 15),
          lastTakenAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

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
