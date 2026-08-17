// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChildProfilesTable extends ChildProfiles
    with TableInfo<$ChildProfilesTable, ChildProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
      'sex', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, dateOfBirth, sex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'child_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<ChildProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    } else if (isInserting) {
      context.missing(_dateOfBirthMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
          _sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChildProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChildProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dateOfBirth: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth'])!,
      sex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sex'])!,
    );
  }

  @override
  $ChildProfilesTable createAlias(String alias) {
    return $ChildProfilesTable(attachedDatabase, alias);
  }
}

class ChildProfile extends DataClass implements Insertable<ChildProfile> {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String sex;
  const ChildProfile(
      {required this.id,
      required this.name,
      required this.dateOfBirth,
      required this.sex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    map['sex'] = Variable<String>(sex);
    return map;
  }

  ChildProfilesCompanion toCompanion(bool nullToAbsent) {
    return ChildProfilesCompanion(
      id: Value(id),
      name: Value(name),
      dateOfBirth: Value(dateOfBirth),
      sex: Value(sex),
    );
  }

  factory ChildProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChildProfile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dateOfBirth: serializer.fromJson<DateTime>(json['dateOfBirth']),
      sex: serializer.fromJson<String>(json['sex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'dateOfBirth': serializer.toJson<DateTime>(dateOfBirth),
      'sex': serializer.toJson<String>(sex),
    };
  }

  ChildProfile copyWith(
          {String? id, String? name, DateTime? dateOfBirth, String? sex}) =>
      ChildProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        sex: sex ?? this.sex,
      );
  ChildProfile copyWithCompanion(ChildProfilesCompanion data) {
    return ChildProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      sex: data.sex.present ? data.sex.value : this.sex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChildProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('sex: $sex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, dateOfBirth, sex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChildProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.dateOfBirth == this.dateOfBirth &&
          other.sex == this.sex);
}

class ChildProfilesCompanion extends UpdateCompanion<ChildProfile> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> dateOfBirth;
  final Value<String> sex;
  final Value<int> rowid;
  const ChildProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.sex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChildProfilesCompanion.insert({
    required String id,
    required String name,
    required DateTime dateOfBirth,
    required String sex,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        dateOfBirth = Value(dateOfBirth),
        sex = Value(sex);
  static Insertable<ChildProfile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? sex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (sex != null) 'sex': sex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChildProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? dateOfBirth,
      Value<String>? sex,
      Value<int>? rowid}) {
    return ChildProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('sex: $sex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaccinationRecordsTable extends VaccinationRecords
    with TableInfo<$VaccinationRecordsTable, VaccinationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaccinationRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
      'child_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES child_profiles (id)'));
  static const VerificationMeta _vaccineCodeMeta =
      const VerificationMeta('vaccineCode');
  @override
  late final GeneratedColumn<String> vaccineCode = GeneratedColumn<String>(
      'vaccine_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _doseNumberMeta =
      const VerificationMeta('doseNumber');
  @override
  late final GeneratedColumn<int> doseNumber = GeneratedColumn<int>(
      'dose_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _administeredDateMeta =
      const VerificationMeta('administeredDate');
  @override
  late final GeneratedColumn<DateTime> administeredDate =
      GeneratedColumn<DateTime>('administered_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _facilityNameMeta =
      const VerificationMeta('facilityName');
  @override
  late final GeneratedColumn<String> facilityName = GeneratedColumn<String>(
      'facility_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, childId, vaccineCode, doseNumber, administeredDate, facilityName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaccination_records';
  @override
  VerificationContext validateIntegrity(Insertable<VaccinationRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('vaccine_code')) {
      context.handle(
          _vaccineCodeMeta,
          vaccineCode.isAcceptableOrUnknown(
              data['vaccine_code']!, _vaccineCodeMeta));
    } else if (isInserting) {
      context.missing(_vaccineCodeMeta);
    }
    if (data.containsKey('dose_number')) {
      context.handle(
          _doseNumberMeta,
          doseNumber.isAcceptableOrUnknown(
              data['dose_number']!, _doseNumberMeta));
    } else if (isInserting) {
      context.missing(_doseNumberMeta);
    }
    if (data.containsKey('administered_date')) {
      context.handle(
          _administeredDateMeta,
          administeredDate.isAcceptableOrUnknown(
              data['administered_date']!, _administeredDateMeta));
    }
    if (data.containsKey('facility_name')) {
      context.handle(
          _facilityNameMeta,
          facilityName.isAcceptableOrUnknown(
              data['facility_name']!, _facilityNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaccinationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaccinationRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
      vaccineCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vaccine_code'])!,
      doseNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dose_number'])!,
      administeredDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}administered_date']),
      facilityName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}facility_name']),
    );
  }

  @override
  $VaccinationRecordsTable createAlias(String alias) {
    return $VaccinationRecordsTable(attachedDatabase, alias);
  }
}

class VaccinationRecord extends DataClass
    implements Insertable<VaccinationRecord> {
  final String id;
  final String childId;
  final String vaccineCode;
  final int doseNumber;

  /// Null until the caregiver marks this dose completed.
  final DateTime? administeredDate;
  final String? facilityName;
  const VaccinationRecord(
      {required this.id,
      required this.childId,
      required this.vaccineCode,
      required this.doseNumber,
      this.administeredDate,
      this.facilityName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['vaccine_code'] = Variable<String>(vaccineCode);
    map['dose_number'] = Variable<int>(doseNumber);
    if (!nullToAbsent || administeredDate != null) {
      map['administered_date'] = Variable<DateTime>(administeredDate);
    }
    if (!nullToAbsent || facilityName != null) {
      map['facility_name'] = Variable<String>(facilityName);
    }
    return map;
  }

  VaccinationRecordsCompanion toCompanion(bool nullToAbsent) {
    return VaccinationRecordsCompanion(
      id: Value(id),
      childId: Value(childId),
      vaccineCode: Value(vaccineCode),
      doseNumber: Value(doseNumber),
      administeredDate: administeredDate == null && nullToAbsent
          ? const Value.absent()
          : Value(administeredDate),
      facilityName: facilityName == null && nullToAbsent
          ? const Value.absent()
          : Value(facilityName),
    );
  }

  factory VaccinationRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaccinationRecord(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      vaccineCode: serializer.fromJson<String>(json['vaccineCode']),
      doseNumber: serializer.fromJson<int>(json['doseNumber']),
      administeredDate:
          serializer.fromJson<DateTime?>(json['administeredDate']),
      facilityName: serializer.fromJson<String?>(json['facilityName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'vaccineCode': serializer.toJson<String>(vaccineCode),
      'doseNumber': serializer.toJson<int>(doseNumber),
      'administeredDate': serializer.toJson<DateTime?>(administeredDate),
      'facilityName': serializer.toJson<String?>(facilityName),
    };
  }

  VaccinationRecord copyWith(
          {String? id,
          String? childId,
          String? vaccineCode,
          int? doseNumber,
          Value<DateTime?> administeredDate = const Value.absent(),
          Value<String?> facilityName = const Value.absent()}) =>
      VaccinationRecord(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        vaccineCode: vaccineCode ?? this.vaccineCode,
        doseNumber: doseNumber ?? this.doseNumber,
        administeredDate: administeredDate.present
            ? administeredDate.value
            : this.administeredDate,
        facilityName:
            facilityName.present ? facilityName.value : this.facilityName,
      );
  VaccinationRecord copyWithCompanion(VaccinationRecordsCompanion data) {
    return VaccinationRecord(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      vaccineCode:
          data.vaccineCode.present ? data.vaccineCode.value : this.vaccineCode,
      doseNumber:
          data.doseNumber.present ? data.doseNumber.value : this.doseNumber,
      administeredDate: data.administeredDate.present
          ? data.administeredDate.value
          : this.administeredDate,
      facilityName: data.facilityName.present
          ? data.facilityName.value
          : this.facilityName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationRecord(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('vaccineCode: $vaccineCode, ')
          ..write('doseNumber: $doseNumber, ')
          ..write('administeredDate: $administeredDate, ')
          ..write('facilityName: $facilityName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, childId, vaccineCode, doseNumber, administeredDate, facilityName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaccinationRecord &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.vaccineCode == this.vaccineCode &&
          other.doseNumber == this.doseNumber &&
          other.administeredDate == this.administeredDate &&
          other.facilityName == this.facilityName);
}

class VaccinationRecordsCompanion extends UpdateCompanion<VaccinationRecord> {
  final Value<String> id;
  final Value<String> childId;
  final Value<String> vaccineCode;
  final Value<int> doseNumber;
  final Value<DateTime?> administeredDate;
  final Value<String?> facilityName;
  final Value<int> rowid;
  const VaccinationRecordsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.vaccineCode = const Value.absent(),
    this.doseNumber = const Value.absent(),
    this.administeredDate = const Value.absent(),
    this.facilityName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaccinationRecordsCompanion.insert({
    required String id,
    required String childId,
    required String vaccineCode,
    required int doseNumber,
    this.administeredDate = const Value.absent(),
    this.facilityName = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        vaccineCode = Value(vaccineCode),
        doseNumber = Value(doseNumber);
  static Insertable<VaccinationRecord> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? vaccineCode,
    Expression<int>? doseNumber,
    Expression<DateTime>? administeredDate,
    Expression<String>? facilityName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (vaccineCode != null) 'vaccine_code': vaccineCode,
      if (doseNumber != null) 'dose_number': doseNumber,
      if (administeredDate != null) 'administered_date': administeredDate,
      if (facilityName != null) 'facility_name': facilityName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaccinationRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? childId,
      Value<String>? vaccineCode,
      Value<int>? doseNumber,
      Value<DateTime?>? administeredDate,
      Value<String?>? facilityName,
      Value<int>? rowid}) {
    return VaccinationRecordsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      vaccineCode: vaccineCode ?? this.vaccineCode,
      doseNumber: doseNumber ?? this.doseNumber,
      administeredDate: administeredDate ?? this.administeredDate,
      facilityName: facilityName ?? this.facilityName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (vaccineCode.present) {
      map['vaccine_code'] = Variable<String>(vaccineCode.value);
    }
    if (doseNumber.present) {
      map['dose_number'] = Variable<int>(doseNumber.value);
    }
    if (administeredDate.present) {
      map['administered_date'] = Variable<DateTime>(administeredDate.value);
    }
    if (facilityName.present) {
      map['facility_name'] = Variable<String>(facilityName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationRecordsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('vaccineCode: $vaccineCode, ')
          ..write('doseNumber: $doseNumber, ')
          ..write('administeredDate: $administeredDate, ')
          ..write('facilityName: $facilityName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChildProfilesTable childProfiles = $ChildProfilesTable(this);
  late final $VaccinationRecordsTable vaccinationRecords =
      $VaccinationRecordsTable(this);
  late final ChildProfilesDao childProfilesDao =
      ChildProfilesDao(this as AppDatabase);
  late final VaccinationRecordsDao vaccinationRecordsDao =
      VaccinationRecordsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [childProfiles, vaccinationRecords];
}

typedef $$ChildProfilesTableCreateCompanionBuilder = ChildProfilesCompanion
    Function({
  required String id,
  required String name,
  required DateTime dateOfBirth,
  required String sex,
  Value<int> rowid,
});
typedef $$ChildProfilesTableUpdateCompanionBuilder = ChildProfilesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> dateOfBirth,
  Value<String> sex,
  Value<int> rowid,
});

final class $$ChildProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ChildProfilesTable, ChildProfile> {
  $$ChildProfilesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VaccinationRecordsTable, List<VaccinationRecord>>
      _vaccinationRecordsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.vaccinationRecords,
              aliasName: $_aliasNameGenerator(
                  db.childProfiles.id, db.vaccinationRecords.childId));

  $$VaccinationRecordsTableProcessedTableManager get vaccinationRecordsRefs {
    final manager =
        $$VaccinationRecordsTableTableManager($_db, $_db.vaccinationRecords)
            .filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_vaccinationRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ChildProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnFilters(column));

  Expression<bool> vaccinationRecordsRefs(
      Expression<bool> Function($$VaccinationRecordsTableFilterComposer f) f) {
    final $$VaccinationRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vaccinationRecords,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VaccinationRecordsTableFilterComposer(
              $db: $db,
              $table: $db.vaccinationRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChildProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnOrderings(column));
}

class $$ChildProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  Expression<T> vaccinationRecordsRefs<T extends Object>(
      Expression<T> Function($$VaccinationRecordsTableAnnotationComposer a) f) {
    final $$VaccinationRecordsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.vaccinationRecords,
            getReferencedColumn: (t) => t.childId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$VaccinationRecordsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.vaccinationRecords,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ChildProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChildProfilesTable,
    ChildProfile,
    $$ChildProfilesTableFilterComposer,
    $$ChildProfilesTableOrderingComposer,
    $$ChildProfilesTableAnnotationComposer,
    $$ChildProfilesTableCreateCompanionBuilder,
    $$ChildProfilesTableUpdateCompanionBuilder,
    (ChildProfile, $$ChildProfilesTableReferences),
    ChildProfile,
    PrefetchHooks Function({bool vaccinationRecordsRefs})> {
  $$ChildProfilesTableTableManager(_$AppDatabase db, $ChildProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChildProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChildProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChildProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> dateOfBirth = const Value.absent(),
            Value<String> sex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChildProfilesCompanion(
            id: id,
            name: name,
            dateOfBirth: dateOfBirth,
            sex: sex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required DateTime dateOfBirth,
            required String sex,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChildProfilesCompanion.insert(
            id: id,
            name: name,
            dateOfBirth: dateOfBirth,
            sex: sex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ChildProfilesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({vaccinationRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (vaccinationRecordsRefs) db.vaccinationRecords
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (vaccinationRecordsRefs)
                    await $_getPrefetchedData<ChildProfile, $ChildProfilesTable,
                            VaccinationRecord>(
                        currentTable: table,
                        referencedTable: $$ChildProfilesTableReferences
                            ._vaccinationRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChildProfilesTableReferences(db, table, p0)
                                .vaccinationRecordsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.childId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ChildProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChildProfilesTable,
    ChildProfile,
    $$ChildProfilesTableFilterComposer,
    $$ChildProfilesTableOrderingComposer,
    $$ChildProfilesTableAnnotationComposer,
    $$ChildProfilesTableCreateCompanionBuilder,
    $$ChildProfilesTableUpdateCompanionBuilder,
    (ChildProfile, $$ChildProfilesTableReferences),
    ChildProfile,
    PrefetchHooks Function({bool vaccinationRecordsRefs})>;
typedef $$VaccinationRecordsTableCreateCompanionBuilder
    = VaccinationRecordsCompanion Function({
  required String id,
  required String childId,
  required String vaccineCode,
  required int doseNumber,
  Value<DateTime?> administeredDate,
  Value<String?> facilityName,
  Value<int> rowid,
});
typedef $$VaccinationRecordsTableUpdateCompanionBuilder
    = VaccinationRecordsCompanion Function({
  Value<String> id,
  Value<String> childId,
  Value<String> vaccineCode,
  Value<int> doseNumber,
  Value<DateTime?> administeredDate,
  Value<String?> facilityName,
  Value<int> rowid,
});

final class $$VaccinationRecordsTableReferences extends BaseReferences<
    _$AppDatabase, $VaccinationRecordsTable, VaccinationRecord> {
  $$VaccinationRecordsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChildProfilesTable _childIdTable(_$AppDatabase db) =>
      db.childProfiles.createAlias($_aliasNameGenerator(
          db.vaccinationRecords.childId, db.childProfiles.id));

  $$ChildProfilesTableProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $$ChildProfilesTableTableManager($_db, $_db.childProfiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VaccinationRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $VaccinationRecordsTable> {
  $$VaccinationRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vaccineCode => $composableBuilder(
      column: $table.vaccineCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get doseNumber => $composableBuilder(
      column: $table.doseNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get administeredDate => $composableBuilder(
      column: $table.administeredDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get facilityName => $composableBuilder(
      column: $table.facilityName, builder: (column) => ColumnFilters(column));

  $$ChildProfilesTableFilterComposer get childId {
    final $$ChildProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableFilterComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VaccinationRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $VaccinationRecordsTable> {
  $$VaccinationRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vaccineCode => $composableBuilder(
      column: $table.vaccineCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get doseNumber => $composableBuilder(
      column: $table.doseNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get administeredDate => $composableBuilder(
      column: $table.administeredDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get facilityName => $composableBuilder(
      column: $table.facilityName,
      builder: (column) => ColumnOrderings(column));

  $$ChildProfilesTableOrderingComposer get childId {
    final $$ChildProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VaccinationRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaccinationRecordsTable> {
  $$VaccinationRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vaccineCode => $composableBuilder(
      column: $table.vaccineCode, builder: (column) => column);

  GeneratedColumn<int> get doseNumber => $composableBuilder(
      column: $table.doseNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get administeredDate => $composableBuilder(
      column: $table.administeredDate, builder: (column) => column);

  GeneratedColumn<String> get facilityName => $composableBuilder(
      column: $table.facilityName, builder: (column) => column);

  $$ChildProfilesTableAnnotationComposer get childId {
    final $$ChildProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VaccinationRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VaccinationRecordsTable,
    VaccinationRecord,
    $$VaccinationRecordsTableFilterComposer,
    $$VaccinationRecordsTableOrderingComposer,
    $$VaccinationRecordsTableAnnotationComposer,
    $$VaccinationRecordsTableCreateCompanionBuilder,
    $$VaccinationRecordsTableUpdateCompanionBuilder,
    (VaccinationRecord, $$VaccinationRecordsTableReferences),
    VaccinationRecord,
    PrefetchHooks Function({bool childId})> {
  $$VaccinationRecordsTableTableManager(
      _$AppDatabase db, $VaccinationRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaccinationRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaccinationRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaccinationRecordsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<String> vaccineCode = const Value.absent(),
            Value<int> doseNumber = const Value.absent(),
            Value<DateTime?> administeredDate = const Value.absent(),
            Value<String?> facilityName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VaccinationRecordsCompanion(
            id: id,
            childId: childId,
            vaccineCode: vaccineCode,
            doseNumber: doseNumber,
            administeredDate: administeredDate,
            facilityName: facilityName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childId,
            required String vaccineCode,
            required int doseNumber,
            Value<DateTime?> administeredDate = const Value.absent(),
            Value<String?> facilityName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VaccinationRecordsCompanion.insert(
            id: id,
            childId: childId,
            vaccineCode: vaccineCode,
            doseNumber: doseNumber,
            administeredDate: administeredDate,
            facilityName: facilityName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VaccinationRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (childId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childId,
                    referencedTable:
                        $$VaccinationRecordsTableReferences._childIdTable(db),
                    referencedColumn: $$VaccinationRecordsTableReferences
                        ._childIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$VaccinationRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VaccinationRecordsTable,
    VaccinationRecord,
    $$VaccinationRecordsTableFilterComposer,
    $$VaccinationRecordsTableOrderingComposer,
    $$VaccinationRecordsTableAnnotationComposer,
    $$VaccinationRecordsTableCreateCompanionBuilder,
    $$VaccinationRecordsTableUpdateCompanionBuilder,
    (VaccinationRecord, $$VaccinationRecordsTableReferences),
    VaccinationRecord,
    PrefetchHooks Function({bool childId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChildProfilesTableTableManager get childProfiles =>
      $$ChildProfilesTableTableManager(_db, _db.childProfiles);
  $$VaccinationRecordsTableTableManager get vaccinationRecords =>
      $$VaccinationRecordsTableTableManager(_db, _db.vaccinationRecords);
}

mixin _$ChildProfilesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChildProfilesTable get childProfiles => attachedDatabase.childProfiles;
}
mixin _$VaccinationRecordsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChildProfilesTable get childProfiles => attachedDatabase.childProfiles;
  $VaccinationRecordsTable get vaccinationRecords =>
      attachedDatabase.vaccinationRecords;
}
