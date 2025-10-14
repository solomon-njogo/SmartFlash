import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'course_model.g.dart';

/// Course model for organizing decks, quizzes, and materials
@HiveType(typeId: 30)
@JsonSerializable()
class CourseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? coverImageUrl;

  @HiveField(4)
  final String? iconName; // Material icon name

  @HiveField(5)
  final int colorValue; // Color as int for Hive storage

  @HiveField(6)
  final List<String> deckIds;

  @HiveField(7)
  final List<String> quizIds;

  @HiveField(8)
  final List<String> materialIds;

  @HiveField(9)
  final String createdBy;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  @HiveField(12)
  final List<String> tags;

  @HiveField(13)
  final String? category;

  @HiveField(14)
  final String? subject;

  @HiveField(15)
  final int totalDecks;

  @HiveField(16)
  final int totalQuizzes;

  @HiveField(17)
  final int totalMaterials;

  @HiveField(18)
  final DateTime? lastAccessedAt;

  @HiveField(19)
  final Map<String, dynamic>? metadata;

  CourseModel({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    this.iconName = 'folder',
    this.colorValue = 0xFF2196F3, // Default blue
    this.deckIds = const [],
    this.quizIds = const [],
    this.materialIds = const [],
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.category,
    this.subject,
    this.totalDecks = 0,
    this.totalQuizzes = 0,
    this.totalMaterials = 0,
    this.lastAccessedAt,
    this.metadata,
  });

  /// Create CourseModel from JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);

  /// Convert CourseModel to JSON
  Map<String, dynamic> toJson() => _$CourseModelToJson(this);

  /// Create a copy of CourseModel with updated fields
  CourseModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    String? iconName,
    int? colorValue,
    List<String>? deckIds,
    List<String>? quizIds,
    List<String>? materialIds,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? category,
    String? subject,
    int? totalDecks,
    int? totalQuizzes,
    int? totalMaterials,
    DateTime? lastAccessedAt,
    Map<String, dynamic>? metadata,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      deckIds: deckIds ?? this.deckIds,
      quizIds: quizIds ?? this.quizIds,
      materialIds: materialIds ?? this.materialIds,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      totalDecks: totalDecks ?? this.totalDecks,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      totalMaterials: totalMaterials ?? this.totalMaterials,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get total content count
  int get totalContent => totalDecks + totalQuizzes + totalMaterials;

  /// Check if course has been accessed recently
  bool get isRecentlyAccessed {
    if (lastAccessedAt == null) return false;
    final daysSinceLastAccess =
        DateTime.now().difference(lastAccessedAt!).inDays;
    return daysSinceLastAccess <= 7;
  }

  /// Get color as Color object
  Color get color => Color(colorValue);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CourseModel(id: $id, name: $name, totalContent: $totalContent)';
  }
}
