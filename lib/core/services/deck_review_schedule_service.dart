import '../../data/remote/supabase_client.dart';
import '../../core/utils/logger.dart';

/// Service for managing deck review schedules
class DeckReviewScheduleService {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Calculate and update the next review date for a deck
  Future<void> updateDeckReviewSchedule(String deckId, String userId) async {
    try {
      final client = _supabaseService.client;

      // Get all flashcards in the deck with FSRS state
      final flashcardsResponse = await client
          .from('flashcards')
          .select('id, fsrs_state')
          .eq('deck_id', deckId);

      if (flashcardsResponse.isEmpty) {
        // No flashcards, remove schedule if exists
        await _removeSchedule(deckId, userId);
        return;
      }

      final flashcards = flashcardsResponse as List;
      DateTime? earliestDueDate;
      int cardsDueCount = 0;
      int cardsLearningCount = 0;
      int cardsReviewCount = 0;
      int cardsRelearningCount = 0;

      final now = DateTime.now();

      for (final flashcard in flashcards) {
        final fsrsState = flashcard['fsrs_state'] as Map<String, dynamic>?;
        if (fsrsState == null) {
          // Card without FSRS state is considered due
          cardsDueCount++;
          if (earliestDueDate == null || now.isBefore(earliestDueDate)) {
            earliestDueDate = now;
          }
          continue;
        }

        final dueStr = fsrsState['due'] as String?;
        if (dueStr == null) continue;

        final due = DateTime.parse(dueStr);
        final state = fsrsState['state'] as String?;

        // Count cards by state
        switch (state) {
          case 'learning':
            cardsLearningCount++;
            break;
          case 'review':
            cardsReviewCount++;
            break;
          case 'relearning':
            cardsRelearningCount++;
            break;
        }

        // Check if due
        if (due.isBefore(now) || due.isAtSameMomentAs(now)) {
          cardsDueCount++;
        }

        // Track earliest due date
        if (earliestDueDate == null || due.isBefore(earliestDueDate)) {
          earliestDueDate = due;
        }
      }

      // Get latest attempt
      final latestAttempt = await client
          .from('deck_attempts')
          .select('id, completed_at')
          .eq('deck_id', deckId)
          .eq('user_id', userId)
          .eq('status', 'completed')
          .order('completed_at', ascending: false)
          .limit(1)
          .maybeSingle();

      // Upsert the schedule
      await client.from('deck_review_schedules').upsert({
        'deck_id': deckId,
        'user_id': userId,
        'next_review_date': earliestDueDate?.toIso8601String(),
        'cards_due_count': cardsDueCount,
        'cards_learning_count': cardsLearningCount,
        'cards_review_count': cardsReviewCount,
        'cards_relearning_count': cardsRelearningCount,
        'last_attempt_id': latestAttempt?['id'],
        'last_attempt_at': latestAttempt?['completed_at'],
      });

      Logger.info('Deck review schedule updated: $deckId');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to update deck review schedule: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get the next review date for a deck
  Future<DateTime?> getDeckNextReviewDate(String deckId, String userId) async {
    try {
      final client = _supabaseService.client;

      final response = await client
          .from('deck_review_schedules')
          .select('next_review_date')
          .eq('deck_id', deckId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      final nextReviewDateStr = response['next_review_date'] as String?;
      if (nextReviewDateStr == null) return null;

      return DateTime.parse(nextReviewDateStr);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to get deck next review date: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get all decks due for review for a user
  Future<List<Map<String, dynamic>>> getDueDecks(String userId) async {
    try {
      final client = _supabaseService.client;
      final now = DateTime.now().toIso8601String();

      final response = await client
          .from('deck_review_schedules')
          .select('''
            deck_id,
            next_review_date,
            cards_due_count,
            decks:deck_id (
              id,
              name,
              description
            )
          ''')
          .eq('user_id', userId)
          .lte('next_review_date', now)
          .gt('cards_due_count', 0)
          .order('next_review_date', ascending: true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to get due decks: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Get upcoming deck reviews (next N reviews, including due ones)
  Future<List<Map<String, dynamic>>> getUpcomingDeckReviews(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final client = _supabaseService.client;

      final response = await client
          .from('deck_review_schedules')
          .select('''
            deck_id,
            next_review_date,
            cards_due_count,
            cards_learning_count,
            cards_review_count,
            cards_relearning_count,
            decks:deck_id (
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
        'Failed to get upcoming deck reviews: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Remove schedule for a deck
  Future<void> _removeSchedule(String deckId, String userId) async {
    try {
      final client = _supabaseService.client;
      await client
          .from('deck_review_schedules')
          .delete()
          .eq('deck_id', deckId)
          .eq('user_id', userId);
    } catch (e) {
      Logger.warning('Failed to remove deck schedule: $e');
    }
  }
}

