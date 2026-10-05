import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/reminders/reminder_schedule.dart';
import 'package:tikasathi/core/reminders/reminder_scheduler.dart';
import 'package:tikasathi/core/services/local_backup_service.dart';
import 'package:tikasathi/core/services/notification_service.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

import '../../helpers/fake_settings_repository.dart';

class _MockNotificationService extends Mock implements NotificationService {}

void main() {
  group('LocalBackupService', () {
    late AppDatabase database;
    late _MemoryProfileStore profiles;
    late FakeSettingsRepository settings;
    late int rescheduleCalls;
    late LocalBackupService service;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      profiles = _MemoryProfileStore();
      settings = FakeSettingsRepository(language: AppLanguage.nepali);
      rescheduleCalls = 0;
      service = LocalBackupService(
        database: database,
        profiles: profiles,
        settings: settings,
        rescheduleReminders: () async {
          rescheduleCalls += 1;
        },
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('fileNameFor uses the local calendar day', () {
      expect(
        LocalBackupService.fileNameFor(DateTime(2026, 10, 3)),
        'tikasathi-backup-2026-10-03.json',
      );
    });

    test('round trip restores rows, profile, language, and reminders',
        () async {
      final BackupRows original = await _seed(database);
      profiles.caregiver = <String, String?>{
        'name': 'Maya',
        'phone': '9800000000',
        'address': 'Ward 4',
      };
      profiles.onboardingCompleted = true;
      settings.language = AppLanguage.english;

      final String json = await service.buildBackupJson(
        createdAt: DateTime(2026, 10, 3, 9),
      );
      final Map<String, dynamic> document =
          jsonDecode(json) as Map<String, dynamic>;
      expect(document['app'], 'tikasathi');
      expect(document['backupVersion'], 1);
      expect(document['schemaVersion'], database.schemaVersion);
      expect(document['createdAt'], '2026-10-03T09:00:00.000');
      expect(document['language'], 'en');
      expect(document['onboardingCompleted'], isTrue);

      await database.backupDao.replaceAll(BackupRows.empty);
      profiles.caregiver = <String, String?>{
        'name': null,
        'phone': null,
        'address': null,
      };
      profiles.onboardingCompleted = false;
      settings.language = AppLanguage.nepali;
      rescheduleCalls = 0;

      await service.importJson(json);

      _expectRows(await database.backupDao.readAll(), original);
      expect(profiles.caregiver['name'], 'Maya');
      expect(profiles.caregiver['phone'], '9800000000');
      expect(profiles.caregiver['address'], 'Ward 4');
      expect(profiles.onboardingCompleted, isTrue);
      expect(settings.language, AppLanguage.english);
      expect(rescheduleCalls, 1);
    });

    test('an invalid file changes nothing', () async {
      await _seed(database);
      profiles.caregiver = <String, String?>{
        'name': 'Maya',
        'phone': '9800000000',
        'address': 'Ward 4',
      };
      profiles.onboardingCompleted = true;
      settings.language = AppLanguage.english;
      final String valid = await service.buildBackupJson();
      final BackupRows before = await database.backupDao.readAll();

      final Map<String, dynamic> wrongApp =
          jsonDecode(valid) as Map<String, dynamic>;
      wrongApp['app'] = 'other-app';
      final Map<String, dynamic> newerSchema =
          jsonDecode(valid) as Map<String, dynamic>;
      newerSchema['schemaVersion'] = database.schemaVersion + 1;
      final Map<String, dynamic> missingKeys =
          jsonDecode(valid) as Map<String, dynamic>;
      missingKeys.remove('childProfiles');
      final Map<String, dynamic> newerBackup =
          jsonDecode(valid) as Map<String, dynamic>;
      newerBackup['backupVersion'] = 2;

      final List<(String, BackupRejection)> rejected =
          <(String, BackupRejection)>[
        (jsonEncode(wrongApp), BackupRejection.wrongApp),
        (jsonEncode(newerSchema), BackupRejection.unsupportedSchemaVersion),
        (jsonEncode(missingKeys), BackupRejection.missingKeys),
        (jsonEncode(newerBackup), BackupRejection.unsupportedBackupVersion),
        ('not json', BackupRejection.missingKeys),
      ];

      for (final (String json, BackupRejection reason) in rejected) {
        await expectLater(
          service.importJson(json),
          throwsA(
            isA<BackupValidationException>().having(
              (BackupValidationException error) => error.reason,
              'reason',
              reason,
            ),
          ),
        );
      }

      _expectRows(await database.backupDao.readAll(), before);
      expect(profiles.caregiver['name'], 'Maya');
      expect(profiles.onboardingCompleted, isTrue);
      expect(settings.language, AppLanguage.english);
      expect(rescheduleCalls, 0);
    });

    test('a foreign-key failure halfway through import rolls back', () async {
      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'original',
          name: 'Original',
          dateOfBirth: DateTime(2023, 4, 15),
          sex: 'female',
        ),
      );
      profiles.caregiver = <String, String?>{
        'name': 'Maya',
        'phone': null,
        'address': null,
      };
      settings.language = AppLanguage.nepali;

      final String json = jsonEncode(<String, Object?>{
        'app': 'tikasathi',
        'backupVersion': 1,
        'schemaVersion': database.schemaVersion,
        'createdAt': '2026-10-03T09:00:00.000',
        'childProfiles': <Map<String, Object?>>[
          <String, Object?>{
            'id': 'imported',
            'name': 'Imported',
            'dateOfBirth': '2024-01-02T00:00:00.000',
            'sex': 'male',
            'isSetupComplete': true,
          },
        ],
        'vaccinationRecords': <Object?>[],
        'vaccinationDues': <Object?>[],
        'reminders': <Map<String, Object?>>[
          <String, Object?>{
            'id': 'reminder-1',
            'childId': 'imported',
            'dueId': 'missing-due',
            'kind': ReminderKind.sameDay.name,
            'scheduledFor': '2026-10-04T09:00:00.000',
            'notificationId': 1,
            'deliveredAt': null,
          },
        ],
        'healthFacilitators': <Object?>[],
        'caregiver': <String, Object?>{
          'name': 'Sita',
          'phone': '9800000001',
          'address': 'Ward 5',
        },
        'language': 'en',
        'onboardingCompleted': false,
      });

      await expectLater(service.importJson(json), throwsA(isA<Object>()));

      final List<ChildProfile> children =
          await database.childProfilesDao.getAllChildProfiles();
      expect(children.map((ChildProfile child) => child.name), ['Original']);
      expect((await database.remindersDao.getPendingReminders()), isEmpty);
      expect(profiles.caregiver['name'], 'Maya');
      expect(settings.language, AppLanguage.nepali);
      expect(profiles.onboardingCompleted, isTrue);
      expect(rescheduleCalls, 0);
    });

    test('a failure after the database write restores the previous data',
        () async {
      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'original',
          name: 'Original',
          dateOfBirth: DateTime(2023, 4, 15),
          sex: 'female',
        ),
      );
      profiles.caregiver = <String, String?>{
        'name': 'Maya',
        'phone': '9800000000',
        'address': 'Ward 4',
      };
      settings.language = AppLanguage.nepali;
      final LocalBackupService failing = LocalBackupService(
        database: database,
        profiles: profiles,
        settings: settings,
        rescheduleReminders: () async {
          throw StateError('notifications unavailable');
        },
      );

      final String json = jsonEncode(<String, Object?>{
        'app': 'tikasathi',
        'backupVersion': 1,
        'schemaVersion': database.schemaVersion,
        'createdAt': '2026-10-03T09:00:00.000',
        'childProfiles': <Map<String, Object?>>[
          <String, Object?>{
            'id': 'imported',
            'name': 'Imported',
            'dateOfBirth': '2024-01-02T00:00:00.000',
            'sex': 'male',
            'isSetupComplete': false,
          },
        ],
        'vaccinationRecords': <Object?>[],
        'vaccinationDues': <Object?>[],
        'reminders': <Object?>[],
        'healthFacilitators': <Object?>[],
        'caregiver': <String, Object?>{
          'name': 'Sita',
          'phone': '9800000001',
          'address': 'Ward 5',
        },
        'language': 'en',
        'onboardingCompleted': false,
      });

      await expectLater(
        failing.importJson(json),
        throwsA(isA<StateError>()),
      );

      final List<ChildProfile> children =
          await database.childProfilesDao.getAllChildProfiles();
      expect(children.single.name, 'Original');
      expect(profiles.caregiver['name'], 'Maya');
      expect(profiles.caregiver['phone'], '9800000000');
      expect(settings.language, AppLanguage.nepali);
      expect(profiles.onboardingCompleted, isTrue);
    });

    test('a failed rollback still reports the original error', () async {
      final _BrokenRollbackStore brokenProfiles = _BrokenRollbackStore();
      final LocalBackupService failing = LocalBackupService(
        database: database,
        profiles: brokenProfiles,
        settings: settings,
        rescheduleReminders: () async {
          throw StateError('notifications unavailable');
        },
      );
      final String json = await service.buildBackupJson();

      await expectLater(
        failing.importJson(json),
        throwsA(
          isA<StateError>().having(
            (StateError e) => e.message,
            'message',
            'notifications unavailable',
          ),
        ),
      );
    });

    test('an empty database exports and imports cleanly', () async {
      profiles.caregiver = <String, String?>{
        'name': null,
        'phone': null,
        'address': null,
      };
      profiles.onboardingCompleted = false;
      settings.language = AppLanguage.nepali;

      final String json = await service.buildBackupJson(
        createdAt: DateTime(2026, 10, 3, 9),
      );

      await _seed(database);
      profiles.caregiver = <String, String?>{
        'name': 'Maya',
        'phone': '9800000000',
        'address': 'Ward 4',
      };
      profiles.onboardingCompleted = true;
      settings.language = AppLanguage.english;

      await service.importJson(json);

      final BackupRows rows = await database.backupDao.readAll();
      expect(rows.childProfiles, isEmpty);
      expect(rows.vaccinationRecords, isEmpty);
      expect(rows.vaccinationDues, isEmpty);
      expect(rows.reminders, isEmpty);
      expect(rows.healthFacilitators, isEmpty);
      expect(profiles.caregiver['name'], isNull);
      expect(profiles.caregiver['phone'], isNull);
      expect(profiles.caregiver['address'], isNull);
      expect(profiles.onboardingCompleted, isFalse);
      expect(settings.language, AppLanguage.nepali);
    });

    test('several children each keep their records, dues, and reminders',
        () async {
      await _insertBundle(
        database,
        childId: 'child-1',
        name: 'Aarav Sharma',
        dateOfBirth: DateTime(2020, 1, 2, 8),
        sex: 'male',
        administeredDate: DateTime(2020, 3, 2, 9, 15),
        facilityName: 'Ward clinic',
        dueDate: DateTime(2020, 2, 13, 8),
        scheduledFor: DateTime(2026, 11, 1, 8),
      );
      await _insertBundle(
        database,
        childId: 'child-2',
        name: 'Maya Gurung',
        dateOfBirth: DateTime(2021, 5, 6, 15, 30, 45),
        sex: 'female',
        administeredDate: DateTime(2021, 7, 6, 11, 5, 30),
        facilityName: 'Outreach camp',
        dueDate: DateTime(2021, 6, 17, 15, 30, 45),
        scheduledFor: DateTime(2026, 12, 2, 15, 30, 45),
        kind: ReminderKind.advance,
      );
      await _insertBundle(
        database,
        childId: 'child-3',
        name: 'राम बहादुर',
        dateOfBirth: DateTime(2022, 11, 12, 23, 5, 9),
        sex: 'male',
        administeredDate: DateTime(2023, 1, 12, 10),
        facilityName: 'पोखरा',
        dueDate: DateTime(2022, 12, 24, 23, 5, 9),
        scheduledFor: DateTime(2027, 1, 3, 7, 45),
        kind: ReminderKind.followUpWeek,
      );
      final BackupRows original = await database.backupDao.readAll();
      expect(original.childProfiles, hasLength(3));
      expect(original.vaccinationRecords, hasLength(3));
      expect(original.vaccinationDues, hasLength(3));
      expect(original.reminders, hasLength(3));

      final String json = await service.buildBackupJson();
      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'extra',
          name: 'Extra',
          dateOfBirth: DateTime(2024, 1, 1),
          sex: 'female',
        ),
      );

      await service.importJson(json);
      await service.importJson(json);

      final BackupRows restored = await database.backupDao.readAll();
      _expectRows(restored, original);
      expect(restored.childProfiles, hasLength(3));
      expect(restored.vaccinationRecords, hasLength(3));
      expect(restored.vaccinationDues, hasLength(3));
      expect(restored.reminders, hasLength(3));
    });

    test('Nepali names and addresses survive the round trip', () async {
      const String childName = 'सीता गुरुङ';
      const String facility = 'वडा स्वास्थ्य चौकी';
      const String caregiverAddress = 'काठमाडौं महानगरपालिका-४, बागमती';
      const String clinicAddress = 'पोखरा महानगरपालिका-८, कास्की';

      await _insertBundle(
        database,
        childId: 'child-ne',
        name: childName,
        dateOfBirth: DateTime(2023, 4, 15, 14, 45, 30),
        sex: 'female',
        administeredDate: DateTime(2023, 6, 1, 10, 30),
        facilityName: facility,
        dueDate: DateTime(2023, 5, 27, 9),
        scheduledFor: DateTime(2026, 10, 4, 9),
      );
      await database.healthFacilitatorsDao.saveLocalFacilitator(
        name: 'स्थानीय क्लिनिक',
        address: clinicAddress,
        phone: '९८०१११२२३३',
      );
      profiles.caregiver = <String, String?>{
        'name': 'माता सीता',
        'phone': '9800000000',
        'address': caregiverAddress,
      };
      profiles.onboardingCompleted = true;
      settings.language = AppLanguage.nepali;
      final BackupRows original = await database.backupDao.readAll();

      final String json = await service.buildBackupJson();
      expect(json, contains(childName));
      expect(json, contains(facility));
      expect(json, contains(caregiverAddress));
      expect(json, contains(clinicAddress));

      await database.backupDao.replaceAll(BackupRows.empty);
      profiles.caregiver = <String, String?>{
        'name': 'Maya',
        'phone': null,
        'address': 'Ward 4',
      };
      settings.language = AppLanguage.english;

      await service.importJson(json);

      _expectRows(await database.backupDao.readAll(), original);
      expect(profiles.caregiver['name'], 'माता सीता');
      expect(profiles.caregiver['address'], caregiverAddress);
      expect(settings.language, AppLanguage.nepali);
    });

    test('dates and times come back exactly the same', () async {
      final DateTime birth = DateTime(2023, 6, 1, 15, 45, 30);
      final DateTime given = DateTime(2023, 8, 1, 8, 5, 59);
      final DateTime due = DateTime(2024, 1, 2, 23, 59, 58);
      final DateTime scheduled = DateTime(2024, 1, 2, 7, 15);
      final DateTime utcGiven = DateTime.utc(2023, 12, 31, 18);

      await _insertBundle(
        database,
        childId: 'child-time',
        name: 'Aarav',
        dateOfBirth: birth,
        sex: 'male',
        administeredDate: given,
        facilityName: 'Ward clinic',
        dueDate: due,
        scheduledFor: scheduled,
      );
      await database.vaccinationRecordsDao.insertVaccinationRecord(
        VaccinationRecordsCompanion.insert(
          id: 'record-utc',
          childId: 'child-time',
          vaccineCode: 'PENTA',
          doseNumber: 2,
          administeredDate: utcGiven,
        ),
      );
      final BackupRows before = await database.backupDao.readAll();
      final VaccinationRecord storedGiven = before.vaccinationRecords
          .singleWhere(
              (VaccinationRecord row) => row.id == 'record-child-time');
      final VaccinationRecord storedUtc = before.vaccinationRecords
          .singleWhere((VaccinationRecord row) => row.id == 'record-utc');

      final String json = await service.buildBackupJson(
        createdAt: DateTime(2026, 10, 3, 15, 45, 30),
      );
      expect(json, contains(storedGiven.administeredDate.toIso8601String()));
      expect(json, contains('T15:45:30'));
      expect(json, contains(storedUtc.administeredDate.toIso8601String()));

      await database.backupDao.replaceAll(BackupRows.empty);
      await service.importJson(json);

      final BackupRows after = await database.backupDao.readAll();
      _expectRows(after, before);
      final VaccinationRecord restoredGiven = after.vaccinationRecords
          .singleWhere(
              (VaccinationRecord row) => row.id == 'record-child-time');
      final ChildProfile restoredChild = after.childProfiles.single;
      expect(restoredGiven.administeredDate.hour,
          storedGiven.administeredDate.hour);
      expect(
        restoredGiven.administeredDate.minute,
        storedGiven.administeredDate.minute,
      );
      expect(
        restoredGiven.administeredDate.second,
        storedGiven.administeredDate.second,
      );
      expect(
        restoredGiven.administeredDate.isUtc,
        storedGiven.administeredDate.isUtc,
      );
      expect(
        restoredGiven.administeredDate.millisecondsSinceEpoch,
        storedGiven.administeredDate.millisecondsSinceEpoch,
      );
      expect(
        restoredChild.dateOfBirth.millisecondsSinceEpoch,
        before.childProfiles.single.dateOfBirth.millisecondsSinceEpoch,
      );
      expect(restoredChild.dateOfBirth.hour, 15);
      expect(restoredChild.dateOfBirth.minute, 45);
      expect(restoredChild.dateOfBirth.second, 30);
    });

    test('importing twice in a row does not duplicate anything', () async {
      final BackupRows original = await _seed(database);
      profiles.caregiver = <String, String?>{
        'name': 'Maya',
        'phone': '9800000000',
        'address': 'Ward 4',
      };
      final String json = await service.buildBackupJson();

      await service.importJson(json);
      await service.importJson(json);

      final BackupRows restored = await database.backupDao.readAll();
      _expectRows(restored, original);
      expect(restored.childProfiles, hasLength(1));
      expect(restored.vaccinationRecords, hasLength(1));
      expect(restored.vaccinationDues, hasLength(1));
      expect(restored.reminders, hasLength(1));
      expect(restored.healthFacilitators, hasLength(2));
      expect(rescheduleCalls, 2);
    });

    test('a corrupted file, a non-JSON file, and an empty file change nothing',
        () async {
      await _seed(database);
      profiles.caregiver = <String, String?>{
        'name': 'Maya',
        'phone': '9800000000',
        'address': 'Ward 4',
      };
      profiles.onboardingCompleted = true;
      settings.language = AppLanguage.english;
      final BackupRows before = await database.backupDao.readAll();

      final List<String> rejected = <String>[
        '{"app": "tikasathi", "backupVersion":',
        'this is not json',
        '',
      ];
      for (final String json in rejected) {
        await expectLater(
          service.importJson(json),
          throwsA(
            isA<BackupValidationException>().having(
              (BackupValidationException error) => error.reason,
              'reason',
              BackupRejection.missingKeys,
            ),
          ),
        );
      }

      _expectRows(await database.backupDao.readAll(), before);
      expect(profiles.caregiver['name'], 'Maya');
      expect(profiles.onboardingCompleted, isTrue);
      expect(settings.language, AppLanguage.english);
      expect(rescheduleCalls, 0);
    });

    test('a backup from an older schemaVersion is rejected', () async {
      await _seed(database);
      final BackupRows before = await database.backupDao.readAll();
      final String valid = await service.buildBackupJson();
      final Map<String, dynamic> older =
          jsonDecode(valid) as Map<String, dynamic>;
      expect(database.schemaVersion, greaterThan(1));
      older['schemaVersion'] = 1;

      await expectLater(
        service.importJson(jsonEncode(older)),
        throwsA(
          isA<BackupValidationException>().having(
            (BackupValidationException error) => error.reason,
            'reason',
            BackupRejection.unsupportedSchemaVersion,
          ),
        ),
      );

      _expectRows(await database.backupDao.readAll(), before);
      expect(rescheduleCalls, 0);
    });

    test('reminders are re-registered after import', () async {
      final _MockNotificationService notifications = _MockNotificationService();
      when(() => notifications.registeredNotificationIds())
          .thenAnswer((_) async => <int>{});
      when(() => notifications.cancelReminder(any())).thenAnswer((_) async {});
      when(
        () => notifications.scheduleReminder(
          notificationId: any(named: 'notificationId'),
          when: any(named: 'when'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => notifications.showNotificationNow(
          notificationId: any(named: 'notificationId'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {});
      final ReminderScheduler scheduler =
          ReminderScheduler(database, notifications, settings);
      final LocalBackupService wired = LocalBackupService(
        database: database,
        profiles: profiles,
        settings: settings,
        rescheduleReminders: () async {
          await scheduler.catchUpMissed();
          await scheduler.sync(
            await database.remindersDao.getPendingReminders(),
          );
        },
      );

      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'child-1',
          name: 'Aarav',
          dateOfBirth: DateTime(2024, 1, 1),
          sex: 'male',
        ),
      );
      await database.vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'due-1',
          childId: 'child-1',
          vaccineCode: 'BCG',
          doseNumber: 1,
          dueDate: DateTime(2026, 11, 1, 9),
        ),
      );
      final DateTime scheduledFor =
          DateTime.now().add(const Duration(days: 10));
      final Reminder reminder = await database.remindersDao.insertReminderAt(
        dueId: 'due-1',
        scheduledFor: scheduledFor,
        kind: ReminderKind.advance,
      );
      final String json = await wired.buildBackupJson();
      await database.backupDao.replaceAll(BackupRows.empty);
      clearInteractions(notifications);

      await wired.importJson(json);

      final List<Reminder> pending =
          await database.remindersDao.getPendingReminders();
      expect(pending, hasLength(1));
      expect(pending.single.notificationId, reminder.notificationId);
      verify(
        () => notifications.scheduleReminder(
          notificationId: reminder.notificationId,
          when: any(named: 'when'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).called(1);
    });

    test('import registers only the device reminder window', () async {
      final _MockNotificationService notifications = _MockNotificationService();
      when(() => notifications.registeredNotificationIds())
          .thenAnswer((_) async => <int>{});
      when(() => notifications.cancelReminder(any())).thenAnswer((_) async {});
      when(
        () => notifications.scheduleReminder(
          notificationId: any(named: 'notificationId'),
          when: any(named: 'when'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => notifications.showNotificationNow(
          notificationId: any(named: 'notificationId'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {});
      final ReminderScheduler scheduler =
          ReminderScheduler(database, notifications, settings);
      final LocalBackupService wired = LocalBackupService(
        database: database,
        profiles: profiles,
        settings: settings,
        rescheduleReminders: () => rescheduleRestoredReminders(
          database: database,
          scheduler: scheduler,
        ),
      );

      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'child-1',
          name: 'Aarav',
          dateOfBirth: DateTime(2026, 9, 19),
          sex: 'male',
        ),
      );
      await database.vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'due-1',
          childId: 'child-1',
          vaccineCode: 'BCG',
          doseNumber: 1,
          dueDate: DateTime(2026, 11, 1, 9),
        ),
      );
      final DateTime base = DateTime.now().add(const Duration(days: 1));
      const int extra = ReminderScheduler.registrationLimit + 1;
      for (int index = 0; index < extra; index++) {
        await database.remindersDao.insertReminderAt(
          dueId: 'due-1',
          scheduledFor: base.add(Duration(hours: index)),
          kind: ReminderKind.advance,
        );
      }
      final List<Reminder> before =
          await database.remindersDao.getPendingReminders();
      expect(before, hasLength(extra));
      final String json = await wired.buildBackupJson();
      await database.backupDao.replaceAll(BackupRows.empty);
      clearInteractions(notifications);

      await wired.importJson(json);

      final List<Reminder> restored =
          await database.remindersDao.getPendingReminders();
      expect(restored, hasLength(extra));
      verify(
        () => notifications.scheduleReminder(
          notificationId: any(named: 'notificationId'),
          when: any(named: 'when'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).called(ReminderScheduler.registrationLimit);
    });

    test('exportToFile and importFromFile round trip through a path', () async {
      final BackupRows original = await _seed(database);
      final Directory directory =
          await Directory.systemTemp.createTemp('tikasathi_backup');
      final String path = '${directory.path}/tikasathi-backup-test.json';
      try {
        await service.exportToFile(path, createdAt: DateTime(2026, 10, 3, 9));
        expect(await File(path).readAsString(), contains('"app": "tikasathi"'));

        await database.backupDao.replaceAll(BackupRows.empty);
        profiles.caregiver = <String, String?>{
          'name': null,
          'phone': null,
          'address': null,
        };
        await service.importFromFile(path);

        _expectRows(await database.backupDao.readAll(), original);
      } finally {
        await directory.delete(recursive: true);
      }
    });
  });
}

Future<void> _insertBundle(
  AppDatabase database, {
  required String childId,
  required String name,
  required DateTime dateOfBirth,
  required String sex,
  required DateTime administeredDate,
  required String? facilityName,
  required DateTime dueDate,
  required DateTime scheduledFor,
  ReminderKind kind = ReminderKind.sameDay,
}) async {
  await database.childProfilesDao.insertChildProfile(
    ChildProfilesCompanion.insert(
      id: childId,
      name: name,
      dateOfBirth: dateOfBirth,
      sex: sex,
    ),
  );
  await database.childProfilesDao.setSetupComplete(childId, true);
  await database.vaccinationRecordsDao.insertVaccinationRecord(
    VaccinationRecordsCompanion.insert(
      id: 'record-$childId',
      childId: childId,
      vaccineCode: 'PENTA',
      doseNumber: 1,
      administeredDate: administeredDate,
      facilityName: Value(facilityName),
    ),
  );
  await database.vaccinationDuesDao.insertVaccinationDue(
    VaccinationDuesCompanion.insert(
      id: 'due-$childId',
      childId: childId,
      vaccineCode: 'BCG',
      doseNumber: 1,
      dueDate: dueDate,
    ),
  );
  await database.remindersDao.insertReminderAt(
    dueId: 'due-$childId',
    scheduledFor: scheduledFor,
    kind: kind,
  );
}

Future<BackupRows> _seed(AppDatabase database) async {
  await database.childProfilesDao.insertChildProfile(
    ChildProfilesCompanion.insert(
      id: 'child-1',
      name: 'Aarav',
      dateOfBirth: DateTime(2023, 4, 15),
      sex: 'male',
    ),
  );
  await database.childProfilesDao.setSetupComplete('child-1', true);
  await database.vaccinationRecordsDao.insertVaccinationRecord(
    VaccinationRecordsCompanion.insert(
      id: 'record-1',
      childId: 'child-1',
      vaccineCode: 'PENTA',
      doseNumber: 1,
      administeredDate: DateTime(2023, 6, 1, 10, 30),
      facilityName: const Value('Ward clinic'),
    ),
  );
  await database.manualVaccinationScheduleOverridesDao.removeDose(
    childId: 'child-1',
    vaccineCode: 'PENTA',
    doseNumber: 2,
  );
  await database.manualVaccinationScheduleOverridesDao.saveDateOverride(
    childId: 'child-1',
    vaccineCode: 'BCG',
    doseNumber: 1,
    dueDate: DateTime(2023, 5, 20),
  );
  await database.vaccinationDuesDao.insertVaccinationDue(
    VaccinationDuesCompanion.insert(
      id: 'due-1',
      childId: 'child-1',
      vaccineCode: 'BCG',
      doseNumber: 1,
      dueDate: DateTime(2023, 4, 15, 9),
    ),
  );
  await database.remindersDao.insertReminderAt(
    dueId: 'due-1',
    scheduledFor: DateTime(2023, 4, 15, 9),
    kind: ReminderKind.sameDay,
  );
  final Reminder reminder =
      (await database.remindersDao.getPendingReminders()).single;
  await database.remindersDao.markReminderDelivered(
    reminder.id,
    deliveredAt: DateTime(2023, 4, 15, 9, 5),
  );
  await database.healthFacilitatorsDao.saveLocalFacilitator(
    name: 'Local clinic',
    address: 'Ward 4',
    phone: '9800000000',
  );
  await database.into(database.healthFacilitators).insert(
        HealthFacilitatorsCompanion.insert(
          id: 'clinic-2',
          name: const Value('Outreach'),
          address: const Value(null),
          phone: const Value(null),
        ),
      );
  return database.backupDao.readAll();
}

void _expectRows(BackupRows actual, BackupRows expected) {
  int byId(String a, String b) => a.compareTo(b);
  final List<ChildProfile> children =
      List<ChildProfile>.of(actual.childProfiles)
        ..sort((ChildProfile a, ChildProfile b) => byId(a.id, b.id));
  final List<ChildProfile> expectedChildren =
      List<ChildProfile>.of(expected.childProfiles)
        ..sort((ChildProfile a, ChildProfile b) => byId(a.id, b.id));
  final List<VaccinationRecord> records =
      List<VaccinationRecord>.of(actual.vaccinationRecords)
        ..sort((VaccinationRecord a, VaccinationRecord b) => byId(a.id, b.id));
  final List<VaccinationRecord> expectedRecords =
      List<VaccinationRecord>.of(expected.vaccinationRecords)
        ..sort((VaccinationRecord a, VaccinationRecord b) => byId(a.id, b.id));
  final List<VaccinationDue> dues =
      List<VaccinationDue>.of(actual.vaccinationDues)
        ..sort((VaccinationDue a, VaccinationDue b) => byId(a.id, b.id));
  final List<VaccinationDue> expectedDues =
      List<VaccinationDue>.of(expected.vaccinationDues)
        ..sort((VaccinationDue a, VaccinationDue b) => byId(a.id, b.id));
  final List<Reminder> reminders = List<Reminder>.of(actual.reminders)
    ..sort((Reminder a, Reminder b) => byId(a.id, b.id));
  final List<Reminder> expectedReminders = List<Reminder>.of(expected.reminders)
    ..sort((Reminder a, Reminder b) => byId(a.id, b.id));
  final List<HealthFacilitator> facilitators =
      List<HealthFacilitator>.of(actual.healthFacilitators)
        ..sort((HealthFacilitator a, HealthFacilitator b) => byId(a.id, b.id));
  final List<HealthFacilitator> expectedFacilitators =
      List<HealthFacilitator>.of(expected.healthFacilitators)
        ..sort((HealthFacilitator a, HealthFacilitator b) => byId(a.id, b.id));
  final List<ManualVaccinationScheduleOverride> overrides =
      List<ManualVaccinationScheduleOverride>.of(
    actual.manualScheduleOverrides,
  )..sort((ManualVaccinationScheduleOverride a,
              ManualVaccinationScheduleOverride b) =>
          byId(a.id, b.id));
  final List<ManualVaccinationScheduleOverride> expectedOverrides =
      List<ManualVaccinationScheduleOverride>.of(
    expected.manualScheduleOverrides,
  )..sort((ManualVaccinationScheduleOverride a,
              ManualVaccinationScheduleOverride b) =>
          byId(a.id, b.id));

  expect(children, expectedChildren);
  expect(records, expectedRecords);
  expect(dues, expectedDues);
  expect(overrides, expectedOverrides);
  expect(reminders, expectedReminders);
  expect(facilitators, expectedFacilitators);
}

class _MemoryProfileStore implements BackupProfileStore {
  Map<String, String?> caregiver = <String, String?>{
    'name': null,
    'phone': null,
    'address': null,
  };
  bool onboardingCompleted = true;

  @override
  Future<Map<String, String?>> getCaregiverProfile() async {
    return Map<String, String?>.of(caregiver);
  }

  @override
  Future<bool> hasCompletedOnboarding() async => onboardingCompleted;

  @override
  Future<void> writeCaregiverProfile({
    required String? name,
    required String? phone,
    required String? address,
  }) async {
    caregiver = <String, String?>{
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  @override
  Future<void> writeOnboardingCompleted(bool completed) async {
    onboardingCompleted = completed;
  }
}

/// Accepts the import's profile write, then fails every write after it, as a
/// full disk would during the rollback.
class _BrokenRollbackStore extends _MemoryProfileStore {
  int writes = 0;

  @override
  Future<void> writeCaregiverProfile({
    required String? name,
    required String? phone,
    required String? address,
  }) async {
    writes += 1;
    if (writes > 1) {
      throw StateError('rollback write failed');
    }
    await super.writeCaregiverProfile(
      name: name,
      phone: phone,
      address: address,
    );
  }
}
