import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_name.dart';
import '../../../app/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.surface,
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
    return const AppLogo(size: 120, borderRadius: 20);
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        const AppName(
          variant: AppNameVariant.branded,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your smart learning companion',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
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
    return AspectRatio(
      aspectRatio: 1.0, // Makes the card square
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
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
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleGoogleAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child:
                authProvider.isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textOnPrimary,
                        ),
                      ),
                    )
                    : Text(
                      'Get Started',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
