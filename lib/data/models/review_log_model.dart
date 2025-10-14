import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_log_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class ReviewLog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cardId; // Can be flashcard ID or question ID

  @HiveField(2)
  final int rating; // 1-4 (Again, Hard, Good, Easy)

  @HiveField(3)
  final DateTime reviewDateTime;

  @HiveField(4)
  final int scheduledDays;

  @HiveField(5)
  final int elapsedDays;

  @HiveField(6)
  final int state;

  @HiveField(7)
  final FSRSCardState cardState;

  @HiveField(8)
  final String reviewType; // 'flashcard' or 'question'

  const ReviewLog({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.reviewDateTime,
    required this.scheduledDays,
    required this.elapsedDays,
    required this.state,
    required this.cardState,
    required this.reviewType,
  });

  factory ReviewLog.fromJson(Map<String, dynamic> json) =>
      _$ReviewLogFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewLogToJson(this);

  ReviewLog copyWith({
    String? id,
    String? cardId,
    int? rating,
    DateTime? reviewDateTime,
    int? scheduledDays,
    int? elapsedDays,
    int? state,
    FSRSCardState? cardState,
    String? reviewType,
  }) {
    return ReviewLog(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      rating: rating ?? this.rating,
      reviewDateTime: reviewDateTime ?? this.reviewDateTime,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      state: state ?? this.state,
      cardState: cardState ?? this.cardState,
      reviewType: reviewType ?? this.reviewType,
    );
  }

  String get ratingLabel {
    switch (rating) {
      case 1:
        return 'Again';
      case 2:
        return 'Hard';
      case 3:
        return 'Good';
      case 4:
        return 'Easy';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'ReviewLog(id: $id, cardId: $cardId, rating: $ratingLabel, reviewDateTime: $reviewDateTime, scheduledDays: $scheduledDays, elapsedDays: $elapsedDays, state: $state, reviewType: $reviewType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewLog &&
        other.id == id &&
        other.cardId == cardId &&
        other.rating == rating &&
        other.reviewDateTime == reviewDateTime &&
        other.scheduledDays == scheduledDays &&
        other.elapsedDays == elapsedDays &&
        other.state == state &&
        other.cardState == cardState &&
        other.reviewType == reviewType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cardId.hashCode ^
        rating.hashCode ^
        reviewDateTime.hashCode ^
        scheduledDays.hashCode ^
        elapsedDays.hashCode ^
        state.hashCode ^
        cardState.hashCode ^
        reviewType.hashCode;
  }
}