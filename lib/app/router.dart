import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import '../features/auth/views/auth_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/auth/views/profile_screen.dart';
import '../features/course/views/course_details_screen.dart';
import 'screens/settings_screen.dart';
import '../features/course/views/create_course_screen.dart' as feature_course;
import '../features/course/views/edit_course_screen.dart' as feature_course_edit;
import 'screens/other_screens.dart';
import '../features/materials/views/upload_materials_screen.dart';
import '../features/materials/views/material_preview_screen.dart';
import '../features/ai/views/ai_generation_screen.dart';
import '../features/ai/views/ai_content_review_screen.dart';
import '../features/deck/views/deck_details_screen.dart';
import '../features/deck/views/create_deck_screen.dart';
import '../features/deck/views/flashcard_edit_screen.dart';
import '../features/deck/views/flashcard_review_screen.dart';
import '../features/deck/views/deck_attempt_results_screen.dart';
import '../data/models/deck_attempt_model.dart';
import '../features/quiz/views/quiz_taking_screen.dart';
import '../features/quiz/views/quiz_results_screen.dart';
import '../data/models/quiz_attempt_model.dart';

/// App router configuration using GoRouter
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    // Ensure the router reevaluates redirects when auth state changes
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      // Avoid relying on Provider here because the redirect context may not have access
      // to ancestor providers depending on GoRouter's internal context.
      final isAuthenticated =
          Supabase.instance.client.auth.currentSession?.user != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplashRoute = state.matchedLocation == '/';

      // If user is not authenticated and not on auth or splash routes, redirect to auth
      if (!isAuthenticated && !isAuthRoute && !isSplashRoute) {
        return '/auth';
      }

      // If on splash, decide based on current auth state
      if (isSplashRoute) {
        return isAuthenticated ? '/home' : '/auth';
      }

      // If user is authenticated and on auth route, redirect to home
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash route
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // Main app routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: '/course-details/:courseId',
        name: 'courseDetails',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          final tabIndex = state.uri.queryParameters['tab'];
          final initialTabIndex = tabIndex != null ? int.tryParse(tabIndex) : null;
          return CourseDetailsScreen(
            courseId: courseId,
            initialTabIndex: initialTabIndex,
          );
        },
      ),

      GoRoute(
        path: '/create-course',
        name: 'createCourse',
        builder: (context, state) => const feature_course.CreateCourseScreen(),
      ),

      GoRoute(
        path: '/edit-course/:courseId',
        name: 'editCourse',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return feature_course_edit.EditCourseScreen(courseId: courseId);
        },
      ),

      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: '/create-deck',
        name: 'createDeck',
        builder: (context, state) {
          final courseId = state.uri.queryParameters['courseId'];
          return CreateDeckScreen(courseId: courseId);
        },
      ),

      GoRoute(
        path: '/edit-deck/:deckId',
        name: 'editDeck',
        builder: (context, state) {
          final deckId = state.pathParameters['deckId']!;
          return EditDeckScreen(deckId: deckId);
        },
      ),

      GoRoute(
        path: '/deck-details/:deckId',
        name: 'deckDetails',
        builder: (context, state) {
          final deckId = state.pathParameters['deckId']!;
          return DeckDetailsScreen(deckId: deckId);
        },
      ),

      GoRoute(
        path: '/flashcard-edit',
        name: 'flashcardEdit',
        builder: (context, state) {
          final deckId = state.uri.queryParameters['deckId']!;
          final flashcardId = state.uri.queryParameters['flashcardId'];
          return FlashcardEditScreen(
            deckId: deckId,
            flashcardId: flashcardId,
          );
        },
      ),

      GoRoute(
        path: '/flashcard-review',
        name: 'flashcardReview',
        builder: (context, state) {
          final deckId = state.uri.queryParameters['deckId']!;
          final flashcardId = state.uri.queryParameters['flashcardId'];
          return FlashcardReviewScreen(
            deckId: deckId,
            flashcardId: flashcardId,
          );
        },
      ),

      GoRoute(
        path: '/deck-attempt-results',
        name: 'deckAttemptResults',
        builder: (context, state) {
          final attempt = state.extra as DeckAttemptModel?;
          if (attempt == null) {
            // If no attempt provided, navigate back
            return const Scaffold(
              body: Center(child: Text('No attempt data provided')),
            );
          }
          return DeckAttemptResultsScreen(attempt: attempt);
        },
      ),

      GoRoute(
        path: '/study-session/:deckId',
        name: 'studySession',
        builder: (context, state) {
          final deckId = state.pathParameters['deckId']!;
          return StudySessionScreen(deckId: deckId);
        },
      ),

      GoRoute(
        path: '/study-results',
        name: 'studyResults',
        builder: (context, state) {
          final results = state.extra as Map<String, dynamic>?;
          return StudyResultsScreen(results: results);
        },
      ),

      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),

      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/upload-materials',
        name: 'uploadMaterials',
        builder: (context, state) {
          final queryCourseId = state.uri.queryParameters['courseId'];
          final extraCourseId = state.extra is String ? state.extra as String? : null;
          return UploadMaterialsScreen(preselectedCourseId: queryCourseId ?? extraCourseId);
        },
      ),
      GoRoute(
        path: '/material-preview/:materialId',
        name: 'materialPreview',
        builder: (context, state) {
          final materialId = state.pathParameters['materialId']!;
          return MaterialPreviewScreen(materialId: materialId);
        },
      ),
      GoRoute(
        path: '/ai-generation',
        name: 'aiGeneration',
        builder: (context, state) {
          final courseId = state.uri.queryParameters['courseId'];
          return AIGenerationScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/ai-review',
        name: 'aiReview',
        builder: (context, state) => const AIContentReviewScreen(),
      ),
      GoRoute(
        path: '/quiz-taking/:quizId',
        name: 'quizTaking',
        builder: (context, state) {
          final quizId = state.pathParameters['quizId']!;
          return QuizTakingScreen(quizId: quizId);
        },
      ),
      GoRoute(
        path: '/quiz-results',
        name: 'quizResults',
        builder: (context, state) {
          final attempt = state.extra as QuizAttemptModel?;
          if (attempt == null) {
            // If no attempt provided, navigate back
            return const Scaffold(
              body: Center(child: Text('No attempt data provided')),
            );
          }
          return QuizResultsScreen(attempt: attempt);
        },
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );

  /// Get the router instance
  static GoRouter get router => _router;
}

/// Navigation helper class for easy navigation throughout the app
class AppNavigation {
  static final GoRouter _router = AppRouter.router;

  /// Navigate to a route
  static void go(BuildContext context, String location, {Object? extra}) {
    _router.go(location, extra: extra);
  }

  /// Push a new route
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String location, {
    Object? extra,
  }) {
    return _router.push<T>(location, extra: extra);
  }

  /// Push and replace current route
  static Future<T?> pushReplacement<T extends Object?>(
    BuildContext context,
    String location, {
    Object? extra,
  }) {
    return _router.pushReplacement<T>(location, extra: extra);
  }

  /// Push and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String location, {
    Object? extra,
  }) async {
    _router.go(location, extra: extra);
    return null;
  }

  /// Pop current route
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    _router.pop<T>(result);
  }

  /// Pop until a specific route
  static void popUntil(BuildContext context, String location) {
    _router.go(location);
  }

  /// Pop to root
  static void popToRoot(BuildContext context) {
    _router.go('/');
  }

  /// Navigate to home
  static void goHome(BuildContext context) {
    go(context, '/home');
  }

  /// Navigate to auth
  static void goAuth(BuildContext context) {
    go(context, '/auth');
  }

  /// Navigate to profile
  static void goProfile(BuildContext context) {
    push(context, '/profile');
  }

  /// Navigate to settings
  static void goSettings(BuildContext context) {
    push(context, '/settings');
  }

  /// Navigate to course details
  static void goCourseDetails(
    BuildContext context,
    String courseId, {
    int? tabIndex,
  }) {
    if (tabIndex != null) {
      push(context, '/course-details/$courseId?tab=$tabIndex');
    } else {
      push(context, '/course-details/$courseId');
    }
  }

  /// Navigate to create course
  static void goCreateCourse(BuildContext context) {
    push(context, '/create-course');
  }

  /// Navigate to edit course
  static void goEditCourse(BuildContext context, String courseId) {
    push(context, '/edit-course/$courseId');
  }

  /// Navigate to create deck
  static void goCreateDeck(BuildContext context, {String? courseId}) {
    if (courseId != null) {
      push(context, '/create-deck?courseId=$courseId');
    } else {
      push(context, '/create-deck');
    }
  }

  /// Navigate to edit deck
  static void goEditDeck(BuildContext context, String deckId) {
    push(context, '/edit-deck/$deckId');
  }

  /// Navigate to deck details
  static void goDeckDetails(BuildContext context, String deckId) {
    push(context, '/deck-details/$deckId');
  }

  /// Navigate to study session
  static void goStudySession(BuildContext context, String deckId) {
    push(context, '/study-session/$deckId');
  }

  /// Navigate to quiz taking screen
  static void goQuizTaking(BuildContext context, String quizId) {
    push(context, '/quiz-taking/$quizId');
  }

  /// Navigate to quiz results screen
  static void goQuizResults(
    BuildContext context,
    QuizAttemptModel attempt,
  ) {
    push(context, '/quiz-results', extra: attempt);
  }

  /// Navigate to study results
  static void goStudyResults(
    BuildContext context,
    Map<String, dynamic> results,
  ) {
    push(context, '/study-results', extra: results);
  }

  /// Navigate to search
  static void goSearch(BuildContext context) {
    push(context, '/search');
  }

  /// Navigate to statistics
  static void goStatistics(BuildContext context) {
    push(context, '/statistics');
  }

  /// Navigate to upload materials
  static void goUploadMaterials(BuildContext context, {String? courseId}) {
    if (courseId != null) {
      push(context, '/upload-materials?courseId=$courseId');
    } else {
      push(context, '/upload-materials');
    }
  }

  /// Navigate to material preview
  static void goMaterialPreview(BuildContext context, String materialId) {
    push(context, '/material-preview/$materialId');
  }

  /// Navigate to AI generation
  static void goAIGeneration(BuildContext context, {String? courseId}) {
    if (courseId != null) {
      push(context, '/ai-generation?courseId=$courseId');
    } else {
      push(context, '/ai-generation');
    }
  }

  /// Navigate to AI review
  static void goAIReview(BuildContext context) {
    push(context, '/ai-review');
  }

  /// Navigate to flashcard edit
  static void goFlashcardEdit(
    BuildContext context, {
    required String deckId,
    String? flashcardId,
  }) {
    if (flashcardId != null) {
      push(context, '/flashcard-edit?deckId=$deckId&flashcardId=$flashcardId');
    } else {
      push(context, '/flashcard-edit?deckId=$deckId');
    }
  }

  /// Navigate to flashcard review
  static void goFlashcardReview(
    BuildContext context, {
    required String deckId,
    String? flashcardId,
  }) {
    if (flashcardId != null) {
      push(context, '/flashcard-review?deckId=$deckId&flashcardId=$flashcardId');
    } else {
      push(context, '/flashcard-review?deckId=$deckId');
    }
  }
}

/// Simple Listenable that notifies GoRouter when the provided stream emits
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
