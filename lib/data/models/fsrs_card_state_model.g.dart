// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fsrs_card_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FSRSCardState _$FSRSCardStateFromJson(Map<String, dynamic> json) => FSRSCardState(
      due: DateTime.parse(json['due'] as String),
      stability: (json['stability'] as num).toDouble(),
      difficulty: (json['difficulty'] as num).toDouble(),
      elapsedDays: json['elapsedDays'] as int,
      scheduledDays: json['scheduledDays'] as int,
      reps: json['reps'] as int,
      lapses: json['lapses'] as int,
      state: json['state'] as int,
      lastReview: DateTime.parse(json['lastReview'] as String),
    );

Map<String, dynamic> _$FSRSCardStateToJson(FSRSCardState instance) =>
    <String, dynamic>{
      'due': instance.due.toIso8601String(),
      'stability': instance.stability,
      'difficulty': instance.difficulty,
      'elapsedDays': instance.elapsedDays,
      'scheduledDays': instance.scheduledDays,
      'reps': instance.reps,
      'lapses': instance.lapses,
      'state': instance.state,
      'lastReview': instance.lastReview.toIso8601String(),
    };