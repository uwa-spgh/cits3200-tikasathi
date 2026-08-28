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
      GeneratedColumn<DateTime>('administered_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
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
    } else if (isInserting) {
      context.missing(_administeredDateMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {childId, vaccineCode, doseNumber},
      ];
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
          DriftSqlType.dateTime, data['${effectivePrefix}administered_date'])!,
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
  final DateTime administeredDate;
  final String? facilityName;
  const VaccinationRecord(
      {required this.id,
      required this.childId,
      required this.vaccineCode,
      required this.doseNumber,
      required this.administeredDate,
      this.facilityName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['vaccine_code'] = Variable<String>(vaccineCode);
    map['dose_number'] = Variable<int>(doseNumber);
    map['administered_date'] = Variable<DateTime>(administeredDate);
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
      administeredDate: Value(administeredDate),
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
      administeredDate: serializer.fromJson<DateTime>(json['administeredDate']),
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
      'administeredDate': serializer.toJson<DateTime>(administeredDate),
      'facilityName': serializer.toJson<String?>(facilityName),
    };
  }

  VaccinationRecord copyWith(
          {String? id,
          String? childId,
          String? vaccineCode,
          int? doseNumber,
          DateTime? administeredDate,
          Value<String?> facilityName = const Value.absent()}) =>
      VaccinationRecord(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        vaccineCode: vaccineCode ?? this.vaccineCode,
        doseNumber: doseNumber ?? this.doseNumber,
        administeredDate: administeredDate ?? this.administeredDate,
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
  final Value<DateTime> administeredDate;
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
    required DateTime administeredDate,
    this.facilityName = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        vaccineCode = Value(vaccineCode),
        doseNumber = Value(doseNumber),
        administeredDate = Value(administeredDate);
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
      Value<DateTime>? administeredDate,
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

class $VaccinationDuesTable extends VaccinationDues
    with TableInfo<$VaccinationDuesTable, VaccinationDue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaccinationDuesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, childId, vaccineCode, doseNumber, dueDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaccination_dues';
  @override
  VerificationContext validateIntegrity(Insertable<VaccinationDue> instance,
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
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {childId, vaccineCode, doseNumber},
      ];
  @override
  VaccinationDue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaccinationDue(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
      vaccineCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vaccine_code'])!,
      doseNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dose_number'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
    );
  }

  @override
  $VaccinationDuesTable createAlias(String alias) {
    return $VaccinationDuesTable(attachedDatabase, alias);
  }
}

class VaccinationDue extends DataClass implements Insertable<VaccinationDue> {
  final String id;
  final String childId;
  final String vaccineCode;
  final int doseNumber;
  final DateTime dueDate;
  const VaccinationDue(
      {required this.id,
      required this.childId,
      required this.vaccineCode,
      required this.doseNumber,
      required this.dueDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['vaccine_code'] = Variable<String>(vaccineCode);
    map['dose_number'] = Variable<int>(doseNumber);
    map['due_date'] = Variable<DateTime>(dueDate);
    return map;
  }

  VaccinationDuesCompanion toCompanion(bool nullToAbsent) {
    return VaccinationDuesCompanion(
      id: Value(id),
      childId: Value(childId),
      vaccineCode: Value(vaccineCode),
      doseNumber: Value(doseNumber),
      dueDate: Value(dueDate),
    );
  }

  factory VaccinationDue.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaccinationDue(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      vaccineCode: serializer.fromJson<String>(json['vaccineCode']),
      doseNumber: serializer.fromJson<int>(json['doseNumber']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
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
      'dueDate': serializer.toJson<DateTime>(dueDate),
    };
  }

  VaccinationDue copyWith(
          {String? id,
          String? childId,
          String? vaccineCode,
          int? doseNumber,
          DateTime? dueDate}) =>
      VaccinationDue(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        vaccineCode: vaccineCode ?? this.vaccineCode,
        doseNumber: doseNumber ?? this.doseNumber,
        dueDate: dueDate ?? this.dueDate,
      );
  VaccinationDue copyWithCompanion(VaccinationDuesCompanion data) {
    return VaccinationDue(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      vaccineCode:
          data.vaccineCode.present ? data.vaccineCode.value : this.vaccineCode,
      doseNumber:
          data.doseNumber.present ? data.doseNumber.value : this.doseNumber,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationDue(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('vaccineCode: $vaccineCode, ')
          ..write('doseNumber: $doseNumber, ')
          ..write('dueDate: $dueDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, childId, vaccineCode, doseNumber, dueDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaccinationDue &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.vaccineCode == this.vaccineCode &&
          other.doseNumber == this.doseNumber &&
          other.dueDate == this.dueDate);
}

class VaccinationDuesCompanion extends UpdateCompanion<VaccinationDue> {
  final Value<String> id;
  final Value<String> childId;
  final Value<String> vaccineCode;
  final Value<int> doseNumber;
  final Value<DateTime> dueDate;
  final Value<int> rowid;
  const VaccinationDuesCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.vaccineCode = const Value.absent(),
    this.doseNumber = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaccinationDuesCompanion.insert({
    required String id,
    required String childId,
    required String vaccineCode,
    required int doseNumber,
    required DateTime dueDate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        vaccineCode = Value(vaccineCode),
        doseNumber = Value(doseNumber),
        dueDate = Value(dueDate);
  static Insertable<VaccinationDue> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? vaccineCode,
    Expression<int>? doseNumber,
    Expression<DateTime>? dueDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (vaccineCode != null) 'vaccine_code': vaccineCode,
      if (doseNumber != null) 'dose_number': doseNumber,
      if (dueDate != null) 'due_date': dueDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaccinationDuesCompanion copyWith(
      {Value<String>? id,
      Value<String>? childId,
      Value<String>? vaccineCode,
      Value<int>? doseNumber,
      Value<DateTime>? dueDate,
      Value<int>? rowid}) {
    return VaccinationDuesCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      vaccineCode: vaccineCode ?? this.vaccineCode,
      doseNumber: doseNumber ?? this.doseNumber,
      dueDate: dueDate ?? this.dueDate,
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
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationDuesCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('vaccineCode: $vaccineCode, ')
          ..write('doseNumber: $doseNumber, ')
          ..write('dueDate: $dueDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dueIdMeta = const VerificationMeta('dueId');
  @override
  late final GeneratedColumn<String> dueId = GeneratedColumn<String>(
      'due_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES vaccination_dues (id)'));
  @override
  late final GeneratedColumnWithTypeConverter<ReminderKind, String> kind =
      GeneratedColumn<String>('kind', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ReminderKind>($RemindersTable.$converterkind);
  static const VerificationMeta _scheduledForMeta =
      const VerificationMeta('scheduledFor');
  @override
  late final GeneratedColumn<DateTime> scheduledFor = GeneratedColumn<DateTime>(
      'scheduled_for', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notificationIdMeta =
      const VerificationMeta('notificationId');
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
      'notification_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deliveredAtMeta =
      const VerificationMeta('deliveredAt');
  @override
  late final GeneratedColumn<DateTime> deliveredAt = GeneratedColumn<DateTime>(
      'delivered_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, childId, dueId, kind, scheduledFor, notificationId, deliveredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<Reminder> instance,
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
    if (data.containsKey('due_id')) {
      context.handle(
          _dueIdMeta, dueId.isAcceptableOrUnknown(data['due_id']!, _dueIdMeta));
    } else if (isInserting) {
      context.missing(_dueIdMeta);
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(
          _scheduledForMeta,
          scheduledFor.isAcceptableOrUnknown(
              data['scheduled_for']!, _scheduledForMeta));
    } else if (isInserting) {
      context.missing(_scheduledForMeta);
    }
    if (data.containsKey('notification_id')) {
      context.handle(
          _notificationIdMeta,
          notificationId.isAcceptableOrUnknown(
              data['notification_id']!, _notificationIdMeta));
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
          _deliveredAtMeta,
          deliveredAt.isAcceptableOrUnknown(
              data['delivered_at']!, _deliveredAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {notificationId},
        {dueId, kind, scheduledFor},
      ];
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
      dueId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_id'])!,
      kind: $RemindersTable.$converterkind.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!),
      scheduledFor: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}scheduled_for'])!,
      notificationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}notification_id'])!,
      deliveredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}delivered_at']),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReminderKind, String, String> $converterkind =
      const EnumNameConverter<ReminderKind>(ReminderKind.values);
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String id;
  final String childId;
  final String dueId;

  /// Which reminder rule produced this row. See [ReminderKind].
  final ReminderKind kind;
  final DateTime scheduledFor;

  /// The id this reminder is registered under with the device's notification
  /// system. Unique so a reminder can be cancelled without ambiguity.
  final int notificationId;

  /// When the reminder was handed to the device. Null while still pending.
  final DateTime? deliveredAt;
  const Reminder(
      {required this.id,
      required this.childId,
      required this.dueId,
      required this.kind,
      required this.scheduledFor,
      required this.notificationId,
      this.deliveredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['due_id'] = Variable<String>(dueId);
    {
      map['kind'] =
          Variable<String>($RemindersTable.$converterkind.toSql(kind));
    }
    map['scheduled_for'] = Variable<DateTime>(scheduledFor);
    map['notification_id'] = Variable<int>(notificationId);
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      childId: Value(childId),
      dueId: Value(dueId),
      kind: Value(kind),
      scheduledFor: Value(scheduledFor),
      notificationId: Value(notificationId),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      dueId: serializer.fromJson<String>(json['dueId']),
      kind: $RemindersTable.$converterkind
          .fromJson(serializer.fromJson<String>(json['kind'])),
      scheduledFor: serializer.fromJson<DateTime>(json['scheduledFor']),
      notificationId: serializer.fromJson<int>(json['notificationId']),
      deliveredAt: serializer.fromJson<DateTime?>(json['deliveredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'dueId': serializer.toJson<String>(dueId),
      'kind': serializer
          .toJson<String>($RemindersTable.$converterkind.toJson(kind)),
      'scheduledFor': serializer.toJson<DateTime>(scheduledFor),
      'notificationId': serializer.toJson<int>(notificationId),
      'deliveredAt': serializer.toJson<DateTime?>(deliveredAt),
    };
  }

  Reminder copyWith(
          {String? id,
          String? childId,
          String? dueId,
          ReminderKind? kind,
          DateTime? scheduledFor,
          int? notificationId,
          Value<DateTime?> deliveredAt = const Value.absent()}) =>
      Reminder(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        dueId: dueId ?? this.dueId,
        kind: kind ?? this.kind,
        scheduledFor: scheduledFor ?? this.scheduledFor,
        notificationId: notificationId ?? this.notificationId,
        deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
      );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      dueId: data.dueId.present ? data.dueId.value : this.dueId,
      kind: data.kind.present ? data.kind.value : this.kind,
      scheduledFor: data.scheduledFor.present
          ? data.scheduledFor.value
          : this.scheduledFor,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      deliveredAt:
          data.deliveredAt.present ? data.deliveredAt.value : this.deliveredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('dueId: $dueId, ')
          ..write('kind: $kind, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('notificationId: $notificationId, ')
          ..write('deliveredAt: $deliveredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, childId, dueId, kind, scheduledFor, notificationId, deliveredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.dueId == this.dueId &&
          other.kind == this.kind &&
          other.scheduledFor == this.scheduledFor &&
          other.notificationId == this.notificationId &&
          other.deliveredAt == this.deliveredAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> id;
  final Value<String> childId;
  final Value<String> dueId;
  final Value<ReminderKind> kind;
  final Value<DateTime> scheduledFor;
  final Value<int> notificationId;
  final Value<DateTime?> deliveredAt;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.dueId = const Value.absent(),
    this.kind = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String childId,
    required String dueId,
    required ReminderKind kind,
    required DateTime scheduledFor,
    required int notificationId,
    this.deliveredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        dueId = Value(dueId),
        kind = Value(kind),
        scheduledFor = Value(scheduledFor),
        notificationId = Value(notificationId);
  static Insertable<Reminder> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? dueId,
    Expression<String>? kind,
    Expression<DateTime>? scheduledFor,
    Expression<int>? notificationId,
    Expression<DateTime>? deliveredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (dueId != null) 'due_id': dueId,
      if (kind != null) 'kind': kind,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (notificationId != null) 'notification_id': notificationId,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith(
      {Value<String>? id,
      Value<String>? childId,
      Value<String>? dueId,
      Value<ReminderKind>? kind,
      Value<DateTime>? scheduledFor,
      Value<int>? notificationId,
      Value<DateTime?>? deliveredAt,
      Value<int>? rowid}) {
    return RemindersCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      dueId: dueId ?? this.dueId,
      kind: kind ?? this.kind,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      notificationId: notificationId ?? this.notificationId,
      deliveredAt: deliveredAt ?? this.deliveredAt,
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
    if (dueId.present) {
      map['due_id'] = Variable<String>(dueId.value);
    }
    if (kind.present) {
      map['kind'] =
          Variable<String>($RemindersTable.$converterkind.toSql(kind.value));
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('dueId: $dueId, ')
          ..write('kind: $kind, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('notificationId: $notificationId, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HealthFacilitatorsTable extends HealthFacilitators
    with TableInfo<$HealthFacilitatorsTable, HealthFacilitator> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthFacilitatorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, address, phone];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_facilitators';
  @override
  VerificationContext validateIntegrity(Insertable<HealthFacilitator> instance,
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
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthFacilitator map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthFacilitator(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
    );
  }

  @override
  $HealthFacilitatorsTable createAlias(String alias) {
    return $HealthFacilitatorsTable(attachedDatabase, alias);
  }
}

class HealthFacilitator extends DataClass
    implements Insertable<HealthFacilitator> {
  final String id;
  final String? name;
  final String? address;
  final String? phone;
  const HealthFacilitator(
      {required this.id, this.name, this.address, this.phone});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    return map;
  }

  HealthFacilitatorsCompanion toCompanion(bool nullToAbsent) {
    return HealthFacilitatorsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
    );
  }

  factory HealthFacilitator.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthFacilitator(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
    };
  }

  HealthFacilitator copyWith(
          {String? id,
          Value<String?> name = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<String?> phone = const Value.absent()}) =>
      HealthFacilitator(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
        address: address.present ? address.value : this.address,
        phone: phone.present ? phone.value : this.phone,
      );
  HealthFacilitator copyWithCompanion(HealthFacilitatorsCompanion data) {
    return HealthFacilitator(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthFacilitator(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('phone: $phone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, address, phone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthFacilitator &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.phone == this.phone);
}

class HealthFacilitatorsCompanion extends UpdateCompanion<HealthFacilitator> {
  final Value<String> id;
  final Value<String?> name;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<int> rowid;
  const HealthFacilitatorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthFacilitatorsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<HealthFacilitator> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthFacilitatorsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? name,
      Value<String?>? address,
      Value<String?>? phone,
      Value<int>? rowid}) {
    return HealthFacilitatorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
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
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthFacilitatorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
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
  late final $VaccinationDuesTable vaccinationDues =
      $VaccinationDuesTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $HealthFacilitatorsTable healthFacilitators =
      $HealthFacilitatorsTable(this);
  late final ChildProfilesDao childProfilesDao =
      ChildProfilesDao(this as AppDatabase);
  late final VaccinationRecordsDao vaccinationRecordsDao =
      VaccinationRecordsDao(this as AppDatabase);
  late final VaccinationDuesDao vaccinationDuesDao =
      VaccinationDuesDao(this as AppDatabase);
  late final RemindersDao remindersDao = RemindersDao(this as AppDatabase);
  late final HealthFacilitatorsDao healthFacilitatorsDao =
      HealthFacilitatorsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        childProfiles,
        vaccinationRecords,
        vaccinationDues,
        reminders,
        healthFacilitators
      ];
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

  static MultiTypedResultKey<$VaccinationDuesTable, List<VaccinationDue>>
      _vaccinationDuesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.vaccinationDues,
              aliasName: $_aliasNameGenerator(
                  db.childProfiles.id, db.vaccinationDues.childId));

  $$VaccinationDuesTableProcessedTableManager get vaccinationDuesRefs {
    final manager =
        $$VaccinationDuesTableTableManager($_db, $_db.vaccinationDues)
            .filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_vaccinationDuesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
      _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.reminders,
          aliasName:
              $_aliasNameGenerator(db.childProfiles.id, db.reminders.childId));

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager($_db, $_db.reminders)
        .filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
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

  Expression<bool> vaccinationDuesRefs(
      Expression<bool> Function($$VaccinationDuesTableFilterComposer f) f) {
    final $$VaccinationDuesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vaccinationDues,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VaccinationDuesTableFilterComposer(
              $db: $db,
              $table: $db.vaccinationDues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> remindersRefs(
      Expression<bool> Function($$RemindersTableFilterComposer f) f) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableFilterComposer(
              $db: $db,
              $table: $db.reminders,
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

  Expression<T> vaccinationDuesRefs<T extends Object>(
      Expression<T> Function($$VaccinationDuesTableAnnotationComposer a) f) {
    final $$VaccinationDuesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vaccinationDues,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VaccinationDuesTableAnnotationComposer(
              $db: $db,
              $table: $db.vaccinationDues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
      Expression<T> Function($$RemindersTableAnnotationComposer a) f) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableAnnotationComposer(
              $db: $db,
              $table: $db.reminders,
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
    PrefetchHooks Function(
        {bool vaccinationRecordsRefs,
        bool vaccinationDuesRefs,
        bool remindersRefs})> {
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
          prefetchHooksCallback: (
              {vaccinationRecordsRefs = false,
              vaccinationDuesRefs = false,
              remindersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (vaccinationRecordsRefs) db.vaccinationRecords,
                if (vaccinationDuesRefs) db.vaccinationDues,
                if (remindersRefs) db.reminders
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
                        typedResults: items),
                  if (vaccinationDuesRefs)
                    await $_getPrefetchedData<ChildProfile, $ChildProfilesTable, VaccinationDue>(
                        currentTable: table,
                        referencedTable: $$ChildProfilesTableReferences
                            ._vaccinationDuesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChildProfilesTableReferences(db, table, p0)
                                .vaccinationDuesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.childId == item.id),
                        typedResults: items),
                  if (remindersRefs)
                    await $_getPrefetchedData<ChildProfile, $ChildProfilesTable,
                            Reminder>(
                        currentTable: table,
                        referencedTable: $$ChildProfilesTableReferences
                            ._remindersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChildProfilesTableReferences(db, table, p0)
                                .remindersRefs,
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
    PrefetchHooks Function(
        {bool vaccinationRecordsRefs,
        bool vaccinationDuesRefs,
        bool remindersRefs})>;
typedef $$VaccinationRecordsTableCreateCompanionBuilder
    = VaccinationRecordsCompanion Function({
  required String id,
  required String childId,
  required String vaccineCode,
  required int doseNumber,
  required DateTime administeredDate,
  Value<String?> facilityName,
  Value<int> rowid,
});
typedef $$VaccinationRecordsTableUpdateCompanionBuilder
    = VaccinationRecordsCompanion Function({
  Value<String> id,
  Value<String> childId,
  Value<String> vaccineCode,
  Value<int> doseNumber,
  Value<DateTime> administeredDate,
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
            Value<DateTime> administeredDate = const Value.absent(),
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
            required DateTime administeredDate,
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
typedef $$VaccinationDuesTableCreateCompanionBuilder = VaccinationDuesCompanion
    Function({
  required String id,
  required String childId,
  required String vaccineCode,
  required int doseNumber,
  required DateTime dueDate,
  Value<int> rowid,
});
typedef $$VaccinationDuesTableUpdateCompanionBuilder = VaccinationDuesCompanion
    Function({
  Value<String> id,
  Value<String> childId,
  Value<String> vaccineCode,
  Value<int> doseNumber,
  Value<DateTime> dueDate,
  Value<int> rowid,
});

final class $$VaccinationDuesTableReferences extends BaseReferences<
    _$AppDatabase, $VaccinationDuesTable, VaccinationDue> {
  $$VaccinationDuesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChildProfilesTable _childIdTable(_$AppDatabase db) =>
      db.childProfiles.createAlias($_aliasNameGenerator(
          db.vaccinationDues.childId, db.childProfiles.id));

  $$ChildProfilesTableProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $$ChildProfilesTableTableManager($_db, $_db.childProfiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
      _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.reminders,
          aliasName:
              $_aliasNameGenerator(db.vaccinationDues.id, db.reminders.dueId));

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager($_db, $_db.reminders)
        .filter((f) => f.dueId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VaccinationDuesTableFilterComposer
    extends Composer<_$AppDatabase, $VaccinationDuesTable> {
  $$VaccinationDuesTableFilterComposer({
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

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

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

  Expression<bool> remindersRefs(
      Expression<bool> Function($$RemindersTableFilterComposer f) f) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.dueId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableFilterComposer(
              $db: $db,
              $table: $db.reminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VaccinationDuesTableOrderingComposer
    extends Composer<_$AppDatabase, $VaccinationDuesTable> {
  $$VaccinationDuesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

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

class $$VaccinationDuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaccinationDuesTable> {
  $$VaccinationDuesTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

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

  Expression<T> remindersRefs<T extends Object>(
      Expression<T> Function($$RemindersTableAnnotationComposer a) f) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.dueId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableAnnotationComposer(
              $db: $db,
              $table: $db.reminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VaccinationDuesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VaccinationDuesTable,
    VaccinationDue,
    $$VaccinationDuesTableFilterComposer,
    $$VaccinationDuesTableOrderingComposer,
    $$VaccinationDuesTableAnnotationComposer,
    $$VaccinationDuesTableCreateCompanionBuilder,
    $$VaccinationDuesTableUpdateCompanionBuilder,
    (VaccinationDue, $$VaccinationDuesTableReferences),
    VaccinationDue,
    PrefetchHooks Function({bool childId, bool remindersRefs})> {
  $$VaccinationDuesTableTableManager(
      _$AppDatabase db, $VaccinationDuesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaccinationDuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaccinationDuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaccinationDuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<String> vaccineCode = const Value.absent(),
            Value<int> doseNumber = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VaccinationDuesCompanion(
            id: id,
            childId: childId,
            vaccineCode: vaccineCode,
            doseNumber: doseNumber,
            dueDate: dueDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childId,
            required String vaccineCode,
            required int doseNumber,
            required DateTime dueDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              VaccinationDuesCompanion.insert(
            id: id,
            childId: childId,
            vaccineCode: vaccineCode,
            doseNumber: doseNumber,
            dueDate: dueDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VaccinationDuesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({childId = false, remindersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (remindersRefs) db.reminders],
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
                        $$VaccinationDuesTableReferences._childIdTable(db),
                    referencedColumn:
                        $$VaccinationDuesTableReferences._childIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (remindersRefs)
                    await $_getPrefetchedData<VaccinationDue,
                            $VaccinationDuesTable, Reminder>(
                        currentTable: table,
                        referencedTable: $$VaccinationDuesTableReferences
                            ._remindersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VaccinationDuesTableReferences(db, table, p0)
                                .remindersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.dueId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VaccinationDuesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VaccinationDuesTable,
    VaccinationDue,
    $$VaccinationDuesTableFilterComposer,
    $$VaccinationDuesTableOrderingComposer,
    $$VaccinationDuesTableAnnotationComposer,
    $$VaccinationDuesTableCreateCompanionBuilder,
    $$VaccinationDuesTableUpdateCompanionBuilder,
    (VaccinationDue, $$VaccinationDuesTableReferences),
    VaccinationDue,
    PrefetchHooks Function({bool childId, bool remindersRefs})>;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String id,
  required String childId,
  required String dueId,
  required ReminderKind kind,
  required DateTime scheduledFor,
  required int notificationId,
  Value<DateTime?> deliveredAt,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> id,
  Value<String> childId,
  Value<String> dueId,
  Value<ReminderKind> kind,
  Value<DateTime> scheduledFor,
  Value<int> notificationId,
  Value<DateTime?> deliveredAt,
  Value<int> rowid,
});

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildProfilesTable _childIdTable(_$AppDatabase db) =>
      db.childProfiles.createAlias(
          $_aliasNameGenerator(db.reminders.childId, db.childProfiles.id));

  $$ChildProfilesTableProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $$ChildProfilesTableTableManager($_db, $_db.childProfiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $VaccinationDuesTable _dueIdTable(_$AppDatabase db) =>
      db.vaccinationDues.createAlias(
          $_aliasNameGenerator(db.reminders.dueId, db.vaccinationDues.id));

  $$VaccinationDuesTableProcessedTableManager get dueId {
    final $_column = $_itemColumn<String>('due_id')!;

    final manager =
        $$VaccinationDuesTableTableManager($_db, $_db.vaccinationDues)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dueIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ReminderKind, ReminderKind, String> get kind =>
      $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get scheduledFor => $composableBuilder(
      column: $table.scheduledFor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get notificationId => $composableBuilder(
      column: $table.notificationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deliveredAt => $composableBuilder(
      column: $table.deliveredAt, builder: (column) => ColumnFilters(column));

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

  $$VaccinationDuesTableFilterComposer get dueId {
    final $$VaccinationDuesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dueId,
        referencedTable: $db.vaccinationDues,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VaccinationDuesTableFilterComposer(
              $db: $db,
              $table: $db.vaccinationDues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledFor => $composableBuilder(
      column: $table.scheduledFor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get notificationId => $composableBuilder(
      column: $table.notificationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deliveredAt => $composableBuilder(
      column: $table.deliveredAt, builder: (column) => ColumnOrderings(column));

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

  $$VaccinationDuesTableOrderingComposer get dueId {
    final $$VaccinationDuesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dueId,
        referencedTable: $db.vaccinationDues,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VaccinationDuesTableOrderingComposer(
              $db: $db,
              $table: $db.vaccinationDues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledFor => $composableBuilder(
      column: $table.scheduledFor, builder: (column) => column);

  GeneratedColumn<int> get notificationId => $composableBuilder(
      column: $table.notificationId, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveredAt => $composableBuilder(
      column: $table.deliveredAt, builder: (column) => column);

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

  $$VaccinationDuesTableAnnotationComposer get dueId {
    final $$VaccinationDuesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dueId,
        referencedTable: $db.vaccinationDues,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VaccinationDuesTableAnnotationComposer(
              $db: $db,
              $table: $db.vaccinationDues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RemindersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, $$RemindersTableReferences),
    Reminder,
    PrefetchHooks Function({bool childId, bool dueId})> {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<String> dueId = const Value.absent(),
            Value<ReminderKind> kind = const Value.absent(),
            Value<DateTime> scheduledFor = const Value.absent(),
            Value<int> notificationId = const Value.absent(),
            Value<DateTime?> deliveredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemindersCompanion(
            id: id,
            childId: childId,
            dueId: dueId,
            kind: kind,
            scheduledFor: scheduledFor,
            notificationId: notificationId,
            deliveredAt: deliveredAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childId,
            required String dueId,
            required ReminderKind kind,
            required DateTime scheduledFor,
            required int notificationId,
            Value<DateTime?> deliveredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemindersCompanion.insert(
            id: id,
            childId: childId,
            dueId: dueId,
            kind: kind,
            scheduledFor: scheduledFor,
            notificationId: notificationId,
            deliveredAt: deliveredAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RemindersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({childId = false, dueId = false}) {
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
                        $$RemindersTableReferences._childIdTable(db),
                    referencedColumn:
                        $$RemindersTableReferences._childIdTable(db).id,
                  ) as T;
                }
                if (dueId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.dueId,
                    referencedTable: $$RemindersTableReferences._dueIdTable(db),
                    referencedColumn:
                        $$RemindersTableReferences._dueIdTable(db).id,
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

typedef $$RemindersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, $$RemindersTableReferences),
    Reminder,
    PrefetchHooks Function({bool childId, bool dueId})>;
typedef $$HealthFacilitatorsTableCreateCompanionBuilder
    = HealthFacilitatorsCompanion Function({
  required String id,
  Value<String?> name,
  Value<String?> address,
  Value<String?> phone,
  Value<int> rowid,
});
typedef $$HealthFacilitatorsTableUpdateCompanionBuilder
    = HealthFacilitatorsCompanion Function({
  Value<String> id,
  Value<String?> name,
  Value<String?> address,
  Value<String?> phone,
  Value<int> rowid,
});

class $$HealthFacilitatorsTableFilterComposer
    extends Composer<_$AppDatabase, $HealthFacilitatorsTable> {
  $$HealthFacilitatorsTableFilterComposer({
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

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));
}

class $$HealthFacilitatorsTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthFacilitatorsTable> {
  $$HealthFacilitatorsTableOrderingComposer({
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

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));
}

class $$HealthFacilitatorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthFacilitatorsTable> {
  $$HealthFacilitatorsTableAnnotationComposer({
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

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);
}

class $$HealthFacilitatorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HealthFacilitatorsTable,
    HealthFacilitator,
    $$HealthFacilitatorsTableFilterComposer,
    $$HealthFacilitatorsTableOrderingComposer,
    $$HealthFacilitatorsTableAnnotationComposer,
    $$HealthFacilitatorsTableCreateCompanionBuilder,
    $$HealthFacilitatorsTableUpdateCompanionBuilder,
    (
      HealthFacilitator,
      BaseReferences<_$AppDatabase, $HealthFacilitatorsTable, HealthFacilitator>
    ),
    HealthFacilitator,
    PrefetchHooks Function()> {
  $$HealthFacilitatorsTableTableManager(
      _$AppDatabase db, $HealthFacilitatorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthFacilitatorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthFacilitatorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthFacilitatorsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HealthFacilitatorsCompanion(
            id: id,
            name: name,
            address: address,
            phone: phone,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> name = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HealthFacilitatorsCompanion.insert(
            id: id,
            name: name,
            address: address,
            phone: phone,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HealthFacilitatorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HealthFacilitatorsTable,
    HealthFacilitator,
    $$HealthFacilitatorsTableFilterComposer,
    $$HealthFacilitatorsTableOrderingComposer,
    $$HealthFacilitatorsTableAnnotationComposer,
    $$HealthFacilitatorsTableCreateCompanionBuilder,
    $$HealthFacilitatorsTableUpdateCompanionBuilder,
    (
      HealthFacilitator,
      BaseReferences<_$AppDatabase, $HealthFacilitatorsTable, HealthFacilitator>
    ),
    HealthFacilitator,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChildProfilesTableTableManager get childProfiles =>
      $$ChildProfilesTableTableManager(_db, _db.childProfiles);
  $$VaccinationRecordsTableTableManager get vaccinationRecords =>
      $$VaccinationRecordsTableTableManager(_db, _db.vaccinationRecords);
  $$VaccinationDuesTableTableManager get vaccinationDues =>
      $$VaccinationDuesTableTableManager(_db, _db.vaccinationDues);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$HealthFacilitatorsTableTableManager get healthFacilitators =>
      $$HealthFacilitatorsTableTableManager(_db, _db.healthFacilitators);
}

mixin _$ChildProfilesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChildProfilesTable get childProfiles => attachedDatabase.childProfiles;
  $VaccinationDuesTable get vaccinationDues => attachedDatabase.vaccinationDues;
  $VaccinationRecordsTable get vaccinationRecords =>
      attachedDatabase.vaccinationRecords;
}
mixin _$VaccinationRecordsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChildProfilesTable get childProfiles => attachedDatabase.childProfiles;
  $VaccinationRecordsTable get vaccinationRecords =>
      attachedDatabase.vaccinationRecords;
  $VaccinationDuesTable get vaccinationDues => attachedDatabase.vaccinationDues;
}
mixin _$VaccinationDuesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChildProfilesTable get childProfiles => attachedDatabase.childProfiles;
  $VaccinationDuesTable get vaccinationDues => attachedDatabase.vaccinationDues;
  $VaccinationRecordsTable get vaccinationRecords =>
      attachedDatabase.vaccinationRecords;
}
mixin _$RemindersDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChildProfilesTable get childProfiles => attachedDatabase.childProfiles;
  $VaccinationDuesTable get vaccinationDues => attachedDatabase.vaccinationDues;
  $RemindersTable get reminders => attachedDatabase.reminders;
}
mixin _$HealthFacilitatorsDaoMixin on DatabaseAccessor<AppDatabase> {
  $HealthFacilitatorsTable get healthFacilitators =>
      attachedDatabase.healthFacilitators;
}
