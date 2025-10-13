import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'flashcard_model.dart';

part 'question_model.g.dart';

/// Question types for quizzes
@HiveType(typeId: 20)
enum QuestionType {
  @HiveField(0)
  multipleChoice,
  @HiveField(1)
  trueFalse,
  @HiveField(2)
  fillInTheBlank,
  @HiveField(3)
  matching,
  @HiveField(4)
  shortAnswer,
}

/// Question model for quizzes
@HiveType(typeId: 3)
@JsonSerializable()
class QuestionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String quizId;

  @HiveField(2)
  final String questionText;

  @HiveField(3)
  final QuestionType questionType;

  @HiveField(4)
  final List<String> options; // For multiple choice, true/false, matching

  @HiveField(5)
  final List<String> correctAnswers;

  @HiveField(6)
  final String? explanation;

  @HiveField(7)
  final int points;

  @HiveField(8)
  final Duration? timeLimit;

  @HiveField(9)
  final String? imageUrl;

  @HiveField(10)
  final String? audioUrl;

  @HiveField(11)
  final int order;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime updatedAt;

  @HiveField(14)
  final String? createdBy;

  @HiveField(15)
  final bool isAIGenerated;

  @HiveField(16)
  final Map<String, dynamic>? metadata;

  @HiveField(17)
  final List<String>? tags;

  @HiveField(18)
  final DifficultyLevel difficulty;

  QuestionModel({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.questionType,
    this.options = const [],
    required this.correctAnswers,
    this.explanation,
    this.points = 1,
    this.timeLimit,
    this.imageUrl,
    this.audioUrl,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.isAIGenerated = false,
    this.metadata,
    this.tags,
    this.difficulty = DifficultyLevel.medium,
  });

  /// Create QuestionModel from JSON
  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  /// Convert QuestionModel to JSON
  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);

  /// Create a copy of QuestionModel with updated fields
  QuestionModel copyWith({
    String? id,
    String? quizId,
    String? questionText,
    QuestionType? questionType,
    List<String>? options,
    List<String>? correctAnswers,
    String? explanation,
    int? points,
    Duration? timeLimit,
    String? imageUrl,
    String? audioUrl,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isAIGenerated,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    DifficultyLevel? difficulty,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      questionText: questionText ?? this.questionText,
      questionType: questionType ?? this.questionType,
      options: options ?? this.options,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
      timeLimit: timeLimit ?? this.timeLimit,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  /// Check if answer is correct
  bool isCorrectAnswer(String answer) {
    return correctAnswers.contains(answer.toLowerCase().trim());
  }

  /// Check if multiple answers are correct
  bool areCorrectAnswers(List<String> answers) {
    if (answers.length != correctAnswers.length) return false;

    final normalizedAnswers =
        answers.map((a) => a.toLowerCase().trim()).toList();
    final normalizedCorrect =
        correctAnswers.map((a) => a.toLowerCase().trim()).toList();

    return normalizedAnswers.every(
          (answer) => normalizedCorrect.contains(answer),
        ) &&
        normalizedCorrect.every((answer) => normalizedAnswers.contains(answer));
  }

  /// Get question type as string
  String get questionTypeString {
    switch (questionType) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.fillInTheBlank:
        return 'Fill in the Blank';
      case QuestionType.matching:
        return 'Matching';
      case QuestionType.shortAnswer:
        return 'Short Answer';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuestionModel(id: $id, questionText: $questionText, type: $questionType)';
  }
}
