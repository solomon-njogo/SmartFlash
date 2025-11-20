import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../providers/ai_generation_provider.dart';
import '../../data/models/deck_model.dart';
import '../../data/remote/supabase_client.dart';
import '../utils/logger.dart';

/// Provider for managing AI content review workflow
class AIReviewProvider extends ChangeNotifier {
  static const _uuid = Uuid();
  AIReviewProvider({
    AIGenerationProvider? generationProvider,
    SupabaseService? supabaseService,
  }) : _generationProvider = generationProvider,
       _supabaseService = SupabaseService.instance;

  AIGenerationProvider? _generationProvider;
  final SupabaseService _supabaseService;

  /// Set the generation provider (should be called from the UI with the shared instance)
  void setGenerationProvider(AIGenerationProvider provider) {
    _generationProvider = provider;
  }

  // State
  ReviewStatus _status = ReviewStatus.idle;
  String? _feedback;
  String? _error;
  List<int> _selectedFlashcardIndices = [];
  List<int> _selectedQuestionIndices = [];

  // Getters
  ReviewStatus get status => _status;
  String? get feedback => _feedback;
  String? get error => _error;
  List<int> get selectedFlashcardIndices => _selectedFlashcardIndices;
  List<int> get selectedQuestionIndices => _selectedQuestionIndices;

  bool get isReviewing => _status == ReviewStatus.reviewing;
  bool get hasSelectedItems =>
      _selectedFlashcardIndices.isNotEmpty ||
      _selectedQuestionIndices.isNotEmpty;

  /// Start review process
  void startReview() {
    if (_generationProvider == null ||
        !_generationProvider!.hasGeneratedContent) {
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
    if (_generationProvider == null) return;
    final flashcards = _generationProvider!.generatedFlashcards;
    if (flashcards != null) {
      _selectedFlashcardIndices = List.generate(flashcards.length, (i) => i);
      notifyListeners();
    }
  }

  /// Select all questions
  void selectAllQuestions() {
    if (_generationProvider == null) return;
    final quiz = _generationProvider!.generatedQuiz;
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

  /// Get or create a deck
  Future<DeckModel> _getOrCreateDeck({
    required String deckId,
    required String deckName,
    required String? createdBy,
    required String description,
  }) async {
    try {
      // Try to get existing deck
      final decks = await _supabaseService.getUserDecks(createdBy ?? '');
      return decks.firstWhere(
        (d) => d.id == deckId,
        orElse: () => throw Exception(),
      );
    } catch (e) {
      // Create new deck if it doesn't exist
      final now = DateTime.now();
      final deck = DeckModel(
        id: _uuid.v4(), // Generate proper UUID
        name: deckName,
        description: description,
        createdBy: createdBy ?? '',
        createdAt: now,
        updatedAt: now,
        isAIGenerated: true,
      );
      await _supabaseService.createDeck(deck);
      return deck;
    }
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

      if (_generationProvider == null) {
        _status = ReviewStatus.idle;
        _error = 'Generation provider not available. Please try again.';
        notifyListeners();
        return false;
      }
      final flashcards = _generationProvider!.generatedFlashcards;
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
      final deck = await _getOrCreateDeck(
        deckId: deckId,
        deckName: deckName,
        createdBy: createdBy,
        description: 'AI-generated flashcards',
      );

      // Save flashcards
      for (final preview in flashcardsToSave) {
        final flashcard = preview
            .toFlashcardModel(
              id: _uuid.v4(), // Generate proper UUID
              createdBy: createdBy,
            )
            .copyWith(
              deckId:
                  deck.id, // Use the actual deck ID (either found or newly created)
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
  Future<bool> acceptQuiz({
    required String deckId,
    required String deckName,
    String? createdBy,
  }) async {
    try {
      Logger.info(
        'Starting acceptQuiz with deckId: $deckId, deckName: $deckName',
        tag: 'AIReviewProvider',
      );
      _status = ReviewStatus.saving;
      _error = null;
      notifyListeners();

      if (_generationProvider == null) {
        Logger.error('Generation provider is null', tag: 'AIReviewProvider');
        _status = ReviewStatus.idle;
        _error = 'Generation provider not available. Please try again.';
        notifyListeners();
        return false;
      }

      final quizPreview = _generationProvider!.generatedQuiz;
      Logger.info(
        'Quiz preview: ${quizPreview != null ? "exists" : "null"}, Questions: ${quizPreview?.questions.length ?? 0}',
        tag: 'AIReviewProvider',
      );

      if (quizPreview == null || quizPreview.questions.isEmpty) {
        Logger.warning(
          'Quiz preview is null or has no questions. Preview: ${quizPreview != null}, Questions: ${quizPreview?.questions.length ?? 0}',
          tag: 'AIReviewProvider',
        );
        _status = ReviewStatus.idle;
        _error = 'No quiz to save. Please generate a quiz first.';
        notifyListeners();
        return false;
      }

      // Filter selected questions if any are selected
      Logger.info(
        'Selected question indices: $_selectedQuestionIndices, Total questions: ${quizPreview.questions.length}',
        tag: 'AIReviewProvider',
      );

      final questionsToSave =
          _selectedQuestionIndices.isEmpty
              ? quizPreview.questions
              : _selectedQuestionIndices
                  .map((i) => quizPreview.questions[i])
                  .toList();

      Logger.info(
        'Questions to save: ${questionsToSave.length}',
        tag: 'AIReviewProvider',
      );

      if (questionsToSave.isEmpty) {
        Logger.warning(
          'No questions to save after filtering',
          tag: 'AIReviewProvider',
        );
        _status = ReviewStatus.idle;
        _error = 'No questions selected to save.';
        notifyListeners();
        return false;
      }

      // Ensure deck exists
      final deck = await _getOrCreateDeck(
        deckId: deckId,
        deckName: deckName,
        createdBy: createdBy,
        description: 'AI-generated quiz deck',
      );

      // Create quiz with selected questions
      final quizId = _uuid.v4(); // Generate proper UUID
      final quizData = quizPreview.toQuizModels(
        quizId: quizId,
        createdBy: createdBy ?? '',
      );

      // Update quiz with filtered questions
      final filteredQuestions =
          questionsToSave.map((q) {
            // Generate a proper UUID for each question
            final questionId = _uuid.v4();
            return q.toQuestionModel(
              quizId: quizId,
              createdBy: createdBy,
              questionId: questionId,
            );
          }).toList();

      final quiz = quizData.quiz.copyWith(
        deckId:
            deck.id, // Use the actual deck ID (either found or newly created)
        questionIds: filteredQuestions.map((q) => q.id).toList(),
      );

      // Save quiz
      await _supabaseService.createQuiz(quiz);

      // Save questions
      for (final question in filteredQuestions) {
        await _supabaseService.createQuestion(question);
      }

      _status = ReviewStatus.completed;
      _error = null;
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
      _error = e.toString();
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

      if (_generationProvider == null) {
        _status = ReviewStatus.failed;
        _error = 'Generation provider not available.';
        notifyListeners();
        return;
      }
      await _generationProvider!.regenerateWithFeedback(_feedback!);

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
    _error = null;
    _selectedFlashcardIndices.clear();
    _selectedQuestionIndices.clear();
    notifyListeners();
  }
}

enum ReviewStatus { idle, reviewing, saving, regenerating, completed, failed }
