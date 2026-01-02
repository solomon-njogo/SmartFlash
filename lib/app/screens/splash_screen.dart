import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_name.dart';
import '../widgets/app_logo.dart';
import '../router.dart';
import '../../core/providers/onboarding_provider.dart';
import '../../data/local/hive_service.dart';

/// Splash screen shown during app initialization (Enhanced with animations)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with spring-like curve
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Fade animation for logo
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Scale animation for logo (spring effect)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Start animation
    _controller.forward();

    // Haptic feedback (light impact)
    HapticFeedback.lightImpact();

    // Navigate after animation completes
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Ensure HiveService is initialized
    try {
      if (!HiveService.instance.isInitialized) {
        await HiveService.instance.initialize();
      }
    } catch (e) {
      // If initialization fails, continue anyway
    }

    if (!mounted) return;

    final isAuthenticated =
        Supabase.instance.client.auth.currentSession?.user != null;

    // Check onboarding status
    try {
      final onboardingProvider = Provider.of<OnboardingProvider>(
        context,
        listen: false,
      );
      final hasCompletedOnboarding =
          await onboardingProvider.hasCompletedOnboarding();

      if (!mounted) return;

      if (!hasCompletedOnboarding) {
        // Navigate to onboarding
        AppNavigation.pushAndRemoveUntil(context, '/onboarding');
      } else if (isAuthenticated) {
        // Navigate to home
        AppNavigation.pushAndRemoveUntil(context, '/home');
      } else {
        // Navigate to auth
        AppNavigation.pushAndRemoveUntil(context, '/auth');
      }
    } catch (e) {
      // On error, default to auth/home based on authentication
      if (!mounted) return;
      if (isAuthenticated) {
        AppNavigation.pushAndRemoveUntil(context, '/home');
      } else {
        AppNavigation.pushAndRemoveUntil(context, '/auth');
      }
    }
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
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: AppLogo(
                        size: 120,
                        borderRadius: 24,
                        backgroundColor: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Animated app name
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(
                          0.4,
                          1.0,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const AppName(
                        variant: AppNameVariant.splash,
                        showTagline: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Loading indicator
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
                      ),
                    ),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
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
