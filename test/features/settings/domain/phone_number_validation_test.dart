import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/features/settings/domain/phone_number_validation.dart';

void main() {
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
}
