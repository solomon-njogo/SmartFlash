import 'package:flutter/foundation.dart';
import '../../data/models/course_model.dart';
import '../../data/remote/course_remote.dart';
import '../../core/utils/logger.dart';

/// Course provider for managing course-related state
class CourseProvider extends ChangeNotifier {
  final CourseRemoteDataSource _remote = CourseRemoteDataSource();
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
      // Fetch courses from remote (Supabase). This replaces the previous
      // hard-coded sample data so that the app shows courses stored in the DB.
      final remoteCourses = await _remote.fetchCourses();
      _courses = remoteCourses;
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
      Logger.logUserAction(
        'CreateCourse:start',
        data: {'id': course.id, 'name': course.name},
      );
      // Persist remotely first (RLS uses auth user as created_by)
      await _remote.insertCourse(course);

      // On success, update local state
      _courses.add(course);
      notifyListeners();
      Logger.logUserAction('CreateCourse:success', data: {'id': course.id});
      return true;
    } catch (e, st) {
      Logger.logException(e, st, context: 'CourseProvider.createCourse');
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
