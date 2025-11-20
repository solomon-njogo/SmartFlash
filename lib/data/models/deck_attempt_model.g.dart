// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_attempt_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeckAttemptModelAdapter extends TypeAdapter<DeckAttemptModel> {
  @override
  final int typeId = 26;

  @override
  DeckAttemptModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeckAttemptModel(
      id: fields[0] as String,
      deckId: fields[1] as String,
      userId: fields[2] as String,
      startedAt: fields[3] as DateTime,
      completedAt: fields[4] as DateTime?,
      status: fields[5] as DeckAttemptStatus,
      totalCards: fields[6] as int,
      cardsStudied: fields[7] as int,
      cardsAgain: fields[8] as int,
      cardsHard: fields[9] as int,
      cardsGood: fields[10] as int,
      cardsEasy: fields[11] as int,
      totalTimeSeconds: fields[12] as int,
      attemptNumber: fields[13] as int,
      metadata: (fields[14] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
      cardResults: (fields[17] as List?)?.cast<DeckAttemptCardResult>(),
    );
  }

  @override
  void write(BinaryWriter writer, DeckAttemptModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.deckId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.startedAt)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.totalCards)
      ..writeByte(7)
      ..write(obj.cardsStudied)
      ..writeByte(8)
      ..write(obj.cardsAgain)
      ..writeByte(9)
      ..write(obj.cardsHard)
      ..writeByte(10)
      ..write(obj.cardsGood)
      ..writeByte(11)
      ..write(obj.cardsEasy)
      ..writeByte(12)
      ..write(obj.totalTimeSeconds)
      ..writeByte(13)
      ..write(obj.attemptNumber)
      ..writeByte(14)
      ..write(obj.metadata)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.cardResults);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckAttemptModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeckAttemptStatusAdapter extends TypeAdapter<DeckAttemptStatus> {
  @override
  final int typeId = 25;

  @override
  DeckAttemptStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DeckAttemptStatus.inProgress;
      case 1:
        return DeckAttemptStatus.completed;
      case 2:
        return DeckAttemptStatus.abandoned;
      default:
        return DeckAttemptStatus.inProgress;
    }
  }

  @override
  void write(BinaryWriter writer, DeckAttemptStatus obj) {
    switch (obj) {
      case DeckAttemptStatus.inProgress:
        writer.writeByte(0);
        break;
      case DeckAttemptStatus.completed:
        writer.writeByte(1);
        break;
      case DeckAttemptStatus.abandoned:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckAttemptStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeckAttemptModel _$DeckAttemptModelFromJson(Map<String, dynamic> json) =>
    DeckAttemptModel(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      userId: json['user_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      status: $enumDecodeNullable(_$DeckAttemptStatusEnumMap, json['status']) ??
          DeckAttemptStatus.inProgress,
      totalCards: (json['total_cards'] as num?)?.toInt() ?? 0,
      cardsStudied: (json['cards_studied'] as num?)?.toInt() ?? 0,
      cardsAgain: (json['cards_again'] as num?)?.toInt() ?? 0,
      cardsHard: (json['cards_hard'] as num?)?.toInt() ?? 0,
      cardsGood: (json['cards_good'] as num?)?.toInt() ?? 0,
      cardsEasy: (json['cards_easy'] as num?)?.toInt() ?? 0,
      totalTimeSeconds: (json['total_time_seconds'] as num?)?.toInt() ?? 0,
      attemptNumber: (json['attempt_number'] as num?)?.toInt() ?? 1,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      cardResults: (json['cardResults'] as List<dynamic>?)
          ?.map(
              (e) => DeckAttemptCardResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeckAttemptModelToJson(DeckAttemptModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deck_id': instance.deckId,
      'user_id': instance.userId,
      'started_at': instance.startedAt.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'status': _$DeckAttemptStatusEnumMap[instance.status]!,
      'total_cards': instance.totalCards,
      'cards_studied': instance.cardsStudied,
      'cards_again': instance.cardsAgain,
      'cards_hard': instance.cardsHard,
      'cards_good': instance.cardsGood,
      'cards_easy': instance.cardsEasy,
      'total_time_seconds': instance.totalTimeSeconds,
      'attempt_number': instance.attemptNumber,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'cardResults': instance.cardResults,
    };

const _$DeckAttemptStatusEnumMap = {
  DeckAttemptStatus.inProgress: 'inProgress',
  DeckAttemptStatus.completed: 'completed',
  DeckAttemptStatus.abandoned: 'abandoned',
};
