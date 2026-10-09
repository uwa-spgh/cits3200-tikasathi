import 'package:flutter/services.dart';

String normalizePhoneNumber(String phone) {
  return phone.replaceAll(RegExp(r'\s'), '');
}

bool isValidPhoneNumber(String phone, {required bool allowEmpty}) {
  if (phone.isEmpty) {
    return allowEmpty;
  }
  return RegExp(r'^\+?\d+$').hasMatch(phone);
}

class PhoneNumberInputFormatter extends TextInputFormatter {
  const PhoneNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    var oldOffset = 0;
    var newOffset = 0;
    var selectionBase = newValue.selection.baseOffset;
    var selectionExtent = newValue.selection.extentOffset;
    var hasDigit = false;
    var hasLeadingPlus = false;

    for (final int rune in newValue.text.runes) {
      final character = String.fromCharCode(rune);
      final characterLength = character.length;
      final isDigit = RegExp(r'^\d$').hasMatch(character);
      final isSpace = RegExp(r'^\s$').hasMatch(character);
      final isLeadingPlus =
          character == '+' && !hasLeadingPlus && !hasDigit && buffer.isEmpty;

      if (isDigit) {
        hasDigit = true;
        buffer.write(character);
        newOffset += characterLength;
      } else if (isSpace && hasDigit) {
        buffer.write(character);
        newOffset += characterLength;
      } else if (isLeadingPlus) {
        hasLeadingPlus = true;
        buffer.write(character);
        newOffset += characterLength;
      }

      final nextOldOffset = oldOffset + characterLength;
      if (oldOffset < newValue.selection.baseOffset &&
          nextOldOffset >= newValue.selection.baseOffset) {
        selectionBase = newOffset;
      }
      if (oldOffset < newValue.selection.extentOffset &&
          nextOldOffset >= newValue.selection.extentOffset) {
        selectionExtent = newOffset;
      }
      oldOffset = nextOldOffset;
    }

    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection(
        baseOffset: selectionBase.clamp(0, newOffset),
        extentOffset: selectionExtent.clamp(0, newOffset),
      ),
      composing: TextRange.empty,
    );
  }
}
