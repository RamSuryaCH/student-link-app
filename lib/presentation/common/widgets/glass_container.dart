import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:student_link_app/core/constants/colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const GlassContainer({
    Key? key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: -5,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            color: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }
}
