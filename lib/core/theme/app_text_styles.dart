import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle h1 = TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.textPrimary);
  static const TextStyle h2 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const TextStyle h3 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const TextStyle h4 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle body = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const TextStyle bodySecondary = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const TextStyle small = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const TextStyle tiny = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted);
  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white);
  static const TextStyle label = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
}
