import 'package:fsrs/fsrs.dart';
import '../../data/models/flashcard_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/fsrs_card_state_model.dart';
import '../../data/models/review_log_model.dart';
import '../constants/app_constants.dart';

/// FSRS Scheduler Service for managing spaced repetition scheduling
class FSRSSchedulerService {
  static final FSRSSchedulerService _instance =
      FSRSSchedulerService._internal();
  factory FSRSSchedulerService() => _instance;
  FSRSSchedulerService._internal();

  /// Initialize the FSRS scheduler
  void initialize() {
    // FSRS scheduler initialization will be implemented when API is clarified
    // For now, we use our own simplified implementation with constants
    // TODO: Use AppConstants.fsrsParameters when FSRS API is clarified
  }

  /// Simulate FSRS scheduling logic until we understand the correct API
  Card _simulateFSRSSchedule(Card card, Rating rating, DateTime now) {
    // Simplified FSRS-like scheduling logic
    State newState;
    int newStep = card.step ?? 0;
    double? newStability = card.stability;
    double? newDifficulty = card.difficulty;
    DateTime newDue;

    switch (rating) {
      case Rating.again:
        newState = State.relearning;
        newStep = 0;
        newStability = null;
        newDifficulty = null;
        newDue = now.add(AppConstants.fsrsLearningStep1);
        break;
      case Rating.hard:
        if (card.state == State.learning) {
          newState = State.learning;
          newStep = (card.step ?? 0) + 1;
          newDue = now.add(AppConstants.fsrsLearningStep2);
        } else {
          newState = State.review;
          newStability = (card.stability ?? 2.5) * 0.8;
          newDue = now.add(Duration(days: 1));
        }
        break;
      case Rating.good:
        if (card.state == State.learning) {
          newState = State.learning;
          newStep = (card.step ?? 0) + 1;
          newDue = now.add(AppConstants.fsrsLearningStep2);
        } else {
          newState = State.review;
          newStability = card.stability ?? 2.5;
          newDue = now.add(Duration(days: 1));
        }
        break;
      case Rating.easy:
        if (card.state == State.learning) {
          newState = State.review;
          newStability = 2.5;
          newDue = now.add(Duration(days: 4));
        } else {
          newState = State.review;
          newStability = (card.stability ?? 2.5) * 1.3;
          newDue = now.add(Duration(days: 4));
        }
        break;
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

  /// Review a flashcard with the given rating
  ReviewResult reviewFlashcard(FlashcardModel flashcard, Rating rating) {
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

    // Schedule the card
    final scheduledCard = _simulateFSRSSchedule(card, rating, now);

    // Create review log
    final reviewLog = ReviewLogModel(
      id: '${flashcard.id}_${now.millisecondsSinceEpoch}',
      cardId: flashcard.id,
      cardType: 'flashcard',
      rating: rating,
      reviewDateTime: now,
      scheduledDays: 0, // FSRS doesn't expose this directly
      elapsedDays: 0, // FSRS doesn't expose this directly
      state: scheduledCard.state,
      cardState: scheduledCard.state,
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
  /// Note: Questions no longer support FSRS state in the database schema
  /// This method creates a review log but does not update question state
  ReviewResult reviewQuestion(QuestionModel question, Rating rating) {
    final now = DateTime.now();

    // Create review log
    final reviewLog = ReviewLogModel(
      id: '${question.id}_${now.millisecondsSinceEpoch}',
      cardId: question.id,
      cardType: 'question',
      rating: rating,
      reviewDateTime: now,
      scheduledDays: 0,
      elapsedDays: 0,
      state: State.learning, // Default state since we don't track FSRS for questions
      cardState: State.learning,
    );

    // Update question timestamp only (no FSRS state)
    return ReviewResult(
      updatedQuestion: question.copyWith(
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
  /// Note: Questions no longer support FSRS state in the database schema
  /// Returns null as questions don't track review dates
  DateTime? getQuestionNextReviewDate(QuestionModel question) {
    return null;
  }

  /// Get retrievability for a flashcard
  double getFlashcardRetrievability(FlashcardModel flashcard, DateTime now) {
    if (flashcard.fsrsState == null) return 0.0;
    return flashcard.fsrsState!.getRetrievability(now);
  }

  /// Get retrievability for a question
  /// Note: Questions no longer support FSRS state in the database schema
  /// Returns 0.0 as questions don't track retrievability
  double getQuestionRetrievability(QuestionModel question, DateTime now) {
    return 0.0;
  }

  /// Get preview of next review dates for all ratings
  Map<Rating, DateTime> getFlashcardReviewDatePreview(
    FlashcardModel flashcard,
  ) {
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

    return {
      Rating.again: _simulateFSRSSchedule(card, Rating.again, now).due,
      Rating.hard: _simulateFSRSSchedule(card, Rating.hard, now).due,
      Rating.good: _simulateFSRSSchedule(card, Rating.good, now).due,
      Rating.easy: _simulateFSRSSchedule(card, Rating.easy, now).due,
    };
  }

  /// Get preview of next review dates for all ratings for a question
  /// Note: Questions no longer support FSRS state in the database schema
  /// Returns empty map as questions don't track review dates
  Map<Rating, DateTime> getQuestionReviewDatePreview(QuestionModel question) {
    return {};
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
