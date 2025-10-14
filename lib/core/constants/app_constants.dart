class AppConstants {
  // FSRS Configuration
  static const double defaultDesiredRetention = 0.9;
  static const double maxInterval = 36500.0; // 100 years
  static const List<int> learningSteps = [1, 10]; // minutes
  static const List<int> relearningSteps = [1, 10]; // minutes
  
  // Review Rating Labels
  static const Map<int, String> ratingLabels = {
    1: 'Again',
    2: 'Hard', 
    3: 'Good',
    4: 'Easy',
  };
  
  static const Map<int, String> ratingDescriptions = {
    1: 'Forgot completely',
    2: 'Remembered with difficulty',
    3: 'Remembered with hesitation',
    4: 'Remembered easily',
  };
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Study Session Constants
  static const int maxCardsPerSession = 50;
  static const int maxQuestionsPerQuiz = 20;
  
  // Database Constants
  static const String flashcardsBoxName = 'flashcards';
  static const String questionsBoxName = 'questions';
  static const String reviewLogsBoxName = 'review_logs';
  static const String decksBoxName = 'decks';
  static const String quizzesBoxName = 'quizzes';
  
  // Supabase Constants
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Review Types
  static const String flashcardReviewType = 'flashcard';
  static const String questionReviewType = 'question';
}