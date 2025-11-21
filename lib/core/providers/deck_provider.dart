import 'package:flutter/foundation.dart';
import '../../data/models/deck_model.dart' as data_models;
import '../../data/remote/supabase_client.dart';
import '../utils/logger.dart';

/// Deck provider for managing deck-related state
class DeckProvider extends ChangeNotifier {
  List<data_models.DeckModel> _decks = [];
  bool _isLoading = false;
  String? _error;
  data_models.DeckModel? _selectedDeck;

  /// List of all decks
  List<data_models.DeckModel> get decks => _decks;

  /// Whether data is loading
  bool get isLoading => _isLoading;

  /// Current error message
  String? get error => _error;

  /// Currently selected deck
  data_models.DeckModel? get selectedDeck => _selectedDeck;

  DeckProvider() {
    _loadDecks();
  }

  /// Load all decks from database
  Future<void> _loadDecks() async {
    try {
      _setLoading(true);
      _clearError();

      final supabaseService = SupabaseService.instance;

      // Check if user is authenticated
      if (!supabaseService.isAuthenticated) {
        Logger.info('User not authenticated, skipping deck load');
        _decks = [];
        notifyListeners();
        return;
      }

      final userId = supabaseService.currentUserId;
      if (userId == null) {
        Logger.warning('User ID is null, skipping deck load');
        _decks = [];
        notifyListeners();
        return;
      }

      // Fetch decks from database
      _decks = await supabaseService.getUserDecks(userId);

      Logger.info('Loaded ${_decks.length} decks from database');
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to load decks: $e');
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
  Future<bool> createDeck(data_models.DeckModel deck) async {
    try {
      _setLoading(true);
      _clearError();

      final supabaseService = SupabaseService.instance;
      if (!supabaseService.isAuthenticated) {
        _setError('User not authenticated');
        return false;
      }

      final createdDeck = await supabaseService.createDeck(deck);
      _decks.add(createdDeck);
      notifyListeners();
      return true;
    } catch (e) {
      Logger.error('Failed to create deck: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing deck
  Future<bool> updateDeck(data_models.DeckModel deck) async {
    try {
      _setLoading(true);
      _clearError();

      final supabaseService = SupabaseService.instance;
      if (!supabaseService.isAuthenticated) {
        _setError('User not authenticated');
        return false;
      }

      final updatedDeck = await supabaseService.updateDeck(deck);
      final index = _decks.indexWhere((d) => d.id == deck.id);
      if (index != -1) {
        _decks[index] = updatedDeck;
        notifyListeners();
      }
      return true;
    } catch (e) {
      Logger.error('Failed to update deck: $e');
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

      final supabaseService = SupabaseService.instance;
      if (!supabaseService.isAuthenticated) {
        _setError('User not authenticated');
        return false;
      }

      await supabaseService.deleteDeck(deckId);
      _decks.removeWhere((deck) => deck.id == deckId);
      notifyListeners();
      return true;
    } catch (e) {
      Logger.error('Failed to delete deck: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get deck by ID
  data_models.DeckModel? getDeckById(String deckId) {
    try {
      return _decks.firstWhere((deck) => deck.id == deckId);
    } catch (e) {
      return null;
    }
  }

  /// Set selected deck
  void selectDeck(data_models.DeckModel deck) {
    _selectedDeck = deck;
    notifyListeners();
  }

  /// Clear selected deck
  void clearSelectedDeck() {
    _selectedDeck = null;
    notifyListeners();
  }

  /// Search decks by name
  List<data_models.DeckModel> searchDecks(String query) {
    if (query.isEmpty) return _decks;

    return _decks
        .where(
          (deck) =>
              deck.name.toLowerCase().contains(query.toLowerCase()) ||
              (deck.description?.toLowerCase().contains(query.toLowerCase()) ?? false),
        )
        .toList();
  }

  /// Get decks by course ID
  List<data_models.DeckModel> getDecksByCourseId(String courseId) {
    return _decks.where((deck) => deck.courseId == courseId).toList();
  }

  /// Get decks by course ID (async version that queries database if needed)
  Future<List<data_models.DeckModel>> getDecksByCourseIdAsync(String courseId) async {
    try {
      // First try local cache
      final cached = getDecksByCourseId(courseId);
      if (cached.isNotEmpty) {
        Logger.info('Found ${cached.length} decks in cache for course: $courseId');
        return cached;
      }

      // Fallback: query database directly by courseId
      Logger.info(
        'No local decks found, querying database for course decks: $courseId',
      );
      final supabaseService = SupabaseService.instance;
      if (!supabaseService.isAuthenticated) return [];

      // Query directly by courseId (more efficient than loading all decks)
      final courseDecks = await supabaseService.getCourseDecks(courseId);

      // Update local cache with results, avoiding duplicates
      if (courseDecks.isNotEmpty) {
        final existingIds = _decks.map((d) => d.id).toSet();
        final newDecks = courseDecks.where((d) => !existingIds.contains(d.id)).toList();
        if (newDecks.isNotEmpty) {
          _decks.addAll(newDecks);
          notifyListeners();
        }
      }

      Logger.info('Found ${courseDecks.length} decks for course: $courseId');
      return courseDecks;
    } catch (e) {
      Logger.error('Failed to get decks by course ID (async): $e');
      return [];
    }
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
