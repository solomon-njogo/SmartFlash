import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/router.dart';
import '../../../app/app_text_styles.dart';

/// Building screen - Labor illusion (makes user value the result more)
class OnboardingBuildingScreen extends StatefulWidget {
  const OnboardingBuildingScreen({super.key});

  @override
  State<OnboardingBuildingScreen> createState() =>
      _OnboardingBuildingScreenState();
}

class _OnboardingBuildingScreenState
    extends State<OnboardingBuildingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
    HapticFeedback.lightImpact();

    // Navigate after animation
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        AppNavigation.push(context, '/onboarding/permissions');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Icon(
                          Icons.auto_awesome,
                          size: 80,
                          color: colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  'Building your personalized plan...',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'This will only take a moment',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

