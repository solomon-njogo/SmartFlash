import 'package:flutter/foundation.dart';
import 'package:fsrs/fsrs.dart' hide State;
import '../../data/models/flashcard_model.dart';
import '../../data/models/deck_attempt_model.dart';
import '../../data/models/deck_attempt_card_result.dart';
import '../services/fsrs_scheduler_service.dart';
import '../services/review_log_service.dart';
import '../services/deck_attempt_service.dart';
import '../../data/remote/supabase_client.dart';
import '../../core/utils/logger.dart';
import 'package:uuid/uuid.dart';

/// Flashcard Review Provider for managing FSRS-powered flashcard reviews
class FlashcardReviewProvider extends ChangeNotifier {
  final FSRSSchedulerService _schedulerService = FSRSSchedulerService();
  final ReviewLogService _reviewLogService = ReviewLogService();
  final DeckAttemptService _attemptService = DeckAttemptService();
  final SupabaseService _supabaseService = SupabaseService.instance;

  List<FlashcardModel> _dueCards = [];
  List<FlashcardModel> _newCards = [];
  List<FlashcardModel> _learningCards = [];
  List<FlashcardModel> _reviewCards = [];
  List<FlashcardModel> _relearningCards = [];

  FlashcardModel? _currentCard;
  bool _isLoading = false;
  String? _error;
  int _currentCardIndex = 0;
  bool _showAnswer = false;
  DateTime? _startTime;
  // TODO: Use response time in review log creation
  // ignore: unused_field
  double _responseTime = 0.0;
  DeckAttemptModel? _currentAttempt;
  final List<DeckAttemptCardResult> _cardResults = [];
  final Uuid _uuid = const Uuid();
  DateTime? _sessionStartTime;

  /// Cards due for review
  List<FlashcardModel> get dueCards => _dueCards;

  /// New cards (never reviewed)
  List<FlashcardModel> get newCards => _newCards;

  /// Cards in learning phase
  List<FlashcardModel> get learningCards => _learningCards;

  /// Cards in review phase
  List<FlashcardModel> get reviewCards => _reviewCards;

  /// Cards in relearning phase
  List<FlashcardModel> get relearningCards => _relearningCards;

  /// Currently displayed card
  FlashcardModel? get currentCard => _currentCard;

  /// Whether data is loading
  bool get isLoading => _isLoading;

  /// Current error message
  String? get error => _error;

  /// Current card index in the review session
  int get currentCardIndex => _currentCardIndex;

  /// Total cards in current session
  int get totalCards => _dueCards.length;

  /// Whether answer is currently shown
  bool get showAnswer => _showAnswer;

  /// Progress percentage (0.0 to 1.0)
  double get progress => totalCards > 0 ? _currentCardIndex / totalCards : 0.0;

  /// Whether there are more cards to review
  bool get hasMoreCards => _currentCardIndex < totalCards;

  /// Initialize the provider
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();

      _schedulerService.initialize();
      _reviewLogService.initialize();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize: $e');
      _setLoading(false);
    }
  }

  /// Load cards for review session
  Future<void> loadCardsForReview(String deckId) async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Load cards from local storage or API
      // For now, using empty lists
      _dueCards = [];
      _newCards = [];
      _learningCards = [];
      _reviewCards = [];
      _relearningCards = [];

      _currentCardIndex = 0;
      _showAnswer = false;
      _currentCard = null;

      if (_dueCards.isNotEmpty) {
        _currentCard = _dueCards.first;
        _startTime = DateTime.now();
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load cards: $e');
      _setLoading(false);
    }
  }

  /// Start review session with specific cards
  Future<void> startReviewSession(
    List<FlashcardModel> cards,
    String deckId,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      // Initialize services if not already initialized
      try {
        _schedulerService.initialize();
        _reviewLogService.initialize();
        Logger.info('Review services initialized');
      } catch (e) {
        Logger.warning('Failed to initialize review services (non-critical): $e');
        // Continue even if initialization fails
      }

      _dueCards = cards;
      _currentCardIndex = 0;
      _showAnswer = false;
      _currentCard = cards.isNotEmpty ? cards.first : null;
      _startTime = DateTime.now();
      _sessionStartTime = DateTime.now();
      _cardResults.clear();

      // Create attempt record (but don't save card results yet)
      final userId = _supabaseService.currentUserId;
      if (userId != null && deckId.isNotEmpty) {
        _currentAttempt = await _attemptService.createAttempt(
          deckId: deckId,
          userId: userId,
          totalCards: cards.length,
        );
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to start review session: $e');
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Show the answer for current card
  void showCardAnswer() {
    if (_currentCard != null && !_showAnswer) {
      _showAnswer = true;
      notifyListeners();
    }
  }

  /// Rate the current card and move to next
  Future<void> rateCard(Rating rating) async {
    if (_currentCard == null) {
      Logger.warning('Cannot rate card: currentCard is null');
      return;
    }

    try {
      Logger.info('Rating card ${_currentCardIndex + 1}/${_dueCards.length} - Rating: ${_ratingToString(rating)}');
      _setLoading(true);

      // Calculate response time
      int timeSpentSeconds = 0;
      if (_startTime != null) {
        final timeSpent = DateTime.now().difference(_startTime!);
        _responseTime = timeSpent.inSeconds.toDouble();
        timeSpentSeconds = timeSpent.inSeconds;
        Logger.info('Time spent on card: ${timeSpentSeconds}s');
      }

      // Review the card using FSRS
      final result = _schedulerService.reviewFlashcard(_currentCard!, rating);
      Logger.info('FSRS review completed for card: ${_currentCard!.id}');

      // Save review log (for FSRS algorithm) - non-critical, continue if it fails
      try {
        await _reviewLogService.saveReviewLog(result.reviewLog);
        Logger.info('Review log saved');
      } catch (e) {
        Logger.warning('Failed to save review log (non-critical): $e');
        // Continue even if review log save fails - it's not critical for the attempt
      }

      // Store card result locally (don't save to database yet)
      // Store the current card ID before we potentially null it
      final currentCardId = _currentCard!.id;
      final currentCardIndexForResult = _currentCardIndex;
      
      if (_currentAttempt != null) {
        // Create card result and store locally
        final cardResult = DeckAttemptCardResult(
          id: _uuid.v4(),
          attemptId: _currentAttempt!.id,
          flashcardId: currentCardId,
          rating: _ratingToString(rating),
          timeSpentSeconds: timeSpentSeconds,
          answeredAt: DateTime.now(),
          order: currentCardIndexForResult,
        );

        _cardResults.add(cardResult);
        Logger.info('Card result added locally. Total results: ${_cardResults.length}');

        // Update local attempt statistics based on difficulty rating
        final updatedCardsStudied = _currentAttempt!.cardsStudied + 1;
        final updatedCardsAgain = rating == Rating.again 
            ? _currentAttempt!.cardsAgain + 1 
            : _currentAttempt!.cardsAgain;
        final updatedCardsHard = rating == Rating.hard 
            ? _currentAttempt!.cardsHard + 1 
            : _currentAttempt!.cardsHard;
        final updatedCardsGood = rating == Rating.good 
            ? _currentAttempt!.cardsGood + 1 
            : _currentAttempt!.cardsGood;
        final updatedCardsEasy = rating == Rating.easy 
            ? _currentAttempt!.cardsEasy + 1 
            : _currentAttempt!.cardsEasy;
        final totalTimeSeconds =
            _sessionStartTime != null
                ? DateTime.now().difference(_sessionStartTime!).inSeconds
                : 0;

        _currentAttempt = _currentAttempt!.copyWith(
          cardsStudied: updatedCardsStudied,
          cardsAgain: updatedCardsAgain,
          cardsHard: updatedCardsHard,
          cardsGood: updatedCardsGood,
          cardsEasy: updatedCardsEasy,
          totalTimeSeconds: totalTimeSeconds,
          updatedAt: DateTime.now(),
        );
        
        Logger.info('Attempt stats updated - Studied: $updatedCardsStudied, Again: $updatedCardsAgain, Hard: $updatedCardsHard, Good: $updatedCardsGood, Easy: $updatedCardsEasy');
      }

      // Update the card in local storage
      // TODO: Update card in local storage

      // Move to next card
      _currentCardIndex++;
      _showAnswer = false;
      _startTime = DateTime.now();

      Logger.info('Moving to next card. New index: $_currentCardIndex, Total cards: ${_dueCards.length}');

      if (_currentCardIndex < _dueCards.length) {
        _currentCard = _dueCards[_currentCardIndex];
        Logger.info('Next card loaded: ${_currentCard!.id}');
      } else {
        // All cards reviewed - set currentCard to null to mark session as completed
        _currentCard = null;
        Logger.info('All cards reviewed! Session completed. Total results: ${_cardResults.length}');
        Logger.info('Current card set to null. isSessionCompleted should be: ${_currentCard == null && _dueCards.isNotEmpty}');
        // All cards reviewed - show summary screen
        // Don't save yet, wait for user to view summary
      }

      _setLoading(false);
      notifyListeners();
      
      // Log final state for debugging
      Logger.info('After notifyListeners - currentCard: ${_currentCard?.id ?? "null"}, cardIndex: $_currentCardIndex, totalCards: ${_dueCards.length}, isSessionCompleted: ${_currentCard == null && _dueCards.isNotEmpty}');
    } catch (e) {
      Logger.error('Failed to rate card: $e');
      _setError('Failed to rate card: $e');
      
      // Even on error, try to complete the card processing
      // Increment index and update card state
      _currentCardIndex++;
      if (_currentCardIndex >= _dueCards.length) {
        _currentCard = null;
        Logger.info('Error occurred but setting currentCard to null since all cards processed');
      } else if (_currentCardIndex < _dueCards.length) {
        _currentCard = _dueCards[_currentCardIndex];
      }
      
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Convert Rating enum to string
  String _ratingToString(Rating rating) {
    switch (rating) {
      case Rating.again:
        return 'again';
      case Rating.hard:
        return 'hard';
      case Rating.good:
        return 'good';
      case Rating.easy:
        return 'easy';
    }
  }

  /// Skip current card
  void skipCard() {
    if (_currentCard == null) return;

    _currentCardIndex++;
    _showAnswer = false;
    _startTime = DateTime.now();

    if (_currentCardIndex < _dueCards.length) {
      _currentCard = _dueCards[_currentCardIndex];
    } else {
      _currentCard = null;
    }

    notifyListeners();
  }

  /// Go to previous card
  void goToPreviousCard() {
    if (!canGoToPrevious) return;

    _currentCardIndex--;
    _showAnswer = false;
    _startTime = DateTime.now();

    if (_currentCardIndex >= 0 && _currentCardIndex < _dueCards.length) {
      _currentCard = _dueCards[_currentCardIndex];
      // Check if this card was already rated
      final existingResult =
          _cardResults
              .where((result) => result.flashcardId == _currentCard!.id)
              .firstOrNull;
      // If card was rated, show answer automatically
      if (existingResult != null) {
        _showAnswer = true;
      }
    }

    notifyListeners();
  }

  /// Go to next card
  void goToNextCard() {
    if (!canGoToNext) return;

    _currentCardIndex++;
    _showAnswer = false;
    _startTime = DateTime.now();

    if (_currentCardIndex < _dueCards.length) {
      _currentCard = _dueCards[_currentCardIndex];
      // Check if this card was already rated
      final existingResult =
          _cardResults
              .where((result) => result.flashcardId == _currentCard!.id)
              .firstOrNull;
      // If card was rated, show answer automatically
      if (existingResult != null) {
        _showAnswer = true;
      }
    } else {
      _currentCard = null;
    }

    notifyListeners();
  }

  /// Get preview of next review dates for current card
  Map<Rating, DateTime> getReviewDatePreview() {
    if (_currentCard == null) return {};
    return _schedulerService.getFlashcardReviewDatePreview(_currentCard!);
  }

  /// Get retrievability for current card
  double getCurrentCardRetrievability() {
    if (_currentCard == null) return 0.0;
    return _schedulerService.getFlashcardRetrievability(
      _currentCard!,
      DateTime.now(),
    );
  }

  /// Get review statistics for current card
  ReviewStats getCurrentCardStats() {
    if (_currentCard == null) {
      return ReviewStats(
        totalReviews: 0,
        correctAnswers: 0,
        incorrectAnswers: 0,
        averageResponseTime: 0.0,
        lastReviewedAt: null,
        streak: 0,
      );
    }
    return _reviewLogService.getReviewStats(_currentCard!.id);
  }

  /// Reset review session
  void resetSession() {
    _currentCardIndex = 0;
    _showAnswer = false;
    _currentCard = _dueCards.isNotEmpty ? _dueCards.first : null;
    _startTime = DateTime.now();
    notifyListeners();
  }

  /// Clear all data
  void clearData() {
    _dueCards.clear();
    _newCards.clear();
    _learningCards.clear();
    _reviewCards.clear();
    _relearningCards.clear();
    _currentCard = null;
    _currentCardIndex = 0;
    _showAnswer = false;
    _startTime = null;
    _currentAttempt = null;
    _cardResults.clear();
    _sessionStartTime = null;
    notifyListeners();
  }

  /// Get current attempt
  DeckAttemptModel? get currentAttempt => _currentAttempt;

  /// Get collected card results
  List<DeckAttemptCardResult> get cardResults =>
      List.unmodifiable(_cardResults);

  /// Check if session is completed (all cards reviewed)
  bool get isSessionCompleted => _currentCard == null && _dueCards.isNotEmpty;

  /// Check if can go to previous card
  bool get canGoToPrevious => _currentCardIndex > 0;

  /// Check if can go to next card
  bool get canGoToNext => _currentCardIndex < _dueCards.length - 1;

  /// Check if current card has been rated
  bool get isCurrentCardRated {
    if (_currentCard == null) return false;
    return _cardResults.any((result) => result.flashcardId == _currentCard!.id);
  }

  /// Save attempt and all card results to database
  Future<void> saveAttemptResults() async {
    if (_currentAttempt == null || _cardResults.isEmpty) return;

    try {
      _setLoading(true);
      _clearError();

      // Save all card results
      for (final cardResult in _cardResults) {
        try {
          await _attemptService.saveCardResult(
            attemptId: cardResult.attemptId,
            flashcardId: cardResult.flashcardId,
            rating: _stringToRating(cardResult.rating),
            timeSpentSeconds: cardResult.timeSpentSeconds,
            order: cardResult.order,
          );
        } catch (e) {
          Logger.error('Failed to save card result: $e');
        }
      }

      // Update attempt with final statistics
      final totalTimeSeconds =
          _sessionStartTime != null
              ? DateTime.now().difference(_sessionStartTime!).inSeconds
              : _currentAttempt!.totalTimeSeconds;

      final updatedAttempt = _currentAttempt!.copyWith(
        totalTimeSeconds: totalTimeSeconds,
        updatedAt: DateTime.now(),
      );

      _currentAttempt = await _supabaseService.updateDeckAttempt(
        updatedAttempt,
      );

      // Complete the attempt
      _currentAttempt = await _attemptService.completeAttempt(_currentAttempt!);

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to save attempt results: $e');
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Convert string to Rating enum
  Rating _stringToRating(String rating) {
    switch (rating) {
      case 'again':
        return Rating.again;
      case 'hard':
        return Rating.hard;
      case 'good':
        return Rating.good;
      case 'easy':
        return Rating.easy;
      default:
        return Rating.again;
    }
  }

  /// Abandon current attempt
  Future<void> abandonAttempt() async {
    if (_currentAttempt != null) {
      try {
        _currentAttempt = await _attemptService.abandonAttempt(
          _currentAttempt!,
        );
        notifyListeners();
      } catch (e) {
        Logger.error('Failed to abandon attempt: $e');
      }
    }
  }

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
