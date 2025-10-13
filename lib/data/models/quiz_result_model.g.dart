// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionResultAdapter extends TypeAdapter<QuestionResult> {
  @override
  final int typeId = 23;

  @override
  QuestionResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionResult(
      questionId: fields[0] as String,
      userAnswers: (fields[1] as List).cast<String>(),
      correctAnswers: (fields[2] as List).cast<String>(),
      isCorrect: fields[3] as bool,
      pointsEarned: fields[4] as int,
      maxPoints: fields[5] as int,
      timeSpent: fields[6] as Duration?,
      answeredAt: fields[7] as DateTime,
      explanation: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionResult obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.userAnswers)
      ..writeByte(2)
      ..write(obj.correctAnswers)
      ..writeByte(3)
      ..write(obj.isCorrect)
      ..writeByte(4)
      ..write(obj.pointsEarned)
      ..writeByte(5)
      ..write(obj.maxPoints)
      ..writeByte(6)
      ..write(obj.timeSpent)
      ..writeByte(7)
      ..write(obj.answeredAt)
      ..writeByte(8)
      ..write(obj.explanation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizResultModelAdapter extends TypeAdapter<QuizResultModel> {
  @override
  final int typeId = 5;

  @override
  QuizResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizResultModel(
      id: fields[0] as String,
      quizId: fields[1] as String,
      userId: fields[2] as String,
      status: fields[3] as QuizResultStatus,
      questionResults: (fields[4] as List).cast<QuestionResult>(),
      totalQuestions: fields[5] as int,
      correctAnswers: fields[6] as int,
      totalPoints: fields[7] as int,
      pointsEarned: fields[8] as int,
      scorePercentage: fields[9] as double,
      totalTime: fields[10] as Duration,
      startedAt: fields[11] as DateTime,
      completedAt: fields[12] as DateTime?,
      submittedAt: fields[13] as DateTime?,
      attemptNumber: fields[14] as int,
      metadata: (fields[15] as Map?)?.cast<String, dynamic>(),
      notes: fields[16] as String?,
      isPassed: fields[17] as bool,
      passingScore: fields[18] as double,
      incorrectQuestionIds: (fields[19] as List?)?.cast<String>(),
      timeLimit: fields[20] as Duration?,
      wasTimedOut: fields[21] as bool,
      analytics: (fields[22] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuizResultModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.quizId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.questionResults)
      ..writeByte(5)
      ..write(obj.totalQuestions)
      ..writeByte(6)
      ..write(obj.correctAnswers)
      ..writeByte(7)
      ..write(obj.totalPoints)
      ..writeByte(8)
      ..write(obj.pointsEarned)
      ..writeByte(9)
      ..write(obj.scorePercentage)
      ..writeByte(10)
      ..write(obj.totalTime)
      ..writeByte(11)
      ..write(obj.startedAt)
      ..writeByte(12)
      ..write(obj.completedAt)
      ..writeByte(13)
      ..write(obj.submittedAt)
      ..writeByte(14)
      ..write(obj.attemptNumber)
      ..writeByte(15)
      ..write(obj.metadata)
      ..writeByte(16)
      ..write(obj.notes)
      ..writeByte(17)
      ..write(obj.isPassed)
      ..writeByte(18)
      ..write(obj.passingScore)
      ..writeByte(19)
      ..write(obj.incorrectQuestionIds)
      ..writeByte(20)
      ..write(obj.timeLimit)
      ..writeByte(21)
      ..write(obj.wasTimedOut)
      ..writeByte(22)
      ..write(obj.analytics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizResultStatusAdapter extends TypeAdapter<QuizResultStatus> {
  @override
  final int typeId = 22;

  @override
  QuizResultStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuizResultStatus.inProgress;
      case 1:
        return QuizResultStatus.completed;
      case 2:
        return QuizResultStatus.abandoned;
      case 3:
        return QuizResultStatus.timedOut;
      default:
        return QuizResultStatus.inProgress;
    }
  }

  @override
  void write(BinaryWriter writer, QuizResultStatus obj) {
    switch (obj) {
      case QuizResultStatus.inProgress:
        writer.writeByte(0);
        break;
      case QuizResultStatus.completed:
        writer.writeByte(1);
        break;
      case QuizResultStatus.abandoned:
        writer.writeByte(2);
        break;
      case QuizResultStatus.timedOut:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizResultStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionResult _$QuestionResultFromJson(Map<String, dynamic> json) =>
    QuestionResult(
      questionId: json['questionId'] as String,
      userAnswers: (json['userAnswers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctAnswers: (json['correctAnswers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isCorrect: json['isCorrect'] as bool,
      pointsEarned: (json['pointsEarned'] as num).toInt(),
      maxPoints: (json['maxPoints'] as num).toInt(),
      timeSpent: json['timeSpent'] == null
          ? null
          : Duration(microseconds: (json['timeSpent'] as num).toInt()),
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      explanation: json['explanation'] as String?,
    );

Map<String, dynamic> _$QuestionResultToJson(QuestionResult instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'userAnswers': instance.userAnswers,
      'correctAnswers': instance.correctAnswers,
      'isCorrect': instance.isCorrect,
      'pointsEarned': instance.pointsEarned,
      'maxPoints': instance.maxPoints,
      'timeSpent': instance.timeSpent?.inMicroseconds,
      'answeredAt': instance.answeredAt.toIso8601String(),
      'explanation': instance.explanation,
    };

QuizResultModel _$QuizResultModelFromJson(Map<String, dynamic> json) =>
    QuizResultModel(
      id: json['id'] as String,
      quizId: json['quizId'] as String,
      userId: json['userId'] as String,
      status: $enumDecodeNullable(_$QuizResultStatusEnumMap, json['status']) ??
          QuizResultStatus.inProgress,
      questionResults: (json['questionResults'] as List<dynamic>?)
              ?.map((e) => QuestionResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      totalPoints: (json['totalPoints'] as num).toInt(),
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      scorePercentage: (json['scorePercentage'] as num?)?.toDouble() ?? 0.0,
      totalTime: json['totalTime'] == null
          ? Duration.zero
          : Duration(microseconds: (json['totalTime'] as num).toInt()),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      attemptNumber: (json['attemptNumber'] as num?)?.toInt() ?? 1,
      metadata: json['metadata'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      isPassed: json['isPassed'] as bool? ?? false,
      passingScore: (json['passingScore'] as num?)?.toDouble() ?? 70.0,
      incorrectQuestionIds: (json['incorrectQuestionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      timeLimit: json['timeLimit'] == null
          ? null
          : Duration(microseconds: (json['timeLimit'] as num).toInt()),
      wasTimedOut: json['wasTimedOut'] as bool? ?? false,
      analytics: json['analytics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$QuizResultModelToJson(QuizResultModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quizId': instance.quizId,
      'userId': instance.userId,
      'status': _$QuizResultStatusEnumMap[instance.status]!,
      'questionResults': instance.questionResults,
      'totalQuestions': instance.totalQuestions,
      'correctAnswers': instance.correctAnswers,
      'totalPoints': instance.totalPoints,
      'pointsEarned': instance.pointsEarned,
      'scorePercentage': instance.scorePercentage,
      'totalTime': instance.totalTime.inMicroseconds,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'attemptNumber': instance.attemptNumber,
      'metadata': instance.metadata,
      'notes': instance.notes,
      'isPassed': instance.isPassed,
      'passingScore': instance.passingScore,
      'incorrectQuestionIds': instance.incorrectQuestionIds,
      'timeLimit': instance.timeLimit?.inMicroseconds,
      'wasTimedOut': instance.wasTimedOut,
      'analytics': instance.analytics,
    };

const _$QuizResultStatusEnumMap = {
  QuizResultStatus.inProgress: 'inProgress',
  QuizResultStatus.completed: 'completed',
  QuizResultStatus.abandoned: 'abandoned',
  QuizResultStatus.timedOut: 'timedOut',
};
