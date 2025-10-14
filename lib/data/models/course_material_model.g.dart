// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_material_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseMaterialModelAdapter extends TypeAdapter<CourseMaterialModel> {
  @override
  final int typeId = 31;

  @override
  CourseMaterialModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseMaterialModel(
      id: fields[0] as String,
      courseId: fields[1] as String,
      name: fields[2] as String,
      description: fields[3] as String?,
      fileType: fields[4] as FileType,
      fileSizeBytes: fields[5] as int,
      fileUrl: fields[6] as String?,
      filePath: fields[7] as String?,
      uploadedBy: fields[8] as String,
      uploadedAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      tags: (fields[11] as List).cast<String>(),
      thumbnailUrl: fields[12] as String?,
      metadata: (fields[13] as Map?)?.cast<String, dynamic>(),
      isDownloaded: fields[14] as bool,
      downloadCount: fields[15] as int,
      lastAccessedAt: fields[16] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CourseMaterialModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.fileType)
      ..writeByte(5)
      ..write(obj.fileSizeBytes)
      ..writeByte(6)
      ..write(obj.fileUrl)
      ..writeByte(7)
      ..write(obj.filePath)
      ..writeByte(8)
      ..write(obj.uploadedBy)
      ..writeByte(9)
      ..write(obj.uploadedAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.thumbnailUrl)
      ..writeByte(13)
      ..write(obj.metadata)
      ..writeByte(14)
      ..write(obj.isDownloaded)
      ..writeByte(15)
      ..write(obj.downloadCount)
      ..writeByte(16)
      ..write(obj.lastAccessedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseMaterialModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FileTypeAdapter extends TypeAdapter<FileType> {
  @override
  final int typeId = 32;

  @override
  FileType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FileType.pdf;
      case 1:
        return FileType.doc;
      case 2:
        return FileType.docx;
      case 3:
        return FileType.ppt;
      case 4:
        return FileType.pptx;
      case 5:
        return FileType.image;
      case 6:
        return FileType.audio;
      case 7:
        return FileType.video;
      case 8:
        return FileType.text;
      case 9:
        return FileType.other;
      default:
        return FileType.pdf;
    }
  }

  @override
  void write(BinaryWriter writer, FileType obj) {
    switch (obj) {
      case FileType.pdf:
        writer.writeByte(0);
        break;
      case FileType.doc:
        writer.writeByte(1);
        break;
      case FileType.docx:
        writer.writeByte(2);
        break;
      case FileType.ppt:
        writer.writeByte(3);
        break;
      case FileType.pptx:
        writer.writeByte(4);
        break;
      case FileType.image:
        writer.writeByte(5);
        break;
      case FileType.audio:
        writer.writeByte(6);
        break;
      case FileType.video:
        writer.writeByte(7);
        break;
      case FileType.text:
        writer.writeByte(8);
        break;
      case FileType.other:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseMaterialModel _$CourseMaterialModelFromJson(Map<String, dynamic> json) =>
    CourseMaterialModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      fileType: $enumDecode(_$FileTypeEnumMap, json['fileType']),
      fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
      fileUrl: json['fileUrl'] as String?,
      filePath: json['filePath'] as String?,
      uploadedBy: json['uploadedBy'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      thumbnailUrl: json['thumbnailUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
      lastAccessedAt: json['lastAccessedAt'] == null
          ? null
          : DateTime.parse(json['lastAccessedAt'] as String),
    );

Map<String, dynamic> _$CourseMaterialModelToJson(
        CourseMaterialModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'name': instance.name,
      'description': instance.description,
      'fileType': _$FileTypeEnumMap[instance.fileType]!,
      'fileSizeBytes': instance.fileSizeBytes,
      'fileUrl': instance.fileUrl,
      'filePath': instance.filePath,
      'uploadedBy': instance.uploadedBy,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tags': instance.tags,
      'thumbnailUrl': instance.thumbnailUrl,
      'metadata': instance.metadata,
      'isDownloaded': instance.isDownloaded,
      'downloadCount': instance.downloadCount,
      'lastAccessedAt': instance.lastAccessedAt?.toIso8601String(),
    };

const _$FileTypeEnumMap = {
  FileType.pdf: 'pdf',
  FileType.doc: 'doc',
  FileType.docx: 'docx',
  FileType.ppt: 'ppt',
  FileType.pptx: 'pptx',
  FileType.image: 'image',
  FileType.audio: 'audio',
  FileType.video: 'video',
  FileType.text: 'text',
  FileType.other: 'other',
};
