import 'package:flutter/foundation.dart';
import '../../data/models/flashcard_model.dart';
import '../../data/models/review_log_model.dart';
import '../services/fsrs_scheduler_service.dart';
import '../services/review_log_service.dart';
import '../../data/local/hive_service.dart';

class FlashcardReviewProvider with ChangeNotifier {
  final FSRSSchedulerService _schedulerService = FSRSSchedulerService();
  final ReviewLogService _reviewLogService = ReviewLogService();
  final HiveService _hiveService = HiveService();

  List<FlashcardModel> _dueFlashcards = [];
  FlashcardModel? _currentCard;
  int _currentIndex = 0;
  bool _isRevealed = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<FlashcardModel> get dueFlashcards => _dueFlashcards;
  FlashcardModel? get currentCard => _currentCard;
  int get currentIndex => _currentIndex;
  bool get isRevealed => _isRevealed;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNextCard => _currentIndex < _dueFlashcards.length - 1;
  bool get hasPreviousCard => _currentIndex > 0;
  int get totalCards => _dueFlashcards.length;
  int get remainingCards => _dueFlashcards.length - _currentIndex;

  /// Initialize the review session
  Future<void> initializeReviewSession({String? deckId}) async {
    _setLoading(true);
    _clearError();

    try {
      // Get due flashcards
      if (deckId != null) {
        _dueFlashcards = _hiveService.getFlashcardsByDeck(deckId)
            .where((card) => card.isDueForReview)
            .toList();
      } else {
        _dueFlashcards = _hiveService.getDueFlashcards();
      }

      // Shuffle the cards for better learning
      _dueFlashcards.shuffle();

      if (_dueFlashcards.isNotEmpty) {
        _currentCard = _dueFlashcards.first;
        _currentIndex = 0;
        _isRevealed = false;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize review session: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Move to the next card
  void nextCard() {
    if (hasNextCard) {
      _currentIndex++;
      _currentCard = _dueFlashcards[_currentIndex];
      _isRevealed = false;
      notifyListeners();
    }
  }

  /// Move to the previous card
  void previousCard() {
    if (hasPreviousCard) {
      _currentIndex--;
      _currentCard = _dueFlashcards[_currentIndex];
      _isRevealed = false;
      notifyListeners();
    }
  }

  /// Reveal the answer
  void revealAnswer() {
    _isRevealed = true;
    notifyListeners();
  }

  /// Review the current card with a rating
  Future<void> reviewCard(int rating) async {
    if (_currentCard == null) return;

    _setLoading(true);
    _clearError();

    try {
      // Create review log using FSRS scheduler
      final reviewLog = _schedulerService.reviewFlashcard(_currentCard!, rating);
      
      // Update the flashcard with new FSRS state
      final updatedCard = _currentCard!.copyWith(
        fsrsState: reviewLog.cardState,
        updatedAt: DateTime.now(),
      );

      // Save to local storage
      await _hiveService.saveFlashcard(updatedCard);
      await _reviewLogService.saveReviewLog(reviewLog);

      // Update the current card in the list
      _dueFlashcards[_currentIndex] = updatedCard;
      _currentCard = updatedCard;

      notifyListeners();
    } catch (e) {
      _setError('Failed to review card: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get preview of next review dates for each rating
  Map<int, DateTime> getNextReviewDatePreview() {
    if (_currentCard?.fsrsState == null) return {};
    return _schedulerService.getNextReviewDatePreview(_currentCard!.fsrsState!);
  }

  /// Get retrievability of current card
  double getCurrentCardRetrievability() {
    if (_currentCard?.fsrsState == null) return 0.0;
    return _schedulerService.getRetrievability(_currentCard!.fsrsState!);
  }

  /// Skip the current card (mark as not reviewed)
  void skipCard() {
    nextCard();
  }

  /// Reset the review session
  void resetSession() {
    _dueFlashcards.clear();
    _currentCard = null;
    _currentIndex = 0;
    _isRevealed = false;
    _clearError();
    notifyListeners();
  }

  /// Get review statistics for the current session
  Map<String, dynamic> getSessionStats() {
    final totalCards = _dueFlashcards.length;
    final reviewedCards = _currentIndex;
    final remainingCards = totalCards - _currentIndex;
    
    return {
      'totalCards': totalCards,
      'reviewedCards': reviewedCards,
      'remainingCards': remainingCards,
      'progress': totalCards > 0 ? reviewedCards / totalCards : 0.0,
    };
  }

  /// Get cards by status
  List<FlashcardModel> getCardsByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return _dueFlashcards.where((card) => card.isNew).toList();
      case 'learning':
        return _dueFlashcards.where((card) => card.isLearning).toList();
      case 'review':
        return _dueFlashcards.where((card) => card.isReview).toList();
      case 'relearning':
        return _dueFlashcards.where((card) => card.isRelearning).toList();
      default:
        return _dueFlashcards;
    }
  }

  /// Filter cards by difficulty
  List<FlashcardModel> getCardsByDifficulty(int difficulty) {
    return _dueFlashcards.where((card) => card.difficulty == difficulty).toList();
  }

  /// Search cards by content
  List<FlashcardModel> searchCards(String query) {
    if (query.isEmpty) return _dueFlashcards;
    
    final lowercaseQuery = query.toLowerCase();
    return _dueFlashcards.where((card) =>
      card.front.toLowerCase().contains(lowercaseQuery) ||
      card.back.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}