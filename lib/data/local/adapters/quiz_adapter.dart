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
    // Handle migration: skip old deckId field (3) if present
    return QuizModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      questionIds: (fields[4] as List?)?.cast<String>() ?? 
                   (fields[3] as List?)?.cast<String>() ?? const [],
      createdBy: fields[5] as String? ?? fields[4] as String? ?? '',
      createdAt: fields[6] as DateTime? ?? fields[5] as DateTime? ?? DateTime.now(),
      updatedAt: fields[7] as DateTime? ?? fields[6] as DateTime? ?? DateTime.now(),
      isAIGenerated: fields[8] as bool? ?? fields[7] as bool? ?? false,
      courseId: fields[9] as String? ?? fields[8] as String? ?? '',
      materialIds: (fields[10] as List?)?.cast<String>() ?? 
                   (fields[9] as List?)?.cast<String>() ?? const [],
    );
  }

  @override
  void write(BinaryWriter writer, QuizModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.questionIds)
      ..writeByte(4)
      ..write(obj.createdBy)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.isAIGenerated)
      ..writeByte(8)
      ..write(obj.courseId)
      ..writeByte(9)
      ..write(obj.materialIds);
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
