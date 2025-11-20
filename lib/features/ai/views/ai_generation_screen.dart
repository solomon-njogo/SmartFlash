import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/ai_generation_provider.dart';
import '../../../core/providers/course_material_provider.dart';
import '../../../data/models/course_material_model.dart';
import '../../../app/app_text_styles.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/router.dart';

/// Screen for AI content generation
class AIGenerationScreen extends StatefulWidget {
  const AIGenerationScreen({super.key});

  @override
  State<AIGenerationScreen> createState() => _AIGenerationScreenState();
}

class _AIGenerationScreenState extends State<AIGenerationScreen> {
  CourseMaterialModel? _selectedMaterial;
  GenerationType? _generationType;
  String _difficulty = 'medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Content Generation'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<AIGenerationProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Material Selection
                _buildMaterialSelection(provider),
                const SizedBox(height: 24),

                // Generation Type Selection
                _buildGenerationTypeSelection(),
                const SizedBox(height: 24),

                // Generation Options
                if (_generationType != null) _buildGenerationOptions(),
                const SizedBox(height: 24),

                // Generate Button
                if (_selectedMaterial != null && _generationType != null)
                  _buildGenerateButton(provider),

                // Progress Indicator
                if (provider.isGenerating) _buildProgressIndicator(provider),

                // Error Display
                if (provider.error != null) _buildErrorDisplay(provider.error!),

                // Success - Navigate to Review
                if (provider.status == GenerationStatus.completed &&
                    provider.hasGeneratedContent)
                  _buildSuccessActions(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMaterialSelection(AIGenerationProvider provider) {
    final materialsProvider = context.watch<CourseMaterialProvider>();
    final materials =
        materialsProvider.materials
            .where(
              (m) =>
                  m.fileType == FileType.pdf ||
                  m.fileType == FileType.docx ||
                  m.fileType == FileType.doc,
            )
            .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Document', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            if (materials.isEmpty)
              const Text('No PDF or Word documents available')
            else
              DropdownButtonFormField<CourseMaterialModel>(
                value: _selectedMaterial,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Choose a document',
                  border: OutlineInputBorder(),
                ),
                items:
                    materials.map((material) {
                      return DropdownMenuItem(
                        value: material,
                        child: Text(
                          material.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                selectedItemBuilder: (context) {
                  return materials.map((material) {
                    return Text(material.name, overflow: TextOverflow.ellipsis);
                  }).toList();
                },
                onChanged: (material) {
                  setState(() {
                    _selectedMaterial = material;
                  });
                  if (material != null) {
                    provider.selectMaterial(material);
                  }
                },
              ),
            if (_selectedMaterial != null && provider.documentText == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  provider.error ?? 'Document text not available',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationTypeSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Content Type', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<GenerationType>(
                    title: const Text('Flashcards'),
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
                    title: const Text('Quiz'),
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

  Widget _buildGenerationOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _generationType == GenerationType.flashcards
                  ? 'Flashcard Options'
                  : 'Quiz Options',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 16),
            // Info about fixed count
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _generationType == GenerationType.flashcards
                          ? 'Will generate 10 flashcards'
                          : 'Will generate 10 multiple choice questions',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                    deckId: 'deck_${DateTime.now().millisecondsSinceEpoch}',
                    questionCount: 10, // Fixed to 10
                    difficulty: _difficulty,
                    questionTypes: ['multipleChoice'], // Only MCQs
                  );
                }
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        'Generate ${_generationType == GenerationType.flashcards ? 'Flashcards' : 'Quiz'}',
        style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildProgressIndicator(AIGenerationProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: provider.progress),
            const SizedBox(height: 8),
            Text(
              'Generating... ${(provider.progress * 100).toInt()}%',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDisplay(String error) {
    return Card(
      color: AppColors.error.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          error,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildSuccessActions(AIGenerationProvider provider) {
    return Card(
      color: AppColors.success.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Generation Complete!',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to review screen
                AppNavigation.goAIReview(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('Review & Accept'),
            ),
          ],
        ),
      ),
    );
  }
}
