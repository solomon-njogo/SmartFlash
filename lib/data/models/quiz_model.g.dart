// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizModelAdapter extends TypeAdapter<QuizModel> {
  @override
  final int typeId = 4;

  @override
  QuizModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      deckId: fields[3] as String,
      questionIds: (fields[4] as List).cast<String>(),
      status: fields[5] as QuizStatus,
      createdBy: fields[6] as String,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      timeLimit: fields[9] as Duration?,
      totalQuestions: fields[10] as int,
      totalPoints: fields[11] as int,
      isRandomized: fields[12] as bool,
      allowRetake: fields[13] as bool,
      maxAttempts: fields[14] as int,
      showCorrectAnswers: fields[15] as bool,
      showExplanations: fields[16] as bool,
      showScore: fields[17] as bool,
      coverImageUrl: fields[18] as String?,
      tags: (fields[19] as List).cast<String>(),
      settings: (fields[20] as Map?)?.cast<String, dynamic>(),
      isAIGenerated: fields[21] as bool,
      category: fields[22] as String?,
      subject: fields[23] as String?,
      difficulty: fields[24] as int,
      metadata: (fields[25] as Map?)?.cast<String, dynamic>(),
      totalAttempts: fields[26] as int,
      averageScore: fields[27] as double,
      averageTime: fields[28] as Duration,
      lastTakenAt: fields[29] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, QuizModel obj) {
    writer
      ..writeByte(30)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.deckId)
      ..writeByte(4)
      ..write(obj.questionIds)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.createdBy)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.timeLimit)
      ..writeByte(10)
      ..write(obj.totalQuestions)
      ..writeByte(11)
      ..write(obj.totalPoints)
      ..writeByte(12)
      ..write(obj.isRandomized)
      ..writeByte(13)
      ..write(obj.allowRetake)
      ..writeByte(14)
      ..write(obj.maxAttempts)
      ..writeByte(15)
      ..write(obj.showCorrectAnswers)
      ..writeByte(16)
      ..write(obj.showExplanations)
      ..writeByte(17)
      ..write(obj.showScore)
      ..writeByte(18)
      ..write(obj.coverImageUrl)
      ..writeByte(19)
      ..write(obj.tags)
      ..writeByte(20)
      ..write(obj.settings)
      ..writeByte(21)
      ..write(obj.isAIGenerated)
      ..writeByte(22)
      ..write(obj.category)
      ..writeByte(23)
      ..write(obj.subject)
      ..writeByte(24)
      ..write(obj.difficulty)
      ..writeByte(25)
      ..write(obj.metadata)
      ..writeByte(26)
      ..write(obj.totalAttempts)
      ..writeByte(27)
      ..write(obj.averageScore)
      ..writeByte(28)
      ..write(obj.averageTime)
      ..writeByte(29)
      ..write(obj.lastTakenAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizStatusAdapter extends TypeAdapter<QuizStatus> {
  @override
  final int typeId = 21;

  @override
  QuizStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuizStatus.draft;
      case 1:
        return QuizStatus.published;
      case 2:
        return QuizStatus.archived;
      default:
        return QuizStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, QuizStatus obj) {
    switch (obj) {
      case QuizStatus.draft:
        writer.writeByte(0);
        break;
      case QuizStatus.published:
        writer.writeByte(1);
        break;
      case QuizStatus.archived:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizModel _$QuizModelFromJson(Map<String, dynamic> json) => QuizModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      deckId: json['deckId'] as String,
      questionIds: (json['questionIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: $enumDecodeNullable(_$QuizStatusEnumMap, json['status']) ??
          QuizStatus.draft,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      timeLimit: json['timeLimit'] == null
          ? null
          : Duration(microseconds: (json['timeLimit'] as num).toInt()),
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      isRandomized: json['isRandomized'] as bool? ?? false,
      allowRetake: json['allowRetake'] as bool? ?? true,
      maxAttempts: (json['maxAttempts'] as num?)?.toInt() ?? 0,
      showCorrectAnswers: json['showCorrectAnswers'] as bool? ?? true,
      showExplanations: json['showExplanations'] as bool? ?? true,
      showScore: json['showScore'] as bool? ?? true,
      coverImageUrl: json['coverImageUrl'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      settings: json['settings'] as Map<String, dynamic>?,
      isAIGenerated: json['isAIGenerated'] as bool? ?? false,
      category: json['category'] as String?,
      subject: json['subject'] as String?,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 3,
      metadata: json['metadata'] as Map<String, dynamic>?,
      totalAttempts: (json['totalAttempts'] as num?)?.toInt() ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      averageTime: json['averageTime'] == null
          ? Duration.zero
          : Duration(microseconds: (json['averageTime'] as num).toInt()),
      lastTakenAt: json['lastTakenAt'] == null
          ? null
          : DateTime.parse(json['lastTakenAt'] as String),
    );

Map<String, dynamic> _$QuizModelToJson(QuizModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'deckId': instance.deckId,
      'questionIds': instance.questionIds,
      'status': _$QuizStatusEnumMap[instance.status]!,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'timeLimit': instance.timeLimit?.inMicroseconds,
      'totalQuestions': instance.totalQuestions,
      'totalPoints': instance.totalPoints,
      'isRandomized': instance.isRandomized,
      'allowRetake': instance.allowRetake,
      'maxAttempts': instance.maxAttempts,
      'showCorrectAnswers': instance.showCorrectAnswers,
      'showExplanations': instance.showExplanations,
      'showScore': instance.showScore,
      'coverImageUrl': instance.coverImageUrl,
      'tags': instance.tags,
      'settings': instance.settings,
      'isAIGenerated': instance.isAIGenerated,
      'category': instance.category,
      'subject': instance.subject,
      'difficulty': instance.difficulty,
      'metadata': instance.metadata,
      'totalAttempts': instance.totalAttempts,
      'averageScore': instance.averageScore,
      'averageTime': instance.averageTime.inMicroseconds,
      'lastTakenAt': instance.lastTakenAt?.toIso8601String(),
    };

const _$QuizStatusEnumMap = {
  QuizStatus.draft: 'draft',
  QuizStatus.published: 'published',
  QuizStatus.archived: 'archived',
};
