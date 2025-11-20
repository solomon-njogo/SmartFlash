import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/settings_provider.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer2<ThemeProvider, SettingsProvider>(
        builder: (context, themeProvider, settingsProvider, child) {
          return ListView(
            children: [
              // Theme settings
              _buildSectionHeader(context, 'Appearance'),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.setDarkMode(value),
              ),
              SwitchListTile(
                title: const Text('System Theme'),
                subtitle: const Text('Follow system theme'),
                value: themeProvider.isSystemTheme,
                onChanged: (value) => themeProvider.useSystemTheme(),
              ),

              const Divider(),

              // Notification settings
              _buildSectionHeader(context, 'Notifications'),
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Enable push notifications'),
                value: settingsProvider.notificationsEnabled,
                onChanged: (value) => settingsProvider.toggleNotifications(),
              ),

              const Divider(),

              // Study settings
              _buildSectionHeader(context, 'Study'),
              SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Play sounds during study'),
                value: settingsProvider.soundEnabled,
                onChanged: (value) => settingsProvider.toggleSound(),
              ),
              SwitchListTile(
                title: const Text('Haptic Feedback'),
                subtitle: const Text('Vibrate on interactions'),
                value: settingsProvider.hapticFeedbackEnabled,
                onChanged: (value) => settingsProvider.toggleHapticFeedback(),
              ),

              const Divider(),

              // Language settings
              _buildSectionHeader(context, 'Language'),
              ListTile(
                title: const Text('Language'),
                subtitle: Text(_getLanguageName(settingsProvider.language)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(context, settingsProvider),
              ),

              const Divider(),

              // Study reminder
              _buildSectionHeader(context, 'Study Reminder'),
              ListTile(
                title: const Text('Daily Reminder'),
                subtitle: Text(
                  '${settingsProvider.studyReminderHour.toString().padLeft(2, '0')}:'
                  '${settingsProvider.studyReminderMinute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTimePicker(context, settingsProvider),
              ),

              const Divider(),

              // Reset settings
              _buildSectionHeader(context, 'Reset'),
              ListTile(
                title: const Text('Reset to Defaults'),
                subtitle: const Text('Reset all settings to default values'),
                trailing: const Icon(Icons.restore),
                onTap: () => _showResetDialog(context, settingsProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(
                  context,
                  settingsProvider,
                  'en',
                  'English',
                ),
                _buildLanguageOption(
                  context,
                  settingsProvider,
                  'es',
                  'Spanish',
                ),
                _buildLanguageOption(context, settingsProvider, 'fr', 'French'),
                _buildLanguageOption(context, settingsProvider, 'de', 'German'),
              ],
            ),
          ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    SettingsProvider settingsProvider,
    String code,
    String name,
  ) {
    return ListTile(
      title: Text(name),
      trailing:
          settingsProvider.language == code
              ? Icon(Icons.check, color: Theme.of(context).primaryColor)
              : null,
      onTap: () {
        settingsProvider.setLanguage(code);
        Navigator.of(context).pop();
      },
    );
  }

  void _showTimePicker(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settingsProvider.studyReminderHour,
        minute: settingsProvider.studyReminderMinute,
      ),
    ).then((time) {
      if (time != null) {
        settingsProvider.setStudyReminderTime(time.hour, time.minute);
      }
    });
  }

  void _showResetDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Settings'),
            content: const Text(
              'Are you sure you want to reset all settings to default values?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  settingsProvider.resetToDefaults();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings reset to defaults')),
                  );
                },
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }
}
