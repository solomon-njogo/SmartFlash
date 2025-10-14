import 'package:flutter/foundation.dart';

/// Simple deck model for now
class DeckModel {
  final String id;
  final String title;
  final String description;
  final String category;

  DeckModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
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

      // Mock data for now (15 sample decks)
      _decks = [
        DeckModel(
          id: '1',
          title: 'Biology Basics',
          description: 'Cells, DNA, and the fundamentals of life',
          category: 'Science',
        ),
        DeckModel(
          id: '2',
          title: 'Chemistry Essentials',
          description: 'Atoms, bonding, periodic table trends',
          category: 'Science',
        ),
        DeckModel(
          id: '3',
          title: 'World History 101',
          description: 'Ancient to modern key events and figures',
          category: 'History',
        ),
        DeckModel(
          id: '4',
          title: 'US Capitals',
          description: 'States and their capital cities',
          category: 'Geography',
        ),
        DeckModel(
          id: '5',
          title: 'Algebra I',
          description: 'Linear equations, functions, and inequalities',
          category: 'Math',
        ),
        DeckModel(
          id: '6',
          title: 'Geometry',
          description: 'Angles, triangles, and circle theorems',
          category: 'Math',
        ),
        DeckModel(
          id: '7',
          title: 'Physics Foundations',
          description: 'Motion, forces, energy, and waves',
          category: 'Science',
        ),
        DeckModel(
          id: '8',
          title: 'Programming in Dart',
          description: 'Syntax, types, collections, and async',
          category: 'Technology',
        ),
        DeckModel(
          id: '9',
          title: 'Flutter Widgets',
          description: 'Common widgets and layout patterns',
          category: 'Technology',
        ),
        DeckModel(
          id: '10',
          title: 'Spanish Vocabulary A1',
          description: 'Everyday words and phrases for beginners',
          category: 'Language',
        ),
        DeckModel(
          id: '11',
          title: 'French Useful Phrases',
          description: 'Greetings, travel, dining expressions',
          category: 'Language',
        ),
        DeckModel(
          id: '12',
          title: 'Anatomy: Human Body',
          description: 'Major systems and organ functions',
          category: 'Medicine',
        ),
        DeckModel(
          id: '13',
          title: 'Literary Devices',
          description: 'Metaphor, irony, alliteration, and more',
          category: 'Literature',
        ),
        DeckModel(
          id: '14',
          title: 'Intro to Psychology',
          description: 'Key theories, experiments, and terms',
          category: 'Social Science',
        ),
        DeckModel(
          id: '15',
          title: 'Astronomy Highlights',
          description: 'Stars, planets, galaxies, and cosmology',
          category: 'Science',
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
