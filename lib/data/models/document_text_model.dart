/// Model for storing parsed document text
class DocumentTextModel {
  final String id;
  final String materialId;
  final String extractedText;
  final int textLength;
  final int wordCount;
  final ParsingStatus parsingStatus;
  final DateTime? parsedAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  DocumentTextModel({
    required this.id,
    required this.materialId,
    required this.extractedText,
    required this.textLength,
    required this.wordCount,
    required this.parsingStatus,
    this.parsedAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Create from JSON
  factory DocumentTextModel.fromJson(Map<String, dynamic> json) {
    return DocumentTextModel(
      id: json['id'] as String,
      materialId: json['material_id'] as String,
      extractedText: json['extracted_text'] as String,
      textLength: json['text_length'] as int,
      wordCount: (json['word_count'] as int?) ?? 0,
      parsingStatus: _parseStatus(json['parsing_status'] as String),
      parsedAt: json['parsed_at'] != null
          ? DateTime.parse(json['parsed_at'] as String)
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material_id': materialId,
      'extracted_text': extractedText,
      'text_length': textLength,
      'word_count': wordCount,
      'parsing_status': parsingStatus.name,
      'parsed_at': parsedAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  static ParsingStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ParsingStatus.pending;
      case 'completed':
        return ParsingStatus.completed;
      case 'failed':
        return ParsingStatus.failed;
      default:
        return ParsingStatus.pending;
    }
  }

  DocumentTextModel copyWith({
    String? id,
    String? materialId,
    String? extractedText,
    int? textLength,
    int? wordCount,
    ParsingStatus? parsingStatus,
    DateTime? parsedAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return DocumentTextModel(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      extractedText: extractedText ?? this.extractedText,
      textLength: textLength ?? this.textLength,
      wordCount: wordCount ?? this.wordCount,
      parsingStatus: parsingStatus ?? this.parsingStatus,
      parsedAt: parsedAt ?? this.parsedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum ParsingStatus {
  pending,
  completed,
  failed,
}

