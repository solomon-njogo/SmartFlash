import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/ai_generation_provider.dart';
import '../../../core/providers/course_material_provider.dart';
import '../../../data/models/course_material_model.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/router.dart';

/// Screen for AI content generation
class AIGenerationScreen extends StatefulWidget {
  final String? courseId;

  const AIGenerationScreen({super.key, this.courseId});

  @override
  State<AIGenerationScreen> createState() => _AIGenerationScreenState();
}

class _AIGenerationScreenState extends State<AIGenerationScreen> {
  final Set<CourseMaterialModel> _selectedMaterials = {};
  GenerationType? _generationType;
  String _difficulty = 'medium';
  bool _hasNavigatedToReview = false;
  AIGenerationProvider? _provider;

  @override
  void initState() {
    super.initState();
    // If courseId is provided, default to flashcards (deck creation)
    if (widget.courseId != null) {
      _generationType = GenerationType.flashcards;
    }
  }

  @override
  void dispose() {
    if (_provider != null) {
      _provider!.removeListener(_onProviderChanged);
    }
    super.dispose();
  }

  void _onProviderChanged() {
    if (_provider == null || !mounted) return;

    // Auto-navigate to review screen when generation completes
    if (!_hasNavigatedToReview &&
        _provider!.status == GenerationStatus.completed &&
        _provider!.hasGeneratedContent) {
      _hasNavigatedToReview = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AppNavigation.goAIReview(context);
        }
      });
    }
    // Reset navigation flag if status changes back to idle
    if (_provider!.status == GenerationStatus.idle) {
      _hasNavigatedToReview = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Content Generation',
          style: AppTextStyles.titleLarge.copyWith(
            color: theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
          ),
        ),
      ),
      body: Consumer<AIGenerationProvider>(
        builder: (context, provider, child) {
          // Set courseId in provider if available (only once)
          if (widget.courseId != null && provider.courseId != widget.courseId) {
            provider.setCourseId(widget.courseId);
          }
          // Set up listener on first build
          if (_provider != provider) {
            _provider?.removeListener(_onProviderChanged);
            _provider = provider;
            provider.addListener(_onProviderChanged);
          }

          // Check for auto-navigation in build (as backup)
          if (!_hasNavigatedToReview &&
              provider.status == GenerationStatus.completed &&
              provider.hasGeneratedContent) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_hasNavigatedToReview) {
                _hasNavigatedToReview = true;
                AppNavigation.goAIReview(context);
              }
            });
          }
          final colorScheme = Theme.of(context).colorScheme;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Material Selection
                _buildMaterialSelection(provider, colorScheme),
                const SizedBox(height: 16),

                // Generation Type Selection
                _buildGenerationTypeSelection(colorScheme),
                const SizedBox(height: 16),

                // Generation Options
                if (_generationType != null)
                  _buildGenerationOptions(colorScheme),
                const SizedBox(height: 16),

                // Generate Button
                if (_selectedMaterials.isNotEmpty && _generationType != null)
                  _buildGenerateButton(provider),

                // Progress Indicator
                if (provider.isGenerating) _buildProgressIndicator(provider),

                // Error Display
                if (provider.error != null) _buildErrorDisplay(provider.error!),

                // Success - Show message (auto-navigation happens via listener)
                if (provider.status == GenerationStatus.completed &&
                    provider.hasGeneratedContent &&
                    provider.generationType == GenerationType.flashcards)
                  _buildSuccessActions(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMaterialSelection(
    AIGenerationProvider provider,
    ColorScheme colorScheme,
  ) {
    final materialsProvider = context.watch<CourseMaterialProvider>();
    var materials =
        materialsProvider.materials
            .where(
              (m) =>
                  m.fileType == FileType.pdf ||
                  m.fileType == FileType.docx ||
                  m.fileType == FileType.doc,
            )
            .toList();

    // Always filter by course if courseId is provided
    if (widget.courseId != null) {
      materials =
          materials.where((m) => m.courseId == widget.courseId).toList();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Documents',
              style: AppTextStyles.titleLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            if (materials.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No PDF or Word documents available${widget.courseId != null ? ' for this course' : ''}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap:
                        () => _showDocumentSelectionDialog(materials, provider),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_selectedMaterials.isEmpty)
                                  Text(
                                    'Choose documents',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                else
                                  Text(
                                    _selectedMaterials.length == 1
                                        ? _selectedMaterials.first.name
                                        : '${_selectedMaterials.length} documents selected',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (_selectedMaterials.isNotEmpty &&
                                    _selectedMaterials.length > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _selectedMaterials
                                          .map((m) => m.name)
                                          .join(', '),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedMaterials.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _selectedMaterials.map((material) {
                              return Chip(
                                label: Text(
                                  material.name,
                                  style: AppTextStyles.bodySmall,
                                ),
                                onDeleted: () {
                                  setState(() {
                                    _selectedMaterials.remove(material);
                                    provider.selectMaterials(
                                      _selectedMaterials.toList(),
                                    );
                                  });
                                },
                                deleteIcon: const Icon(Icons.close, size: 18),
                                backgroundColor: colorScheme.primaryContainer,
                                labelStyle: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                ],
              ),
            if (_selectedMaterials.isNotEmpty && provider.hasDocumentTextError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  provider.error ?? 'Some document texts are not available',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDocumentSelectionDialog(
    List<CourseMaterialModel> materials,
    AIGenerationProvider provider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder:
                (context, scrollController) => StatefulBuilder(
                  builder: (context, setModalState) {
                    return Column(
                      children: [
                        // Handle bar
                        Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Select Documents',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setModalState(() {
                                        if (_selectedMaterials.length ==
                                            materials.length) {
                                          _selectedMaterials.clear();
                                        } else {
                                          _selectedMaterials.clear();
                                          _selectedMaterials.addAll(materials);
                                        }
                                      });
                                    },
                                    child: Text(
                                      _selectedMaterials.length ==
                                              materials.length
                                          ? 'Deselect All'
                                          : 'Select All',
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: colorScheme.onSurface,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(color: colorScheme.outlineVariant),
                        // Document list
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: materials.length,
                            itemBuilder: (context, index) {
                              final material = materials[index];
                              final isSelected = _selectedMaterials.contains(
                                material,
                              );
                              return CheckboxListTile(
                                title: Text(
                                  material.name,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Icon(
                                      _getFileTypeIcon(material.fileType),
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getFileTypeLabel(material.fileType),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                value: isSelected,
                                onChanged: (value) {
                                  setModalState(() {
                                    if (value == true) {
                                      _selectedMaterials.add(material);
                                    } else {
                                      _selectedMaterials.remove(material);
                                    }
                                  });
                                },
                                activeColor: colorScheme.primary,
                              );
                            },
                          ),
                        ),
                        // Footer with apply button
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedMaterials.isEmpty
                                      ? 'No documents selected'
                                      : '${_selectedMaterials.length} document${_selectedMaterials.length == 1 ? '' : 's'} selected',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color:
                                        _selectedMaterials.isEmpty
                                            ? colorScheme.onSurfaceVariant
                                            : colorScheme.primary,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    provider.selectMaterials(
                                      _selectedMaterials.toList(),
                                    );
                                  });
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                ),
                                child: const Text('Apply'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
          ),
    );
  }

  String _getFileTypeLabel(FileType fileType) {
    switch (fileType) {
      case FileType.pdf:
        return 'PDF Document';
      case FileType.docx:
      case FileType.doc:
        return 'Word Document';
      default:
        return 'Document';
    }
  }

  IconData _getFileTypeIcon(FileType fileType) {
    switch (fileType) {
      case FileType.pdf:
        return Icons.picture_as_pdf;
      case FileType.docx:
      case FileType.doc:
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildGenerationTypeSelection(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Type',
              style: AppTextStyles.titleLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<GenerationType>(
                    title: Text(
                      'Flashcards',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    value: GenerationType.flashcards,
                    groupValue: _generationType,
                    onChanged: (value) {
                      setState(() {
                        _generationType = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<GenerationType>(
                    title: Text(
                      'Quiz',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    value: GenerationType.quiz,
                    groupValue: _generationType,
                    onChanged: (value) {
                      setState(() {
                        _generationType = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationOptions(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _generationType == GenerationType.flashcards
                  ? 'Flashcard Options'
                  : 'Quiz Options',
              style: AppTextStyles.titleMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            // Info about fixed count
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _generationType == GenerationType.flashcards
                          ? 'Will generate 10 flashcards'
                          : 'Will generate 10 multiple choice questions',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Difficulty
            DropdownButtonFormField<String>(
              value: _difficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(),
              ),
              items:
                  ['easy', 'medium', 'hard']
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _difficulty = value ?? 'medium';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(AIGenerationProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed:
          provider.isGenerating
              ? null
              : () {
                if (_generationType == GenerationType.flashcards) {
                  provider.generateFlashcards(
                    deckId: 'deck_${DateTime.now().millisecondsSinceEpoch}',
                    count: 10, // Fixed to 10
                    difficulty: _difficulty,
                    cardTypes: ['basic'], // Default card type
                  );
                } else {
                  provider.generateQuiz(
                    questionCount: 10, // Fixed to 10
                    difficulty: _difficulty,
                    questionTypes: ['multipleChoice'], // Only MCQs
                  );
                }
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        'Generate ${_generationType == GenerationType.flashcards ? 'Flashcards' : 'Quiz'}',
        style: AppTextStyles.titleMedium.copyWith(color: colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildProgressIndicator(AIGenerationProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            LinearProgressIndicator(value: provider.progress),
            const SizedBox(height: 8),
            Text(
              'Generating... ${(provider.progress * 100).toInt()}%',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDisplay(String error) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          error,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessActions(AIGenerationProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              'Generation Complete!',
              style: AppTextStyles.titleMedium.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Navigate to review screen
                AppNavigation.goAIReview(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Review & Accept'),
            ),
          ],
        ),
      ),
    );
  }
}
