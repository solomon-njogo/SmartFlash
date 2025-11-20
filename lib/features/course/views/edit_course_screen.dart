import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/providers/course_provider.dart';
import '../../../data/models/course_model.dart';

class EditCourseScreen extends StatefulWidget {
  const EditCourseScreen({super.key, required this.courseId});

  final String courseId;

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _attemptedSubmit = false;
  bool _isInitializing = true;
  bool _courseNotFound = false;
  CourseModel? _course;

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCourse());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCourse() async {
    final courseProvider = context.read<CourseProvider>();
    final existingCourse = courseProvider.getCourseById(widget.courseId);
    if (existingCourse != null) {
      _applyCourse(existingCourse);
      return;
    }

    setState(() {
      _isInitializing = true;
    });

    await courseProvider.refreshCourses();
    if (!mounted) return;

    final refreshedCourse = courseProvider.getCourseById(widget.courseId);
    if (refreshedCourse != null) {
      _applyCourse(refreshedCourse);
    } else {
      setState(() {
        _courseNotFound = true;
        _isInitializing = false;
      });
    }
  }

  void _applyCourse(CourseModel course) {
    _course = course;
    _nameController.text = course.name;
    _descriptionController.text = course.description ?? '';
    setState(() {
      _isInitializing = false;
      _courseNotFound = false;
    });
  }

  Future<void> _onSubmit() async {
    setState(() {
      _attemptedSubmit = true;
    });

    if (_course == null || !_isNameValid) return;

    final courseProvider = context.read<CourseProvider>();
    final updatedCourse = _course!.copyWith(
      name: _nameController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final success = await courseProvider.updateCourse(updatedCourse);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course updated successfully')),
      );
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      AppNavigation.pushReplacement(
        context,
        '/course-details/${updatedCourse.id}',
      );
    } else if (courseProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(courseProvider.error!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update course')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    if (_course == null) return;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Delete course?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will permanently remove the course, including all associated decks, quizzes, and materials.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final courseProvider = context.read<CourseProvider>();
    final success = await courseProvider.deleteCourse(_course!.id);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${_course!.name}" has been deleted'),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      AppNavigation.goHome(context);
    } else if (courseProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(courseProvider.error!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete course')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading = courseProvider.isLoading;

    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Course')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_courseNotFound || _course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Course')),
        body: const Center(child: Text('Course not found')),
      );
    }

    final bool canSubmit = _isNameValid && !isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Course')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth >= 600;
            final double horizontalPadding =
                wide ? (constraints.maxWidth - 560) / 2 : 16;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Course',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Update the details to keep this course organized.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Name',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'e.g., Biology 101',
                      errorText:
                          _attemptedSubmit && !_isNameValid
                              ? 'Name is required'
                              : null,
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description (optional)',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Add a short description',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 3,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: canSubmit ? _onSubmit : null,
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                              : const Text('Save Changes'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                      onPressed: isLoading ? null : _confirmDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete course'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

