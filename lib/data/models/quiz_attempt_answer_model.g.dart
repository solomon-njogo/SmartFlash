// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_attempt_answer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizAttemptAnswerModelAdapter
    extends TypeAdapter<QuizAttemptAnswerModel> {
  @override
  final int typeId = 29;

  @override
  QuizAttemptAnswerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizAttemptAnswerModel(
      id: fields[0] as String,
      attemptId: fields[1] as String,
      questionId: fields[2] as String,
      userAnswers: (fields[3] as List).cast<String>(),
      isCorrect: fields[4] as bool,
      answeredAt: fields[5] as DateTime,
      timeSpentSeconds: fields[6] as int,
      order: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuizAttemptAnswerModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.attemptId)
      ..writeByte(2)
      ..write(obj.questionId)
      ..writeByte(3)
      ..write(obj.userAnswers)
      ..writeByte(4)
      ..write(obj.isCorrect)
      ..writeByte(5)
      ..write(obj.answeredAt)
      ..writeByte(6)
      ..write(obj.timeSpentSeconds)
      ..writeByte(7)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizAttemptAnswerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizAttemptAnswerModel _$QuizAttemptAnswerModelFromJson(
        Map<String, dynamic> json) =>
    QuizAttemptAnswerModel(
      id: json['id'] as String,
      attemptId: json['attempt_id'] as String,
      questionId: json['question_id'] as String,
      userAnswers: (json['user_answers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isCorrect: json['is_correct'] as bool,
      answeredAt: DateTime.parse(json['answered_at'] as String),
      timeSpentSeconds: (json['time_spent_seconds'] as num).toInt(),
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$QuizAttemptAnswerModelToJson(
        QuizAttemptAnswerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'attempt_id': instance.attemptId,
      'question_id': instance.questionId,
      'user_answers': instance.userAnswers,
      'is_correct': instance.isCorrect,
      'answered_at': instance.answeredAt.toIso8601String(),
      'time_spent_seconds': instance.timeSpentSeconds,
      'order': instance.order,
    };
