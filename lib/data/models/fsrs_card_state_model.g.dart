// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fsrs_card_state_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FSRSCardStateAdapter extends TypeAdapter<FSRSCardState> {
  @override
  final int typeId = 30;

  @override
  FSRSCardState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FSRSCardState(
      cardId: fields[0] as int,
      state: fields[1] as State,
      step: fields[2] as int,
      stability: fields[3] as double?,
      difficulty: fields[4] as double?,
      due: fields[5] as DateTime,
      lastReview: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FSRSCardState obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.cardId)
      ..writeByte(1)
      ..write(obj.state)
      ..writeByte(2)
      ..write(obj.step)
      ..writeByte(3)
      ..write(obj.stability)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.due)
      ..writeByte(6)
      ..write(obj.lastReview);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FSRSCardStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FSRSCardState _$FSRSCardStateFromJson(Map<String, dynamic> json) =>
    FSRSCardState(
      cardId: (json['cardId'] as num).toInt(),
      state: $enumDecode(_$StateEnumMap, json['state']),
      step: (json['step'] as num).toInt(),
      stability: (json['stability'] as num?)?.toDouble(),
      difficulty: (json['difficulty'] as num?)?.toDouble(),
      due: DateTime.parse(json['due'] as String),
      lastReview: json['lastReview'] == null
          ? null
          : DateTime.parse(json['lastReview'] as String),
    );

Map<String, dynamic> _$FSRSCardStateToJson(FSRSCardState instance) =>
    <String, dynamic>{
      'cardId': instance.cardId,
      'state': _$StateEnumMap[instance.state]!,
      'step': instance.step,
      'stability': instance.stability,
      'difficulty': instance.difficulty,
      'due': instance.due.toIso8601String(),
      'lastReview': instance.lastReview?.toIso8601String(),
    };

const _$StateEnumMap = {
  State.learning: 'learning',
  State.review: 'review',
  State.relearning: 'relearning',
};
