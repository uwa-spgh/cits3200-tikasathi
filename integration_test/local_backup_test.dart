import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/services/local_backup_service.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:tikasathi/main.dart' as app;

const String _backupFileName = 'tikasathi-backup-device.json';
const String _childName = 'आरव';
const String _caregiverName = 'Sita';
const String _caregiverPhone = '9801234567';
const String _caregiverAddress = 'काठमाडौं-४';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const String phase =
      String.fromEnvironment('BACKUP_PHASE', defaultValue: 'export');

  testWidgets(
    'onboards, records a dose, and exports a backup file',
    (WidgetTester tester) async {
      await _launch(tester);
      await _onboardAndRecord(tester);

      final ProviderContainer container = _container(tester);
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File(p.join(directory.path, _backupFileName));
      await container.read(localBackupServiceProvider).exportToFile(file.path);

      final Map<String, dynamic> document =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final List<dynamic> children =
          document['childProfiles']! as List<dynamic>;
      final List<dynamic> records =
          document['vaccinationRecords']! as List<dynamic>;
      final List<dynamic> reminders = document['reminders']! as List<dynamic>;
      expect(children, hasLength(1));
      expect(
        (children.single as Map<String, dynamic>)['name'],
        _childName,
      );
      expect(
        records.map(
          (dynamic row) => (row as Map<String, dynamic>)['vaccineCode'],
        ),
        contains('BCG'),
      );
      expect(reminders, isNotEmpty);
      expect(
        (document['caregiver']! as Map<String, dynamic>)['name'],
        _caregiverName,
      );
      expect(
        (document['caregiver']! as Map<String, dynamic>)['address'],
        _caregiverAddress,
      );
      debugPrint(
        'EXPORT_OK path=${file.path} records=${records.length} '
        'reminders=${reminders.length}',
      );
      await Future<void>.delayed(const Duration(seconds: 20));
    },
    skip: phase != 'export',
    timeout: const Timeout(Duration(minutes: 6)),
  );

  testWidgets(
    'imports the pushed backup and rejects a wrong file',
    (WidgetTester tester) async {
      await _launch(tester);
      final ProviderContainer container = _container(tester);
      final Directory directory = await getApplicationDocumentsDirectory();
      await File(p.join(directory.path, 'backup-import-waiting'))
          .writeAsString('1');
      final File file = File(p.join(directory.path, _backupFileName));
      debugPrint('WAITING_FOR_BACKUP ${file.path}');

      final DateTime deadline =
          DateTime.now().add(const Duration(seconds: 120));
      while (!file.existsSync() || file.lengthSync() == 0) {
        if (DateTime.now().isAfter(deadline)) {
          fail('Backup file was not pushed to ${file.path}');
        }
        await tester.pump(const Duration(milliseconds: 400));
      }

      final LocalBackupService service =
          container.read(localBackupServiceProvider);
      await service.importFromFile(file.path);

      final AppDatabase database = container.read(appDatabaseProvider);
      final BackupRows rows = await database.backupDao.readAll();
      final Map<String, dynamic> document =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      _expectIds(
        rows.childProfiles.map((ChildProfile row) => row.id),
        document['childProfiles'],
      );
      _expectIds(
        rows.vaccinationRecords.map((VaccinationRecord row) => row.id),
        document['vaccinationRecords'],
      );
      _expectIds(
        rows.reminders.map((Reminder row) => row.id),
        document['reminders'],
      );
      _expectClock(
        rows.childProfiles.map(
          (ChildProfile row) => (id: row.id, when: row.dateOfBirth),
        ),
        document['childProfiles'],
        'dateOfBirth',
      );
      _expectClock(
        rows.vaccinationRecords.map(
          (VaccinationRecord row) => (id: row.id, when: row.administeredDate),
        ),
        document['vaccinationRecords'],
        'administeredDate',
      );
      _expectClock(
        rows.reminders.map(
          (Reminder row) => (id: row.id, when: row.scheduledFor),
        ),
        document['reminders'],
        'scheduledFor',
      );
      expect(
        rows.childProfiles.map((ChildProfile row) => row.name),
        contains(_childName),
      );
      expect(
        rows.vaccinationRecords.map((VaccinationRecord row) => row.vaccineCode),
        contains('BCG'),
      );

      final List<Reminder> pending =
          await database.remindersDao.getPendingReminders();
      expect(pending, isNotEmpty);

      final Map<String, String?> caregiver = await container
          .read(secureStorageServiceProvider)
          .getCaregiverProfile();
      expect(caregiver['name'], _caregiverName);
      expect(caregiver['phone'], _caregiverPhone);
      expect(caregiver['address'], _caregiverAddress);

      final File wrong = File(p.join(directory.path, 'not-a-backup.txt'));
      await wrong.writeAsString('this is not a backup');
      final List<String> childIds =
          rows.childProfiles.map((ChildProfile row) => row.id).toList()..sort();
      final List<String> recordIds = rows.vaccinationRecords
          .map((VaccinationRecord row) => row.id)
          .toList()
        ..sort();
      final List<String> reminderIds =
          rows.reminders.map((Reminder row) => row.id).toList()..sort();

      await expectLater(
        service.importFromFile(wrong.path),
        throwsA(isA<BackupValidationException>()),
      );

      final BackupRows after = await database.backupDao.readAll();
      expect(
        (after.childProfiles.map((ChildProfile row) => row.id).toList()
          ..sort()),
        childIds,
      );
      expect(
        (after.vaccinationRecords
            .map((VaccinationRecord row) => row.id)
            .toList()
          ..sort()),
        recordIds,
      );
      expect(
        (after.reminders.map((Reminder row) => row.id).toList()..sort()),
        reminderIds,
      );
      expect(
        (after.childProfiles.single.dateOfBirth).toIso8601String(),
        rows.childProfiles.single.dateOfBirth.toIso8601String(),
      );

      debugPrint(
        'IMPORT_OK children=${rows.childProfiles.length} '
        'records=${rows.vaccinationRecords.length} '
        'reminders=${rows.reminders.length} pending=${pending.length}',
      );
      await File(p.join(directory.path, 'import-ok')).writeAsString('1');
      await Future<void>.delayed(const Duration(seconds: 25));
    },
    skip: phase != 'import',
    timeout: const Timeout(Duration(minutes: 4)),
  );

  testWidgets(
    'shows the backup section in Nepali',
    (WidgetTester tester) async {
      await _launch(tester);
      await _pumpUntil(tester, find.text('Settings'));
      await tester.tap(find.text('Settings'));
      await tester.pump(const Duration(milliseconds: 400));

      await _pumpUntil(tester, find.text('DEBUG: Test Notifications'));
      await tester.ensureVisible(find.text('DEBUG: Test Notifications'));
      await tester.tap(find.text('DEBUG: Test Notifications'));
      await _pumpUntil(
        tester,
        find.textContaining('registered with device'),
      );
      final Text snackbar = tester.widget<Text>(
        find.textContaining('registered with device'),
      );
      debugPrint('REMINDER_STATUS ${snackbar.data}');

      await Future<void>.delayed(const Duration(seconds: 7));
      await tester.pump(const Duration(milliseconds: 300));

      final Finder nepali = find.text('Nepali');
      await tester.ensureVisible(nepali);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(nepali);
      await _pumpUntil(tester, find.text('ब्याकअप'));
      await tester.ensureVisible(find.text('ब्याकअप'));
      await tester.pump(const Duration(milliseconds: 400));

      final Directory directory = await getApplicationDocumentsDirectory();
      await File(p.join(directory.path, 'screenshot-ready')).writeAsString('1');
      debugPrint('SCREEN_READY');
      await Future<void>.delayed(const Duration(seconds: 20));
    },
    skip: phase != 'screenshot',
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

Future<void> _launch(WidgetTester tester) async {
  await app.main();
  await tester.pump();
}

Future<void> _onboardAndRecord(WidgetTester tester) async {
  await _pumpUntil(tester, find.text('🇬🇧'));
  await tester.tap(find.text('🇬🇧'));
  await _pumpUntil(tester, find.text('Continue'));

  await _tapLabeled(tester, 'Continue');
  await _pumpUntil(tester, find.byType(TextField));
  await _enterFromEnd(tester, 3, _caregiverName);
  await _enterFromEnd(tester, 2, _caregiverPhone);
  await _enterFromEnd(tester, 1, _caregiverAddress);
  await _tapLabeled(tester, 'Continue');

  await _pumpUntil(tester, find.text('Boy'));
  await _enterFromEnd(tester, 4, _childName);
  await _enterFromEnd(tester, 3, '19');
  await _enterFromEnd(tester, 2, '09');
  await _enterFromEnd(tester, 1, '2026');
  await tester.tap(find.text('Boy'));
  await tester.pump(const Duration(milliseconds: 200));
  await _tapLabeled(tester, 'Continue');

  await _pumpUntil(tester, find.textContaining('BCG'));
  await tester.ensureVisible(find.textContaining('BCG').first);
  await tester.tap(find.textContaining('BCG').first);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text('Finish'));

  final DateTime deadline = DateTime.now().add(const Duration(seconds: 40));
  while (find.text('Settings').evaluate().isEmpty) {
    if (find.text('OK').evaluate().isNotEmpty &&
        find.text('Missed Vaccines').evaluate().isNotEmpty) {
      await tester.tap(find.text('OK'));
      await tester.pump(const Duration(milliseconds: 300));
    }
    if (DateTime.now().isAfter(deadline)) {
      fail('Onboarding did not reach the home screen.');
    }
    await tester.pump(const Duration(milliseconds: 200));
  }
}

ProviderContainer _container(WidgetTester tester) {
  return ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final DateTime deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      final String visible = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text text) => text.data ?? '')
          .where((String data) => data.isNotEmpty)
          .join(' | ');
      fail('Timed out waiting for $finder. Visible text: $visible');
    }
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _tapLabeled(WidgetTester tester, String label) async {
  final Finder button = find.widgetWithText(ElevatedButton, label);
  await tester.ensureVisible(button.last);
  await tester.tap(button.last);
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _enterFromEnd(
  WidgetTester tester,
  int fromEnd,
  String value,
) async {
  final Finder fields = find.byType(TextField);
  final Finder field = fields.at(fields.evaluate().length - fromEnd);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump(const Duration(milliseconds: 100));
}

void _expectIds(Iterable<String> actual, Object? jsonRows) {
  final List<dynamic> rows = jsonRows! as List<dynamic>;
  final Set<String> expected = <String>{
    for (final dynamic row in rows)
      (row as Map<String, dynamic>)['id']! as String,
  };
  expect(actual.toSet(), expected);
  expect(actual.length, rows.length);
}

void _expectClock(
  Iterable<({String id, DateTime when})> actual,
  Object? jsonRows,
  String field,
) {
  final Map<String, String> expected = <String, String>{
    for (final dynamic row in jsonRows! as List<dynamic>)
      (row as Map<String, dynamic>)['id']! as String: row[field]! as String,
  };
  for (final ({String id, DateTime when}) row in actual) {
    expect(row.when.toIso8601String(), expected[row.id]);
  }
}
