import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/deck_model.dart' as data_models;
import '../../../data/models/flashcard_model.dart';
import '../../../core/providers/flashcard_provider.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../data/remote/supabase_client.dart';

/// Deck details screen showing deck info and flashcards
class DeckDetailsScreen extends StatefulWidget {
  final String deckId;

  const DeckDetailsScreen({
    super.key,
    required this.deckId,
  });

  @override
  State<DeckDetailsScreen> createState() => _DeckDetailsScreenState();
}

class _DeckDetailsScreenState extends State<DeckDetailsScreen> {
  data_models.DeckModel? _deck;
  bool _isHeaderExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadDeck();
  }

  Future<void> _loadDeck() async {
    try {
      final supabaseService = SupabaseService.instance;
      final decks = await supabaseService.getUserDecks(
        supabaseService.currentUserId ?? '',
      );
      final found = decks.firstWhere(
        (d) => d.id == widget.deckId,
        orElse: () => throw Exception('Deck not found'),
      );
      if (mounted) {
        setState(() {
          _deck = found;
        });
      }
    } catch (e) {
      // Deck not found, will show placeholder
      if (mounted) {
        setState(() {
          _deck = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: Text(
          _deck?.name ?? 'Deck',
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _deck == null
                ? null
                : () {
                    // TODO: Navigate to edit deck
                  },
            icon: Icon(Icons.edit, color: colorScheme.onSurface),
          ),
        ],
      ),
      body: Column(
        children: [
          // Deck header
          _buildDeckHeader(context),
          // Flashcards list
          Expanded(
            child: _buildFlashcardsList(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppNavigation.goFlashcardEdit(
            context,
            deckId: widget.deckId,
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Flashcard'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildDeckHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.library_books,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _deck?.name ?? 'Deck',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_deck?.description != null && _isHeaderExpanded) ...[
                        const SizedBox(height: 4),
                        Text(
                          _deck!.description!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isHeaderExpanded = !_isHeaderExpanded;
                    });
                  },
                  icon: AnimatedRotation(
                    turns: _isHeaderExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isHeaderExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Consumer<FlashcardProvider>(
                      builder: (context, flashcardProvider, child) {
                        final flashcardCount = flashcardProvider
                            .getFlashcardCountByDeckId(widget.deckId);
                        return Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildStatChip(
                              context,
                              Icons.style,
                              '$flashcardCount',
                              'Cards',
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String count,
    String label,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 14 : 16,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: isSmallScreen ? 4 : 6),
          Text(
            count,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 12 : null,
            ),
          ),
          SizedBox(width: isSmallScreen ? 2 : 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: isSmallScreen ? 10 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardsList(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, flashcardProvider, child) {
        return FutureBuilder<List<FlashcardModel>>(
          future: flashcardProvider.getFlashcardsByDeckIdAsync(widget.deckId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final flashcards = snapshot.data ?? [];

            if (flashcards.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () => flashcardProvider.refreshFlashcards(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: flashcards.length,
                itemBuilder: (context, index) {
                  final flashcard = flashcards[index];
                  return _buildFlashcardCard(context, flashcard, flashcardProvider);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFlashcardCard(
    BuildContext context,
    FlashcardModel flashcard,
    FlashcardProvider flashcardProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          AppNavigation.goFlashcardReview(
            context,
            deckId: widget.deckId,
            flashcardId: flashcard.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Front',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          flashcard.frontText,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'study':
                          AppNavigation.goFlashcardReview(
                            context,
                            deckId: widget.deckId,
                            flashcardId: flashcard.id,
                          );
                          break;
                        case 'edit':
                          AppNavigation.goFlashcardEdit(
                            context,
                            deckId: widget.deckId,
                            flashcardId: flashcard.id,
                          );
                          break;
                        case 'delete':
                          _showDeleteFlashcardDialog(
                            context,
                            flashcardProvider,
                            flashcard,
                          );
                          break;
                      }
                    },
                    itemBuilder: (context) => [
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
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Back',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flashcard.backText,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Flashcards',
              style: AppTextStyles.headlineSmall.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This deck doesn\'t have any flashcards yet.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                AppNavigation.goFlashcardEdit(
                  context,
                  deckId: widget.deckId,
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Flashcard'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteFlashcardDialog(
    BuildContext context,
    FlashcardProvider flashcardProvider,
    FlashcardModel flashcard,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flashcard'),
        content: Text('Are you sure you want to delete this flashcard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await flashcardProvider.deleteFlashcard(flashcard.id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Flashcard deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        flashcardProvider.error ?? 'Failed to delete flashcard',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

