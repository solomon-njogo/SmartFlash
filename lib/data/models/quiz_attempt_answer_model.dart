import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quiz_attempt_answer_model.g.dart';

/// Quiz attempt answer model for tracking individual question answers
@HiveType(typeId: 29)
@JsonSerializable()
class QuizAttemptAnswerModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  @JsonKey(name: 'attempt_id')
  final String attemptId;

  @HiveField(2)
  @JsonKey(name: 'question_id')
  final String questionId;

  @HiveField(3)
  @JsonKey(name: 'user_answers')
  final List<String> userAnswers;

  @HiveField(4)
  @JsonKey(name: 'is_correct')
  final bool isCorrect;

  @HiveField(5)
  @JsonKey(name: 'answered_at')
  final DateTime answeredAt;

  @HiveField(6)
  @JsonKey(name: 'time_spent_seconds')
  final int timeSpentSeconds;

  @HiveField(7)
  final int order;

  const QuizAttemptAnswerModel({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.userAnswers,
    required this.isCorrect,
    required this.answeredAt,
    required this.timeSpentSeconds,
    required this.order,
  });

  /// Create QuizAttemptAnswerModel from JSON
  factory QuizAttemptAnswerModel.fromJson(Map<String, dynamic> json) =>
      _$QuizAttemptAnswerModelFromJson(json);

  /// Convert QuizAttemptAnswerModel to JSON
  Map<String, dynamic> toJson() => _$QuizAttemptAnswerModelToJson(this);

  /// Create QuizAttemptAnswerModel from database JSON (snake_case)
  factory QuizAttemptAnswerModel.fromDatabaseJson(Map<String, dynamic> json) {
    return QuizAttemptAnswerModel(
      id: json['id'] as String,
      attemptId: json['attempt_id'] as String,
      questionId: json['question_id'] as String,
      userAnswers: (json['user_answers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isCorrect: json['is_correct'] as bool,
      answeredAt: DateTime.parse(json['answered_at'] as String),
      timeSpentSeconds: json['time_spent_seconds'] as int,
      order: json['order'] as int,
    );
  }

  /// Convert QuizAttemptAnswerModel to database-compatible JSON (snake_case)
  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'attempt_id': attemptId,
      'question_id': questionId,
      'user_answers': userAnswers,
      'is_correct': isCorrect,
      'answered_at': answeredAt.toIso8601String(),
      'time_spent_seconds': timeSpentSeconds,
      'order': order,
    };
  }

  /// Create a copy of QuizAttemptAnswerModel with updated fields
  QuizAttemptAnswerModel copyWith({
    String? id,
    String? attemptId,
    String? questionId,
    List<String>? userAnswers,
    bool? isCorrect,
    DateTime? answeredAt,
    int? timeSpentSeconds,
    int? order,
  }) {
    return QuizAttemptAnswerModel(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      userAnswers: userAnswers ?? this.userAnswers,
      isCorrect: isCorrect ?? this.isCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      order: order ?? this.order,
    );
  }

  /// Get time spent as Duration
  Duration get timeSpent => Duration(seconds: timeSpentSeconds);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizAttemptAnswerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuizAttemptAnswerModel(id: $id, questionId: $questionId, isCorrect: $isCorrect)';
  }
}

