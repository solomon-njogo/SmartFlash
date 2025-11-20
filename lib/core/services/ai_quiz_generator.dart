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
  AIQuizGenerator({AIService? aiService})
    : _aiService = aiService ?? AIService();

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

      // Generate with retry logic for both API calls and JSON parsing
      QuizPreview? quiz;
      int parseAttempts = 0;
      const maxParseRetries = 3;
      Exception? lastParseException;

      while (parseAttempts < maxParseRetries && quiz == null) {
        try {
          // Generate with streaming for progress
          String? streamedContent = '';
          final fullResponse = await _aiService.generateWithRetry(
            prompt: prompt,
            maxTokens: AIConstants.defaultMaxTokens * 3, // More tokens for quiz
            onStreamChunk: (chunk) {
              streamedContent = (streamedContent ?? '') + chunk;
              if (onProgress != null && streamedContent != null) {
                final estimatedProgress =
                    0.3 + (streamedContent!.length / 15000).clamp(0.0, 0.6);
                onProgress(estimatedProgress);
              }
            },
          );

          if (onProgress != null) {
            onProgress(0.9);
          }

          // Parse JSON response with robust error handling
          quiz = _parseQuizResponse(fullResponse, deckId, questionCount);
          break; // Success, exit retry loop
        } catch (parseError) {
          lastParseException =
              parseError is Exception
                  ? parseError
                  : Exception(parseError.toString());
          parseAttempts++;

          if (parseAttempts < maxParseRetries) {
            Logger.warning(
              'JSON parsing attempt $parseAttempts failed, retrying generation...',
              tag: 'AIQuizGenerator',
            );
            // Wait before retrying
            await Future.delayed(Duration(seconds: 2 * parseAttempts));
            // Reset progress slightly
            if (onProgress != null) {
              onProgress(0.2);
            }
          } else {
            Logger.error(
              'Failed to parse JSON after $maxParseRetries attempts',
              tag: 'AIQuizGenerator',
            );
            rethrow;
          }
        }
      }

      if (quiz == null) {
        throw lastParseException ??
            Exception('Failed to generate valid quiz after retries');
      }

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

      // Generate with retry logic for both API calls and JSON parsing
      QuizPreview? quiz;
      int parseAttempts = 0;
      const maxParseRetries = 3;
      Exception? lastParseException;

      while (parseAttempts < maxParseRetries && quiz == null) {
        try {
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

          // Parse JSON response with robust error handling
          quiz = _parseQuizResponse(fullResponse, deckId, questionCount);
          break; // Success, exit retry loop
        } catch (parseError) {
          lastParseException =
              parseError is Exception
                  ? parseError
                  : Exception(parseError.toString());
          parseAttempts++;

          if (parseAttempts < maxParseRetries) {
            Logger.warning(
              'JSON parsing attempt $parseAttempts failed during regeneration, retrying...',
              tag: 'AIQuizGenerator',
            );
            // Wait before retrying
            await Future.delayed(Duration(seconds: 2 * parseAttempts));
            // Reset progress slightly
            if (onProgress != null) {
              onProgress(0.1);
            }
          } else {
            Logger.error(
              'Failed to parse JSON after $maxParseRetries attempts during regeneration',
              tag: 'AIQuizGenerator',
            );
            rethrow;
          }
        }
      }

      if (quiz == null) {
        throw lastParseException ??
            Exception('Failed to generate valid quiz after retries');
      }

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
      // Extract and clean JSON from response with multiple strategies
      String cleanedResponse = _extractAndCleanJson(response);

      // Try to parse the JSON with multiple strategies
      Map<String, dynamic> jsonData;
      try {
        jsonData = jsonDecode(cleanedResponse) as Map<String, dynamic>;
      } catch (parseError) {
        // Strategy 1: Try to fix common JSON issues
        Logger.warning(
          'Initial JSON parse failed, attempting to fix common issues',
          tag: 'AIQuizGenerator',
        );
        try {
          cleanedResponse = _fixCommonJsonIssues(cleanedResponse);
          jsonData = jsonDecode(cleanedResponse) as Map<String, dynamic>;
        } catch (fixError) {
          // Strategy 2: Try to extract JSON from nested code blocks or text
          Logger.warning(
            'Fixed JSON still failed, trying alternative extraction',
            tag: 'AIQuizGenerator',
          );
          try {
            cleanedResponse = _extractJsonWithRegex(response);
            jsonData = jsonDecode(cleanedResponse) as Map<String, dynamic>;
          } catch (regexError) {
            // Strategy 3: Last resort - try to find and extract just the questions array
            Logger.warning(
              'All extraction strategies failed, attempting partial recovery',
              tag: 'AIQuizGenerator',
            );
            throw parseError; // Re-throw original error for retry mechanism
          }
        }
      }
      final now = DateTime.now();

      final quizName = jsonData['quizName'] as String? ?? 'AI Generated Quiz';
      final quizDescription = jsonData['quizDescription'] as String?;
      final questionsData = jsonData['questions'] as List;

      // Validate and parse questions with error handling
      final questions = <QuestionPreview>[];
      for (int i = 0; i < questionsData.length; i++) {
        try {
          final data = questionsData[i] as Map<String, dynamic>;

          // Clean and validate question text
          String questionText = (data['questionText'] as String? ?? '').trim();
          if (questionText.isEmpty) {
            Logger.warning(
              'Skipping question ${i + 1}: empty question text',
              tag: 'AIQuizGenerator',
            );
            continue;
          }

          // Clean question text from markdown
          questionText = _cleanMarkdown(questionText);

          // Parse options with validation
          final rawOptions = data['options'] as List?;
          final options = <String>[];
          if (rawOptions != null && rawOptions.isNotEmpty) {
            for (final opt in rawOptions) {
              final optStr = opt.toString().trim();
              if (optStr.isNotEmpty) {
                options.add(_cleanMarkdown(optStr));
              }
            }
          }

          // Ensure we have at least 2 options for multiple choice
          if (options.length < 2) {
            Logger.warning(
              'Question ${i + 1} has less than 2 options, skipping',
              tag: 'AIQuizGenerator',
            );
            continue;
          }

          // Parse correct answers
          final rawCorrectAnswers = data['correctAnswers'] as List?;
          final correctAnswers = <String>[];
          if (rawCorrectAnswers != null) {
            for (final ans in rawCorrectAnswers) {
              final ansStr = ans.toString().trim();
              if (ansStr.isNotEmpty) {
                correctAnswers.add(_cleanMarkdown(ansStr));
              }
            }
          }

          // Validate that at least one correct answer exists
          if (correctAnswers.isEmpty) {
            Logger.warning(
              'Question ${i + 1} has no correct answers, using first option as default',
              tag: 'AIQuizGenerator',
            );
            if (options.isNotEmpty) {
              correctAnswers.add(options.first);
            } else {
              continue; // Skip if no options either
            }
          }

          // Clean explanation
          String? explanation = data['explanation'] as String?;
          if (explanation != null) {
            explanation = _cleanMarkdown(explanation.trim());
            if (explanation.isEmpty) {
              explanation = null;
            }
          }

          questions.add(
            QuestionPreview(
              quizId: '', // Will be set when quiz is created
              questionText: questionText,
              questionType: _parseQuestionType(
                data['questionType'] as String? ?? 'multipleChoice',
              ),
              options: options,
              correctAnswers: correctAnswers,
              explanation: explanation,
              points: (data['points'] as int?) ?? 1,
              difficulty: _parseDifficulty(
                data['difficulty'] as String? ?? 'medium',
              ),
              order: questions.length + 1,
              createdAt: now,
              updatedAt: now,
            ),
          );
        } catch (e) {
          Logger.warning(
            'Error parsing question ${i + 1}: $e. Skipping this question.',
            tag: 'AIQuizGenerator',
          );
          // Continue with next question instead of failing completely
          continue;
        }
      }

      // Validate we have at least some questions
      if (questions.isEmpty) {
        throw Exception(
          'No valid questions could be parsed from the AI response. '
          'Expected $expectedQuestionCount questions but got 0 after parsing.',
        );
      }

      Logger.info(
        'Successfully parsed ${questions.length} questions from AI response (expected $expectedQuestionCount)',
        tag: 'AIQuizGenerator',
      );

      // Extract difficulty from first question or use default
      final firstQuestionDifficulty =
          questions.isNotEmpty
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

  /// Extract and clean JSON from AI response with multiple strategies
  String _extractAndCleanJson(String response) {
    String cleaned = response.trim();

    // Strategy 1: Remove markdown code blocks
    // Handle ```json ... ``` or ``` ... ```
    final codeBlockPattern = RegExp(
      r'```(?:json)?\s*\n?(.*?)\n?```',
      dotAll: true,
    );
    final codeBlockMatch = codeBlockPattern.firstMatch(cleaned);
    if (codeBlockMatch != null) {
      cleaned = codeBlockMatch.group(1) ?? cleaned;
    }

    // Strategy 2: Find JSON object boundaries
    // Look for first { and last }
    final firstBrace = cleaned.indexOf('{');
    final lastBrace = cleaned.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      cleaned = cleaned.substring(firstBrace, lastBrace + 1);
    }

    // Strategy 3: Remove leading/trailing non-JSON content
    cleaned = cleaned.trim();

    // Remove any leading text before first {
    final firstBraceIndex = cleaned.indexOf('{');
    if (firstBraceIndex > 0) {
      cleaned = cleaned.substring(firstBraceIndex);
    }

    // Remove any trailing text after last }
    final lastBraceIndex = cleaned.lastIndexOf('}');
    if (lastBraceIndex != -1 && lastBraceIndex < cleaned.length - 1) {
      cleaned = cleaned.substring(0, lastBraceIndex + 1);
    }

    return cleaned.trim();
  }

  /// Extract JSON using regex patterns as fallback
  String _extractJsonWithRegex(String response) {
    // Try to find JSON object using balanced braces
    final jsonPattern = RegExp(
      r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}',
      dotAll: true,
    );
    final matches = jsonPattern.allMatches(response);

    if (matches.isNotEmpty) {
      // Find the longest match (most likely to be the full JSON)
      String longestMatch = '';
      for (final match in matches) {
        if (match.group(0) != null &&
            match.group(0)!.length > longestMatch.length) {
          longestMatch = match.group(0)!;
        }
      }

      if (longestMatch.isNotEmpty) {
        return longestMatch.trim();
      }
    }

    // If no match found, return original response for further processing
    return response;
  }

  /// Fix common JSON issues in AI responses
  String _fixCommonJsonIssues(String jsonString) {
    String fixed = jsonString;

    // Fix 1: Remove markdown bold/italic markers (**text**, *text*)
    fixed = fixed.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    fixed = fixed.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');

    // Fix 2: Remove control characters that might break JSON
    fixed = fixed.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ');

    // Fix 3: Fix common escape sequence issues
    // Replace smart quotes with regular quotes
    fixed = fixed.replaceAll('"', '"').replaceAll('"', '"');
    fixed = fixed.replaceAll(''', "'").replaceAll(''', "'");

    // Fix 4: Remove trailing commas before closing braces/brackets
    fixed = fixed.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');

    // Fix 5: Remove any remaining markdown formatting
    fixed = fixed.replaceAll(RegExp(r'#{1,6}\s+'), ''); // Headers
    fixed = fixed.replaceAll(RegExp(r'`([^`]+)`'), r'$1'); // Inline code

    // Fix 6: Fix unescaped newlines in string values (conservative approach)
    try {
      // Use a more careful approach - find string boundaries and fix content
      final buffer = StringBuffer();
      bool inString = false;
      bool escaped = false;

      for (int i = 0; i < fixed.length; i++) {
        final char = fixed[i];

        if (escaped) {
          buffer.write(char);
          escaped = false;
          continue;
        }

        if (char == '\\') {
          escaped = true;
          buffer.write(char);
          continue;
        }

        if (char == '"') {
          inString = !inString;
          buffer.write(char);
          continue;
        }

        if (inString) {
          // Inside a string - escape problematic characters
          if (char == '\n') {
            buffer.write('\\n');
          } else if (char == '\r') {
            buffer.write('\\r');
          } else if (char == '\t') {
            buffer.write('\\t');
          } else {
            buffer.write(char);
          }
        } else {
          buffer.write(char);
        }
      }

      fixed = buffer.toString();
    } catch (e) {
      // If string fixing fails, continue with original
      Logger.warning(
        'Error fixing string escapes, using original: $e',
        tag: 'AIQuizGenerator',
      );
    }

    return fixed.trim();
  }

  /// Clean markdown formatting from text
  String _cleanMarkdown(String text) {
    if (text.isEmpty) return text;

    // Remove markdown bold/italic
    text = text.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    text = text.replaceAll(RegExp(r'__([^_]+)__'), r'$1');
    text = text.replaceAll(RegExp(r'_([^_]+)_'), r'$1');

    // Remove markdown code blocks
    text = text.replaceAll(RegExp(r'`([^`]+)`'), r'$1');

    // Remove markdown headers
    text = text.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

    // Remove markdown links but keep text
    text = text.replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1');

    // Clean up extra whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
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
    final quiz = QuizModel(
      id: quizId,
      name: name,
      description: description,
      deckId: deckId,
      questionIds: questions.map((q) => q.id).toList(),
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isAIGenerated: true,
    );

    final questionModels =
        questions.map((q) {
          return q.toQuestionModel(quizId: quizId, createdBy: createdBy);
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
  }) : id = id ?? 'q_${DateTime.now().millisecondsSinceEpoch}_$order';

  QuestionModel toQuestionModel({
    required String quizId,
    String? createdBy,
    String? questionId,
  }) {
    return QuestionModel(
      id: questionId ?? id, // Use provided UUID or fallback to existing id
      quizId: quizId,
      questionText: questionText,
      questionType: questionType,
      options: options,
      correctAnswers: correctAnswers,
      explanation: explanation,
      order: order,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      isAIGenerated: true,
    );
  }
}
