import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:tikasathi/core/validation/name_validation.dart';

void main() {
  group('isValidPersonName', () {
    test('accepts English and Nepali names with vowel signs and conjuncts', () {
      expect(isValidPersonName('Mary Jane'), isTrue);
      expect(isValidPersonName('सीता'), isTrue);
      expect(isValidPersonName('सुनीता'), isTrue);
      expect(isValidPersonName('प्रकाश'), isTrue);
    });

    test('accepts apostrophes, hyphens, and periods', () {
      expect(isValidPersonName("O'Connor"), isTrue);
      expect(isValidPersonName('Anne-Marie'), isTrue);
      expect(isValidPersonName('J. Smith'), isTrue);
    });

    test('trims surrounding whitespace as part of validation', () {
      expect(isValidPersonName('  Mary Jane  '), isTrue);
    });

    test('rejects empty, whitespace-only, and punctuation-only values', () {
      expect(isValidPersonName(''), isFalse);
      expect(isValidPersonName('   '), isFalse);
      expect(isValidPersonName("'-."), isFalse);
      expect(isValidPersonName('\u093e Mary'), isFalse);
    });

    test('rejects numbers and unsupported symbols', () {
      expect(isValidPersonName('Mary2'), isFalse);
      expect(isValidPersonName('Mary@Jane'), isFalse);
      expect(isValidPersonName('Mary/Jane'), isFalse);
    });
  });

  group('PersonNameInputFormatter', () {
    final formatter = PersonNameInputFormatter();

    TextEditingValue format(String text, {int? offset}) {
      final value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(
          offset: offset ?? text.length,
        ),
      );
      return formatter.formatEditUpdate(value, value);
    }

    test('keeps valid English, Nepali, and name punctuation', () {
      for (final name in <String>[
        'Mary Jane',
        "O'Connor",
        'Anne-Marie',
        'J. Smith',
        'सीता',
        'सुनीता',
        'प्रकाश',
      ]) {
        expect(format(name).text, name);
      }
    });

    test('filters numbers and unsupported symbols from typed or pasted text',
        () {
      expect(format('Mary2 @Jane/').text, 'Mary Jane');
    });

    test('keeps combining marks during active IME composition', () {
      const composing = TextRange(start: 0, end: 2);
      const value = TextEditingValue(
        text: 'सी',
        selection: TextSelection.collapsed(offset: 2),
        composing: composing,
      );

      expect(formatter.formatEditUpdate(value, value), value);
    });

    test('preserves a usable cursor after filtering', () {
      final result = format('Mary2 Jane', offset: 6);
      expect(result.text, 'Mary Jane');
      expect(result.selection.baseOffset, 5);
      expect(result.selection.extentOffset, 5);
    });

    test('preserves a usable selection after filtering', () {
      const oldValue = TextEditingValue(
        text: 'Mary Jane',
        selection: TextSelection(baseOffset: 0, extentOffset: 9),
      );
      const newValue = TextEditingValue(
        text: 'Mary2 Jane',
        selection: TextSelection(baseOffset: 0, extentOffset: 10),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, 'Mary Jane');
      expect(result.selection.baseOffset, 0);
      expect(result.selection.extentOffset, 9);
    });
  });
}
