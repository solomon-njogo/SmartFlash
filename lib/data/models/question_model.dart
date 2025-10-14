import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'fsrs_card_state_model.dart';

part 'question_model.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class QuestionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String question;

  @HiveField(2)
  final List<String> options;

  @HiveField(3)
  final int correctAnswerIndex;

  @HiveField(4)
  final String explanation;

  @HiveField(5)
  final String quizId;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final FSRSCardState? fsrsState;

  @HiveField(9)
  final String? userId;

  @HiveField(10)
  final List<String> tags;

  @HiveField(11)
  final int difficulty; // 1-5 user-defined difficulty

  const QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.quizId,
    required this.createdAt,
    required this.updatedAt,
    this.fsrsState,
    this.userId,
    this.tags = const [],
    this.difficulty = 3,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);

  factory QuestionModel.create({
    required String question,
    required List<String> options,
    required int correctAnswerIndex,
    required String explanation,
    required String quizId,
    String? userId,
    List<String> tags = const [],
    int difficulty = 3,
  }) {
    final now = DateTime.now();
    return QuestionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: question,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      explanation: explanation,
      quizId: quizId,
      createdAt: now,
      updatedAt: now,
      fsrsState: FSRSCardState.initial(),
      userId: userId,
      tags: tags,
      difficulty: difficulty,
    );
  }

  QuestionModel copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanation,
    String? quizId,
    DateTime? createdAt,
    DateTime? updatedAt,
    FSRSCardState? fsrsState,
    String? userId,
    List<String>? tags,
    int? difficulty,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
      quizId: quizId ?? this.quizId,
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

  bool isCorrectAnswer(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }

  @override
  String toString() {
    return 'QuestionModel(id: $id, question: $question, quizId: $quizId, status: $statusText, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionModel &&
        other.id == id &&
        other.question == question &&
        other.options == options &&
        other.correctAnswerIndex == correctAnswerIndex &&
        other.explanation == explanation &&
        other.quizId == quizId &&
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
        question.hashCode ^
        options.hashCode ^
        correctAnswerIndex.hashCode ^
        explanation.hashCode ^
        quizId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        fsrsState.hashCode ^
        userId.hashCode ^
        tags.hashCode ^
        difficulty.hashCode;
  }
}