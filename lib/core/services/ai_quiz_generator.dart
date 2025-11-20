import 'dart:convert';
import '../constants/ai_constants.dart';
import '../services/ai_service.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/question_model.dart';
import '../../data/models/document_text_model.dart';
import '../../data/models/flashcard_model.dart';
import '../utils/logger.dart';

/// Service for generating quizzes from document text using AI
class AIQuizGenerator {
  AIQuizGenerator({
    AIService? aiService,
  }) : _aiService = aiService ?? AIService();

  final AIService _aiService;

  /// Generate quiz from document text
  Future<QuizPreview> generateQuiz({
    required DocumentTextModel documentText,
    required String deckId,
    required int questionCount,
    required String difficulty,
    required List<String> questionTypes,
    Function(double)? onProgress,
  }) async {
    try {
      Logger.info(
        'Generating quiz with $questionCount questions from document text',
        tag: 'AIQuizGenerator',
      );

      if (onProgress != null) {
        onProgress(0.1);
      }

      // Build prompt
      final prompt = AIConstants.getQuizPrompt(
        documentText: documentText.extractedText,
        questionCount: questionCount,
        difficulty: difficulty,
        questionTypes: questionTypes,
      );

      if (onProgress != null) {
        onProgress(0.3);
      }

      // Generate with streaming for progress
      String? streamedContent = '';
      final fullResponse = await _aiService.generateWithRetry(
        prompt: prompt,
        maxTokens: AIConstants.defaultMaxTokens * 3, // More tokens for quiz
        onStreamChunk: (chunk) {
          streamedContent = (streamedContent ?? '') + chunk;
          if (onProgress != null && streamedContent != null) {
            final estimatedProgress = 0.3 + (streamedContent!.length / 15000).clamp(0.0, 0.6);
            onProgress(estimatedProgress);
          }
        },
      );

      if (onProgress != null) {
        onProgress(0.9);
      }

      // Parse JSON response
      final quiz = _parseQuizResponse(fullResponse, deckId, questionCount);

      if (onProgress != null) {
        onProgress(1.0);
      }

      Logger.info(
        'Generated quiz with ${quiz.questions.length} questions successfully',
        tag: 'AIQuizGenerator',
      );

      return quiz;
    } catch (e, st) {
      Logger.error(
        'Error generating quiz: $e',
        tag: 'AIQuizGenerator',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Regenerate quiz with user feedback
  Future<QuizPreview> regenerateQuiz({
    required DocumentTextModel documentText,
    required String deckId,
    required int questionCount,
    required String difficulty,
    required List<String> questionTypes,
    required String userFeedback,
    Function(double)? onProgress,
  }) async {
    try {
      Logger.info(
        'Regenerating quiz with user feedback',
        tag: 'AIQuizGenerator',
      );

      final originalPrompt = AIConstants.getQuizPrompt(
        documentText: documentText.extractedText,
        questionCount: questionCount,
        difficulty: difficulty,
        questionTypes: questionTypes,
      );

      final prompt = AIConstants.getRegenerationPrompt(
        originalPrompt: originalPrompt,
        userFeedback: userFeedback,
      );

      if (onProgress != null) {
        onProgress(0.2);
      }

      final fullResponse = await _aiService.generateWithRetry(
        prompt: prompt,
        maxTokens: AIConstants.defaultMaxTokens * 3,
        onStreamChunk: (chunk) {
          if (onProgress != null) {
            onProgress(0.2 + (chunk.length / 15000).clamp(0.0, 0.7));
          }
        },
      );

      if (onProgress != null) {
        onProgress(0.9);
      }

      final quiz = _parseQuizResponse(fullResponse, deckId, questionCount);

      if (onProgress != null) {
        onProgress(1.0);
      }

      return quiz;
    } catch (e, st) {
      Logger.error(
        'Error regenerating quiz: $e',
        tag: 'AIQuizGenerator',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  QuizPreview _parseQuizResponse(
    String response,
    String deckId,
    int expectedQuestionCount,
  ) {
    try {
      // Clean response
      String cleanedResponse = response.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      cleanedResponse = cleanedResponse.trim();

      final jsonData = jsonDecode(cleanedResponse) as Map<String, dynamic>;
      final now = DateTime.now();

      final quizName = jsonData['quizName'] as String? ?? 'AI Generated Quiz';
      final quizDescription = jsonData['quizDescription'] as String?;
      final questionsData = jsonData['questions'] as List;

      final questions = questionsData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value as Map<String, dynamic>;
        return QuestionPreview(
          quizId: '', // Will be set when quiz is created
          questionText: data['questionText'] as String? ?? '',
          questionType: _parseQuestionType(data['questionType'] as String? ?? 'multipleChoice'),
          options: (data['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
          correctAnswers: (data['correctAnswers'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          explanation: data['explanation'] as String?,
          points: (data['points'] as int?) ?? 1,
          difficulty: _parseDifficulty(data['difficulty'] as String? ?? 'medium'),
          order: index + 1,
          createdAt: now,
          updatedAt: now,
        );
      }).toList();

      // Extract difficulty from first question or use default
      final firstQuestionDifficulty = questions.isNotEmpty 
          ? questions.first.difficulty 
          : DifficultyLevel.medium;
      
      return QuizPreview(
        deckId: deckId,
        name: quizName,
        description: quizDescription,
        questions: questions,
        difficulty: _parseDifficultyInt(firstQuestionDifficulty.name),
        createdAt: now,
        updatedAt: now,
      );
    } catch (e, st) {
      Logger.error(
        'Error parsing quiz response: $e',
        tag: 'AIQuizGenerator',
        error: e,
        stackTrace: st,
      );
      throw Exception('Failed to parse AI response: $e');
    }
  }

  QuestionType _parseQuestionType(String type) {
    switch (type.toLowerCase()) {
      case 'truefalse':
        return QuestionType.trueFalse;
      case 'fillintheblank':
        return QuestionType.fillInTheBlank;
      case 'matching':
        return QuestionType.matching;
      case 'shortanswer':
        return QuestionType.shortAnswer;
      default:
        return QuestionType.multipleChoice;
    }
  }

  DifficultyLevel _parseDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'hard':
        return DifficultyLevel.hard;
      default:
        return DifficultyLevel.medium;
    }
  }

  int _parseDifficultyInt(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 2;
      case 'hard':
        return 4;
      case 'very easy':
        return 1;
      case 'very hard':
        return 5;
      default:
        return 3;
    }
  }
}

/// Preview model for quiz before saving
class QuizPreview {
  final String deckId;
  final String name;
  final String? description;
  final List<QuestionPreview> questions;
  final int difficulty;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuizPreview({
    required this.deckId,
    required this.name,
    this.description,
    required this.questions,
    required this.difficulty,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to QuizModel and QuestionModel list
  ({QuizModel quiz, List<QuestionModel> questions}) toQuizModels({
    required String quizId,
    required String createdBy,
  }) {
    final now = DateTime.now();
    final quiz = QuizModel(
      id: quizId,
      name: name,
      description: description,
      deckId: deckId,
      questionIds: questions.map((q) => q.id).toList(),
      status: QuizStatus.draft,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      totalQuestions: questions.length,
      totalPoints: questions.fold(0, (sum, q) => sum + q.points),
      difficulty: difficulty,
      isAIGenerated: true,
      metadata: {
        'generated_at': now.toIso8601String(),
      },
    );

    final questionModels = questions.map((q) {
      return q.toQuestionModel(
        quizId: quizId,
        createdBy: createdBy,
      );
    }).toList();

    return (quiz: quiz, questions: questionModels);
  }
}

/// Preview model for questions before saving
class QuestionPreview {
  final String id;
  final String quizId;
  final String questionText;
  final QuestionType questionType;
  final List<String> options;
  final List<String> correctAnswers;
  final String? explanation;
  final int points;
  final DifficultyLevel difficulty;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuestionPreview({
    String? id,
    required this.quizId,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.correctAnswers,
    this.explanation,
    required this.points,
    required this.difficulty,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? 'q_${DateTime.now().millisecondsSinceEpoch}_${order}';

  QuestionModel toQuestionModel({
    required String quizId,
    String? createdBy,
  }) {
    return QuestionModel(
      id: id,
      quizId: quizId,
      questionText: questionText,
      questionType: questionType,
      options: options,
      correctAnswers: correctAnswers,
      explanation: explanation,
      points: points,
      difficulty: difficulty,
      order: order,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      isAIGenerated: true,
      metadata: {
        'generated_at': DateTime.now().toIso8601String(),
      },
    );
  }
}

