import 'package:flutter/foundation.dart';
import '../providers/ai_generation_provider.dart';
import '../../data/models/deck_model.dart';
import '../../data/remote/supabase_client.dart';
import '../utils/logger.dart';

/// Provider for managing AI content review workflow
class AIReviewProvider extends ChangeNotifier {
  AIReviewProvider({
    AIGenerationProvider? generationProvider,
    SupabaseService? supabaseService,
  }) : _generationProvider = generationProvider ?? AIGenerationProvider(),
       _supabaseService = SupabaseService.instance;

  final AIGenerationProvider _generationProvider;
  final SupabaseService _supabaseService;

  // State
  ReviewStatus _status = ReviewStatus.idle;
  String? _feedback;
  List<int> _selectedFlashcardIndices = [];
  List<int> _selectedQuestionIndices = [];

  // Getters
  ReviewStatus get status => _status;
  String? get feedback => _feedback;
  List<int> get selectedFlashcardIndices => _selectedFlashcardIndices;
  List<int> get selectedQuestionIndices => _selectedQuestionIndices;

  bool get isReviewing => _status == ReviewStatus.reviewing;
  bool get hasSelectedItems =>
      _selectedFlashcardIndices.isNotEmpty ||
      _selectedQuestionIndices.isNotEmpty;

  /// Start review process
  void startReview() {
    if (!_generationProvider.hasGeneratedContent) {
      return;
    }
    _status = ReviewStatus.reviewing;
    _selectedFlashcardIndices.clear();
    _selectedQuestionIndices.clear();
    notifyListeners();
  }

  /// Set feedback for regeneration
  void setFeedback(String feedback) {
    _feedback = feedback;
    notifyListeners();
  }

  /// Toggle flashcard selection
  void toggleFlashcardSelection(int index) {
    if (_selectedFlashcardIndices.contains(index)) {
      _selectedFlashcardIndices.remove(index);
    } else {
      _selectedFlashcardIndices.add(index);
    }
    notifyListeners();
  }

  /// Toggle question selection
  void toggleQuestionSelection(int index) {
    if (_selectedQuestionIndices.contains(index)) {
      _selectedQuestionIndices.remove(index);
    } else {
      _selectedQuestionIndices.add(index);
    }
    notifyListeners();
  }

  /// Select all flashcards
  void selectAllFlashcards() {
    final flashcards = _generationProvider.generatedFlashcards;
    if (flashcards != null) {
      _selectedFlashcardIndices = List.generate(flashcards.length, (i) => i);
      notifyListeners();
    }
  }

  /// Select all questions
  void selectAllQuestions() {
    final quiz = _generationProvider.generatedQuiz;
    if (quiz != null) {
      _selectedQuestionIndices = List.generate(quiz.questions.length, (i) => i);
      notifyListeners();
    }
  }

  /// Deselect all
  void deselectAll() {
    _selectedFlashcardIndices.clear();
    _selectedQuestionIndices.clear();
    notifyListeners();
  }

  /// Accept and save flashcards
  Future<bool> acceptFlashcards({
    required String deckId,
    required String deckName,
    String? createdBy,
  }) async {
    try {
      _status = ReviewStatus.saving;
      notifyListeners();

      final flashcards = _generationProvider.generatedFlashcards;
      if (flashcards == null || flashcards.isEmpty) {
        _status = ReviewStatus.idle;
        notifyListeners();
        return false;
      }

      // Filter selected flashcards if any are selected
      final flashcardsToSave =
          _selectedFlashcardIndices.isEmpty
              ? flashcards
              : _selectedFlashcardIndices.map((i) => flashcards[i]).toList();

      // Ensure deck exists
      DeckModel? deck;
      try {
        // Try to get existing deck
        final decks = await _supabaseService.getUserDecks(createdBy ?? '');
        deck = decks.firstWhere(
          (d) => d.id == deckId,
          orElse: () => throw Exception(),
        );
      } catch (e) {
        // Create new deck if it doesn't exist
        final now = DateTime.now();
        deck = DeckModel(
          id: deckId,
          name: deckName,
          description: 'AI-generated flashcards',
          createdBy: createdBy ?? '',
          createdAt: now,
          updatedAt: now,
          isAIGenerated: true,
        );
        await _supabaseService.createDeck(deck);
      }

      // Save flashcards
      final now = DateTime.now();
      for (final preview in flashcardsToSave) {
        final flashcard = preview.toFlashcardModel(
          id:
              '${deckId}_card_${now.millisecondsSinceEpoch}_${flashcardsToSave.indexOf(preview)}',
          createdBy: createdBy,
        );
        await _supabaseService.createFlashcard(flashcard);
      }

      // Deck is already created/updated, no need to update card count in MVP

      _status = ReviewStatus.completed;
      notifyListeners();
      return true;
    } catch (e, st) {
      Logger.error(
        'Error accepting flashcards: $e',
        tag: 'AIReviewProvider',
        error: e,
        stackTrace: st,
      );
      _status = ReviewStatus.failed;
      notifyListeners();
      return false;
    }
  }

  /// Accept and save quiz
  Future<bool> acceptQuiz({required String deckId, String? createdBy}) async {
    try {
      _status = ReviewStatus.saving;
      notifyListeners();

      final quizPreview = _generationProvider.generatedQuiz;
      if (quizPreview == null || quizPreview.questions.isEmpty) {
        _status = ReviewStatus.idle;
        notifyListeners();
        return false;
      }

      // Filter selected questions if any are selected
      final questionsToSave =
          _selectedQuestionIndices.isEmpty
              ? quizPreview.questions
              : _selectedQuestionIndices
                  .map((i) => quizPreview.questions[i])
                  .toList();

      if (questionsToSave.isEmpty) {
        _status = ReviewStatus.idle;
        notifyListeners();
        return false;
      }

      // Create quiz with selected questions
      final now = DateTime.now();
      final quizId = 'quiz_${now.millisecondsSinceEpoch}';
      final quizData = quizPreview.toQuizModels(
        quizId: quizId,
        createdBy: createdBy ?? '',
      );

      // Update quiz with filtered questions
      final filteredQuestions =
          questionsToSave.map((q) {
            return q.toQuestionModel(quizId: quizId, createdBy: createdBy);
          }).toList();

      final totalPoints = filteredQuestions.fold<int>(
        0,
        (sum, q) => sum + q.points,
      );
      final quiz = quizData.quiz.copyWith(
        questionIds: filteredQuestions.map((q) => q.id).toList(),
        totalQuestions: filteredQuestions.length,
        totalPoints: totalPoints,
      );

      // Save quiz
      await _supabaseService.createQuiz(quiz);

      // Save questions
      for (final question in filteredQuestions) {
        await _supabaseService.createQuestion(question);
      }

      _status = ReviewStatus.completed;
      notifyListeners();
      return true;
    } catch (e, st) {
      Logger.error(
        'Error accepting quiz: $e',
        tag: 'AIReviewProvider',
        error: e,
        stackTrace: st,
      );
      _status = ReviewStatus.failed;
      notifyListeners();
      return false;
    }
  }

  /// Reject and regenerate
  Future<void> rejectAndRegenerate() async {
    if (_feedback == null || _feedback!.isEmpty) {
      return;
    }

    try {
      _status = ReviewStatus.regenerating;
      notifyListeners();

      await _generationProvider.regenerateWithFeedback(_feedback!);

      _status = ReviewStatus.reviewing;
      _feedback = null;
      _selectedFlashcardIndices.clear();
      _selectedQuestionIndices.clear();
      notifyListeners();
    } catch (e, st) {
      Logger.error(
        'Error regenerating: $e',
        tag: 'AIReviewProvider',
        error: e,
        stackTrace: st,
      );
      _status = ReviewStatus.failed;
      notifyListeners();
    }
  }

  /// Reset review state
  void reset() {
    _status = ReviewStatus.idle;
    _feedback = null;
    _selectedFlashcardIndices.clear();
    _selectedQuestionIndices.clear();
    notifyListeners();
  }
}

enum ReviewStatus { idle, reviewing, saving, regenerating, completed, failed }
