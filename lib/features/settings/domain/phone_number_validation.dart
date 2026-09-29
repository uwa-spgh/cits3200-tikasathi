bool isValidPhoneNumber(String phone, {required bool allowEmpty}) {
  if (phone.isEmpty) {
    return allowEmpty;
  }
  return RegExp(r'^\+?\d+$').hasMatch(phone);
}
