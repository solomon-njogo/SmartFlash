// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_attempt_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizAttemptModelAdapter extends TypeAdapter<QuizAttemptModel> {
  @override
  final int typeId = 28;

  @override
  QuizAttemptModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizAttemptModel(
      id: fields[0] as String,
      quizId: fields[1] as String,
      userId: fields[2] as String,
      startedAt: fields[3] as DateTime,
      completedAt: fields[4] as DateTime?,
      status: fields[5] as QuizAttemptStatus,
      totalQuestions: fields[6] as int,
      correctAnswers: fields[7] as int,
      scorePercentage: fields[8] as double,
      totalTimeSeconds: fields[9] as int,
      attemptNumber: fields[10] as int,
      metadata: (fields[11] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      answers: (fields[14] as List?)?.cast<QuizAttemptAnswerModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuizAttemptModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.quizId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.startedAt)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.totalQuestions)
      ..writeByte(7)
      ..write(obj.correctAnswers)
      ..writeByte(8)
      ..write(obj.scorePercentage)
      ..writeByte(9)
      ..write(obj.totalTimeSeconds)
      ..writeByte(10)
      ..write(obj.attemptNumber)
      ..writeByte(11)
      ..write(obj.metadata)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.answers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizAttemptModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizAttemptStatusAdapter extends TypeAdapter<QuizAttemptStatus> {
  @override
  final int typeId = 27;

  @override
  QuizAttemptStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuizAttemptStatus.inProgress;
      case 1:
        return QuizAttemptStatus.completed;
      case 2:
        return QuizAttemptStatus.abandoned;
      default:
        return QuizAttemptStatus.inProgress;
    }
  }

  @override
  void write(BinaryWriter writer, QuizAttemptStatus obj) {
    switch (obj) {
      case QuizAttemptStatus.inProgress:
        writer.writeByte(0);
        break;
      case QuizAttemptStatus.completed:
        writer.writeByte(1);
        break;
      case QuizAttemptStatus.abandoned:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizAttemptStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizAttemptModel _$QuizAttemptModelFromJson(Map<String, dynamic> json) =>
    QuizAttemptModel(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String,
      userId: json['user_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      status: $enumDecodeNullable(_$QuizAttemptStatusEnumMap, json['status']) ??
          QuizAttemptStatus.inProgress,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correct_answers'] as num?)?.toInt() ?? 0,
      scorePercentage: (json['score_percentage'] as num?)?.toDouble() ?? 0.0,
      totalTimeSeconds: (json['total_time_seconds'] as num?)?.toInt() ?? 0,
      attemptNumber: (json['attempt_number'] as num?)?.toInt() ?? 1,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      answers: (json['answers'] as List<dynamic>?)
          ?.map(
              (e) => QuizAttemptAnswerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuizAttemptModelToJson(QuizAttemptModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quiz_id': instance.quizId,
      'user_id': instance.userId,
      'started_at': instance.startedAt.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'status': _$QuizAttemptStatusEnumMap[instance.status]!,
      'total_questions': instance.totalQuestions,
      'correct_answers': instance.correctAnswers,
      'score_percentage': instance.scorePercentage,
      'total_time_seconds': instance.totalTimeSeconds,
      'attempt_number': instance.attemptNumber,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'answers': instance.answers,
    };

const _$QuizAttemptStatusEnumMap = {
  QuizAttemptStatus.inProgress: 'inProgress',
  QuizAttemptStatus.completed: 'completed',
  QuizAttemptStatus.abandoned: 'abandoned',
};
