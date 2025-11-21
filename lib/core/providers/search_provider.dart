import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/course_model.dart';
import '../../data/models/deck_model.dart';
import '../../data/models/flashcard_model.dart';
import '../../data/models/quiz_model.dart';
import '../../core/constants/app_constants.dart';
import '../utils/logger.dart';

/// Search filter type
enum SearchFilterType {
  all,
  courses,
  decks,
  quizzes,
  flashcards,
}

/// Sort option for search results
enum SearchSortOption {
  relevance,
  dateNewest,
  dateOldest,
  nameAscending,
  nameDescending,
}

/// Search provider for managing search state and results
class SearchProvider extends ChangeNotifier {
  String _query = '';
  SearchFilterType _filterType = SearchFilterType.all;
  SearchSortOption _sortOption = SearchSortOption.relevance;
  List<String> _recentSearches = [];
  static const int _maxRecentSearches = 10;
  static const String _recentSearchesKey = 'recent_searches';

  // Search results
  List<CourseModel> _courseResults = [];
  List<DeckModel> _deckResults = [];
  List<QuizModel> _quizResults = [];
  List<FlashcardModel> _flashcardResults = [];

  /// Current search query
  String get query => _query;

  /// Current filter type
  SearchFilterType get filterType => _filterType;

  /// Current sort option
  SearchSortOption get sortOption => _sortOption;

  /// Recent searches list
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  /// Course search results
  List<CourseModel> get courseResults => List.unmodifiable(_courseResults);

  /// Deck search results
  List<DeckModel> get deckResults => List.unmodifiable(_deckResults);

  /// Quiz search results
  List<QuizModel> get quizResults => List.unmodifiable(_quizResults);

  /// Flashcard search results
  List<FlashcardModel> get flashcardResults =>
      List.unmodifiable(_flashcardResults);

  /// Total number of results
  int get totalResults =>
      _courseResults.length +
      _deckResults.length +
      _quizResults.length +
      _flashcardResults.length;

  /// Whether there are any results
  bool get hasResults => totalResults > 0;

  /// Whether search is active (query is not empty)
  bool get isSearchActive => _query.isNotEmpty;

  SearchProvider() {
    _loadRecentSearches();
  }

  /// Load recent searches from Hive
  Future<void> _loadRecentSearches() async {
    try {
      final box = await Hive.openBox(AppConstants.hiveBoxName);
      final saved = box.get(_recentSearchesKey);
      if (saved != null && saved is List) {
        _recentSearches = List<String>.from(saved);
        notifyListeners();
      }
    } catch (e) {
      Logger.error('Failed to load recent searches: $e');
    }
  }

  /// Save recent searches to Hive
  Future<void> _saveRecentSearches() async {
    try {
      final box = await Hive.openBox(AppConstants.hiveBoxName);
      await box.put(_recentSearchesKey, _recentSearches);
    } catch (e) {
      Logger.error('Failed to save recent searches: $e');
    }
  }

  /// Set search query
  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  /// Set filter type
  void setFilterType(SearchFilterType filterType) {
    _filterType = filterType;
    notifyListeners();
  }

  /// Set sort option
  void setSortOption(SearchSortOption sortOption) {
    _sortOption = sortOption;
    notifyListeners();
  }

  /// Perform search across all types
  void performSearch({
    required List<CourseModel> courses,
    required List<DeckModel> decks,
    required List<QuizModel> quizzes,
    required List<FlashcardModel> flashcards,
  }) {
    if (_query.isEmpty) {
      _courseResults = [];
      _deckResults = [];
      _quizResults = [];
      _flashcardResults = [];
      notifyListeners();
      return;
    }

    // Search courses
    if (_filterType == SearchFilterType.all ||
        _filterType == SearchFilterType.courses) {
      _courseResults = courses
          .where(
            (course) =>
                course.name.toLowerCase().contains(_query.toLowerCase()) ||
                (course.description
                        ?.toLowerCase()
                        .contains(_query.toLowerCase()) ??
                    false) ||
                course.tags.any(
                  (tag) => tag.toLowerCase().contains(_query.toLowerCase()),
                ),
          )
          .toList();
    } else {
      _courseResults = [];
    }

    // Search decks
    if (_filterType == SearchFilterType.all ||
        _filterType == SearchFilterType.decks) {
      _deckResults = decks
          .where(
            (deck) =>
                deck.name.toLowerCase().contains(_query.toLowerCase()) ||
                (deck.description
                        ?.toLowerCase()
                        .contains(_query.toLowerCase()) ??
                    false) ||
                deck.tags.any(
                  (tag) => tag.toLowerCase().contains(_query.toLowerCase()),
                ),
          )
          .toList();
    } else {
      _deckResults = [];
    }

    // Search quizzes
    if (_filterType == SearchFilterType.all ||
        _filterType == SearchFilterType.quizzes) {
      _quizResults = quizzes
          .where(
            (quiz) =>
                quiz.name.toLowerCase().contains(_query.toLowerCase()) ||
                (quiz.description
                        ?.toLowerCase()
                        .contains(_query.toLowerCase()) ??
                    false),
          )
          .toList();
    } else {
      _quizResults = [];
    }

    // Search flashcards
    if (_filterType == SearchFilterType.all ||
        _filterType == SearchFilterType.flashcards) {
      _flashcardResults = flashcards
          .where(
            (flashcard) =>
                flashcard.frontText
                    .toLowerCase()
                    .contains(_query.toLowerCase()) ||
                flashcard.backText.toLowerCase().contains(_query.toLowerCase()) ||
                (flashcard.tags?.any(
                      (tag) => tag.toLowerCase().contains(_query.toLowerCase()),
                    ) ??
                    false),
          )
          .toList();
    } else {
      _flashcardResults = [];
    }

    // Apply sorting
    _applySorting();

    // Add to recent searches
    _addToRecentSearches(_query);

    notifyListeners();
  }

  /// Apply sorting to results
  void _applySorting() {
    switch (_sortOption) {
      case SearchSortOption.relevance:
        // Relevance is already handled by search order
        break;
      case SearchSortOption.dateNewest:
        _courseResults.sort(
          (a, b) => b.updatedAt.compareTo(a.updatedAt),
        );
        _deckResults.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        _quizResults.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        _flashcardResults.sort(
          (a, b) => b.updatedAt.compareTo(a.updatedAt),
        );
        break;
      case SearchSortOption.dateOldest:
        _courseResults.sort(
          (a, b) => a.updatedAt.compareTo(b.updatedAt),
        );
        _deckResults.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        _quizResults.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        _flashcardResults.sort(
          (a, b) => a.updatedAt.compareTo(b.updatedAt),
        );
        break;
      case SearchSortOption.nameAscending:
        _courseResults.sort((a, b) => a.name.compareTo(b.name));
        _deckResults.sort((a, b) => a.name.compareTo(b.name));
        _quizResults.sort((a, b) => a.name.compareTo(b.name));
        _flashcardResults.sort(
          (a, b) => a.frontText.compareTo(b.frontText),
        );
        break;
      case SearchSortOption.nameDescending:
        _courseResults.sort((a, b) => b.name.compareTo(a.name));
        _deckResults.sort((a, b) => b.name.compareTo(a.name));
        _quizResults.sort((a, b) => b.name.compareTo(a.name));
        _flashcardResults.sort(
          (a, b) => b.frontText.compareTo(a.frontText),
        );
        break;
    }
  }

  /// Add query to recent searches
  void _addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;

    // Remove if already exists
    _recentSearches.remove(query.trim());

    // Add to beginning
    _recentSearches.insert(0, query.trim());

    // Limit to max recent searches
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
    }

    _saveRecentSearches();
  }

  /// Clear search
  void clearSearch() {
    _query = '';
    _courseResults = [];
    _deckResults = [];
    _flashcardResults = [];
    notifyListeners();
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    _recentSearches = [];
    await _saveRecentSearches();
    notifyListeners();
  }

  /// Remove a recent search
  Future<void> removeRecentSearch(String search) async {
    _recentSearches.remove(search);
    await _saveRecentSearches();
    notifyListeners();
  }

  /// Use a recent search
  void useRecentSearch(String search) {
    setQuery(search);
  }
}

