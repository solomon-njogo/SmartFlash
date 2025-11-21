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
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate responsive padding based on screen size
    final baseWidth = 375.0;
    final scaleFactor = (screenWidth / baseWidth).clamp(0.8, 1.3);
    final horizontalPadding = (24 * scaleFactor).clamp(16.0, 32.0);
    final verticalSpacing = (40 * scaleFactor).clamp(24.0, 56.0);
    final sectionSpacing = (32 * scaleFactor).clamp(24.0, 40.0);
    final cardsSpacing = (48 * scaleFactor).clamp(32.0, 64.0);
    final bottomPadding = (24 * scaleFactor).clamp(16.0, 32.0);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      SizedBox(height: verticalSpacing),

                      // App icon section
                      _buildAppIcon(),
                      SizedBox(height: sectionSpacing),

                      // Welcome message section
                      _buildWelcomeSection(),
                      SizedBox(height: cardsSpacing),

                      // Feature cards section
                      _buildFeatureCards(),
                      SizedBox(height: verticalSpacing),
                    ],
                  ),
                ),
              ),
            ),

            // Fix button to bottom position
            Padding(
              padding: EdgeInsets.all(bottomPadding),
              child: _buildGetStartedButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = 375.0;
    final scaleFactor = (screenWidth / baseWidth).clamp(0.8, 1.3);
    final iconSize = (120 * scaleFactor).clamp(100.0, 140.0);
    final borderRadius = (24 * scaleFactor).clamp(20.0, 28.0);
    
    return AppLogo(
      size: iconSize,
      borderRadius: borderRadius,
    );
  }

  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = 375.0;
    final scaleFactor = (screenWidth / baseWidth).clamp(0.8, 1.3);
    final spacing = (12 * scaleFactor).clamp(8.0, 16.0);
    final fontSize = (16 * scaleFactor).clamp(14.0, 18.0);
    
    return Column(
      children: [
        const AppName(
          variant: AppNameVariant.branded,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing),
        Text(
          'Your smart learning companion',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: fontSize,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCards() {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = 375.0;
    final scaleFactor = (screenWidth / baseWidth).clamp(0.8, 1.3);
    final cardPadding = (6 * scaleFactor).clamp(4.0, 10.0);
    
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
                padding: EdgeInsets.all(cardPadding),
                child: _buildFeatureCard(
                  icon: features[0]['icon'] as IconData,
                  title: features[0]['title'] as String,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
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
                padding: EdgeInsets.all(cardPadding),
                child: _buildFeatureCard(
                  icon: features[2]['icon'] as IconData,
                  title: features[2]['title'] as String,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
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
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate responsive sizes based on screen dimensions
    // Base sizes for a standard phone (375px width)
    final baseWidth = 375.0;
    final scaleFactor = (screenWidth / baseWidth).clamp(0.8, 1.3);
    
    // Responsive padding (scales with screen size)
    final cardPadding = (16 * scaleFactor).clamp(12.0, 24.0);
    final verticalPadding = (6 * scaleFactor).clamp(4.0, 10.0);
    
    // Responsive icon size (scales with screen size)
    final iconContainerSize = (40 * scaleFactor).clamp(36.0, 56.0);
    final iconSize = (20 * scaleFactor).clamp(18.0, 28.0);
    
    // Responsive spacing
    final spacing = (6 * scaleFactor).clamp(4.0, 10.0);
    
    // Responsive font size
    final fontSize = (10 * scaleFactor).clamp(9.0, 13.0);
    
    // Responsive border radius
    final borderRadius = (14 * scaleFactor).clamp(12.0, 18.0);
    final iconBorderRadius = (10 * scaleFactor).clamp(8.0, 14.0);

    return AspectRatio(
      aspectRatio: 1.0, // Makes the card square
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          // Glassmorphic effect
          color: isDark
              ? colorScheme.surfaceVariant.withOpacity(0.6)
              : colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(borderRadius),
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
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 2,
                child: Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(iconBorderRadius),
                  ),
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: spacing),
              Flexible(
                flex: 3,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ),
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
