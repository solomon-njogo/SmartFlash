import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/course_model.dart';
import '../../app/app_text_styles.dart';
import '../../core/providers/course_material_provider.dart';
import '../../core/providers/quiz_provider.dart';

/// Course card widget for displaying courses on home screen
class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and menu
              Row(
                children: [
                  // Course icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: course.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(course.iconName ?? 'folder'),
                      color: course.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Course info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (course.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            course.description!,
                            style: AppTextStyles.cardSubtitle.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Menu button
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Statistics
              Row(
                children: [
                  _buildStatItem(
                    context,
                    Icons.library_books,
                    '${course.totalDecks}',
                    'Decks',
                    colorScheme,
                  ),
                  const SizedBox(width: 16),
                  Consumer<QuizProvider>(
                    builder: (context, quizProvider, child) {
                      final quizCount = quizProvider.getQuizCountByCourseId(course.id);
                      return _buildStatItem(
                        context,
                        Icons.quiz,
                        '$quizCount',
                        'Quizzes',
                        colorScheme,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Consumer<CourseMaterialProvider>(
                    builder: (context, materialProvider, child) {
                      final materialCount = materialProvider.getMaterialCountByCourseId(course.id);
                      return _buildStatItem(
                        context,
                        Icons.attach_file,
                        '$materialCount',
                        'Materials',
                        colorScheme,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tags and last accessed
              Row(
                children: [
                  // Tags
                  if (course.tags.isNotEmpty) ...[
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children:
                            course.tags.take(3).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: course.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: course.color,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Last accessed indicator
                  if (course.isRecentlyAccessed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Recent',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.primary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String count,
    String label,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          count,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'laptop':
        return Icons.laptop;
      case 'biotech':
        return Icons.biotech;
      case 'public':
        return Icons.public;
      case 'calculate':
        return Icons.calculate;
      case 'translate':
        return Icons.translate;
      case 'folder':
      default:
        return Icons.folder;
    }
  }
}
