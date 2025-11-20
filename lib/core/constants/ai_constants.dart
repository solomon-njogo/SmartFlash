import 'api_constants.dart';

/// AI-specific constants and configuration
class AIConstants {
  // OpenRouter API Configuration
  static String get openRouterApiKey => ApiConstants.openRouterApiKey;
  static String get openRouterBaseUrl =>
      ApiConstants.openRouterBaseUrl.isNotEmpty
          ? ApiConstants.openRouterBaseUrl
          : 'https://openrouter.ai/api/v1';

  // Default AI Model (GPT-OSS-120B via OpenRouter)
  static const String defaultModel = 'openai/gpt-oss-120b';

  // Alternative models
  static const String gpt4Turbo = 'openai/gpt-4-turbo';
  static const String gpt35Turbo = 'openai/gpt-3.5-turbo';
  static const String claude3Opus = 'anthropic/claude-3-opus';
  static const String claude3Sonnet = 'anthropic/claude-3-sonnet';

  // Generation Parameters
  static const double defaultTemperature = 0.7;
  static const int defaultMaxTokens = 2000;
  static const int defaultFlashcardCount = 10;
  static const int defaultQuizQuestionCount = 10;
  static const int maxFlashcardCount = 50;
  static const int maxQuizQuestionCount = 50;

  // Prompt Templates
  static String getFlashcardPrompt({
    required String documentText,
    required int count,
    required String difficulty,
    required List<String> cardTypes,
  }) {
    return '''You are an expert educational content creator. Generate $count high-quality flashcards from the following document text.

Document Text:
$documentText

Requirements:
- Generate exactly $count flashcards
- Difficulty level: $difficulty
- Card types to use: ${cardTypes.join(', ')}
- Each flashcard should have a clear front (question) and back (answer)
- Ensure content is accurate and educational
- Vary the complexity based on difficulty level

For each flashcard, provide:
1. Front text (question or prompt)
2. Back text (answer or explanation)
3. Card type (basic, multipleChoice, fillInTheBlank, or trueFalse)
4. Difficulty level (easy, medium, or hard)

Return the response as a JSON array with this structure:
[
  {
    "frontText": "Question or prompt",
    "backText": "Answer or explanation",
    "cardType": "basic",
    "difficulty": "medium"
  },
  ...
]

Only return the JSON array, no additional text.''';
  }

  static String getQuizPrompt({
    required String documentText,
    required int questionCount,
    required String difficulty,
    required List<String> questionTypes,
  }) {
    return '''You are an expert educational content creator. Generate $questionCount high-quality multiple choice quiz questions from the following document text.

Document Text:
$documentText

Requirements:
- Generate exactly $questionCount questions
- ALL questions must be multiple choice type
- Difficulty level: $difficulty
- Each question must have exactly 4 options (A, B, C, D)
- Only one option should be correct
- Include clear explanations for each answer
- Ensure content is accurate and educational
- Vary the complexity based on difficulty level
- Questions should test understanding, not just recall

For each question, provide:
1. Question text (clear and unambiguous)
2. Question type: "multipleChoice" (always)
3. Options: Exactly 4 options as an array
4. Correct answer: The correct option text (must match one of the options exactly)
5. Explanation: Brief explanation of why the answer is correct
6. Points: 1 (default)
7. Difficulty level: "$difficulty"

Return the response as a JSON object with this structure:
{
  "quizName": "Quiz title based on document",
  "quizDescription": "Brief description",
  "questions": [
    {
      "questionText": "Question text",
      "questionType": "multipleChoice",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctAnswers": ["Option A"],
      "explanation": "Explanation of why Option A is correct",
      "points": 1,
      "difficulty": "$difficulty"
    },
    ...
  ]
}

IMPORTANT: All questions must be multiple choice with exactly 4 options. Only return the JSON object, no additional text.''';
  }

  static String getRegenerationPrompt({
    required String originalPrompt,
    required String userFeedback,
  }) {
    return '''$originalPrompt

User Feedback for Improvement:
$userFeedback

Please regenerate the content taking into account the user's feedback. Address all concerns mentioned and improve the quality accordingly.''';
  }

  // Request Timeouts
  static const Duration generationTimeout = Duration(seconds: 60);
  static const Duration streamingTimeout = Duration(seconds: 120);

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
