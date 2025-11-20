import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/models/deck_model.dart' as data_models;
import '../../../core/providers/course_provider.dart';
import '../../../core/providers/deck_provider.dart';
import '../../../core/providers/course_material_provider.dart';
import '../../../core/providers/quiz_provider.dart';
import '../../../app/app_text_styles.dart';
import '../../../data/models/course_material_model.dart';
import '../../../app/widgets/course_material_card.dart';
import '../../../app/router.dart';

/// Course details screen with tabs for Decks, Quizzes, and Materials
class CourseDetailsScreen extends StatefulWidget {
  final String courseId;
  final int? initialTabIndex;

  const CourseDetailsScreen({
    super.key,
    required this.courseId,
    this.initialTabIndex,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with WidgetsBindingObserver {
  late int _currentIndex;
  CourseModel? _course;
  bool _isHeaderExpanded = true;
  bool _materialsLoaded = false;
  bool _hasRefreshedOnResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.initialTabIndex ?? 0;
    _loadCourse();
    // Schedule the course access marking for after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markCourseAsAccessed();
      // Ensure materials are loaded for the course to show accurate counts
      final materialProvider = Provider.of<CourseMaterialProvider>(
        context,
        listen: false,
      );
      // Only load if materials haven't been loaded for this course yet
      final courseMaterials = materialProvider.getMaterialsByCourseId(
        widget.courseId,
      );
      if (courseMaterials.isEmpty && !materialProvider.isLoading) {
        materialProvider.loadMaterialsForCourse(widget.courseId);
      }

      // Refresh decks to ensure we have the latest data
      final deckProvider = Provider.of<DeckProvider>(context, listen: false);
      deckProvider.refreshDecks();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh decks when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final deckProvider = Provider.of<DeckProvider>(
            context,
            listen: false,
          );
          deckProvider.refreshDecks();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh decks when screen becomes visible again (e.g., when navigating back)
    // Use a flag to avoid refreshing multiple times in the same frame
    if (!_hasRefreshedOnResume) {
      _hasRefreshedOnResume = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _hasRefreshedOnResume = false;
        if (mounted) {
          final deckProvider = Provider.of<DeckProvider>(
            context,
            listen: false,
          );
          // Only refresh if we have a course loaded
          if (_course != null) {
            deckProvider.refreshDecks();
          }
        }
      });
    }
  }

  @override
  void didUpdateWidget(CourseDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh decks when widget is updated (e.g., when navigating back)
    if (oldWidget.courseId != widget.courseId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final deckProvider = Provider.of<DeckProvider>(
            context,
            listen: false,
          );
          deckProvider.refreshDecks();
        }
      });
    }
  }

  void _loadCourse() {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    _course = courseProvider.getCourseById(widget.courseId);
  }

  void _markCourseAsAccessed() {
    if (_course != null) {
      final courseProvider = Provider.of<CourseProvider>(
        context,
        listen: false,
      );
      courseProvider.markCourseAsAccessed(widget.courseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_course == null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(title: const Text('Course Not Found')),
        body: const Center(child: Text('Course not found')),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: Text(
          _course!.name,
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                _course == null
                    ? null
                    : () => AppNavigation.goEditCourse(context, _course!.id),
            icon: Icon(Icons.edit, color: colorScheme.onSurface),
          ),
        ],
      ),
      body: Column(
        children: [
          // Course header
          _buildCourseHeader(context),
          // Tab content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildDecksTab(context),
                _buildQuizzesTab(context),
                _buildMaterialsTab(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Decks',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quizzes'),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_file),
            label: 'Materials',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context, colorScheme),
    );
  }

  Widget _buildCourseHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          // Always visible header with course icon, name, and collapse button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _course!.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIconData(_course!.iconName ?? 'folder'),
                    color: _course!.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _course!.name,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_course!.description != null &&
                          _isHeaderExpanded) ...[
                        const SizedBox(height: 4),
                        Text(
                          _course!.description!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isHeaderExpanded = !_isHeaderExpanded;
                    });
                  },
                  icon: AnimatedRotation(
                    turns: _isHeaderExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Collapsible content
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child:
                _isHeaderExpanded
                    ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description (if not shown above)
                          if (_course!.description != null) ...[
                            Text(
                              _course!.description!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          // Statistics
                          Consumer2<CourseMaterialProvider, DeckProvider>(
                            builder: (
                              context,
                              materialProvider,
                              deckProvider,
                              child,
                            ) {
                              final materialCount = materialProvider
                                  .getMaterialCountByCourseId(_course!.id);
                              // Access decks to ensure Consumer2 rebuilds when decks change
                              final courseDecks = deckProvider
                                  .getDecksByCourseId(_course!.id);
                              final deckCount = courseDecks.length;
                              return Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  _buildStatChip(
                                    context,
                                    Icons.library_books,
                                    '$deckCount',
                                    'Decks',
                                  ),
                                  Consumer<QuizProvider>(
                                    builder: (context, quizProvider, child) {
                                      final quizCount = quizProvider
                                          .getQuizCountByCourseId(_course!.id);
                                      return _buildStatChip(
                                        context,
                                        Icons.quiz,
                                        '$quizCount',
                                        'Quizzes',
                                      );
                                    },
                                  ),
                                  _buildStatChip(
                                    context,
                                    Icons.attach_file,
                                    '$materialCount',
                                    'Materials',
                                  ),
                                ],
                              );
                            },
                          ),
                          // Tags
                          if (_course!.tags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  _course!.tags.map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _course!.color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        tag,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: _course!.color,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String count,
    String label,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 14 : 16,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: isSmallScreen ? 4 : 6),
          Text(
            count,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 12 : null,
            ),
          ),
          SizedBox(width: isSmallScreen ? 2 : 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: isSmallScreen ? 10 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfoChip(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecksTab(BuildContext context) {
    return Consumer<DeckProvider>(
      builder: (context, deckProvider, child) {
        // First check local cache
        final cachedDecks = deckProvider.getDecksByCourseId(widget.courseId);

        // Use FutureBuilder with a key that changes when provider updates
        // This ensures it rebuilds when decks are refreshed
        return FutureBuilder<List<data_models.DeckModel>>(
          key: ValueKey(
            'decks_${widget.courseId}_${deckProvider.decks.length}',
          ),
          future:
              cachedDecks.isNotEmpty
                  ? Future.value(cachedDecks)
                  : deckProvider.getDecksByCourseIdAsync(widget.courseId),
          builder: (context, snapshot) {
            // Show cached data immediately if available
            final courseDecks =
                snapshot.hasData
                    ? snapshot.data!
                    : (snapshot.connectionState == ConnectionState.waiting &&
                            cachedDecks.isNotEmpty
                        ? cachedDecks
                        : []);

            if (snapshot.connectionState == ConnectionState.waiting &&
                courseDecks.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Also check cache again in case it was updated
            final finalDecks =
                cachedDecks.isNotEmpty ? cachedDecks : courseDecks;

            if (finalDecks.isEmpty) {
              return _buildEmptyState(
                context,
                Icons.library_books,
                'No Decks',
                'This course doesn\'t have any decks yet.',
                'Create Deck',
                () {
                  AppNavigation.goAIGeneration(
                    context,
                    courseId: widget.courseId,
                  );
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await deckProvider.refreshDecks();
                // Force rebuild by using setState or the key will handle it
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: finalDecks.length,
                itemBuilder: (context, index) {
                  final deck = finalDecks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: _course!.color.withOpacity(0.1),
                        child: Icon(Icons.library_books, color: _course!.color),
                      ),
                      title: Text(
                        deck.name,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        deck.description ?? '',
                        style: AppTextStyles.cardSubtitle.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'study':
                              AppNavigation.goFlashcardReview(
                                context,
                                deckId: deck.id,
                              );
                              break;
                            case 'edit':
                              // TODO: Navigate to edit deck
                              break;
                            case 'delete':
                              _showDeleteDeckDialog(
                                context,
                                deckProvider,
                                deck,
                              );
                              break;
                          }
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'study',
                                child: Row(
                                  children: [
                                    Icon(Icons.play_arrow),
                                    SizedBox(width: 8),
                                    Text('Study'),
                                  ],
                                ),
                              ),
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
                      onTap: () {
                        AppNavigation.goFlashcardReview(
                          context,
                          deckId: deck.id,
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuizzesTab(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        // Use FutureBuilder to handle async fallback
        return FutureBuilder<List<QuizModel>>(
          future: quizProvider.getQuizzesByCourseIdAsync(widget.courseId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final courseQuizzes = snapshot.data ?? [];

            if (courseQuizzes.isEmpty) {
              return _buildEmptyState(
                context,
                Icons.quiz,
                'No Quizzes',
                'This course doesn\'t have any quizzes yet.',
                'Create Quiz',
                () {
                  AppNavigation.goAIGeneration(context, courseId: widget.courseId);
                },
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courseQuizzes.length,
              itemBuilder: (context, index) {
                final quiz = courseQuizzes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _course!.color.withOpacity(0.1),
                      child: Icon(Icons.quiz, color: _course!.color),
                    ),
                    title: Text(
                      quiz.name,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (quiz.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            quiz.description!,
                            style: AppTextStyles.cardSubtitle.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _buildQuizInfoChip(
                              context,
                              Icons.question_answer,
                              '${quiz.questionIds.length} Questions',
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'start':
                            quizProvider.startQuiz(quiz.id);
                            // TODO: Navigate to quiz screen
                            break;
                          case 'edit':
                            // TODO: Navigate to edit quiz
                            break;
                          case 'delete':
                            _showDeleteQuizDialog(context, quizProvider, quiz);
                            break;
                        }
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'start',
                              child: Row(
                                children: [
                                  Icon(Icons.play_arrow),
                                  SizedBox(width: 8),
                                  Text('Start Quiz'),
                                ],
                              ),
                            ),
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
                    onTap: () {
                      AppNavigation.goQuizTaking(context, quiz.id);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMaterialsTab(BuildContext context) {
    return Consumer<CourseMaterialProvider>(
      builder: (context, materialProvider, child) {
        // Load materials when tab is first shown (only once)
        if (!_materialsLoaded && !materialProvider.isLoading) {
          _materialsLoaded = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            materialProvider.loadMaterialsForCourse(widget.courseId);
          });
        }

        if (materialProvider.isLoading && materialProvider.materials.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final courseMaterials = materialProvider.getMaterialsByCourseId(
          widget.courseId,
        );

        if (courseMaterials.isEmpty) {
          return _buildEmptyState(
            context,
            Icons.attach_file,
            'No Materials',
            'This course doesn\'t have any materials yet.',
            'Upload Material',
            () {
              AppNavigation.goUploadMaterials(
                context,
                courseId: widget.courseId,
              );
            },
          );
        }

        return RefreshIndicator(
          onRefresh:
              () => materialProvider.loadMaterialsForCourse(widget.courseId),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courseMaterials.length,
            itemBuilder: (context, index) {
              final material = courseMaterials[index];
              return CourseMaterialCard(
                material: material,
                onTap: () {
                  AppNavigation.goMaterialPreview(context, material.id);
                },
                onDownload: () async {
                  materialProvider.markMaterialAsAccessed(material.id);
                  final filePath = await materialProvider.downloadMaterial(
                    material.id,
                  );
                  if (filePath != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Material downloaded successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          materialProvider.error ??
                              'Failed to download material',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                onDelete: () {
                  _showDeleteMaterialDialog(
                    context,
                    materialProvider,
                    material,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String actionText,
    VoidCallback onAction,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDeckDialog(
    BuildContext context,
    DeckProvider deckProvider,
    data_models.DeckModel deck,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Deck'),
            content: Text('Are you sure you want to delete "${deck.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final success = await deckProvider.deleteDeck(deck.id);
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Deck deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            deckProvider.error ?? 'Failed to delete deck',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showDeleteMaterialDialog(
    BuildContext context,
    CourseMaterialProvider materialProvider,
    CourseMaterialModel material,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Material'),
            content: Text(
              'Are you sure you want to delete "${material.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final success = await materialProvider.deleteMaterial(
                    material.id,
                  );
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Deleted ${material.name}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            materialProvider.error ??
                                'Failed to delete material',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showDeleteQuizDialog(
    BuildContext context,
    QuizProvider quizProvider,
    quiz,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Quiz'),
            content: Text('Are you sure you want to delete "${quiz.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  quizProvider.deleteQuiz(quiz.id);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    switch (_currentIndex) {
      case 0: // Decks tab
        return FloatingActionButton.extended(
          onPressed: () {
            AppNavigation.goAIGeneration(context, courseId: widget.courseId);
          },
          icon: const Icon(Icons.add),
          label: const Text('Create Deck'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        );
      case 1: // Quizzes tab
        return FloatingActionButton.extended(
          onPressed: () {
            AppNavigation.goAIGeneration(context, courseId: widget.courseId);
          },
          icon: const Icon(Icons.add),
          label: const Text('Create Quiz'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        );
      case 2: // Materials tab
        return FloatingActionButton.extended(
          onPressed: () {
            AppNavigation.goUploadMaterials(context, courseId: widget.courseId);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Materials'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        );
      default:
        return null;
    }
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
