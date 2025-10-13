import 'package:hive/hive.dart';
import '../../models/quiz_result_model.dart';

/// Hive adapter for QuizResultModel
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
      status: fields[3] as QuizResultStatus? ?? QuizResultStatus.inProgress,
      questionResults: (fields[4] as List?)?.cast<QuestionResult>() ?? const [],
      totalQuestions: fields[5] as int,
      correctAnswers: fields[6] as int? ?? 0,
      totalPoints: fields[7] as int,
      pointsEarned: fields[8] as int? ?? 0,
      scorePercentage: fields[9] as double? ?? 0.0,
      totalTime: fields[10] as Duration? ?? Duration.zero,
      startedAt: fields[11] as DateTime,
      completedAt: fields[12] as DateTime?,
      submittedAt: fields[13] as DateTime?,
      attemptNumber: fields[14] as int? ?? 1,
      metadata: fields[15] as Map<String, dynamic>?,
      notes: fields[16] as String?,
      isPassed: fields[17] as bool? ?? false,
      passingScore: fields[18] as double? ?? 70.0,
      incorrectQuestionIds: (fields[19] as List?)?.cast<String>(),
      timeLimit: fields[20] as Duration?,
      wasTimedOut: fields[21] as bool? ?? false,
      analytics: fields[22] as Map<String, dynamic>?,
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
