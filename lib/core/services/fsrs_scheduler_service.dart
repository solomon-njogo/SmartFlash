import 'package:fsrs/fsrs.dart';
import '../../data/models/flashcard_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/fsrs_card_state_model.dart';
import '../../data/models/review_log_model.dart';
import '../config/fsrs_config.dart';

/// FSRS Scheduler Service for managing spaced repetition scheduling
class FSRSSchedulerService {
  static final FSRSSchedulerService _instance =
      FSRSSchedulerService._internal();
  factory FSRSSchedulerService() => _instance;
  FSRSSchedulerService._internal();

  bool _initialized = false;
  double _requestRetention = 0.9;

  /// Initialize the FSRS scheduler
  void initialize({String? userId}) {
    if (_initialized) return;

    // Parameters are stored but not used in simplified implementation
    // In full FSRS, these would be used in calculations
    FSRSConfig.getParameters(userId: userId);
    _requestRetention = FSRSConfig.getRequestRetention(userId: userId);

    _initialized = true;
  }

  /// Ensure FSRS is initialized
  void _ensureInitialized() {
    if (!_initialized) {
      initialize();
    }
  }

  /// Schedule a card using the FSRS algorithm
  /// Returns a map of ratings to scheduled cards
  Map<Rating, Card> _scheduleCard(Card card, DateTime now) {
    _ensureInitialized();

    // Use the FSRS algorithm to schedule the card for all ratings
    // For now, we'll use a simplified approach that works with the Card class
    // The actual FSRS implementation would use the parameters to calculate
    // stability, difficulty, and intervals

    final schedulingCards = <Rating, Card>{};

    // Calculate scheduled cards for each rating
    // This is a placeholder - the actual FSRS algorithm would be more complex
    for (final rating in [
      Rating.again,
      Rating.hard,
      Rating.good,
      Rating.easy,
    ]) {
      schedulingCards[rating] = _calculateScheduledCard(card, rating, now);
    }

    return schedulingCards;
  }

  /// Calculate scheduled card for a specific rating
  Card _calculateScheduledCard(Card card, Rating rating, DateTime now) {
    // This is a simplified FSRS implementation
    // In a full implementation, this would use the FSRS parameters
    // to calculate stability, difficulty, and intervals

    State newState;
    int newStep = card.step ?? 0;
    double? newStability = card.stability;
    double? newDifficulty = card.difficulty;
    DateTime newDue;

    switch (rating) {
      case Rating.again:
        newState =
            card.state == State.learning ? State.learning : State.relearning;
        newStep = 0;
        newStability = null;
        newDifficulty = null;
        newDue = now.add(FSRSConfig.learningSteps[0]);
        break;
      case Rating.hard:
        if (card.state == State.learning || card.state == State.relearning) {
          newState = card.state;
          newStep = (card.step ?? 0) + 1;
          newDue = now.add(
            FSRSConfig.learningSteps.length > 1
                ? FSRSConfig.learningSteps[1]
                : FSRSConfig.learningSteps[0],
          );
        } else {
          newState = State.review;
          newStability = (card.stability ?? 2.5) * 0.8;
          newDue = now.add(Duration(days: 1));
        }
        break;
      case Rating.good:
        if (card.state == State.learning || card.state == State.relearning) {
          newState = card.state;
          newStep = (card.step ?? 0) + 1;
          if (newStep >= FSRSConfig.learningSteps.length) {
            newState = State.review;
            newStability = 2.5;
            newDue = now.add(Duration(days: FSRSConfig.graduatingInterval));
          } else {
            newDue = now.add(FSRSConfig.learningSteps[newStep]);
          }
        } else {
          newState = State.review;
          newStability = card.stability ?? 2.5;
          final interval = _calculateInterval(newStability);
          newDue = now.add(Duration(days: interval));
        }
        break;
      case Rating.easy:
        if (card.state == State.learning || card.state == State.relearning) {
          newState = State.review;
          newStability = 2.5;
          newDue = now.add(Duration(days: FSRSConfig.easyInterval));
        } else {
          newState = State.review;
          newStability = (card.stability ?? 2.5) * 1.3;
          final interval = _calculateInterval(newStability);
          newDue = now.add(Duration(days: interval));
        }
        break;
    }

    // Ensure at least 24 hours between reviews
    final minimumNextReview = now.add(const Duration(hours: 24));
    if (newDue.isBefore(minimumNextReview)) {
      newDue = minimumNextReview;
    }

    return Card(
      cardId: card.cardId,
      state: newState,
      step: newStep,
      stability: newStability,
      difficulty: newDifficulty,
      due: newDue,
      lastReview: now,
    );
  }

  /// Calculate interval in days based on stability
  int _calculateInterval(double stability) {
    // Simplified interval calculation
    // Full FSRS would use the parameters and request retention
    return (stability * _requestRetention).round().clamp(
      1,
      FSRSConfig.maxInterval,
    );
  }

  /// Review a flashcard with the given rating
  ReviewResult reviewFlashcard(FlashcardModel flashcard, Rating rating) {
    _ensureInitialized();
    final now = DateTime.now();

    // Convert FlashcardModel to FSRS Card
    Card card;
    if (flashcard.fsrsState != null) {
      card = flashcard.fsrsState!.toFSRSCard();
    } else {
      // Create new card for first review
      card = Card(
        cardId: flashcard.id.hashCode,
        state: State.learning,
        step: 0,
        stability: null,
        difficulty: null,
        due: now,
        lastReview: null,
      );
    }

    // Get scheduling cards for all ratings
    final schedulingCards = _scheduleCard(card, now);

    // Get the scheduled card for the given rating
    final scheduledCard = schedulingCards[rating]!;

    // Calculate scheduled and elapsed days
    final scheduledDays = scheduledCard.due.difference(now).inDays;
    final elapsedDays =
        card.lastReview != null ? now.difference(card.lastReview!).inDays : 0;

    // Calculate retrievability using FSRSCardState method
    final fsrsState = FSRSCardState.fromFSRSCard(scheduledCard);
    final retrievability = fsrsState.getRetrievability(now);

    // Create review log
    final reviewLog = ReviewLogModel(
      id: '${flashcard.id}_${now.millisecondsSinceEpoch}',
      cardId: flashcard.id,
      cardType: 'flashcard',
      rating: rating,
      reviewDateTime: now,
      scheduledDays: scheduledDays,
      elapsedDays: elapsedDays,
      state: scheduledCard.state,
      cardState: scheduledCard.state,
      stability: scheduledCard.stability,
      difficulty: scheduledCard.difficulty,
      retrievability: retrievability,
    );

    // Convert back to FSRSCardState
    final newFsrsState = FSRSCardState.fromFSRSCard(scheduledCard);

    return ReviewResult(
      updatedFlashcard: flashcard.copyWith(
        fsrsState: newFsrsState,
        totalReviews: flashcard.totalReviews + 1,
        updatedAt: now,
      ),
      reviewLog: reviewLog,
    );
  }

  /// Review a question with the given rating
  ReviewResult reviewQuestion(QuestionModel question, Rating rating) {
    _ensureInitialized();
    final now = DateTime.now();

    // Convert QuestionModel to FSRS Card
    Card card;
    if (question.fsrsState != null) {
      card = question.fsrsState!.toFSRSCard();
    } else {
      // Create new card for first review
      card = Card(
        cardId: question.id.hashCode,
        state: State.learning,
        step: 0,
        stability: null,
        difficulty: null,
        due: now,
        lastReview: null,
      );
    }

    // Get scheduling cards for all ratings
    final schedulingCards = _scheduleCard(card, now);

    // Get the scheduled card for the given rating
    final scheduledCard = schedulingCards[rating]!;

    // Calculate scheduled and elapsed days
    final scheduledDays = scheduledCard.due.difference(now).inDays;
    final elapsedDays =
        card.lastReview != null ? now.difference(card.lastReview!).inDays : 0;

    // Calculate retrievability using FSRSCardState method
    final fsrsState = FSRSCardState.fromFSRSCard(scheduledCard);
    final retrievability = fsrsState.getRetrievability(now);

    // Create review log
    final reviewLog = ReviewLogModel(
      id: '${question.id}_${now.millisecondsSinceEpoch}',
      cardId: question.id,
      cardType: 'question',
      rating: rating,
      reviewDateTime: now,
      scheduledDays: scheduledDays,
      elapsedDays: elapsedDays,
      state: scheduledCard.state,
      cardState: scheduledCard.state,
      stability: scheduledCard.stability,
      difficulty: scheduledCard.difficulty,
      retrievability: retrievability,
    );

    // Convert back to FSRSCardState
    final newFsrsState = FSRSCardState.fromFSRSCard(scheduledCard);

    return ReviewResult(
      updatedQuestion: question.copyWith(
        fsrsState: newFsrsState,
        updatedAt: now,
      ),
      reviewLog: reviewLog,
    );
  }

  /// Auto-convert quiz result to FSRS rating
  Rating convertQuizResultToRating(bool isCorrect) {
    return isCorrect ? Rating.good : Rating.again;
  }

  /// Get next review date for a flashcard
  DateTime? getFlashcardNextReviewDate(FlashcardModel flashcard) {
    if (flashcard.fsrsState == null) return null;
    return flashcard.fsrsState!.due;
  }

  /// Get next review date for a question
  DateTime? getQuestionNextReviewDate(QuestionModel question) {
    if (question.fsrsState == null) return null;
    return question.fsrsState!.due;
  }

  /// Get retrievability for a flashcard
  double getFlashcardRetrievability(FlashcardModel flashcard, DateTime now) {
    if (flashcard.fsrsState == null) return 0.0;
    return flashcard.fsrsState!.getRetrievability(now);
  }

  /// Get retrievability for a question
  double getQuestionRetrievability(QuestionModel question, DateTime now) {
    if (question.fsrsState == null) return 0.0;
    return question.fsrsState!.getRetrievability(now);
  }

  /// Get preview of next review dates for all ratings
  Map<Rating, DateTime> getFlashcardReviewDatePreview(
    FlashcardModel flashcard,
  ) {
    _ensureInitialized();
    final now = DateTime.now();
    Card card;

    if (flashcard.fsrsState != null) {
      card = flashcard.fsrsState!.toFSRSCard();
    } else {
      card = Card(
        cardId: flashcard.id.hashCode,
        state: State.learning,
        step: 0,
        stability: null,
        difficulty: null,
        due: now,
        lastReview: null,
      );
    }

    final schedulingCards = _scheduleCard(card, now);

    return {
      Rating.again: schedulingCards[Rating.again]!.due,
      Rating.hard: schedulingCards[Rating.hard]!.due,
      Rating.good: schedulingCards[Rating.good]!.due,
      Rating.easy: schedulingCards[Rating.easy]!.due,
    };
  }

  /// Get preview of next review dates for all ratings for a question
  Map<Rating, DateTime> getQuestionReviewDatePreview(QuestionModel question) {
    _ensureInitialized();
    final now = DateTime.now();
    Card card;

    if (question.fsrsState != null) {
      card = question.fsrsState!.toFSRSCard();
    } else {
      card = Card(
        cardId: question.id.hashCode,
        state: State.learning,
        step: 0,
        stability: null,
        difficulty: null,
        due: now,
        lastReview: null,
      );
    }

    final schedulingCards = _scheduleCard(card, now);

    return {
      Rating.again: schedulingCards[Rating.again]!.due,
      Rating.hard: schedulingCards[Rating.hard]!.due,
      Rating.good: schedulingCards[Rating.good]!.due,
      Rating.easy: schedulingCards[Rating.easy]!.due,
    };
  }

  /// Get user-friendly rating labels
  Map<Rating, String> get ratingLabels => {
    Rating.again: 'Again',
    Rating.hard: 'Hard',
    Rating.good: 'Good',
    Rating.easy: 'Easy',
  };

  /// Get user-friendly rating descriptions
  Map<Rating, String> get ratingDescriptions => {
    Rating.again: 'Forgot completely',
    Rating.hard: 'Remembered with difficulty',
    Rating.good: 'Remembered with hesitation',
    Rating.easy: 'Remembered easily',
  };
}

/// Result of a review operation
class ReviewResult {
  final FlashcardModel? updatedFlashcard;
  final QuestionModel? updatedQuestion;
  final ReviewLogModel reviewLog;

  ReviewResult({
    this.updatedFlashcard,
    this.updatedQuestion,
    required this.reviewLog,
  });
}
