// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewLog _$ReviewLogFromJson(Map<String, dynamic> json) => ReviewLog(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      rating: json['rating'] as int,
      reviewDateTime: DateTime.parse(json['reviewDateTime'] as String),
      scheduledDays: json['scheduledDays'] as int,
      elapsedDays: json['elapsedDays'] as int,
      state: json['state'] as int,
      cardState: FSRSCardState.fromJson(json['cardState'] as Map<String, dynamic>),
      reviewType: json['reviewType'] as String,
    );

Map<String, dynamic> _$ReviewLogToJson(ReviewLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cardId': instance.cardId,
      'rating': instance.rating,
      'reviewDateTime': instance.reviewDateTime.toIso8601String(),
      'scheduledDays': instance.scheduledDays,
      'elapsedDays': instance.elapsedDays,
      'state': instance.state,
      'cardState': instance.cardState.toJson(),
      'reviewType': instance.reviewType,
    };