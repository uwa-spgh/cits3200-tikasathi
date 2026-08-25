import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/nip/vaccine_catalogue.dart';

void main() {
  group('generate', () {
    test('generate produces standard NIP for child at age 0', () {
      final today = DateTime.now();
      final dues = generate(today, today, []);

      for (final due in dues) {
        expect(doesDoseExist(due.vaccineCode, due.doseNumber), true);
        expect(
            today.add(getDoseAge(due.vaccineCode, due.doseNumber)!.duration) ==
                due.dueDate,
            true);
      }
    });

    test('generate does not produce dues for existing records', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final records = <AdministeredDose>[
        (vaccineCode: 'BCG', doseNumber: 1, administeredDate: yesterday),
        (vaccineCode: 'BOPV', doseNumber: 1, administeredDate: yesterday),
        (vaccineCode: 'BOPV', doseNumber: 2, administeredDate: yesterday),
        (vaccineCode: 'BOPV', doseNumber: 3, administeredDate: yesterday),
        (vaccineCode: 'PCV', doseNumber: 1, administeredDate: yesterday),
        (vaccineCode: 'PCV', doseNumber: 2, administeredDate: yesterday),
      ];

      final dues = generate(today, today, records);
      for (final record in records) {
        expect(
            dues.any((GeneratedDue due) =>
                due.vaccineCode == record.vaccineCode &&
                due.doseNumber == record.doseNumber),
            false);
      }
    });

    test('generate calculates the catch-up schedule for overdue vaccinations',
        () {
      final today = DateTime.now();
      final dob = today.subtract(DayDuration(weeks: 12).duration);
      final records = <AdministeredDose>[
        (
          vaccineCode: 'BOPV',
          doseNumber: 1,
          administeredDate: dob.add(DayDuration(weeks: 6).duration)
        ),
      ];

      final dues = generate(dob, today, records);
      final bopvDues = dues.where((due) => due.vaccineCode == 'BOPV');

      expect(bopvDues.length, 2,
          reason:
              'Expected 2 BOPV dues to be created, instead found ${bopvDues.length}');
      expect(
          bopvDues.any(
              (due) => due.dueDate == dob.add(getDoseAge('BOPV', 1)!.duration)),
          false);
      expect(
          bopvDues
              .any((due) => due.dueDate == today.add(const Duration(days: 1))),
          true);
      expect(
          bopvDues.any((due) =>
              due.dueDate ==
              today.add(
                  DayDuration(months: 1).duration + const Duration(days: 1))),
          true);
    });

    test('generate does not use catch-up schedule for completed vaccinations',
        () {
      final today = DateTime.now();
      final dob = today.subtract(DayDuration(weeks: 16).duration);
      final records = <AdministeredDose>[
        (
          vaccineCode: 'BOPV',
          doseNumber: 1,
          administeredDate: dob.add(DayDuration(weeks: 6).duration)
        ),
        (
          vaccineCode: 'BOPV',
          doseNumber: 2,
          administeredDate: dob.add(DayDuration(weeks: 10).duration)
        ),
        (
          vaccineCode: 'BOPV',
          doseNumber: 3,
          administeredDate: dob.add(DayDuration(weeks: 14).duration)
        ),
      ];

      final dues = generate(dob, today, records);
      final bopvDues = dues.where((due) => due.vaccineCode == 'BOPV');

      expect(bopvDues.length, 0);
    });

    test('generate does not use catch-up schedule for ongoing vaccinations',
        () {
      final today = DateTime.now();
      final dob = today.subtract(DayDuration(weeks: 9).duration);
      final records = <AdministeredDose>[
        (
          vaccineCode: 'BOPV',
          doseNumber: 1,
          administeredDate: dob.add(DayDuration(weeks: 6).duration)
        ),
      ];

      final dues = generate(dob, today, records);
      final bopvDues = dues.where((due) => due.vaccineCode == 'BOPV');

      expect(bopvDues.length, 2);
      expect(
          bopvDues.any(
              (due) => due.dueDate == dob.add(getDoseAge('BOPV', 2)!.duration)),
          true);
      expect(
          bopvDues.any(
              (due) => due.dueDate == dob.add(getDoseAge('BOPV', 3)!.duration)),
          true);
    });
  });

  group('status', () {
    test('status correctly identifies completed vaccination', () {
      final today = DateTime.now();
      final dob = today.subtract(DayDuration(weeks: 16).duration);
      final records = <AdministeredDose>[
        (
          vaccineCode: 'BOPV',
          doseNumber: 1,
          administeredDate: dob.add(DayDuration(weeks: 6).duration)
        ),
        (
          vaccineCode: 'BOPV',
          doseNumber: 2,
          administeredDate: dob.add(DayDuration(weeks: 10).duration)
        ),
        (
          vaccineCode: 'BOPV',
          doseNumber: 3,
          administeredDate: dob.add(DayDuration(weeks: 14).duration)
        ),
      ];

      final dues = generate(dob, today, records);
      expect(status(today, dues, 'BOPV'), VaccineStatus.completed);
    });

    test('status correctly identifies ongoing vaccination', () {
      final past = DateTime.now();
      final dob = past.subtract(DayDuration(weeks: 11).duration);
      final records = <AdministeredDose>[
        (
          vaccineCode: 'BOPV',
          doseNumber: 1,
          administeredDate: dob.add(DayDuration(weeks: 6).duration)
        ),
        (
          vaccineCode: 'BOPV',
          doseNumber: 2,
          administeredDate: dob.add(DayDuration(weeks: 10).duration)
        ),
      ];

      final dues = generate(dob, past, records);
      final today = past.add(DayDuration(weeks: 2).duration);
      expect(status(today, dues, 'BOPV'), VaccineStatus.ongoing);
    });

    test('status correctly identifies overdue vaccination', () {
      final past = DateTime.now();
      final dob = past.subtract(DayDuration(weeks: 11).duration);
      final records = <AdministeredDose>[
        (
          vaccineCode: 'BOPV',
          doseNumber: 1,
          administeredDate: dob.add(DayDuration(weeks: 6).duration)
        ),
        (
          vaccineCode: 'BOPV',
          doseNumber: 2,
          administeredDate: dob.add(DayDuration(weeks: 10).duration)
        ),
      ];

      final dues = generate(dob, past, records);
      final today = past.add(DayDuration(weeks: 4).duration);
      expect(status(today, dues, 'BOPV'), VaccineStatus.overdue);
    });
  });
}
