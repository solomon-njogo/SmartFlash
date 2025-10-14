import 'package:hive_flutter/hive_flutter.dart';
import '../models/fsrs_card_state_model.dart';
import '../models/review_log_model.dart';
import '../models/flashcard_model.dart';
import '../models/question_model.dart';
import '../../core/constants/app_constants.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  late Box<FlashcardModel> _flashcardsBox;
  late Box<QuestionModel> _questionsBox;
  late Box<ReviewLog> _reviewLogsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(FSRSCardStateAdapter());
    Hive.registerAdapter(ReviewLogAdapter());
    Hive.registerAdapter(FlashcardModelAdapter());
    Hive.registerAdapter(QuestionModelAdapter());
    
    // Open boxes
    _flashcardsBox = await Hive.openBox<FlashcardModel>(AppConstants.flashcardsBoxName);
    _questionsBox = await Hive.openBox<QuestionModel>(AppConstants.questionsBoxName);
    _reviewLogsBox = await Hive.openBox<ReviewLog>(AppConstants.reviewLogsBoxName);
  }

  // Flashcard methods
  Future<void> saveFlashcard(FlashcardModel flashcard) async {
    await _flashcardsBox.put(flashcard.id, flashcard);
  }

  Future<void> saveFlashcards(List<FlashcardModel> flashcards) async {
    final Map<String, FlashcardModel> flashcardsMap = {
      for (var flashcard in flashcards) flashcard.id: flashcard
    };
    await _flashcardsBox.putAll(flashcardsMap);
  }

  FlashcardModel? getFlashcard(String id) {
    return _flashcardsBox.get(id);
  }

  List<FlashcardModel> getAllFlashcards() {
    return _flashcardsBox.values.toList();
  }

  List<FlashcardModel> getFlashcardsByDeck(String deckId) {
    return _flashcardsBox.values
        .where((flashcard) => flashcard.deckId == deckId)
        .toList();
  }

  List<FlashcardModel> getDueFlashcards() {
    return _flashcardsBox.values
        .where((flashcard) => flashcard.isDueForReview)
        .toList();
  }

  Future<void> deleteFlashcard(String id) async {
    await _flashcardsBox.delete(id);
  }

  // Question methods
  Future<void> saveQuestion(QuestionModel question) async {
    await _questionsBox.put(question.id, question);
  }

  Future<void> saveQuestions(List<QuestionModel> questions) async {
    final Map<String, QuestionModel> questionsMap = {
      for (var question in questions) question.id: question
    };
    await _questionsBox.putAll(questionsMap);
  }

  QuestionModel? getQuestion(String id) {
    return _questionsBox.get(id);
  }

  List<QuestionModel> getAllQuestions() {
    return _questionsBox.values.toList();
  }

  List<QuestionModel> getQuestionsByQuiz(String quizId) {
    return _questionsBox.values
        .where((question) => question.quizId == quizId)
        .toList();
  }

  List<QuestionModel> getDueQuestions() {
    return _questionsBox.values
        .where((question) => question.isDueForReview)
        .toList();
  }

  Future<void> deleteQuestion(String id) async {
    await _questionsBox.delete(id);
  }

  // Review log methods
  Future<void> saveReviewLog(ReviewLog reviewLog) async {
    await _reviewLogsBox.put(reviewLog.id, reviewLog);
  }

  Future<void> saveReviewLogs(List<ReviewLog> reviewLogs) async {
    final Map<String, ReviewLog> reviewLogsMap = {
      for (var reviewLog in reviewLogs) reviewLog.id: reviewLog
    };
    await _reviewLogsBox.putAll(reviewLogsMap);
  }

  ReviewLog? getReviewLog(String id) {
    return _reviewLogsBox.get(id);
  }

  List<ReviewLog> getAllReviewLogs() {
    return _reviewLogsBox.values.toList();
  }

  List<ReviewLog> getReviewLogsByCard(String cardId) {
    return _reviewLogsBox.values
        .where((reviewLog) => reviewLog.cardId == cardId)
        .toList()
      ..sort((a, b) => b.reviewDateTime.compareTo(a.reviewDateTime));
  }

  Future<void> deleteReviewLog(String id) async {
    await _reviewLogsBox.delete(id);
  }

  // Utility methods
  Future<void> clearAllData() async {
    await _flashcardsBox.clear();
    await _questionsBox.clear();
    await _reviewLogsBox.clear();
  }

  Future<void> close() async {
    await _flashcardsBox.close();
    await _questionsBox.close();
    await _reviewLogsBox.close();
  }

  // Getters for direct access
  Box<FlashcardModel> get flashcardsBox => _flashcardsBox;
  Box<QuestionModel> get questionsBox => _questionsBox;
  Box<ReviewLog> get reviewLogsBox => _reviewLogsBox;
}