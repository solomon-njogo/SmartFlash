import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'deck_model.g.dart';

/// Deck visibility levels
@HiveType(typeId: 12)
enum DeckVisibility {
  @HiveField(0)
  private,
  @HiveField(1)
  public,
  @HiveField(2)
  shared,
}

/// Study modes for decks
@HiveType(typeId: 13)
enum StudyMode {
  @HiveField(0)
  spacedRepetition,
  @HiveField(1)
  sequential,
  @HiveField(2)
  random,
  @HiveField(3)
  difficultyBased,
}

/// Deck model for local and remote storage
@HiveType(typeId: 2)
@JsonSerializable()
class DeckModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? coverImageUrl;

  @HiveField(4)
  final List<String> tags;

  @HiveField(5)
  final DeckVisibility visibility;

  @HiveField(6)
  final StudyMode studyMode;

  @HiveField(7)
  final String createdBy;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  @HiveField(10)
  final int totalCards;

  @HiveField(11)
  final int studiedCards;

  @HiveField(12)
  final int masteredCards;

  @HiveField(13)
  final double averageScore;

  @HiveField(14)
  final Duration totalStudyTime;

  @HiveField(15)
  final DateTime? lastStudiedAt;

  @HiveField(16)
  final bool isBookmarked;

  @HiveField(17)
  final int bookmarkCount;

  @HiveField(18)
  final Map<String, dynamic>? settings;

  @HiveField(19)
  final String? category;

  @HiveField(20)
  final String? subject;

  @HiveField(21)
  final int difficulty; // 1-5 scale

  @HiveField(22)
  final bool isAIGenerated;

  @HiveField(23)
  final String? sourceFileUrl;

  @HiveField(24)
  final Map<String, dynamic>? metadata;

  @HiveField(25)
  final String? courseId;

  DeckModel({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    this.tags = const [],
    this.visibility = DeckVisibility.private,
    this.studyMode = StudyMode.spacedRepetition,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.totalCards = 0,
    this.studiedCards = 0,
    this.masteredCards = 0,
    this.averageScore = 0.0,
    this.totalStudyTime = Duration.zero,
    this.lastStudiedAt,
    this.isBookmarked = false,
    this.bookmarkCount = 0,
    this.settings,
    this.category,
    this.subject,
    this.difficulty = 3,
    this.isAIGenerated = false,
    this.sourceFileUrl,
    this.metadata,
    this.courseId,
  });

  /// Create DeckModel from JSON
  factory DeckModel.fromJson(Map<String, dynamic> json) =>
      _$DeckModelFromJson(json);

  /// Convert DeckModel to JSON
  Map<String, dynamic> toJson() => _$DeckModelToJson(this);

  /// Create a copy of DeckModel with updated fields
  DeckModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    List<String>? tags,
    DeckVisibility? visibility,
    StudyMode? studyMode,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalCards,
    int? studiedCards,
    int? masteredCards,
    double? averageScore,
    Duration? totalStudyTime,
    DateTime? lastStudiedAt,
    bool? isBookmarked,
    int? bookmarkCount,
    Map<String, dynamic>? settings,
    String? category,
    String? subject,
    int? difficulty,
    bool? isAIGenerated,
    String? sourceFileUrl,
    Map<String, dynamic>? metadata,
    String? courseId,
  }) {
    return DeckModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      studyMode: studyMode ?? this.studyMode,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalCards: totalCards ?? this.totalCards,
      studiedCards: studiedCards ?? this.studiedCards,
      masteredCards: masteredCards ?? this.masteredCards,
      averageScore: averageScore ?? this.averageScore,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      settings: settings ?? this.settings,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      sourceFileUrl: sourceFileUrl ?? this.sourceFileUrl,
      metadata: metadata ?? this.metadata,
      courseId: courseId ?? this.courseId,
    );
  }

  /// Get completion percentage
  double get completionPercentage {
    if (totalCards == 0) return 0.0;
    return (studiedCards / totalCards) * 100;
  }

  /// Get mastery percentage
  double get masteryPercentage {
    if (totalCards == 0) return 0.0;
    return (masteredCards / totalCards) * 100;
  }

  /// Check if deck has been studied recently
  bool get isRecentlyStudied {
    if (lastStudiedAt == null) return false;
    final daysSinceLastStudy = DateTime.now().difference(lastStudiedAt!).inDays;
    return daysSinceLastStudy <= 7;
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeckModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DeckModel(id: $id, name: $name, totalCards: $totalCards)';
  }
}
