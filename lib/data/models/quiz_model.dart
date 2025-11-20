import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quiz_model.g.dart';

/// Quiz status
@HiveType(typeId: 21)
enum QuizStatus {
  @HiveField(0)
  draft,
  @HiveField(1)
  published,
  @HiveField(2)
  archived,
}

/// Quiz model for creating and managing quizzes
@HiveType(typeId: 4)
@JsonSerializable()
class QuizModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String deckId;

  @HiveField(4)
  final List<String> questionIds;

  @HiveField(5)
  final QuizStatus status;

  @HiveField(6)
  final String createdBy;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final Duration? timeLimit;

  @HiveField(10)
  final int totalQuestions;

  @HiveField(11)
  final int totalPoints;

  @HiveField(12)
  final bool isRandomized;

  @HiveField(13)
  final bool allowRetake;

  @HiveField(14)
  final int maxAttempts;

  @HiveField(15)
  final bool showCorrectAnswers;

  @HiveField(16)
  final bool showExplanations;

  @HiveField(17)
  final bool showScore;

  @HiveField(18)
  final String? coverImageUrl;

  @HiveField(19)
  final List<String> tags;

  @HiveField(20)
  final Map<String, dynamic>? settings;

  @HiveField(21)
  final bool isAIGenerated;

  @HiveField(22)
  final String? category;

  @HiveField(23)
  final String? subject;

  @HiveField(24)
  final int difficulty; // 1-5 scale

  @HiveField(25)
  final Map<String, dynamic>? metadata;

  @HiveField(26)
  final int totalAttempts;

  @HiveField(27)
  final double averageScore;

  @HiveField(28)
  final Duration averageTime;

  @HiveField(29)
  final DateTime? lastTakenAt;

  QuizModel({
    required this.id,
    required this.name,
    this.description,
    required this.deckId,
    this.questionIds = const [],
    this.status = QuizStatus.draft,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.timeLimit,
    this.totalQuestions = 0,
    this.totalPoints = 0,
    this.isRandomized = false,
    this.allowRetake = true,
    this.maxAttempts = 0, // 0 means unlimited
    this.showCorrectAnswers = true,
    this.showExplanations = true,
    this.showScore = true,
    this.coverImageUrl,
    this.tags = const [],
    this.settings,
    this.isAIGenerated = false,
    this.category,
    this.subject,
    this.difficulty = 3,
    this.metadata,
    this.totalAttempts = 0,
    this.averageScore = 0.0,
    this.averageTime = Duration.zero,
    this.lastTakenAt,
  });

  /// Create QuizModel from JSON
  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);

  /// Convert QuizModel to JSON
  Map<String, dynamic> toJson() => _$QuizModelToJson(this);

  /// Create a copy of QuizModel with updated fields
  QuizModel copyWith({
    String? id,
    String? name,
    String? description,
    String? deckId,
    List<String>? questionIds,
    QuizStatus? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Duration? timeLimit,
    int? totalQuestions,
    int? totalPoints,
    bool? isRandomized,
    bool? allowRetake,
    int? maxAttempts,
    bool? showCorrectAnswers,
    bool? showExplanations,
    bool? showScore,
    String? coverImageUrl,
    List<String>? tags,
    Map<String, dynamic>? settings,
    bool? isAIGenerated,
    String? category,
    String? subject,
    int? difficulty,
    Map<String, dynamic>? metadata,
    int? totalAttempts,
    double? averageScore,
    Duration? averageTime,
    DateTime? lastTakenAt,
  }) {
    return QuizModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      deckId: deckId ?? this.deckId,
      questionIds: questionIds ?? this.questionIds,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timeLimit: timeLimit ?? this.timeLimit,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalPoints: totalPoints ?? this.totalPoints,
      isRandomized: isRandomized ?? this.isRandomized,
      allowRetake: allowRetake ?? this.allowRetake,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      showCorrectAnswers: showCorrectAnswers ?? this.showCorrectAnswers,
      showExplanations: showExplanations ?? this.showExplanations,
      showScore: showScore ?? this.showScore,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      tags: tags ?? this.tags,
      settings: settings ?? this.settings,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      metadata: metadata ?? this.metadata,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      averageScore: averageScore ?? this.averageScore,
      averageTime: averageTime ?? this.averageTime,
      lastTakenAt: lastTakenAt ?? this.lastTakenAt,
    );
  }

  /// Check if quiz can be taken
  bool get canBeTaken {
    return status == QuizStatus.published &&
        questionIds.isNotEmpty &&
        (maxAttempts == 0 || totalAttempts < maxAttempts);
  }

  /// Get difficulty level as string
  String get difficultyLevel {
    switch (difficulty) {
      case 1:
        return 'Very Easy';
      case 2:
        return 'Easy';
      case 3:
        return 'Medium';
      case 4:
        return 'Hard';
      case 5:
        return 'Very Hard';
      default:
        return 'Medium';
    }
  }

  /// Get status as string
  String get statusString {
    switch (status) {
      case QuizStatus.draft:
        return 'Draft';
      case QuizStatus.published:
        return 'Published';
      case QuizStatus.archived:
        return 'Archived';
    }
  }

  /// Check if quiz has time limit
  bool get hasTimeLimit => timeLimit != null;

  /// Get estimated completion time
  Duration get estimatedTime {
    if (timeLimit != null) return timeLimit!;
    // Estimate 30 seconds per question if no time limit
    return Duration(seconds: totalQuestions * 30);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuizModel(id: $id, name: $name, totalQuestions: $totalQuestions)';
  }
}
