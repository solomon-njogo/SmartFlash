import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Custom loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  final String? message;
  final bool showMessage;
  final EdgeInsets? padding;

  const LoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.message,
    this.showMessage = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size ?? 32, // Slightly larger default
              height: size ?? 32,
              child: CircularProgressIndicator(
                strokeWidth: 3, // Slightly thicker for better visibility
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? theme.colorScheme.primary,
                ),
              ),
            ),
            if (showMessage && message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 16, // Ensure readable size
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full screen loading indicator (Enhanced with backdrop)
class FullScreenLoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const FullScreenLoadingIndicator({
    super.key,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: backgroundColor ??
          theme.colorScheme.surface.withOpacity(0.95), // More opaque
      child: LoadingIndicator(
        size: 40, // Larger for full screen
        message: message ?? 'Loading...',
        showMessage: true,
      ),
    );
  }
}

/// Button loading indicator
class ButtonLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const ButtonLoadingIndicator({super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}

/// Linear loading indicator
class LinearLoadingIndicator extends StatelessWidget {
  final double? value;
  final Color? backgroundColor;
  final Color? valueColor;
  final String? message;
  final bool showMessage;

  const LinearLoadingIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.valueColor,
    this.message,
    this.showMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          value: value,
          backgroundColor: backgroundColor ?? theme.colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            valueColor ?? theme.colorScheme.primary,
          ),
        ),
        if (showMessage && message != null) ...[
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            message!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Skeleton loading widget (Enhanced with shimmer effect)
class SkeletonLoading extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200), // Faster, smoother animation
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height ?? 20,
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ??
                BorderRadius.circular(16), // Modern corner radius
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor ??
                    (isDark
                        ? theme.colorScheme.surfaceVariant
                        : theme.colorScheme.surfaceVariant),
                widget.highlightColor ??
                    (isDark
                        ? theme.colorScheme.surface
                        : theme.colorScheme.surface),
                widget.baseColor ??
                    (isDark
                        ? theme.colorScheme.surfaceVariant
                        : theme.colorScheme.surfaceVariant),
              ],
              stops:
                  [
                    (_animation.value - 0.5).clamp(0.0, 1.0),
                    _animation.value.clamp(0.0, 1.0),
                    (_animation.value + 0.5).clamp(0.0, 1.0),
                  ],
            ),
          ),
        );
      },
    );
  }
}

/// Card skeleton loading (Enhanced)
class CardSkeletonLoading extends StatelessWidget {
  final double? width;
  final double? height;

  const CardSkeletonLoading({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Modern corner radius
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonLoading(
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoading(
                        width: width ?? double.infinity,
                        height: 20,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 8),
                      SkeletonLoading(
                        width: (width ?? 200) * 0.7,
                        height: 16,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SkeletonLoading(
              width: (width ?? 200) * 0.5,
              height: 14,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }
}

/// Course card skeleton loading
class CourseCardSkeleton extends StatelessWidget {
  const CourseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonLoading(
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoading(
                        width: double.infinity,
                        height: 20,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 8),
                      SkeletonLoading(
                        width: 200,
                        height: 16,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SkeletonLoading(
                  width: 60,
                  height: 24,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 12),
                SkeletonLoading(
                  width: 60,
                  height: 24,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 12),
                SkeletonLoading(
                  width: 60,
                  height: 24,
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// List skeleton loading
class ListSkeletonLoading extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const ListSkeletonLoading({
    super.key,
    this.itemCount = 3,
    Widget Function(BuildContext, int)? itemBuilder,
  }) : itemBuilder = itemBuilder ?? _defaultItemBuilder;

  static Widget _defaultItemBuilder(BuildContext context, int index) {
    return const CardSkeletonLoading();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
