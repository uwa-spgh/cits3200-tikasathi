import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/features/child/domain/date_of_birth_validation.dart';

void main() {
  group('parseValidChildDateOfBirth', () {
    final today = DateTime.now();
    final currentDay = DateTime(today.year, today.month, today.day);
    DateTime dateYearsAgo(int years) => DateTime(
          currentDay.year - years,
          currentDay.month,
          currentDay.day,
        );

    test('reports a child who is exactly 18 today as too old', () {
      final birthday = dateYearsAgo(18);
      expect(
        validateChildDateOfBirth(
          day: birthday.day,
          month: birthday.month,
          year: birthday.year,
          today: today,
        ),
        const TypeMatcher<ChildDateOfBirthValidation>(),
      );
      expect(
        validateChildDateOfBirth(
          day: birthday.day,
          month: birthday.month,
          year: birthday.year,
          today: today,
        ).error,
        ChildDateOfBirthError.tooOld,
      );
    });

    test('accepts a newborn born today', () {
      expect(
        parseValidChildDateOfBirth(
          day: currentDay.day,
          month: currentDay.month,
          year: currentDay.year,
          today: today,
        ),
        currentDay,
      );
    });

    test('accepts a one-year-old', () {
      final birthday = dateYearsAgo(1);
      expect(
        parseValidChildDateOfBirth(
          day: birthday.day,
          month: birthday.month,
          year: birthday.year,
          today: today,
        ),
        birthday,
      );
    });

    test('accepts a 17-year-old', () {
      final birthday = dateYearsAgo(17);
      expect(
        parseValidChildDateOfBirth(
          day: birthday.day,
          month: birthday.month,
          year: birthday.year,
          today: today,
        ),
        birthday,
      );
    });

    test('rejects exactly 18 and older dates', () {
      final eighteenthBirthday = dateYearsAgo(18);
      expect(
        validateChildDateOfBirth(
          day: eighteenthBirthday.day,
          month: eighteenthBirthday.month,
          year: eighteenthBirthday.year,
          today: today,
        ).error,
        ChildDateOfBirthError.tooOld,
      );
      final dayBeforeEighteenthBirthday =
          eighteenthBirthday.subtract(const Duration(days: 1));
      expect(
        validateChildDateOfBirth(
          day: dayBeforeEighteenthBirthday.day,
          month: dayBeforeEighteenthBirthday.month,
          year: dayBeforeEighteenthBirthday.year,
          today: today,
        ).error,
        ChildDateOfBirthError.tooOld,
      );
      final nineteenthBirthday = dateYearsAgo(19);
      expect(
        validateChildDateOfBirth(
          day: nineteenthBirthday.day,
          month: nineteenthBirthday.month,
          year: nineteenthBirthday.year,
          today: today,
        ).error,
        ChildDateOfBirthError.tooOld,
      );
    });

    test('rejects tomorrow as future', () {
      final tomorrow = currentDay.add(const Duration(days: 1));
      expect(
        validateChildDateOfBirth(
          day: tomorrow.day,
          month: tomorrow.month,
          year: tomorrow.year,
          today: today,
        ).error,
        ChildDateOfBirthError.future,
      );
    });

    test('rejects negative and calendar-invalid dates', () {
      expect(
        validateChildDateOfBirth(
          day: -1,
          month: -1,
          year: -100,
          today: today,
        ).error,
        ChildDateOfBirthError.invalid,
      );
      expect(
        validateChildDateOfBirth(
          day: 31,
          month: 2,
          year: 2010,
          today: today,
        ).error,
        ChildDateOfBirthError.invalid,
      );
    });

    test('handles a leap-day current date at the age boundary', () {
      final leapDay = DateTime(2024, 2, 29);
      expect(
        validateChildDateOfBirth(
          day: 28,
          month: 2,
          year: 2006,
          today: leapDay,
        ).isValid,
        isFalse,
      );
      expect(
        validateChildDateOfBirth(
          day: 1,
          month: 3,
          year: 2006,
          today: leapDay,
        ).isValid,
        isTrue,
      );
    });
  });
}
