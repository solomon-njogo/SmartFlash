import 'package:hive/hive.dart';
import '../../models/question_model.dart';
import '../../models/flashcard_model.dart';

/// Hive adapter for QuestionModel
class QuestionModelAdapter extends TypeAdapter<QuestionModel> {
  @override
  final int typeId = 3;

  @override
  QuestionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionModel(
      id: fields[0] as String,
      quizId: fields[1] as String,
      questionText: fields[2] as String,
      questionType: fields[3] as QuestionType? ?? QuestionType.multipleChoice,
      options: (fields[4] as List?)?.cast<String>() ?? const [],
      correctAnswers: (fields[5] as List?)?.cast<String>() ?? const [],
      explanation: fields[6] as String?,
      points: fields[7] as int? ?? 1,
      timeLimit: fields[8] as Duration?,
      imageUrl: fields[9] as String?,
      audioUrl: fields[10] as String?,
      order: fields[11] as int,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      createdBy: fields[14] as String?,
      isAIGenerated: fields[15] as bool? ?? false,
      metadata: fields[16] as Map<String, dynamic>?,
      tags: (fields[17] as List?)?.cast<String>(),
      difficulty: fields[18] as DifficultyLevel? ?? DifficultyLevel.medium,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.quizId)
      ..writeByte(2)
      ..write(obj.questionText)
      ..writeByte(3)
      ..write(obj.questionType)
      ..writeByte(4)
      ..write(obj.options)
      ..writeByte(5)
      ..write(obj.correctAnswers)
      ..writeByte(6)
      ..write(obj.explanation)
      ..writeByte(7)
      ..write(obj.points)
      ..writeByte(8)
      ..write(obj.timeLimit)
      ..writeByte(9)
      ..write(obj.imageUrl)
      ..writeByte(10)
      ..write(obj.audioUrl)
      ..writeByte(11)
      ..write(obj.order)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.createdBy)
      ..writeByte(15)
      ..write(obj.isAIGenerated)
      ..writeByte(16)
      ..write(obj.metadata)
      ..writeByte(17)
      ..write(obj.tags)
      ..writeByte(18)
      ..write(obj.difficulty);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
