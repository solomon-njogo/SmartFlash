import '../../data/remote/supabase_client.dart';
import '../../core/utils/logger.dart';

/// Service for managing quiz review schedules
class QuizReviewScheduleService {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Calculate and update the next review date for a quiz
  Future<void> updateQuizReviewSchedule(String quizId, String userId) async {
    try {
      final client = _supabaseService.client;

      // Get all questions in the quiz with FSRS state
      final questionsResponse = await client
          .from('questions')
          .select('id, fsrs_state')
          .eq('quiz_id', quizId);

      if (questionsResponse.isEmpty) {
        // No questions, remove schedule if exists
        await _removeSchedule(quizId, userId);
        return;
      }

      final questions = questionsResponse as List;
      DateTime? earliestDueDate;
      int questionsDueCount = 0;
      int questionsLearningCount = 0;
      int questionsReviewCount = 0;
      int questionsRelearningCount = 0;

      final now = DateTime.now();

      for (final question in questions) {
        final fsrsState = question['fsrs_state'] as Map<String, dynamic>?;
        if (fsrsState == null) {
          // Question without FSRS state is considered due
          questionsDueCount++;
          if (earliestDueDate == null || now.isBefore(earliestDueDate)) {
            earliestDueDate = now;
          }
          continue;
        }

        final dueStr = fsrsState['due'] as String?;
        if (dueStr == null) continue;

        final due = DateTime.parse(dueStr);
        final state = fsrsState['state'] as String?;

        // Count questions by state
        switch (state) {
          case 'learning':
            questionsLearningCount++;
            break;
          case 'review':
            questionsReviewCount++;
            break;
          case 'relearning':
            questionsRelearningCount++;
            break;
        }

        // Check if due
        if (due.isBefore(now) || due.isAtSameMomentAs(now)) {
          questionsDueCount++;
        }

        // Track earliest due date
        if (earliestDueDate == null || due.isBefore(earliestDueDate)) {
          earliestDueDate = due;
        }
      }

      // Get latest attempt
      final latestAttempt = await client
          .from('quiz_attempts')
          .select('id, completed_at')
          .eq('quiz_id', quizId)
          .eq('user_id', userId)
          .eq('status', 'completed')
          .order('completed_at', ascending: false)
          .limit(1)
          .maybeSingle();

      // Upsert the schedule
      await client.from('quiz_review_schedules').upsert({
        'quiz_id': quizId,
        'user_id': userId,
        'next_review_date': earliestDueDate?.toIso8601String(),
        'questions_due_count': questionsDueCount,
        'questions_learning_count': questionsLearningCount,
        'questions_review_count': questionsReviewCount,
        'questions_relearning_count': questionsRelearningCount,
        'last_attempt_id': latestAttempt?['id'],
        'last_attempt_at': latestAttempt?['completed_at'],
      });

      Logger.info('Quiz review schedule updated: $quizId');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to update quiz review schedule: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get the next review date for a quiz
  Future<DateTime?> getQuizNextReviewDate(String quizId, String userId) async {
    try {
      final client = _supabaseService.client;

      final response = await client
          .from('quiz_review_schedules')
          .select('next_review_date')
          .eq('quiz_id', quizId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      final nextReviewDateStr = response['next_review_date'] as String?;
      if (nextReviewDateStr == null) return null;

      return DateTime.parse(nextReviewDateStr);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to get quiz next review date: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get all quizzes due for review for a user
  Future<List<Map<String, dynamic>>> getDueQuizzes(String userId) async {
    try {
      final client = _supabaseService.client;
      final now = DateTime.now().toIso8601String();

      final response = await client
          .from('quiz_review_schedules')
          .select('''
            quiz_id,
            next_review_date,
            questions_due_count,
            quizzes:quiz_id (
              id,
              name,
              description
            )
          ''')
          .eq('user_id', userId)
          .lte('next_review_date', now)
          .gt('questions_due_count', 0)
          .order('next_review_date', ascending: true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to get due quizzes: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Get upcoming quiz reviews (next N reviews, including due ones)
  Future<List<Map<String, dynamic>>> getUpcomingQuizReviews(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final client = _supabaseService.client;

      final response = await client
          .from('quiz_review_schedules')
          .select('''
            quiz_id,
            next_review_date,
            questions_due_count,
            questions_learning_count,
            questions_review_count,
            questions_relearning_count,
            quizzes:quiz_id (
              id,
              name,
              description
            )
          ''')
          .eq('user_id', userId)
          .not('next_review_date', 'is', null)
          .order('next_review_date', ascending: true)
          .limit(limit);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to get upcoming quiz reviews: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Remove schedule for a quiz
  Future<void> _removeSchedule(String quizId, String userId) async {
    try {
      final client = _supabaseService.client;
      await client
          .from('quiz_review_schedules')
          .delete()
          .eq('quiz_id', quizId)
          .eq('user_id', userId);
    } catch (e) {
      Logger.warning('Failed to remove quiz schedule: $e');
    }
  }
}

