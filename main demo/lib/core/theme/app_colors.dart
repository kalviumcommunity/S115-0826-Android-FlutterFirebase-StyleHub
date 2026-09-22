import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette (Rose / Salon Luxury)
  static const Color primary = Color(0xFFE11D48); // Rose 600
  static const Color primaryHover = Color(0xFFBE123C); // Rose 700
  static const Color primaryLight = Color(0xFFFFF1F2); // Rose 50
  static const Color primaryMuted = Color(0xFFFDA4AF); // Rose 300

  // Secondary & Accents
  static const Color secondary = Color(0xFF0F172A); // Slate 900
  static const Color accent = Color(0xFFD97706); // Amber 600
  static const Color accentLight = Color(0xFFFEF3C7); // Amber 100

  // Neutrals / Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color divider = Color(0xFFCBD5E1); // Slate 300

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textInverse = Colors.white;

  // Status Indicators
  static const Color statusPending = Color(0xFFD97706); // Amber 600
  static const Color statusPendingBg = Color(0xFFFEF3C7);
  static const Color statusConfirmed = Color(0xFF2563EB); // Blue 600
  static const Color statusConfirmedBg = Color(0xFFDBEAFE);
  static const Color statusCompleted = Color(0xFF059669); // Emerald 600
  static const Color statusCompletedBg = Color(0xFFD1FAE5);
  static const Color statusCancelled = Color(0xFFDC2626); // Red 600
  static const Color statusCancelledBg = Color(0xFFFEE2E2);

  // Role Badges
  static const Color roleCustomer = Color(0xFFE11D48);
  static const Color roleStaff = Color(0xFF2563EB);
  static const Color roleAdmin = Color(0xFF7C3AED);
}
