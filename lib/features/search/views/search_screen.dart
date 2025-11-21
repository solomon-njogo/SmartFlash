import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/providers/course_provider.dart';
import '../../../core/providers/deck_provider.dart';
import '../../../core/providers/flashcard_provider.dart';
import '../../../core/providers/quiz_provider.dart';
import '../widgets/search_result_item.dart';
import '../widgets/recent_search_item.dart';
import '../widgets/search_filter_sheet.dart';

/// Search screen for searching across courses, decks, and flashcards
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Auto-focus search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final searchProvider = context.read<SearchProvider>();
    searchProvider.setQuery(_searchController.text);
    _performSearch();
  }

  void _performSearch() {
    final searchProvider = context.read<SearchProvider>();
    final courseProvider = context.read<CourseProvider>();
    final deckProvider = context.read<DeckProvider>();
    final quizProvider = context.read<QuizProvider>();
    final flashcardProvider = context.read<FlashcardProvider>();

    searchProvider.performSearch(
      courses: courseProvider.courses,
      decks: deckProvider.decks,
      quizzes: quizProvider.quizzes,
      flashcards: flashcardProvider.flashcards,
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          return SearchFilterSheet(searchProvider: searchProvider);
        },
      ),
    ).then((_) {
      // Re-perform search after filter/sort changes
      _performSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          Consumer<SearchProvider>(
            builder: (context, searchProvider, child) {
              if (searchProvider.isSearchActive) {
                return IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: _showFilterSheet,
                  tooltip: 'Filter & Sort',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search input
          _buildSearchInput(context, colorScheme),
          // Results or recent searches
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                if (searchProvider.isSearchActive) {
                  return _buildSearchResults(context, searchProvider);
                } else {
                  return _buildRecentSearches(context, searchProvider);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search courses, decks, quizzes, flashcards...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchProvider>().clearSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceVariant,
        ),
        style: AppTextStyles.bodyLarge,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    SearchProvider searchProvider,
  ) {
    if (!searchProvider.hasResults) {
      return _buildEmptyResults(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        final courseProvider = context.read<CourseProvider>();
        final deckProvider = context.read<DeckProvider>();
        final quizProvider = context.read<QuizProvider>();
        final flashcardProvider = context.read<FlashcardProvider>();

        await Future.wait([
          courseProvider.refreshCourses(),
          deckProvider.refreshDecks(),
          quizProvider.refreshQuizzes(),
          flashcardProvider.refreshFlashcards(),
        ]);

        _performSearch();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Course results
          if (searchProvider.courseResults.isNotEmpty) ...[
            _buildSectionHeader(context, 'Courses', searchProvider.courseResults.length),
            ...searchProvider.courseResults.map((course) {
              return SearchResultItem(
                item: course,
                onTap: () {
                  AppNavigation.goCourseDetails(context, course.id);
                },
              );
            }),
          ],
          // Deck results
          if (searchProvider.deckResults.isNotEmpty) ...[
            _buildSectionHeader(context, 'Decks', searchProvider.deckResults.length),
            ...searchProvider.deckResults.map((deck) {
              return SearchResultItem(
                item: deck,
                onTap: () {
                  AppNavigation.push(
                    context,
                    '/flashcard-review?deckId=${deck.id}',
                  );
                },
              );
            }),
          ],
          // Quiz results
          if (searchProvider.quizResults.isNotEmpty) ...[
            _buildSectionHeader(context, 'Quizzes', searchProvider.quizResults.length),
            ...searchProvider.quizResults.map((quiz) {
              return SearchResultItem(
                item: quiz,
                onTap: () {
                  AppNavigation.goQuizTaking(context, quiz.id);
                },
              );
            }),
          ],
          // Flashcard results
          if (searchProvider.flashcardResults.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              'Flashcards',
              searchProvider.flashcardResults.length,
            ),
            ...searchProvider.flashcardResults.map((flashcard) {
              return SearchResultItem(
                item: flashcard,
                onTap: () {
                  AppNavigation.push(
                    context,
                    '/flashcard-review?deckId=${flashcard.deckId}&flashcardId=${flashcard.id}',
                  );
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: AppTextStyles.headlineSmall.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(
    BuildContext context,
    SearchProvider searchProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (searchProvider.recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Start searching',
              style: AppTextStyles.headlineSmall.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search across your courses, decks, and flashcards',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: AppTextStyles.titleLarge.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                searchProvider.clearRecentSearches();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          children: searchProvider.recentSearches.map((search) {
            return RecentSearchItem(
              search: search,
              onTap: () {
                _searchController.text = search;
                searchProvider.useRecentSearch(search);
                _performSearch();
              },
              onDelete: () {
                searchProvider.removeRecentSearch(search);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

