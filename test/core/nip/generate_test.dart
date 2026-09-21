import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/nip/vaccine_catalogue.dart';

void main() {
  group('generate', () {
    test('produces standard NIP for child at age 0', () {
      final today = DateTime.now();
      final dues = generate(true, today, today, []);

      for (final due in dues) {
        expect(doesDoseExist(due.vaccineCode, due.doseNumber), true);
        expect(
            today.add(getDoseAge(due.vaccineCode, due.doseNumber)!.duration) ==
                due.dueDate,
            true);
      }
    });

    test('does not produce dues for existing records', () {
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

      final dues = generate(true, today, today, records);
      for (final record in records) {
        expect(
            dues.any((GeneratedDue due) =>
                due.vaccineCode == record.vaccineCode &&
                due.doseNumber == record.doseNumber),
            false);
      }
    });

    test('calculates the catch-up schedule for overdue vaccinations',
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

      final dues = generate(true, dob, today, records);
      final bopvDues = dues.where((due) => due.vaccineCode == 'BOPV');

      expect(bopvDues.length, 2,
          reason:
              'Expected 2 BOPV dues to be created, instead found ${bopvDues.length}');
      expect(
          bopvDues.any(
              (due) => due.dueDate == dob.add(getDoseAge('BOPV', 1)!.duration)),
          false);
      expect(
          bopvDues.any(
              (due) => due.dueDate == dob.add(getDoseAge('BOPV', 2)!.duration)),
          true);
      expect(
          bopvDues.any((due) =>
              due.dueDate == today.add(DayDuration(months: 1).duration)),
          true);
    });

    test('does not use catch-up schedule for completed vaccinations',
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

      final dues = generate(true, dob, today, records);
      final bopvDues = dues.where((due) => due.vaccineCode == 'BOPV');

      expect(bopvDues.length, 0);
    });

    test('does not use catch-up schedule for ongoing vaccinations',
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

      final dues = generate(true, dob, today, records);
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

    test('generates HPV schedule for girl and does not for boy', () {
      final today = DateTime.now();
      final dob = today.subtract(DayDuration(years: 9).duration);

      final boyDues = generate(false, dob, today, []);
      final girlDues = generate(true, dob, today, []);

      expect(boyDues.any((due) => due.vaccineCode == "HPV"), false);
      expect(boyDues.any((due) => due.vaccineCode == "HPV"), true);
    });

    test('does not use catch-up schedule when there is not enough time', () {
      final today = DateTime.now();
      final dob = today.subtract(DayDuration(months: 22).duration);
      final dues = generate(false, dob, today, []);
      final pcvDues = dues.where((due) => due.vaccineCode == 'PCV');

      expect(pcvDues.length, 2); // dues past max age are not dropped
      expect(pcvDues.any((due) => due.dueDate.isAfter(today)), false); // all dues are original dates, not catch-up
    });
  });

  group('status', () {
    test('correctly identifies completed vaccination', () {
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

      final dues = generate(true, dob, today, records);
      expect(status(today, dues, 'BOPV'), VaccineStatus.completed);
    });

    test('correctly identifies ongoing vaccination', () {
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

      final dues = generate(true, dob, past, records);
      final today = past.add(DayDuration(weeks: 2).duration);
      expect(status(today, dues, 'BOPV'), VaccineStatus.ongoing);
    });

    test('correctly identifies overdue vaccination', () {
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

      final dues = generate(true, dob, past, records);
      final today = past.add(DayDuration(weeks: 4).duration);
      expect(status(today, dues, 'BOPV'), VaccineStatus.overdue);
    });
  });
}
