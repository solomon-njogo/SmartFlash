import 'package:flutter/foundation.dart';
import '../../data/local/hive_service.dart';
import '../utils/logger.dart';

/// Onboarding preferences model
class OnboardingPreferences {
  final List<String> goals;
  final int studyTimeMinutes;
  final String learningStyle;

  OnboardingPreferences({
    required this.goals,
    required this.studyTimeMinutes,
    required this.learningStyle,
  });

  Map<String, dynamic> toJson() => {
        'goals': goals,
        'studyTimeMinutes': studyTimeMinutes,
        'learningStyle': learningStyle,
      };

  factory OnboardingPreferences.fromJson(Map<String, dynamic> json) =>
      OnboardingPreferences(
        goals: List<String>.from(json['goals'] ?? []),
        studyTimeMinutes: json['studyTimeMinutes'] ?? 15,
        learningStyle: json['learningStyle'] ?? 'Mixed',
      );
}

/// Provider for managing onboarding state
class OnboardingProvider extends ChangeNotifier {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _onboardingPreferencesKey = 'onboarding_preferences';

  bool _isLoading = false;
  OnboardingPreferences? _preferences;

  /// Whether onboarding is in progress
  bool get isLoading => _isLoading;

  /// Get stored onboarding preferences
  OnboardingPreferences? get preferences => _preferences;

  OnboardingProvider() {
    // Load preferences only if HiveService is initialized
    if (HiveService.instance.isInitialized) {
      _loadPreferences();
    }
  }

  /// Load preferences from storage
  Future<void> _loadPreferences() async {
    try {
      if (!HiveService.instance.isInitialized) {
        return;
      }
      final progressBox = HiveService.instance.progressBox;
      final prefsJson = progressBox.get(_onboardingPreferencesKey);
      if (prefsJson != null) {
        _preferences = OnboardingPreferences.fromJson(
          Map<String, dynamic>.from(prefsJson as Map),
        );
      }
    } catch (e) {
      Logger.error('Failed to load onboarding preferences: $e');
    }
  }

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    try {
      if (!HiveService.instance.isInitialized) {
        return false;
      }
      final progressBox = HiveService.instance.progressBox;
      return progressBox.get(_onboardingCompletedKey, defaultValue: false) as bool;
    } catch (e) {
      Logger.error('Failed to check onboarding status: $e');
      return false;
    }
  }

  /// Save onboarding preferences
  Future<void> savePreferences(OnboardingPreferences prefs) async {
    try {
      _setLoading(true);
      if (!HiveService.instance.isInitialized) {
        await HiveService.instance.initialize();
      }
      final progressBox = HiveService.instance.progressBox;
      await progressBox.put(_onboardingPreferencesKey, prefs.toJson());
      _preferences = prefs;
      notifyListeners();
      Logger.info('Onboarding preferences saved');
    } catch (e) {
      Logger.error('Failed to save onboarding preferences: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    try {
      _setLoading(true);
      if (!HiveService.instance.isInitialized) {
        await HiveService.instance.initialize();
      }
      final progressBox = HiveService.instance.progressBox;
      await progressBox.put(_onboardingCompletedKey, true);
      Logger.info('Onboarding marked as complete');
    } catch (e) {
      Logger.error('Failed to complete onboarding: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Get onboarding preferences
  Future<OnboardingPreferences?> getOnboardingPreferences() async {
    if (_preferences != null) return _preferences;
    await _loadPreferences();
    return _preferences;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

