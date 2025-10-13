import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../models/flashcard_model.dart';
import '../models/deck_model.dart';
import '../models/question_model.dart';
import '../models/quiz_model.dart';
import '../models/quiz_result_model.dart';
import 'adapters/user_adapter.dart' as user_adapters;
import 'adapters/flashcard_adapter.dart' as flashcard_adapters;
import 'adapters/deck_adapter.dart' as deck_adapters;
import 'adapters/question_adapter.dart' as question_adapters;
import 'adapters/quiz_adapter.dart' as quiz_adapters;
import 'adapters/quiz_result_adapter.dart' as quiz_result_adapters;
import 'adapters/quiz_enum_adapters.dart' as quiz_enum_adapters;

/// Service for managing Hive local database operations
class HiveService {
  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._();

  HiveService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize Hive and register adapters
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.info('HiveService already initialized');
      return;
    }

    try {
      Logger.info('Initializing Hive...');

      // Initialize Hive Flutter
      await Hive.initFlutter();

      // Register adapters
      await _registerAdapters();

      // Open boxes
      await _openBoxes();

      _isInitialized = true;
      Logger.info('HiveService initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize HiveService: $e');
      rethrow;
    }
  }

  /// Register all Hive adapters
  Future<void> _registerAdapters() async {
    try {
      // Register model adapters
      Hive.registerAdapter(user_adapters.UserModelAdapter());
      Hive.registerAdapter(flashcard_adapters.FlashcardModelAdapter());
      Hive.registerAdapter(deck_adapters.DeckModelAdapter());
      Hive.registerAdapter(question_adapters.QuestionModelAdapter());
      Hive.registerAdapter(quiz_adapters.QuizModelAdapter());
      Hive.registerAdapter(quiz_result_adapters.QuizResultModelAdapter());

      // Register enum adapters
      Hive.registerAdapter(DifficultyLevelAdapter());
      Hive.registerAdapter(CardTypeAdapter());
      Hive.registerAdapter(DeckVisibilityAdapter());
      Hive.registerAdapter(StudyModeAdapter());
      Hive.registerAdapter(quiz_enum_adapters.QuestionTypeAdapter());
      Hive.registerAdapter(quiz_enum_adapters.QuizStatusAdapter());
      Hive.registerAdapter(quiz_enum_adapters.QuizResultStatusAdapter());
      Hive.registerAdapter(quiz_enum_adapters.QuestionResultAdapter());

      Logger.info('Hive adapters registered successfully');
    } catch (e) {
      Logger.error('Failed to register Hive adapters: $e');
      rethrow;
    }
  }

  /// Open all required Hive boxes
  Future<void> _openBoxes() async {
    try {
      // Open main boxes
      await Future.wait([
        Hive.openBox<UserModel>(AppConstants.userBoxName),
        Hive.openBox<FlashcardModel>(AppConstants.flashcardBoxName),
        Hive.openBox<DeckModel>(AppConstants.deckBoxName),
        Hive.openBox<QuestionModel>('question_box'),
        Hive.openBox<QuizModel>(AppConstants.quizBoxName),
        Hive.openBox<QuizResultModel>(AppConstants.quizResultBoxName),
        Hive.openBox(AppConstants.progressBoxName),
      ]);

      Logger.info('All Hive boxes opened successfully');
    } catch (e) {
      Logger.error('Failed to open Hive boxes: $e');
      rethrow;
    }
  }

  /// Get a specific box by name
  Box<T> getBox<T>(String boxName) {
    if (!_isInitialized) {
      throw Exception('HiveService not initialized. Call initialize() first.');
    }

    final box = Hive.box<T>(boxName);
    if (box.isOpen) {
      return box;
    } else {
      throw Exception('Box $boxName is not open');
    }
  }

  /// Get user box
  Box<UserModel> get userBox => getBox<UserModel>(AppConstants.userBoxName);

  /// Get flashcard box
  Box<FlashcardModel> get flashcardBox =>
      getBox<FlashcardModel>(AppConstants.flashcardBoxName);

  /// Get deck box
  Box<DeckModel> get deckBox => getBox<DeckModel>(AppConstants.deckBoxName);

  /// Get progress box
  Box get progressBox => getBox(AppConstants.progressBoxName);

  /// Get question box
  Box<QuestionModel> get questionBox => getBox<QuestionModel>('question_box');

  /// Get quiz box
  Box<QuizModel> get quizBox => getBox<QuizModel>(AppConstants.quizBoxName);

  /// Get quiz result box
  Box<QuizResultModel> get quizResultBox =>
      getBox<QuizResultModel>(AppConstants.quizResultBoxName);

  /// Clear all data from all boxes
  Future<void> clearAllData() async {
    if (!_isInitialized) {
      Logger.warning('HiveService not initialized, cannot clear data');
      return;
    }

    try {
      Logger.info('Clearing all Hive data...');

      await Future.wait([
        userBox.clear(),
        flashcardBox.clear(),
        deckBox.clear(),
        questionBox.clear(),
        quizBox.clear(),
        quizResultBox.clear(),
        progressBox.clear(),
      ]);

      Logger.info('All Hive data cleared successfully');
    } catch (e) {
      Logger.error('Failed to clear Hive data: $e');
      rethrow;
    }
  }

  /// Close all boxes
  Future<void> closeBoxes() async {
    if (!_isInitialized) {
      Logger.warning('HiveService not initialized, nothing to close');
      return;
    }

    try {
      Logger.info('Closing Hive boxes...');

      await Future.wait([
        userBox.close(),
        flashcardBox.close(),
        deckBox.close(),
        questionBox.close(),
        quizBox.close(),
        quizResultBox.close(),
        progressBox.close(),
      ]);

      _isInitialized = false;
      Logger.info('All Hive boxes closed successfully');
    } catch (e) {
      Logger.error('Failed to close Hive boxes: $e');
      rethrow;
    }
  }

  /// Get storage statistics
  Map<String, dynamic> getStorageStats() {
    if (!_isInitialized) {
      return {'error': 'HiveService not initialized'};
    }

    try {
      return {
        'userBox': {'length': userBox.length, 'keys': userBox.keys.length},
        'flashcardBox': {
          'length': flashcardBox.length,
          'keys': flashcardBox.keys.length,
        },
        'deckBox': {'length': deckBox.length, 'keys': deckBox.keys.length},
        'questionBox': {
          'length': questionBox.length,
          'keys': questionBox.keys.length,
        },
        'progressBox': {
          'length': progressBox.length,
          'keys': progressBox.keys.length,
        },
        'quizBox': {'length': quizBox.length, 'keys': quizBox.keys.length},
        'quizResultBox': {
          'length': quizResultBox.length,
          'keys': quizResultBox.keys.length,
        },
      };
    } catch (e) {
      Logger.error('Failed to get storage stats: $e');
      return {'error': e.toString()};
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await closeBoxes();
    _instance = null;
  }
}
