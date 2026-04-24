import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Soft Aurora Palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color secondaryLight = Color(0xFFFF8FB5);
  static const Color accent = Color(0xFF4ECDC4);
  static const Color accentLight = Color(0xFF6EDED6);

  // Status Colors
  static const Color success = Color(0xFF51CF66);
  static const Color warning = Color(0xFFFFB84D);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF339AF0);

  // Light Mode Colors
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF2D3436);
  static const Color textSecondaryLight = Color(0xFF636E72);
  static const Color dividerLight = Color(0xFFDFE6E9);

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF1A1B2E);
  static const Color surfaceDark = Color(0xFF252642);
  static const Color textPrimaryDark = Color(0xFFECEFF4);
  static const Color textSecondaryDark = Color(0xFFB2BEC3);
  static const Color dividerDark = Color(0xFF3B3C5F);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
