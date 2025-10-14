import 'package:flutter/foundation.dart';

/// Simple deck model for now
class DeckModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? courseId;

  DeckModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.courseId,
  });
}

/// Deck provider for managing deck-related state
class DeckProvider extends ChangeNotifier {
  List<DeckModel> _decks = [];
  bool _isLoading = false;
  String? _error;
  DeckModel? _selectedDeck;

  /// List of all decks
  List<DeckModel> get decks => _decks;

  /// Whether data is loading
  bool get isLoading => _isLoading;

  /// Current error message
  String? get error => _error;

  /// Currently selected deck
  DeckModel? get selectedDeck => _selectedDeck;

  DeckProvider() {
    _loadDecks();
  }

  /// Load all decks from local storage
  Future<void> _loadDecks() async {
    try {
      _setLoading(true);
      _clearError();

      // Sample decks organized by courses
      _decks = [
        // Computer Science 101 decks
        DeckModel(
          id: 'cs101_deck1',
          title: 'Programming Basics',
          description: 'Variables, functions, and control structures',
          category: 'Technology',
          courseId: 'cs101',
        ),
        DeckModel(
          id: 'cs101_deck2',
          title: 'Data Structures',
          description: 'Arrays, lists, stacks, and queues',
          category: 'Technology',
          courseId: 'cs101',
        ),
        DeckModel(
          id: 'cs101_deck3',
          title: 'Algorithms',
          description: 'Sorting, searching, and algorithm complexity',
          category: 'Technology',
          courseId: 'cs101',
        ),

        // Biology Advanced decks
        DeckModel(
          id: 'bio_adv_deck1',
          title: 'Cell Biology',
          description: 'Cell structure, organelles, and functions',
          category: 'Science',
          courseId: 'bio_adv',
        ),
        DeckModel(
          id: 'bio_adv_deck2',
          title: 'Genetics',
          description: 'DNA, RNA, genes, and inheritance',
          category: 'Science',
          courseId: 'bio_adv',
        ),

        // World History decks
        DeckModel(
          id: 'hist_deck1',
          title: 'Ancient Civilizations',
          description: 'Egypt, Greece, Rome, and early empires',
          category: 'History',
          courseId: 'world_history',
        ),
        DeckModel(
          id: 'hist_deck2',
          title: 'Medieval Period',
          description: 'Middle Ages, feudalism, and crusades',
          category: 'History',
          courseId: 'world_history',
        ),
        DeckModel(
          id: 'hist_deck3',
          title: 'Modern Era',
          description: 'Renaissance, revolutions, and world wars',
          category: 'History',
          courseId: 'world_history',
        ),

        // Mathematics decks
        DeckModel(
          id: 'math_deck1',
          title: 'Algebra',
          description: 'Linear equations, functions, and inequalities',
          category: 'Mathematics',
          courseId: 'math_course',
        ),
        DeckModel(
          id: 'math_deck2',
          title: 'Geometry',
          description: 'Angles, triangles, and circle theorems',
          category: 'Mathematics',
          courseId: 'math_course',
        ),
        DeckModel(
          id: 'math_deck3',
          title: 'Calculus',
          description: 'Derivatives, integrals, and limits',
          category: 'Mathematics',
          courseId: 'math_course',
        ),
        DeckModel(
          id: 'math_deck4',
          title: 'Statistics',
          description: 'Probability, distributions, and data analysis',
          category: 'Mathematics',
          courseId: 'math_course',
        ),

        // Spanish Language decks
        DeckModel(
          id: 'spanish_deck1',
          title: 'Vocabulary A1',
          description: 'Basic Spanish words and phrases',
          category: 'Language',
          courseId: 'spanish_lang',
        ),
        DeckModel(
          id: 'spanish_deck2',
          title: 'Common Phrases',
          description: 'Greetings, travel, and daily expressions',
          category: 'Language',
          courseId: 'spanish_lang',
        ),
      ];
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh decks from storage
  Future<void> refreshDecks() async {
    await _loadDecks();
  }

  /// Create a new deck
  Future<bool> createDeck(DeckModel deck) async {
    try {
      _setLoading(true);
      _clearError();

      _decks.add(deck);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing deck
  Future<bool> updateDeck(DeckModel deck) async {
    try {
      _setLoading(true);
      _clearError();

      final index = _decks.indexWhere((d) => d.id == deck.id);
      if (index != -1) {
        _decks[index] = deck;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a deck
  Future<bool> deleteDeck(String deckId) async {
    try {
      _setLoading(true);
      _clearError();

      _decks.removeWhere((deck) => deck.id == deckId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get deck by ID
  DeckModel? getDeckById(String deckId) {
    try {
      return _decks.firstWhere((deck) => deck.id == deckId);
    } catch (e) {
      return null;
    }
  }

  /// Set selected deck
  void selectDeck(DeckModel deck) {
    _selectedDeck = deck;
    notifyListeners();
  }

  /// Clear selected deck
  void clearSelectedDeck() {
    _selectedDeck = null;
    notifyListeners();
  }

  /// Search decks by title
  List<DeckModel> searchDecks(String query) {
    if (query.isEmpty) return _decks;

    return _decks
        .where(
          (deck) =>
              deck.title.toLowerCase().contains(query.toLowerCase()) ||
              deck.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// Get decks by category
  List<DeckModel> getDecksByCategory(String category) {
    return _decks.where((deck) => deck.category == category).toList();
  }

  /// Get decks by course ID
  List<DeckModel> getDecksByCourseId(String courseId) {
    return _decks.where((deck) => deck.courseId == courseId).toList();
  }

  /// Load decks with optional course ID filter
  Future<void> loadDecks({String? courseId}) async {
    await _loadDecks();
    if (courseId != null) {
      _decks = getDecksByCourseId(courseId);
      notifyListeners();
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear error manually
  void clearError() {
    _clearError();
  }
}
