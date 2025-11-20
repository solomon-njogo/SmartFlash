import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'course_material_model.g.dart';

/// File types for course materials
@HiveType(typeId: 32)
enum FileType {
  @HiveField(0)
  pdf,
  @HiveField(1)
  doc,
  @HiveField(2)
  docx,
  @HiveField(3)
  ppt,
  @HiveField(4)
  pptx,
  @HiveField(5)
  image,
  @HiveField(6)
  audio,
  @HiveField(7)
  video,
  @HiveField(8)
  text,
  @HiveField(9)
  other,
}

/// Course material model for uploaded files
@HiveType(typeId: 31)
@JsonSerializable()
class CourseMaterialModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String courseId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final FileType fileType;

  @HiveField(5)
  final int fileSizeBytes;

  @HiveField(6)
  final String? fileUrl;

  @HiveField(7)
  final String? filePath; // Local file path

  @HiveField(8)
  final String uploadedBy;

  @HiveField(9)
  final DateTime uploadedAt;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final List<String> tags;

  @HiveField(12)
  final String? thumbnailUrl;

  @HiveField(13)
  final Map<String, dynamic>? metadata;

  @HiveField(14)
  final bool isDownloaded;

  @HiveField(15)
  final int downloadCount;

  @HiveField(16)
  final DateTime? lastAccessedAt;

  CourseMaterialModel({
    required this.id,
    required this.courseId,
    required this.name,
    this.description,
    required this.fileType,
    required this.fileSizeBytes,
    this.fileUrl,
    this.filePath,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.updatedAt,
    this.tags = const [],
    this.thumbnailUrl,
    this.metadata,
    this.isDownloaded = false,
    this.downloadCount = 0,
    this.lastAccessedAt,
  });

  /// Create CourseMaterialModel from JSON
  factory CourseMaterialModel.fromJson(Map<String, dynamic> json) =>
      _$CourseMaterialModelFromJson(json);

  /// Convert CourseMaterialModel to JSON
  Map<String, dynamic> toJson() => _$CourseMaterialModelToJson(this);

  /// Create a copy of CourseMaterialModel with updated fields
  CourseMaterialModel copyWith({
    String? id,
    String? courseId,
    String? name,
    String? description,
    FileType? fileType,
    int? fileSizeBytes,
    String? fileUrl,
    String? filePath,
    String? uploadedBy,
    DateTime? uploadedAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    bool? isDownloaded,
    int? downloadCount,
    DateTime? lastAccessedAt,
  }) {
    return CourseMaterialModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      description: description ?? this.description,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      fileUrl: fileUrl ?? this.fileUrl,
      filePath: filePath ?? this.filePath,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      metadata: metadata ?? this.metadata,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadCount: downloadCount ?? this.downloadCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  /// Get file size as human readable string
  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (fileSizeBytes < 1024 * 1024 * 1024) {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Get file type as string
  String get fileTypeString {
    switch (fileType) {
      case FileType.pdf:
        return 'PDF';
      case FileType.doc:
        return 'DOC';
      case FileType.docx:
        return 'DOCX';
      case FileType.ppt:
        return 'PPT';
      case FileType.pptx:
        return 'PPTX';
      case FileType.image:
        return 'Image';
      case FileType.audio:
        return 'Audio';
      case FileType.video:
        return 'Video';
      case FileType.text:
        return 'Text';
      case FileType.other:
        return 'Other';
    }
  }

  /// Get file extension
  String get fileExtension {
    switch (fileType) {
      case FileType.pdf:
        return '.pdf';
      case FileType.doc:
        return '.doc';
      case FileType.docx:
        return '.docx';
      case FileType.ppt:
        return '.ppt';
      case FileType.pptx:
        return '.pptx';
      case FileType.image:
        return '.jpg'; // Default image extension
      case FileType.audio:
        return '.mp3'; // Default audio extension
      case FileType.video:
        return '.mp4'; // Default video extension
      case FileType.text:
        return '.txt';
      case FileType.other:
        return '';
    }
  }

  /// Check if file is accessible locally
  bool get isLocalFile => filePath != null && filePath!.isNotEmpty;

  /// Check if file is accessible remotely
  bool get isRemoteFile => fileUrl != null && fileUrl!.isNotEmpty;

  /// Check if material has been accessed recently
  bool get isRecentlyAccessed {
    if (lastAccessedAt == null) return false;
    final daysSinceLastAccess =
        DateTime.now().difference(lastAccessedAt!).inDays;
    return daysSinceLastAccess <= 7;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseMaterialModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CourseMaterialModel(id: $id, name: $name, fileType: $fileTypeString)';
  }
}
