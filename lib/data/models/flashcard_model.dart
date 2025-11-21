import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'fsrs_card_state_model.dart';

part 'flashcard_model.g.dart';

/// Difficulty levels for flashcards
@HiveType(typeId: 10)
enum DifficultyLevel {
  @HiveField(0)
  easy,
  @HiveField(1)
  medium,
  @HiveField(2)
  hard,
}

/// Card types for different learning styles
@HiveType(typeId: 11)
enum CardType {
  @HiveField(0)
  basic, // Front/Back
  @HiveField(1)
  multipleChoice,
  @HiveField(2)
  fillInTheBlank,
  @HiveField(3)
  trueFalse,
}

/// Flashcard model for local and remote storage
@HiveType(typeId: 1)
@JsonSerializable()
class FlashcardModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String deckId;

  @HiveField(2)
  final String frontText;

  @HiveField(3)
  final String backText;

  @HiveField(4)
  final String? frontImageUrl;

  @HiveField(5)
  final String? backImageUrl;

  @HiveField(6)
  final DifficultyLevel difficulty;

  @HiveField(7)
  final CardType cardType;

  @HiveField(8)
  final List<String>? tags;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final String? createdBy;

  @HiveField(12)
  final bool isAIGenerated;

  @HiveField(13)
  final Map<String, dynamic>? metadata;

  // Spaced repetition fields
  @HiveField(14)
  final int interval; // days until next review

  @HiveField(15)
  final double easeFactor;

  @HiveField(16)
  final int repetitions;

  @HiveField(17)
  final DateTime? nextReviewDate;

  @HiveField(18)
  final DateTime? lastReviewedAt;

  @HiveField(19)
  final int consecutiveCorrectAnswers;

  @HiveField(20)
  final int totalReviews;

  @HiveField(21)
  final double averageResponseTime; // in seconds

  // FSRS algorithm state (optional)
  @HiveField(22)
  final FSRSCardState? fsrsState;

  FlashcardModel({
    required this.id,
    required this.deckId,
    required this.frontText,
    required this.backText,
    this.frontImageUrl,
    this.backImageUrl,
    this.difficulty = DifficultyLevel.medium,
    this.cardType = CardType.basic,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.isAIGenerated = false,
    this.metadata,
    this.interval = 1,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    this.nextReviewDate,
    this.lastReviewedAt,
    this.consecutiveCorrectAnswers = 0,
    this.totalReviews = 0,
    this.averageResponseTime = 0.0,
    this.fsrsState,
  });

  /// Create FlashcardModel from JSON
  factory FlashcardModel.fromJson(Map<String, dynamic> json) =>
      _$FlashcardModelFromJson(json);

  /// Convert FlashcardModel to JSON
  Map<String, dynamic> toJson() => _$FlashcardModelToJson(this);

  /// Create FlashcardModel from database JSON (snake_case)
  factory FlashcardModel.fromDatabaseJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      frontText: json['front_text'] as String,
      backText: json['back_text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      isAIGenerated: json['is_ai_generated'] as bool? ?? false,
      // Default values for fields not in database
      difficulty: DifficultyLevel.medium,
      cardType: CardType.basic,
      interval: 1,
      easeFactor: 2.5,
      repetitions: 0,
      consecutiveCorrectAnswers: 0,
      totalReviews: 0,
      averageResponseTime: 0.0,
      fsrsState: json['fsrs_state'] != null
          ? FSRSCardState.fromJson(json['fsrs_state'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert FlashcardModel to database-compatible JSON (snake_case)
  /// Only includes fields that exist in the database schema
  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'deck_id': deckId,
      'front_text': frontText,
      'back_text': backText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'is_ai_generated': isAIGenerated,
      if (fsrsState != null) 'fsrs_state': fsrsState!.toJson(),
      if (fsrsState != null) 'fsrs_card_id': fsrsState!.cardId,
    };
  }

  /// Create a copy of FlashcardModel with updated fields
  FlashcardModel copyWith({
    String? id,
    String? deckId,
    String? frontText,
    String? backText,
    String? frontImageUrl,
    String? backImageUrl,
    DifficultyLevel? difficulty,
    CardType? cardType,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isAIGenerated,
    Map<String, dynamic>? metadata,
    int? interval,
    double? easeFactor,
    int? repetitions,
    DateTime? nextReviewDate,
    DateTime? lastReviewedAt,
    int? consecutiveCorrectAnswers,
    int? totalReviews,
    double? averageResponseTime,
    FSRSCardState? fsrsState,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      frontImageUrl: frontImageUrl ?? this.frontImageUrl,
      backImageUrl: backImageUrl ?? this.backImageUrl,
      difficulty: difficulty ?? this.difficulty,
      cardType: cardType ?? this.cardType,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      metadata: metadata ?? this.metadata,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      consecutiveCorrectAnswers:
          consecutiveCorrectAnswers ?? this.consecutiveCorrectAnswers,
      totalReviews: totalReviews ?? this.totalReviews,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      fsrsState: fsrsState ?? this.fsrsState,
    );
  }

  /// Check if card is due for review
  bool get isDueForReview {
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!);
  }

  /// Get mastery level based on consecutive correct answers
  String get masteryLevel {
    if (consecutiveCorrectAnswers >= 10) return 'Master';
    if (consecutiveCorrectAnswers >= 5) return 'Advanced';
    if (consecutiveCorrectAnswers >= 3) return 'Intermediate';
    return 'Beginner';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlashcardModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FlashcardModel(id: $id, frontText: $frontText, difficulty: $difficulty)';
  }
}
