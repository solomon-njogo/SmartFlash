import '../../data/models/deck_attempt_model.dart';
import '../../data/models/deck_attempt_card_result.dart';
import '../../data/remote/supabase_client.dart';
import '../../core/utils/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:fsrs/fsrs.dart' hide State;
import 'deck_review_schedule_service.dart';

/// Service for managing deck study attempts
class DeckAttemptService {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final DeckReviewScheduleService _scheduleService = DeckReviewScheduleService();
  final Uuid _uuid = const Uuid();

  /// Create a new deck attempt
  Future<DeckAttemptModel> createAttempt({
    required String deckId,
    required String userId,
    required int totalCards,
  }) async {
    try {
      Logger.info('Creating deck attempt for deck: $deckId');

      // Get next attempt number
      final attemptNumber = await _supabaseService.getNextAttemptNumber(
        deckId,
        userId,
      );

      final now = DateTime.now();
      final attempt = DeckAttemptModel(
        id: _uuid.v4(),
        deckId: deckId,
        userId: userId,
        startedAt: now,
        status: DeckAttemptStatus.inProgress,
        totalCards: totalCards,
        cardsStudied: 0,
        cardsAgain: 0,
        cardsHard: 0,
        cardsGood: 0,
        cardsEasy: 0,
        totalTimeSeconds: 0,
        attemptNumber: attemptNumber,
        createdAt: now,
        updatedAt: now,
      );

      final created = await _supabaseService.createDeckAttempt(attempt);
      Logger.info('Deck attempt created: ${created.id}');
      return created;
    } catch (e) {
      Logger.error('Failed to create deck attempt: $e');
      rethrow;
    }
  }

  /// Save a card result for an attempt
  Future<DeckAttemptCardResult> saveCardResult({
    required String attemptId,
    required String flashcardId,
    required Rating rating,
    required int timeSpentSeconds,
    required int order,
  }) async {
    try {
      Logger.info(
        'Saving card result for attempt: $attemptId, flashcard: $flashcardId',
      );

      final cardResult = DeckAttemptCardResult(
        id: _uuid.v4(),
        attemptId: attemptId,
        flashcardId: flashcardId,
        rating: _ratingToString(rating),
        timeSpentSeconds: timeSpentSeconds,
        answeredAt: DateTime.now(),
        order: order,
      );

      final saved = await _supabaseService.saveCardResult(cardResult);
      Logger.info('Card result saved: ${saved.id}');
      return saved;
    } catch (e) {
      Logger.error('Failed to save card result: $e');
      rethrow;
    }
  }

  /// Update attempt with new card result
  Future<DeckAttemptModel> updateAttemptWithCardResult({
    required DeckAttemptModel attempt,
    required Rating rating,
    required int timeSpentSeconds,
  }) async {
    try {
      final updatedCardsStudied = attempt.cardsStudied + 1;
      final updatedCardsAgain = rating == Rating.again 
          ? attempt.cardsAgain + 1 
          : attempt.cardsAgain;
      final updatedCardsHard = rating == Rating.hard 
          ? attempt.cardsHard + 1 
          : attempt.cardsHard;
      final updatedCardsGood = rating == Rating.good 
          ? attempt.cardsGood + 1 
          : attempt.cardsGood;
      final updatedCardsEasy = rating == Rating.easy 
          ? attempt.cardsEasy + 1 
          : attempt.cardsEasy;
      final updatedTotalTime = attempt.totalTimeSeconds + timeSpentSeconds;

      final updated = attempt.copyWith(
        cardsStudied: updatedCardsStudied,
        cardsAgain: updatedCardsAgain,
        cardsHard: updatedCardsHard,
        cardsGood: updatedCardsGood,
        cardsEasy: updatedCardsEasy,
        totalTimeSeconds: updatedTotalTime,
        updatedAt: DateTime.now(),
      );

      final saved = await _supabaseService.updateDeckAttempt(updated);
      Logger.info('Attempt updated: ${saved.id}');
      return saved;
    } catch (e) {
      Logger.error('Failed to update attempt: $e');
      rethrow;
    }
  }

  /// Complete a deck attempt
  Future<DeckAttemptModel> completeAttempt(DeckAttemptModel attempt) async {
    try {
      Logger.info('Completing deck attempt: ${attempt.id}');

      final completed = attempt.copyWith(
        status: DeckAttemptStatus.completed,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await _supabaseService.updateDeckAttempt(completed);
      Logger.info('Deck attempt completed: ${saved.id}');
      
      // Update deck review schedule after completion
      try {
        await _scheduleService.updateDeckReviewSchedule(
          saved.deckId,
          saved.userId,
        );
      } catch (e) {
        Logger.warning('Failed to update deck review schedule: $e');
        // Don't fail the attempt completion if schedule update fails
      }
      
      return saved;
    } catch (e) {
      Logger.error('Failed to complete deck attempt: $e');
      rethrow;
    }
  }

  /// Abandon a deck attempt
  Future<DeckAttemptModel> abandonAttempt(DeckAttemptModel attempt) async {
    try {
      Logger.info('Abandoning deck attempt: ${attempt.id}');

      final abandoned = attempt.copyWith(
        status: DeckAttemptStatus.abandoned,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await _supabaseService.updateDeckAttempt(abandoned);
      Logger.info('Deck attempt abandoned: ${saved.id}');
      return saved;
    } catch (e) {
      Logger.error('Failed to abandon deck attempt: $e');
      rethrow;
    }
  }

  /// Get attempts for a deck
  Future<List<DeckAttemptModel>> getAttemptsByDeck(String deckId) async {
    try {
      Logger.info('Getting attempts for deck: $deckId');
      return await _supabaseService.getDeckAttempts(deckId);
    } catch (e) {
      Logger.error('Failed to get deck attempts: $e');
      rethrow;
    }
  }

  /// Get attempts for a user
  Future<List<DeckAttemptModel>> getAttemptsByUser(String userId) async {
    try {
      Logger.info('Getting attempts for user: $userId');
      return await _supabaseService.getUserDeckAttempts(userId);
    } catch (e) {
      Logger.error('Failed to get user attempts: $e');
      rethrow;
    }
  }

  /// Get card results for an attempt
  Future<List<DeckAttemptCardResult>> getAttemptCardResults(
    String attemptId,
  ) async {
    try {
      Logger.info('Getting card results for attempt: $attemptId');
      return await _supabaseService.getAttemptCardResults(attemptId);
    } catch (e) {
      Logger.error('Failed to get card results: $e');
      rethrow;
    }
  }

  /// Convert Rating enum to string
  String _ratingToString(Rating rating) {
    switch (rating) {
      case Rating.again:
        return 'again';
      case Rating.hard:
        return 'hard';
      case Rating.good:
        return 'good';
      case Rating.easy:
        return 'easy';
    }
  }
}
