import 'package:flutter/material.dart';

/// Edit deck screen for modifying existing decks
class EditDeckScreen extends StatelessWidget {
  final String deckId;

  const EditDeckScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Deck')),
      body: Center(child: Text('Edit Deck Screen - Deck ID: $deckId')),
    );
  }
}

/// Study session screen for practicing flashcards
class StudySessionScreen extends StatelessWidget {
  final String deckId;

  const StudySessionScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Session')),
      body: Center(child: Text('Study Session Screen - Deck ID: $deckId')),
    );
  }
}

/// Study results screen for showing quiz results
class StudyResultsScreen extends StatelessWidget {
  final Map<String, dynamic>? results;

  const StudyResultsScreen({super.key, this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Results')),
      body: Center(
        child: Text(
          'Study Results Screen - Results: ${results?.toString() ?? 'None'}',
        ),
      ),
    );
  }
}

/// Search screen for finding decks and content
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Center(child: Text('Search Screen - Coming Soon')),
    );
  }
}

/// Statistics screen for viewing study progress
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: const Center(child: Text('Statistics Screen - Coming Soon')),
    );
  }
}

/// Not found screen for 404 errors
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
