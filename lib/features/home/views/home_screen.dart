import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/course_provider.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_name.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/widgets/app_logo.dart';
import '../../../app/widgets/course_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Consumer2<AuthProvider, CourseProvider>(
          builder: (context, authProvider, courseProvider, child) {
            return Stack(
              children: [
                // Main content behind
                Column(
                  children: [
                    _buildHeader(context),
                    Expanded(child: _buildMainContent(context, courseProvider)),
                  ],
                ),
                // Floating create button overlay
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 32,
                  child: _buildCreateButton(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the header with app name and user avatar
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App name with logo
          Row(
            children: [
              // App logo
              AppLogo(
                size: 32,
                borderRadius: 8,
                backgroundColor: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const AppName(variant: AppNameVariant.header),
            ],
          ),
          // User avatar
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;
              final photoUrl = user?.userMetadata?['avatar_url'] as String?;
              final userInitial =
                  user?.email?.isNotEmpty == true
                      ? user!.email![0].toUpperCase()
                      : 'U';

              return GestureDetector(
                onTap: () => AppNavigation.goProfile(context),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.primary,
                  backgroundImage:
                      photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                  child:
                      (photoUrl == null || photoUrl.isEmpty)
                          ? Text(
                            userInitial,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                          : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the main content area
  Widget _buildMainContent(
    BuildContext context,
    CourseProvider courseProvider,
  ) {
    if (courseProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (courseProvider.error != null) {
      return _buildErrorState(context, courseProvider);
    }

    return courseProvider.courses.isEmpty
        ? _buildEmptyState(context)
        : _buildCoursesList(context, courseProvider);
  }

  /// Builds the error state
  Widget _buildErrorState(BuildContext context, CourseProvider courseProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error loading courses',
            style: AppTextStyles.headlineSmall.copyWith(
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            courseProvider.error!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => courseProvider.refreshCourses(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large app logo
          AppLogo(
            size: 120,
            borderRadius: 20,
            backgroundColor: colorScheme.primary,
          ),
          const SizedBox(height: 32),
          // Main heading
          Text(
            "Let's get started",
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          // Sub text
          Text(
            'Create your first course below.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: colorScheme.onBackground.withOpacity(0.87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(
    BuildContext context,
    CourseProvider courseProvider,
  ) {
    return RefreshIndicator(
      onRefresh: () => courseProvider.refreshCourses(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: courseProvider.courses.length,
        itemBuilder: (context, index) {
          final course = courseProvider.courses[index];
          return CourseCard(
            course: course,
            onTap: () => AppNavigation.goCourseDetails(context, course.id),
            onEdit: () => AppNavigation.goEditCourse(context, course.id),
            onDelete:
                () => _showDeleteCourseDialog(context, courseProvider, course),
          );
        },
      ),
    );
  }

  void _showDeleteCourseDialog(
    BuildContext context,
    CourseProvider courseProvider,
    course,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Course'),
            content: Text('Are you sure you want to delete "${course.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  courseProvider.deleteCourse(course.id);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  /// Shows the create new bottom sheet
  void _showCreateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateBottomSheet(),
    );
  }

  /// Builds the create new button matching the inspiration design
  /// Appears visually floating (pill over content) with no Scaffold background
  Widget _buildCreateButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.onBackground,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x20000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => _showCreateBottomSheet(context),
          child: const SizedBox(
            height: 56,
            child: Center(child: _CreateButtonContent()),
          ),
        ),
      ),
    );
  }
}

class _CreateButtonContent extends StatelessWidget {
  const _CreateButtonContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '+',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w500,
            color: cs.background,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Create New',
          style: AppTextStyles.button.copyWith(color: cs.background),
        ),
      ],
    );
  }
}

class _CreateBottomSheet extends StatelessWidget {
  const _CreateBottomSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Create New',
              style: AppTextStyles.headlineSmall.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you\'d like to create your course',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Options
            _buildOption(
              context,
              icon: Icons.folder,
              title: 'Create Course',
              subtitle: 'Create a new course to organize your content',
              onTap: () {
                Navigator.pop(context);
                AppNavigation.goCreateCourse(context);
              },
            ),
            const SizedBox(height: 16),
            _buildOption(
              context,
              icon: Icons.upload_file,
              title: 'Upload Materials',
              subtitle: 'Upload documents and files to a course',
              onTap: () {
                Navigator.pop(context);
                AppNavigation.goUploadMaterials(context);
              },
            ),
            const SizedBox(height: 16),
            _buildOption(
              context,
              icon: Icons.library_books,
              title: 'Create Deck',
              subtitle: 'Create flashcards for studying',
              onTap: () {
                Navigator.pop(context);
                AppNavigation.goCreateDeck(context);
              },
            ),
            const SizedBox(height: 16),
            _buildOption(
              context,
              icon: Icons.quiz,
              title: 'Create Quiz',
              subtitle: 'Create quizzes to test knowledge',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to create quiz
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
