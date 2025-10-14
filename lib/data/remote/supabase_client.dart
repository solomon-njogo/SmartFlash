import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/flashcard_model.dart';
import '../models/question_model.dart';
import '../models/review_log_model.dart';
import '../../core/constants/app_constants.dart';

class SupabaseClient {
  static final SupabaseClient _instance = SupabaseClient._internal();
  factory SupabaseClient() => _instance;
  SupabaseClient._internal();

  late SupabaseClient _supabase;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _supabase = Supabase.instance.client;
  }

  SupabaseClient get client => _supabase;

  // Flashcard sync methods
  Future<void> syncFlashcard(FlashcardModel flashcard) async {
    try {
      await _supabase
          .from('flashcards')
          .upsert(flashcard.toJson());
    } catch (e) {
      throw Exception('Failed to sync flashcard: $e');
    }
  }

  Future<void> syncFlashcards(List<FlashcardModel> flashcards) async {
    try {
      final jsonData = flashcards.map((f) => f.toJson()).toList();
      await _supabase
          .from('flashcards')
          .upsert(jsonData);
    } catch (e) {
      throw Exception('Failed to sync flashcards: $e');
    }
  }

  Future<List<FlashcardModel>> getFlashcards({String? userId}) async {
    try {
      var query = _supabase.from('flashcards').select();
      
      if (userId != null) {
        query = query.eq('userId', userId);
      }
      
      final response = await query;
      return (response as List)
          .map((json) => FlashcardModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get flashcards: $e');
    }
  }

  Future<void> deleteFlashcard(String id) async {
    try {
      await _supabase
          .from('flashcards')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete flashcard: $e');
    }
  }

  // Question sync methods
  Future<void> syncQuestion(QuestionModel question) async {
    try {
      await _supabase
          .from('questions')
          .upsert(question.toJson());
    } catch (e) {
      throw Exception('Failed to sync question: $e');
    }
  }

  Future<void> syncQuestions(List<QuestionModel> questions) async {
    try {
      final jsonData = questions.map((q) => q.toJson()).toList();
      await _supabase
          .from('questions')
          .upsert(jsonData);
    } catch (e) {
      throw Exception('Failed to sync questions: $e');
    }
  }

  Future<List<QuestionModel>> getQuestions({String? userId, String? quizId}) async {
    try {
      var query = _supabase.from('questions').select();
      
      if (userId != null) {
        query = query.eq('userId', userId);
      }
      
      if (quizId != null) {
        query = query.eq('quizId', quizId);
      }
      
      final response = await query;
      return (response as List)
          .map((json) => QuestionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get questions: $e');
    }
  }

  Future<void> deleteQuestion(String id) async {
    try {
      await _supabase
          .from('questions')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  // Review log sync methods
  Future<void> syncReviewLog(ReviewLog reviewLog) async {
    try {
      await _supabase
          .from('review_logs')
          .upsert(reviewLog.toJson());
    } catch (e) {
      throw Exception('Failed to sync review log: $e');
    }
  }

  Future<void> syncReviewLogs(List<ReviewLog> reviewLogs) async {
    try {
      final jsonData = reviewLogs.map((r) => r.toJson()).toList();
      await _supabase
          .from('review_logs')
          .upsert(jsonData);
    } catch (e) {
      throw Exception('Failed to sync review logs: $e');
    }
  }

  Future<List<ReviewLog>> getReviewLogs({String? userId, String? cardId}) async {
    try {
      var query = _supabase.from('review_logs').select();
      
      if (userId != null) {
        query = query.eq('userId', userId);
      }
      
      if (cardId != null) {
        query = query.eq('cardId', cardId);
      }
      
      final response = await query;
      return (response as List)
          .map((json) => ReviewLog.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get review logs: $e');
    }
  }

  Future<void> deleteReviewLog(String id) async {
    try {
      await _supabase
          .from('review_logs')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete review log: $e');
    }
  }

  // Conflict resolution methods
  Future<Map<String, dynamic>> resolveConflict(
    String table,
    String id,
    Map<String, dynamic> localData,
    Map<String, dynamic> remoteData,
  ) async {
    // Simple conflict resolution: use the most recently updated record
    final localUpdated = DateTime.parse(localData['updatedAt'] as String);
    final remoteUpdated = DateTime.parse(remoteData['updatedAt'] as String);
    
    if (localUpdated.isAfter(remoteUpdated)) {
      return localData;
    } else {
      return remoteData;
    }
  }

  // Batch sync methods
  Future<void> syncAllData({
    required List<FlashcardModel> flashcards,
    required List<QuestionModel> questions,
    required List<ReviewLog> reviewLogs,
  }) async {
    try {
      await Future.wait([
        syncFlashcards(flashcards),
        syncQuestions(questions),
        syncReviewLogs(reviewLogs),
      ]);
    } catch (e) {
      throw Exception('Failed to sync all data: $e');
    }
  }

  // Get sync status
  Future<Map<String, int>> getSyncStatus() async {
    try {
      final flashcardCount = await _supabase
          .from('flashcards')
          .select('id', const FetchOptions(count: CountOption.exact))
          .count();
      
      final questionCount = await _supabase
          .from('questions')
          .select('id', const FetchOptions(count: CountOption.exact))
          .count();
      
      final reviewLogCount = await _supabase
          .from('review_logs')
          .select('id', const FetchOptions(count: CountOption.exact))
          .count();

      return {
        'flashcards': flashcardCount,
        'questions': questionCount,
        'reviewLogs': reviewLogCount,
      };
    } catch (e) {
      throw Exception('Failed to get sync status: $e');
    }
  }
}