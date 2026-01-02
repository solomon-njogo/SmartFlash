import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/router.dart';
import '../../../app/app_text_styles.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/services/permission_service.dart';

/// Permission priming screen - Contextual permission request
class OnboardingPermissionsScreen extends StatefulWidget {
  const OnboardingPermissionsScreen({super.key});

  @override
  State<OnboardingPermissionsScreen> createState() =>
      _OnboardingPermissionsScreenState();
}

class _OnboardingPermissionsScreenState
    extends State<OnboardingPermissionsScreen> {
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 40),
              // Title
              Text(
                'Enable app permissions',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Enable notifications for study reminders and storage access to upload your study materials.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 3),
              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRequesting ? null : _handleEnablePermissions,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    minimumSize: const Size(0, 56),
                  ),
                  child:
                      _isRequesting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            'Enable Permissions',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed:
                    _isRequesting
                        ? null
                        : () {
                          HapticFeedback.selectionClick();
                          _handleSkip();
                        },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
                child: Text(
                  'Maybe Later',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

  Future<void> _handleEnablePermissions() async {
    setState(() {
      _isRequesting = true;
    });

    HapticFeedback.mediumImpact();

    try {
      final permissionService = PermissionService.instance;
      
      // Request both notification and storage permissions
      final notificationGranted = await permissionService.requestNotificationPermission();
      final storageGranted = await permissionService.requestStoragePermission();

      if (notificationGranted || storageGranted) {
        // At least one permission granted
        HapticFeedback.mediumImpact();
      } else {
        // Permissions denied - that's okay, we'll continue
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Handle error gracefully
    } finally {
      setState(() {
        _isRequesting = false;
      });
    }

    // Continue to next screen regardless of permission result
    if (mounted) {
      _completeOnboarding();
    }
  }

  void _handleSkip() {
    // User skipped - continue without requesting OS permission
    // This preserves the ability to ask again later
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // Mark onboarding as complete
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    await provider.completeOnboarding();

    // Navigate to home (onboarding complete)
    if (mounted) {
      AppNavigation.pushAndRemoveUntil(context, '/home');
    }
  }
}
