// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) => QuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String,
      quizId: json['quizId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      fsrsState: json['fsrsState'] == null
          ? null
          : FSRSCardState.fromJson(json['fsrsState'] as Map<String, dynamic>),
      userId: json['userId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      difficulty: json['difficulty'] as int? ?? 3,
    );

Map<String, dynamic> _$QuestionModelToJson(QuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'options': instance.options,
      'correctAnswerIndex': instance.correctAnswerIndex,
      'explanation': instance.explanation,
      'quizId': instance.quizId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'fsrsState': instance.fsrsState?.toJson(),
      'userId': instance.userId,
      'tags': instance.tags,
      'difficulty': instance.difficulty,
    };