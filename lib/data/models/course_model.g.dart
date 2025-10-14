// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseModelAdapter extends TypeAdapter<CourseModel> {
  @override
  final int typeId = 30;

  @override
  CourseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      coverImageUrl: fields[3] as String?,
      iconName: fields[4] as String?,
      colorValue: fields[5] as int,
      deckIds: (fields[6] as List).cast<String>(),
      quizIds: (fields[7] as List).cast<String>(),
      materialIds: (fields[8] as List).cast<String>(),
      createdBy: fields[9] as String,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      tags: (fields[12] as List).cast<String>(),
      category: fields[13] as String?,
      subject: fields[14] as String?,
      totalDecks: fields[15] as int,
      totalQuizzes: fields[16] as int,
      totalMaterials: fields[17] as int,
      lastAccessedAt: fields[18] as DateTime?,
      metadata: (fields[19] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CourseModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.coverImageUrl)
      ..writeByte(4)
      ..write(obj.iconName)
      ..writeByte(5)
      ..write(obj.colorValue)
      ..writeByte(6)
      ..write(obj.deckIds)
      ..writeByte(7)
      ..write(obj.quizIds)
      ..writeByte(8)
      ..write(obj.materialIds)
      ..writeByte(9)
      ..write(obj.createdBy)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.category)
      ..writeByte(14)
      ..write(obj.subject)
      ..writeByte(15)
      ..write(obj.totalDecks)
      ..writeByte(16)
      ..write(obj.totalQuizzes)
      ..writeByte(17)
      ..write(obj.totalMaterials)
      ..writeByte(18)
      ..write(obj.lastAccessedAt)
      ..writeByte(19)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseModel _$CourseModelFromJson(Map<String, dynamic> json) => CourseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      iconName: json['iconName'] as String? ?? 'folder',
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF2196F3,
      deckIds: (json['deckIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      quizIds: (json['quizIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      materialIds: (json['materialIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      category: json['category'] as String?,
      subject: json['subject'] as String?,
      totalDecks: (json['totalDecks'] as num?)?.toInt() ?? 0,
      totalQuizzes: (json['totalQuizzes'] as num?)?.toInt() ?? 0,
      totalMaterials: (json['totalMaterials'] as num?)?.toInt() ?? 0,
      lastAccessedAt: json['lastAccessedAt'] == null
          ? null
          : DateTime.parse(json['lastAccessedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CourseModelToJson(CourseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'coverImageUrl': instance.coverImageUrl,
      'iconName': instance.iconName,
      'colorValue': instance.colorValue,
      'deckIds': instance.deckIds,
      'quizIds': instance.quizIds,
      'materialIds': instance.materialIds,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tags': instance.tags,
      'category': instance.category,
      'subject': instance.subject,
      'totalDecks': instance.totalDecks,
      'totalQuizzes': instance.totalQuizzes,
      'totalMaterials': instance.totalMaterials,
      'lastAccessedAt': instance.lastAccessedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };
