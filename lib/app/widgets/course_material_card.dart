import 'package:flutter/material.dart';
import '../../data/models/course_material_model.dart';
import '../../app/app_text_styles.dart';

/// Course material card widget for displaying course materials
class CourseMaterialCard extends StatelessWidget {
  final CourseMaterialModel material;
  final VoidCallback? onDelete;

  const CourseMaterialCard({
    super.key,
    required this.material,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
            children: [
              // File type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getFileTypeColor(material.fileType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFileTypeIcon(material.fileType),
                  color: _getFileTypeColor(material.fileType),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Material info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.name,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (material.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        material.description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          material.fileTypeString,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          material.fileSizeFormatted,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                        if (material.downloadCount > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${material.downloadCount} downloads',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              if (onDelete != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
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
