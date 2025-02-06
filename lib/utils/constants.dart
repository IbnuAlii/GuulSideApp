import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF40E0D0);
  static const Color secondary = Color(0xFF3498DB);
  static const Color background = Colors.white;
  static const Color text = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF788485);
  static const Color accent = Color(0xFFF3F7F8);
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}

class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;
}
