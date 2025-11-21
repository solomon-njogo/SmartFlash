import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../models/flashcard_model.dart';
import '../models/deck_model.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../models/deck_attempt_model.dart';
import '../models/deck_attempt_card_result.dart';
import '../models/quiz_attempt_model.dart';
import '../models/quiz_attempt_answer_model.dart';

/// Service for managing Supabase remote database operations
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient? _client;
  SupabaseClient get client {
    // If client is null but Supabase is already initialized, use it
    if (_client == null) {
      try {
        _client = Supabase.instance.client;
        _isInitialized = true;
        Logger.info(
          'SupabaseService using already initialized Supabase instance',
        );
      } catch (e) {
        throw Exception(
          'SupabaseService not initialized. Call initialize() first.',
        );
      }
    }
    return _client!;
  }

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize Supabase client
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.info('SupabaseService already initialized');
      return;
    }

    try {
      Logger.info('Initializing Supabase...');

      // Load environment variables
      await dotenv.load();

      final supabaseUrl = ApiConstants.supabaseUrl;
      final supabaseAnonKey = ApiConstants.supabaseAnonKey;

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception(
          'Supabase URL or Anon Key not found in environment variables',
        );
      }

      // Initialize Supabase
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

      _client = Supabase.instance.client;
      _isInitialized = true;

      Logger.info('SupabaseService initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize SupabaseService: $e');
      rethrow;
    }
  }

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Get current user ID
  String? get currentUserId => currentUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      Logger.info('Signing in with Google...');

      final success = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.smartflash://login-callback/',
      );

      Logger.info('Google sign-in initiated successfully');
      return success;
    } catch (e) {
      Logger.error('Failed to sign in with Google: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      Logger.info('Signing out user');

      await client.auth.signOut();

      Logger.info('User signed out successfully');
    } catch (e) {
      Logger.error('Failed to sign out user: $e');
      rethrow;
    }
  }

  /// Create or update user profile from Google OAuth data
  Future<UserModel> createOrUpdateUserFromGoogle(User user) async {
    try {
      Logger.info('Creating/updating user from Google OAuth: ${user.id}');

      // Extract Google OAuth data
      final userMetadata = user.userMetadata ?? {};

      final userModel = UserModel.fromGoogleAuth(
        id: user.id,
        email: user.email ?? '',
        displayName: userMetadata['full_name'] as String?,
        photoUrl: userMetadata['avatar_url'] as String?,
        firstName: userMetadata['first_name'] as String?,
        lastName: userMetadata['last_name'] as String?,
        locale: userMetadata['locale'] as String?,
        preferences: userMetadata['preferences'] as Map<String, dynamic>?,
      );

      // Try to get existing user profile
      final existingProfile = await getUserProfile(user.id);

      if (existingProfile != null) {
        // Update existing profile with latest Google data
        final updatedProfile = existingProfile.copyWith(
          displayName: userModel.displayName,
          photoUrl: userModel.photoUrl,
          firstName: userModel.firstName,
          lastName: userModel.lastName,
          locale: userModel.locale,
          updatedAt: DateTime.now(),
          lastSeen: DateTime.now(),
          isOnline: true,
        );

        return await updateUserProfile(updatedProfile);
      } else {
        // Create new user profile
        return await updateUserProfile(userModel);
      }
    } catch (e) {
      Logger.error('Failed to create/update user from Google OAuth: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      Logger.info('Updating user profile: ${user.id}');

      final response =
          await client
              .from('users')
              .update(user.toJson())
              .eq('id', user.id)
              .select()
              .single();

      Logger.info('User profile updated successfully');
      return UserModel.fromJson(response);
    } catch (e) {
      Logger.error('Failed to update user profile: $e');
      rethrow;
    }
  }

  /// Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      Logger.info('Getting user profile: $userId');

      final response =
          await client.from('users').select().eq('id', userId).maybeSingle();

      if (response == null) {
        Logger.warning('User profile not found: $userId');
        return null;
      }

      Logger.info('User profile retrieved successfully');
      return UserModel.fromJson(response);
    } catch (e) {
      Logger.error('Failed to get user profile: $e');
      rethrow;
    }
  }

  /// Create a new deck
  Future<DeckModel> createDeck(DeckModel deck) async {
    try {
      Logger.info('Creating deck: ${deck.name}');

      // Only include fields that exist in the database schema
      // Note: course_id may be TEXT or UUID depending on schema migration
      // We'll include it as-is and let the database handle type conversion
      final deckData = {
        'id': deck.id,
        'name': deck.name,
        'description': deck.description,
        'created_by': deck.createdBy,
        'created_at': deck.createdAt.toIso8601String(),
        'updated_at': deck.updatedAt.toIso8601String(),
        'is_ai_generated': deck.isAIGenerated,
        // Only include course_id if it's not null
        // The database will handle type conversion if needed
        if (deck.courseId != null) 'course_id': deck.courseId,
      };

      final response =
          await client.from('decks').insert(deckData).select().single();

      Logger.info('Deck created successfully');
      return DeckModel.fromJson(response);
    } catch (e) {
      Logger.error('Failed to create deck: $e');
      rethrow;
    }
  }

  /// Update deck
  Future<DeckModel> updateDeck(DeckModel deck) async {
    try {
      Logger.info('Updating deck: ${deck.id}');

      // Only include fields that exist in the database schema
      final deckData = {
        'name': deck.name,
        'description': deck.description,
        'updated_at': deck.updatedAt.toIso8601String(),
        'is_ai_generated': deck.isAIGenerated,
        if (deck.courseId != null) 'course_id': deck.courseId,
      };

      final response =
          await client
              .from('decks')
              .update(deckData)
              .eq('id', deck.id)
              .select()
              .single();

      Logger.info('Deck updated successfully');
      return DeckModel.fromJson(response);
    } catch (e) {
      Logger.error('Failed to update deck: $e');
      rethrow;
    }
  }

  /// Get user's decks
  Future<List<DeckModel>> getUserDecks(String userId) async {
    try {
      Logger.info('Getting decks for user: $userId');

      final response = await client
          .from('decks')
          .select()
          .eq('created_by', userId)
          .order('updated_at', ascending: false);

      Logger.info('User decks retrieved successfully');
      return response
          .map<DeckModel>((json) => DeckModel.fromJson(json))
          .toList();
    } catch (e) {
      Logger.error('Failed to get user decks: $e');
      rethrow;
    }
  }

  /// Get decks for a course belonging to the current user
  /// Queries decks directly by course_id and created_by
  Future<List<DeckModel>> getCourseDecks(String courseId) async {
    try {
      Logger.info('Getting decks for course: $courseId');

      if (!isAuthenticated) {
        Logger.warning('User not authenticated, returning empty list');
        return [];
      }

      final userId = currentUserId;
      if (userId == null) {
        Logger.warning('User ID is null, returning empty list');
        return [];
      }

      final response = await client
          .from('decks')
          .select()
          .eq('course_id', courseId)
          .eq('created_by', userId)
          .order('created_at', ascending: false);

      Logger.info('Found ${response.length} decks for course $courseId (user: $userId)');
      return response
          .map<DeckModel>((json) => DeckModel.fromJson(json))
          .toList();
    } catch (e) {
      Logger.error('Failed to get course decks: $e');
      rethrow;
    }
  }

  /// Create a new flashcard
  Future<FlashcardModel> createFlashcard(FlashcardModel flashcard) async {
    try {
      Logger.info('Creating flashcard: ${flashcard.id}');

      // Use toDatabaseJson() to only include fields that exist in the database schema
      final response =
          await client
              .from('flashcards')
              .insert(flashcard.toDatabaseJson())
              .select()
              .single();

      Logger.info('Flashcard created successfully');
      // Convert snake_case from database to camelCase for model
      return FlashcardModel.fromDatabaseJson(response);
    } catch (e) {
      Logger.error('Failed to create flashcard: $e');
      rethrow;
    }
  }

  /// Update flashcard
  Future<FlashcardModel> updateFlashcard(FlashcardModel flashcard) async {
    try {
      Logger.info('Updating flashcard: ${flashcard.id}');

      // Use toDatabaseJson() to only include fields that exist in the database schema
      final response =
          await client
              .from('flashcards')
              .update(flashcard.toDatabaseJson())
              .eq('id', flashcard.id)
              .select()
              .single();

      Logger.info('Flashcard updated successfully');
      // Convert snake_case from database to camelCase for model
      return FlashcardModel.fromDatabaseJson(response);
    } catch (e) {
      Logger.error('Failed to update flashcard: $e');
      rethrow;
    }
  }

  /// Get flashcards for a deck belonging to the current user
  Future<List<FlashcardModel>> getDeckFlashcards(String deckId) async {
    try {
      Logger.info('Getting flashcards for deck: $deckId');

      if (!isAuthenticated) {
        Logger.warning('User not authenticated, returning empty list');
        return [];
      }

      final userId = currentUserId;
      if (userId == null) {
        Logger.warning('User ID is null, returning empty list');
        return [];
      }

      final response = await client
          .from('flashcards')
          .select()
          .eq('deck_id', deckId)
          .eq('created_by', userId)
          .order('created_at', ascending: true);

      Logger.info('Deck flashcards retrieved successfully (user: $userId)');
      return response
          .map<FlashcardModel>((json) => FlashcardModel.fromDatabaseJson(json))
          .toList();
    } catch (e) {
      Logger.error('Failed to get deck flashcards: $e');
      rethrow;
    }
  }

  /// Get user's flashcards
  Future<List<FlashcardModel>> getUserFlashcards(String userId) async {
    try {
      Logger.info('Getting flashcards for user: $userId');

      final response = await client
          .from('flashcards')
          .select()
          .eq('created_by', userId)
          .order('updated_at', ascending: false);

      Logger.info('User flashcards retrieved successfully');
      return response
          .map<FlashcardModel>((json) => FlashcardModel.fromDatabaseJson(json))
          .toList();
    } catch (e) {
      Logger.error('Failed to get user flashcards: $e');
      rethrow;
    }
  }

  /// Delete deck
  Future<void> deleteDeck(String deckId) async {
    try {
      Logger.info('Deleting deck: $deckId');

      await client.from('decks').delete().eq('id', deckId);

      Logger.info('Deck deleted successfully');
    } catch (e) {
      Logger.error('Failed to delete deck: $e');
      rethrow;
    }
  }

  /// Delete flashcard
  Future<void> deleteFlashcard(String flashcardId) async {
    try {
      Logger.info('Deleting flashcard: $flashcardId');

      await client.from('flashcards').delete().eq('id', flashcardId);

      Logger.info('Flashcard deleted successfully');
    } catch (e) {
      Logger.error('Failed to delete flashcard: $e');
      rethrow;
    }
  }

  /// Create a new deck attempt
  Future<DeckAttemptModel> createDeckAttempt(DeckAttemptModel attempt) async {
    try {
      Logger.info('Creating deck attempt: ${attempt.id}');

      final response =
          await client
              .from('deck_attempts')
              .insert(attempt.toDatabaseJson())
              .select()
              .single();

      Logger.info('Deck attempt created successfully');
      return DeckAttemptModel.fromDatabaseJson(response);
    } catch (e) {
      Logger.error('Failed to create deck attempt: $e');
      rethrow;
    }
  }

  /// Update deck attempt
  Future<DeckAttemptModel> updateDeckAttempt(DeckAttemptModel attempt) async {
    try {
      Logger.info('Updating deck attempt: ${attempt.id}');

      final response =
          await client
              .from('deck_attempts')
              .update(attempt.toDatabaseJson())
              .eq('id', attempt.id)
              .select()
              .single();

      Logger.info('Deck attempt updated successfully');
      return DeckAttemptModel.fromDatabaseJson(response);
    } catch (e) {
      Logger.error('Failed to update deck attempt: $e');
      rethrow;
    }
  }

  /// Get deck attempts for a user
  Future<List<DeckAttemptModel>> getUserDeckAttempts(String userId) async {
    try {
      Logger.info('Getting deck attempts for user: $userId');

      final response = await client
          .from('deck_attempts')
          .select()
          .eq('user_id', userId)
          .order('started_at', ascending: false);

      Logger.info('User deck attempts retrieved successfully');
      return response
          .map<DeckAttemptModel>(
            (json) => DeckAttemptModel.fromDatabaseJson(json),
          )
          .toList();
    } catch (e) {
      Logger.error('Failed to get user deck attempts: $e');
      rethrow;
    }
  }

  /// Get deck attempts for a specific deck
  Future<List<DeckAttemptModel>> getDeckAttempts(String deckId) async {
    try {
      Logger.info('Getting deck attempts for deck: $deckId');

      if (!isAuthenticated) {
        Logger.warning('User not authenticated, returning empty list');
        return [];
      }

      final response = await client
          .from('deck_attempts')
          .select()
          .eq('deck_id', deckId)
          .eq('user_id', currentUserId!)
          .order('started_at', ascending: false);

      Logger.info('Deck attempts retrieved successfully');
      return response
          .map<DeckAttemptModel>(
            (json) => DeckAttemptModel.fromDatabaseJson(json),
          )
          .toList();
    } catch (e) {
      Logger.error('Failed to get deck attempts: $e');
      rethrow;
    }
  }

  /// Get next attempt number for a user/deck combination
  Future<int> getNextAttemptNumber(String deckId, String userId) async {
    try {
      Logger.info(
        'Getting next attempt number for deck: $deckId, user: $userId',
      );

      final response = await client
          .from('deck_attempts')
          .select('attempt_number')
          .eq('deck_id', deckId)
          .eq('user_id', userId)
          .order('attempt_number', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        return 1;
      }

      final lastAttemptNumber = response[0]['attempt_number'] as int;
      return lastAttemptNumber + 1;
    } catch (e) {
      Logger.error('Failed to get next attempt number: $e');
      // Return 1 as default if query fails
      return 1;
    }
  }

  /// Save card result for a deck attempt
  Future<DeckAttemptCardResult> saveCardResult(
    DeckAttemptCardResult cardResult,
  ) async {
    try {
      Logger.info('Saving card result: ${cardResult.id}');

      final response =
          await client
              .from('deck_attempt_card_results')
              .insert(cardResult.toDatabaseJson())
              .select()
              .single();

      Logger.info('Card result saved successfully');
      return DeckAttemptCardResult.fromDatabaseJson(response);
    } catch (e) {
      Logger.error('Failed to save card result: $e');
      rethrow;
    }
  }

  /// Get card results for a deck attempt
  Future<List<DeckAttemptCardResult>> getAttemptCardResults(
    String attemptId,
  ) async {
    try {
      Logger.info('Getting card results for attempt: $attemptId');

      final response = await client
          .from('deck_attempt_card_results')
          .select()
          .eq('attempt_id', attemptId)
          .order('order', ascending: true);

      Logger.info('Card results retrieved successfully');
      return response
          .map<DeckAttemptCardResult>(
            (json) => DeckAttemptCardResult.fromDatabaseJson(json),
          )
          .toList();
    } catch (e) {
      Logger.error('Failed to get card results: $e');
      rethrow;
    }
  }

  /// Create a new quiz attempt
  Future<QuizAttemptModel> createQuizAttempt(QuizAttemptModel attempt) async {
    try {
      Logger.info('Creating quiz attempt: ${attempt.id}');

      final response =
          await client
              .from('quiz_attempts')
              .insert(attempt.toDatabaseJson())
              .select()
              .single();

      Logger.info('Quiz attempt created successfully');
      return QuizAttemptModel.fromDatabaseJson(response);
    } catch (e) {
      Logger.error('Failed to create quiz attempt: $e');
      rethrow;
    }
  }

  /// Update quiz attempt
  Future<QuizAttemptModel> updateQuizAttempt(QuizAttemptModel attempt) async {
    try {
      Logger.info('Updating quiz attempt: ${attempt.id}');

      final response =
          await client
              .from('quiz_attempts')
              .update(attempt.toDatabaseJson())
              .eq('id', attempt.id)
              .select()
              .single();

      Logger.info('Quiz attempt updated successfully');
      return QuizAttemptModel.fromDatabaseJson(response);
    } catch (e) {
      Logger.error('Failed to update quiz attempt: $e');
      rethrow;
    }
  }

  /// Get quiz attempts for a user
  Future<List<QuizAttemptModel>> getUserQuizAttempts(String userId) async {
    try {
      Logger.info('Getting quiz attempts for user: $userId');

      final response = await client
          .from('quiz_attempts')
          .select()
          .eq('user_id', userId)
          .order('started_at', ascending: false);

      Logger.info('User quiz attempts retrieved successfully');
      return response
          .map<QuizAttemptModel>(
            (json) => QuizAttemptModel.fromDatabaseJson(json),
          )
          .toList();
    } catch (e) {
      Logger.error('Failed to get user quiz attempts: $e');
      rethrow;
    }
  }

  /// Get quiz attempts for a quiz
  Future<List<QuizAttemptModel>> getQuizAttempts(String quizId) async {
    try {
      Logger.info('Getting quiz attempts for quiz: $quizId');

      final response = await client
          .from('quiz_attempts')
          .select()
          .eq('quiz_id', quizId)
          .order('started_at', ascending: false);

      Logger.info('Quiz attempts retrieved successfully');
      return response
          .map<QuizAttemptModel>(
            (json) => QuizAttemptModel.fromDatabaseJson(json),
          )
          .toList();
    } catch (e) {
      Logger.error('Failed to get quiz attempts: $e');
      rethrow;
    }
  }

  /// Get next quiz attempt number
  Future<int> getNextQuizAttemptNumber(String quizId, String userId) async {
    try {
      Logger.info(
        'Getting next attempt number for quiz: $quizId, user: $userId',
      );

      final response = await client
          .from('quiz_attempts')
          .select('attempt_number')
          .eq('quiz_id', quizId)
          .eq('user_id', userId)
          .order('attempt_number', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        return 1;
      }

      final lastAttemptNumber = response[0]['attempt_number'] as int;
      return lastAttemptNumber + 1;
    } catch (e) {
      Logger.error('Failed to get next quiz attempt number: $e');
      // Return 1 as default if query fails
      return 1;
    }
  }

  /// Save answer for a quiz attempt
  Future<QuizAttemptAnswerModel> saveQuizAnswer(
    QuizAttemptAnswerModel answer,
  ) async {
    try {
      Logger.info('Saving quiz answer: ${answer.id}');

      final response =
          await client
              .from('quiz_attempt_answers')
              .insert(answer.toDatabaseJson())
              .select()
              .single();

      Logger.info('Quiz answer saved successfully');
      return QuizAttemptAnswerModel.fromDatabaseJson(response);
    } catch (e) {
      Logger.error('Failed to save quiz answer: $e');
      rethrow;
    }
  }

  /// Get answers for a quiz attempt
  Future<List<QuizAttemptAnswerModel>> getAttemptAnswers(
    String attemptId,
  ) async {
    try {
      Logger.info('Getting answers for attempt: $attemptId');

      final response = await client
          .from('quiz_attempt_answers')
          .select()
          .eq('attempt_id', attemptId)
          .order('order', ascending: true);

      Logger.info('Attempt answers retrieved successfully');
      return response
          .map<QuizAttemptAnswerModel>(
            (json) => QuizAttemptAnswerModel.fromDatabaseJson(json),
          )
          .toList();
    } catch (e) {
      Logger.error('Failed to get attempt answers: $e');
      rethrow;
    }
  }

  /// Create a new quiz
  Future<QuizModel> createQuiz(QuizModel quiz) async {
    try {
      Logger.info('Creating quiz: ${quiz.id}');

      // Use toDatabaseJson() to only include fields that exist in the database schema
      final response =
          await client
              .from('quizzes')
              .insert(quiz.toDatabaseJson())
              .select()
              .single();

      Logger.info('Quiz created successfully');
      // Convert snake_case from database to camelCase for model
      return QuizModel.fromDatabaseJson(response);
    } catch (e) {
      Logger.error('Failed to create quiz: $e');
      rethrow;
    }
  }

  /// Create a new question
  Future<QuestionModel> createQuestion(QuestionModel question) async {
    try {
      Logger.info('Creating question: ${question.id}');

      // Use toDatabaseJson() to only include fields that exist in the database schema
      final response =
          await client
              .from('questions')
              .insert(question.toDatabaseJson())
              .select()
              .single();

      Logger.info('Question created successfully');
      // Convert snake_case from database to camelCase for model
      return QuestionModel.fromDatabaseJson(response);
    } catch (e) {
      Logger.error('Failed to create question: $e');
      rethrow;
    }
  }

  /// Get user's quizzes
  Future<List<QuizModel>> getUserQuizzes(String userId) async {
    try {
      Logger.info('Getting quizzes for user: $userId');

      final response = await client
          .from('quizzes')
          .select()
          .eq('created_by', userId)
          .order('updated_at', ascending: false);

      Logger.info('User quizzes retrieved successfully');
      return response
          .map<QuizModel>((json) => QuizModel.fromDatabaseJson(json))
          .toList();
    } catch (e) {
      Logger.error('Failed to get user quizzes: $e');
      rethrow;
    }
  }

  /// Get quizzes for a course belonging to the current user
  /// Queries quizzes directly by course_id and created_by
  Future<List<QuizModel>> getCourseQuizzes(String courseId) async {
    try {
      Logger.info('Getting quizzes for course: $courseId');

      if (!isAuthenticated) {
        Logger.warning('User not authenticated, returning empty list');
        return [];
      }

      final userId = currentUserId;
      if (userId == null) {
        Logger.warning('User ID is null, returning empty list');
        return [];
      }

      final response = await client
          .from('quizzes')
          .select()
          .eq('course_id', courseId)
          .eq('created_by', userId)
          .order('created_at', ascending: false);

      Logger.info('Course quizzes retrieved successfully (user: $userId)');
      return response
          .map<QuizModel>((json) => QuizModel.fromDatabaseJson(json))
          .toList();
    } catch (e) {
      Logger.error('Failed to get course quizzes: $e');
      rethrow;
    }
  }

  /// Get questions for a quiz belonging to the current user
  Future<List<QuestionModel>> getQuizQuestions(String quizId) async {
    try {
      Logger.info('Getting questions for quiz: $quizId');

      if (!isAuthenticated) {
        Logger.warning('User not authenticated, returning empty list');
        return [];
      }

      final userId = currentUserId;
      if (userId == null) {
        Logger.warning('User ID is null, returning empty list');
        return [];
      }

      // Verify the quiz belongs to the user before returning questions
      final quizCheck = await client
          .from('quizzes')
          .select('id')
          .eq('id', quizId)
          .eq('created_by', userId)
          .maybeSingle();

      if (quizCheck == null) {
        Logger.warning('Quiz $quizId does not belong to user $userId');
        return [];
      }

      final response = await client
          .from('questions')
          .select()
          .eq('quiz_id', quizId)
          .order('order', ascending: true);

      Logger.info('Quiz questions retrieved successfully (user: $userId)');
      return response
          .map<QuestionModel>((json) => QuestionModel.fromDatabaseJson(json))
          .toList();
    } catch (e) {
      Logger.error('Failed to get quiz questions: $e');
      rethrow;
    }
  }

  /// Sync local data with remote
  Future<void> syncData() async {
    try {
      Logger.info('Starting data sync...');

      if (!isAuthenticated) {
        Logger.warning('User not authenticated, skipping sync');
        return;
      }

      final userId = currentUserId!;

      // Sync user profile
      await _syncUserProfile(userId);

      // Sync decks
      await _syncDecks(userId);

      // Sync flashcards
      await _syncFlashcards(userId);

      Logger.info('Data sync completed successfully');
    } catch (e) {
      Logger.error('Failed to sync data: $e');
      rethrow;
    }
  }

  /// Sync user profile
  Future<void> _syncUserProfile(String userId) async {
    try {
      final userProfile = await getUserProfile(userId);
      if (userProfile != null) {
        // Update local storage with remote data
        // This would typically involve updating Hive storage
        Logger.info('User profile synced');
      }
    } catch (e) {
      Logger.error('Failed to sync user profile: $e');
    }
  }

  /// Sync decks
  Future<void> _syncDecks(String userId) async {
    try {
      final remoteDecks = await getUserDecks(userId);
      // Update local storage with remote data
      Logger.info('Decks synced: ${remoteDecks.length}');
    } catch (e) {
      Logger.error('Failed to sync decks: $e');
    }
  }

  /// Sync flashcards
  Future<void> _syncFlashcards(String userId) async {
    try {
      // Get all user's decks first
      final decks = await getUserDecks(userId);

      for (final deck in decks) {
        final flashcards = await getDeckFlashcards(deck.id);
        // Update local storage with remote data
        Logger.info(
          'Flashcards synced for deck ${deck.id}: ${flashcards.length}',
        );
      }
    } catch (e) {
      Logger.error('Failed to sync flashcards: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _client = null;
    _isInitialized = false;
    _instance = null;
  }
}
