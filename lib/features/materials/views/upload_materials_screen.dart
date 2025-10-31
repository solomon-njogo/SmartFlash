import 'package:file_picker/file_picker.dart' hide FileType;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.preselectedCourseId;
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    final files = result?.files ?? [];
    if (!mounted) return;
    setState(() {
      _selectedFiles
        ..clear()
        ..addAll(files);
      _statusByName.clear();
    });
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

    for (final f in List<PlatformFile>.from(_selectedFiles)) {
      setState(() => _statusByName[f.name] = 'Saving...');
      final now = DateTime.now();
      final id =
          '${_selectedCourseId}_mat_${now.millisecondsSinceEpoch}_${f.name.hashCode}';
      final model = CourseMaterialModel(
        id: id,
        courseId: _selectedCourseId!,
        name: f.name,
        fileType: _mapExtensionToFileType(f.extension),
        fileSizeBytes: f.size,
        filePath: f.path,
        uploadedBy: 'user1',
        uploadedAt: now,
        updatedAt: now,
      );

      final ok = await materials.createMaterial(model);
      if (!mounted) return;
      setState(() => _statusByName[f.name] = ok ? 'Saved' : 'Failed');
      if (ok) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Saved ${f.name}')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save ${f.name}')));
      }
    }

    setState(() => _isUploading = false);
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
                              return _FileTile(
                                file: f,
                                status: status,
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
  final VoidCallback onRemove;
  const _FileTile({
    required this.file,
    required this.status,
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
