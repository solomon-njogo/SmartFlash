import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/providers/deck_provider.dart';
import '../router.dart';
import '../theme/app_name.dart';

/// Home screen showing user's decks and quick actions
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppName(variant: AppNameVariant.appBar),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => AppNavigation.goSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => AppNavigation.goProfile(context),
          ),
        ],
      ),
      body: Consumer2<AuthProvider, DeckProvider>(
        builder: (context, authProvider, deckProvider, child) {
          if (deckProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (deckProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading decks',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deckProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
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

          return RefreshIndicator(
            onRefresh: () => deckProvider.refreshDecks(),
            child:
                deckProvider.decks.isEmpty
                    ? _buildEmptyState(context)
                    : _buildDecksList(context, deckProvider),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppNavigation.goCreateDeck(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: Theme.of(
              context,
            ).textTheme.bodyLarge?.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No decks yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first flashcard deck to get started',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => AppNavigation.goCreateDeck(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Deck'),
          ),
        ],
      ),
    );
  }

  Widget _buildDecksList(BuildContext context, DeckProvider deckProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deckProvider.decks.length,
      itemBuilder: (context, index) {
        final deck = deckProvider.decks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.library_books,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(deck.title),
            subtitle: Text(deck.description),
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
}
