import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/review_log_model.dart';
import '../constants/app_constants.dart';

class ReviewLogService {
  static final ReviewLogService _instance = ReviewLogService._internal();
  factory ReviewLogService() => _instance;
  ReviewLogService._internal();

  late Box<ReviewLog> _reviewLogsBox;

  Future<void> initialize() async {
    _reviewLogsBox = await Hive.openBox<ReviewLog>(AppConstants.reviewLogsBoxName);
  }

  /// Save a review log
  Future<void> saveReviewLog(ReviewLog reviewLog) async {
    await _reviewLogsBox.put(reviewLog.id, reviewLog);
  }

  /// Save multiple review logs
  Future<void> saveReviewLogs(List<ReviewLog> reviewLogs) async {
    final Map<String, ReviewLog> logsMap = {
      for (var log in reviewLogs) log.id: log
    };
    await _reviewLogsBox.putAll(logsMap);
  }

  /// Get review log by ID
  ReviewLog? getReviewLog(String id) {
    return _reviewLogsBox.get(id);
  }

  /// Get all review logs
  List<ReviewLog> getAllReviewLogs() {
    return _reviewLogsBox.values.toList();
  }

  /// Get review logs for a specific card
  List<ReviewLog> getCardReviewHistory(String cardId) {
    return _reviewLogsBox.values
        .where((log) => log.cardId == cardId)
        .toList()
      ..sort((a, b) => b.reviewDateTime.compareTo(a.reviewDateTime));
  }

  /// Get recent review logs
  List<ReviewLog> getRecentReviews({int limit = 50}) {
    final logs = _reviewLogsBox.values.toList()
      ..sort((a, b) => b.reviewDateTime.compareTo(a.reviewDateTime));
    return logs.take(limit).toList();
  }

  /// Get review logs by type
  List<ReviewLog> getReviewLogsByType(String reviewType) {
    return _reviewLogsBox.values
        .where((log) => log.reviewType == reviewType)
        .toList()
      ..sort((a, b) => b.reviewDateTime.compareTo(a.reviewDateTime));
  }

  /// Get review logs within date range
  List<ReviewLog> getReviewLogsInRange(DateTime start, DateTime end) {
    return _reviewLogsBox.values
        .where((log) => 
          log.reviewDateTime.isAfter(start) && 
          log.reviewDateTime.isBefore(end))
        .toList()
      ..sort((a, b) => b.reviewDateTime.compareTo(a.reviewDateTime));
  }

  /// Get review statistics
  ReviewStats getReviewStats({String? cardId, String? reviewType}) {
    List<ReviewLog> logs = _reviewLogsBox.values.toList();
    
    if (cardId != null) {
      logs = logs.where((log) => log.cardId == cardId).toList();
    }
    
    if (reviewType != null) {
      logs = logs.where((log) => log.reviewType == reviewType).toList();
    }

    if (logs.isEmpty) {
      return ReviewStats.empty();
    }

    final totalReviews = logs.length;
    final ratingCounts = <int, int>{};
    final dailyCounts = <String, int>{};
    
    for (final log in logs) {
      ratingCounts[log.rating] = (ratingCounts[log.rating] ?? 0) + 1;
      
      final dateKey = '${log.reviewDateTime.year}-${log.reviewDateTime.month}-${log.reviewDateTime.day}';
      dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
    }

    final averageRating = logs.map((log) => log.rating).reduce((a, b) => a + b) / totalReviews;
    final correctAnswers = logs.where((log) => log.rating >= 3).length;
    final accuracy = correctAnswers / totalReviews;

    return ReviewStats(
      totalReviews: totalReviews,
      averageRating: averageRating,
      accuracy: accuracy,
      ratingCounts: ratingCounts,
      dailyCounts: dailyCounts,
      firstReview: logs.map((log) => log.reviewDateTime).reduce((a, b) => a.isBefore(b) ? a : b),
      lastReview: logs.map((log) => log.reviewDateTime).reduce((a, b) => a.isAfter(b) ? a : b),
    );
  }

  /// Delete review log
  Future<void> deleteReviewLog(String id) async {
    await _reviewLogsBox.delete(id);
  }

  /// Delete all review logs
  Future<void> deleteAllReviewLogs() async {
    await _reviewLogsBox.clear();
  }

  /// Get review logs for sync (recent ones)
  List<ReviewLog> getReviewLogsForSync({int limit = 100}) {
    return getRecentReviews(limit: limit);
  }

  /// Close the service
  Future<void> close() async {
    await _reviewLogsBox.close();
  }
}

class ReviewStats {
  final int totalReviews;
  final double averageRating;
  final double accuracy;
  final Map<int, int> ratingCounts;
  final Map<String, int> dailyCounts;
  final DateTime firstReview;
  final DateTime lastReview;

  const ReviewStats({
    required this.totalReviews,
    required this.averageRating,
    required this.accuracy,
    required this.ratingCounts,
    required this.dailyCounts,
    required this.firstReview,
    required this.lastReview,
  });

  factory ReviewStats.empty() {
    final now = DateTime.now();
    return ReviewStats(
      totalReviews: 0,
      averageRating: 0.0,
      accuracy: 0.0,
      ratingCounts: {},
      dailyCounts: {},
      firstReview: now,
      lastReview: now,
    );
  }

  @override
  String toString() {
    return 'ReviewStats(totalReviews: $totalReviews, averageRating: ${averageRating.toStringAsFixed(2)}, accuracy: ${(accuracy * 100).toStringAsFixed(1)}%)';
  }
}