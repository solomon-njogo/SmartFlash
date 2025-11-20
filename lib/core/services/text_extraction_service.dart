import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;
import '../models/text_extraction_result.dart';
import '../../data/models/course_material_model.dart';
import '../utils/logger.dart';

/// Service for extracting text from various document formats
class TextExtractionService {
  static TextExtractionService? _instance;
  static TextExtractionService get instance =>
      _instance ??= TextExtractionService._();

  TextExtractionService._();

  /// Extract text from a file based on its type
  /// Supports PDF, TXT, and DOCX files
  Future<TextExtractionResult> extractText({
    required FileType fileType,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      Logger.info(
        'Starting text extraction for file type: ${fileType.name}',
        tag: 'TextExtraction',
      );

      switch (fileType) {
        case FileType.pdf:
          return await _extractFromPdf(
            filePath: filePath,
            fileBytes: fileBytes,
          );
        case FileType.text:
          return await _extractFromTxt(
            filePath: filePath,
            fileBytes: fileBytes,
          );
        case FileType.docx:
          return await _extractFromDocx(
            filePath: filePath,
            fileBytes: fileBytes,
          );
        default:
          return TextExtractionResult.failure(
            error:
                'Unsupported file type for text extraction: ${fileType.name}',
            extractionMethod: 'unsupported',
          );
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error during text extraction: $e',
        tag: 'TextExtraction',
        error: e,
        stackTrace: stackTrace,
      );
      return TextExtractionResult.failure(
        error: 'Text extraction failed: $e',
        extractionMethod: fileType.name,
      );
    }
  }

  /// Extract text from PDF file
  Future<TextExtractionResult> _extractFromPdf({
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    try {
      Uint8List bytes;
      if (fileBytes != null) {
        bytes = fileBytes;
      } else if (filePath != null) {
        final file = File(filePath);
        if (!await file.exists()) {
          return TextExtractionResult.failure(
            error: 'PDF file does not exist at path: $filePath',
            extractionMethod: 'pdf-text',
          );
        }
        bytes = await file.readAsBytes();
      } else {
        return TextExtractionResult.failure(
          error: 'Either file path or file bytes must be provided',
          extractionMethod: 'pdf-text',
        );
      }

      // Use syncfusion_flutter_pdf library to extract text
      try {
        final PdfDocument pdfDocument = PdfDocument(inputBytes: bytes);
        final StringBuffer textBuffer = StringBuffer();

        // Extract text from all pages
        for (int i = 0; i < pdfDocument.pages.count; i++) {
          final String pageText = PdfTextExtractor(
            pdfDocument,
          ).extractText(startPageIndex: i, endPageIndex: i);
          if (pageText.isNotEmpty) {
            textBuffer.writeln(pageText);
          }
        }

        pdfDocument.dispose();

        final extractedText = textBuffer.toString();

        // If extraction failed or returned minimal text, return error
        if (extractedText.trim().isEmpty) {
          return TextExtractionResult.failure(
            error:
                'Unable to extract text from PDF. The PDF may be image-based or encrypted.',
            extractionMethod: 'syncfusion-pdf',
          );
        }

        Logger.info(
          'Successfully extracted ${extractedText.length} characters from PDF',
          tag: 'TextExtraction',
        );

        return TextExtractionResult.success(
          extractedText: extractedText,
          extractionMethod: 'syncfusion-pdf',
        );
      } catch (e, stackTrace) {
        Logger.error(
          'Error extracting text from PDF: $e',
          tag: 'TextExtraction',
          error: e,
          stackTrace: stackTrace,
        );
        return TextExtractionResult.failure(
          error: 'Failed to extract text from PDF: $e',
          extractionMethod: 'syncfusion-pdf',
        );
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error reading PDF file: $e',
        tag: 'TextExtraction',
        error: e,
        stackTrace: stackTrace,
      );
      return TextExtractionResult.failure(
        error: 'Failed to read PDF file: $e',
        extractionMethod: 'syncfusion-pdf',
      );
    }
  }

  /// Extract text from TXT file
  Future<TextExtractionResult> _extractFromTxt({
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    try {
      String text;
      if (fileBytes != null) {
        // Try UTF-8 first, fallback to latin1 if needed
        try {
          text = String.fromCharCodes(fileBytes);
        } catch (e) {
          text = String.fromCharCodes(
            fileBytes.map((byte) => byte < 128 ? byte : 63),
          );
        }
      } else if (filePath != null) {
        final file = File(filePath);
        if (!await file.exists()) {
          return TextExtractionResult.failure(
            error: 'TXT file does not exist at path: $filePath',
            extractionMethod: 'fs.readFile',
          );
        }
        // Try UTF-8 first, fallback to latin1
        try {
          text = await file.readAsString(encoding: const Utf8Codec());
        } catch (e) {
          text = await file.readAsString(encoding: const Latin1Codec());
        }
      } else {
        return TextExtractionResult.failure(
          error: 'Either file path or file bytes must be provided',
          extractionMethod: 'fs.readFile',
        );
      }

      Logger.info(
        'Successfully extracted ${text.length} characters from TXT',
        tag: 'TextExtraction',
      );

      return TextExtractionResult.success(
        extractedText: text,
        extractionMethod: 'fs.readFile',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Error extracting text from TXT: $e',
        tag: 'TextExtraction',
        error: e,
        stackTrace: stackTrace,
      );
      return TextExtractionResult.failure(
        error: 'Failed to extract text from TXT: $e',
        extractionMethod: 'fs.readFile',
      );
    }
  }

  /// Extract text from DOCX file
  Future<TextExtractionResult> _extractFromDocx({
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    try {
      Uint8List bytes;
      if (fileBytes != null) {
        bytes = fileBytes;
      } else if (filePath != null) {
        final file = File(filePath);
        if (!await file.exists()) {
          return TextExtractionResult.failure(
            error: 'DOCX file does not exist at path: $filePath',
            extractionMethod: 'docx-to-text',
          );
        }
        bytes = await file.readAsBytes();
      } else {
        return TextExtractionResult.failure(
          error: 'Either file path or file bytes must be provided',
          extractionMethod: 'docx-to-text',
        );
      }

      // Extract text from DOCX file
      // DOCX files are ZIP archives containing XML files
      final text = _extractTextFromDocx(bytes);

      if (text.isEmpty) {
        return TextExtractionResult.failure(
          error: 'Unable to extract text from DOCX file',
          extractionMethod: 'docx-to-text',
        );
      }

      Logger.info(
        'Successfully extracted ${text.length} characters from DOCX',
        tag: 'TextExtraction',
      );

      return TextExtractionResult.success(
        extractedText: text,
        extractionMethod: 'docx-to-text',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Error extracting text from DOCX: $e',
        tag: 'TextExtraction',
        error: e,
        stackTrace: stackTrace,
      );
      return TextExtractionResult.failure(
        error: 'Failed to extract text from DOCX: $e',
        extractionMethod: 'docx-to-text',
      );
    }
  }

  /// Extract text from DOCX bytes
  /// DOCX files are ZIP archives containing XML files
  String _extractTextFromDocx(Uint8List bytes) {
    try {
      // DOCX files are ZIP archives
      final archive = ZipDecoder().decodeBytes(bytes);

      // Find the main document.xml file
      final documentFile = archive.findFile('word/document.xml');
      if (documentFile == null) {
        throw Exception('document.xml not found in DOCX archive');
      }

      // Parse the XML
      final document = xml.XmlDocument.parse(
        utf8.decode(documentFile.content as List<int>),
      );

      // Extract text from all text nodes
      final StringBuffer textBuffer = StringBuffer();
      final textNodes = document.findAllElements('t');

      for (final textNode in textNodes) {
        final text = textNode.innerText;
        if (text.isNotEmpty) {
          textBuffer.write(text);
          textBuffer.write(' ');
        }
      }

      return textBuffer.toString().trim();
    } catch (e) {
      throw Exception('Failed to extract text from DOCX: $e');
    }
  }
}
