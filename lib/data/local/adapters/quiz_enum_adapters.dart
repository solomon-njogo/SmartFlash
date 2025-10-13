import 'package:hive/hive.dart';
import '../../models/question_model.dart';
import '../../models/quiz_model.dart';
import '../../models/quiz_result_model.dart';

/// Hive adapter for QuestionType enum
class QuestionTypeAdapter extends TypeAdapter<QuestionType> {
  @override
  final int typeId = 20;

  @override
  QuestionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuestionType.multipleChoice;
      case 1:
        return QuestionType.trueFalse;
      case 2:
        return QuestionType.fillInTheBlank;
      case 3:
        return QuestionType.matching;
      case 4:
        return QuestionType.shortAnswer;
      default:
        return QuestionType.multipleChoice;
    }
  }

  @override
  void write(BinaryWriter writer, QuestionType obj) {
    switch (obj) {
      case QuestionType.multipleChoice:
        writer.writeByte(0);
        break;
      case QuestionType.trueFalse:
        writer.writeByte(1);
        break;
      case QuestionType.fillInTheBlank:
        writer.writeByte(2);
        break;
      case QuestionType.matching:
        writer.writeByte(3);
        break;
      case QuestionType.shortAnswer:
        writer.writeByte(4);
        break;
    }
  }
}

/// Hive adapter for QuizStatus enum
class QuizStatusAdapter extends TypeAdapter<QuizStatus> {
  @override
  final int typeId = 21;

  @override
  QuizStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuizStatus.draft;
      case 1:
        return QuizStatus.published;
      case 2:
        return QuizStatus.archived;
      default:
        return QuizStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, QuizStatus obj) {
    switch (obj) {
      case QuizStatus.draft:
        writer.writeByte(0);
        break;
      case QuizStatus.published:
        writer.writeByte(1);
        break;
      case QuizStatus.archived:
        writer.writeByte(2);
        break;
    }
  }
}

/// Hive adapter for QuizResultStatus enum
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
}

/// Hive adapter for QuestionResult class
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
      userAnswers: (fields[1] as List?)?.cast<String>() ?? const [],
      correctAnswers: (fields[2] as List?)?.cast<String>() ?? const [],
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
}
