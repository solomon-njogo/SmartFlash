import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/router.dart';
import '../../../core/providers/deck_provider.dart';
import '../../../data/models/deck_model.dart' as data_models;

/// Screen for editing an existing deck
class EditDeckScreen extends StatefulWidget {
  final String deckId;

  const EditDeckScreen({super.key, required this.deckId});

  @override
  State<EditDeckScreen> createState() => _EditDeckScreenState();
}

class _EditDeckScreenState extends State<EditDeckScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _attemptedSubmit = false;
  bool _isLoading = false;
  data_models.DeckModel? _deck;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadDeck();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadDeck() async {
    final deckProvider = Provider.of<DeckProvider>(context, listen: false);
    final deck = deckProvider.getDeckById(widget.deckId);
    
    if (deck != null) {
      setState(() {
        _deck = deck;
        _nameController.text = deck.name;
        _descriptionController.text = deck.description ?? '';
      });
    }
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

  Future<void> _onSubmit() async {
    setState(() {
      _attemptedSubmit = true;
    });

    if (!_isNameValid || _deck == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final deckProvider = Provider.of<DeckProvider>(context, listen: false);
      final updatedDeck = _deck!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        updatedAt: DateTime.now(),
      );
      final success = await deckProvider.updateDeck(updatedDeck);

      if (mounted) {
        if (success) {
          AppNavigation.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(deckProvider.error ?? 'Failed to update deck'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_deck == null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          title: const Text('Edit Deck'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Edit Deck'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Deck Name',
                  hintText: 'Enter deck name',
                  errorText: _attemptedSubmit && !_isNameValid
                      ? 'Deck name is required'
                      : null,
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter deck description',
                ),
                maxLines: 4,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

