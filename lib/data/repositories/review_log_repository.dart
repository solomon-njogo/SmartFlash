import 'package:fsrs/fsrs.dart';
import '../models/review_log_model.dart';
import '../remote/supabase_client.dart';
import '../../core/utils/logger.dart';

/// Repository for managing review logs in the database
class ReviewLogRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Save a review log to the database
  Future<void> saveReviewLog(ReviewLogModel reviewLog) async {
    try {
      final client = _supabaseService.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final data = {
        'id': reviewLog.id,
        'card_id': reviewLog.cardId,
        'card_type': reviewLog.cardType,
        'user_id': userId,
        'rating': reviewLog.rating.name,
        'review_datetime': reviewLog.reviewDateTime.toIso8601String(),
        'scheduled_days': reviewLog.scheduledDays,
        'elapsed_days': reviewLog.elapsedDays,
        'state': reviewLog.state.name,
        'card_state': reviewLog.cardState.name,
        'response_time': reviewLog.responseTime,
        'stability': reviewLog.stability,
        'difficulty': reviewLog.difficulty,
        'retrievability': reviewLog.retrievability,
        'metadata': reviewLog.metadata,
      };

      await client.from('review_logs').insert(data);
      Logger.info('Review log saved: ${reviewLog.id}');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to save review log: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get review logs for a specific card
  Future<List<ReviewLogModel>> getReviewLogsForCard(
    String cardId,
    String cardType,
  ) async {
    try {
      final client = _supabaseService.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .from('review_logs')
          .select()
          .eq('card_id', cardId)
          .eq('card_type', cardType)
          .eq('user_id', userId)
          .order('review_datetime', ascending: false);

      return (response as List)
          .map((json) => _reviewLogFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to get review logs for card: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get review logs for a user
  Future<List<ReviewLogModel>> getReviewLogsForUser({
    String? cardType,
    int? limit,
    DateTime? since,
  }) async {
    try {
      final client = _supabaseService.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      var query = client
          .from('review_logs')
          .select()
          .eq('user_id', userId);

      if (cardType != null) {
        query = query.eq('card_type', cardType) as dynamic;
      }

      if (since != null) {
        query = query.gte('review_datetime', since.toIso8601String()) as dynamic;
      }

      query = query.order('review_datetime', ascending: false) as dynamic;

      if (limit != null) {
        query = query.limit(limit) as dynamic;
      }

      final response = await query;

      return (response as List)
          .map((json) => _reviewLogFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to get review logs for user: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Convert database JSON to ReviewLogModel
  ReviewLogModel _reviewLogFromJson(Map<String, dynamic> json) {
    return ReviewLogModel(
      id: json['id'] as String,
      cardId: json['card_id'] as String,
      cardType: json['card_type'] as String,
      rating: _ratingFromString(json['rating'] as String),
      reviewDateTime: DateTime.parse(json['review_datetime'] as String),
      scheduledDays: json['scheduled_days'] as int,
      elapsedDays: json['elapsed_days'] as int,
      state: _stateFromString(json['state'] as String),
      cardState: _stateFromString(json['card_state'] as String),
      responseTime: (json['response_time'] as num?)?.toDouble() ?? 0.0,
      userId: json['user_id'] as String?,
      stability: (json['stability'] as num?)?.toDouble(),
      difficulty: (json['difficulty'] as num?)?.toDouble(),
      retrievability: (json['retrievability'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert rating string to Rating enum
  Rating _ratingFromString(String value) {
    switch (value.toLowerCase()) {
      case 'again':
        return Rating.again;
      case 'hard':
        return Rating.hard;
      case 'good':
        return Rating.good;
      case 'easy':
        return Rating.easy;
      default:
        return Rating.good;
    }
  }

  /// Convert state string to State enum
  State _stateFromString(String value) {
    switch (value.toLowerCase()) {
      case 'learning':
        return State.learning;
      case 'review':
        return State.review;
      case 'relearning':
        return State.relearning;
      default:
        return State.learning;
    }
  }
}

