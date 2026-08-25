import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

void main() {
  group('AppLanguage.fromCode', () {
    test('maps en to english', () {
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
    });

    test('maps ne to nepali', () {
      expect(AppLanguage.fromCode('ne'), AppLanguage.nepali);
    });

    test('falls back to english when the code is null', () {
      expect(AppLanguage.fromCode(null), AppLanguage.english);
    });

    test('falls back to english when the code is unknown', () {
      expect(AppLanguage.fromCode('fr'), AppLanguage.english);
      expect(AppLanguage.fromCode(''), AppLanguage.english);
    });
  });

  group('AppLanguage.locale', () {
    test('exposes the BCP-47 code as a Locale', () {
      expect(AppLanguage.english.locale, const Locale('en'));
      expect(AppLanguage.nepali.locale, const Locale('ne'));
    });
  });
}
