import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/providers/course_provider.dart';
import '../../../data/models/course_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _attemptedSubmit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

  Future<void> _onSubmit() async {
    setState(() {
      _attemptedSubmit = true;
    });

    if (!_isNameValid) {
      return;
    }

    final courseProvider = context.read<CourseProvider>();
    final now = DateTime.now();
    final String newId = 'course_${now.millisecondsSinceEpoch}';

    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id ?? 'unknown';
    final newCourse = CourseModel(
      id: newId,
      name: _nameController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      createdBy: currentUserId,
      createdAt: now,
      updatedAt: now,
    );

    final success = await courseProvider.createCourse(newCourse);

    if (!mounted) return;

    if (success) {
      AppNavigation.goCourseDetails(context, newId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(courseProvider.error ?? 'Failed to create course'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading = context.watch<CourseProvider>().isLoading;

    final bool canSubmit = _isNameValid && !isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Course')),
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
                    'New Course',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a course to organize your decks, quizzes, and materials.',
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Create Course'),
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
