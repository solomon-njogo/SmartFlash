import 'package:flutter/foundation.dart';
import '../../data/models/course_material_model.dart';

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

  /// Load all materials from local storage
  Future<void> _loadMaterials() async {
    try {
      _setLoading(true);
      _clearError();

      // Sample materials for the 5 courses
      _materials = [
        // Computer Science 101 materials
        CourseMaterialModel(
          id: 'cs101_mat1',
          courseId: 'cs101',
          name: 'syllabus.pdf',
          description: 'Course syllabus and schedule',
          fileType: FileType.pdf,
          fileSizeBytes: (1024 * 1024).round(), // 1MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 30)),
          tags: ['syllabus', 'schedule'],
        ),
        CourseMaterialModel(
          id: 'cs101_mat2',
          courseId: 'cs101',
          name: 'lecture1.pdf',
          description: 'Introduction to Programming',
          fileType: FileType.pdf,
          fileSizeBytes: (2 * 1024 * 1024).round(), // 2MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 28)),
          updatedAt: DateTime.now().subtract(const Duration(days: 28)),
          tags: ['lecture', 'programming'],
        ),
        CourseMaterialModel(
          id: 'cs101_mat3',
          courseId: 'cs101',
          name: 'cheatsheet.png',
          description: 'Programming syntax reference',
          fileType: FileType.image,
          fileSizeBytes: (512 * 1024).round(), // 512KB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 25)),
          updatedAt: DateTime.now().subtract(const Duration(days: 25)),
          tags: ['reference', 'syntax'],
        ),
        CourseMaterialModel(
          id: 'cs101_mat4',
          courseId: 'cs101',
          name: 'assignment1.docx',
          description: 'First programming assignment',
          fileType: FileType.docx,
          fileSizeBytes: (256 * 1024).round(), // 256KB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 20)),
          tags: ['assignment', 'homework'],
        ),

        // Biology Advanced materials
        CourseMaterialModel(
          id: 'bio_adv_mat1',
          courseId: 'bio_adv',
          name: 'textbook_ch1.pdf',
          description: 'Cell Biology Chapter 1',
          fileType: FileType.pdf,
          fileSizeBytes: (5 * 1024 * 1024).round(), // 5MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 25)),
          updatedAt: DateTime.now().subtract(const Duration(days: 25)),
          tags: ['textbook', 'cell-biology'],
        ),
        CourseMaterialModel(
          id: 'bio_adv_mat2',
          courseId: 'bio_adv',
          name: 'lab_notes.pdf',
          description: 'Laboratory experiment notes',
          fileType: FileType.pdf,
          fileSizeBytes: (1.5 * 1024 * 1024).round(), // 1.5MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 22)),
          updatedAt: DateTime.now().subtract(const Duration(days: 22)),
          tags: ['lab', 'experiment'],
        ),
        CourseMaterialModel(
          id: 'bio_adv_mat3',
          courseId: 'bio_adv',
          name: 'diagram.jpg',
          description: 'Cell structure diagram',
          fileType: FileType.image,
          fileSizeBytes: (800 * 1024).round(), // 800KB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 20)),
          tags: ['diagram', 'cell-structure'],
        ),

        // World History materials
        CourseMaterialModel(
          id: 'hist_mat1',
          courseId: 'world_history',
          name: 'timeline.pdf',
          description: 'World history timeline',
          fileType: FileType.pdf,
          fileSizeBytes: (3 * 1024 * 1024).round(), // 3MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 20)),
          tags: ['timeline', 'chronology'],
        ),
        CourseMaterialModel(
          id: 'hist_mat2',
          courseId: 'world_history',
          name: 'map.png',
          description: 'Historical world map',
          fileType: FileType.image,
          fileSizeBytes: (1.2 * 1024 * 1024).round(), // 1.2MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 18)),
          updatedAt: DateTime.now().subtract(const Duration(days: 18)),
          tags: ['map', 'geography'],
        ),

        // Mathematics materials
        CourseMaterialModel(
          id: 'math_mat1',
          courseId: 'math_course',
          name: 'formula_sheet.pdf',
          description: 'Mathematical formulas reference',
          fileType: FileType.pdf,
          fileSizeBytes: (2.5 * 1024 * 1024).round(), // 2.5MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now().subtract(const Duration(days: 15)),
          tags: ['formulas', 'reference'],
        ),
        CourseMaterialModel(
          id: 'math_mat2',
          courseId: 'math_course',
          name: 'practice_problems.pdf',
          description: 'Algebra practice problems',
          fileType: FileType.pdf,
          fileSizeBytes: (1.8 * 1024 * 1024).round(), // 1.8MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 12)),
          updatedAt: DateTime.now().subtract(const Duration(days: 12)),
          tags: ['practice', 'algebra'],
        ),
        CourseMaterialModel(
          id: 'math_mat3',
          courseId: 'math_course',
          name: 'geometry_theorems.pdf',
          description: 'Geometry theorems and proofs',
          fileType: FileType.pdf,
          fileSizeBytes: (2.2 * 1024 * 1024).round(), // 2.2MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10)),
          tags: ['geometry', 'theorems'],
        ),
        CourseMaterialModel(
          id: 'math_mat4',
          courseId: 'math_course',
          name: 'calculus_notes.pdf',
          description: 'Calculus lecture notes',
          fileType: FileType.pdf,
          fileSizeBytes: (3.5 * 1024 * 1024).round(), // 3.5MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 8)),
          updatedAt: DateTime.now().subtract(const Duration(days: 8)),
          tags: ['calculus', 'notes'],
        ),
        CourseMaterialModel(
          id: 'math_mat5',
          courseId: 'math_course',
          name: 'statistics_examples.pdf',
          description: 'Statistics examples and solutions',
          fileType: FileType.pdf,
          fileSizeBytes: (1.9 * 1024 * 1024).round(), // 1.9MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          tags: ['statistics', 'examples'],
        ),

        // Spanish Language materials
        CourseMaterialModel(
          id: 'spanish_mat1',
          courseId: 'spanish_lang',
          name: 'grammar_guide.pdf',
          description: 'Spanish grammar reference guide',
          fileType: FileType.pdf,
          fileSizeBytes: (2.8 * 1024 * 1024).round(), // 2.8MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10)),
          tags: ['grammar', 'reference'],
        ),
        CourseMaterialModel(
          id: 'spanish_mat2',
          courseId: 'spanish_lang',
          name: 'pronunciation.mp3',
          description: 'Spanish pronunciation guide',
          fileType: FileType.audio,
          fileSizeBytes: (5 * 1024 * 1024).round(), // 5MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 8)),
          updatedAt: DateTime.now().subtract(const Duration(days: 8)),
          tags: ['pronunciation', 'audio'],
        ),
        CourseMaterialModel(
          id: 'spanish_mat3',
          courseId: 'spanish_lang',
          name: 'exercises.pdf',
          description: 'Spanish vocabulary exercises',
          fileType: FileType.pdf,
          fileSizeBytes: (1.5 * 1024 * 1024).round(), // 1.5MB
          uploadedBy: 'user1',
          uploadedAt: DateTime.now().subtract(const Duration(days: 6)),
          updatedAt: DateTime.now().subtract(const Duration(days: 6)),
          tags: ['exercises', 'vocabulary'],
        ),
      ];
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh materials from storage
  Future<void> refreshMaterials() async {
    await _loadMaterials();
  }

  /// Create a new material
  Future<bool> createMaterial(CourseMaterialModel material) async {
    try {
      _setLoading(true);
      _clearError();

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

      _materials.removeWhere((material) => material.id == materialId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
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
