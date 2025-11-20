// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_attempt_card_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeckAttemptCardResultAdapter extends TypeAdapter<DeckAttemptCardResult> {
  @override
  final int typeId = 24;

  @override
  DeckAttemptCardResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeckAttemptCardResult(
      id: fields[0] as String,
      attemptId: fields[1] as String,
      flashcardId: fields[2] as String,
      rating: fields[3] as String,
      timeSpentSeconds: fields[4] as int,
      answeredAt: fields[5] as DateTime,
      order: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DeckAttemptCardResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.attemptId)
      ..writeByte(2)
      ..write(obj.flashcardId)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.timeSpentSeconds)
      ..writeByte(5)
      ..write(obj.answeredAt)
      ..writeByte(6)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckAttemptCardResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeckAttemptCardResult _$DeckAttemptCardResultFromJson(
        Map<String, dynamic> json) =>
    DeckAttemptCardResult(
      id: json['id'] as String,
      attemptId: json['attempt_id'] as String,
      flashcardId: json['flashcard_id'] as String,
      rating: json['rating'] as String,
      timeSpentSeconds: (json['time_spent_seconds'] as num).toInt(),
      answeredAt: DateTime.parse(json['answered_at'] as String),
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$DeckAttemptCardResultToJson(
        DeckAttemptCardResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'attempt_id': instance.attemptId,
      'flashcard_id': instance.flashcardId,
      'rating': instance.rating,
      'time_spent_seconds': instance.timeSpentSeconds,
      'answered_at': instance.answeredAt.toIso8601String(),
      'order': instance.order,
    };
