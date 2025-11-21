import 'package:flutter/material.dart';
import '../../../app/router.dart';

/// Screen for study session - redirects to flashcard review
class StudySessionScreen extends StatelessWidget {
  final String deckId;

  const StudySessionScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    // Redirect to flashcard review screen which handles the study session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        AppNavigation.push(
          context,
          '/flashcard-review?deckId=$deckId',
        );
      }
    });

    return Scaffold(
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

