import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:fsrs/fsrs.dart';

part 'review_log_model.g.dart';

/// Review Log model for storing FSRS review history
@HiveType(typeId: 31)
@JsonSerializable()
class ReviewLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cardId; // Can be flashcard ID or question ID

  @HiveField(2)
  final String cardType; // 'flashcard' or 'question'

  @HiveField(3)
  final Rating rating;

  @HiveField(4)
  final DateTime reviewDateTime;

  @HiveField(5)
  final int scheduledDays;

  @HiveField(6)
  final int elapsedDays;

  @HiveField(7)
  final State state;

  @HiveField(8)
  final State cardState;

  @HiveField(9)
  final double responseTime; // in seconds

  @HiveField(10)
  final String? userId;

  @HiveField(11)
  final Map<String, dynamic>? metadata;

  @HiveField(12)
  final double? stability;

  @HiveField(13)
  final double? difficulty;

  @HiveField(14)
  final double? retrievability;

  ReviewLogModel({
    required this.id,
    required this.cardId,
    required this.cardType,
    required this.rating,
    required this.reviewDateTime,
    required this.scheduledDays,
    required this.elapsedDays,
    required this.state,
    required this.cardState,
    this.responseTime = 0.0,
    this.userId,
    this.metadata,
    this.stability,
    this.difficulty,
    this.retrievability,
  });

  /// Create ReviewLogModel from JSON
  factory ReviewLogModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewLogModelFromJson(json);

  /// Convert ReviewLogModel to JSON
  Map<String, dynamic> toJson() => _$ReviewLogModelToJson(this);

  /// Create a copy of ReviewLogModel with updated fields
  ReviewLogModel copyWith({
    String? id,
    String? cardId,
    String? cardType,
    Rating? rating,
    DateTime? reviewDateTime,
    int? scheduledDays,
    int? elapsedDays,
    State? state,
    State? cardState,
    double? responseTime,
    String? userId,
    Map<String, dynamic>? metadata,
    double? stability,
    double? difficulty,
    double? retrievability,
  }) {
    return ReviewLogModel(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      cardType: cardType ?? this.cardType,
      rating: rating ?? this.rating,
      reviewDateTime: reviewDateTime ?? this.reviewDateTime,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      state: state ?? this.state,
      cardState: cardState ?? this.cardState,
      responseTime: responseTime ?? this.responseTime,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      retrievability: retrievability ?? this.retrievability,
    );
  }

  /// Get rating as user-friendly string
  String get ratingString {
    switch (rating) {
      case Rating.again:
        return 'Again';
      case Rating.hard:
        return 'Hard';
      case Rating.good:
        return 'Good';
      case Rating.easy:
        return 'Easy';
    }
  }

  /// Get rating description
  String get ratingDescription {
    switch (rating) {
      case Rating.again:
        return 'Forgot completely';
      case Rating.hard:
        return 'Remembered with difficulty';
      case Rating.good:
        return 'Remembered with hesitation';
      case Rating.easy:
        return 'Remembered easily';
    }
  }

  /// Get state as string
  String get stateString {
    switch (state) {
      case State.learning:
        return 'Learning';
      case State.review:
        return 'Review';
      case State.relearning:
        return 'Relearning';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewLogModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReviewLogModel(id: $id, cardId: $cardId, rating: $rating, reviewDateTime: $reviewDateTime)';
  }
}
