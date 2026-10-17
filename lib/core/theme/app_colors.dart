import 'package:flutter/material.dart';

/// Enterprise color palette for NEXUS People.
/// Tailored for high-end corporate presentation with clear visual hierarchy.
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryHover = Color(0xFF4338CA); // Indigo 700
  static const Color primaryLight = Color(0xFFEEF2FF); // Indigo 50
  static const Color primaryMuted = Color(0xFFC7D2FE); // Indigo 200

  // Deep Navy Tones
  static const Color navyDark = Color(0xFF0F172A); // Slate 900
  static const Color navyMedium = Color(0xFF1E293B); // Slate 800
  static const Color navySurface = Color(0xFF1E2433);
  static const Color navyLight = Color(0xFF334155); // Slate 700

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceHover = Color(0xFFF8FAFC);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderDark = Color(0xFFCBD5E1); // Slate 300
  static const Color borderLight = Color(0xFFF1F5F9);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A); // Deep Navy
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textInverse = Color(0xFFFFFFFF);

  // Status & Functional Colors
  // Green - Active / Success
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successDark = Color(0xFF059669); // Emerald 600
  static const Color successBg = Color(0xFFECFDF5); // Emerald 50
  static const Color successBorder = Color(0xFFA7F3D0);

  // Amber - On Leave / Pending
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningDark = Color(0xFFD97706); // Amber 600
  static const Color warningBg = Color(0xFFFFFBEB); // Amber 50
  static const Color warningBorder = Color(0xFFFDE68A);

  // Red - Terminated / Danger / Delete
  static const Color danger = Color(0xFFEF4444); // Red 500
  static const Color dangerDark = Color(0xFFDC2626); // Red 600
  static const Color dangerBg = Color(0xFFFEF2F2); // Red 50
  static const Color dangerBorder = Color(0xFFFECACA);

  // Purple / Violet - Probation
  static const Color info = Color(0xFF8B5CF6); // Violet 500
  static const Color infoDark = Color(0xFF7C3AED); // Violet 600
  static const Color infoBg = Color(0xFFF5F3FF); // Violet 50
  static const Color infoBorder = Color(0xFFDDD6FE);

  // Department Accent Colors for Badges and Charts
  static const List<Color> departmentPalette = [
    Color(0xFF4F46E5), // Engineering - Indigo
    Color(0xFF06B6D4), // Product - Cyan
    Color(0xFFEC4899), // Human Resources - Pink
    Color(0xFF10B981), // Finance - Emerald
    Color(0xFFF59E0B), // Marketing - Amber
    Color(0xFF8B5CF6), // Sales - Violet
    Color(0xFF0284C7), // Operations - Sky
    Color(0xFF64748B), // Legal - Slate
  ];

  // Subtle Corporate Elevation Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x040F172A),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> hoverShadow = [
    BoxShadow(
      color: Color(0x120F172A),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}
