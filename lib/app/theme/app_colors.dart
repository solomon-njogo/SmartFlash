import 'package:flutter/material.dart';

/// App color constants for consistent theming
/// Following Material Design 3 principles and dark theme best practices
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ===== LIGHT THEME COLORS =====

  // Primary colors - Light theme (Enhanced with vibrant, accessible colors)
  static const Color primary = Color(0xFF1976D2); // More vibrant blue
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryContainer = Color(0xFFE3F2FD);

  // Secondary colors - Light theme
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryDark = Color(0xFF018786);
  static const Color secondaryLight = Color(0xFF66FFF9);

  // Accent colors - Light theme
  static const Color accent = Color(0xFFFF9800);
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);

  // Background colors - Light theme (Enhanced for better contrast)
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceContainer = Color(0xFFEEEEEE);

  // Text colors - Light theme (Enhanced for better readability - AA/AAA compliant)
  static const Color textPrimary = Color(0xFF1A1A1A); // Higher contrast
  static const Color textSecondary = Color(0xFF616161); // Better contrast
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF000000);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Border colors - Light theme
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color borderDark = Color(0xFFBDBDBD);

  // Shadow colors (Enhanced for better depth perception)
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowDark = Color(0x33000000);
  static const Color shadowMedium = Color(0x1F000000);

  // Glassmorphism/Backdrop blur colors
  static const Color glassBackground = Color(0x80FFFFFF);
  static const Color glassBorder = Color(0x1FFFFFFF);

  // ===== DARK THEME COLORS =====
  // Following Material Design 3 dark theme guidelines and 60-30-10 distribution rule

  // Primary colors - Dark theme (desaturated for comfort)
  static const Color primaryDarkTheme = Color(0xFF1E88E5); // Desaturated blue
  static const Color primaryDarkContainer = Color(
    0xFF0D47A1,
  ); // Darker blue for containers
  static const Color primaryDarkLight = Color(0xFF90CAF9); // Lighter tint

  // Secondary colors - Dark theme
  static const Color secondaryDarkTheme = Color(0xFF4DB6AC); // Desaturated teal
  static const Color secondaryDarkContainer = Color(0xFF00695C); // Darker teal
  static const Color secondaryDarkLight = Color(0xFF80CBC4); // Lighter tint

  // Tertiary colors - Dark theme
  static const Color tertiaryDark = Color(0xFFFFB74D); // Desaturated orange
  static const Color tertiaryDarkContainer = Color(0xFFE65100); // Darker orange
  static const Color tertiaryDarkLight = Color(0xFFFFCC80); // Lighter tint

  // Error colors - Dark theme
  static const Color errorDark = Color(0xFFCF6679); // Desaturated red
  static const Color errorDarkContainer = Color(
    0xFF93000A,
  ); // Dark red container

  // Background colors - Dark theme (60% of screen)
  static const Color backgroundDark = Color(
    0xFF121212,
  ); // Material Design 3 base
  static const Color surfaceDark = Color(
    0xFF1E1E1E,
  ); // Elevated surface (20% of screen)
  static const Color surfaceVariantDark = Color(0xFF2C2C2C); // Variant surface

  // Elevation-based surface colors for proper depth hierarchy (Enhanced)
  static const Color surfaceDarkElevation1 = Color(0xFF1A1A1A);
  static const Color surfaceDarkElevation2 = Color(0xFF1E1E1E);
  static const Color surfaceDarkElevation3 = Color(0xFF242424);
  static const Color surfaceDarkElevation4 = Color(0xFF2A2A2A);
  static const Color surfaceDarkElevation5 = Color(0xFF303030);

  // Glassmorphism for dark theme
  static const Color glassBackgroundDark = Color(0x801E1E1E);
  static const Color glassBorderDark = Color(0x1FFFFFFF);

  // Text colors - Dark theme with proper opacity hierarchy
  static const Color textPrimaryDark = Color(0xFFE1E1E1); // 87% white opacity
  static const Color textSecondaryDark = Color(0xFFB3B3B3); // 70% white opacity
  static const Color textHintDark = Color(0xFF666666); // 38% white opacity
  static const Color textOnPrimaryDark = Color(0xFFFFFFFF); // Pure white
  static const Color textOnSecondaryDark = Color(0xFF000000); // Pure black

  // Border colors - Dark theme
  static const Color borderDarkTheme = Color(0xFF666666); // 38% white opacity
  static const Color borderDarkLight = Color(0xFF333333); // Even more subtle
  static const Color borderDarkDark = Color(
    0xFF999999,
  ); // Slightly more visible

  // Shadow colors - Dark theme
  static const Color shadowDarkTheme = Color(0xFF000000); // Pure black shadows
  static const Color shadowDarkLight = Color(0x1A000000); // Subtle shadow
  static const Color shadowDarkDark = Color(0x33000000); // Stronger shadow

  // ===== GRADIENT COLORS =====

  // Light theme gradients (Enhanced with soft, modern gradients)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient primaryGradientSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, surfaceVariant],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDark],
  );

  // Dark theme gradients (Enhanced)
  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDarkTheme, primaryDarkContainer],
  );

  static const LinearGradient primaryGradientDarkSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDarkLight, primaryDarkTheme],
  );

  static const LinearGradient surfaceGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceDark, surfaceDarkElevation2],
  );

  static const LinearGradient secondaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryDarkTheme, secondaryDarkContainer],
  );

  static const LinearGradient accentGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tertiaryDark, tertiaryDarkContainer],
  );

  // ===== UTILITY METHODS =====

  /// Get surface color based on elevation level
  /// Following Material Design 3 elevation principles
  static Color getSurfaceColorForElevation(int elevation) {
    switch (elevation) {
      case 0:
        return backgroundDark;
      case 1:
        return surfaceDarkElevation1;
      case 2:
        return surfaceDarkElevation2;
      case 3:
        return surfaceDarkElevation3;
      case 4:
        return surfaceDarkElevation4;
      case 5:
        return surfaceDarkElevation5;
      default:
        return surfaceDarkElevation2; // Default to elevation 2
    }
  }

  /// Get text color based on hierarchy level
  /// Following Material Design 3 text hierarchy principles
  static Color getTextColorForHierarchy(TextHierarchy hierarchy) {
    switch (hierarchy) {
      case TextHierarchy.primary:
        return textPrimaryDark; // 87% opacity
      case TextHierarchy.secondary:
        return textSecondaryDark; // 70% opacity
      case TextHierarchy.hint:
        return textHintDark; // 38% opacity
      case TextHierarchy.disabled:
        return textHintDark.withOpacity(0.2); // Even more subtle
    }
  }

  /// Get border color based on state
  static Color getBorderColorForState(BorderState state) {
    switch (state) {
      case BorderState.normal:
        return borderDarkTheme;
      case BorderState.focused:
        return primaryDarkTheme;
      case BorderState.error:
        return errorDark;
      case BorderState.disabled:
        return borderDarkLight;
    }
  }
}

/// Text hierarchy levels for proper opacity distribution
enum TextHierarchy {
  primary, // 87% opacity - main content
  secondary, // 70% opacity - supporting content
  hint, // 38% opacity - placeholder text
  disabled, // 20% opacity - disabled text
}

/// Border states for proper color selection
enum BorderState {
  normal, // Default border
  focused, // Focused state
  error, // Error state
  disabled, // Disabled state
}
