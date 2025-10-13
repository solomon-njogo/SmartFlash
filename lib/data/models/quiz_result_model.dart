import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quiz_result_model.g.dart';

/// Quiz result status
@HiveType(typeId: 22)
enum QuizResultStatus {
  @HiveField(0)
  inProgress,
  @HiveField(1)
  completed,
  @HiveField(2)
  abandoned,
  @HiveField(3)
  timedOut,
}

/// Individual question result
@HiveType(typeId: 23)
@JsonSerializable()
class QuestionResult {
  @HiveField(0)
  final String questionId;

  @HiveField(1)
  final List<String> userAnswers;

  @HiveField(2)
  final List<String> correctAnswers;

  @HiveField(3)
  final bool isCorrect;

  @HiveField(4)
  final int pointsEarned;

  @HiveField(5)
  final int maxPoints;

  @HiveField(6)
  final Duration? timeSpent;

  @HiveField(7)
  final DateTime answeredAt;

  @HiveField(8)
  final String? explanation;

  const QuestionResult({
    required this.questionId,
    required this.userAnswers,
    required this.correctAnswers,
    required this.isCorrect,
    required this.pointsEarned,
    required this.maxPoints,
    this.timeSpent,
    required this.answeredAt,
    this.explanation,
  });

  /// Create QuestionResult from JSON
  factory QuestionResult.fromJson(Map<String, dynamic> json) =>
      _$QuestionResultFromJson(json);

  /// Convert QuestionResult to JSON
  Map<String, dynamic> toJson() => _$QuestionResultToJson(this);

  /// Create a copy of QuestionResult with updated fields
  QuestionResult copyWith({
    String? questionId,
    List<String>? userAnswers,
    List<String>? correctAnswers,
    bool? isCorrect,
    int? pointsEarned,
    int? maxPoints,
    Duration? timeSpent,
    DateTime? answeredAt,
    String? explanation,
  }) {
    return QuestionResult(
      questionId: questionId ?? this.questionId,
      userAnswers: userAnswers ?? this.userAnswers,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      isCorrect: isCorrect ?? this.isCorrect,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      maxPoints: maxPoints ?? this.maxPoints,
      timeSpent: timeSpent ?? this.timeSpent,
      answeredAt: answeredAt ?? this.answeredAt,
      explanation: explanation ?? this.explanation,
    );
  }

  /// Get accuracy percentage for this question
  double get accuracyPercentage {
    if (maxPoints == 0) return 0.0;
    return (pointsEarned / maxPoints) * 100;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionResult && other.questionId == questionId;
  }

  @override
  int get hashCode => questionId.hashCode;

  @override
  String toString() {
    return 'QuestionResult(questionId: $questionId, isCorrect: $isCorrect, points: $pointsEarned/$maxPoints)';
  }
}

/// Quiz result model for tracking quiz performance
@HiveType(typeId: 5)
@JsonSerializable()
class QuizResultModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String quizId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final QuizResultStatus status;

  @HiveField(4)
  final List<QuestionResult> questionResults;

  @HiveField(5)
  final int totalQuestions;

  @HiveField(6)
  final int correctAnswers;

  @HiveField(7)
  final int totalPoints;

  @HiveField(8)
  final int pointsEarned;

  @HiveField(9)
  final double scorePercentage;

  @HiveField(10)
  final Duration totalTime;

  @HiveField(11)
  final DateTime startedAt;

  @HiveField(12)
  final DateTime? completedAt;

  @HiveField(13)
  final DateTime? submittedAt;

  @HiveField(14)
  final int attemptNumber;

  @HiveField(15)
  final Map<String, dynamic>? metadata;

  @HiveField(16)
  final String? notes;

  @HiveField(17)
  final bool isPassed;

  @HiveField(18)
  final double passingScore; // Percentage required to pass

  @HiveField(19)
  final List<String>? incorrectQuestionIds;

  @HiveField(20)
  final Duration? timeLimit;

  @HiveField(21)
  final bool wasTimedOut;

  @HiveField(22)
  final Map<String, dynamic>? analytics;

  QuizResultModel({
    required this.id,
    required this.quizId,
    required this.userId,
    this.status = QuizResultStatus.inProgress,
    this.questionResults = const [],
    required this.totalQuestions,
    this.correctAnswers = 0,
    required this.totalPoints,
    this.pointsEarned = 0,
    this.scorePercentage = 0.0,
    this.totalTime = Duration.zero,
    required this.startedAt,
    this.completedAt,
    this.submittedAt,
    this.attemptNumber = 1,
    this.metadata,
    this.notes,
    this.isPassed = false,
    this.passingScore = 70.0,
    this.incorrectQuestionIds,
    this.timeLimit,
    this.wasTimedOut = false,
    this.analytics,
  });

  /// Create QuizResultModel from JSON
  factory QuizResultModel.fromJson(Map<String, dynamic> json) =>
      _$QuizResultModelFromJson(json);

  /// Convert QuizResultModel to JSON
  Map<String, dynamic> toJson() => _$QuizResultModelToJson(this);

  /// Create a copy of QuizResultModel with updated fields
  QuizResultModel copyWith({
    String? id,
    String? quizId,
    String? userId,
    QuizResultStatus? status,
    List<QuestionResult>? questionResults,
    int? totalQuestions,
    int? correctAnswers,
    int? totalPoints,
    int? pointsEarned,
    double? scorePercentage,
    Duration? totalTime,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? submittedAt,
    int? attemptNumber,
    Map<String, dynamic>? metadata,
    String? notes,
    bool? isPassed,
    double? passingScore,
    List<String>? incorrectQuestionIds,
    Duration? timeLimit,
    bool? wasTimedOut,
    Map<String, dynamic>? analytics,
  }) {
    return QuizResultModel(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      questionResults: questionResults ?? this.questionResults,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalPoints: totalPoints ?? this.totalPoints,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      scorePercentage: scorePercentage ?? this.scorePercentage,
      totalTime: totalTime ?? this.totalTime,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      metadata: metadata ?? this.metadata,
      notes: notes ?? this.notes,
      isPassed: isPassed ?? this.isPassed,
      passingScore: passingScore ?? this.passingScore,
      incorrectQuestionIds: incorrectQuestionIds ?? this.incorrectQuestionIds,
      timeLimit: timeLimit ?? this.timeLimit,
      wasTimedOut: wasTimedOut ?? this.wasTimedOut,
      analytics: analytics ?? this.analytics,
    );
  }

  /// Get accuracy percentage
  double get accuracyPercentage {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100;
  }

  /// Get status as string
  String get statusString {
    switch (status) {
      case QuizResultStatus.inProgress:
        return 'In Progress';
      case QuizResultStatus.completed:
        return 'Completed';
      case QuizResultStatus.abandoned:
        return 'Abandoned';
      case QuizResultStatus.timedOut:
        return 'Timed Out';
    }
  }

  /// Get grade letter
  String get gradeLetter {
    if (scorePercentage >= 90) return 'A';
    if (scorePercentage >= 80) return 'B';
    if (scorePercentage >= 70) return 'C';
    if (scorePercentage >= 60) return 'D';
    return 'F';
  }

  /// Get performance level
  String get performanceLevel {
    if (scorePercentage >= 90) return 'Excellent';
    if (scorePercentage >= 80) return 'Good';
    if (scorePercentage >= 70) return 'Satisfactory';
    if (scorePercentage >= 60) return 'Needs Improvement';
    return 'Poor';
  }

  /// Check if result is recent (within last 24 hours)
  bool get isRecent {
    if (completedAt == null) return false;
    final hoursSinceCompletion =
        DateTime.now().difference(completedAt!).inHours;
    return hoursSinceCompletion <= 24;
  }

  /// Get average time per question
  Duration get averageTimePerQuestion {
    if (totalQuestions == 0) return Duration.zero;
    return Duration(milliseconds: totalTime.inMilliseconds ~/ totalQuestions);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizResultModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuizResultModel(id: $id, quizId: $quizId, score: $scorePercentage%, status: $status)';
  }
}
