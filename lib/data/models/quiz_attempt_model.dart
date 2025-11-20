import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'quiz_attempt_answer_model.dart';

part 'quiz_attempt_model.g.dart';

/// Quiz attempt status
@HiveType(typeId: 27)
enum QuizAttemptStatus {
  @HiveField(0)
  inProgress,
  @HiveField(1)
  completed,
  @HiveField(2)
  abandoned,
}

/// Quiz attempt model for tracking quiz sessions
@HiveType(typeId: 28)
@JsonSerializable()
class QuizAttemptModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  @JsonKey(name: 'quiz_id')
  final String quizId;

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
  final QuizAttemptStatus status;

  @HiveField(6)
  @JsonKey(name: 'total_questions')
  final int totalQuestions;

  @HiveField(7)
  @JsonKey(name: 'correct_answers')
  final int correctAnswers;

  @HiveField(8)
  @JsonKey(name: 'score_percentage')
  final double scorePercentage;

  @HiveField(9)
  @JsonKey(name: 'total_time_seconds')
  final int totalTimeSeconds;

  @HiveField(10)
  @JsonKey(name: 'attempt_number')
  final int attemptNumber;

  @HiveField(11)
  final Map<String, dynamic>? metadata;

  @HiveField(12)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(13)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @HiveField(14)
  final List<QuizAttemptAnswerModel>? answers;

  QuizAttemptModel({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.startedAt,
    this.completedAt,
    this.status = QuizAttemptStatus.inProgress,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.scorePercentage = 0.0,
    this.totalTimeSeconds = 0,
    this.attemptNumber = 1,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.answers,
  });

  /// Create QuizAttemptModel from JSON
  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) =>
      _$QuizAttemptModelFromJson(json);

  /// Convert QuizAttemptModel to JSON
  Map<String, dynamic> toJson() => _$QuizAttemptModelToJson(this);

  /// Create QuizAttemptModel from database JSON (snake_case)
  factory QuizAttemptModel.fromDatabaseJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String,
      userId: json['user_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      status: _statusFromString(json['status'] as String),
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      scorePercentage: (json['score_percentage'] as num).toDouble(),
      totalTimeSeconds: json['total_time_seconds'] as int,
      attemptNumber: json['attempt_number'] as int,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert QuizAttemptModel to database-compatible JSON (snake_case)
  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'user_id': userId,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'status': _statusToString(status),
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'score_percentage': scorePercentage,
      'total_time_seconds': totalTimeSeconds,
      'attempt_number': attemptNumber,
      'metadata': metadata,
    };
  }

  /// Create a copy of QuizAttemptModel with updated fields
  QuizAttemptModel copyWith({
    String? id,
    String? quizId,
    String? userId,
    DateTime? startedAt,
    DateTime? completedAt,
    QuizAttemptStatus? status,
    int? totalQuestions,
    int? correctAnswers,
    double? scorePercentage,
    int? totalTimeSeconds,
    int? attemptNumber,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<QuizAttemptAnswerModel>? answers,
  }) {
    return QuizAttemptModel(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      scorePercentage: scorePercentage ?? this.scorePercentage,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      answers: answers ?? this.answers,
    );
  }

  /// Get total time as Duration
  Duration get totalTime => Duration(seconds: totalTimeSeconds);

  /// Get status as string
  String get statusString {
    switch (status) {
      case QuizAttemptStatus.inProgress:
        return 'In Progress';
      case QuizAttemptStatus.completed:
        return 'Completed';
      case QuizAttemptStatus.abandoned:
        return 'Abandoned';
    }
  }

  /// Check if attempt is completed
  bool get isCompleted => status == QuizAttemptStatus.completed;

  /// Check if attempt is abandoned
  bool get isAbandoned => status == QuizAttemptStatus.abandoned;

  /// Check if attempt is in progress
  bool get isInProgress => status == QuizAttemptStatus.inProgress;

  /// Get average time per question
  Duration get averageTimePerQuestion {
    if (totalQuestions == 0) return Duration.zero;
    return Duration(milliseconds: totalTimeSeconds * 1000 ~/ totalQuestions);
  }

  /// Convert status enum to string
  static String _statusToString(QuizAttemptStatus status) {
    switch (status) {
      case QuizAttemptStatus.inProgress:
        return 'in_progress';
      case QuizAttemptStatus.completed:
        return 'completed';
      case QuizAttemptStatus.abandoned:
        return 'abandoned';
    }
  }

  /// Convert string to status enum
  static QuizAttemptStatus _statusFromString(String status) {
    switch (status) {
      case 'in_progress':
        return QuizAttemptStatus.inProgress;
      case 'completed':
        return QuizAttemptStatus.completed;
      case 'abandoned':
        return QuizAttemptStatus.abandoned;
      default:
        return QuizAttemptStatus.inProgress;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizAttemptModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuizAttemptModel(id: $id, quizId: $quizId, status: $status, score: $scorePercentage%)';
  }
}

