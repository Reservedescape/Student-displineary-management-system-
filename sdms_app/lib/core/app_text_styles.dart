import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle universityName = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.white70,
    letterSpacing: 0.8,
  );

  static const TextStyle appTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: 1.5,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 13,
    color: AppColors.white70,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
    letterSpacing: 0.5,
  );

  static const TextStyle forgotPassword = TextStyle(
    fontSize: 13,
    color: AppColors.white70,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle footerText = TextStyle(
    fontSize: 11,
    color: AppColors.white70,
    letterSpacing: 0.5,
  );
}
