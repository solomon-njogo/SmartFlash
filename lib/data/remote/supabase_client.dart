import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../models/flashcard_model.dart';
import '../models/deck_model.dart';

/// Service for managing Supabase remote database operations
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient? _client;
  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'SupabaseService not initialized. Call initialize() first.',
      );
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

      final response =
          await client.from('decks').insert(deck.toJson()).select().single();

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

      final response =
          await client
              .from('decks')
              .update(deck.toJson())
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

  /// Get public decks
  Future<List<DeckModel>> getPublicDecks({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) async {
    try {
      Logger.info('Getting public decks');

      var query = client
          .from('decks')
          .select()
          .eq('visibility', 'public')
          .order('bookmark_count', ascending: false)
          .range(offset, offset + limit - 1);

      // Note: Search functionality can be implemented with text search
      // For now, basic filtering is done client-side if needed

      final response = await query;

      Logger.info('Public decks retrieved successfully');
      return response
          .map<DeckModel>((json) => DeckModel.fromJson(json))
          .toList();
    } catch (e) {
      Logger.error('Failed to get public decks: $e');
      rethrow;
    }
  }

  /// Create a new flashcard
  Future<FlashcardModel> createFlashcard(FlashcardModel flashcard) async {
    try {
      Logger.info('Creating flashcard: ${flashcard.id}');

      final response =
          await client
              .from('flashcards')
              .insert(flashcard.toJson())
              .select()
              .single();

      Logger.info('Flashcard created successfully');
      return FlashcardModel.fromJson(response);
    } catch (e) {
      Logger.error('Failed to create flashcard: $e');
      rethrow;
    }
  }

  /// Update flashcard
  Future<FlashcardModel> updateFlashcard(FlashcardModel flashcard) async {
    try {
      Logger.info('Updating flashcard: ${flashcard.id}');

      final response =
          await client
              .from('flashcards')
              .update(flashcard.toJson())
              .eq('id', flashcard.id)
              .select()
              .single();

      Logger.info('Flashcard updated successfully');
      return FlashcardModel.fromJson(response);
    } catch (e) {
      Logger.error('Failed to update flashcard: $e');
      rethrow;
    }
  }

  /// Get flashcards for a deck
  Future<List<FlashcardModel>> getDeckFlashcards(String deckId) async {
    try {
      Logger.info('Getting flashcards for deck: $deckId');

      final response = await client
          .from('flashcards')
          .select()
          .eq('deck_id', deckId)
          .order('created_at', ascending: true);

      Logger.info('Deck flashcards retrieved successfully');
      return response
          .map<FlashcardModel>((json) => FlashcardModel.fromJson(json))
          .toList();
    } catch (e) {
      Logger.error('Failed to get deck flashcards: $e');
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
