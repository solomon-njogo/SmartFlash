import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import '../features/auth/views/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/other_screens.dart';

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
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: '/create-deck',
        name: 'createDeck',
        builder: (context, state) => const CreateDeckScreen(),
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

  /// Navigate to create deck
  static void goCreateDeck(BuildContext context) {
    push(context, '/create-deck');
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
