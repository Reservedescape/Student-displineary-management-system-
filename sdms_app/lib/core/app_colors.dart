import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Institutional Palette (UEAB Baraton Theme)
  static const Color primary = Color(0xFFBC6B03);      // Warm Gold / Amber
  static const Color primaryDark = Color(0xFF8C4F00);  // Deep Amber
  static const Color primaryLight = Color(0xFFFFF7ED); // Subtle Cream Tint

  static const Color navy = Color(0xFF1B2F5E);         // Baraton Royal Navy
  static const Color navyDark = Color(0xFF0F1B38);     // Midnight Navy
  static const Color navyLight = Color(0xFF2A4480);    // Slate Navy

  // Neutral Background & Surface Tokens
  static const Color background = Color(0xFFF8FAFC);  // Soft Cool Background
  static const Color surface = Color(0xFFFFFFFF);     // Pure White Surface
  static const Color cardBorder = Color(0xFFE2E8F0);  // Subtle Light Border

  // Text Color Tokens
  static const Color textPrimary = Color(0xFF0F172A); // High Contrast Dark
  static const Color textSecondary = Color(0xFF64748B); // Muted Slate Body
  static const Color textMuted = Color(0xFF94A3B8);   // Soft Subtitle / Hints

  // Functional Semantic Status Colors
  static const Color success = Color(0xFF10B981);     // Emerald Green
  static const Color successBg = Color(0xFFECFDF5);   // Emerald Tint
  
  static const Color warning = Color(0xFFF59E0B);     // Amber Warning
  static const Color warningBg = Color(0xFFFFFBEB);   // Amber Tint

  static const Color info = Color(0xFF3B82F6);        // Vibrant Blue
  static const Color infoBg = Color(0xFFEFF6FF);      // Blue Tint

  static const Color danger = Color(0xFFEF4444);      // Crimson Danger
  static const Color dangerBg = Color(0xFFFEF2F2);    // Crimson Tint

  // Gradients
  static const LinearGradient navyGradient = LinearGradient(
    colors: [navyDark, navy, navyLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFBC6B03), Color(0xFF92400E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F1B38), Color(0xFF1B2F5E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Legacy Compatibility Colors
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color inputText = Color(0xFF1E293B);
  static const Color hintText = Color(0xFF94A3B8);
  static const Color iconColor = Color(0xFFBC6B03);
}
