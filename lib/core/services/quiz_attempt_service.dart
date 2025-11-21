import '../../data/models/quiz_attempt_model.dart';
import '../../data/models/quiz_attempt_answer_model.dart';
import '../../data/remote/supabase_client.dart';
import '../../core/utils/logger.dart';
import 'package:uuid/uuid.dart';
import 'quiz_review_schedule_service.dart';

/// Service for managing quiz study attempts
class QuizAttemptService {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final QuizReviewScheduleService _scheduleService = QuizReviewScheduleService();
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
      final attemptNumber = await _getNextAttemptNumber(quizId, userId);

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

  /// Save an answer for an attempt
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
        timeSpentSeconds: timeSpentSeconds,
        answeredAt: DateTime.now(),
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
      final updatedScore = (updatedCorrectAnswers / attempt.totalQuestions) * 100;

      final updated = attempt.copyWith(
        correctAnswers: updatedCorrectAnswers,
        scorePercentage: updatedScore,
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
      
      // Update quiz review schedule after completion
      try {
        await _scheduleService.updateQuizReviewSchedule(
          saved.quizId,
          saved.userId,
        );
      } catch (e) {
        Logger.warning('Failed to update quiz review schedule: $e');
        // Don't fail the attempt completion if schedule update fails
      }
      
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
      Logger.error('Failed to get user attempts: $e');
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
      Logger.error('Failed to get answers: $e');
      rethrow;
    }
  }

  /// Get next attempt number for a quiz
  Future<int> _getNextAttemptNumber(String quizId, String userId) async {
    try {
      final attempts = await _supabaseService.getUserQuizAttempts(userId);
      final quizAttempts = attempts.where((a) => a.quizId == quizId).toList();
      if (quizAttempts.isEmpty) return 1;
      return quizAttempts.map((a) => a.attemptNumber).reduce((a, b) => a > b ? a : b) + 1;
    } catch (e) {
      Logger.warning('Failed to get next attempt number, using 1: $e');
      return 1;
    }
  }
}
