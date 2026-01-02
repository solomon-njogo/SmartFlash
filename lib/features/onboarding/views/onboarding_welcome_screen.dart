import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/router.dart';
import '../../../app/widgets/app_logo.dart';
import '../../../app/theme/app_name.dart';
import '../../../app/app_text_styles.dart';

/// Welcome screen - Value proposition confirmation
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = 375.0;
    final scaleFactor = (screenWidth / baseWidth).clamp(0.8, 1.3);

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // App logo
              AppLogo(
                size: 120 * scaleFactor,
                borderRadius: 24 * scaleFactor,
                backgroundColor: colorScheme.primary,
              ),
              SizedBox(height: 40 * scaleFactor),
              // App name
              const AppName(
                variant: AppNameVariant.branded,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24 * scaleFactor),
              // Value proposition
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Master your studies with AI-powered flashcards and spaced repetition',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Get Started button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    AppNavigation.push(context, '/onboarding/quiz');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    minimumSize: const Size(0, 56),
                  ),
                  child: Text(
                    'Get Started',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

