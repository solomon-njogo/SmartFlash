import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quiz_model.g.dart';

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
  final List<String> questionIds;

  @HiveField(4)
  final String createdBy;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final bool isAIGenerated;

  @HiveField(8)
  final String courseId;

  @HiveField(9)
  final List<String> materialIds;

  QuizModel({
    required this.id,
    required this.name,
    this.description,
    this.questionIds = const [],
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isAIGenerated = false,
    required this.courseId,
    this.materialIds = const [],
  });

  /// Create QuizModel from JSON (camelCase)
  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);

  /// Convert QuizModel to JSON (camelCase)
  Map<String, dynamic> toJson() => _$QuizModelToJson(this);

  /// Create QuizModel from database JSON (snake_case)
  factory QuizModel.fromDatabaseJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      questionIds:
          (json['question_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isAIGenerated: json['is_ai_generated'] as bool? ?? false,
      courseId: json['course_id'] as String,
      materialIds:
          (json['material_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Convert QuizModel to database-compatible JSON (snake_case)
  /// Only includes fields that exist in the database schema
  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'question_ids': questionIds,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_ai_generated': isAIGenerated,
      'course_id': courseId,
      'material_ids': materialIds,
    };
  }

  /// Create a copy of QuizModel with updated fields
  QuizModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? questionIds,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAIGenerated,
    String? courseId,
    List<String>? materialIds,
  }) {
    return QuizModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      questionIds: questionIds ?? this.questionIds,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      courseId: courseId ?? this.courseId,
      materialIds: materialIds ?? this.materialIds,
    );
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
    return 'QuizModel(id: $id, name: $name, questionIds: ${questionIds.length}, courseId: $courseId, materialIds: ${materialIds.length})';
  }
}
