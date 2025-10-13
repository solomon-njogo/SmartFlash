import 'package:hive/hive.dart';
import '../../models/flashcard_model.dart';

/// Hive adapter for FlashcardModel
class FlashcardModelAdapter extends TypeAdapter<FlashcardModel> {
  @override
  final int typeId = 1;

  @override
  FlashcardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlashcardModel(
      id: fields[0] as String,
      deckId: fields[1] as String,
      frontText: fields[2] as String,
      backText: fields[3] as String,
      frontImageUrl: fields[4] as String?,
      backImageUrl: fields[5] as String?,
      difficulty: fields[6] as DifficultyLevel? ?? DifficultyLevel.medium,
      cardType: fields[7] as CardType? ?? CardType.basic,
      tags: (fields[8] as List?)?.cast<String>(),
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      createdBy: fields[11] as String?,
      isAIGenerated: fields[12] as bool? ?? false,
      metadata: fields[13] as Map<String, dynamic>?,
      interval: fields[14] as int? ?? 1,
      easeFactor: fields[15] as double? ?? 2.5,
      repetitions: fields[16] as int? ?? 0,
      nextReviewDate: fields[17] as DateTime?,
      lastReviewedAt: fields[18] as DateTime?,
      consecutiveCorrectAnswers: fields[19] as int? ?? 0,
      totalReviews: fields[20] as int? ?? 0,
      averageResponseTime: fields[21] as double? ?? 0.0,
    );
  }

  @override
  void write(BinaryWriter writer, FlashcardModel obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.deckId)
      ..writeByte(2)
      ..write(obj.frontText)
      ..writeByte(3)
      ..write(obj.backText)
      ..writeByte(4)
      ..write(obj.frontImageUrl)
      ..writeByte(5)
      ..write(obj.backImageUrl)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.cardType)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.createdBy)
      ..writeByte(12)
      ..write(obj.isAIGenerated)
      ..writeByte(13)
      ..write(obj.metadata)
      ..writeByte(14)
      ..write(obj.interval)
      ..writeByte(15)
      ..write(obj.easeFactor)
      ..writeByte(16)
      ..write(obj.repetitions)
      ..writeByte(17)
      ..write(obj.nextReviewDate)
      ..writeByte(18)
      ..write(obj.lastReviewedAt)
      ..writeByte(19)
      ..write(obj.consecutiveCorrectAnswers)
      ..writeByte(20)
      ..write(obj.totalReviews)
      ..writeByte(21)
      ..write(obj.averageResponseTime);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashcardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
