import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}
