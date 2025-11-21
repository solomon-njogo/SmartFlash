import 'package:flutter/material.dart';
import '../../core/widgets/error_widget.dart' as custom_error;

/// Screen for displaying app statistics
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: SafeArea(
        child: Center(
          child: custom_error.EmptyStateWidget(
            title: 'Statistics',
            message: 'Statistics feature coming soon. Track your learning progress and insights here.',
            icon: Icons.analytics_outlined,
            iconColor: colorScheme.primary,
            onAction: () {
              Navigator.of(context).pop();
            },
            actionText: 'Go Back',
          ),
        ),
      ),
    );
  }
}

