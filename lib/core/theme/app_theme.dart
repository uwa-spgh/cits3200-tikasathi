import 'package:flutter/material.dart';

/// The centralised app theme for TikaSathi.
///
/// All feature screens should use `Theme.of(context)` to access these values
/// rather than defining inline styles. This ensures visual consistency across
/// the entire application.
class AppTheme {
  AppTheme._(); // Prevent instantiation

  /// Primary seed colour — used by Material 3 to derive the full palette.
  static const Color _seedColor = Color(0xFF0D47A1);

  /// Light theme (default).
  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
    ),
    useMaterial3: true,
    // Large touch targets for low-literacy / accessibility users
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
  );

  /// Dark theme (optional — can be toggled by the user later).
  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
  );
}
