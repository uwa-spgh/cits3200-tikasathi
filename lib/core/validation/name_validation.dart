import 'package:flutter/services.dart';

final RegExp _nameLetter = RegExp(r'^\p{L}$', unicode: true);
final RegExp _nameMark = RegExp(r'^\p{M}$', unicode: true);
final RegExp _nameSpace = RegExp(r'^\p{Zs}$', unicode: true);

bool isAllowedPersonNameCharacter(String character) {
  return _nameLetter.hasMatch(character) ||
      _nameMark.hasMatch(character) ||
      _nameSpace.hasMatch(character) ||
      character == '.' ||
      character == "'" ||
      character == '-';
}

bool isValidPersonName(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) return false;

  var hasLetter = false;
  var canContinueMark = false;
  for (final int rune in trimmed.runes) {
    final character = String.fromCharCode(rune);
    if (_nameLetter.hasMatch(character)) {
      hasLetter = true;
      canContinueMark = true;
    } else if (_nameMark.hasMatch(character)) {
      if (!canContinueMark) return false;
      canContinueMark = true;
    } else if (_nameSpace.hasMatch(character) ||
        character == '.' ||
        character == "'" ||
        character == '-') {
      canContinueMark = false;
    } else {
      return false;
    }
  }
  return hasLetter;
}

class PersonNameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }

    final buffer = StringBuffer();
    var oldOffset = 0;
    var newOffset = 0;
    var selectionBase = newValue.selection.baseOffset;
    var selectionExtent = newValue.selection.extentOffset;

    for (final int rune in newValue.text.runes) {
      final character = String.fromCharCode(rune);
      final characterLength = character.length;
      if (isAllowedPersonNameCharacter(character)) {
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
