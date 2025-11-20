import 'package:hive/hive.dart';
import 'package:fsrs/fsrs.dart';
import '../../data/models/review_log_model.dart';
import '../../data/local/hive_service.dart';

/// Review Log Service for managing review history
class ReviewLogService {
  static final ReviewLogService _instance = ReviewLogService._internal();
  factory ReviewLogService() => _instance;
  ReviewLogService._internal();

  late Box<ReviewLogModel> _reviewLogBox;

  /// Initialize the service
  void initialize() {
    _reviewLogBox = HiveService.instance.reviewLogBox;
  }

  /// Save a review log
  Future<void> saveReviewLog(ReviewLogModel reviewLog) async {
    await _reviewLogBox.put(reviewLog.id, reviewLog);
  }

  /// Get review log by ID
  ReviewLogModel? getReviewLog(String id) {
    return _reviewLogBox.get(id);
  }

  /// Get all review logs for a specific card
  List<ReviewLogModel> getCardReviewHistory(String cardId) {
    return _reviewLogBox.values.where((log) => log.cardId == cardId).toList()
      ..sort((a, b) => b.reviewDateTime.compareTo(a.reviewDateTime));
  }

  /// Get recent review logs
  List<ReviewLogModel> getRecentReviews({int limit = 50, String? userId}) {
    var logs = _reviewLogBox.values.toList();

    if (userId != null) {
      logs = logs.where((log) => log.userId == userId).toList();
    }

    logs.sort((a, b) => b.reviewDateTime.compareTo(a.reviewDateTime));

    return logs.take(limit).toList();
  }

  /// Get review statistics for a card
  ReviewStats getReviewStats(String cardId) {
    final logs = getCardReviewHistory(cardId);

    if (logs.isEmpty) {
      return ReviewStats(
        totalReviews: 0,
        correctAnswers: 0,
        incorrectAnswers: 0,
        averageResponseTime: 0.0,
        lastReviewedAt: null,
        streak: 0,
      );
    }

    final correctAnswers =
        logs
            .where(
              (log) => log.rating == Rating.good || log.rating == Rating.easy,
            )
            .length;

    final incorrectAnswers =
        logs
            .where(
              (log) => log.rating == Rating.again || log.rating == Rating.hard,
            )
            .length;

    final totalResponseTime = logs.fold<double>(
      0.0,
      (sum, log) => sum + log.responseTime,
    );

    final averageResponseTime =
        logs.isNotEmpty ? totalResponseTime / logs.length : 0.0;

    // Calculate streak (consecutive correct answers)
    int streak = 0;
    for (final log in logs) {
      if (log.rating == Rating.good || log.rating == Rating.easy) {
        streak++;
      } else {
        break;
      }
    }

    return ReviewStats(
      totalReviews: logs.length,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      averageResponseTime: averageResponseTime,
      lastReviewedAt: logs.first.reviewDateTime,
      streak: streak,
    );
  }

  /// Get review statistics for a user
  UserReviewStats getUserReviewStats(String userId) {
    final logs =
        _reviewLogBox.values.where((log) => log.userId == userId).toList();

    if (logs.isEmpty) {
      return UserReviewStats(
        totalReviews: 0,
        cardsReviewed: 0,
        averageAccuracy: 0.0,
        totalStudyTime: 0.0,
        lastStudySession: null,
      );
    }

    final uniqueCards = logs.map((log) => log.cardId).toSet().length;

    final correctAnswers =
        logs
            .where(
              (log) => log.rating == Rating.good || log.rating == Rating.easy,
            )
            .length;

    final averageAccuracy =
        logs.isNotEmpty ? correctAnswers / logs.length : 0.0;

    final totalStudyTime = logs.fold<double>(
      0.0,
      (sum, log) => sum + log.responseTime,
    );

    logs.sort((a, b) => b.reviewDateTime.compareTo(a.reviewDateTime));
    final lastStudySession = logs.first.reviewDateTime;

    return UserReviewStats(
      totalReviews: logs.length,
      cardsReviewed: uniqueCards,
      averageAccuracy: averageAccuracy,
      totalStudyTime: totalStudyTime,
      lastStudySession: lastStudySession,
    );
  }

  /// Get review logs by date range
  List<ReviewLogModel> getReviewLogsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
  }) {
    var logs =
        _reviewLogBox.values
            .where(
              (log) =>
                  log.reviewDateTime.isAfter(startDate) &&
                  log.reviewDateTime.isBefore(endDate),
            )
            .toList();

    if (userId != null) {
      logs = logs.where((log) => log.userId == userId).toList();
    }

    logs.sort((a, b) => b.reviewDateTime.compareTo(a.reviewDateTime));
    return logs;
  }

  /// Delete review log
  Future<void> deleteReviewLog(String id) async {
    await _reviewLogBox.delete(id);
  }

  /// Clear all review logs
  Future<void> clearAllReviewLogs() async {
    await _reviewLogBox.clear();
  }

  /// Get review logs for sync to Supabase
  List<ReviewLogModel> getReviewLogsForSync({
    DateTime? lastSyncTime,
    int limit = 100,
  }) {
    var logs = _reviewLogBox.values.toList();

    if (lastSyncTime != null) {
      logs =
          logs
              .where((log) => log.reviewDateTime.isAfter(lastSyncTime))
              .toList();
    }

    logs.sort((a, b) => a.reviewDateTime.compareTo(b.reviewDateTime));
    return logs.take(limit).toList();
  }
}

/// Review statistics for a specific card
class ReviewStats {
  final int totalReviews;
  final int correctAnswers;
  final int incorrectAnswers;
  final double averageResponseTime;
  final DateTime? lastReviewedAt;
  final int streak;

  ReviewStats({
    required this.totalReviews,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.averageResponseTime,
    required this.lastReviewedAt,
    required this.streak,
  });

  double get accuracy => totalReviews > 0 ? correctAnswers / totalReviews : 0.0;
}

/// Review statistics for a user
class UserReviewStats {
  final int totalReviews;
  final int cardsReviewed;
  final double averageAccuracy;
  final double totalStudyTime;
  final DateTime? lastStudySession;

  UserReviewStats({
    required this.totalReviews,
    required this.cardsReviewed,
    required this.averageAccuracy,
    required this.totalStudyTime,
    required this.lastStudySession,
  });
}
