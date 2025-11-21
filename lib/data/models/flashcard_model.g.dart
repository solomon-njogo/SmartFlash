// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlashcardModelAdapter extends TypeAdapter<FlashcardModel> {
  @override
  final int typeId = 1;

  @override
  FlashcardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlashcardModel(
      id: fields[0] as String,
      deckId: fields[1] as String,
      frontText: fields[2] as String,
      backText: fields[3] as String,
      frontImageUrl: fields[4] as String?,
      backImageUrl: fields[5] as String?,
      difficulty: fields[6] as DifficultyLevel,
      cardType: fields[7] as CardType,
      tags: (fields[8] as List?)?.cast<String>(),
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      createdBy: fields[11] as String?,
      isAIGenerated: fields[12] as bool,
      metadata: (fields[13] as Map?)?.cast<String, dynamic>(),
      interval: fields[14] as int,
      easeFactor: fields[15] as double,
      repetitions: fields[16] as int,
      nextReviewDate: fields[17] as DateTime?,
      lastReviewedAt: fields[18] as DateTime?,
      consecutiveCorrectAnswers: fields[19] as int,
      totalReviews: fields[20] as int,
      averageResponseTime: fields[21] as double,
      fsrsState: fields[22] as FSRSCardState?,
    );
  }

  @override
  void write(BinaryWriter writer, FlashcardModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.deckId)
      ..writeByte(2)
      ..write(obj.frontText)
      ..writeByte(3)
      ..write(obj.backText)
      ..writeByte(4)
      ..write(obj.frontImageUrl)
      ..writeByte(5)
      ..write(obj.backImageUrl)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.cardType)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.createdBy)
      ..writeByte(12)
      ..write(obj.isAIGenerated)
      ..writeByte(13)
      ..write(obj.metadata)
      ..writeByte(14)
      ..write(obj.interval)
      ..writeByte(15)
      ..write(obj.easeFactor)
      ..writeByte(16)
      ..write(obj.repetitions)
      ..writeByte(17)
      ..write(obj.nextReviewDate)
      ..writeByte(18)
      ..write(obj.lastReviewedAt)
      ..writeByte(19)
      ..write(obj.consecutiveCorrectAnswers)
      ..writeByte(20)
      ..write(obj.totalReviews)
      ..writeByte(21)
      ..write(obj.averageResponseTime)
      ..writeByte(22)
      ..write(obj.fsrsState);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashcardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DifficultyLevelAdapter extends TypeAdapter<DifficultyLevel> {
  @override
  final int typeId = 10;

  @override
  DifficultyLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DifficultyLevel.easy;
      case 1:
        return DifficultyLevel.medium;
      case 2:
        return DifficultyLevel.hard;
      default:
        return DifficultyLevel.easy;
    }
  }

  @override
  void write(BinaryWriter writer, DifficultyLevel obj) {
    switch (obj) {
      case DifficultyLevel.easy:
        writer.writeByte(0);
        break;
      case DifficultyLevel.medium:
        writer.writeByte(1);
        break;
      case DifficultyLevel.hard:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CardTypeAdapter extends TypeAdapter<CardType> {
  @override
  final int typeId = 11;

  @override
  CardType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CardType.basic;
      case 1:
        return CardType.multipleChoice;
      case 2:
        return CardType.fillInTheBlank;
      case 3:
        return CardType.trueFalse;
      default:
        return CardType.basic;
    }
  }

  @override
  void write(BinaryWriter writer, CardType obj) {
    switch (obj) {
      case CardType.basic:
        writer.writeByte(0);
        break;
      case CardType.multipleChoice:
        writer.writeByte(1);
        break;
      case CardType.fillInTheBlank:
        writer.writeByte(2);
        break;
      case CardType.trueFalse:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlashcardModel _$FlashcardModelFromJson(Map<String, dynamic> json) =>
    FlashcardModel(
      id: json['id'] as String,
      deckId: json['deckId'] as String,
      frontText: json['frontText'] as String,
      backText: json['backText'] as String,
      frontImageUrl: json['frontImageUrl'] as String?,
      backImageUrl: json['backImageUrl'] as String?,
      difficulty:
          $enumDecodeNullable(_$DifficultyLevelEnumMap, json['difficulty']) ??
              DifficultyLevel.medium,
      cardType: $enumDecodeNullable(_$CardTypeEnumMap, json['cardType']) ??
          CardType.basic,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      isAIGenerated: json['isAIGenerated'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      nextReviewDate: json['nextReviewDate'] == null
          ? null
          : DateTime.parse(json['nextReviewDate'] as String),
      lastReviewedAt: json['lastReviewedAt'] == null
          ? null
          : DateTime.parse(json['lastReviewedAt'] as String),
      consecutiveCorrectAnswers:
          (json['consecutiveCorrectAnswers'] as num?)?.toInt() ?? 0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      averageResponseTime:
          (json['averageResponseTime'] as num?)?.toDouble() ?? 0.0,
      fsrsState: json['fsrsState'] == null
          ? null
          : FSRSCardState.fromJson(json['fsrsState'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FlashcardModelToJson(FlashcardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deckId': instance.deckId,
      'frontText': instance.frontText,
      'backText': instance.backText,
      'frontImageUrl': instance.frontImageUrl,
      'backImageUrl': instance.backImageUrl,
      'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
      'cardType': _$CardTypeEnumMap[instance.cardType]!,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'isAIGenerated': instance.isAIGenerated,
      'metadata': instance.metadata,
      'interval': instance.interval,
      'easeFactor': instance.easeFactor,
      'repetitions': instance.repetitions,
      'nextReviewDate': instance.nextReviewDate?.toIso8601String(),
      'lastReviewedAt': instance.lastReviewedAt?.toIso8601String(),
      'consecutiveCorrectAnswers': instance.consecutiveCorrectAnswers,
      'totalReviews': instance.totalReviews,
      'averageResponseTime': instance.averageResponseTime,
      'fsrsState': instance.fsrsState,
    };

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.easy: 'easy',
  DifficultyLevel.medium: 'medium',
  DifficultyLevel.hard: 'hard',
};

const _$CardTypeEnumMap = {
  CardType.basic: 'basic',
  CardType.multipleChoice: 'multipleChoice',
  CardType.fillInTheBlank: 'fillInTheBlank',
  CardType.trueFalse: 'trueFalse',
};
