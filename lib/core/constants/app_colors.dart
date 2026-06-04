import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color secondaryPink = Color(0xFFEC4899);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentBlue = Color(0xFF3B82F6);

  static const Color backgroundDeep = Color(0xFF020617);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color cardBackground = Color(0xFF1E293B);
  static const Color cardLight = Color(0xFF334155);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceElevated = Color(0xFF172033);
  static const Color borderSoft = Color(0x1AFFFFFF);

  static const Color primary = primaryPurple;
  static const Color background = backgroundDark;

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, secondaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentCyan, accentTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient appBackgroundGradient = LinearGradient(
    colors: [backgroundDeep, backgroundDark, Color(0xFF111827)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color primaryBlue = primaryPurple;
  static const Color secondaryBlue = secondaryPink;
  static const Color purple = primaryPurple;
}
