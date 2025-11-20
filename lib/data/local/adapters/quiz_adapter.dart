import 'package:hive/hive.dart';
import '../../models/quiz_model.dart';

/// Hive adapter for QuizModel
class QuizModelAdapter extends TypeAdapter<QuizModel> {
  @override
  final int typeId = 4;

  @override
  QuizModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      deckId: fields[3] as String,
      questionIds: (fields[4] as List?)?.cast<String>() ?? const [],
      createdBy: fields[5] as String,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      isAIGenerated: fields[8] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, QuizModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.deckId)
      ..writeByte(4)
      ..write(obj.questionIds)
      ..writeByte(5)
      ..write(obj.createdBy)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.isAIGenerated);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
