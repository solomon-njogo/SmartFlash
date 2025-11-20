import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Theme provider for managing app theme state
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isSystemTheme = true;

  /// Whether dark mode is enabled
  bool get isDarkMode => _isDarkMode;

  /// Whether system theme is being used
  bool get isSystemTheme => _isSystemTheme;

  /// Toggle dark mode
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _isSystemTheme = false;
    notifyListeners();
  }

  /// Set dark mode
  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    _isSystemTheme = false;
    notifyListeners();
  }

  /// Use system theme
  void useSystemTheme() {
    _isSystemTheme = true;
    notifyListeners();
  }

  /// Get current theme mode
  ThemeMode get themeMode {
    if (_isSystemTheme) {
      return ThemeMode.system;
    }
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

/// Settings provider for managing app settings
class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _hapticFeedbackEnabled = true;
  String _language = 'en';
  int _studyReminderHour = 9;
  int _studyReminderMinute = 0;

  /// Whether notifications are enabled
  bool get notificationsEnabled => _notificationsEnabled;

  /// Whether sound is enabled
  bool get soundEnabled => _soundEnabled;

  /// Whether haptic feedback is enabled
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;

  /// Current language
  String get language => _language;

  /// Study reminder hour
  int get studyReminderHour => _studyReminderHour;

  /// Study reminder minute
  int get studyReminderMinute => _studyReminderMinute;

  /// Toggle notifications
  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  /// Toggle sound
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  /// Toggle haptic feedback
  void toggleHapticFeedback() {
    _hapticFeedbackEnabled = !_hapticFeedbackEnabled;
    notifyListeners();
  }

  /// Set language
  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }

  /// Set study reminder time
  void setStudyReminderTime(int hour, int minute) {
    _studyReminderHour = hour;
    _studyReminderMinute = minute;
    notifyListeners();
  }

  /// Reset all settings to default
  void resetToDefaults() {
    _notificationsEnabled = true;
    _soundEnabled = true;
    _hapticFeedbackEnabled = true;
    _language = 'en';
    _studyReminderHour = 9;
    _studyReminderMinute = 0;
    notifyListeners();
  }
}
