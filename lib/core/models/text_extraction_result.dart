/// Result model for text extraction operations
class TextExtractionResult {
  final String extractedText;
  final int characterCount;
  final int wordCount;
  final String extractionMethod;
  final bool success;
  final String? error;

  TextExtractionResult({
    required this.extractedText,
    required this.characterCount,
    required this.wordCount,
    required this.extractionMethod,
    required this.success,
    this.error,
  });

  /// Create a successful extraction result
  factory TextExtractionResult.success({
    required String extractedText,
    required String extractionMethod,
  }) {
    final normalizedText = _normalizeText(extractedText);
    final wordCount = _countWords(normalizedText);
    return TextExtractionResult(
      extractedText: normalizedText,
      characterCount: normalizedText.length,
      wordCount: wordCount,
      extractionMethod: extractionMethod,
      success: true,
    );
  }

  /// Create a failed extraction result
  factory TextExtractionResult.failure({
    required String error,
    required String extractionMethod,
  }) {
    return TextExtractionResult(
      extractedText: '',
      characterCount: 0,
      wordCount: 0,
      extractionMethod: extractionMethod,
      success: false,
      error: error,
    );
  }

  /// Normalize text by cleaning whitespace and line breaks
  static String _normalizeText(String text) {
    // Replace multiple whitespaces with single space
    var normalized = text.replaceAll(RegExp(r'\s+'), ' ');
    
    // Normalize line breaks (multiple newlines to double newline)
    normalized = normalized.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Trim leading and trailing whitespace
    normalized = normalized.trim();
    
    return normalized;
  }

  /// Count words in text by splitting on whitespace
  static int _countWords(String text) {
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }
}

