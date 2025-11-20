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
              width: size ?? 24,
              height: size ?? 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? theme.colorScheme.primary,
                ),
              ),
            ),
            if (showMessage && message != null) ...[
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
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

/// Full screen loading indicator
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
      color: backgroundColor ?? theme.colorScheme.surface.withOpacity(0.8),
      child: LoadingIndicator(
        size: 32,
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

/// Skeleton loading widget
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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height ?? 20,
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ??
                BorderRadius.circular(AppConstants.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor ?? theme.colorScheme.surfaceVariant,
                widget.highlightColor ?? theme.colorScheme.surface,
                widget.baseColor ?? theme.colorScheme.surfaceVariant,
              ],
              stops:
                  [
                    _animation.value - 0.3,
                    _animation.value,
                    _animation.value + 0.3,
                  ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Card skeleton loading
class CardSkeletonLoading extends StatelessWidget {
  final double? width;
  final double? height;

  const CardSkeletonLoading({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoading(width: width ?? double.infinity, height: 20),
            const SizedBox(height: AppConstants.smallPadding),
            SkeletonLoading(width: (width ?? 200) * 0.7, height: 16),
            const SizedBox(height: AppConstants.smallPadding),
            SkeletonLoading(width: (width ?? 200) * 0.5, height: 14),
          ],
        ),
      ),
    );
  }
}
