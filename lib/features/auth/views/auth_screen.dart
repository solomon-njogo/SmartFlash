import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_name.dart';
// Removed direct AppColors usage in favor of Theme colorScheme
import '../../../app/app_text_styles.dart';
import '../../../app/widgets/app_logo.dart';

/// Authentication screen with onboarding-style UI
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // App icon section
                      _buildAppIcon(),
                      const SizedBox(height: 32),

                      // Welcome message section
                      _buildWelcomeSection(),
                      const SizedBox(height: 48),

                      // Feature cards section
                      _buildFeatureCards(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Fix button to bottom position
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildGetStartedButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return const AppLogo(
      size: 120,
      borderRadius: 24, // Modern corner radius
    );
  }

  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        const AppName(
          variant: AppNameVariant.branded,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Your smart learning companion',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCards() {
    final features = [
      {
        'icon': Icons.library_books_outlined,
        'title': 'Enhanced Memory Retention',
      },
      {'icon': Icons.psychology_outlined, 'title': 'AI-Powered Learning'},
      {'icon': Icons.schedule_outlined, 'title': 'Spaced Repetition Algorithm'},
      {'icon': Icons.analytics_outlined, 'title': 'Smart Analytics'},
    ];

    return Column(
      children: [
        // First row
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildFeatureCard(
                  icon: features[0]['icon'] as IconData,
                  title: features[0]['title'] as String,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildFeatureCard(
                  icon: features[1]['icon'] as IconData,
                  title: features[1]['title'] as String,
                ),
              ),
            ),
          ],
        ),
        // Second row
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildFeatureCard(
                  icon: features[2]['icon'] as IconData,
                  title: features[2]['title'] as String,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildFeatureCard(
                  icon: features[3]['icon'] as IconData,
                  title: features[3]['title'] as String,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1.0, // Makes the card square
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Glassmorphic effect
          color: isDark
              ? colorScheme.surfaceVariant.withOpacity(0.6)
              : colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16), // Modern corner radius
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : () {
              HapticFeedback.mediumImpact();
              _handleGoogleAuth();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 18), // Increased for better touch target
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Modern corner radius
              ),
              elevation: 2,
              minimumSize: const Size(double.infinity, 56), // Minimum touch target
            ),
            child:
                authProvider.isLoading
                    ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login,
                          size: 20,
                          color: colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Get Started with Google',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }

  Future<void> _handleGoogleAuth() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      AppNavigation.goHome(context);
    }
  }
}
