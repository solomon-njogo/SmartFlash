import 'dart:convert';
import '../constants/ai_constants.dart';
import '../services/ai_service.dart';
import '../../data/models/flashcard_model.dart';
import '../../data/models/document_text_model.dart';
import '../utils/logger.dart';

/// Service for generating flashcards from document text using AI
class AIFlashcardGenerator {
  AIFlashcardGenerator({
    AIService? aiService,
  }) : _aiService = aiService ?? AIService();

  final AIService _aiService;

  /// Generate flashcards from document text
  Future<List<FlashcardPreview>> generateFlashcards({
    required DocumentTextModel documentText,
    required String deckId,
    required int count,
    required String difficulty,
    required List<String> cardTypes,
    Function(double)? onProgress,
  }) async {
    try {
      Logger.info(
        'Generating $count flashcards from document text',
        tag: 'AIFlashcardGenerator',
      );

      if (onProgress != null) {
        onProgress(0.1);
      }

      // Build prompt
      final prompt = AIConstants.getFlashcardPrompt(
        documentText: documentText.extractedText,
        count: count,
        difficulty: difficulty,
        cardTypes: cardTypes,
      );

      if (onProgress != null) {
        onProgress(0.3);
      }

      // Generate with streaming for progress
      String? streamedContent = '';
      final fullResponse = await _aiService.generateWithRetry(
        prompt: prompt,
        maxTokens: AIConstants.defaultMaxTokens * 2, // More tokens for multiple flashcards
        onStreamChunk: (chunk) {
          streamedContent = (streamedContent ?? '') + chunk;
          if (onProgress != null && streamedContent != null) {
            // Estimate progress based on content length
            final estimatedProgress = 0.3 + (streamedContent!.length / 10000).clamp(0.0, 0.6);
            onProgress(estimatedProgress);
          }
        },
      );

      if (onProgress != null) {
        onProgress(0.9);
      }

      // Parse JSON response
      final flashcards = _parseFlashcardResponse(fullResponse, deckId);

      if (onProgress != null) {
        onProgress(1.0);
      }

      Logger.info(
        'Generated ${flashcards.length} flashcards successfully',
        tag: 'AIFlashcardGenerator',
      );

      return flashcards;
    } catch (e, st) {
      Logger.error(
        'Error generating flashcards: $e',
        tag: 'AIFlashcardGenerator',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Regenerate flashcards with user feedback
  Future<List<FlashcardPreview>> regenerateFlashcards({
    required DocumentTextModel documentText,
    required String deckId,
    required int count,
    required String difficulty,
    required List<String> cardTypes,
    required String userFeedback,
    Function(double)? onProgress,
  }) async {
    try {
      Logger.info(
        'Regenerating flashcards with user feedback',
        tag: 'AIFlashcardGenerator',
      );

      final originalPrompt = AIConstants.getFlashcardPrompt(
        documentText: documentText.extractedText,
        count: count,
        difficulty: difficulty,
        cardTypes: cardTypes,
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
        maxTokens: AIConstants.defaultMaxTokens * 2,
        onStreamChunk: (chunk) {
          if (onProgress != null) {
            onProgress(0.2 + (chunk.length / 10000).clamp(0.0, 0.7));
          }
        },
      );

      if (onProgress != null) {
        onProgress(0.9);
      }

      final flashcards = _parseFlashcardResponse(fullResponse, deckId);

      if (onProgress != null) {
        onProgress(1.0);
      }

      return flashcards;
    } catch (e, st) {
      Logger.error(
        'Error regenerating flashcards: $e',
        tag: 'AIFlashcardGenerator',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  List<FlashcardPreview> _parseFlashcardResponse(String response, String deckId) {
    try {
      // Clean response - remove markdown code blocks if present
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

      final jsonData = jsonDecode(cleanedResponse) as List;
      final now = DateTime.now();

      return jsonData.map((item) {
        final data = item as Map<String, dynamic>;
        return FlashcardPreview(
          deckId: deckId,
          frontText: data['frontText'] as String? ?? '',
          backText: data['backText'] as String? ?? '',
          cardType: _parseCardType(data['cardType'] as String? ?? 'basic'),
          difficulty: _parseDifficulty(data['difficulty'] as String? ?? 'medium'),
          createdAt: now,
          updatedAt: now,
        );
      }).toList();
    } catch (e, st) {
      Logger.error(
        'Error parsing flashcard response: $e',
        tag: 'AIFlashcardGenerator',
        error: e,
        stackTrace: st,
      );
      throw Exception('Failed to parse AI response: $e');
    }
  }

  CardType _parseCardType(String type) {
    switch (type.toLowerCase()) {
      case 'multiplechoice':
        return CardType.multipleChoice;
      case 'fillintheblank':
        return CardType.fillInTheBlank;
      case 'truefalse':
        return CardType.trueFalse;
      default:
        return CardType.basic;
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
}

/// Preview model for flashcards before saving
class FlashcardPreview {
  final String deckId;
  final String frontText;
  final String backText;
  final CardType cardType;
  final DifficultyLevel difficulty;
  final DateTime createdAt;
  final DateTime updatedAt;

  FlashcardPreview({
    required this.deckId,
    required this.frontText,
    required this.backText,
    required this.cardType,
    required this.difficulty,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to FlashcardModel
  FlashcardModel toFlashcardModel({
    required String id,
    String? createdBy,
  }) {
    return FlashcardModel(
      id: id,
      deckId: deckId,
      frontText: frontText,
      backText: backText,
      cardType: cardType,
      difficulty: difficulty,
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

