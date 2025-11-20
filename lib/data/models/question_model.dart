import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

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
  final int order;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  @HiveField(10)
  final String? createdBy;

  @HiveField(11)
  final bool isAIGenerated;

  QuestionModel({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.questionType,
    this.options = const [],
    required this.correctAnswers,
    this.explanation,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.isAIGenerated = false,
  });

  /// Create QuestionModel from JSON (camelCase)
  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  /// Convert QuestionModel to JSON (camelCase)
  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);

  /// Create QuestionModel from database JSON (snake_case)
  factory QuestionModel.fromDatabaseJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String,
      questionText: json['question_text'] as String,
      questionType: _questionTypeFromString(json['question_type'] as String),
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctAnswers:
          (json['correct_answers'] as List<dynamic>)
              .map((e) => e.toString())
              .toList(),
      explanation: json['explanation'] as String?,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      isAIGenerated: json['is_ai_generated'] as bool? ?? false,
    );
  }

  /// Convert QuestionModel to database-compatible JSON (snake_case)
  /// Only includes fields that exist in the database schema
  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question_text': questionText,
      'question_type': _questionTypeToString(questionType),
      'options': options,
      'correct_answers': correctAnswers,
      'explanation': explanation,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'is_ai_generated': isAIGenerated,
    };
  }

  /// Helper to convert string to QuestionType enum
  static QuestionType _questionTypeFromString(String value) {
    switch (value) {
      case 'multipleChoice':
        return QuestionType.multipleChoice;
      case 'trueFalse':
        return QuestionType.trueFalse;
      case 'fillInTheBlank':
        return QuestionType.fillInTheBlank;
      case 'matching':
        return QuestionType.matching;
      case 'shortAnswer':
        return QuestionType.shortAnswer;
      default:
        return QuestionType.multipleChoice;
    }
  }

  /// Helper to convert QuestionType enum to string
  static String _questionTypeToString(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'multipleChoice';
      case QuestionType.trueFalse:
        return 'trueFalse';
      case QuestionType.fillInTheBlank:
        return 'fillInTheBlank';
      case QuestionType.matching:
        return 'matching';
      case QuestionType.shortAnswer:
        return 'shortAnswer';
    }
  }

  /// Create a copy of QuestionModel with updated fields
  QuestionModel copyWith({
    String? id,
    String? quizId,
    String? questionText,
    QuestionType? questionType,
    List<String>? options,
    List<String>? correctAnswers,
    String? explanation,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isAIGenerated,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      questionText: questionText ?? this.questionText,
      questionType: questionType ?? this.questionType,
      options: options ?? this.options,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      explanation: explanation ?? this.explanation,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
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
