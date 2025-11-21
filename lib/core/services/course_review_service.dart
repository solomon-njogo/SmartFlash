import '../../data/models/quiz_attempt_model.dart';
import '../../data/models/deck_attempt_model.dart';
import '../../data/remote/supabase_client.dart';
import '../utils/logger.dart';
import 'quiz_attempt_service.dart';
import 'deck_attempt_service.dart';

/// Service for managing course review history
class CourseReviewService {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final QuizAttemptService _quizAttemptService = QuizAttemptService();
  final DeckAttemptService _deckAttemptService = DeckAttemptService();

  /// Get all completed quiz attempts for a course
  Future<List<QuizAttemptModel>> getCourseQuizAttempts(
    String courseId,
    String userId,
  ) async {
    try {
      Logger.info('Getting quiz attempts for course: $courseId');

      // Get all quizzes for the course
      final quizzes = await _supabaseService.getCourseQuizzes(courseId);

      if (quizzes.isEmpty) {
        Logger.info('No quizzes found for course: $courseId');
        return [];
      }

      // Get all attempts for each quiz
      final List<QuizAttemptModel> allAttempts = [];
      for (final quiz in quizzes) {
        try {
          final attempts = await _quizAttemptService.getAttemptsByQuiz(quiz.id);
          // Filter only completed attempts
          final completedAttempts = attempts
              .where((a) =>
                  a.status == QuizAttemptStatus.completed &&
                  a.userId == userId)
              .toList();
          allAttempts.addAll(completedAttempts);
        } catch (e) {
          Logger.warning(
            'Failed to get attempts for quiz ${quiz.id}: $e',
          );
          // Continue with other quizzes
        }
      }

      // Sort by started_at descending (most recent first)
      allAttempts.sort((a, b) => b.startedAt.compareTo(a.startedAt));

      Logger.info(
        'Found ${allAttempts.length} completed quiz attempts for course: $courseId',
      );
      return allAttempts;
    } catch (e) {
      Logger.error('Failed to get course quiz attempts: $e');
      rethrow;
    }
  }

  /// Get all completed deck attempts for a course
  Future<List<DeckAttemptModel>> getCourseDeckAttempts(
    String courseId,
    String userId,
  ) async {
    try {
      Logger.info('Getting deck attempts for course: $courseId');

      // Get all decks for the course
      final decks = await _supabaseService.getCourseDecks(courseId);

      if (decks.isEmpty) {
        Logger.info('No decks found for course: $courseId');
        return [];
      }

      // Get all attempts for each deck
      final List<DeckAttemptModel> allAttempts = [];
      for (final deck in decks) {
        try {
          final attempts = await _deckAttemptService.getAttemptsByDeck(deck.id);
          // Filter only completed attempts
          final completedAttempts = attempts
              .where((a) =>
                  a.status == DeckAttemptStatus.completed &&
                  a.userId == userId)
              .toList();
          allAttempts.addAll(completedAttempts);
        } catch (e) {
          Logger.warning(
            'Failed to get attempts for deck ${deck.id}: $e',
          );
          // Continue with other decks
        }
      }

      // Sort by started_at descending (most recent first)
      allAttempts.sort((a, b) => b.startedAt.compareTo(a.startedAt));

      Logger.info(
        'Found ${allAttempts.length} completed deck attempts for course: $courseId',
      );
      return allAttempts;
    } catch (e) {
      Logger.error('Failed to get course deck attempts: $e');
      rethrow;
    }
  }
}

