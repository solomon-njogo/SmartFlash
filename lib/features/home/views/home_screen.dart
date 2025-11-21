import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/course_provider.dart';
import '../../../core/providers/course_material_provider.dart';
import '../../../core/providers/deck_provider.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_name.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/widgets/app_logo.dart';
import '../../../app/widgets/course_card.dart';
import '../../../app/widgets/upcoming_reviews_section.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart' as custom_error;

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
          // Search and user avatar
          Row(
            children: [
              // Search button (Enhanced with haptic feedback)
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  AppNavigation.goSearch(context);
                },
                tooltip: 'Search',
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48), // Better touch target
                ),
              ),
              const SizedBox(width: 8),
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
        ],
      ),
    );
  }

  /// Builds the main content area
  Widget _buildMainContent(
    BuildContext context,
    CourseProvider courseProvider,
  ) {
    if (courseProvider.isLoading && courseProvider.courses.isEmpty) {
      // Show skeleton loading when loading for the first time
      return ListSkeletonLoading(
        itemCount: 3,
        itemBuilder: (context, index) => const CourseCardSkeleton(),
      );
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
    return Center(
      child: custom_error.ErrorWidget(
        title: 'Error loading courses',
        message: courseProvider.error ?? 'Something went wrong',
        icon: Icons.error_outline,
        onRetry: () {
          HapticFeedback.mediumImpact();
          courseProvider.refreshCourses();
        },
        retryText: 'Retry',
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: custom_error.EmptyStateWidget(
        title: "Let's get started",
        message: 'Create your first course to organize your study materials and start learning.',
        icon: Icons.folder_outlined,
        iconColor: colorScheme.primary,
        onAction: () {
          HapticFeedback.mediumImpact();
          AppNavigation.goCreateCourse(context);
        },
        actionText: 'Create Course',
      ),
    );
  }

  Widget _buildCoursesList(
    BuildContext context,
    CourseProvider courseProvider,
  ) {
    final materialProvider = Provider.of<CourseMaterialProvider>(context, listen: false);
    final deckProvider = Provider.of<DeckProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await Future.wait([
          courseProvider.refreshCourses(),
          materialProvider.refreshMaterials(),
          deckProvider.refreshDecks(),
        ]);
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Upcoming reviews section
          if (userId != null)
            UpcomingReviewsSection(
              key: ValueKey('upcoming_reviews_$userId'),
              userId: userId,
            ),
          // Courses list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
          // Bottom padding for floating button
          const SizedBox(height: 100),
        ],
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

  /// Builds the create course button matching the inspiration design
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
          onTap: () {
            HapticFeedback.mediumImpact();
            AppNavigation.goCreateCourse(context);
          },
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
          'Create Course',
          style: AppTextStyles.button.copyWith(color: cs.background),
        ),
      ],
    );
  }
}

