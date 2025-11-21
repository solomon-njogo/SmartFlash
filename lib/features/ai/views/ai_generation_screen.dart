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
  bool _courseIdSet = false;

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
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive padding and spacing based on screen size
    final baseWidth = 375.0;
    final scaleFactor = (screenWidth / baseWidth).clamp(0.8, 1.3);
    final horizontalPadding = (16 * scaleFactor).clamp(12.0, 24.0);
    final verticalPadding = (12 * scaleFactor).clamp(8.0, 16.0);
    final sectionSpacing = (16 * scaleFactor).clamp(12.0, 20.0);

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
          // Set courseId in provider if available (only once, after build)
          if (widget.courseId != null &&
              !_courseIdSet &&
              provider.courseId != widget.courseId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_courseIdSet) {
                _courseIdSet = true;
                provider.setCourseId(widget.courseId);
              }
            });
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

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Material Selection
                _buildMaterialSelection(provider, colorScheme, scaleFactor),
                SizedBox(height: sectionSpacing),

                // Generation Type Selection
                _buildGenerationTypeSelection(colorScheme, scaleFactor),
                SizedBox(height: sectionSpacing),

                // Generation Options
                if (_generationType != null)
                  _buildGenerationOptions(colorScheme, scaleFactor),
                SizedBox(height: sectionSpacing),

                // Generate Button
                if (_selectedMaterials.isNotEmpty && _generationType != null)
                  _buildGenerateButton(provider, scaleFactor),

                // Progress Indicator
                if (provider.isGenerating)
                  _buildProgressIndicator(provider, scaleFactor),

                // Error Display
                if (provider.error != null)
                  _buildErrorDisplay(provider.error!, scaleFactor),

                // Success - Show message (auto-navigation happens via listener)
                if (provider.status == GenerationStatus.completed &&
                    provider.hasGeneratedContent &&
                    provider.generationType == GenerationType.flashcards)
                  _buildSuccessActions(provider, scaleFactor),
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
    double scaleFactor,
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

    final cardPadding = (12 * scaleFactor).clamp(10.0, 16.0);
    final titleSpacing = (10 * scaleFactor).clamp(8.0, 12.0);
    final chipSpacing = (8 * scaleFactor).clamp(6.0, 12.0);
    final chipRunSpacing = (8 * scaleFactor).clamp(6.0, 12.0);
    final innerSpacing = (8 * scaleFactor).clamp(6.0, 12.0);
    final containerPadding = (14 * scaleFactor).clamp(12.0, 18.0);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Documents',
              style: AppTextStyles.titleLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: titleSpacing),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: containerPadding,
                        vertical: containerPadding,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(
                          (12 * scaleFactor).clamp(10.0, 16.0),
                        ),
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
                      padding: EdgeInsets.only(top: innerSpacing),
                      child: Wrap(
                        spacing: chipSpacing,
                        runSpacing: chipRunSpacing,
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
                padding: EdgeInsets.only(top: innerSpacing),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = 375.0;
    final scaleFactor = (screenWidth / baseWidth).clamp(0.8, 1.3);
    final handleMargin = (12 * scaleFactor).clamp(10.0, 16.0);
    final handleBottomMargin = (8 * scaleFactor).clamp(6.0, 12.0);
    final handleWidth = (40 * scaleFactor).clamp(36.0, 48.0);
    final handleHeight = (4 * scaleFactor).clamp(3.0, 6.0);
    final headerPadding = (16 * scaleFactor).clamp(12.0, 20.0);
    final headerVerticalPadding = (8 * scaleFactor).clamp(6.0, 12.0);
    final borderRadius = (20 * scaleFactor).clamp(16.0, 24.0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
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
                          margin: EdgeInsets.only(
                            top: handleMargin,
                            bottom: handleBottomMargin,
                          ),
                          width: handleWidth,
                          height: handleHeight,
                          decoration: BoxDecoration(
                            color: colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Header
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: headerPadding,
                            vertical: headerVerticalPadding,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Title - flexible to prevent overflow
                              Flexible(
                                child: Text(
                                  'Select Documents',
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              // Buttons row - flexible and responsive
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Use smaller button on small screens
                                    screenWidth < 360
                                        ? IconButton(
                                          icon: Icon(
                                            _selectedMaterials.length ==
                                                    materials.length
                                                ? Icons.deselect
                                                : Icons.select_all,
                                            color: colorScheme.primary,
                                            size: (20 * scaleFactor).clamp(
                                              18.0,
                                              24.0,
                                            ),
                                          ),
                                          tooltip:
                                              _selectedMaterials.length ==
                                                      materials.length
                                                  ? 'Deselect All'
                                                  : 'Select All',
                                          onPressed: () {
                                            setModalState(() {
                                              if (_selectedMaterials.length ==
                                                  materials.length) {
                                                _selectedMaterials.clear();
                                              } else {
                                                _selectedMaterials.clear();
                                                _selectedMaterials.addAll(
                                                  materials,
                                                );
                                              }
                                            });
                                          },
                                          padding: EdgeInsets.all(
                                            (8 * scaleFactor).clamp(4.0, 12.0),
                                          ),
                                          constraints: BoxConstraints(
                                            minWidth: (36 * scaleFactor).clamp(
                                              32.0,
                                              48.0,
                                            ),
                                            minHeight: (36 * scaleFactor).clamp(
                                              32.0,
                                              48.0,
                                            ),
                                          ),
                                        )
                                        : TextButton(
                                          onPressed: () {
                                            setModalState(() {
                                              if (_selectedMaterials.length ==
                                                  materials.length) {
                                                _selectedMaterials.clear();
                                              } else {
                                                _selectedMaterials.clear();
                                                _selectedMaterials.addAll(
                                                  materials,
                                                );
                                              }
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: (8 * scaleFactor)
                                                  .clamp(4.0, 12.0),
                                              vertical: (4 * scaleFactor).clamp(
                                                2.0,
                                                8.0,
                                              ),
                                            ),
                                            minimumSize: Size(
                                              (60 * scaleFactor).clamp(
                                                48.0,
                                                80.0,
                                              ),
                                              (32 * scaleFactor).clamp(
                                                28.0,
                                                40.0,
                                              ),
                                            ),
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                          child: Text(
                                            _selectedMaterials.length ==
                                                    materials.length
                                                ? 'Deselect All'
                                                : 'Select All',
                                            style: TextStyle(
                                              fontSize: (12 * scaleFactor)
                                                  .clamp(11.0, 14.0),
                                            ),
                                          ),
                                        ),
                                    SizedBox(
                                      width: (4 * scaleFactor).clamp(2.0, 8.0),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: colorScheme.onSurface,
                                        size: (20 * scaleFactor).clamp(
                                          18.0,
                                          24.0,
                                        ),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                      padding: EdgeInsets.all(
                                        (8 * scaleFactor).clamp(4.0, 12.0),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: (36 * scaleFactor).clamp(
                                          32.0,
                                          48.0,
                                        ),
                                        minHeight: (36 * scaleFactor).clamp(
                                          32.0,
                                          48.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: colorScheme.outlineVariant),
                        // Document list
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(
                              vertical: headerVerticalPadding,
                            ),
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getFileTypeIcon(material.fileType),
                                      size: (16 * scaleFactor).clamp(
                                        14.0,
                                        18.0,
                                      ),
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    SizedBox(
                                      width: (4 * scaleFactor).clamp(3.0, 6.0),
                                    ),
                                    Flexible(
                                      child: Text(
                                        _getFileTypeLabel(material.fileType),
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
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
                          padding: EdgeInsets.all(headerPadding),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.1),
                                blurRadius: (10 * scaleFactor).clamp(8.0, 12.0),
                                offset: Offset(
                                  0,
                                  (-2 * scaleFactor).clamp(-3.0, -1.0),
                                ),
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
                                    fontSize: (14 * scaleFactor).clamp(
                                      12.0,
                                      16.0,
                                    ),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(
                                width: (8 * scaleFactor).clamp(4.0, 12.0),
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: (16 * scaleFactor).clamp(
                                      12.0,
                                      20.0,
                                    ),
                                    vertical: (8 * scaleFactor).clamp(
                                      6.0,
                                      12.0,
                                    ),
                                  ),
                                  minimumSize: Size(
                                    (70 * scaleFactor).clamp(60.0, 90.0),
                                    (36 * scaleFactor).clamp(32.0, 44.0),
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Apply',
                                  style: TextStyle(
                                    fontSize: (14 * scaleFactor).clamp(
                                      12.0,
                                      16.0,
                                    ),
                                  ),
                                ),
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

  Widget _buildGenerationTypeSelection(
    ColorScheme colorScheme,
    double scaleFactor,
  ) {
    final cardPadding = (12 * scaleFactor).clamp(10.0, 16.0);
    final titleSpacing = (10 * scaleFactor).clamp(8.0, 12.0);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Type',
              style: AppTextStyles.titleLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: titleSpacing),
            // Use LayoutBuilder for responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                // Stack vertically on very small screens (< 320px)
                if (constraints.maxWidth < 320) {
                  return Column(
                    children: [
                      RadioListTile<GenerationType>(
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
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<GenerationType>(
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
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  );
                }
                // Use horizontal layout for larger screens
                return Row(
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
                        contentPadding: EdgeInsets.zero,
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
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationOptions(ColorScheme colorScheme, double scaleFactor) {
    final cardPadding = (12 * scaleFactor).clamp(10.0, 16.0);
    final titleSpacing = (12 * scaleFactor).clamp(10.0, 16.0);
    final infoPadding = (12 * scaleFactor).clamp(10.0, 16.0);
    final borderRadius = (8 * scaleFactor).clamp(6.0, 12.0);
    final iconSpacing = (8 * scaleFactor).clamp(6.0, 12.0);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
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
            SizedBox(height: titleSpacing),
            // Info about fixed count
            Container(
              padding: EdgeInsets.all(infoPadding),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.onPrimaryContainer,
                    size: (20 * scaleFactor).clamp(18.0, 24.0),
                  ),
                  SizedBox(width: iconSpacing),
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
            SizedBox(height: titleSpacing),
            // Difficulty
            DropdownButtonFormField<String>(
              value: _difficulty,
              decoration: InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    (12 * scaleFactor).clamp(10.0, 16.0),
                  ),
                ),
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

  Widget _buildGenerateButton(
    AIGenerationProvider provider,
    double scaleFactor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonPadding = (14 * scaleFactor).clamp(12.0, 18.0);

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
        padding: EdgeInsets.symmetric(vertical: buttonPadding),
        minimumSize: Size(
          double.infinity,
          (48 * scaleFactor).clamp(44.0, 56.0),
        ),
      ),
      child: Text(
        'Generate ${_generationType == GenerationType.flashcards ? 'Flashcards' : 'Quiz'}',
        style: AppTextStyles.titleMedium.copyWith(color: colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildProgressIndicator(
    AIGenerationProvider provider,
    double scaleFactor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardPadding = (12 * scaleFactor).clamp(10.0, 16.0);
    final spacing = (8 * scaleFactor).clamp(6.0, 12.0);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          children: [
            LinearProgressIndicator(value: provider.progress),
            SizedBox(height: spacing),
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

  Widget _buildErrorDisplay(String error, double scaleFactor) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardPadding = (12 * scaleFactor).clamp(10.0, 16.0);

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Text(
          error,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessActions(
    AIGenerationProvider provider,
    double scaleFactor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardPadding = (12 * scaleFactor).clamp(10.0, 16.0);
    final spacing = (12 * scaleFactor).clamp(10.0, 16.0);

    return Card(
      color: colorScheme.tertiaryContainer,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          children: [
            Text(
              'Generation Complete!',
              style: AppTextStyles.titleMedium.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
            SizedBox(height: spacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to review screen
                  AppNavigation.goAIReview(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: Size(0, (48 * scaleFactor).clamp(44.0, 56.0)),
                ),
                child: const Text('Review & Accept'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
