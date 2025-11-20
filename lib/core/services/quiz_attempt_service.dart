import '../../data/models/quiz_attempt_model.dart';
import '../../data/models/quiz_attempt_answer_model.dart';
import '../../data/remote/supabase_client.dart';
import '../../core/utils/logger.dart';
import 'package:uuid/uuid.dart';

/// Service for managing quiz attempts
class QuizAttemptService {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final Uuid _uuid = const Uuid();

  /// Create a new quiz attempt
  Future<QuizAttemptModel> createAttempt({
    required String quizId,
    required String userId,
    required int totalQuestions,
  }) async {
    try {
      Logger.info('Creating quiz attempt for quiz: $quizId');

      // Get next attempt number
      final attemptNumber = await _supabaseService.getNextQuizAttemptNumber(
        quizId,
        userId,
      );

      final now = DateTime.now();
      final attempt = QuizAttemptModel(
        id: _uuid.v4(),
        quizId: quizId,
        userId: userId,
        startedAt: now,
        status: QuizAttemptStatus.inProgress,
        totalQuestions: totalQuestions,
        correctAnswers: 0,
        scorePercentage: 0.0,
        totalTimeSeconds: 0,
        attemptNumber: attemptNumber,
        createdAt: now,
        updatedAt: now,
      );

      final created = await _supabaseService.createQuizAttempt(attempt);
      Logger.info('Quiz attempt created: ${created.id}');
      return created;
    } catch (e) {
      Logger.error('Failed to create quiz attempt: $e');
      rethrow;
    }
  }

  /// Save an answer for a question
  Future<QuizAttemptAnswerModel> saveAnswer({
    required String attemptId,
    required String questionId,
    required List<String> userAnswers,
    required bool isCorrect,
    required int timeSpentSeconds,
    required int order,
  }) async {
    try {
      Logger.info(
        'Saving answer for attempt: $attemptId, question: $questionId',
      );

      final answer = QuizAttemptAnswerModel(
        id: _uuid.v4(),
        attemptId: attemptId,
        questionId: questionId,
        userAnswers: userAnswers,
        isCorrect: isCorrect,
        answeredAt: DateTime.now(),
        timeSpentSeconds: timeSpentSeconds,
        order: order,
      );

      final saved = await _supabaseService.saveQuizAnswer(answer);
      Logger.info('Answer saved: ${saved.id}');
      return saved;
    } catch (e) {
      Logger.error('Failed to save answer: $e');
      rethrow;
    }
  }

  /// Update attempt with new answer
  Future<QuizAttemptModel> updateAttemptWithAnswer({
    required QuizAttemptModel attempt,
    required bool isCorrect,
    required int timeSpentSeconds,
  }) async {
    try {
      final updatedCorrectAnswers =
          isCorrect ? attempt.correctAnswers + 1 : attempt.correctAnswers;
      final updatedTotalTime = attempt.totalTimeSeconds + timeSpentSeconds;
      final updatedScorePercentage = attempt.totalQuestions > 0
          ? (updatedCorrectAnswers / attempt.totalQuestions) * 100
          : 0.0;

      final updated = attempt.copyWith(
        correctAnswers: updatedCorrectAnswers,
        scorePercentage: updatedScorePercentage,
        totalTimeSeconds: updatedTotalTime,
        updatedAt: DateTime.now(),
      );

      final saved = await _supabaseService.updateQuizAttempt(updated);
      Logger.info('Attempt updated: ${saved.id}');
      return saved;
    } catch (e) {
      Logger.error('Failed to update attempt: $e');
      rethrow;
    }
  }

  /// Complete a quiz attempt
  Future<QuizAttemptModel> completeAttempt(QuizAttemptModel attempt) async {
    try {
      Logger.info('Completing quiz attempt: ${attempt.id}');

      final completed = attempt.copyWith(
        status: QuizAttemptStatus.completed,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await _supabaseService.updateQuizAttempt(completed);
      Logger.info('Quiz attempt completed: ${saved.id}');
      return saved;
    } catch (e) {
      Logger.error('Failed to complete quiz attempt: $e');
      rethrow;
    }
  }

  /// Abandon a quiz attempt
  Future<QuizAttemptModel> abandonAttempt(QuizAttemptModel attempt) async {
    try {
      Logger.info('Abandoning quiz attempt: ${attempt.id}');

      final abandoned = attempt.copyWith(
        status: QuizAttemptStatus.abandoned,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await _supabaseService.updateQuizAttempt(abandoned);
      Logger.info('Quiz attempt abandoned: ${saved.id}');
      return saved;
    } catch (e) {
      Logger.error('Failed to abandon quiz attempt: $e');
      rethrow;
    }
  }

  /// Get attempts for a quiz
  Future<List<QuizAttemptModel>> getAttemptsByQuiz(String quizId) async {
    try {
      Logger.info('Getting attempts for quiz: $quizId');
      return await _supabaseService.getQuizAttempts(quizId);
    } catch (e) {
      Logger.error('Failed to get quiz attempts: $e');
      rethrow;
    }
  }

  /// Get attempts for a user
  Future<List<QuizAttemptModel>> getAttemptsByUser(String userId) async {
    try {
      Logger.info('Getting attempts for user: $userId');
      return await _supabaseService.getUserQuizAttempts(userId);
    } catch (e) {
      Logger.error('Failed to get user quiz attempts: $e');
      rethrow;
    }
  }

  /// Get answers for an attempt
  Future<List<QuizAttemptAnswerModel>> getAttemptAnswers(
    String attemptId,
  ) async {
    try {
      Logger.info('Getting answers for attempt: $attemptId');
      return await _supabaseService.getAttemptAnswers(attemptId);
    } catch (e) {
      Logger.error('Failed to get attempt answers: $e');
      rethrow;
    }
  }
}

