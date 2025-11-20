import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/providers/course_material_provider.dart';
import '../../../data/models/course_material_model.dart';

class MaterialPreviewScreen extends StatefulWidget {
  final String materialId;
  const MaterialPreviewScreen({super.key, required this.materialId});

  @override
  State<MaterialPreviewScreen> createState() => _MaterialPreviewScreenState();
}

class _MaterialPreviewScreenState extends State<MaterialPreviewScreen> {
  bool _isDownloading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final materialProvider = context.watch<CourseMaterialProvider>();
    final material = materialProvider.getMaterialById(widget.materialId);
    final cs = Theme.of(context).colorScheme;

    if (material == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Material Not Found'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => AppNavigation.pop(context),
          ),
        ),
        body: Center(
          child: Text(
            'Material not found',
            style: AppTextStyles.bodyLarge.copyWith(color: cs.onSurface),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(material.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppNavigation.pop(context),
        ),
        actions: [
          if (material.fileUrl != null)
            IconButton(
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      material.isDownloaded
                          ? Icons.check_circle
                          : Icons.download,
                    ),
              onPressed: _isDownloading ? null : () => _downloadMaterial(material),
              tooltip: material.isDownloaded ? 'Downloaded' : 'Download',
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth >= 900
              ? 48.0
              : constraints.maxWidth >= 600
                  ? 32.0
                  : 16.0;
          return Padding(
            padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Material info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getFileTypeIcon(material.fileType),
                              color: _getFileTypeColor(material.fileType),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    material.name,
                                    style: AppTextStyles.titleLarge.copyWith(
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  if (material.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      material.description!,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _InfoChip(
                              icon: Icons.description,
                              label: material.fileTypeString,
                            ),
                            _InfoChip(
                              icon: Icons.storage,
                              label: material.fileSizeFormatted,
                            ),
                            if (material.downloadCount > 0)
                              _InfoChip(
                                icon: Icons.download,
                                label: '${material.downloadCount} downloads',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Preview/Open button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openMaterial(material),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(
                      material.isDownloaded
                          ? 'Open File'
                          : material.fileType == FileType.pdf ||
                                  material.fileType == FileType.doc ||
                                  material.fileType == FileType.docx
                          ? 'Preview Material'
                          : 'Open Material',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: cs.onErrorContainer),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: cs.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                // Note about preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: cs.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          material.fileType == FileType.pdf ||
                                  material.fileType == FileType.doc ||
                                  material.fileType == FileType.docx
                              ? 'PDFs and Word documents will open in your default viewer. Download the file to view offline.'
                              : 'This file will open in an external app.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadMaterial(CourseMaterialModel material) async {
    if (material.isDownloaded && material.filePath != null) {
      // Already downloaded, just open it
      await _openMaterial(material);
      return;
    }

    setState(() {
      _isDownloading = true;
      _error = null;
    });

    try {
      final materialProvider = context.read<CourseMaterialProvider>();
      final filePath = await materialProvider.downloadMaterial(material.id);

      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Open the downloaded file
        await _openMaterial(material);
      } else if (mounted) {
        setState(() {
          _error = 'Failed to download material';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error downloading: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _openMaterial(CourseMaterialModel material) async {
    try {
      // If downloaded, open local file
      if (material.isDownloaded && material.filePath != null) {
        final file = File(material.filePath!);
        if (await file.exists()) {
          final result = await OpenFilex.open(material.filePath!);
          if (result.type != ResultType.done && mounted) {
            setState(() {
              _error = 'Could not open file: ${result.message}';
            });
          }
          return;
        }
      }

      // Otherwise, open remote URL
      if (material.fileUrl != null) {
        final uri = Uri.parse(material.fileUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else if (mounted) {
          setState(() {
            _error = 'Could not open URL';
          });
        }
      } else {
        setState(() {
          _error = 'No file URL available';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error opening file: $e';
        });
      }
    }
  }

  IconData _getFileTypeIcon(FileType fileType) {
    switch (fileType) {
      case FileType.pdf:
        return Icons.picture_as_pdf;
      case FileType.doc:
      case FileType.docx:
        return Icons.description;
      case FileType.ppt:
      case FileType.pptx:
        return Icons.slideshow;
      case FileType.image:
        return Icons.image;
      case FileType.audio:
        return Icons.audiotrack;
      case FileType.video:
        return Icons.videocam;
      case FileType.text:
        return Icons.text_snippet;
      case FileType.other:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileTypeColor(FileType fileType) {
    switch (fileType) {
      case FileType.pdf:
        return Colors.red;
      case FileType.doc:
      case FileType.docx:
        return Colors.blue;
      case FileType.ppt:
      case FileType.pptx:
        return Colors.orange;
      case FileType.image:
        return Colors.green;
      case FileType.audio:
        return Colors.purple;
      case FileType.video:
        return Colors.pink;
      case FileType.text:
        return Colors.grey;
      case FileType.other:
        return Colors.brown;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

