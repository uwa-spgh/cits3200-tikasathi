import 'dart:convert';

import 'package:drift/drift.dart';
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

  });
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

  expect(children, expectedChildren);
  expect(records, expectedRecords);
  expect(dues, expectedDues);
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
