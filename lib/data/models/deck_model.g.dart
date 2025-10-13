// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      tags: (fields[4] as List).cast<String>(),
      visibility: fields[5] as DeckVisibility,
      studyMode: fields[6] as StudyMode,
      createdBy: fields[7] as String,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      totalCards: fields[10] as int,
      studiedCards: fields[11] as int,
      masteredCards: fields[12] as int,
      averageScore: fields[13] as double,
      totalStudyTime: fields[14] as Duration,
      lastStudiedAt: fields[15] as DateTime?,
      isBookmarked: fields[16] as bool,
      bookmarkCount: fields[17] as int,
      settings: (fields[18] as Map?)?.cast<String, dynamic>(),
      category: fields[19] as String?,
      subject: fields[20] as String?,
      difficulty: fields[21] as int,
      isAIGenerated: fields[22] as bool,
      sourceFileUrl: fields[23] as String?,
      metadata: (fields[24] as Map?)?.cast<String, dynamic>(),
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
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeckVisibilityAdapter extends TypeAdapter<DeckVisibility> {
  @override
  final int typeId = 12;

  @override
  DeckVisibility read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DeckVisibility.private;
      case 1:
        return DeckVisibility.public;
      case 2:
        return DeckVisibility.shared;
      default:
        return DeckVisibility.private;
    }
  }

  @override
  void write(BinaryWriter writer, DeckVisibility obj) {
    switch (obj) {
      case DeckVisibility.private:
        writer.writeByte(0);
        break;
      case DeckVisibility.public:
        writer.writeByte(1);
        break;
      case DeckVisibility.shared:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckVisibilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StudyModeAdapter extends TypeAdapter<StudyMode> {
  @override
  final int typeId = 13;

  @override
  StudyMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StudyMode.spacedRepetition;
      case 1:
        return StudyMode.sequential;
      case 2:
        return StudyMode.random;
      case 3:
        return StudyMode.difficultyBased;
      default:
        return StudyMode.spacedRepetition;
    }
  }

  @override
  void write(BinaryWriter writer, StudyMode obj) {
    switch (obj) {
      case StudyMode.spacedRepetition:
        writer.writeByte(0);
        break;
      case StudyMode.sequential:
        writer.writeByte(1);
        break;
      case StudyMode.random:
        writer.writeByte(2);
        break;
      case StudyMode.difficultyBased:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeckModel _$DeckModelFromJson(Map<String, dynamic> json) => DeckModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      visibility:
          $enumDecodeNullable(_$DeckVisibilityEnumMap, json['visibility']) ??
              DeckVisibility.private,
      studyMode: $enumDecodeNullable(_$StudyModeEnumMap, json['studyMode']) ??
          StudyMode.spacedRepetition,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      totalCards: (json['totalCards'] as num?)?.toInt() ?? 0,
      studiedCards: (json['studiedCards'] as num?)?.toInt() ?? 0,
      masteredCards: (json['masteredCards'] as num?)?.toInt() ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      totalStudyTime: json['totalStudyTime'] == null
          ? Duration.zero
          : Duration(microseconds: (json['totalStudyTime'] as num).toInt()),
      lastStudiedAt: json['lastStudiedAt'] == null
          ? null
          : DateTime.parse(json['lastStudiedAt'] as String),
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      settings: json['settings'] as Map<String, dynamic>?,
      category: json['category'] as String?,
      subject: json['subject'] as String?,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 3,
      isAIGenerated: json['isAIGenerated'] as bool? ?? false,
      sourceFileUrl: json['sourceFileUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$DeckModelToJson(DeckModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'coverImageUrl': instance.coverImageUrl,
      'tags': instance.tags,
      'visibility': _$DeckVisibilityEnumMap[instance.visibility]!,
      'studyMode': _$StudyModeEnumMap[instance.studyMode]!,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'totalCards': instance.totalCards,
      'studiedCards': instance.studiedCards,
      'masteredCards': instance.masteredCards,
      'averageScore': instance.averageScore,
      'totalStudyTime': instance.totalStudyTime.inMicroseconds,
      'lastStudiedAt': instance.lastStudiedAt?.toIso8601String(),
      'isBookmarked': instance.isBookmarked,
      'bookmarkCount': instance.bookmarkCount,
      'settings': instance.settings,
      'category': instance.category,
      'subject': instance.subject,
      'difficulty': instance.difficulty,
      'isAIGenerated': instance.isAIGenerated,
      'sourceFileUrl': instance.sourceFileUrl,
      'metadata': instance.metadata,
    };

const _$DeckVisibilityEnumMap = {
  DeckVisibility.private: 'private',
  DeckVisibility.public: 'public',
  DeckVisibility.shared: 'shared',
};

const _$StudyModeEnumMap = {
  StudyMode.spacedRepetition: 'spacedRepetition',
  StudyMode.sequential: 'sequential',
  StudyMode.random: 'random',
  StudyMode.difficultyBased: 'difficultyBased',
};
