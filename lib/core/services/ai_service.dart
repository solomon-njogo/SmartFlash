import 'dart:async';

import 'package:dio/dio.dart';
import '../constants/ai_constants.dart';
import '../utils/logger.dart';

/// Service for interacting with OpenRouter AI API
class AIService {
  AIService({
    Dio? dio,
    String? apiKey,
    String? baseUrl,
  })  : _dio = dio ?? Dio(),
        _apiKey = apiKey ?? AIConstants.openRouterApiKey,
        _baseUrl = baseUrl ?? AIConstants.openRouterBaseUrl {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
      'HTTP-Referer': 'https://smartflash.app',
      'X-Title': 'SmartFlash',
    };
    _dio.options.connectTimeout = AIConstants.generationTimeout;
    _dio.options.receiveTimeout = AIConstants.generationTimeout;
  }

  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;

  /// Generate text completion using OpenRouter API
  Future<String> generateCompletion({
    required String prompt,
    String? model,
    double? temperature,
    int? maxTokens,
    Function(String)? onStreamChunk,
  }) async {
    final modelToUse = model ?? AIConstants.defaultModel;
    final temp = temperature ?? AIConstants.defaultTemperature;
    final tokens = maxTokens ?? AIConstants.defaultMaxTokens;

    try {
      Logger.info(
        'Generating AI completion with model: $modelToUse',
        tag: 'AI',
      );

      final requestBody = {
        'model': modelToUse,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': temp,
        'max_tokens': tokens,
      };

      // Note: Streaming support can be added later if needed
      // For now, we use regular completion and simulate progress
      if (onStreamChunk != null) {
        // Simulate progress updates
        onStreamChunk('Generating...');
      }

      // Regular completion
      final response = await _dio.post(
        '/chat/completions',
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'] as String;
        Logger.info('AI completion generated successfully', tag: 'AI');
        return content;
      } else {
        throw Exception('Failed to generate completion: ${response.statusCode}');
      }
    } on DioException catch (e) {
      Logger.error(
        'DioException in AI service: ${e.message}',
        tag: 'AI',
        error: e,
      );
      if (e.response != null) {
        throw Exception(
          'AI API error: ${e.response?.data['error']?['message'] ?? e.message}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, st) {
      Logger.error(
        'Error generating AI completion: $e',
        tag: 'AI',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }


  /// Generate with retry logic
  Future<String> generateWithRetry({
    required String prompt,
    String? model,
    double? temperature,
    int? maxTokens,
    Function(String)? onStreamChunk,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < AIConstants.maxRetries) {
      try {
        return await generateCompletion(
          prompt: prompt,
          model: model,
          temperature: temperature,
          maxTokens: maxTokens,
          onStreamChunk: onStreamChunk,
        );
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;
        if (attempts < AIConstants.maxRetries) {
          Logger.warning(
            'AI generation attempt $attempts failed, retrying...',
            tag: 'AI',
          );
          await Future.delayed(AIConstants.retryDelay);
        }
      }
    }

    throw lastException ?? Exception('Failed to generate after retries');
  }
}

