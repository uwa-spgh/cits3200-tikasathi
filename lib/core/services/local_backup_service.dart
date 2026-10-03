import 'dart:convert';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/reminders/reminder_schedule.dart';
import 'package:tikasathi/core/reminders/reminder_scheduler.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/settings_repository.dart';

part 'local_backup_service.g.dart';

/// Why a backup file was refused before any data was changed.
enum BackupRejection {
  wrongApp,
  unsupportedBackupVersion,
  unsupportedSchemaVersion,
  missingKeys,
}

class BackupValidationException implements Exception {
  const BackupValidationException(this.reason);

  final BackupRejection reason;

  @override
  String toString() => 'BackupValidationException($reason)';
}

/// Builds and restores a local JSON backup of the phone's TikaSathi data.
///
/// Nothing here talks to the network. The settings screen writes the text to
/// a file and hands it to the system share sheet.
class LocalBackupService {
  LocalBackupService({
    required AppDatabase database,
    required BackupProfileStore profiles,
    required SettingsRepository settings,
    Future<void> Function()? rescheduleReminders,
  })  : _database = database,
        _profiles = profiles,
        _settings = settings,
        _rescheduleReminders = rescheduleReminders;

  static const String appId = 'tikasathi';
  static const int backupVersion = 1;

  static const List<String> _rootKeys = <String>[
    'app',
    'backupVersion',
    'schemaVersion',
    'createdAt',
    'childProfiles',
    'vaccinationRecords',
    'vaccinationDues',
    'reminders',
    'healthFacilitators',
    'caregiver',
    'language',
    'onboardingCompleted',
  ];

  final AppDatabase _database;
  final BackupProfileStore _profiles;
  final SettingsRepository _settings;
  final Future<void> Function()? _rescheduleReminders;

  /// `tikasathi-backup-YYYY-MM-DD.json` for the local calendar day of [when].
  static String fileNameFor(DateTime when) {
    final String month = when.month.toString().padLeft(2, '0');
    final String day = when.day.toString().padLeft(2, '0');
    return 'tikasathi-backup-${when.year}-$month-$day.json';
  }

  Future<String> buildBackupJson({DateTime? createdAt}) async {
    final BackupRows rows = await _database.backupDao.readAll();
    final Map<String, String?> caregiver =
        await _profiles.getCaregiverProfile();
    final AppLanguage language = await _settings.getLanguage();
    final bool onboardingCompleted = await _profiles.hasCompletedOnboarding();
    final DateTime stampedAt = createdAt ?? DateTime.now();

    final Map<String, Object?> document = <String, Object?>{
      'app': appId,
      'backupVersion': backupVersion,
      'schemaVersion': _database.schemaVersion,
      'createdAt': stampedAt.toIso8601String(),
      'childProfiles': <Map<String, Object?>>[
        for (final ChildProfile row in rows.childProfiles) _childToJson(row),
      ],
      'vaccinationRecords': <Map<String, Object?>>[
        for (final VaccinationRecord row in rows.vaccinationRecords)
          _recordToJson(row),
      ],
      'vaccinationDues': <Map<String, Object?>>[
        for (final VaccinationDue row in rows.vaccinationDues) _dueToJson(row),
      ],
      'reminders': <Map<String, Object?>>[
        for (final Reminder row in rows.reminders) _reminderToJson(row),
      ],
      'healthFacilitators': <Map<String, Object?>>[
        for (final HealthFacilitator row in rows.healthFacilitators)
          _facilitatorToJson(row),
      ],
      'caregiver': <String, Object?>{
        'name': caregiver['name'],
        'phone': caregiver['phone'],
        'address': caregiver['address'],
      },
      'language': language.code,
      'onboardingCompleted': onboardingCompleted,
    };

    return const JsonEncoder.withIndent('  ').convert(document);
  }

  /// Writes the backup JSON to [path].
  ///
  /// The settings screen still shares a file through the system sheet. Tests
  /// pass a path here because that sheet cannot be driven.
  Future<void> exportToFile(String path, {DateTime? createdAt}) async {
    final String json = await buildBackupJson(createdAt: createdAt);
    final File file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(json, flush: true);
  }

  /// Restores the backup stored at [path]. Same checks as [importJson].
  Future<void> importFromFile(String path) async {
    final String json = await File(path).readAsString();
    await importJson(json);
  }

  /// Checks [jsonText] without writing. Throws [BackupValidationException].
  void validate(String jsonText) {
    _parse(jsonText);
  }

  /// Replaces the database, caregiver profile, language, and onboarding flag.
  ///
  /// Validation runs first. The table replace is one transaction, so a bad row
  /// leaves the old rows in place. If restoring the profile or re-registering
  /// reminders fails afterwards, the previous rows and profile are put back.
  Future<void> importJson(String jsonText) async {
    final _BackupDocument document = _parse(jsonText);
    final BackupRows previousRows = await _database.backupDao.readAll();
    final Map<String, String?> previousCaregiver =
        await _profiles.getCaregiverProfile();
    final AppLanguage previousLanguage = await _settings.getLanguage();
    final bool previousOnboarding = await _profiles.hasCompletedOnboarding();

    await _database.backupDao.replaceAll(
      BackupRows(
        childProfiles: document.childProfiles,
        vaccinationRecords: document.vaccinationRecords,
        vaccinationDues: document.vaccinationDues,
        reminders: document.reminders,
        healthFacilitators: document.healthFacilitators,
      ),
    );

    try {
      await _profiles.writeCaregiverProfile(
        name: document.caregiverName,
        phone: document.caregiverPhone,
        address: document.caregiverAddress,
      );
      await _settings.setLanguage(document.language);
      await _profiles.writeOnboardingCompleted(document.onboardingCompleted);
      final Future<void> Function()? reschedule = _rescheduleReminders;
      if (reschedule != null) {
        await reschedule();
      }
    } catch (error, stackTrace) {
      try {
        await _database.backupDao.replaceAll(previousRows);
        await _profiles.writeCaregiverProfile(
          name: previousCaregiver['name'],
          phone: previousCaregiver['phone'],
          address: previousCaregiver['address'],
        );
        await _settings.setLanguage(previousLanguage);
        await _profiles.writeOnboardingCompleted(previousOnboarding);
      } catch (_) {
        // A failed rollback must not hide the error that caused it.
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  _BackupDocument _parse(String jsonText) {
    final Object? decoded;
    try {
      decoded = jsonDecode(jsonText);
    } on FormatException {
      throw const BackupValidationException(BackupRejection.missingKeys);
    }

    final Map<String, dynamic> root = _asMap(decoded);
    for (final String key in _rootKeys) {
      if (!root.containsKey(key)) {
        throw const BackupValidationException(BackupRejection.missingKeys);
      }
    }
    if (root['createdAt'] is! String) {
      throw const BackupValidationException(BackupRejection.missingKeys);
    }
    if (root['app'] != appId) {
      throw const BackupValidationException(BackupRejection.wrongApp);
    }
    if (root['backupVersion'] != backupVersion) {
      throw const BackupValidationException(
        BackupRejection.unsupportedBackupVersion,
      );
    }
    if (root['schemaVersion'] != _database.schemaVersion) {
      throw const BackupValidationException(
        BackupRejection.unsupportedSchemaVersion,
      );
    }

    final Map<String, dynamic> caregiver = _asMap(root['caregiver']);
    for (final String key in const <String>['name', 'phone', 'address']) {
      if (!caregiver.containsKey(key)) {
        throw const BackupValidationException(BackupRejection.missingKeys);
      }
    }
    if (root['onboardingCompleted'] is! bool) {
      throw const BackupValidationException(BackupRejection.missingKeys);
    }

    return _BackupDocument(
      childProfiles: <ChildProfile>[
        for (final Map<String, dynamic> row
            in _asMapList(root['childProfiles']))
          _childFromJson(row),
      ],
      vaccinationRecords: <VaccinationRecord>[
        for (final Map<String, dynamic> row
            in _asMapList(root['vaccinationRecords']))
          _recordFromJson(row),
      ],
      vaccinationDues: <VaccinationDue>[
        for (final Map<String, dynamic> row
            in _asMapList(root['vaccinationDues']))
          _dueFromJson(row),
      ],
      reminders: <Reminder>[
        for (final Map<String, dynamic> row in _asMapList(root['reminders']))
          _reminderFromJson(row),
      ],
      healthFacilitators: <HealthFacilitator>[
        for (final Map<String, dynamic> row
            in _asMapList(root['healthFacilitators']))
          _facilitatorFromJson(row),
      ],
      caregiverName: _optionalString(caregiver, 'name'),
      caregiverPhone: _optionalString(caregiver, 'phone'),
      caregiverAddress: _optionalString(caregiver, 'address'),
      language: _language(root['language']),
      onboardingCompleted: root['onboardingCompleted'] as bool,
    );
  }
}

class _BackupDocument {
  const _BackupDocument({
    required this.childProfiles,
    required this.vaccinationRecords,
    required this.vaccinationDues,
    required this.reminders,
    required this.healthFacilitators,
    required this.caregiverName,
    required this.caregiverPhone,
    required this.caregiverAddress,
    required this.language,
    required this.onboardingCompleted,
  });

  final List<ChildProfile> childProfiles;
  final List<VaccinationRecord> vaccinationRecords;
  final List<VaccinationDue> vaccinationDues;
  final List<Reminder> reminders;
  final List<HealthFacilitator> healthFacilitators;
  final String? caregiverName;
  final String? caregiverPhone;
  final String? caregiverAddress;
  final AppLanguage language;
  final bool onboardingCompleted;
}

Map<String, Object?> _childToJson(ChildProfile row) {
  return <String, Object?>{
    'id': row.id,
    'name': row.name,
    'dateOfBirth': row.dateOfBirth.toIso8601String(),
    'sex': row.sex,
    'isSetupComplete': row.isSetupComplete,
  };
}

Map<String, Object?> _recordToJson(VaccinationRecord row) {
  return <String, Object?>{
    'id': row.id,
    'childId': row.childId,
    'vaccineCode': row.vaccineCode,
    'doseNumber': row.doseNumber,
    'administeredDate': row.administeredDate.toIso8601String(),
    'facilityName': row.facilityName,
  };
}

Map<String, Object?> _dueToJson(VaccinationDue row) {
  return <String, Object?>{
    'id': row.id,
    'childId': row.childId,
    'vaccineCode': row.vaccineCode,
    'doseNumber': row.doseNumber,
    'dueDate': row.dueDate.toIso8601String(),
  };
}

Map<String, Object?> _reminderToJson(Reminder row) {
  return <String, Object?>{
    'id': row.id,
    'childId': row.childId,
    'dueId': row.dueId,
    'kind': row.kind.name,
    'scheduledFor': row.scheduledFor.toIso8601String(),
    'notificationId': row.notificationId,
    'deliveredAt': row.deliveredAt?.toIso8601String(),
  };
}

Map<String, Object?> _facilitatorToJson(HealthFacilitator row) {
  return <String, Object?>{
    'id': row.id,
    'name': row.name,
    'address': row.address,
    'phone': row.phone,
  };
}

ChildProfile _childFromJson(Map<String, dynamic> json) {
  _requireKeys(json, const <String>[
    'id',
    'name',
    'dateOfBirth',
    'sex',
    'isSetupComplete',
  ]);
  return ChildProfile(
    id: _requiredString(json, 'id'),
    name: _requiredString(json, 'name'),
    dateOfBirth: _requiredDate(json, 'dateOfBirth'),
    sex: _requiredString(json, 'sex'),
    isSetupComplete: _requiredBool(json, 'isSetupComplete'),
  );
}

VaccinationRecord _recordFromJson(Map<String, dynamic> json) {
  _requireKeys(json, const <String>[
    'id',
    'childId',
    'vaccineCode',
    'doseNumber',
    'administeredDate',
    'facilityName',
  ]);
  return VaccinationRecord(
    id: _requiredString(json, 'id'),
    childId: _requiredString(json, 'childId'),
    vaccineCode: _requiredString(json, 'vaccineCode'),
    doseNumber: _requiredInt(json, 'doseNumber'),
    administeredDate: _requiredDate(json, 'administeredDate'),
    facilityName: _optionalString(json, 'facilityName'),
  );
}

VaccinationDue _dueFromJson(Map<String, dynamic> json) {
  _requireKeys(json, const <String>[
    'id',
    'childId',
    'vaccineCode',
    'doseNumber',
    'dueDate',
  ]);
  return VaccinationDue(
    id: _requiredString(json, 'id'),
    childId: _requiredString(json, 'childId'),
    vaccineCode: _requiredString(json, 'vaccineCode'),
    doseNumber: _requiredInt(json, 'doseNumber'),
    dueDate: _requiredDate(json, 'dueDate'),
  );
}

Reminder _reminderFromJson(Map<String, dynamic> json) {
  _requireKeys(json, const <String>[
    'id',
    'childId',
    'dueId',
    'kind',
    'scheduledFor',
    'notificationId',
    'deliveredAt',
  ]);
  return Reminder(
    id: _requiredString(json, 'id'),
    childId: _requiredString(json, 'childId'),
    dueId: _requiredString(json, 'dueId'),
    kind: _requiredKind(json),
    scheduledFor: _requiredDate(json, 'scheduledFor'),
    notificationId: _requiredInt(json, 'notificationId'),
    deliveredAt: _optionalDate(json, 'deliveredAt'),
  );
}

HealthFacilitator _facilitatorFromJson(Map<String, dynamic> json) {
  _requireKeys(json, const <String>['id', 'name', 'address', 'phone']);
  return HealthFacilitator(
    id: _requiredString(json, 'id'),
    name: _optionalString(json, 'name'),
    address: _optionalString(json, 'address'),
    phone: _optionalString(json, 'phone'),
  );
}

AppLanguage _language(Object? value) {
  if (value == AppLanguage.english.code) {
    return AppLanguage.english;
  }
  if (value == AppLanguage.nepali.code) {
    return AppLanguage.nepali;
  }
  throw const BackupValidationException(BackupRejection.missingKeys);
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    final Map<String, dynamic> mapped = <String, dynamic>{};
    for (final MapEntry<Object?, Object?> entry in value.entries) {
      final Object? key = entry.key;
      if (key is! String) {
        throw const BackupValidationException(BackupRejection.missingKeys);
      }
      mapped[key] = entry.value;
    }
    return mapped;
  }
  throw const BackupValidationException(BackupRejection.missingKeys);
}

List<Map<String, dynamic>> _asMapList(Object? value) {
  if (value is! List<dynamic>) {
    throw const BackupValidationException(BackupRejection.missingKeys);
  }
  return <Map<String, dynamic>>[
    for (final Object? item in value) _asMap(item),
  ];
}

void _requireKeys(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    if (!json.containsKey(key)) {
      throw const BackupValidationException(BackupRejection.missingKeys);
    }
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! String) {
    throw const BackupValidationException(BackupRejection.missingKeys);
  }
  return value;
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  throw const BackupValidationException(BackupRejection.missingKeys);
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! int) {
    throw const BackupValidationException(BackupRejection.missingKeys);
  }
  return value;
}

bool _requiredBool(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! bool) {
    throw const BackupValidationException(BackupRejection.missingKeys);
  }
  return value;
}

DateTime _requiredDate(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! String) {
    throw const BackupValidationException(BackupRejection.missingKeys);
  }
  return _parseDate(value);
}

DateTime? _optionalDate(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw const BackupValidationException(BackupRejection.missingKeys);
  }
  return _parseDate(value);
}

DateTime _parseDate(String value) {
  try {
    return DateTime.parse(value);
  } on FormatException {
    throw const BackupValidationException(BackupRejection.missingKeys);
  }
}

/// Registers restored reminders with the device.
///
/// The running app only keeps a short window scheduled. Android rejects a
/// package that goes past 500 concurrent alarms, so a full restore must use
/// that same window. Every reminder still stays in the table.
Future<void> rescheduleRestoredReminders({
  required AppDatabase database,
  required ReminderScheduler scheduler,
}) async {
  await scheduler.catchUpMissed();
  await scheduler.sync(
    await database.remindersDao.getPendingReminders(
      limit: ReminderScheduler.registrationLimit,
    ),
  );
}

ReminderKind _requiredKind(Map<String, dynamic> json) {
  final String name = _requiredString(json, 'kind');
  for (final ReminderKind kind in ReminderKind.values) {
    if (kind.name == name) {
      return kind;
    }
  }
  throw const BackupValidationException(BackupRejection.missingKeys);
}

@Riverpod(keepAlive: true)
LocalBackupService localBackupService(LocalBackupServiceRef ref) {
  final AppDatabase database = ref.watch(appDatabaseProvider);
  final ReminderScheduler scheduler = ref.watch(reminderSchedulerProvider);
  return LocalBackupService(
    database: database,
    profiles: ref.watch(secureStorageServiceProvider),
    settings: ref.watch(settingsRepositoryProvider),
    rescheduleReminders: () => rescheduleRestoredReminders(
      database: database,
      scheduler: scheduler,
    ),
  );
}
