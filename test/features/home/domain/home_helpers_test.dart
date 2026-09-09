import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/features/home/domain/home_helpers.dart';

void main() {
  test('maps male values to the male avatar', () {
    expect(childSexFromString('boy'), ChildSex.male);
    expect(
      getChildAvatar(
        sex: childSexFromString('boy'),
        dateOfBirth: DateTime(2020),
      ),
      '👦',
    );
  });

  test('keeps an infant avatar independent of sex', () {
    expect(
      getChildAvatar(
        sex: childSexFromString('male'),
        dateOfBirth: DateTime.now().subtract(const Duration(days: 30)),
      ),
      '👶',
    );
  });
}
