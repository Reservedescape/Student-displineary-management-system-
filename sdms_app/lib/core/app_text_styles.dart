import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle universityName = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.3,
  );

  static const TextStyle appTitle = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    letterSpacing: 3,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 13,
    color: AppColors.white70,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  static const TextStyle forgotPassword = TextStyle(
    fontSize: 12,
    color: AppColors.white70,
  );

  static const TextStyle footerText = TextStyle(
    fontSize: 10,
    color: AppColors.white70,
    letterSpacing: 0.3,
  );
}
