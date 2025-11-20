import 'dart:typed_data';

import 'package:file_picker/file_picker.dart' hide FileType;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/providers/course_material_provider.dart';
import '../../../core/providers/course_provider.dart';
import '../../../data/models/course_material_model.dart';

class UploadMaterialsScreen extends StatefulWidget {
  final String? preselectedCourseId;
  const UploadMaterialsScreen({super.key, this.preselectedCourseId});

  @override
  State<UploadMaterialsScreen> createState() => _UploadMaterialsScreenState();
}

class _UploadMaterialsScreenState extends State<UploadMaterialsScreen> {
  String? _selectedCourseId;
  final List<PlatformFile> _selectedFiles = [];
  final Map<String, String> _statusByName = {};
  final Map<String, double> _progressByName = {};
  bool _isUploading = false;
  static const int maxFileSizeBytes = 50 * 1024 * 1024; // 50MB

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.preselectedCourseId;
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    final files = result?.files ?? [];
    if (!mounted || files.isEmpty) return;

    // Validate file sizes
    final List<String> errors = [];
    final List<PlatformFile> validFiles = [];

    for (final file in files) {
      if (file.size > maxFileSizeBytes) {
        errors.add('${file.name} exceeds maximum size of 50MB');
      } else {
        // Check if file is already in the list (by name and identifier)
        final isDuplicate = _selectedFiles.any(
          (existingFile) =>
              existingFile.name == file.name &&
              existingFile.identifier == file.identifier,
        );

        if (!isDuplicate) {
          validFiles.add(file);
        }
      }
    }

    // Show errors if any
    if (errors.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Some files are too large:'),
              ...errors.map((e) => Text('• $e')),
            ],
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Add only new valid files to the existing list
    if (validFiles.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(validFiles);
        // Only clear status/progress for newly added files
        for (final file in validFiles) {
          _statusByName.remove(file.name);
          _progressByName.remove(file.name);
        }
      });
    } else if (errors.isEmpty && mounted) {
      // All files were duplicates
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All selected files are already in the list'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.removeWhere(
        (f) => f.identifier == file.identifier && f.name == file.name,
      );
      _statusByName.remove(file.name);
    });
  }

  FileType _mapExtensionToFileType(String? extension) {
    final ext = (extension ?? '').toLowerCase();
    switch (ext) {
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
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'webp':
        return FileType.image;
      case 'mp3':
      case 'wav':
      case 'm4a':
      case 'aac':
        return FileType.audio;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return FileType.video;
      case 'txt':
      case 'md':
      case 'rtf':
        return FileType.text;
      default:
        return FileType.other;
    }
  }

  Future<void> _uploadAll() async {
    if (_selectedCourseId == null || _selectedFiles.isEmpty) return;
    final materials = context.read<CourseMaterialProvider>();
    setState(() => _isUploading = true);

    int successCount = 0;

    for (final f in List<PlatformFile>.from(_selectedFiles)) {
      setState(() {
        _statusByName[f.name] = 'Preparing...';
        _progressByName[f.name] = 0.0;
      });

      try {
        final now = DateTime.now();
        final id =
            '${_selectedCourseId}_mat_${now.millisecondsSinceEpoch}_${f.name.hashCode}';

        // Get user ID from Supabase
        final userId = Supabase.instance.client.auth.currentUser?.id ?? 'user1';

        final model = CourseMaterialModel(
          id: id,
          courseId: _selectedCourseId!,
          name: f.name,
          fileType: _mapExtensionToFileType(f.extension),
          fileSizeBytes: f.size,
          filePath: f.path, // May be null on web
          uploadedBy: userId,
          uploadedAt: now,
          updatedAt: now,
        );

        // Read file bytes if path is null (web platform)
        Uint8List? fileBytes;
        if (f.path == null && f.bytes != null) {
          fileBytes = f.bytes;
        }

        setState(() => _statusByName[f.name] = 'Processing...');

        final ok = await materials.createMaterial(
          model,
          fileBytes: fileBytes,
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _progressByName[f.name] = progress;
                // Show combined progress for upload and extraction
                final progressPercent = (progress * 100).toStringAsFixed(0);
                if (progress < 0.7) {
                  _statusByName[f.name] = 'Uploading $progressPercent%';
                } else if (progress < 0.9) {
                  _statusByName[f.name] = 'Extracting text $progressPercent%';
                } else {
                  _statusByName[f.name] = 'Finalizing $progressPercent%';
                }
              });
            }
          },
        );

        if (!mounted) return;

        if (ok) {
          successCount++;
          setState(() {
            _statusByName[f.name] = 'Saved';
            _progressByName[f.name] = 1.0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved ${f.name}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final errorMsg = materials.error ?? 'Unknown error';
          setState(() {
            _statusByName[f.name] = 'Failed';
            _progressByName.remove(f.name);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save ${f.name}: $errorMsg'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _statusByName[f.name] = 'Failed';
          _progressByName.remove(f.name);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading ${f.name}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isUploading = false);

      // If at least one file was successfully uploaded and we have a course ID,
      // navigate back to the course details page on the materials tab
      if (successCount > 0 && _selectedCourseId != null) {
        // Reload materials for the course to show the newly uploaded ones
        materials.loadMaterialsForCourse(_selectedCourseId!);

        // Navigate back to course details page with materials tab selected (index 2)
        AppNavigation.goCourseDetails(context, _selectedCourseId!, tabIndex: 2);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Materials'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppNavigation.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal =
              constraints.maxWidth >= 900
                  ? 48.0
                  : constraints.maxWidth >= 600
                  ? 32.0
                  : 16.0;
          return Padding(
            padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select course',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: cs.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                _CourseDropdown(
                  selectedCourseId: _selectedCourseId,
                  onChanged: (id) => setState(() => _selectedCourseId = id),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.file_open),
                      label: const Text('Pick files'),
                    ),
                    const SizedBox(width: 12),
                    if (_selectedFiles.isNotEmpty)
                      Text(
                        '${_selectedFiles.length} selected',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                      _selectedFiles.isEmpty
                          ? Center(
                            child: Text(
                              'No files selected',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                            ),
                          )
                          : ListView.separated(
                            itemCount: _selectedFiles.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final f = _selectedFiles[index];
                              final status = _statusByName[f.name];
                              final progress = _progressByName[f.name];
                              return _FileTile(
                                file: f,
                                status: status,
                                progress: progress,
                                onRemove: () => _removeFile(f),
                              );
                            },
                          ),
                ),
                const SizedBox(height: 8),
                SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isUploading ||
                                  _selectedCourseId == null ||
                                  _selectedFiles.isEmpty
                              ? null
                              : _uploadAll,
                      child:
                          _isUploading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Save Materials'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CourseDropdown extends StatelessWidget {
  final String? selectedCourseId;
  final ValueChanged<String?> onChanged;
  const _CourseDropdown({
    required this.selectedCourseId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseProvider>().courses;
    return DropdownButtonFormField<String>(
      value: selectedCourseId,
      items:
          courses
              .map(
                (c) =>
                    DropdownMenuItem<String>(value: c.id, child: Text(c.name)),
              )
              .toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Choose a course',
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  final PlatformFile file;
  final String? status;
  final double? progress;
  final VoidCallback onRemove;
  const _FileTile({
    required this.file,
    required this.status,
    this.progress,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: AppTextStyles.bodyLarge.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  _readableSize(file.size),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: cs.onSurface.withOpacity(0.7),
                  ),
                ),
                if (status != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    status!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          status == 'Saved'
                              ? Colors.green
                              : status == 'Failed'
                              ? Colors.red
                              : cs.primary,
                    ),
                  ),
                ],
                if (progress != null && progress! > 0 && progress! < 1) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                ],
              ],
            ),
          ),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  String _readableSize(int bytes) {
    const kb = 1024;
    const mb = kb * 1024;
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(2)} MB';
    if (bytes >= kb) return '${(bytes / kb).toStringAsFixed(1)} KB';
    return '$bytes B';
  }
}
