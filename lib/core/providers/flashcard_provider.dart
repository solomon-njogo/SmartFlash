import 'package:flutter/foundation.dart';
import '../../data/models/flashcard_model.dart';
import '../../data/remote/supabase_client.dart';
import '../utils/logger.dart';

/// Flashcard provider for managing flashcard state
class FlashcardProvider extends ChangeNotifier {
  List<FlashcardModel> _flashcards = [];
  FlashcardModel? _currentFlashcard;
  bool _isLoading = false;
  String? _error;

  /// List of all flashcards
  List<FlashcardModel> get flashcards => _flashcards;

  /// Current flashcard being viewed/edited
  FlashcardModel? get currentFlashcard => _currentFlashcard;

  /// Whether data is loading
  bool get isLoading => _isLoading;

  /// Current error message
  String? get error => _error;

  FlashcardProvider() {
    _loadFlashcards();
  }

  /// Load flashcards from storage
  Future<void> _loadFlashcards() async {
    try {
      _setLoading(true);
      _clearError();

      final supabaseService = SupabaseService.instance;

      // Check if user is authenticated
      if (!supabaseService.isAuthenticated) {
        Logger.info('User not authenticated, skipping flashcard load');
        _flashcards = [];
        notifyListeners();
        return;
      }

      final userId = supabaseService.currentUserId;
      if (userId == null) {
        Logger.warning('User ID is null, skipping flashcard load');
        _flashcards = [];
        notifyListeners();
        return;
      }

      // Fetch flashcards from database
      _flashcards = await supabaseService.getUserFlashcards(userId);

      Logger.info('Loaded ${_flashcards.length} flashcards from database');
      notifyListeners();
    } catch (e) {
      Logger.error('Failed to load flashcards: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Get flashcards by deck ID
  /// Filters flashcards directly by deckId
  List<FlashcardModel> getFlashcardsByDeckId(String deckId) {
    try {
      final matchingFlashcards =
          _flashcards.where((flashcard) => flashcard.deckId == deckId).toList();

      Logger.info(
        'Found ${matchingFlashcards.length} flashcards for deck $deckId',
      );

      return matchingFlashcards;
    } catch (e) {
      Logger.error('Failed to get flashcards by deck ID: $e');
      return [];
    }
  }

  /// Get flashcards by deck ID (async version that queries database if needed)
  Future<List<FlashcardModel>> getFlashcardsByDeckIdAsync(String deckId) async {
    try {
      // First try local cache
      final cached = getFlashcardsByDeckId(deckId);
      if (cached.isNotEmpty) {
        return cached;
      }

      // Fallback: query database directly
      Logger.info(
        'No local flashcards found, querying database for deck flashcards: $deckId',
      );
      final supabaseService = SupabaseService.instance;
      if (!supabaseService.isAuthenticated) return [];

      final flashcards = await supabaseService.getDeckFlashcards(deckId);

      // Update local cache with results, avoiding duplicates
      if (flashcards.isNotEmpty) {
        final existingIds = _flashcards.map((f) => f.id).toSet();
        final newFlashcards =
            flashcards.where((f) => !existingIds.contains(f.id)).toList();
        if (newFlashcards.isNotEmpty) {
          _flashcards.addAll(newFlashcards);
          notifyListeners();
        }
      }

      return flashcards;
    } catch (e) {
      Logger.error('Failed to get flashcards by deck ID (async): $e');
      return [];
    }
  }

  /// Get flashcard count for a deck
  int getFlashcardCountByDeckId(String deckId) {
    return getFlashcardsByDeckId(deckId).length;
  }

  /// Get flashcard by ID
  FlashcardModel? getFlashcardById(String flashcardId) {
    try {
      return _flashcards.firstWhere((flashcard) => flashcard.id == flashcardId);
    } catch (e) {
      return null;
    }
  }

  /// Refresh flashcards from storage
  Future<void> refreshFlashcards() async {
    await _loadFlashcards();
  }

  /// Create a new flashcard
  Future<bool> createFlashcard(FlashcardModel flashcard) async {
    try {
      _setLoading(true);
      _clearError();

      final supabaseService = SupabaseService.instance;
      if (!supabaseService.isAuthenticated) {
        _setError('User not authenticated');
        return false;
      }

      final createdFlashcard = await supabaseService.createFlashcard(flashcard);
      _flashcards.add(createdFlashcard);
      notifyListeners();
      return true;
    } catch (e) {
      Logger.error('Failed to create flashcard: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing flashcard
  Future<bool> updateFlashcard(FlashcardModel flashcard) async {
    try {
      _setLoading(true);
      _clearError();

      final supabaseService = SupabaseService.instance;
      if (!supabaseService.isAuthenticated) {
        _setError('User not authenticated');
        return false;
      }

      final updatedFlashcard = await supabaseService.updateFlashcard(flashcard);
      final index = _flashcards.indexWhere((f) => f.id == flashcard.id);
      if (index != -1) {
        _flashcards[index] = updatedFlashcard;
        notifyListeners();
      }
      return true;
    } catch (e) {
      Logger.error('Failed to update flashcard: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a flashcard
  Future<bool> deleteFlashcard(String flashcardId) async {
    try {
      _setLoading(true);
      _clearError();

      final supabaseService = SupabaseService.instance;
      if (!supabaseService.isAuthenticated) {
        _setError('User not authenticated');
        return false;
      }

      await supabaseService.deleteFlashcard(flashcardId);
      _flashcards.removeWhere((flashcard) => flashcard.id == flashcardId);
      notifyListeners();
      return true;
    } catch (e) {
      Logger.error('Failed to delete flashcard: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Set current flashcard
  void setCurrentFlashcard(FlashcardModel? flashcard) {
    _currentFlashcard = flashcard;
    notifyListeners();
  }

  /// Clear current flashcard
  void clearCurrentFlashcard() {
    _currentFlashcard = null;
    notifyListeners();
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

  /// Search flashcards by query
  /// Searches across frontText, backText, and tags
  List<FlashcardModel> searchFlashcards(String query) {
    if (query.isEmpty) return _flashcards;

    final lowerQuery = query.toLowerCase();
    return _flashcards
        .where(
          (flashcard) =>
              flashcard.frontText.toLowerCase().contains(lowerQuery) ||
              flashcard.backText.toLowerCase().contains(lowerQuery) ||
              (flashcard.tags?.any(
                    (tag) => tag.toLowerCase().contains(lowerQuery),
                  ) ??
                  false),
        )
        .toList();
  }
}

