import 'package:flutter/material.dart';
import '../app_text_styles.dart';
import 'app_colors.dart';
import '../../core/constants/app_constants.dart';

/// App name styling system for consistent branding across the app
class AppNameStyles {
  // Private constructor to prevent instantiation
  AppNameStyles._();

  /// Large app name style for splash screens and hero sections
  static const TextStyle splash = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: AppColors.primary,
    height: 1.2,
  );

  /// Medium app name style for headers and titles
  static const TextStyle header = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Small app name style for app bars and navigation
  static const TextStyle appBar = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// Compact app name style for small spaces
  static const TextStyle compact = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  /// Branded app name style with gradient effect
  static const TextStyle branded = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
    color: AppColors.primary,
    height: 1.2,
  );

  /// Subtle app name style for secondary contexts
  static const TextStyle subtle = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
    height: 1.2,
  );

  /// Logo-style app name for branding elements
  static const TextStyle logo = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    color: AppColors.primary,
    height: 1.1,
  );

  /// App name with tagline style
  static const TextStyle withTagline = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Tagline style to accompany app name
  static const TextStyle tagline = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
    height: 1.2,
  );

  /// App name style for cards and widgets
  static const TextStyle card = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// App name style for buttons and interactive elements
  static const TextStyle button = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: AppColors.textOnPrimary,
    height: 1.1,
  );

  /// App name style for dark themes
  static const TextStyle dark = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textOnPrimary,
    height: 1.3,
  );

  /// App name style for light themes
  static const TextStyle light = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// App name style with shadow effect
  static TextStyle shadowed({
    Color shadowColor = AppColors.shadow,
    double blurRadius = 4.0,
    Offset offset = const Offset(0, 2),
  }) {
    return const TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
      color: AppColors.textPrimary,
      height: 1.2,
    ).copyWith(
      shadows: [
        Shadow(color: shadowColor, blurRadius: blurRadius, offset: offset),
      ],
    );
  }

  /// App name style with outline effect
  static TextStyle outlined({
    Color strokeColor = AppColors.primary,
    double strokeWidth = 2.0,
  }) {
    return TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
      color: AppColors.textPrimary,
      height: 1.2,
      foreground:
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = strokeColor,
    );
  }

  /// App name style with gradient effect
  static TextStyle gradient({
    List<Color> colors = const [AppColors.primary, AppColors.primaryDark],
  }) {
    return TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
      height: 1.2,
      foreground:
          Paint()
            ..shader = LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
    );
  }
}

/// Reusable app name widget with consistent styling
class AppName extends StatelessWidget {
  /// The app name variant to display
  final AppNameVariant variant;

  /// Custom text style override
  final TextStyle? style;

  /// If true (default), the text color adapts to the active theme
  /// to ensure proper contrast in light/dark modes. Set to false to
  /// preserve the color defined in [style] or the variant's default.
  final bool useThemeColor;

  /// Optional explicit color override. If provided, this wins over
  /// [useThemeColor] computed color.
  final Color? color;

  /// Text alignment
  final TextAlign? textAlign;

  /// Maximum number of lines
  final int? maxLines;

  /// Text overflow behavior
  final TextOverflow? overflow;

  /// Whether to show the tagline
  final bool showTagline;

  /// Custom tagline text
  final String? customTagline;

  /// Tagline style
  final TextStyle? taglineStyle;

  const AppName({
    super.key,
    this.variant = AppNameVariant.header,
    this.style,
    this.useThemeColor = true,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.showTagline = false,
    this.customTagline,
    this.taglineStyle,
  });

  @override
  Widget build(BuildContext context) {
    final appNameStyle = _getStyleForVariant(variant);
    final baseStyle = style ?? appNameStyle;

    // Determine effective color
    TextStyle effectiveStyle = baseStyle;
    final Color? explicit = color;
    if (explicit != null) {
      effectiveStyle = baseStyle.copyWith(color: explicit);
    } else if (useThemeColor) {
      final cs = Theme.of(context).colorScheme;
      Color themedColor;
      switch (variant) {
        case AppNameVariant.button:
          themedColor = cs.onPrimary;
          break;
        case AppNameVariant.appBar:
          themedColor = cs.onSurface;
          break;
        case AppNameVariant.dark:
          themedColor = cs.onPrimary;
          break;
        case AppNameVariant.light:
          themedColor = cs.onBackground;
          break;
        default:
          themedColor = cs.onBackground;
      }
      effectiveStyle = baseStyle.copyWith(color: themedColor);
    }

    if (showTagline) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppConstants.appName,
            style: effectiveStyle,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          ),
          const SizedBox(height: 4),
          Text(
            customTagline ?? AppConstants.appDescription,
            style: taglineStyle ?? AppNameStyles.tagline,
            textAlign: textAlign,
          ),
        ],
      );
    }

    return Text(
      AppConstants.appName,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextStyle _getStyleForVariant(AppNameVariant variant) {
    switch (variant) {
      case AppNameVariant.splash:
        return AppNameStyles.splash;
      case AppNameVariant.header:
        return AppNameStyles.header;
      case AppNameVariant.appBar:
        return AppNameStyles.appBar;
      case AppNameVariant.compact:
        return AppNameStyles.compact;
      case AppNameVariant.branded:
        return AppNameStyles.branded;
      case AppNameVariant.subtle:
        return AppNameStyles.subtle;
      case AppNameVariant.logo:
        return AppNameStyles.logo;
      case AppNameVariant.withTagline:
        return AppNameStyles.withTagline;
      case AppNameVariant.card:
        return AppNameStyles.card;
      case AppNameVariant.button:
        return AppNameStyles.button;
      case AppNameVariant.dark:
        return AppNameStyles.dark;
      case AppNameVariant.light:
        return AppNameStyles.light;
    }
  }
}

/// App name variants for different contexts
enum AppNameVariant {
  /// Large style for splash screens and hero sections
  splash,

  /// Medium style for headers and titles
  header,

  /// Style for app bars and navigation
  appBar,

  /// Compact style for small spaces
  compact,

  /// Branded style with primary color
  branded,

  /// Subtle style for secondary contexts
  subtle,

  /// Logo-style for branding elements
  logo,

  /// Style designed to work with taglines
  withTagline,

  /// Style for cards and widgets
  card,

  /// Style for buttons and interactive elements
  button,

  /// Style for dark themes
  dark,

  /// Style for light themes
  light,
}

/// App name with special effects
class AppNameWithEffect extends StatelessWidget {
  /// The effect type to apply
  final AppNameEffect effect;

  /// Effect-specific parameters
  final Map<String, dynamic>? effectParams;

  /// Text alignment
  final TextAlign? textAlign;

  /// Maximum number of lines
  final int? maxLines;

  /// Text overflow behavior
  final TextOverflow? overflow;

  const AppNameWithEffect({
    super.key,
    required this.effect,
    this.effectParams,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyleForEffect(effect, effectParams);

    return Text(
      AppConstants.appName,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextStyle _getStyleForEffect(
    AppNameEffect effect,
    Map<String, dynamic>? params,
  ) {
    switch (effect) {
      case AppNameEffect.shadowed:
        return AppNameStyles.shadowed(
          shadowColor: params?['shadowColor'] ?? AppColors.shadow,
          blurRadius: params?['blurRadius'] ?? 4.0,
          offset: params?['offset'] ?? const Offset(0, 2),
        );
      case AppNameEffect.outlined:
        return AppNameStyles.outlined(
          strokeColor: params?['strokeColor'] ?? AppColors.primary,
          strokeWidth: params?['strokeWidth'] ?? 2.0,
        );
      case AppNameEffect.gradient:
        return AppNameStyles.gradient(
          colors:
              params?['colors'] ??
              const [AppColors.primary, AppColors.primaryDark],
        );
    }
  }
}

/// App name effect types
enum AppNameEffect {
  /// Text with shadow effect
  shadowed,

  /// Text with outline effect
  outlined,

  /// Text with gradient effect
  gradient,
}
