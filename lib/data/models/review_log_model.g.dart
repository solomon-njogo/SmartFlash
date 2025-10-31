// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReviewLogModelAdapter extends TypeAdapter<ReviewLogModel> {
  @override
  final int typeId = 31;

  @override
  ReviewLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewLogModel(
      id: fields[0] as String,
      cardId: fields[1] as String,
      cardType: fields[2] as String,
      rating: fields[3] as Rating,
      reviewDateTime: fields[4] as DateTime,
      scheduledDays: fields[5] as int,
      elapsedDays: fields[6] as int,
      state: fields[7] as State,
      cardState: fields[8] as State,
      responseTime: fields[9] as double,
      userId: fields[10] as String?,
      metadata: (fields[11] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReviewLogModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cardId)
      ..writeByte(2)
      ..write(obj.cardType)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.reviewDateTime)
      ..writeByte(5)
      ..write(obj.scheduledDays)
      ..writeByte(6)
      ..write(obj.elapsedDays)
      ..writeByte(7)
      ..write(obj.state)
      ..writeByte(8)
      ..write(obj.cardState)
      ..writeByte(9)
      ..write(obj.responseTime)
      ..writeByte(10)
      ..write(obj.userId)
      ..writeByte(11)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewLogModel _$ReviewLogModelFromJson(Map<String, dynamic> json) =>
    ReviewLogModel(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      cardType: json['cardType'] as String,
      rating: $enumDecode(_$RatingEnumMap, json['rating']),
      reviewDateTime: DateTime.parse(json['reviewDateTime'] as String),
      scheduledDays: (json['scheduledDays'] as num).toInt(),
      elapsedDays: (json['elapsedDays'] as num).toInt(),
      state: $enumDecode(_$StateEnumMap, json['state']),
      cardState: $enumDecode(_$StateEnumMap, json['cardState']),
      responseTime: (json['responseTime'] as num?)?.toDouble() ?? 0.0,
      userId: json['userId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ReviewLogModelToJson(ReviewLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cardId': instance.cardId,
      'cardType': instance.cardType,
      'rating': _$RatingEnumMap[instance.rating]!,
      'reviewDateTime': instance.reviewDateTime.toIso8601String(),
      'scheduledDays': instance.scheduledDays,
      'elapsedDays': instance.elapsedDays,
      'state': _$StateEnumMap[instance.state]!,
      'cardState': _$StateEnumMap[instance.cardState]!,
      'responseTime': instance.responseTime,
      'userId': instance.userId,
      'metadata': instance.metadata,
    };

const _$RatingEnumMap = {
  Rating.again: 'again',
  Rating.hard: 'hard',
  Rating.good: 'good',
  Rating.easy: 'easy',
};

const _$StateEnumMap = {
  State.learning: 'learning',
  State.review: 'review',
  State.relearning: 'relearning',
};
