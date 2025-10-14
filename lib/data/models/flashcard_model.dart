import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'fsrs_card_state_model.dart';

part 'flashcard_model.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class FlashcardModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String front;

  @HiveField(2)
  final String back;

  @HiveField(3)
  final String deckId;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final FSRSCardState? fsrsState;

  @HiveField(7)
  final String? userId;

  @HiveField(8)
  final List<String> tags;

  @HiveField(9)
  final int difficulty; // 1-5 user-defined difficulty

  const FlashcardModel({
    required this.id,
    required this.front,
    required this.back,
    required this.deckId,
    required this.createdAt,
    required this.updatedAt,
    this.fsrsState,
    this.userId,
    this.tags = const [],
    this.difficulty = 3,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) =>
      _$FlashcardModelFromJson(json);

  Map<String, dynamic> toJson() => _$FlashcardModelToJson(this);

  factory FlashcardModel.create({
    required String front,
    required String back,
    required String deckId,
    String? userId,
    List<String> tags = const [],
    int difficulty = 3,
  }) {
    final now = DateTime.now();
    return FlashcardModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      front: front,
      back: back,
      deckId: deckId,
      createdAt: now,
      updatedAt: now,
      fsrsState: FSRSCardState.initial(),
      userId: userId,
      tags: tags,
      difficulty: difficulty,
    );
  }

  FlashcardModel copyWith({
    String? id,
    String? front,
    String? back,
    String? deckId,
    DateTime? createdAt,
    DateTime? updatedAt,
    FSRSCardState? fsrsState,
    String? userId,
    List<String>? tags,
    int? difficulty,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      deckId: deckId ?? this.deckId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fsrsState: fsrsState ?? this.fsrsState,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  bool get isDueForReview {
    return fsrsState?.isDueForReview ?? true;
  }

  bool get isNew {
    return fsrsState?.reps == 0;
  }

  bool get isLearning {
    return fsrsState?.state == 1;
  }

  bool get isReview {
    return fsrsState?.state == 2;
  }

  bool get isRelearning {
    return fsrsState?.state == 3;
  }

  String get statusText {
    if (isNew) return 'New';
    if (isLearning) return 'Learning';
    if (isReview) return 'Review';
    if (isRelearning) return 'Relearning';
    return 'Unknown';
  }

  @override
  String toString() {
    return 'FlashcardModel(id: $id, front: $front, back: $back, deckId: $deckId, status: $statusText, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlashcardModel &&
        other.id == id &&
        other.front == front &&
        other.back == back &&
        other.deckId == deckId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.fsrsState == fsrsState &&
        other.userId == userId &&
        other.tags == tags &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        front.hashCode ^
        back.hashCode ^
        deckId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        fsrsState.hashCode ^
        userId.hashCode ^
        tags.hashCode ^
        difficulty.hashCode;
  }
}