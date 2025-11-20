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
      status: fields[5] as QuizStatus? ?? QuizStatus.draft,
      createdBy: fields[6] as String,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      timeLimit: fields[9] as Duration?,
      totalQuestions: fields[10] as int? ?? 0,
      totalPoints: fields[11] as int? ?? 0,
      isRandomized: fields[12] as bool? ?? false,
      allowRetake: fields[13] as bool? ?? true,
      maxAttempts: fields[14] as int? ?? 0,
      showCorrectAnswers: fields[15] as bool? ?? true,
      showExplanations: fields[16] as bool? ?? true,
      showScore: fields[17] as bool? ?? true,
      coverImageUrl: fields[18] as String?,
      tags: (fields[19] as List?)?.cast<String>() ?? const [],
      settings: fields[20] as Map<String, dynamic>?,
      isAIGenerated: fields[21] as bool? ?? false,
      category: fields[22] as String?,
      subject: fields[23] as String?,
      difficulty: fields[24] as int? ?? 3,
      metadata: fields[25] as Map<String, dynamic>?,
      totalAttempts: fields[26] as int? ?? 0,
      averageScore: fields[27] as double? ?? 0.0,
      averageTime: fields[28] as Duration? ?? Duration.zero,
      lastTakenAt: fields[29] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, QuizModel obj) {
    writer
      ..writeByte(30)
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
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.createdBy)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.timeLimit)
      ..writeByte(10)
      ..write(obj.totalQuestions)
      ..writeByte(11)
      ..write(obj.totalPoints)
      ..writeByte(12)
      ..write(obj.isRandomized)
      ..writeByte(13)
      ..write(obj.allowRetake)
      ..writeByte(14)
      ..write(obj.maxAttempts)
      ..writeByte(15)
      ..write(obj.showCorrectAnswers)
      ..writeByte(16)
      ..write(obj.showExplanations)
      ..writeByte(17)
      ..write(obj.showScore)
      ..writeByte(18)
      ..write(obj.coverImageUrl)
      ..writeByte(19)
      ..write(obj.tags)
      ..writeByte(20)
      ..write(obj.settings)
      ..writeByte(21)
      ..write(obj.isAIGenerated)
      ..writeByte(22)
      ..write(obj.category)
      ..writeByte(23)
      ..write(obj.subject)
      ..writeByte(24)
      ..write(obj.difficulty)
      ..writeByte(25)
      ..write(obj.metadata)
      ..writeByte(26)
      ..write(obj.totalAttempts)
      ..writeByte(27)
      ..write(obj.averageScore)
      ..writeByte(28)
      ..write(obj.averageTime)
      ..writeByte(29)
      ..write(obj.lastTakenAt);
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
