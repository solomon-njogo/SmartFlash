import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deck_attempt_card_result.g.dart';

/// Deck attempt card result model for tracking individual card performance
@HiveType(typeId: 24)
@JsonSerializable()
class DeckAttemptCardResult {
  @HiveField(0)
  final String id;

  @HiveField(1)
  @JsonKey(name: 'attempt_id')
  final String attemptId;

  @HiveField(2)
  @JsonKey(name: 'flashcard_id')
  final String flashcardId;

  @HiveField(3)
  final String rating; // 'again', 'hard', 'good', 'easy'

  @HiveField(4)
  @JsonKey(name: 'time_spent_seconds')
  final int timeSpentSeconds;

  @HiveField(5)
  @JsonKey(name: 'answered_at')
  final DateTime answeredAt;

  @HiveField(6)
  final int order;

  const DeckAttemptCardResult({
    required this.id,
    required this.attemptId,
    required this.flashcardId,
    required this.rating,
    required this.timeSpentSeconds,
    required this.answeredAt,
    required this.order,
  });

  /// Create DeckAttemptCardResult from JSON
  factory DeckAttemptCardResult.fromJson(Map<String, dynamic> json) =>
      _$DeckAttemptCardResultFromJson(json);

  /// Convert DeckAttemptCardResult to JSON
  Map<String, dynamic> toJson() => _$DeckAttemptCardResultToJson(this);

  /// Create DeckAttemptCardResult from database JSON (snake_case)
  factory DeckAttemptCardResult.fromDatabaseJson(Map<String, dynamic> json) {
    return DeckAttemptCardResult(
      id: json['id'] as String,
      attemptId: json['attempt_id'] as String,
      flashcardId: json['flashcard_id'] as String,
      rating: json['rating'] as String,
      timeSpentSeconds: json['time_spent_seconds'] as int,
      answeredAt: DateTime.parse(json['answered_at'] as String),
      order: json['order'] as int,
    );
  }

  /// Convert DeckAttemptCardResult to database-compatible JSON (snake_case)
  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'attempt_id': attemptId,
      'flashcard_id': flashcardId,
      'rating': rating,
      'time_spent_seconds': timeSpentSeconds,
      'answered_at': answeredAt.toIso8601String(),
      'order': order,
    };
  }

  /// Create a copy of DeckAttemptCardResult with updated fields
  DeckAttemptCardResult copyWith({
    String? id,
    String? attemptId,
    String? flashcardId,
    String? rating,
    int? timeSpentSeconds,
    DateTime? answeredAt,
    int? order,
  }) {
    return DeckAttemptCardResult(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      flashcardId: flashcardId ?? this.flashcardId,
      rating: rating ?? this.rating,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      answeredAt: answeredAt ?? this.answeredAt,
      order: order ?? this.order,
    );
  }

  /// Get time spent as Duration
  Duration get timeSpent => Duration(seconds: timeSpentSeconds);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeckAttemptCardResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DeckAttemptCardResult(id: $id, flashcardId: $flashcardId, rating: $rating)';
  }
}
