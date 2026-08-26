import 'package:flutter/material.dart';

/// Supported app display languages.
/// Stored as BCP-47 language codes (`en`, `ne`) in SharedPreferences.
enum AppLanguage {
  english('en'),
  nepali('ne');

  const AppLanguage(this.code);

  final String code;

  Locale get locale => Locale(code);

  /// Parses a stored code. Unknown or null values fall back to Nepali.
  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.nepali,
    );
  }
}
