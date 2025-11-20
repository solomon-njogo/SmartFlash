import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/course_material_model.dart';
import '../../data/remote/material_remote.dart';
import '../../core/utils/logger.dart';

/// Course material provider for managing course materials
class CourseMaterialProvider extends ChangeNotifier {
  List<CourseMaterialModel> _materials = [];
  bool _isLoading = false;
  String? _error;
  CourseMaterialModel? _selectedMaterial;

  /// List of all materials
  List<CourseMaterialModel> get materials => _materials;

  /// Whether data is loading
  bool get isLoading => _isLoading;

  /// Current error message
  String? get error => _error;

  /// Currently selected material
  CourseMaterialModel? get selectedMaterial => _selectedMaterial;

  CourseMaterialProvider() {
    _loadMaterials();
  }

  /// Load all materials from database
  Future<void> _loadMaterials() async {
    try {
      _setLoading(true);
      _clearError();

      // Try to load all materials from database
      try {
        final remote = MaterialRemoteDataSource();
        // Load all materials for all courses to support real-time counts
        final response = await remote.fetchAllMaterials();
        _materials =
            response.map((row) {
              return CourseMaterialModel(
                id: row['id'] as String,
                courseId: row['course_id'] as String,
                name: row['name'] as String,
                description: row['description'] as String?,
                fileType: _parseFileType(row['file_type'] as String),
                fileSizeBytes: row['file_size_bytes'] as int,
                fileUrl: row['file_url'] as String?,
                uploadedBy: row['uploaded_by'] as String,
                uploadedAt: DateTime.parse(row['uploaded_at'] as String),
                updatedAt: DateTime.parse(row['updated_at'] as String),
                tags: (row['tags'] as List<dynamic>?)?.cast<String>() ?? [],
                thumbnailUrl: row['thumbnail_url'] as String?,
                metadata: row['metadata'] as Map<String, dynamic>?,
                downloadCount: row['download_count'] as int? ?? 0,
                lastAccessedAt:
                    row['last_accessed_at'] != null
                        ? DateTime.parse(row['last_accessed_at'] as String)
                        : null,
              );
            }).toList();
      } catch (e) {
        // If database fetch fails, start with empty list
        _materials = [];
        Logger.warning(
          'Failed to load materials from database: $e',
          tag: 'Materials',
        );
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Load materials for a specific course
  Future<void> loadMaterialsForCourse(String courseId) async {
    try {
      _setLoading(true);
      _clearError();

      final remote = MaterialRemoteDataSource();
      final materialsData = await remote.fetchMaterialsByCourseId(courseId);

      // Convert database rows to CourseMaterialModel
      final courseMaterials =
          materialsData.map((row) {
            return CourseMaterialModel(
              id: row['id'] as String,
              courseId: row['course_id'] as String,
              name: row['name'] as String,
              description: row['description'] as String?,
              fileType: _parseFileType(row['file_type'] as String),
              fileSizeBytes: row['file_size_bytes'] as int,
              fileUrl: row['file_url'] as String?,
              uploadedBy: row['uploaded_by'] as String,
              uploadedAt: DateTime.parse(row['uploaded_at'] as String),
              updatedAt: DateTime.parse(row['updated_at'] as String),
              tags: (row['tags'] as List<dynamic>?)?.cast<String>() ?? [],
              thumbnailUrl: row['thumbnail_url'] as String?,
              metadata: row['metadata'] as Map<String, dynamic>?,
              downloadCount: row['download_count'] as int? ?? 0,
              lastAccessedAt:
                  row['last_accessed_at'] != null
                      ? DateTime.parse(row['last_accessed_at'] as String)
                      : null,
            );
          }).toList();

      // Update materials list: remove old materials for this course and add new ones
      _materials.removeWhere((m) => m.courseId == courseId);
      _materials.addAll(courseMaterials);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  FileType _parseFileType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return FileType.pdf;
      case 'doc':
        return FileType.doc;
      case 'docx':
        return FileType.docx;
      case 'ppt':
        return FileType.ppt;
      case 'pptx':
        return FileType.pptx;
      case 'image':
        return FileType.image;
      case 'audio':
        return FileType.audio;
      case 'video':
        return FileType.video;
      case 'text':
        return FileType.text;
      default:
        return FileType.other;
    }
  }

  /// Refresh materials from storage
  Future<void> refreshMaterials() async {
    await _loadMaterials();
  }

  /// Create a new material
  Future<bool> createMaterial(
    CourseMaterialModel material, {
    Uint8List? fileBytes,
    Function(double)? onProgress,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      // Upload to storage and insert DB row via Supabase
      final remote = MaterialRemoteDataSource();
      final inserted = await remote.uploadAndInsertMaterial(
        material,
        fileBytes: fileBytes,
        onProgress: onProgress,
      );

      // Build the final model with remote URL, clear local path
      final saved = material.copyWith(
        fileUrl: (inserted['file_url'] as String?),
        filePath: null,
        uploadedBy: inserted['uploaded_by'] as String? ?? material.uploadedBy,
        updatedAt:
            DateTime.tryParse(inserted['updated_at'] as String? ?? '') ??
            material.updatedAt,
      );

      // Check if material already exists (update) or add new
      final existingIndex = _materials.indexWhere((m) => m.id == saved.id);
      if (existingIndex != -1) {
        _materials[existingIndex] = saved;
      } else {
        _materials.add(saved);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing material
  Future<bool> updateMaterial(CourseMaterialModel material) async {
    try {
      _setLoading(true);
      _clearError();

      final index = _materials.indexWhere((m) => m.id == material.id);
      if (index != -1) {
        _materials[index] = material;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a material
  Future<bool> deleteMaterial(String materialId) async {
    try {
      _setLoading(true);
      _clearError();

      final material = getMaterialById(materialId);
      if (material == null) {
        _setError('Material not found');
        return false;
      }

      // Delete from remote (storage and database)
      final remote = MaterialRemoteDataSource();
      await remote.deleteMaterial(materialId, material.fileUrl);

      // Remove from local list
      _materials.removeWhere((m) => m.id == materialId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Download a material to local storage
  Future<String?> downloadMaterial(String materialId) async {
    try {
      _setLoading(true);
      _clearError();

      final material = getMaterialById(materialId);
      if (material == null || material.fileUrl == null) {
        _setError('Material or file URL not found');
        return null;
      }

      // Download file from storage
      final remote = MaterialRemoteDataSource();
      final fileBytes = await remote.downloadMaterial(material.fileUrl!);

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final materialsDir = Directory('${directory.path}/materials');
      if (!await materialsDir.exists()) {
        await materialsDir.create(recursive: true);
      }

      // Save file
      final filePath = '${materialsDir.path}/${material.name}';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      // Update material with local path
      final updatedMaterial = material.copyWith(
        filePath: filePath,
        isDownloaded: true,
        downloadCount: material.downloadCount + 1,
        lastAccessedAt: DateTime.now(),
      );

      final index = _materials.indexWhere((m) => m.id == materialId);
      if (index != -1) {
        _materials[index] = updatedMaterial;
        notifyListeners();
      }

      return filePath;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get material by ID
  CourseMaterialModel? getMaterialById(String materialId) {
    try {
      return _materials.firstWhere((material) => material.id == materialId);
    } catch (e) {
      return null;
    }
  }

  /// Get materials by course ID
  List<CourseMaterialModel> getMaterialsByCourseId(String courseId) {
    return _materials
        .where((material) => material.courseId == courseId)
        .toList();
  }

  /// Get material count for a specific course
  int getMaterialCountByCourseId(String courseId) {
    return _materials.where((material) => material.courseId == courseId).length;
  }

  /// Set selected material
  void selectMaterial(CourseMaterialModel material) {
    _selectedMaterial = material;
    notifyListeners();
  }

  /// Clear selected material
  void clearSelectedMaterial() {
    _selectedMaterial = null;
    notifyListeners();
  }

  /// Search materials by name
  List<CourseMaterialModel> searchMaterials(String query) {
    if (query.isEmpty) return _materials;

    return _materials
        .where(
          (material) =>
              material.name.toLowerCase().contains(query.toLowerCase()) ||
              (material.description?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false),
        )
        .toList();
  }

  /// Get materials by file type
  List<CourseMaterialModel> getMaterialsByFileType(FileType fileType) {
    return _materials
        .where((material) => material.fileType == fileType)
        .toList();
  }

  /// Get recently accessed materials
  List<CourseMaterialModel> getRecentlyAccessedMaterials() {
    return _materials.where((material) => material.isRecentlyAccessed).toList()
      ..sort(
        (a, b) => (b.lastAccessedAt ?? DateTime(1970)).compareTo(
          a.lastAccessedAt ?? DateTime(1970),
        ),
      );
  }

  /// Mark material as accessed
  void markMaterialAsAccessed(String materialId) {
    final material = getMaterialById(materialId);
    if (material != null) {
      final updatedMaterial = material.copyWith(
        lastAccessedAt: DateTime.now(),
        downloadCount: material.downloadCount + 1,
      );
      updateMaterial(updatedMaterial);
    }
  }

  /// Upload file (mock implementation)
  Future<bool> uploadFile({
    required String courseId,
    required String fileName,
    required FileType fileType,
    required int fileSizeBytes,
    String? description,
    List<String>? tags,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final material = CourseMaterialModel(
        id: '${courseId}_mat_${DateTime.now().millisecondsSinceEpoch}',
        courseId: courseId,
        name: fileName,
        description: description,
        fileType: fileType,
        fileSizeBytes: fileSizeBytes,
        uploadedBy: 'user1', // TODO: Get from auth provider
        uploadedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: tags ?? [],
      );

      _materials.add(material);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear error manually
  void clearError() {
    _clearError();
  }
}
