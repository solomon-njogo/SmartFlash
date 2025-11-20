// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionModelAdapter extends TypeAdapter<QuestionModel> {
  @override
  final int typeId = 3;

  @override
  QuestionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionModel(
      id: fields[0] as String,
      quizId: fields[1] as String,
      questionText: fields[2] as String,
      questionType: fields[3] as QuestionType,
      options: (fields[4] as List).cast<String>(),
      correctAnswers: (fields[5] as List).cast<String>(),
      explanation: fields[6] as String?,
      points: fields[7] as int,
      timeLimit: fields[8] as Duration?,
      imageUrl: fields[9] as String?,
      audioUrl: fields[10] as String?,
      order: fields[11] as int,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      createdBy: fields[14] as String?,
      isAIGenerated: fields[15] as bool,
      metadata: (fields[16] as Map?)?.cast<String, dynamic>(),
      tags: (fields[17] as List?)?.cast<String>(),
      difficulty: fields[18] as DifficultyLevel,
      fsrsState: fields[19] as FSRSCardState?,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.quizId)
      ..writeByte(2)
      ..write(obj.questionText)
      ..writeByte(3)
      ..write(obj.questionType)
      ..writeByte(4)
      ..write(obj.options)
      ..writeByte(5)
      ..write(obj.correctAnswers)
      ..writeByte(6)
      ..write(obj.explanation)
      ..writeByte(7)
      ..write(obj.points)
      ..writeByte(8)
      ..write(obj.timeLimit)
      ..writeByte(9)
      ..write(obj.imageUrl)
      ..writeByte(10)
      ..write(obj.audioUrl)
      ..writeByte(11)
      ..write(obj.order)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.createdBy)
      ..writeByte(15)
      ..write(obj.isAIGenerated)
      ..writeByte(16)
      ..write(obj.metadata)
      ..writeByte(17)
      ..write(obj.tags)
      ..writeByte(18)
      ..write(obj.difficulty)
      ..writeByte(19)
      ..write(obj.fsrsState);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuestionTypeAdapter extends TypeAdapter<QuestionType> {
  @override
  final int typeId = 20;

  @override
  QuestionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuestionType.multipleChoice;
      case 1:
        return QuestionType.trueFalse;
      case 2:
        return QuestionType.fillInTheBlank;
      case 3:
        return QuestionType.matching;
      case 4:
        return QuestionType.shortAnswer;
      default:
        return QuestionType.multipleChoice;
    }
  }

  @override
  void write(BinaryWriter writer, QuestionType obj) {
    switch (obj) {
      case QuestionType.multipleChoice:
        writer.writeByte(0);
        break;
      case QuestionType.trueFalse:
        writer.writeByte(1);
        break;
      case QuestionType.fillInTheBlank:
        writer.writeByte(2);
        break;
      case QuestionType.matching:
        writer.writeByte(3);
        break;
      case QuestionType.shortAnswer:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) =>
    QuestionModel(
      id: json['id'] as String,
      quizId: json['quizId'] as String,
      questionText: json['questionText'] as String,
      questionType: $enumDecode(_$QuestionTypeEnumMap, json['questionType']),
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      correctAnswers: (json['correctAnswers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      explanation: json['explanation'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 1,
      timeLimit: json['timeLimit'] == null
          ? null
          : Duration(microseconds: (json['timeLimit'] as num).toInt()),
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      order: (json['order'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      isAIGenerated: json['isAIGenerated'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      difficulty:
          $enumDecodeNullable(_$DifficultyLevelEnumMap, json['difficulty']) ??
              DifficultyLevel.medium,
      fsrsState: json['fsrsState'] == null
          ? null
          : FSRSCardState.fromJson(json['fsrsState'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuestionModelToJson(QuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quizId': instance.quizId,
      'questionText': instance.questionText,
      'questionType': _$QuestionTypeEnumMap[instance.questionType]!,
      'options': instance.options,
      'correctAnswers': instance.correctAnswers,
      'explanation': instance.explanation,
      'points': instance.points,
      'timeLimit': instance.timeLimit?.inMicroseconds,
      'imageUrl': instance.imageUrl,
      'audioUrl': instance.audioUrl,
      'order': instance.order,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'isAIGenerated': instance.isAIGenerated,
      'metadata': instance.metadata,
      'tags': instance.tags,
      'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
      'fsrsState': instance.fsrsState,
    };

const _$QuestionTypeEnumMap = {
  QuestionType.multipleChoice: 'multipleChoice',
  QuestionType.trueFalse: 'trueFalse',
  QuestionType.fillInTheBlank: 'fillInTheBlank',
  QuestionType.matching: 'matching',
  QuestionType.shortAnswer: 'shortAnswer',
};

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.easy: 'easy',
  DifficultyLevel.medium: 'medium',
  DifficultyLevel.hard: 'hard',
};
