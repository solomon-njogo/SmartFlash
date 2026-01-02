import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/router.dart';
import '../../../app/app_text_styles.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../widgets/onboarding_progress_indicator.dart';
import '../widgets/quiz_question_widget.dart';

/// Quiz screen for personalization (Investment Loop)
class OnboardingQuizScreen extends StatefulWidget {
  const OnboardingQuizScreen({super.key});

  @override
  State<OnboardingQuizScreen> createState() => _OnboardingQuizScreenState();
}

class _OnboardingQuizScreenState extends State<OnboardingQuizScreen> {
  int _currentStep = 0;

  // Quiz answers
  List<String> _selectedGoals = [];
  int _studyTimeMinutes = 15;
  String? _learningStyle;

  final List<String> _goals = [
    'Exam Prep',
    'Language Learning',
    'Professional Development',
    'General Study',
  ];

  final List<String> _learningStyles = [
    'Visual',
    'Auditory',
    'Kinesthetic',
    'Mixed',
  ];

  double get _progress {
    switch (_currentStep) {
      case 0:
        return 0.2; // Start at 20% (Endowed Progress Effect)
      case 1:
        return 0.5;
      case 2:
        return 0.8;
      default:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            OnboardingProgressIndicator(progress: _progress),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      _buildQuestionContent(),
                      const SizedBox(height: 56),
                      _buildNavigationButtons(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    switch (_currentStep) {
      case 0:
        return _buildGoalsQuestion();
      case 1:
        return _buildStudyTimeQuestion();
      case 2:
        return _buildLearningStyleQuestion();
      default:
        return const SizedBox();
    }
  }

  Widget _buildGoalsQuestion() {
    return QuizQuestionWidget(
      question: 'What are your goals?',
      subtitle: 'Select all that apply',
      options: _goals,
      selectedOptions: _selectedGoals,
      isMultiSelect: true,
      onOptionSelected: (goal) {
        setState(() {
          if (!_selectedGoals.contains(goal)) {
            _selectedGoals.add(goal);
            HapticFeedback.selectionClick();
          }
        });
      },
      onOptionDeselected: (goal) {
        setState(() {
          _selectedGoals.remove(goal);
          HapticFeedback.selectionClick();
        });
      },
    );
  }

  Widget _buildStudyTimeQuestion() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How much time do you have?',
          style: AppTextStyles.headlineSmall.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ll personalize your study schedule',
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 40),
        // Slider
        Column(
          children: [
            Text(
              '$_studyTimeMinutes minutes per day',
              style: AppTextStyles.headlineMedium.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            Slider(
              value: _studyTimeMinutes.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: '$_studyTimeMinutes minutes',
              onChanged: (value) {
                setState(() {
                  _studyTimeMinutes = value.round();
                  HapticFeedback.selectionClick();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '5 min',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '60 min',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLearningStyleQuestion() {
    return QuizQuestionWidget(
      question: 'What\'s your learning style?',
      subtitle: 'Choose the one that best describes you',
      options: _learningStyles,
      selectedOptions: _learningStyle != null ? [_learningStyle!] : [],
      isMultiSelect: false,
      onOptionSelected: (style) {
        setState(() {
          // For single-select, replace the previous selection
          _learningStyle = style;
          HapticFeedback.selectionClick();
        });
      },
      onOptionDeselected: (style) {
        setState(() {
          _learningStyle = null;
        });
      },
    );
  }

  Widget _buildNavigationButtons() {
    final canProceed = _canProceed();

    if (_currentStep == 0) {
      // First step: only Next button, full width
      return ElevatedButton(
        onPressed:
            canProceed
                ? () {
                  HapticFeedback.mediumImpact();
                  _handleNext();
                }
                : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          minimumSize: const Size(double.infinity, 56),
        ),
        child: Text(
          'Next',
          style: AppTextStyles.button.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Other steps: Back and Next buttons side by side
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _currentStep--;
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              minimumSize: const Size(0, 56),
            ),
            child: const Text('Back'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed:
                canProceed
                    ? () {
                      HapticFeedback.mediumImpact();
                      _handleNext();
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              minimumSize: const Size(0, 56),
            ),
            child: Text(
              _currentStep == 2 ? 'Continue' : 'Next',
              style: AppTextStyles.button.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedGoals.isNotEmpty;
      case 1:
        return true; // Slider always has a value
      case 2:
        return _learningStyle != null;
      default:
        return false;
    }
  }

  void _handleNext() async {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Save preferences and move to building screen
      final provider = Provider.of<OnboardingProvider>(context, listen: false);
      await provider.savePreferences(
        OnboardingPreferences(
          goals: _selectedGoals,
          studyTimeMinutes: _studyTimeMinutes,
          learningStyle: _learningStyle ?? 'Mixed',
        ),
      );
      AppNavigation.push(context, '/onboarding/building');
    }
  }
}
