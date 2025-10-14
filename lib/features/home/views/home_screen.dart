import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/deck_provider.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_name.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/widgets/app_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Consumer2<AuthProvider, DeckProvider>(
          builder: (context, authProvider, deckProvider, child) {
            return Stack(
              children: [
                // Main content behind
                Column(
                  children: [
                    _buildHeader(context),
                    Expanded(child: _buildMainContent(context, deckProvider)),
                  ],
                ),
                // Floating create button overlay
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 32,
                  child: _buildCreateButton(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the header with app name and user avatar
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App name with logo
          Row(
            children: [
              // App logo
              AppLogo(
                size: 32,
                borderRadius: 8,
                backgroundColor: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const AppName(variant: AppNameVariant.header),
            ],
          ),
          // User avatar
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;
              final photoUrl = user?.userMetadata?['avatar_url'] as String?;
              final userInitial =
                  user?.email?.isNotEmpty == true
                      ? user!.email![0].toUpperCase()
                      : 'U';

              return GestureDetector(
                onTap: () => AppNavigation.goProfile(context),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.primary,
                  backgroundImage:
                      photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                  child:
                      (photoUrl == null || photoUrl.isEmpty)
                          ? Text(
                            userInitial,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                          : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the main content area
  Widget _buildMainContent(BuildContext context, DeckProvider deckProvider) {
    if (deckProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (deckProvider.error != null) {
      return _buildErrorState(context, deckProvider);
    }

    return deckProvider.decks.isEmpty
        ? _buildEmptyState(context)
        : _buildDecksList(context, deckProvider);
  }

  /// Builds the error state
  Widget _buildErrorState(BuildContext context, DeckProvider deckProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error loading decks',
            style: AppTextStyles.headlineSmall.copyWith(
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            deckProvider.error!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => deckProvider.refreshDecks(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large app logo
          AppLogo(
            size: 120,
            borderRadius: 20,
            backgroundColor: colorScheme.primary,
          ),
          const SizedBox(height: 32),
          // Main heading
          Text(
            "Let's get started",
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          // Sub text
          Text(
            'Create your first notebook below.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: colorScheme.onBackground.withOpacity(0.87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecksList(BuildContext context, DeckProvider deckProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () => deckProvider.refreshDecks(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: deckProvider.decks.length,
        itemBuilder: (context, index) {
          final deck = deckProvider.decks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.library_books, color: colorScheme.primary),
              ),
              title: Text(
                deck.title,
                style: AppTextStyles.cardTitle.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                deck.description,
                style: AppTextStyles.cardSubtitle.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'study':
                      AppNavigation.goStudySession(context, deck.id);
                      break;
                    case 'edit':
                      AppNavigation.goEditDeck(context, deck.id);
                      break;
                    case 'delete':
                      _showDeleteDialog(context, deckProvider, deck);
                      break;
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'study',
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow),
                            SizedBox(width: 8),
                            Text('Study'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
              ),
              onTap: () => AppNavigation.goDeckDetails(context, deck.id),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    DeckProvider deckProvider,
    deck,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Deck'),
            content: Text('Are you sure you want to delete "${deck.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  deckProvider.deleteDeck(deck.id);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  /// Shows the create new bottom sheet
  void _showCreateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateBottomSheet(),
    );
  }

  /// Builds the create new button matching the inspiration design
  /// Appears visually floating (pill over content) with no Scaffold background
  Widget _buildCreateButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.onBackground,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x20000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => _showCreateBottomSheet(context),
          child: const SizedBox(
            height: 56,
            child: Center(child: _CreateButtonContent()),
          ),
        ),
      ),
    );
  }
}

class _CreateButtonContent extends StatelessWidget {
  const _CreateButtonContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '+',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w500,
            color: cs.background,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Create New',
          style: AppTextStyles.button.copyWith(color: cs.background),
        ),
      ],
    );
  }
}

class _CreateBottomSheet extends StatelessWidget {
  const _CreateBottomSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Create New',
              style: AppTextStyles.headlineSmall.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you\'d like to create your notebook',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Options
            _buildOption(
              context,
              icon: Icons.upload_file,
              title: 'Upload PDFs',
              subtitle: 'Upload documents to get started',
              onTap: () {
                Navigator.pop(context);
                AppNavigation.goCreateDeck(context);
              },
            ),
            const SizedBox(height: 16),
            _buildOption(
              context,
              icon: Icons.text_fields,
              title: 'Start from scratch',
              subtitle: 'Create a blank notebook',
              onTap: () {
                Navigator.pop(context);
                AppNavigation.goCreateDeck(context);
              },
            ),
            const SizedBox(height: 16),
            _buildOption(
              context,
              icon: Icons.link,
              title: 'Import from URL',
              subtitle: 'Add content from web pages',
              onTap: () {
                Navigator.pop(context);
                AppNavigation.goCreateDeck(context);
              },
            ),
            const SizedBox(height: 16),
            _buildOption(
              context,
              icon: Icons.folder_open,
              title: 'Import from Google Drive',
              subtitle: 'Connect your Google Drive',
              onTap: () {
                Navigator.pop(context);
                AppNavigation.goCreateDeck(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
