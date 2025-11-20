/// Service for validating AI-generated content quality
class AIQualityValidator {
  /// Validate flashcard quality
  QualityScore validateFlashcard({
    required String frontText,
    required String backText,
    required String cardType,
  }) {
    double score = 0.0;
    final issues = <String>[];

    // Check front text
    if (frontText.isEmpty || frontText.trim().length < 3) {
      issues.add('Front text is too short or empty');
      score -= 0.3;
    } else if (frontText.length > 500) {
      issues.add('Front text is too long');
      score -= 0.1;
    } else {
      score += 0.2;
    }

    // Check back text
    if (backText.isEmpty || backText.trim().length < 3) {
      issues.add('Back text is too short or empty');
      score -= 0.3;
    } else if (backText.length > 1000) {
      issues.add('Back text is too long');
      score -= 0.1;
    } else {
      score += 0.2;
    }

    // Check content quality
    if (frontText.toLowerCase() == backText.toLowerCase()) {
      issues.add('Front and back text are identical');
      score -= 0.2;
    }

    // Check for meaningful content
    if (frontText.split(' ').length < 3) {
      issues.add('Front text lacks detail');
      score -= 0.1;
    }

    if (backText.split(' ').length < 3) {
      issues.add('Back text lacks detail');
      score -= 0.1;
    }

    // Normalize score to 0-1 range
    score = (score + 1.0) / 2.0;
    score = score.clamp(0.0, 1.0);

    return QualityScore(
      score: score,
      issues: issues,
      isValid: score >= 0.6,
    );
  }

  /// Validate question quality
  QualityScore validateQuestion({
    required String questionText,
    required List<String> options,
    required List<String> correctAnswers,
    required String questionType,
  }) {
    double score = 0.0;
    final issues = <String>[];

    // Check question text
    if (questionText.isEmpty || questionText.trim().length < 5) {
      issues.add('Question text is too short or empty');
      score -= 0.3;
    } else {
      score += 0.2;
    }

    // Check options for multiple choice
    if (questionType == 'multipleChoice') {
      if (options.length < 2) {
        issues.add('Multiple choice questions need at least 2 options');
        score -= 0.3;
      } else if (options.length < 4) {
        issues.add('Multiple choice questions should have 4 options');
        score -= 0.1;
      } else {
        score += 0.2;
      }

      // Check for duplicate options
      if (options.toSet().length != options.length) {
        issues.add('Duplicate options found');
        score -= 0.1;
      }
    }

    // Check correct answers
    if (correctAnswers.isEmpty) {
      issues.add('No correct answers provided');
      score -= 0.3;
    } else {
      score += 0.2;
    }

    // Check if correct answers are in options (for multiple choice)
    if (questionType == 'multipleChoice') {
      final correctInOptions = correctAnswers.every(
        (answer) => options.any((opt) => opt.toLowerCase().contains(answer.toLowerCase())),
      );
      if (!correctInOptions) {
        issues.add('Correct answers not found in options');
        score -= 0.2;
      }
    }

    // Normalize score
    score = (score + 1.0) / 2.0;
    score = score.clamp(0.0, 1.0);

    return QualityScore(
      score: score,
      issues: issues,
      isValid: score >= 0.6,
    );
  }

  /// Validate batch of flashcards
  BatchQualityScore validateFlashcards(List<Map<String, dynamic>> flashcards) {
    final scores = flashcards.map((card) {
      return validateFlashcard(
        frontText: card['frontText'] as String? ?? '',
        backText: card['backText'] as String? ?? '',
        cardType: card['cardType'] as String? ?? 'basic',
      );
    }).toList();

    final averageScore = scores.map((s) => s.score).reduce((a, b) => a + b) / scores.length;
    final validCount = scores.where((s) => s.isValid).length;
    final allIssues = scores.expand((s) => s.issues).toList();

    return BatchQualityScore(
      averageScore: averageScore,
      validCount: validCount,
      totalCount: flashcards.length,
      issues: allIssues,
      isValid: averageScore >= 0.7 && validCount >= flashcards.length * 0.8,
    );
  }

  /// Validate batch of questions
  BatchQualityScore validateQuestions(List<Map<String, dynamic>> questions) {
    final scores = questions.map((q) {
      return validateQuestion(
        questionText: q['questionText'] as String? ?? '',
        options: (q['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
        correctAnswers: (q['correctAnswers'] as List?)?.map((e) => e.toString()).toList() ?? [],
        questionType: q['questionType'] as String? ?? 'multipleChoice',
      );
    }).toList();

    final averageScore = scores.map((s) => s.score).reduce((a, b) => a + b) / scores.length;
    final validCount = scores.where((s) => s.isValid).length;
    final allIssues = scores.expand((s) => s.issues).toList();

    return BatchQualityScore(
      averageScore: averageScore,
      validCount: validCount,
      totalCount: questions.length,
      issues: allIssues,
      isValid: averageScore >= 0.7 && validCount >= questions.length * 0.8,
    );
  }
}

/// Quality score for individual items
class QualityScore {
  final double score; // 0.0 to 1.0
  final List<String> issues;
  final bool isValid;

  QualityScore({
    required this.score,
    required this.issues,
    required this.isValid,
  });

  String get scoreLabel {
    if (score >= 0.9) return 'Excellent';
    if (score >= 0.7) return 'Good';
    if (score >= 0.5) return 'Fair';
    return 'Poor';
  }
}

/// Quality score for batch of items
class BatchQualityScore {
  final double averageScore;
  final int validCount;
  final int totalCount;
  final List<String> issues;
  final bool isValid;

  BatchQualityScore({
    required this.averageScore,
    required this.validCount,
    required this.totalCount,
    required this.issues,
    required this.isValid,
  });

  double get validPercentage => (validCount / totalCount) * 100;
}

