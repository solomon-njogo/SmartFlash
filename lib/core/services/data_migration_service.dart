import '../../data/local/hive_service.dart';

/// Data Migration Service for converting SM-2 to FSRS
class DataMigrationService {
  static final DataMigrationService _instance =
      DataMigrationService._internal();
  factory DataMigrationService() => _instance;
  DataMigrationService._internal();

  /// Migrate all flashcards from SM-2 to FSRS
  Future<MigrationResult> migrateFlashcardsToFSRS() async {
    try {
      final flashcardBox = HiveService.instance.flashcardBox;
      final flashcards = flashcardBox.values.toList();

      int migratedCount = 0;
      int skippedCount = 0;
      List<String> errors = [];

      for (final flashcard in flashcards) {
        try {
          // Skip if already has FSRS state
          // FSRS state is not stored on FlashcardModel in the current schema,
          // so we always consider migration as skipped for now.
          skippedCount++;
          continue;
        } catch (e) {
          errors.add('Failed to migrate flashcard ${flashcard.id}: $e');
        }
      }

      return MigrationResult(
        totalItems: flashcards.length,
        migratedCount: migratedCount,
        skippedCount: skippedCount,
        errors: errors,
      );
    } catch (e) {
      return MigrationResult(
        totalItems: 0,
        migratedCount: 0,
        skippedCount: 0,
        errors: ['Migration failed: $e'],
      );
    }
  }

  /// Migrate all questions from SM-2 to FSRS
  Future<MigrationResult> migrateQuestionsToFSRS() async {
    try {
      final questionBox = HiveService.instance.questionBox;
      final questions = questionBox.values.toList();

      int migratedCount = 0;
      int skippedCount = 0;
      List<String> errors = [];

      for (final question in questions) {
        try {
          // Skip if already has FSRS state
          // FSRS state is not stored on QuestionModel in the current schema,
          // so we always consider migration as skipped for now.
          skippedCount++;
          continue;
        } catch (e) {
          errors.add('Failed to migrate question ${question.id}: $e');
        }
      }

      return MigrationResult(
        totalItems: questions.length,
        migratedCount: migratedCount,
        skippedCount: skippedCount,
        errors: errors,
      );
    } catch (e) {
      return MigrationResult(
        totalItems: 0,
        migratedCount: 0,
        skippedCount: 0,
        errors: ['Migration failed: $e'],
      );
    }
  }

  /// Check if migration is needed
  Future<bool> isMigrationNeeded() async {
    try {
      // FSRS state is not tracked on models; migration not needed
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get migration statistics
  Future<MigrationStats> getMigrationStats() async {
    try {
      final flashcardBox = HiveService.instance.flashcardBox;
      final questionBox = HiveService.instance.questionBox;

      final flashcards = flashcardBox.values.toList();
      final questions = questionBox.values.toList();

      final flashcardsWithFSRS = 0;
      final questionsWithFSRS = 0;

      return MigrationStats(
        totalFlashcards: flashcards.length,
        flashcardsWithFSRS: flashcardsWithFSRS,
        totalQuestions: questions.length,
        questionsWithFSRS: questionsWithFSRS,
        migrationNeeded: false,
      );
    } catch (e) {
      return MigrationStats(
        totalFlashcards: 0,
        flashcardsWithFSRS: 0,
        totalQuestions: 0,
        questionsWithFSRS: 0,
        migrationNeeded: false,
      );
    }
  }
}

/// Result of a migration operation
class MigrationResult {
  final int totalItems;
  final int migratedCount;
  final int skippedCount;
  final List<String> errors;

  MigrationResult({
    required this.totalItems,
    required this.migratedCount,
    required this.skippedCount,
    required this.errors,
  });

  bool get isSuccess => errors.isEmpty;
  double get successRate => totalItems > 0 ? migratedCount / totalItems : 0.0;
}

/// Migration statistics
class MigrationStats {
  final int totalFlashcards;
  final int flashcardsWithFSRS;
  final int totalQuestions;
  final int questionsWithFSRS;
  final bool migrationNeeded;

  MigrationStats({
    required this.totalFlashcards,
    required this.flashcardsWithFSRS,
    required this.totalQuestions,
    required this.questionsWithFSRS,
    required this.migrationNeeded,
  });

  double get flashcardMigrationProgress =>
      totalFlashcards > 0 ? flashcardsWithFSRS / totalFlashcards : 0.0;

  double get questionMigrationProgress =>
      totalQuestions > 0 ? questionsWithFSRS / totalQuestions : 0.0;
}
