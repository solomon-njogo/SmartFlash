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
    final extractionStartTime = DateTime.now();
    try {
      Logger.info('=== Starting text extraction ===', tag: 'TextExtraction');
      Logger.info(
        'Extraction parameters - FileType: ${fileType.name}, FileName: ${fileName ?? "N/A"}, Has filePath: ${filePath != null}, Has fileBytes: ${fileBytes != null}',
        tag: 'TextExtraction',
      );
      if (fileBytes != null) {
        Logger.debug(
          'File bytes size: ${fileBytes.length} bytes',
          tag: 'TextExtraction',
        );
      }
      if (filePath != null) {
        Logger.debug('File path: $filePath', tag: 'TextExtraction');
      }

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
          Logger.warning(
            'Unsupported file type for text extraction: ${fileType.name}',
            tag: 'TextExtraction',
          );
          return TextExtractionResult.failure(
            error:
                'Unsupported file type for text extraction: ${fileType.name}',
            extractionMethod: 'unsupported',
          );
      }
    } catch (e, stackTrace) {
      final extractionDuration = DateTime.now().difference(extractionStartTime);
      Logger.error(
        'Error during text extraction after ${extractionDuration.inMilliseconds}ms: $e',
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
    final pdfExtractionStartTime = DateTime.now();
    try {
      Logger.info('Extracting text from PDF file...', tag: 'TextExtraction');

      Uint8List bytes;
      if (fileBytes != null) {
        Logger.debug(
          'Using provided file bytes: ${fileBytes.length} bytes',
          tag: 'TextExtraction',
        );
        bytes = fileBytes;
      } else if (filePath != null) {
        Logger.debug(
          'Reading PDF file from path: $filePath',
          tag: 'TextExtraction',
        );
        final file = File(filePath);
        if (!await file.exists()) {
          Logger.error(
            'PDF file does not exist at path: $filePath',
            tag: 'TextExtraction',
          );
          return TextExtractionResult.failure(
            error: 'PDF file does not exist at path: $filePath',
            extractionMethod: 'pdf-text',
          );
        }
        bytes = await file.readAsBytes();
        Logger.debug(
          'Read ${bytes.length} bytes from PDF file',
          tag: 'TextExtraction',
        );
      } else {
        Logger.error(
          'Neither file path nor file bytes provided for PDF extraction',
          tag: 'TextExtraction',
        );
        return TextExtractionResult.failure(
          error: 'Either file path or file bytes must be provided',
          extractionMethod: 'pdf-text',
        );
      }

      // Use syncfusion_flutter_pdf library to extract text
      try {
        Logger.debug(
          'Opening PDF document with Syncfusion library...',
          tag: 'TextExtraction',
        );
        final PdfDocument pdfDocument = PdfDocument(inputBytes: bytes);
        final pageCount = pdfDocument.pages.count;
        Logger.info(
          'PDF document opened - Pages: $pageCount',
          tag: 'TextExtraction',
        );

        final StringBuffer textBuffer = StringBuffer();

        // Extract text from all pages
        Logger.debug(
          'Extracting text from $pageCount page(s)...',
          tag: 'TextExtraction',
        );

        // Create text extractor once for efficiency
        final textExtractor = PdfTextExtractor(pdfDocument);

        for (int i = 0; i < pageCount; i++) {
          try {
            final String pageText = textExtractor.extractText(
              startPageIndex: i,
              endPageIndex: i,
            );
            if (pageText.isNotEmpty && pageText.trim().isNotEmpty) {
              textBuffer.writeln(pageText);
              Logger.debug(
                'Page ${i + 1}/$pageCount: Extracted ${pageText.length} characters',
                tag: 'TextExtraction',
              );
            } else {
              Logger.debug(
                'Page ${i + 1}/$pageCount: No text found (empty or whitespace only)',
                tag: 'TextExtraction',
              );
            }
          } catch (e, stackTrace) {
            Logger.warning(
              'Error extracting text from page ${i + 1}: $e',
              tag: 'TextExtraction',
              error: e,
              stackTrace: stackTrace,
            );
            // Continue with next page even if one fails
          }
        }

        // Try alternative extraction method if primary method returned empty
        if (textBuffer.isEmpty && pageCount > 0) {
          Logger.debug(
            'Primary extraction method returned empty, trying alternative method...',
            tag: 'TextExtraction',
          );
          try {
            // Try extracting all pages at once
            final allText = textExtractor.extractText(
              startPageIndex: 0,
              endPageIndex: pageCount - 1,
            );
            if (allText.isNotEmpty && allText.trim().isNotEmpty) {
              textBuffer.write(allText);
              Logger.debug(
                'Alternative method extracted ${allText.length} characters',
                tag: 'TextExtraction',
              );
            }
          } catch (e) {
            Logger.debug(
              'Alternative extraction method also failed: $e',
              tag: 'TextExtraction',
            );
          }
        }

        pdfDocument.dispose();
        Logger.debug('PDF document disposed', tag: 'TextExtraction');

        final extractedText = textBuffer.toString();

        // If extraction failed or returned minimal text, return error
        if (extractedText.trim().isEmpty) {
          final pdfExtractionDuration = DateTime.now().difference(
            pdfExtractionStartTime,
          );
          Logger.warning(
            'PDF text extraction returned empty text after ${pdfExtractionDuration.inMilliseconds}ms. PDF may be image-based or encrypted.',
            tag: 'TextExtraction',
          );
          return TextExtractionResult.failure(
            error:
                'Unable to extract text from PDF. The PDF may be image-based or encrypted.',
            extractionMethod: 'syncfusion-pdf',
          );
        }

        final pdfExtractionDuration = DateTime.now().difference(
          pdfExtractionStartTime,
        );
        final wordCount =
            extractedText
                .split(RegExp(r'\s+'))
                .where((w) => w.isNotEmpty)
                .length;
        Logger.info(
          'Successfully extracted text from PDF in ${pdfExtractionDuration.inMilliseconds}ms',
          tag: 'TextExtraction',
        );
        Logger.info(
          'PDF extraction result - Characters: ${extractedText.length}, Words: $wordCount, Pages: $pageCount',
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
    final txtExtractionStartTime = DateTime.now();
    try {
      Logger.info('Extracting text from TXT file...', tag: 'TextExtraction');

      String text;
      String encodingUsed = 'unknown';
      if (fileBytes != null) {
        Logger.debug(
          'Reading TXT from bytes: ${fileBytes.length} bytes',
          tag: 'TextExtraction',
        );
        // Try UTF-8 first, fallback to latin1 if needed
        try {
          text = String.fromCharCodes(fileBytes);
          encodingUsed = 'UTF-8';
          Logger.debug(
            'Successfully decoded TXT using UTF-8',
            tag: 'TextExtraction',
          );
        } catch (e) {
          Logger.debug(
            'UTF-8 decode failed, trying fallback encoding',
            tag: 'TextExtraction',
          );
          text = String.fromCharCodes(
            fileBytes.map((byte) => byte < 128 ? byte : 63),
          );
          encodingUsed = 'latin1-fallback';
          Logger.debug(
            'Successfully decoded TXT using fallback encoding',
            tag: 'TextExtraction',
          );
        }
      } else if (filePath != null) {
        Logger.debug(
          'Reading TXT file from path: $filePath',
          tag: 'TextExtraction',
        );
        final file = File(filePath);
        if (!await file.exists()) {
          Logger.error(
            'TXT file does not exist at path: $filePath',
            tag: 'TextExtraction',
          );
          return TextExtractionResult.failure(
            error: 'TXT file does not exist at path: $filePath',
            extractionMethod: 'fs.readFile',
          );
        }
        // Try UTF-8 first, fallback to latin1
        try {
          text = await file.readAsString(encoding: const Utf8Codec());
          encodingUsed = 'UTF-8';
          Logger.debug(
            'Successfully read TXT using UTF-8',
            tag: 'TextExtraction',
          );
        } catch (e) {
          Logger.debug(
            'UTF-8 read failed, trying Latin1',
            tag: 'TextExtraction',
          );
          text = await file.readAsString(encoding: const Latin1Codec());
          encodingUsed = 'Latin1';
          Logger.debug(
            'Successfully read TXT using Latin1',
            tag: 'TextExtraction',
          );
        }
      } else {
        Logger.error(
          'Neither file path nor file bytes provided for TXT extraction',
          tag: 'TextExtraction',
        );
        return TextExtractionResult.failure(
          error: 'Either file path or file bytes must be provided',
          extractionMethod: 'fs.readFile',
        );
      }

      final txtExtractionDuration = DateTime.now().difference(
        txtExtractionStartTime,
      );
      final wordCount =
          text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      Logger.info(
        'Successfully extracted text from TXT in ${txtExtractionDuration.inMilliseconds}ms',
        tag: 'TextExtraction',
      );
      Logger.info(
        'TXT extraction result - Characters: ${text.length}, Words: $wordCount, Encoding: $encodingUsed',
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
    final docxExtractionStartTime = DateTime.now();
    try {
      Logger.info('Extracting text from DOCX file...', tag: 'TextExtraction');

      Uint8List bytes;
      if (fileBytes != null) {
        Logger.debug(
          'Using provided file bytes: ${fileBytes.length} bytes',
          tag: 'TextExtraction',
        );
        bytes = fileBytes;
      } else if (filePath != null) {
        Logger.debug(
          'Reading DOCX file from path: $filePath',
          tag: 'TextExtraction',
        );
        final file = File(filePath);
        if (!await file.exists()) {
          Logger.error(
            'DOCX file does not exist at path: $filePath',
            tag: 'TextExtraction',
          );
          return TextExtractionResult.failure(
            error: 'DOCX file does not exist at path: $filePath',
            extractionMethod: 'docx-to-text',
          );
        }
        bytes = await file.readAsBytes();
        Logger.debug(
          'Read ${bytes.length} bytes from DOCX file',
          tag: 'TextExtraction',
        );
      } else {
        Logger.error(
          'Neither file path nor file bytes provided for DOCX extraction',
          tag: 'TextExtraction',
        );
        return TextExtractionResult.failure(
          error: 'Either file path or file bytes must be provided',
          extractionMethod: 'docx-to-text',
        );
      }

      // Extract text from DOCX file
      // DOCX files are ZIP archives containing XML files
      Logger.debug(
        'Extracting text from DOCX archive (ZIP format)...',
        tag: 'TextExtraction',
      );
      final text = _extractTextFromDocx(bytes);

      if (text.isEmpty) {
        final docxExtractionDuration = DateTime.now().difference(
          docxExtractionStartTime,
        );
        Logger.warning(
          'DOCX text extraction returned empty text after ${docxExtractionDuration.inMilliseconds}ms',
          tag: 'TextExtraction',
        );
        return TextExtractionResult.failure(
          error: 'Unable to extract text from DOCX file',
          extractionMethod: 'docx-to-text',
        );
      }

      final docxExtractionDuration = DateTime.now().difference(
        docxExtractionStartTime,
      );
      final wordCount =
          text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      Logger.info(
        'Successfully extracted text from DOCX in ${docxExtractionDuration.inMilliseconds}ms',
        tag: 'TextExtraction',
      );
      Logger.info(
        'DOCX extraction result - Characters: ${text.length}, Words: $wordCount',
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
      Logger.debug('Decoding DOCX as ZIP archive...', tag: 'TextExtraction');
      // DOCX files are ZIP archives
      final archive = ZipDecoder().decodeBytes(bytes);
      Logger.debug(
        'ZIP archive decoded, files in archive: ${archive.files.length}',
        tag: 'TextExtraction',
      );

      // Find the main document.xml file
      Logger.debug(
        'Looking for word/document.xml in archive...',
        tag: 'TextExtraction',
      );
      final documentFile = archive.findFile('word/document.xml');
      if (documentFile == null) {
        Logger.error(
          'document.xml not found in DOCX archive',
          tag: 'TextExtraction',
        );
        throw Exception('document.xml not found in DOCX archive');
      }
      Logger.debug(
        'Found document.xml, size: ${documentFile.content.length} bytes',
        tag: 'TextExtraction',
      );

      // Parse the XML
      Logger.debug('Parsing XML document...', tag: 'TextExtraction');
      final xmlString = utf8.decode(documentFile.content as List<int>);
      final document = xml.XmlDocument.parse(xmlString);

      // DOCX uses namespaces - extract text from <w:t> elements
      // Search for all elements with local name 't' regardless of namespace
      Logger.debug(
        'Extracting text from XML text nodes...',
        tag: 'TextExtraction',
      );
      final StringBuffer textBuffer = StringBuffer();

      // Get all elements and filter for those with local name 't'
      // This handles both namespaced (w:t) and non-namespaced (t) elements
      final allElements = document.findAllElements('*');
      final textNodes =
          allElements.where((element) {
            final localName = element.localName;
            return localName == 't';
          }).toList();

      Logger.debug(
        'Found ${textNodes.length} text nodes (local name: t)',
        tag: 'TextExtraction',
      );

      int nonEmptyNodes = 0;
      for (final textNode in textNodes) {
        final text = textNode.innerText;
        if (text.isNotEmpty) {
          textBuffer.write(text);
          textBuffer.write(' ');
          nonEmptyNodes++;
        }
      }
      Logger.debug(
        'Extracted text from $nonEmptyNodes non-empty text nodes',
        tag: 'TextExtraction',
      );

      // If still no text found, try extracting all text from document recursively
      if (textBuffer.isEmpty) {
        Logger.debug(
          'No text found with <t> elements, trying recursive text extraction...',
          tag: 'TextExtraction',
        );
        final allText = document.innerText;
        if (allText.trim().isNotEmpty) {
          // Clean up excessive whitespace
          final cleanedText = allText
              .split(RegExp(r'\s+'))
              .where((s) => s.isNotEmpty)
              .join(' ');
          textBuffer.write(cleanedText);
          Logger.debug(
            'Extracted ${cleanedText.length} characters using recursive extraction',
            tag: 'TextExtraction',
          );
        }
      }

      final result = textBuffer.toString().trim();
      Logger.debug(
        'DOCX text extraction completed, result length: ${result.length} characters',
        tag: 'TextExtraction',
      );
      return result;
    } catch (e, stackTrace) {
      Logger.error(
        'Error extracting text from DOCX: $e',
        tag: 'TextExtraction',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to extract text from DOCX: $e');
    }
  }
}
