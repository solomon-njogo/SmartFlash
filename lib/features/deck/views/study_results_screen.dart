import 'package:flutter/material.dart';
import '../../../app/router.dart';
import '../../../core/widgets/error_widget.dart' as custom_error;

/// Screen for displaying study session results
class StudyResultsScreen extends StatelessWidget {
  final Map<String, dynamic>? results;

  const StudyResultsScreen({super.key, this.results});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (results == null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          title: const Text('Study Results'),
        ),
        body: Center(
          child: custom_error.EmptyStateWidget(
            title: 'No Results',
            message: 'No study results available.',
            icon: Icons.assessment_outlined,
            iconColor: colorScheme.primary,
            onAction: () {
              AppNavigation.pop(context);
            },
            actionText: 'Go Back',
          ),
        ),
      );
    }

    final correct = results!['correct'] as int? ?? 0;
    final incorrect = results!['incorrect'] as int? ?? 0;
    final total = correct + incorrect;
    final percentage = total > 0 ? (correct / total * 100).round() : 0;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Study Results'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '$percentage%',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Correct',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            'Total',
                            '$total',
                            Icons.quiz_outlined,
                          ),
                          _buildStatItem(
                            context,
                            'Correct',
                            '$correct',
                            Icons.check_circle_outline,
                            colorScheme.primary,
                          ),
                          _buildStatItem(
                            context,
                            'Incorrect',
                            '$incorrect',
                            Icons.cancel_outlined,
                            colorScheme.error,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  AppNavigation.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statColor = color ?? colorScheme.onSurface;

    return Column(
      children: [
        Icon(icon, color: statColor, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: statColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

