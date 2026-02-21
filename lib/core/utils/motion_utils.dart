import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MotionUtils {
  /// Defines the standard duration for structural animations
  static const Duration durationStandard = Duration(milliseconds: 300);
  static const Duration durationFast = Duration(milliseconds: 150);
  
  /// Global curve for Apple-like smoothness
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// Apples standard button scale effect (haptic down)
  static Widget scaleButtonEffect({
    required Widget child,
    required VoidCallback onTap,
  }) {
    // Basic implementation using GestureDetector or InkWell
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: child, // Usually would wrap in an AnimatedScale for the full effect
    );
  }

  /// Apple-level list load animation (Staggered Fade & Slide)
  static Widget listLoadEffect(Widget child, int index) {
    return child.animate()
        .fade(duration: durationStandard, delay: (index * 50).ms)
        .slideY(begin: 0.1, end: 0, duration: durationStandard, curve: defaultCurve);
  }
}
