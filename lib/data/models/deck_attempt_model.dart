import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'deck_attempt_card_result.dart';

part 'deck_attempt_model.g.dart';

/// Deck attempt status
@HiveType(typeId: 25)
enum DeckAttemptStatus {
  @HiveField(0)
  inProgress,
  @HiveField(1)
  completed,
  @HiveField(2)
  abandoned,
}

/// Deck attempt model for tracking study sessions
@HiveType(typeId: 26)
@JsonSerializable()
class DeckAttemptModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  @JsonKey(name: 'deck_id')
  final String deckId;

  @HiveField(2)
  @JsonKey(name: 'user_id')
  final String userId;

  @HiveField(3)
  @JsonKey(name: 'started_at')
  final DateTime startedAt;

  @HiveField(4)
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;

  @HiveField(5)
  final DeckAttemptStatus status;

  @HiveField(6)
  @JsonKey(name: 'total_cards')
  final int totalCards;

  @HiveField(7)
  @JsonKey(name: 'cards_studied')
  final int cardsStudied;

  @HiveField(8)
  @JsonKey(name: 'cards_again')
  final int cardsAgain;

  @HiveField(9)
  @JsonKey(name: 'cards_hard')
  final int cardsHard;

  @HiveField(10)
  @JsonKey(name: 'cards_good')
  final int cardsGood;

  @HiveField(11)
  @JsonKey(name: 'cards_easy')
  final int cardsEasy;

  @HiveField(12)
  @JsonKey(name: 'total_time_seconds')
  final int totalTimeSeconds;

  @HiveField(13)
  @JsonKey(name: 'attempt_number')
  final int attemptNumber;

  @HiveField(14)
  final Map<String, dynamic>? metadata;

  @HiveField(15)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(16)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @HiveField(17)
  final List<DeckAttemptCardResult>? cardResults;

  DeckAttemptModel({
    required this.id,
    required this.deckId,
    required this.userId,
    required this.startedAt,
    this.completedAt,
    this.status = DeckAttemptStatus.inProgress,
    this.totalCards = 0,
    this.cardsStudied = 0,
    this.cardsAgain = 0,
    this.cardsHard = 0,
    this.cardsGood = 0,
    this.cardsEasy = 0,
    this.totalTimeSeconds = 0,
    this.attemptNumber = 1,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.cardResults,
  });

  /// Create DeckAttemptModel from JSON
  factory DeckAttemptModel.fromJson(Map<String, dynamic> json) =>
      _$DeckAttemptModelFromJson(json);

  /// Convert DeckAttemptModel to JSON
  Map<String, dynamic> toJson() => _$DeckAttemptModelToJson(this);

  /// Create DeckAttemptModel from database JSON (snake_case)
  factory DeckAttemptModel.fromDatabaseJson(Map<String, dynamic> json) {
    return DeckAttemptModel(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      userId: json['user_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt:
          json['completed_at'] != null
              ? DateTime.parse(json['completed_at'] as String)
              : null,
      status: _statusFromString(json['status'] as String),
      totalCards: json['total_cards'] as int,
      cardsStudied: json['cards_studied'] as int,
      cardsAgain: json['cards_again'] as int? ?? 0,
      cardsHard: json['cards_hard'] as int? ?? 0,
      cardsGood: json['cards_good'] as int? ?? 0,
      cardsEasy: json['cards_easy'] as int? ?? 0,
      totalTimeSeconds: json['total_time_seconds'] as int,
      attemptNumber: json['attempt_number'] as int,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert DeckAttemptModel to database-compatible JSON (snake_case)
  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'deck_id': deckId,
      'user_id': userId,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'status': _statusToString(status),
      'total_cards': totalCards,
      'cards_studied': cardsStudied,
      'cards_again': cardsAgain,
      'cards_hard': cardsHard,
      'cards_good': cardsGood,
      'cards_easy': cardsEasy,
      'total_time_seconds': totalTimeSeconds,
      'attempt_number': attemptNumber,
      'metadata': metadata,
    };
  }

  /// Create a copy of DeckAttemptModel with updated fields
  DeckAttemptModel copyWith({
    String? id,
    String? deckId,
    String? userId,
    DateTime? startedAt,
    DateTime? completedAt,
    DeckAttemptStatus? status,
    int? totalCards,
    int? cardsStudied,
    int? cardsAgain,
    int? cardsHard,
    int? cardsGood,
    int? cardsEasy,
    int? totalTimeSeconds,
    int? attemptNumber,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<DeckAttemptCardResult>? cardResults,
  }) {
    return DeckAttemptModel(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      totalCards: totalCards ?? this.totalCards,
      cardsStudied: cardsStudied ?? this.cardsStudied,
      cardsAgain: cardsAgain ?? this.cardsAgain,
      cardsHard: cardsHard ?? this.cardsHard,
      cardsGood: cardsGood ?? this.cardsGood,
      cardsEasy: cardsEasy ?? this.cardsEasy,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cardResults: cardResults ?? this.cardResults,
    );
  }

  /// Get success percentage (good + easy / total studied)
  double get successPercentage {
    if (cardsStudied == 0) return 0.0;
    return ((cardsGood + cardsEasy) / cardsStudied) * 100;
  }

  /// Get difficulty distribution as a map
  Map<String, int> get difficultyDistribution => {
    'again': cardsAgain,
    'hard': cardsHard,
    'good': cardsGood,
    'easy': cardsEasy,
  };

  /// Get total time as Duration
  Duration get totalTime => Duration(seconds: totalTimeSeconds);

  /// Get status as string
  String get statusString {
    switch (status) {
      case DeckAttemptStatus.inProgress:
        return 'In Progress';
      case DeckAttemptStatus.completed:
        return 'Completed';
      case DeckAttemptStatus.abandoned:
        return 'Abandoned';
    }
  }

  /// Check if attempt is completed
  bool get isCompleted => status == DeckAttemptStatus.completed;

  /// Check if attempt is abandoned
  bool get isAbandoned => status == DeckAttemptStatus.abandoned;

  /// Check if attempt is in progress
  bool get isInProgress => status == DeckAttemptStatus.inProgress;

  /// Get average time per card
  Duration get averageTimePerCard {
    if (cardsStudied == 0) return Duration.zero;
    return Duration(milliseconds: totalTimeSeconds * 1000 ~/ cardsStudied);
  }

  /// Convert status enum to string
  static String _statusToString(DeckAttemptStatus status) {
    switch (status) {
      case DeckAttemptStatus.inProgress:
        return 'in_progress';
      case DeckAttemptStatus.completed:
        return 'completed';
      case DeckAttemptStatus.abandoned:
        return 'abandoned';
    }
  }

  /// Convert string to status enum
  static DeckAttemptStatus _statusFromString(String status) {
    switch (status) {
      case 'in_progress':
        return DeckAttemptStatus.inProgress;
      case 'completed':
        return DeckAttemptStatus.completed;
      case 'abandoned':
        return DeckAttemptStatus.abandoned;
      default:
        return DeckAttemptStatus.inProgress;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeckAttemptModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DeckAttemptModel(id: $id, deckId: $deckId, status: $status, cardsStudied: $cardsStudied/$totalCards)';
  }
}
