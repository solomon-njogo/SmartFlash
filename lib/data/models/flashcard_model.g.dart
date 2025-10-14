// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlashcardModel _$FlashcardModelFromJson(Map<String, dynamic> json) => FlashcardModel(
      id: json['id'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      deckId: json['deckId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      fsrsState: json['fsrsState'] == null
          ? null
          : FSRSCardState.fromJson(json['fsrsState'] as Map<String, dynamic>),
      userId: json['userId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      difficulty: json['difficulty'] as int? ?? 3,
    );

Map<String, dynamic> _$FlashcardModelToJson(FlashcardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'front': instance.front,
      'back': instance.back,
      'deckId': instance.deckId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'fsrsState': instance.fsrsState?.toJson(),
      'userId': instance.userId,
      'tags': instance.tags,
      'difficulty': instance.difficulty,
    };