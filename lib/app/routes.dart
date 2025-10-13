import 'package:flutter/material.dart';

/// Route names for the application
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route names
  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String createDeck = '/create-deck';
  static const String editDeck = '/edit-deck';
  static const String deckDetails = '/deck-details';
  static const String studySession = '/study-session';
  static const String studyResults = '/study-results';
  static const String search = '/search';
  static const String statistics = '/statistics';

  /// Route generator for named routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;

    if (routeName == splash) {
      return MaterialPageRoute(
        builder: (_) => const SplashScreen(),
        settings: settings,
      );
    } else if (routeName == auth) {
      return MaterialPageRoute(
        builder: (_) => const AuthScreen(),
        settings: settings,
      );
    } else if (routeName == home) {
      return MaterialPageRoute(
        builder: (_) => const HomeScreen(),
        settings: settings,
      );
    } else if (routeName == profile) {
      return MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
        settings: settings,
      );
    } else if (routeName == settings) {
      return MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
        settings: settings,
      );
    } else if (routeName == createDeck) {
      return MaterialPageRoute(
        builder: (_) => const CreateDeckScreen(),
        settings: settings,
      );
    } else if (routeName == editDeck) {
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => EditDeckScreen(deckId: args?['deckId']),
        settings: settings,
      );
    } else if (routeName == deckDetails) {
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => DeckDetailsScreen(deckId: args?['deckId']),
        settings: settings,
      );
    } else if (routeName == studySession) {
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => StudySessionScreen(deckId: args?['deckId']),
        settings: settings,
      );
    } else if (routeName == studyResults) {
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => StudyResultsScreen(results: args?['results']),
        settings: settings,
      );
    } else if (routeName == search) {
      return MaterialPageRoute(
        builder: (_) => const SearchScreen(),
        settings: settings,
      );
    } else if (routeName == statistics) {
      return MaterialPageRoute(
        builder: (_) => const StatisticsScreen(),
        settings: settings,
      );
    } else {
      return MaterialPageRoute(
        builder: (_) => const NotFoundScreen(),
        settings: settings,
      );
    }
  }

  /// Navigation helper methods
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  static void popUntil(BuildContext context, RoutePredicate predicate) {
    Navigator.popUntil(context, predicate);
  }

  static void popToRoot(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}

// Placeholder screens - these will be implemented later
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Auth Screen')));
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Home Screen')));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Profile Screen')));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Settings Screen')));
  }
}

class CreateDeckScreen extends StatelessWidget {
  const CreateDeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Create Deck Screen')));
  }
}

class EditDeckScreen extends StatelessWidget {
  final String? deckId;

  const EditDeckScreen({super.key, this.deckId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Edit Deck Screen - Deck ID: ${deckId ?? 'Unknown'}'),
      ),
    );
  }
}

class DeckDetailsScreen extends StatelessWidget {
  final String? deckId;

  const DeckDetailsScreen({super.key, this.deckId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Deck Details Screen - Deck ID: ${deckId ?? 'Unknown'}'),
      ),
    );
  }
}

class StudySessionScreen extends StatelessWidget {
  final String? deckId;

  const StudySessionScreen({super.key, this.deckId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Study Session Screen - Deck ID: ${deckId ?? 'Unknown'}'),
      ),
    );
  }
}

class StudyResultsScreen extends StatelessWidget {
  final Map<String, dynamic>? results;

  const StudyResultsScreen({super.key, this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Study Results Screen - Results: ${results?.toString() ?? 'None'}',
        ),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Search Screen')));
  }
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Statistics Screen')));
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              'The page you are looking for does not exist.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
