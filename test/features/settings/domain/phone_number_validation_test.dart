import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:tikasathi/features/settings/domain/phone_number_validation.dart';

void main() {
  TextEditingValue format(String value, {int? cursor}) {
    final int offset = cursor ?? value.length;
    return const PhoneNumberInputFormatter().formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: offset),
      ),
    );
  }

  group('isValidPhoneNumber', () {
    test('accepts digits and an optional leading plus', () {
      expect(isValidPhoneNumber('9800000000', allowEmpty: false), isTrue);
      expect(isValidPhoneNumber('+9800000000', allowEmpty: false), isTrue);
    });

    test('rejects letters, spaces, and a plus without digits', () {
      expect(isValidPhoneNumber('98 00000000', allowEmpty: false), isFalse);
      expect(isValidPhoneNumber('98abc', allowEmpty: false), isFalse);
      expect(isValidPhoneNumber('+', allowEmpty: false), isFalse);
    });

    test('allows empty values only when configured', () {
      expect(isValidPhoneNumber('', allowEmpty: true), isTrue);
      expect(isValidPhoneNumber('', allowEmpty: false), isFalse);
    });
  });

  group('normalizePhoneNumber', () {
    test('removes spaces while preserving digits and a leading plus', () {
      expect(
        normalizePhoneNumber('+977 984 123 4567'),
        '+9779841234567',
      );
    });
  });

  group('PhoneNumberInputFormatter', () {
    test('allows digits, a leading plus, and spaces after digits', () {
      expect(format('+977 984 123 4567').text, '+977 984 123 4567');
      expect(format('9841234567').text, '9841234567');
    });

    test('filters letters and unsupported symbols from pasted text', () {
      expect(format(r'abc+977 984@123#456$7').text, '+977 9841234567');
    });

    test('rejects plus signs in the middle and repeated plus signs', () {
      expect(format('984+123').text, '984123');
      expect(format('++977+984').text, '+977984');
    });

    test('allows empty and partial input', () {
      expect(format('').text, isEmpty);
      expect(format('+').text, '+');
      expect(format('984 ').text, '984 ');
    });

    test('preserves a usable cursor after filtering', () {
      final result = format('98a4', cursor: 3);
      expect(result.text, '984');
      expect(result.selection.baseOffset, 2);
    });

    test('preserves a usable selection after filtering', () {
      final result = const PhoneNumberInputFormatter().formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '98a45',
          selection: TextSelection(baseOffset: 1, extentOffset: 4),
        ),
      );
      expect(result.text, '9845');
      expect(result.selection.baseOffset, 1);
      expect(result.selection.extentOffset, 3);
    });
  });
}
