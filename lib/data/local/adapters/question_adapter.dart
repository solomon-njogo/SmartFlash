import 'package:hive/hive.dart';
import '../../models/question_model.dart';

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
      order: fields[7] as int,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      createdBy: fields[10] as String?,
      isAIGenerated: fields[11] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionModel obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.order)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.createdBy)
      ..writeByte(11)
      ..write(obj.isAIGenerated);
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
