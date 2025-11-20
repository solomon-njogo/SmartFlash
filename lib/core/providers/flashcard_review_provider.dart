import 'package:flutter/foundation.dart';
import 'package:fsrs/fsrs.dart';
import '../../data/models/flashcard_model.dart';
import '../services/fsrs_scheduler_service.dart';
import '../services/review_log_service.dart';

/// Flashcard Review Provider for managing FSRS-powered flashcard reviews
class FlashcardReviewProvider extends ChangeNotifier {
  final FSRSSchedulerService _schedulerService = FSRSSchedulerService();
  final ReviewLogService _reviewLogService = ReviewLogService();

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
  void startReviewSession(List<FlashcardModel> cards) {
    _dueCards = cards;
    _currentCardIndex = 0;
    _showAnswer = false;
    _currentCard = cards.isNotEmpty ? cards.first : null;
    _startTime = DateTime.now();
    notifyListeners();
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
    if (_currentCard == null) return;

    try {
      _setLoading(true);

      // Calculate response time
      if (_startTime != null) {
        _responseTime =
            DateTime.now().difference(_startTime!).inSeconds.toDouble();
      }

      // Review the card using FSRS
      final result = _schedulerService.reviewFlashcard(_currentCard!, rating);

      // Save review log
      await _reviewLogService.saveReviewLog(result.reviewLog);

      // Update the card in local storage
      // TODO: Update card in local storage

      // Move to next card
      _currentCardIndex++;
      _showAnswer = false;
      _startTime = DateTime.now();

      if (_currentCardIndex < _dueCards.length) {
        _currentCard = _dueCards[_currentCardIndex];
      } else {
        _currentCard = null;
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to rate card: $e');
      _setLoading(false);
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
    notifyListeners();
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
