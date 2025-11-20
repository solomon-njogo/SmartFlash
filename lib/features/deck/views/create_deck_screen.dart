import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';
import '../../../data/models/deck_model.dart' as data_models;
import '../../../data/remote/supabase_client.dart';

class CreateDeckScreen extends StatefulWidget {
  final String? courseId;

  const CreateDeckScreen({super.key, this.courseId});

  @override
  State<CreateDeckScreen> createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends State<CreateDeckScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _attemptedSubmit = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

  Future<void> _onSubmit() async {
    setState(() {
      _attemptedSubmit = true;
    });

    if (!_isNameValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = SupabaseService.instance;
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;

      if (currentUserId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Not authenticated'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final now = DateTime.now();
      const uuid = Uuid();
      final newId = uuid.v4();

      final newDeck = data_models.DeckModel(
        id: newId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdBy: currentUserId,
        createdAt: now,
        updatedAt: now,
        courseId: widget.courseId,
        isAIGenerated: false,
      );

      await supabaseService.createDeck(newDeck);

      if (!mounted) return;

      // Navigate to deck details
      AppNavigation.goDeckDetails(context, newId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create deck: $e'),
            backgroundColor: Colors.red,
          ),
        );
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

    final bool canSubmit = _isNameValid && !_isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Deck'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth >= 600;
            final double horizontalPadding =
                wide ? (constraints.maxWidth - 560) / 2 : 16;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Deck',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a deck to organize your flashcards.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Name',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'e.g., Biology Terms',
                      errorText:
                          _attemptedSubmit && !_isNameValid
                              ? 'Name is required'
                              : null,
                      border: const OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Description (optional)',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Add a short description',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 3,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: canSubmit ? _onSubmit : null,
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Create Deck'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

