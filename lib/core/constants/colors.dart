import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7B61FF);
  static const Color accent = Color(0xFFFF4D9D);
  static const Color background = Color(0xFF0D0F23);
  static const Color surface = Color(0xFF16182F);
  static const Color primaryText = Color(0xFFF5F7FF);
  static const Color secondaryText = Color(0xFFB8B9D6);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFACC15);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
