import 'package:package_info_plus/package_info_plus.dart';

/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'SmartFlash';
  static const String appDescription = 'AI-powered study app';

  /// Get app version from pubspec.yaml
  static Future<String> get appVersion async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  // Database Configuration
  static const String hiveBoxName = 'smartflash_box';
  static const String userBoxName = 'user_box';
  static const String flashcardBoxName = 'flashcard_box';
  static const String deckBoxName = 'deck_box';
  static const String progressBoxName = 'progress_box';
  static const String quizBoxName = 'quiz_box';
  static const String quizResultBoxName = 'quiz_result_box';
  static const String reviewLogBoxName = 'review_log_box';

  // Spaced Repetition Configuration
  static const int initialInterval = 1; // days
  static const double initialEaseFactor = 2.5;
  static const int maxInterval = 365; // days
  static const int minInterval = 1; // days
  // FSRS learning steps (used while in learning state)
  static const Duration fsrsLearningStep1 = Duration(minutes: 1);
  static const Duration fsrsLearningStep2 = Duration(minutes: 10);

  // Study Session Configuration
  static const int defaultCardsPerSession = 20;
  static const int maxCardsPerSession = 100;
  static const Duration sessionTimeout = Duration(minutes: 30);

  // Quiz Configuration
  static const int defaultQuizQuestions = 10;
  static const int maxQuizQuestions = 50;
  static const int minQuizQuestions = 3;
  static const Duration quizTimeLimit = Duration(minutes: 30);
  static const Duration questionTimeLimit = Duration(minutes: 2);
  static const int maxAnswerOptions = 6;
  static const int minAnswerOptions = 2;

  // File Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> supportedFileTypes = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'md',
    'pptx',
    'ppt',
    'xls',
    'xlsx',
    'csv',
    'json',
    'xml',
  ];

  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Validation Rules
  static const int maxCardTitleLength = 100;
  static const int maxCardContentLength = 1000;
  static const int maxDeckNameLength = 50;
  static const int maxDeckDescriptionLength = 200;
  static const int maxQuizTitleLength = 100;
  static const int maxQuizDescriptionLength = 500;
  static const int maxQuestionTextLength = 500;
  static const int maxAnswerTextLength = 200;
}
