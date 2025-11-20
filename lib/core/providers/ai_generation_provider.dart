import 'package:flutter/foundation.dart';
import '../services/ai_flashcard_generator.dart';
import '../services/ai_quiz_generator.dart';
import '../services/ai_quality_validator.dart';
import '../../data/models/document_text_model.dart';
import '../../data/models/course_material_model.dart';
import '../../data/remote/document_text_remote.dart';
import '../utils/logger.dart';

/// Provider for managing AI content generation
class AIGenerationProvider extends ChangeNotifier {
  AIGenerationProvider({
    AIFlashcardGenerator? flashcardGenerator,
    AIQuizGenerator? quizGenerator,
    AIQualityValidator? qualityValidator,
    DocumentTextRemoteDataSource? documentTextRemote,
  })  : _flashcardGenerator = flashcardGenerator ?? AIFlashcardGenerator(),
        _quizGenerator = quizGenerator ?? AIQuizGenerator(),
        _qualityValidator = qualityValidator ?? AIQualityValidator(),
        _documentTextRemote = documentTextRemote ?? DocumentTextRemoteDataSource();

  final AIFlashcardGenerator _flashcardGenerator;
  final AIQuizGenerator _quizGenerator;
  final AIQualityValidator _qualityValidator;
  final DocumentTextRemoteDataSource _documentTextRemote;

  // State
  GenerationStatus _status = GenerationStatus.idle;
  double _progress = 0.0;
  String? _error;
  List<CourseMaterialModel> _selectedMaterials = [];
  Map<String, DocumentTextModel> _documentTexts = {};
  List<FlashcardPreview>? _generatedFlashcards;
  QuizPreview? _generatedQuiz;
  GenerationType? _generationType;
  String? _courseId;

  // Getters
  GenerationStatus get status => _status;
  double get progress => _progress;
  String? get error => _error;
  List<CourseMaterialModel> get selectedMaterials => _selectedMaterials;
  Map<String, DocumentTextModel> get documentTexts => _documentTexts;
  // Legacy getters for backward compatibility
  CourseMaterialModel? get selectedMaterial => _selectedMaterials.isNotEmpty ? _selectedMaterials.first : null;
  DocumentTextModel? get documentText {
    if (_selectedMaterials.isEmpty || _documentTexts.isEmpty) return null;
    // Return combined document text for single document case
    if (_selectedMaterials.length == 1) {
      return _documentTexts[_selectedMaterials.first.id];
    }
    // For multiple documents, return a combined model
    return _getCombinedDocumentText();
  }
  List<FlashcardPreview>? get generatedFlashcards => _generatedFlashcards;
  QuizPreview? get generatedQuiz => _generatedQuiz;
  GenerationType? get generationType => _generationType;
  String? get courseId => _courseId;
  bool get hasDocumentTextError => _selectedMaterials.isNotEmpty && 
      _selectedMaterials.any((m) => 
        _documentTexts[m.id] == null || 
        _documentTexts[m.id]?.parsingStatus != ParsingStatus.completed);

  bool get isGenerating => _status == GenerationStatus.generating;
  bool get hasGeneratedContent =>
      _generatedFlashcards != null || _generatedQuiz != null;

  /// Set the course ID for this generation session
  void setCourseId(String? courseId) {
    _courseId = courseId;
    notifyListeners();
  }

  /// Select materials for generation
  Future<void> selectMaterials(List<CourseMaterialModel> materials) async {
    try {
      _selectedMaterials = materials;
      _error = null;
      _documentTexts.clear();

      if (materials.isEmpty) {
        notifyListeners();
        return;
      }

      // Load document texts for all selected materials
      final errors = <String>[];
      for (final material in materials) {
        try {
          final docText = await _documentTextRemote.getDocumentTextByMaterialId(
            material.id,
          );

          if (docText == null) {
            errors.add('${material.name}: Document text not available. Please wait for document parsing to complete.');
          } else if (docText.parsingStatus != ParsingStatus.completed) {
            errors.add('${material.name}: Document parsing is still in progress. Please wait.');
          } else {
            _documentTexts[material.id] = docText;
          }
        } catch (e) {
          errors.add('${material.name}: Failed to load document text: $e');
        }
      }

      if (errors.isNotEmpty && _documentTexts.isEmpty) {
        _error = errors.join('\n');
      } else if (errors.isNotEmpty) {
        // Some documents loaded successfully, but some failed
        _error = 'Some documents have issues:\n${errors.join('\n')}';
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to load document texts: $e';
      notifyListeners();
    }
  }

  /// Legacy method for backward compatibility
  Future<void> selectMaterial(CourseMaterialModel material) async {
    await selectMaterials([material]);
  }

  /// Get combined document text from all selected materials
  DocumentTextModel _getCombinedDocumentText() {
    if (_selectedMaterials.isEmpty || _documentTexts.isEmpty) {
      throw StateError('No materials or document texts available');
    }

    // Combine texts from all selected materials
    final combinedText = _selectedMaterials
        .where((m) => _documentTexts[m.id] != null)
        .map((m) {
          final docText = _documentTexts[m.id]!;
          return '=== ${m.name} ===\n${docText.extractedText}';
        })
        .join('\n\n');
    
    // Create a combined document text model
    return DocumentTextModel(
      id: 'combined_${_selectedMaterials.map((m) => m.id).join('_')}',
      materialId: _selectedMaterials.map((m) => m.id).join(','),
      extractedText: combinedText,
      textLength: combinedText.length,
      wordCount: combinedText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
      parsingStatus: ParsingStatus.completed,
      parsedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {
        'combined_from': _selectedMaterials.map((m) => m.id).toList(),
        'material_names': _selectedMaterials.map((m) => m.name).toList(),
      },
    );
  }

  /// Generate flashcards
  Future<void> generateFlashcards({
    required String deckId,
    required int count,
    required String difficulty,
    required List<String> cardTypes,
  }) async {
    if (_selectedMaterials.isEmpty) {
      _error = 'Please select at least one material';
      notifyListeners();
      return;
    }

    // Check if all selected materials have valid document texts
    final validMaterials = _selectedMaterials.where((m) => 
      _documentTexts[m.id] != null && 
      _documentTexts[m.id]?.parsingStatus == ParsingStatus.completed
    ).toList();

    if (validMaterials.isEmpty) {
      _error = 'Please select materials with parsed text';
      notifyListeners();
      return;
    }

    try {
      _status = GenerationStatus.generating;
      _progress = 0.0;
      _error = null;
      _generationType = GenerationType.flashcards;
      notifyListeners();

      // Get combined document text
      final combinedDocText = validMaterials.length == 1
          ? _documentTexts[validMaterials.first.id]!
          : _getCombinedDocumentText();

      _generatedFlashcards = await _flashcardGenerator.generateFlashcards(
        documentText: combinedDocText,
        deckId: deckId,
        count: count,
        difficulty: difficulty,
        cardTypes: cardTypes,
        onProgress: (progress) {
          _progress = progress;
          notifyListeners();
        },
      );

      _status = GenerationStatus.completed;
      _progress = 1.0;
      notifyListeners();
    } catch (e, st) {
      Logger.error(
        'Error generating flashcards: $e',
        tag: 'AIGenerationProvider',
        error: e,
        stackTrace: st,
      );
      _status = GenerationStatus.failed;
      _error = 'Failed to generate flashcards: $e';
      notifyListeners();
    }
  }

  /// Generate quiz
  Future<void> generateQuiz({
    required int questionCount,
    required String difficulty,
    required List<String> questionTypes,
  }) async {
    if (_selectedMaterials.isEmpty) {
      _error = 'Please select at least one material';
      notifyListeners();
      return;
    }

    // Check if all selected materials have valid document texts
    final validMaterials = _selectedMaterials.where((m) => 
      _documentTexts[m.id] != null && 
      _documentTexts[m.id]?.parsingStatus == ParsingStatus.completed
    ).toList();

    if (validMaterials.isEmpty) {
      _error = 'Please select materials with parsed text';
      notifyListeners();
      return;
    }

    try {
      _status = GenerationStatus.generating;
      _progress = 0.0;
      _error = null;
      _generationType = GenerationType.quiz;
      notifyListeners();

      // Get combined document text
      final combinedDocText = validMaterials.length == 1
          ? _documentTexts[validMaterials.first.id]!
          : _getCombinedDocumentText();

      // Get courseId from first material (all should be from same course)
      final courseId = validMaterials.first.courseId;
      final materialIds = validMaterials.map((m) => m.id).toList();

      _generatedQuiz = await _quizGenerator.generateQuiz(
        documentText: combinedDocText,
        questionCount: questionCount,
        difficulty: difficulty,
        questionTypes: questionTypes,
        courseId: courseId,
        materialIds: materialIds,
        onProgress: (progress) {
          _progress = progress;
          notifyListeners();
        },
      );

      _status = GenerationStatus.completed;
      _progress = 1.0;
      notifyListeners();
    } catch (e, st) {
      Logger.error(
        'Error generating quiz: $e',
        tag: 'AIGenerationProvider',
        error: e,
        stackTrace: st,
      );
      _status = GenerationStatus.failed;
      _error = 'Failed to generate quiz: $e';
      notifyListeners();
    }
  }

  /// Regenerate selected questions with feedback
  Future<void> regenerateSelectedQuestions({
    required List<int> selectedIndices,
    required String feedback,
  }) async {
    if (_selectedMaterials.isEmpty) {
      _error = 'Please select at least one material';
      notifyListeners();
      return;
    }

    final validMaterials = _selectedMaterials.where((m) => 
      _documentTexts[m.id] != null && 
      _documentTexts[m.id]?.parsingStatus == ParsingStatus.completed
    ).toList();

    if (validMaterials.isEmpty) {
      _error = 'Please select materials with parsed text';
      notifyListeners();
      return;
    }

    if (_generationType != GenerationType.quiz || _generatedQuiz == null) {
      _error = 'No quiz available for regeneration';
      notifyListeners();
      return;
    }

    try {
      _status = GenerationStatus.generating;
      _progress = 0.0;
      _error = null;
      notifyListeners();

      final originalQuiz = _generatedQuiz!;
      
      // Validate indices
      if (selectedIndices.isEmpty || 
          selectedIndices.any((i) => i < 0 || i >= originalQuiz.questions.length)) {
        _error = 'Invalid question indices selected';
        _status = GenerationStatus.failed;
        notifyListeners();
        return;
      }

      // Get selected questions to extract their properties
      final selectedQuestions = selectedIndices
          .map((i) => originalQuiz.questions[i])
          .toList();

      // Extract difficulty and question types from selected questions
      // Use the most common difficulty, or default to medium
      final difficultyCounts = <String, int>{};
      for (final q in selectedQuestions) {
        final diff = q.difficulty.name;
        difficultyCounts[diff] = (difficultyCounts[diff] ?? 0) + 1;
      }
      final mostCommonDifficulty = difficultyCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      final questionTypes = selectedQuestions
          .map((q) => q.questionType.name)
          .toSet()
          .toList();

      // Get combined document text for regeneration
      final combinedDocText = validMaterials.length == 1
          ? _documentTexts[validMaterials.first.id]!
          : _getCombinedDocumentText();

      // Regenerate only the selected questions
      final regeneratedQuestions = await _quizGenerator.regenerateSelectedQuestions(
        documentText: combinedDocText,
        questionCount: selectedIndices.length,
        difficulty: mostCommonDifficulty,
        questionTypes: questionTypes,
        userFeedback: feedback,
        courseId: originalQuiz.courseId,
        materialIds: originalQuiz.materialIds,
        onProgress: (progress) {
          _progress = progress;
          notifyListeners();
        },
      );

      // Ensure we got the expected number of questions
      if (regeneratedQuestions.length != selectedIndices.length) {
        Logger.warning(
          'Expected ${selectedIndices.length} regenerated questions but got ${regeneratedQuestions.length}',
          tag: 'AIGenerationProvider',
        );
      }

      // Create updated questions list by replacing selected questions
      final updatedQuestions = List<QuestionPreview>.from(originalQuiz.questions);
      final now = DateTime.now();
      
      // Sort indices in descending order to replace from end to start
      final sortedIndices = List<int>.from(selectedIndices)..sort((a, b) => b.compareTo(a));
      
      // Replace questions at selected indices
      for (int i = 0; i < sortedIndices.length && i < regeneratedQuestions.length; i++) {
        final originalIndex = sortedIndices[i];
        final regeneratedQuestion = regeneratedQuestions[i];
        
        // Preserve the original order number and quizId
        final originalQuestion = updatedQuestions[originalIndex];
        final originalOrder = originalQuestion.order;
        
        // Create new question with preserved order and quizId, updated timestamp
        final updatedQuestion = QuestionPreview(
          quizId: originalQuestion.quizId,
          questionText: regeneratedQuestion.questionText,
          questionType: regeneratedQuestion.questionType,
          options: regeneratedQuestion.options,
          correctAnswers: regeneratedQuestion.correctAnswers,
          explanation: regeneratedQuestion.explanation,
          points: regeneratedQuestion.points,
          difficulty: regeneratedQuestion.difficulty,
          order: originalOrder,
          createdAt: originalQuestion.createdAt,
          updatedAt: now,
        );
        
        updatedQuestions[originalIndex] = updatedQuestion;
      }

      // Update the quiz with new questions
      _generatedQuiz = originalQuiz.copyWith(
        questions: updatedQuestions,
        updatedAt: now,
      );

      _status = GenerationStatus.completed;
      _progress = 1.0;
      notifyListeners();
    } catch (e, st) {
      Logger.error(
        'Error regenerating selected questions: $e',
        tag: 'AIGenerationProvider',
        error: e,
        stackTrace: st,
      );
      _status = GenerationStatus.failed;
      _error = 'Failed to regenerate selected questions: $e';
      notifyListeners();
    }
  }

  /// Regenerate with feedback
  Future<void> regenerateWithFeedback(String feedback) async {
    if (_selectedMaterials.isEmpty) {
      _error = 'Please select at least one material';
      notifyListeners();
      return;
    }

    final validMaterials = _selectedMaterials.where((m) => 
      _documentTexts[m.id] != null && 
      _documentTexts[m.id]?.parsingStatus == ParsingStatus.completed
    ).toList();

    if (validMaterials.isEmpty) {
      _error = 'Please select materials with parsed text';
      notifyListeners();
      return;
    }

    try {
      _status = GenerationStatus.generating;
      _progress = 0.0;
      _error = null;
      notifyListeners();

      // Get combined document text
      final combinedDocText = validMaterials.length == 1
          ? _documentTexts[validMaterials.first.id]!
          : _getCombinedDocumentText();

      if (_generationType == GenerationType.flashcards && _generatedFlashcards != null) {
        final deckId = _generatedFlashcards!.first.deckId;
        final count = _generatedFlashcards!.length;
        final difficulty = _generatedFlashcards!.first.difficulty.name;
        final cardTypes = _generatedFlashcards!.map((f) => f.cardType.name).toSet().toList();

        _generatedFlashcards = await _flashcardGenerator.regenerateFlashcards(
          documentText: combinedDocText,
          deckId: deckId,
          count: count,
          difficulty: difficulty,
          cardTypes: cardTypes,
          userFeedback: feedback,
          onProgress: (progress) {
            _progress = progress;
            notifyListeners();
          },
        );
      } else if (_generationType == GenerationType.quiz && _generatedQuiz != null) {
        final questionCount = _generatedQuiz!.questions.length;
        final difficulty = _generatedQuiz!.difficulty.toString();
        final questionTypes = _generatedQuiz!.questions
            .map((q) => q.questionType.name)
            .toSet()
            .toList();

        _generatedQuiz = await _quizGenerator.regenerateQuiz(
          documentText: combinedDocText,
          questionCount: questionCount,
          difficulty: difficulty,
          questionTypes: questionTypes,
          userFeedback: feedback,
          courseId: _generatedQuiz!.courseId,
          materialIds: _generatedQuiz!.materialIds,
          onProgress: (progress) {
            _progress = progress;
            notifyListeners();
          },
        );
      }

      _status = GenerationStatus.completed;
      _progress = 1.0;
      notifyListeners();
    } catch (e, st) {
      Logger.error(
        'Error regenerating with feedback: $e',
        tag: 'AIGenerationProvider',
        error: e,
        stackTrace: st,
      );
      _status = GenerationStatus.failed;
      _error = 'Failed to regenerate: $e';
      notifyListeners();
    }
  }

  /// Update quiz questions (for partial regeneration)
  void updateQuizQuestions(QuizPreview updatedQuiz) {
    _generatedQuiz = updatedQuiz;
    _status = GenerationStatus.completed;
    _progress = 1.0;
    _error = null;
    notifyListeners();
  }

  /// Clear generated content
  void clearGeneratedContent() {
    _generatedFlashcards = null;
    _generatedQuiz = null;
    _status = GenerationStatus.idle;
    _progress = 0.0;
    _error = null;
    _generationType = null;
    notifyListeners();
  }

  /// Reset provider
  void reset() {
    _selectedMaterials.clear();
    _documentTexts.clear();
    _courseId = null;
    clearGeneratedContent();
  }
}

enum GenerationStatus {
  idle,
  generating,
  completed,
  failed,
}

enum GenerationType {
  flashcards,
  quiz,
}

