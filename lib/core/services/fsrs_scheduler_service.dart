import 'package:fsrs/fsrs.dart';
import '../constants/app_constants.dart';
import '../../data/models/fsrs_card_state_model.dart';
import '../../data/models/flashcard_model.dart';
import '../../data/models/question_model.dart';

class FSRSSchedulerService {
  static final FSRSSchedulerService _instance = FSRSSchedulerService._internal();
  factory FSRSSchedulerService() => _instance;
  FSRSSchedulerService._internal();

  late final Scheduler _scheduler;
  late final Parameters _parameters;

  void initialize() {
    _parameters = Parameters(
      desiredRetention: AppConstants.defaultDesiredRetention,
      maxInterval: AppConstants.maxInterval,
      learningSteps: AppConstants.learningSteps,
      relearningSteps: AppConstants.relearningSteps,
    );
    _scheduler = Scheduler(_parameters);
  }

  /// Review a flashcard with the given rating
  ReviewLog reviewFlashcard(FlashcardModel flashcard, int rating) {
    if (flashcard.fsrsState == null) {
      throw Exception('Flashcard must have FSRS state to review');
    }

    final card = _fsrsCardStateToCard(flashcard.fsrsState!);
    final now = DateTime.now();
    
    final review = _scheduler.review(card, Rating.values[rating - 1], now);
    
    final newFsrsState = _cardToFsrsCardState(review.card, now);
    final reviewLog = ReviewLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cardId: flashcard.id,
      rating: rating,
      reviewDateTime: now,
      scheduledDays: review.card.scheduledDays,
      elapsedDays: review.card.elapsedDays,
      state: review.card.state.index,
      cardState: newFsrsState,
      reviewType: AppConstants.flashcardReviewType,
    );

    return reviewLog;
  }

  /// Review a question with the given rating
  ReviewLog reviewQuestion(QuestionModel question, int rating) {
    if (question.fsrsState == null) {
      throw Exception('Question must have FSRS state to review');
    }

    final card = _fsrsCardStateToCard(question.fsrsState!);
    final now = DateTime.now();
    
    final review = _scheduler.review(card, Rating.values[rating - 1], now);
    
    final newFsrsState = _cardToFsrsCardState(review.card, now);
    final reviewLog = ReviewLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cardId: question.id,
      rating: rating,
      reviewDateTime: now,
      scheduledDays: review.card.scheduledDays,
      elapsedDays: review.card.elapsedDays,
      state: review.card.state.index,
      cardState: newFsrsState,
      reviewType: AppConstants.questionReviewType,
    );

    return reviewLog;
  }

  /// Auto-convert quiz result to FSRS rating
  ReviewLog reviewQuestionFromQuiz(QuestionModel question, bool isCorrect) {
    // Convert quiz result to FSRS rating
    // Incorrect → Rating.Again (1), Correct → Rating.Good (3)
    final rating = isCorrect ? 3 : 1;
    return reviewQuestion(question, rating);
  }

  /// Get the next review date for a card
  DateTime getNextReviewDate(FSRSCardState fsrsState) {
    return fsrsState.due;
  }

  /// Get the retrievability of a card
  double getRetrievability(FSRSCardState fsrsState) {
    final card = _fsrsCardStateToCard(fsrsState);
    return _scheduler.getRetrievability(card, DateTime.now());
  }

  /// Check if a card is due for review
  bool isDueForReview(FSRSCardState fsrsState) {
    return fsrsState.isDueForReview;
  }

  /// Get preview of next review date for each rating
  Map<int, DateTime> getNextReviewDatePreview(FSRSCardState fsrsState) {
    final card = _fsrsCardStateToCard(fsrsState);
    final now = DateTime.now();
    final previews = <int, DateTime>{};

    for (int rating = 1; rating <= 4; rating++) {
      try {
        final review = _scheduler.review(card, Rating.values[rating - 1], now);
        previews[rating] = DateTime.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch + (review.card.scheduledDays * 24 * 60 * 60 * 1000),
        );
      } catch (e) {
        // If preview fails, use current due date
        previews[rating] = fsrsState.due;
      }
    }

    return previews;
  }

  /// Convert FSRS CardState to FSRS Card
  Card _fsrsCardStateToCard(FSRSCardState fsrsState) {
    return Card(
      due: fsrsState.due,
      stability: fsrsState.stability,
      difficulty: fsrsState.difficulty,
      elapsedDays: fsrsState.elapsedDays,
      scheduledDays: fsrsState.scheduledDays,
      reps: fsrsState.reps,
      lapses: fsrsState.lapses,
      state: State.values[fsrsState.state],
      lastReview: fsrsState.lastReview,
    );
  }

  /// Convert FSRS Card to FSRS CardState
  FSRSCardState _cardToFsrsCardState(Card card, DateTime reviewTime) {
    return FSRSCardState(
      due: card.due,
      stability: card.stability,
      difficulty: card.difficulty,
      elapsedDays: card.elapsedDays,
      scheduledDays: card.scheduledDays,
      reps: card.reps,
      lapses: card.lapses,
      state: card.state.index,
      lastReview: reviewTime,
    );
  }

  /// Update parameters
  void updateParameters({
    double? desiredRetention,
    double? maxInterval,
    List<int>? learningSteps,
    List<int>? relearningSteps,
  }) {
    _parameters = Parameters(
      desiredRetention: desiredRetention ?? _parameters.desiredRetention,
      maxInterval: maxInterval ?? _parameters.maxInterval,
      learningSteps: learningSteps ?? _parameters.learningSteps,
      relearningSteps: relearningSteps ?? _parameters.relearningSteps,
    );
    _scheduler = Scheduler(_parameters);
  }

  /// Get current parameters
  Parameters get parameters => _parameters;
}