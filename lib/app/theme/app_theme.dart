import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import '../app_text_styles.dart';

/// App theme configuration
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.textPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnSecondary,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.textPrimary,
        tertiary: AppColors.accent,
        onTertiary: AppColors.textOnPrimary,
        tertiaryContainer: AppColors.accentLight,
        onTertiaryContainer: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        background: AppColors.background,
        onBackground: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.borderLight,
        shadow: AppColors.shadow,
        scrim: AppColors.shadowDark,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.surface,
        inversePrimary: AppColors.primaryLight,
        surfaceTint: AppColors.primary,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Card theme (Enhanced with modern corner radius 16dp)
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated button theme (Enhanced with modern corner radius 12dp)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Increased vertical padding for better touch target
          minimumSize: const Size(48, 48), // Minimum touch target size
        ),
      ),

      // Text button theme (Enhanced with better touch targets)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Outlined button theme (Enhanced with modern corner radius 12dp)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(48, 48), // Minimum touch target size
        ),
      ),

      // Input decoration theme (Enhanced with modern corner radius 12dp)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16, // Increased for better touch target
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),

      // Floating action button theme (Enhanced with modern corner radius)
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // Chip theme (Enhanced with modern corner radius)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        labelStyle: AppTextStyles.bodySmall,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.borderLight,
        circularTrackColor: AppColors.borderLight,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.border;
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surface;
        }),
        checkColor: MaterialStateProperty.all(AppColors.textOnPrimary),
        side: const BorderSide(color: AppColors.border),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
      ),
    );
  }

  /// Dark theme configuration
  /// Following Material Design 3 principles and 60-30-10 color distribution rule
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme - Following Material Design 3 dark theme guidelines
      // Implementing proper color hierarchy and distribution ratios
      colorScheme: const ColorScheme.dark(
        // Primary: Desaturated blue (10% of screen - accent/highlight)
        primary: AppColors.primaryDarkTheme, // #1E88E5 - desaturated blue
        onPrimary: AppColors.textOnPrimaryDark, // Pure white for contrast
        primaryContainer:
            AppColors.primaryDarkContainer, // Darker blue for containers
        onPrimaryContainer:
            AppColors.primaryDarkLight, // Light blue tint for text
        // Secondary: Muted teal (supporting accent)
        secondary: AppColors.secondaryDarkTheme, // #4DB6AC - desaturated teal
        onSecondary: AppColors.textOnSecondaryDark, // Black for contrast
        secondaryContainer:
            AppColors.secondaryDarkContainer, // Darker teal for containers
        onSecondaryContainer: AppColors.secondaryDarkLight, // Light teal tint
        // Tertiary: Muted orange (additional accent)
        tertiary: AppColors.tertiaryDark, // #FFB74D - desaturated orange
        onTertiary: AppColors.textOnSecondaryDark, // Black for contrast
        tertiaryContainer:
            AppColors.tertiaryDarkContainer, // Darker orange for containers
        onTertiaryContainer: AppColors.tertiaryDarkLight, // Light orange tint
        // Error: Material Design 3 error colors
        error: AppColors.errorDark, // #CF6679 - desaturated red
        onError: AppColors.textOnSecondaryDark, // Black for contrast
        errorContainer: AppColors.errorDarkContainer, // Dark red container
        onErrorContainer: Color(0xFFCCCCCC), // Light red tint equivalent
        // Background: Base layer (60% of screen)
        background:
            AppColors.backgroundDark, // #121212 - Material Design 3 base
        onBackground:
            AppColors.textPrimaryDark, // 87% white opacity for primary text
        // Surface: Elevated surfaces (20% of screen)
        surface: AppColors.surfaceDark, // #1E1E1E - elevated surface
        onSurface:
            AppColors.textPrimaryDark, // 87% white opacity for primary text
        surfaceVariant:
            AppColors.surfaceVariantDark, // #2C2C2C - variant surface
        onSurfaceVariant:
            AppColors.textSecondaryDark, // 70% white opacity for secondary text
        // Outline: Subtle borders
        outline:
            AppColors
                .borderDarkTheme, // #666666 - 38% white opacity for borders
        outlineVariant:
            AppColors.borderDarkLight, // #333333 - even more subtle borders
        // Shadow and scrim
        shadow: AppColors.shadowDarkTheme, // Pure black shadows
        scrim: AppColors.shadowDarkTheme, // Pure black scrim
        // Inverse colors
        inverseSurface: AppColors.textPrimaryDark, // Inverse surface
        onInverseSurface:
            AppColors.surfaceDarkElevation3, // Dark text on inverse surface
        inversePrimary: AppColors.primaryDarkContainer, // Inverse primary
        // Surface tint - subtle blue tint on surfaces
        surfaceTint: AppColors.primaryDarkTheme, // #1E88E5 - subtle blue tint
      ),

      // App bar theme - Using elevation-based surface color
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDarkElevation2, // Elevated surface
        foregroundColor: AppColors.textPrimaryDark, // 87% white opacity
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // Card theme - Using elevation-based surface colors (Enhanced with modern corner radius 16dp)
      cardTheme: CardTheme(
        color: AppColors.surfaceDarkElevation2, // Elevated surface
        elevation: 2,
        shadowColor: AppColors.shadowDarkTheme,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated button theme - Accent color (10% of screen) (Enhanced)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkTheme, // Desaturated primary
          foregroundColor:
              AppColors.textOnPrimaryDark, // Pure white for contrast
          elevation: 2,
          shadowColor: AppColors.shadowDarkTheme,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(48, 48), // Minimum touch target size
        ),
      ),

      // Text button theme - Accent color for text (Enhanced)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDarkTheme, // Desaturated primary
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Outlined button theme - Accent color for border and text (Enhanced)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDarkTheme, // Desaturated primary
          side: const BorderSide(
            color: AppColors.primaryDarkTheme,
            width: 1.5,
          ), // Desaturated primary
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(48, 48), // Minimum touch target size
        ),
      ),

      // Input decoration theme - Using proper text hierarchy (Enhanced with modern corner radius 12dp)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            AppColors.surfaceVariantDark, // Surface variant for input fields
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.borderDarkTheme,
          ), // Subtle border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.borderDarkTheme,
          ), // Subtle border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryDarkTheme,
            width: 2,
          ), // Primary accent color
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.errorDark,
          ), // Error color
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.errorDark,
            width: 2,
          ), // Error color
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16, // Increased for better touch target
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark, // 70% white opacity for labels
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHintDark, // 38% white opacity for hints
        ),
      ),

      // Text theme - Using proper text hierarchy with opacity
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ).apply(
        bodyColor: AppColors.textPrimaryDark, // 87% white opacity
        displayColor: AppColors.textPrimaryDark, // 87% white opacity
      ),

      // Icon theme - Using proper text hierarchy
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
        size: 24,
      ),

      // Floating action button theme - Accent color (10% of screen) (Enhanced)
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDarkTheme, // Desaturated primary
        foregroundColor: AppColors.textOnPrimaryDark, // Pure white for contrast
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Bottom navigation bar theme - Using elevation-based surface
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDarkElevation2, // Elevated surface
        selectedItemColor: AppColors.primaryDarkTheme, // Desaturated primary
        unselectedItemColor: AppColors.textHintDark, // 38% white opacity
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider theme - Using subtle border colors
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDarkLight, // Subtle divider
        thickness: 1,
        space: 1,
      ),

      // Chip theme - Using surface variant and proper text hierarchy (Enhanced)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariantDark, // Surface variant
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondaryDark, // 70% white opacity
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Progress indicator theme - Using accent colors
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryDarkTheme, // Desaturated primary
        linearTrackColor: AppColors.borderDarkLight, // Subtle track
        circularTrackColor: AppColors.borderDarkLight, // Subtle track
      ),

      // Switch theme - Using proper state colors
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryDarkTheme; // Desaturated primary
          }
          return AppColors.textHintDark; // 38% white opacity
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryDarkContainer; // Primary container
          }
          return AppColors.borderDarkLight; // Subtle track
        }),
      ),

      // Checkbox theme - Using proper state colors
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryDarkTheme; // Desaturated primary
          }
          return AppColors.surfaceDarkElevation2; // Surface color
        }),
        checkColor: MaterialStateProperty.all(
          AppColors.textOnPrimaryDark,
        ), // Pure white for contrast
        side: const BorderSide(
          color: AppColors.borderDarkTheme,
        ), // Subtle border
      ),

      // Radio theme - Using proper state colors
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryDarkTheme; // Desaturated primary
          }
          return AppColors.textHintDark; // 38% white opacity
        }),
      ),
    );
  }
}
