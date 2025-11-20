import 'package:hive/hive.dart';
import '../../models/deck_model.dart';

/// Hive adapter for DeckModel
class DeckModelAdapter extends TypeAdapter<DeckModel> {
  @override
  final int typeId = 2;

  @override
  DeckModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeckModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      coverImageUrl: fields[3] as String?,
      tags: (fields[4] as List?)?.cast<String>() ?? const [],
      visibility: fields[5] as DeckVisibility? ?? DeckVisibility.private,
      studyMode: fields[6] as StudyMode? ?? StudyMode.spacedRepetition,
      createdBy: fields[7] as String,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      totalCards: fields[10] as int? ?? 0,
      studiedCards: fields[11] as int? ?? 0,
      masteredCards: fields[12] as int? ?? 0,
      averageScore: fields[13] as double? ?? 0.0,
      totalStudyTime: fields[14] as Duration? ?? Duration.zero,
      lastStudiedAt: fields[15] as DateTime?,
      isBookmarked: fields[16] as bool? ?? false,
      bookmarkCount: fields[17] as int? ?? 0,
      settings: fields[18] as Map<String, dynamic>?,
      category: fields[19] as String?,
      subject: fields[20] as String?,
      difficulty: fields[21] as int? ?? 3,
      isAIGenerated: fields[22] as bool? ?? false,
      sourceFileUrl: fields[23] as String?,
      metadata: fields[24] as Map<String, dynamic>?,
    );
  }

  @override
  void write(BinaryWriter writer, DeckModel obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.coverImageUrl)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.visibility)
      ..writeByte(6)
      ..write(obj.studyMode)
      ..writeByte(7)
      ..write(obj.createdBy)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.totalCards)
      ..writeByte(11)
      ..write(obj.studiedCards)
      ..writeByte(12)
      ..write(obj.masteredCards)
      ..writeByte(13)
      ..write(obj.averageScore)
      ..writeByte(14)
      ..write(obj.totalStudyTime)
      ..writeByte(15)
      ..write(obj.lastStudiedAt)
      ..writeByte(16)
      ..write(obj.isBookmarked)
      ..writeByte(17)
      ..write(obj.bookmarkCount)
      ..writeByte(18)
      ..write(obj.settings)
      ..writeByte(19)
      ..write(obj.category)
      ..writeByte(20)
      ..write(obj.subject)
      ..writeByte(21)
      ..write(obj.difficulty)
      ..writeByte(22)
      ..write(obj.isAIGenerated)
      ..writeByte(23)
      ..write(obj.sourceFileUrl)
      ..writeByte(24)
      ..write(obj.metadata);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
