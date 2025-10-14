import 'package:hive/hive.dart';
import '../../models/question_model.dart';
import '../../models/fsrs_card_state_model.dart';

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
      question: fields[1] as String,
      options: (fields[2] as List).cast<String>(),
      correctAnswerIndex: fields[3] as int,
      explanation: fields[4] as String,
      quizId: fields[5] as String,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      fsrsState: fields[8] as FSRSCardState?,
      userId: fields[9] as String?,
      tags: (fields[10] as List).cast<String>(),
      difficulty: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.options)
      ..writeByte(3)
      ..write(obj.correctAnswerIndex)
      ..writeByte(4)
      ..write(obj.explanation)
      ..writeByte(5)
      ..write(obj.quizId)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.fsrsState)
      ..writeByte(9)
      ..write(obj.userId)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.difficulty);
  }
}