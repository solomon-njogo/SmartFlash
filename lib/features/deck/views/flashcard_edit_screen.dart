import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/flashcard_model.dart';
import '../../../core/providers/flashcard_provider.dart';
import '../../../app/app_text_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen for creating or editing flashcards
class FlashcardEditScreen extends StatefulWidget {
  final String deckId;
  final String? flashcardId;

  const FlashcardEditScreen({
    super.key,
    required this.deckId,
    this.flashcardId,
  });

  @override
  State<FlashcardEditScreen> createState() => _FlashcardEditScreenState();
}

class _FlashcardEditScreenState extends State<FlashcardEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _frontTextController = TextEditingController();
  final _backTextController = TextEditingController();
  
  DifficultyLevel _difficulty = DifficultyLevel.medium;
  CardType _cardType = CardType.basic;
  bool _isLoading = false;
  FlashcardModel? _existingFlashcard;

  @override
  void initState() {
    super.initState();
    if (widget.flashcardId != null) {
      _loadFlashcard();
    }
  }

  Future<void> _loadFlashcard() async {
    final flashcardProvider = Provider.of<FlashcardProvider>(context, listen: false);
    final flashcard = flashcardProvider.getFlashcardById(widget.flashcardId!);
    
    if (flashcard != null) {
      setState(() {
        _existingFlashcard = flashcard;
        _frontTextController.text = flashcard.frontText;
        _backTextController.text = flashcard.backText;
        _difficulty = flashcard.difficulty;
        _cardType = flashcard.cardType;
      });
    } else {
      // Try to load from database
      final flashcards = await flashcardProvider.getFlashcardsByDeckIdAsync(widget.deckId);
      final found = flashcards.firstWhere(
        (f) => f.id == widget.flashcardId,
        orElse: () => throw Exception('Flashcard not found'),
      );
      setState(() {
        _existingFlashcard = found;
        _frontTextController.text = found.frontText;
        _backTextController.text = found.backText;
        _difficulty = found.difficulty;
        _cardType = found.cardType;
      });
    }
  }

  @override
  void dispose() {
    _frontTextController.dispose();
    _backTextController.dispose();
    super.dispose();
  }

  Future<void> _saveFlashcard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final flashcardProvider = Provider.of<FlashcardProvider>(context, listen: false);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      
      if (userId == null) {
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
      final flashcard = FlashcardModel(
        id: _existingFlashcard?.id ?? const Uuid().v4(),
        deckId: widget.deckId,
        frontText: _frontTextController.text.trim(),
        backText: _backTextController.text.trim(),
        difficulty: _difficulty,
        cardType: _cardType,
        createdAt: _existingFlashcard?.createdAt ?? now,
        updatedAt: now,
        createdBy: userId,
        isAIGenerated: false,
      );

      bool success;
      if (_existingFlashcard != null) {
        success = await flashcardProvider.updateFlashcard(flashcard);
      } else {
        success = await flashcardProvider.createFlashcard(flashcard);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _existingFlashcard != null
                    ? 'Flashcard updated successfully'
                    : 'Flashcard created successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                flashcardProvider.error ?? 'Failed to save flashcard',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: Text(
          _existingFlashcard != null ? 'Edit Flashcard' : 'Create Flashcard',
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Front text field
              TextFormField(
                controller: _frontTextController,
                decoration: InputDecoration(
                  labelText: 'Front',
                  hintText: 'Enter the front text of the flashcard',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
                style: AppTextStyles.bodyLarge,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter front text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Back text field
              TextFormField(
                controller: _backTextController,
                decoration: InputDecoration(
                  labelText: 'Back',
                  hintText: 'Enter the back text of the flashcard',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
                style: AppTextStyles.bodyLarge,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter back text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Difficulty selector
              Text(
                'Difficulty',
                style: AppTextStyles.labelLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<DifficultyLevel>(
                segments: const [
                  ButtonSegment(
                    value: DifficultyLevel.easy,
                    label: Text('Easy'),
                    icon: Icon(Icons.sentiment_satisfied),
                  ),
                  ButtonSegment(
                    value: DifficultyLevel.medium,
                    label: Text('Medium'),
                    icon: Icon(Icons.sentiment_neutral),
                  ),
                  ButtonSegment(
                    value: DifficultyLevel.hard,
                    label: Text('Hard'),
                    icon: Icon(Icons.sentiment_very_dissatisfied),
                  ),
                ],
                selected: {_difficulty},
                onSelectionChanged: (Set<DifficultyLevel> newSelection) {
                  setState(() {
                    _difficulty = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Card type selector
              Text(
                'Card Type',
                style: AppTextStyles.labelLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<CardType>(
                segments: const [
                  ButtonSegment(
                    value: CardType.basic,
                    label: Text('Basic'),
                  ),
                  ButtonSegment(
                    value: CardType.multipleChoice,
                    label: Text('MCQ'),
                  ),
                  ButtonSegment(
                    value: CardType.fillInTheBlank,
                    label: Text('Fill'),
                  ),
                  ButtonSegment(
                    value: CardType.trueFalse,
                    label: Text('T/F'),
                  ),
                ],
                selected: {_cardType},
                onSelectionChanged: (Set<CardType> newSelection) {
                  setState(() {
                    _cardType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveFlashcard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _existingFlashcard != null ? 'Update' : 'Create',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

