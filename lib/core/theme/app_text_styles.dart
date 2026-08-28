import 'package:flutter/material.dart';
import 'package:mobile_hexy/core/theme/app_colors.dart';

abstract final class AppTextStyles {
  static const pageTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );
  static const body = TextStyle(color: AppColors.primary, fontSize: 14);
  static const caption = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
  );
}
