import 'package:flutter/foundation.dart';
import '../../data/models/course_model.dart';

/// Course provider for managing course-related state
class CourseProvider extends ChangeNotifier {
  List<CourseModel> _courses = [];
  bool _isLoading = false;
  String? _error;
  CourseModel? _selectedCourse;

  /// List of all courses
  List<CourseModel> get courses => _courses;

  /// Whether data is loading
  bool get isLoading => _isLoading;

  /// Current error message
  String? get error => _error;

  /// Currently selected course
  CourseModel? get selectedCourse => _selectedCourse;

  CourseProvider() {
    _loadCourses();
  }

  /// Load all courses from local storage
  Future<void> _loadCourses() async {
    try {
      _setLoading(true);
      _clearError();

      // Sample data for 5 courses as specified in the plan
      _courses = [
        CourseModel(
          id: 'cs101',
          name: 'Computer Science 101',
          description:
              'Introduction to programming, data structures, and algorithms',
          iconName: 'laptop',
          colorValue: 0xFF2196F3, // Blue
          deckIds: ['cs101_deck1', 'cs101_deck2', 'cs101_deck3'],
          quizIds: ['cs101_quiz1', 'cs101_quiz2'],
          materialIds: ['cs101_mat1', 'cs101_mat2', 'cs101_mat3', 'cs101_mat4'],
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Technology',
          subject: 'Computer Science',
          totalDecks: 3,
          totalQuizzes: 2,
          totalMaterials: 4,
          lastAccessedAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['programming', 'algorithms', 'data-structures'],
        ),
        CourseModel(
          id: 'bio_adv',
          name: 'Biology Advanced',
          description: 'Advanced topics in cell biology and genetics',
          iconName: 'biotech',
          colorValue: 0xFF4CAF50, // Green
          deckIds: ['bio_adv_deck1', 'bio_adv_deck2'],
          quizIds: ['bio_adv_quiz1'],
          materialIds: ['bio_adv_mat1', 'bio_adv_mat2', 'bio_adv_mat3'],
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          category: 'Science',
          subject: 'Biology',
          totalDecks: 2,
          totalQuizzes: 1,
          totalMaterials: 3,
          lastAccessedAt: DateTime.now().subtract(const Duration(days: 3)),
          tags: ['biology', 'genetics', 'cell-biology'],
        ),
        CourseModel(
          id: 'world_history',
          name: 'World History',
          description: 'Comprehensive study of world civilizations and events',
          iconName: 'public',
          colorValue: 0xFF8D6E63, // Brown
          deckIds: ['hist_deck1', 'hist_deck2', 'hist_deck3'],
          quizIds: ['hist_quiz1', 'hist_quiz2', 'hist_quiz3'],
          materialIds: ['hist_mat1', 'hist_mat2'],
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          category: 'Social Science',
          subject: 'History',
          totalDecks: 3,
          totalQuizzes: 3,
          totalMaterials: 2,
          lastAccessedAt: DateTime.now().subtract(const Duration(days: 2)),
          tags: ['history', 'civilizations', 'world-events'],
        ),
        CourseModel(
          id: 'math_course',
          name: 'Mathematics',
          description:
              'Comprehensive mathematics covering algebra, geometry, calculus, and statistics',
          iconName: 'calculate',
          colorValue: 0xFF9C27B0, // Purple
          deckIds: ['math_deck1', 'math_deck2', 'math_deck3', 'math_deck4'],
          quizIds: ['math_quiz1', 'math_quiz2'],
          materialIds: [
            'math_mat1',
            'math_mat2',
            'math_mat3',
            'math_mat4',
            'math_mat5',
          ],
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now().subtract(const Duration(days: 4)),
          category: 'Mathematics',
          subject: 'Mathematics',
          totalDecks: 4,
          totalQuizzes: 2,
          totalMaterials: 5,
          lastAccessedAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['algebra', 'geometry', 'calculus', 'statistics'],
        ),
        CourseModel(
          id: 'spanish_lang',
          name: 'Language Learning - Spanish',
          description: 'Spanish vocabulary and common phrases for beginners',
          iconName: 'translate',
          colorValue: 0xFFFF9800, // Orange
          deckIds: ['spanish_deck1', 'spanish_deck2'],
          quizIds: ['spanish_quiz1'],
          materialIds: ['spanish_mat1', 'spanish_mat2', 'spanish_mat3'],
          createdBy: 'user1',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Language',
          subject: 'Spanish',
          totalDecks: 2,
          totalQuizzes: 1,
          totalMaterials: 3,
          lastAccessedAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['spanish', 'vocabulary', 'language-learning'],
        ),
      ];
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh courses from storage
  Future<void> refreshCourses() async {
    await _loadCourses();
  }

  /// Create a new course
  Future<bool> createCourse(CourseModel course) async {
    try {
      _setLoading(true);
      _clearError();

      _courses.add(course);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing course
  Future<bool> updateCourse(CourseModel course) async {
    try {
      _setLoading(true);
      _clearError();

      final index = _courses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        _courses[index] = course;
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

  /// Delete a course
  Future<bool> deleteCourse(String courseId) async {
    try {
      _setLoading(true);
      _clearError();

      _courses.removeWhere((course) => course.id == courseId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get course by ID
  CourseModel? getCourseById(String courseId) {
    try {
      return _courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  /// Set selected course
  void selectCourse(CourseModel course) {
    _selectedCourse = course;
    notifyListeners();
  }

  /// Clear selected course
  void clearSelectedCourse() {
    _selectedCourse = null;
    notifyListeners();
  }

  /// Search courses by name
  List<CourseModel> searchCourses(String query) {
    if (query.isEmpty) return _courses;

    return _courses
        .where(
          (course) =>
              course.name.toLowerCase().contains(query.toLowerCase()) ||
              (course.description?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false),
        )
        .toList();
  }

  /// Get courses by category
  List<CourseModel> getCoursesByCategory(String category) {
    return _courses.where((course) => course.category == category).toList();
  }

  /// Get courses by subject
  List<CourseModel> getCoursesBySubject(String subject) {
    return _courses.where((course) => course.subject == subject).toList();
  }

  /// Get recently accessed courses
  List<CourseModel> getRecentlyAccessedCourses() {
    return _courses.where((course) => course.isRecentlyAccessed).toList()..sort(
      (a, b) => (b.lastAccessedAt ?? DateTime(1970)).compareTo(
        a.lastAccessedAt ?? DateTime(1970),
      ),
    );
  }

  /// Get course deck count
  int getCourseDeckCount(String courseId) {
    final course = getCourseById(courseId);
    return course?.totalDecks ?? 0;
  }

  /// Get course quiz count
  int getCourseQuizCount(String courseId) {
    final course = getCourseById(courseId);
    return course?.totalQuizzes ?? 0;
  }

  /// Get course material count
  int getCourseMaterialCount(String courseId) {
    final course = getCourseById(courseId);
    return course?.totalMaterials ?? 0;
  }

  /// Update course statistics
  void updateCourseStatistics(
    String courseId, {
    int? totalDecks,
    int? totalQuizzes,
    int? totalMaterials,
  }) {
    final course = getCourseById(courseId);
    if (course != null) {
      final updatedCourse = course.copyWith(
        totalDecks: totalDecks ?? course.totalDecks,
        totalQuizzes: totalQuizzes ?? course.totalQuizzes,
        totalMaterials: totalMaterials ?? course.totalMaterials,
        updatedAt: DateTime.now(),
      );
      updateCourse(updatedCourse);
    }
  }

  /// Mark course as accessed
  void markCourseAsAccessed(String courseId) {
    final course = getCourseById(courseId);
    if (course != null) {
      final updatedCourse = course.copyWith(lastAccessedAt: DateTime.now());
      updateCourse(updatedCourse);
    }
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
