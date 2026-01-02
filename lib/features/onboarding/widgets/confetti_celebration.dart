import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Confetti celebration widget for victory moments
class ConfettiCelebration extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;

  const ConfettiCelebration({
    super.key,
    this.onComplete,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final Random _random = Random();
  final int _particleCount = 50;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _particleCount,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ),
      );
    }).toList();

    // Start all animations
    for (final controller in _controllers) {
      controller.forward();
    }

    // Trigger haptic feedback
    HapticFeedback.mediumImpact();

    // Call onComplete after duration
    Future.delayed(widget.duration, () {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(_particleCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            final progress = _animations[index].value;
            final startX = _random.nextDouble() * MediaQuery.of(context).size.width;
            final endX = startX + (_random.nextDouble() - 0.5) * 200;
            final currentX = startX + (endX - startX) * progress;
            final currentY = progress * MediaQuery.of(context).size.height * 1.5;
            final rotation = progress * 2 * pi;
            final opacity = 1.0 - progress;

            return Positioned(
              left: currentX,
              top: currentY,
              child: Transform.rotate(
                angle: rotation,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getRandomColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];
    return colors[_random.nextInt(colors.length)];
  }
}

