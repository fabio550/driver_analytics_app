// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, Shift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialKmMeta = const VerificationMeta(
    'initialKm',
  );
  @override
  late final GeneratedColumn<double> initialKm = GeneratedColumn<double>(
    'initial_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finalKmMeta = const VerificationMeta(
    'finalKm',
  );
  @override
  late final GeneratedColumn<double> finalKm = GeneratedColumn<double>(
    'final_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _earningsMeta = const VerificationMeta(
    'earnings',
  );
  @override
  late final GeneratedColumn<double> earnings = GeneratedColumn<double>(
    'earnings',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    initialKm,
    finalKm,
    earnings,
    startTime,
    endTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shift> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('initial_km')) {
      context.handle(
        _initialKmMeta,
        initialKm.isAcceptableOrUnknown(data['initial_km']!, _initialKmMeta),
      );
    } else if (isInserting) {
      context.missing(_initialKmMeta);
    }
    if (data.containsKey('final_km')) {
      context.handle(
        _finalKmMeta,
        finalKm.isAcceptableOrUnknown(data['final_km']!, _finalKmMeta),
      );
    }
    if (data.containsKey('earnings')) {
      context.handle(
        _earningsMeta,
        earnings.isAcceptableOrUnknown(data['earnings']!, _earningsMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shift(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      initialKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_km'],
      )!,
      finalKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}final_km'],
      ),
      earnings: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}earnings'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }
}

class Shift extends DataClass implements Insertable<Shift> {
  final String id;
  final String status;
  final double initialKm;
  final double? finalKm;
  final double? earnings;
  final DateTime startTime;
  final DateTime? endTime;
  const Shift({
    required this.id,
    required this.status,
    required this.initialKm,
    this.finalKm,
    this.earnings,
    required this.startTime,
    this.endTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['status'] = Variable<String>(status);
    map['initial_km'] = Variable<double>(initialKm);
    if (!nullToAbsent || finalKm != null) {
      map['final_km'] = Variable<double>(finalKm);
    }
    if (!nullToAbsent || earnings != null) {
      map['earnings'] = Variable<double>(earnings);
    }
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
      id: Value(id),
      status: Value(status),
      initialKm: Value(initialKm),
      finalKm: finalKm == null && nullToAbsent
          ? const Value.absent()
          : Value(finalKm),
      earnings: earnings == null && nullToAbsent
          ? const Value.absent()
          : Value(earnings),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
    );
  }

  factory Shift.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shift(
      id: serializer.fromJson<String>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      initialKm: serializer.fromJson<double>(json['initialKm']),
      finalKm: serializer.fromJson<double?>(json['finalKm']),
      earnings: serializer.fromJson<double?>(json['earnings']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'status': serializer.toJson<String>(status),
      'initialKm': serializer.toJson<double>(initialKm),
      'finalKm': serializer.toJson<double?>(finalKm),
      'earnings': serializer.toJson<double?>(earnings),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
    };
  }

  Shift copyWith({
    String? id,
    String? status,
    double? initialKm,
    Value<double?> finalKm = const Value.absent(),
    Value<double?> earnings = const Value.absent(),
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
  }) => Shift(
    id: id ?? this.id,
    status: status ?? this.status,
    initialKm: initialKm ?? this.initialKm,
    finalKm: finalKm.present ? finalKm.value : this.finalKm,
    earnings: earnings.present ? earnings.value : this.earnings,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
  );
  Shift copyWithCompanion(ShiftsCompanion data) {
    return Shift(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      initialKm: data.initialKm.present ? data.initialKm.value : this.initialKm,
      finalKm: data.finalKm.present ? data.finalKm.value : this.finalKm,
      earnings: data.earnings.present ? data.earnings.value : this.earnings,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shift(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('initialKm: $initialKm, ')
          ..write('finalKm: $finalKm, ')
          ..write('earnings: $earnings, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, status, initialKm, finalKm, earnings, startTime, endTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shift &&
          other.id == this.id &&
          other.status == this.status &&
          other.initialKm == this.initialKm &&
          other.finalKm == this.finalKm &&
          other.earnings == this.earnings &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime);
}

class ShiftsCompanion extends UpdateCompanion<Shift> {
  final Value<String> id;
  final Value<String> status;
  final Value<double> initialKm;
  final Value<double?> finalKm;
  final Value<double?> earnings;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int> rowid;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.initialKm = const Value.absent(),
    this.finalKm = const Value.absent(),
    this.earnings = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsCompanion.insert({
    required String id,
    required String status,
    required double initialKm,
    this.finalKm = const Value.absent(),
    this.earnings = const Value.absent(),
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       status = Value(status),
       initialKm = Value(initialKm),
       startTime = Value(startTime);
  static Insertable<Shift> custom({
    Expression<String>? id,
    Expression<String>? status,
    Expression<double>? initialKm,
    Expression<double>? finalKm,
    Expression<double>? earnings,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (initialKm != null) 'initial_km': initialKm,
      if (finalKm != null) 'final_km': finalKm,
      if (earnings != null) 'earnings': earnings,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsCompanion copyWith({
    Value<String>? id,
    Value<String>? status,
    Value<double>? initialKm,
    Value<double?>? finalKm,
    Value<double?>? earnings,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<int>? rowid,
  }) {
    return ShiftsCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      initialKm: initialKm ?? this.initialKm,
      finalKm: finalKm ?? this.finalKm,
      earnings: earnings ?? this.earnings,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (initialKm.present) {
      map['initial_km'] = Variable<double>(initialKm.value);
    }
    if (finalKm.present) {
      map['final_km'] = Variable<double>(finalKm.value);
    }
    if (earnings.present) {
      map['earnings'] = Variable<double>(earnings.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('initialKm: $initialKm, ')
          ..write('finalKm: $finalKm, ')
          ..write('earnings: $earnings, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftPausesTable extends ShiftPauses
    with TableInfo<$ShiftPausesTable, ShiftPause> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftPausesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shifts (id)',
    ),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, shiftId, startTime, endTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shift_pauses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShiftPause> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShiftPause map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftPause(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
    );
  }

  @override
  $ShiftPausesTable createAlias(String alias) {
    return $ShiftPausesTable(attachedDatabase, alias);
  }
}

class ShiftPause extends DataClass implements Insertable<ShiftPause> {
  final String id;
  final String shiftId;
  final DateTime startTime;
  final DateTime? endTime;
  const ShiftPause({
    required this.id,
    required this.shiftId,
    required this.startTime,
    this.endTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shift_id'] = Variable<String>(shiftId);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    return map;
  }

  ShiftPausesCompanion toCompanion(bool nullToAbsent) {
    return ShiftPausesCompanion(
      id: Value(id),
      shiftId: Value(shiftId),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
    );
  }

  factory ShiftPause.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftPause(
      id: serializer.fromJson<String>(json['id']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shiftId': serializer.toJson<String>(shiftId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
    };
  }

  ShiftPause copyWith({
    String? id,
    String? shiftId,
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
  }) => ShiftPause(
    id: id ?? this.id,
    shiftId: shiftId ?? this.shiftId,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
  );
  ShiftPause copyWithCompanion(ShiftPausesCompanion data) {
    return ShiftPause(
      id: data.id.present ? data.id.value : this.id,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftPause(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shiftId, startTime, endTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftPause &&
          other.id == this.id &&
          other.shiftId == this.shiftId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime);
}

class ShiftPausesCompanion extends UpdateCompanion<ShiftPause> {
  final Value<String> id;
  final Value<String> shiftId;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int> rowid;
  const ShiftPausesCompanion({
    this.id = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftPausesCompanion.insert({
    required String id,
    required String shiftId,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shiftId = Value(shiftId),
       startTime = Value(startTime);
  static Insertable<ShiftPause> custom({
    Expression<String>? id,
    Expression<String>? shiftId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shiftId != null) 'shift_id': shiftId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftPausesCompanion copyWith({
    Value<String>? id,
    Value<String>? shiftId,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<int>? rowid,
  }) {
    return ShiftPausesCompanion(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftPausesCompanion(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CostsTable extends Costs with TableInfo<$CostsTable, Cost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subcategoryMeta = const VerificationMeta(
    'subcategory',
  );
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    subcategory,
    amount,
    date,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'costs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
        _subcategoryMeta,
        subcategory.isAcceptableOrUnknown(
          data['subcategory']!,
          _subcategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subcategoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cost(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      subcategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $CostsTable createAlias(String alias) {
    return $CostsTable(attachedDatabase, alias);
  }
}

class Cost extends DataClass implements Insertable<Cost> {
  final String id;
  final String category;
  final String subcategory;
  final double amount;
  final DateTime date;
  final String? description;
  const Cost({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.amount,
    required this.date,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['subcategory'] = Variable<String>(subcategory);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  CostsCompanion toCompanion(bool nullToAbsent) {
    return CostsCompanion(
      id: Value(id),
      category: Value(category),
      subcategory: Value(subcategory),
      amount: Value(amount),
      date: Value(date),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory Cost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cost(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      subcategory: serializer.fromJson<String>(json['subcategory']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'subcategory': serializer.toJson<String>(subcategory),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String?>(description),
    };
  }

  Cost copyWith({
    String? id,
    String? category,
    String? subcategory,
    double? amount,
    DateTime? date,
    Value<String?> description = const Value.absent(),
  }) => Cost(
    id: id ?? this.id,
    category: category ?? this.category,
    subcategory: subcategory ?? this.subcategory,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    description: description.present ? description.value : this.description,
  );
  Cost copyWithCompanion(CostsCompanion data) {
    return Cost(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      subcategory: data.subcategory.present
          ? data.subcategory.value
          : this.subcategory,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cost(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, category, subcategory, amount, date, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cost &&
          other.id == this.id &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.description == this.description);
}

class CostsCompanion extends UpdateCompanion<Cost> {
  final Value<String> id;
  final Value<String> category;
  final Value<String> subcategory;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String?> description;
  final Value<int> rowid;
  const CostsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CostsCompanion.insert({
    required String id,
    required String category,
    required String subcategory,
    required double amount,
    required DateTime date,
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       category = Value(category),
       subcategory = Value(subcategory),
       amount = Value(amount),
       date = Value(date);
  static Insertable<Cost> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CostsCompanion copyWith({
    Value<String>? id,
    Value<String>? category,
    Value<String>? subcategory,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String?>? description,
    Value<int>? rowid,
  }) {
    return CostsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CostsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FuelCostsTable extends FuelCosts
    with TableInfo<$FuelCostsTable, FuelCost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FuelCostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _costIdMeta = const VerificationMeta('costId');
  @override
  late final GeneratedColumn<String> costId = GeneratedColumn<String>(
    'cost_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES costs (id)',
    ),
  );
  static const VerificationMeta _odometerKmMeta = const VerificationMeta(
    'odometerKm',
  );
  @override
  late final GeneratedColumn<double> odometerKm = GeneratedColumn<double>(
    'odometer_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFullTankMeta = const VerificationMeta(
    'isFullTank',
  );
  @override
  late final GeneratedColumn<bool> isFullTank = GeneratedColumn<bool>(
    'is_full_tank',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_full_tank" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _previousFillUpMissingMeta =
      const VerificationMeta('previousFillUpMissing');
  @override
  late final GeneratedColumn<bool> previousFillUpMissing =
      GeneratedColumn<bool>(
        'previous_fill_up_missing',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("previous_fill_up_missing" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  @override
  List<GeneratedColumn> get $columns => [
    costId,
    odometerKm,
    quantity,
    isFullTank,
    previousFillUpMissing,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuel_costs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FuelCost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cost_id')) {
      context.handle(
        _costIdMeta,
        costId.isAcceptableOrUnknown(data['cost_id']!, _costIdMeta),
      );
    } else if (isInserting) {
      context.missing(_costIdMeta);
    }
    if (data.containsKey('odometer_km')) {
      context.handle(
        _odometerKmMeta,
        odometerKm.isAcceptableOrUnknown(data['odometer_km']!, _odometerKmMeta),
      );
    } else if (isInserting) {
      context.missing(_odometerKmMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('is_full_tank')) {
      context.handle(
        _isFullTankMeta,
        isFullTank.isAcceptableOrUnknown(
          data['is_full_tank']!,
          _isFullTankMeta,
        ),
      );
    }
    if (data.containsKey('previous_fill_up_missing')) {
      context.handle(
        _previousFillUpMissingMeta,
        previousFillUpMissing.isAcceptableOrUnknown(
          data['previous_fill_up_missing']!,
          _previousFillUpMissingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {costId};
  @override
  FuelCost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FuelCost(
      costId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cost_id'],
      )!,
      odometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}odometer_km'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      isFullTank: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_full_tank'],
      )!,
      previousFillUpMissing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}previous_fill_up_missing'],
      )!,
    );
  }

  @override
  $FuelCostsTable createAlias(String alias) {
    return $FuelCostsTable(attachedDatabase, alias);
  }
}

class FuelCost extends DataClass implements Insertable<FuelCost> {
  final String costId;
  final double odometerKm;
  final double quantity;
  final bool isFullTank;
  final bool previousFillUpMissing;
  const FuelCost({
    required this.costId,
    required this.odometerKm,
    required this.quantity,
    required this.isFullTank,
    required this.previousFillUpMissing,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cost_id'] = Variable<String>(costId);
    map['odometer_km'] = Variable<double>(odometerKm);
    map['quantity'] = Variable<double>(quantity);
    map['is_full_tank'] = Variable<bool>(isFullTank);
    map['previous_fill_up_missing'] = Variable<bool>(previousFillUpMissing);
    return map;
  }

  FuelCostsCompanion toCompanion(bool nullToAbsent) {
    return FuelCostsCompanion(
      costId: Value(costId),
      odometerKm: Value(odometerKm),
      quantity: Value(quantity),
      isFullTank: Value(isFullTank),
      previousFillUpMissing: Value(previousFillUpMissing),
    );
  }

  factory FuelCost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FuelCost(
      costId: serializer.fromJson<String>(json['costId']),
      odometerKm: serializer.fromJson<double>(json['odometerKm']),
      quantity: serializer.fromJson<double>(json['quantity']),
      isFullTank: serializer.fromJson<bool>(json['isFullTank']),
      previousFillUpMissing: serializer.fromJson<bool>(
        json['previousFillUpMissing'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'costId': serializer.toJson<String>(costId),
      'odometerKm': serializer.toJson<double>(odometerKm),
      'quantity': serializer.toJson<double>(quantity),
      'isFullTank': serializer.toJson<bool>(isFullTank),
      'previousFillUpMissing': serializer.toJson<bool>(previousFillUpMissing),
    };
  }

  FuelCost copyWith({
    String? costId,
    double? odometerKm,
    double? quantity,
    bool? isFullTank,
    bool? previousFillUpMissing,
  }) => FuelCost(
    costId: costId ?? this.costId,
    odometerKm: odometerKm ?? this.odometerKm,
    quantity: quantity ?? this.quantity,
    isFullTank: isFullTank ?? this.isFullTank,
    previousFillUpMissing: previousFillUpMissing ?? this.previousFillUpMissing,
  );
  FuelCost copyWithCompanion(FuelCostsCompanion data) {
    return FuelCost(
      costId: data.costId.present ? data.costId.value : this.costId,
      odometerKm: data.odometerKm.present
          ? data.odometerKm.value
          : this.odometerKm,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      isFullTank: data.isFullTank.present
          ? data.isFullTank.value
          : this.isFullTank,
      previousFillUpMissing: data.previousFillUpMissing.present
          ? data.previousFillUpMissing.value
          : this.previousFillUpMissing,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FuelCost(')
          ..write('costId: $costId, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('quantity: $quantity, ')
          ..write('isFullTank: $isFullTank, ')
          ..write('previousFillUpMissing: $previousFillUpMissing')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    costId,
    odometerKm,
    quantity,
    isFullTank,
    previousFillUpMissing,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FuelCost &&
          other.costId == this.costId &&
          other.odometerKm == this.odometerKm &&
          other.quantity == this.quantity &&
          other.isFullTank == this.isFullTank &&
          other.previousFillUpMissing == this.previousFillUpMissing);
}

class FuelCostsCompanion extends UpdateCompanion<FuelCost> {
  final Value<String> costId;
  final Value<double> odometerKm;
  final Value<double> quantity;
  final Value<bool> isFullTank;
  final Value<bool> previousFillUpMissing;
  final Value<int> rowid;
  const FuelCostsCompanion({
    this.costId = const Value.absent(),
    this.odometerKm = const Value.absent(),
    this.quantity = const Value.absent(),
    this.isFullTank = const Value.absent(),
    this.previousFillUpMissing = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FuelCostsCompanion.insert({
    required String costId,
    required double odometerKm,
    required double quantity,
    this.isFullTank = const Value.absent(),
    this.previousFillUpMissing = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : costId = Value(costId),
       odometerKm = Value(odometerKm),
       quantity = Value(quantity);
  static Insertable<FuelCost> custom({
    Expression<String>? costId,
    Expression<double>? odometerKm,
    Expression<double>? quantity,
    Expression<bool>? isFullTank,
    Expression<bool>? previousFillUpMissing,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (costId != null) 'cost_id': costId,
      if (odometerKm != null) 'odometer_km': odometerKm,
      if (quantity != null) 'quantity': quantity,
      if (isFullTank != null) 'is_full_tank': isFullTank,
      if (previousFillUpMissing != null)
        'previous_fill_up_missing': previousFillUpMissing,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FuelCostsCompanion copyWith({
    Value<String>? costId,
    Value<double>? odometerKm,
    Value<double>? quantity,
    Value<bool>? isFullTank,
    Value<bool>? previousFillUpMissing,
    Value<int>? rowid,
  }) {
    return FuelCostsCompanion(
      costId: costId ?? this.costId,
      odometerKm: odometerKm ?? this.odometerKm,
      quantity: quantity ?? this.quantity,
      isFullTank: isFullTank ?? this.isFullTank,
      previousFillUpMissing:
          previousFillUpMissing ?? this.previousFillUpMissing,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (costId.present) {
      map['cost_id'] = Variable<String>(costId.value);
    }
    if (odometerKm.present) {
      map['odometer_km'] = Variable<double>(odometerKm.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (isFullTank.present) {
      map['is_full_tank'] = Variable<bool>(isFullTank.value);
    }
    if (previousFillUpMissing.present) {
      map['previous_fill_up_missing'] = Variable<bool>(
        previousFillUpMissing.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FuelCostsCompanion(')
          ..write('costId: $costId, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('quantity: $quantity, ')
          ..write('isFullTank: $isFullTank, ')
          ..write('previousFillUpMissing: $previousFillUpMissing, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceCostsTable extends MaintenanceCosts
    with TableInfo<$MaintenanceCostsTable, MaintenanceCost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceCostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _costIdMeta = const VerificationMeta('costId');
  @override
  late final GeneratedColumn<String> costId = GeneratedColumn<String>(
    'cost_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES costs (id)',
    ),
  );
  static const VerificationMeta _odometerKmMeta = const VerificationMeta(
    'odometerKm',
  );
  @override
  late final GeneratedColumn<double> odometerKm = GeneratedColumn<double>(
    'odometer_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [costId, odometerKm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_costs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceCost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cost_id')) {
      context.handle(
        _costIdMeta,
        costId.isAcceptableOrUnknown(data['cost_id']!, _costIdMeta),
      );
    } else if (isInserting) {
      context.missing(_costIdMeta);
    }
    if (data.containsKey('odometer_km')) {
      context.handle(
        _odometerKmMeta,
        odometerKm.isAcceptableOrUnknown(data['odometer_km']!, _odometerKmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {costId};
  @override
  MaintenanceCost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceCost(
      costId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cost_id'],
      )!,
      odometerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}odometer_km'],
      ),
    );
  }

  @override
  $MaintenanceCostsTable createAlias(String alias) {
    return $MaintenanceCostsTable(attachedDatabase, alias);
  }
}

class MaintenanceCost extends DataClass implements Insertable<MaintenanceCost> {
  final String costId;
  final double? odometerKm;
  const MaintenanceCost({required this.costId, this.odometerKm});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cost_id'] = Variable<String>(costId);
    if (!nullToAbsent || odometerKm != null) {
      map['odometer_km'] = Variable<double>(odometerKm);
    }
    return map;
  }

  MaintenanceCostsCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceCostsCompanion(
      costId: Value(costId),
      odometerKm: odometerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(odometerKm),
    );
  }

  factory MaintenanceCost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceCost(
      costId: serializer.fromJson<String>(json['costId']),
      odometerKm: serializer.fromJson<double?>(json['odometerKm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'costId': serializer.toJson<String>(costId),
      'odometerKm': serializer.toJson<double?>(odometerKm),
    };
  }

  MaintenanceCost copyWith({
    String? costId,
    Value<double?> odometerKm = const Value.absent(),
  }) => MaintenanceCost(
    costId: costId ?? this.costId,
    odometerKm: odometerKm.present ? odometerKm.value : this.odometerKm,
  );
  MaintenanceCost copyWithCompanion(MaintenanceCostsCompanion data) {
    return MaintenanceCost(
      costId: data.costId.present ? data.costId.value : this.costId,
      odometerKm: data.odometerKm.present
          ? data.odometerKm.value
          : this.odometerKm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceCost(')
          ..write('costId: $costId, ')
          ..write('odometerKm: $odometerKm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(costId, odometerKm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceCost &&
          other.costId == this.costId &&
          other.odometerKm == this.odometerKm);
}

class MaintenanceCostsCompanion extends UpdateCompanion<MaintenanceCost> {
  final Value<String> costId;
  final Value<double?> odometerKm;
  final Value<int> rowid;
  const MaintenanceCostsCompanion({
    this.costId = const Value.absent(),
    this.odometerKm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaintenanceCostsCompanion.insert({
    required String costId,
    this.odometerKm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : costId = Value(costId);
  static Insertable<MaintenanceCost> custom({
    Expression<String>? costId,
    Expression<double>? odometerKm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (costId != null) 'cost_id': costId,
      if (odometerKm != null) 'odometer_km': odometerKm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaintenanceCostsCompanion copyWith({
    Value<String>? costId,
    Value<double?>? odometerKm,
    Value<int>? rowid,
  }) {
    return MaintenanceCostsCompanion(
      costId: costId ?? this.costId,
      odometerKm: odometerKm ?? this.odometerKm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (costId.present) {
      map['cost_id'] = Variable<String>(costId.value);
    }
    if (odometerKm.present) {
      map['odometer_km'] = Variable<double>(odometerKm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceCostsCompanion(')
          ..write('costId: $costId, ')
          ..write('odometerKm: $odometerKm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EarningsTable extends Earnings with TableInfo<$EarningsTable, Earning> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EarningsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shiftId,
    occurredAt,
    kind,
    amount,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'earnings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Earning> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Earning map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Earning(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $EarningsTable createAlias(String alias) {
    return $EarningsTable(attachedDatabase, alias);
  }
}

class Earning extends DataClass implements Insertable<Earning> {
  final String id;
  final String? shiftId;
  final DateTime occurredAt;
  final String kind;
  final double? amount;
  final String? description;
  const Earning({
    required this.id,
    this.shiftId,
    required this.occurredAt,
    required this.kind,
    this.amount,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || shiftId != null) {
      map['shift_id'] = Variable<String>(shiftId);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  EarningsCompanion toCompanion(bool nullToAbsent) {
    return EarningsCompanion(
      id: Value(id),
      shiftId: shiftId == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftId),
      occurredAt: Value(occurredAt),
      kind: Value(kind),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory Earning.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Earning(
      id: serializer.fromJson<String>(json['id']),
      shiftId: serializer.fromJson<String?>(json['shiftId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      kind: serializer.fromJson<String>(json['kind']),
      amount: serializer.fromJson<double?>(json['amount']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shiftId': serializer.toJson<String?>(shiftId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'kind': serializer.toJson<String>(kind),
      'amount': serializer.toJson<double?>(amount),
      'description': serializer.toJson<String?>(description),
    };
  }

  Earning copyWith({
    String? id,
    Value<String?> shiftId = const Value.absent(),
    DateTime? occurredAt,
    String? kind,
    Value<double?> amount = const Value.absent(),
    Value<String?> description = const Value.absent(),
  }) => Earning(
    id: id ?? this.id,
    shiftId: shiftId.present ? shiftId.value : this.shiftId,
    occurredAt: occurredAt ?? this.occurredAt,
    kind: kind ?? this.kind,
    amount: amount.present ? amount.value : this.amount,
    description: description.present ? description.value : this.description,
  );
  Earning copyWithCompanion(EarningsCompanion data) {
    return Earning(
      id: data.id.present ? data.id.value : this.id,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      kind: data.kind.present ? data.kind.value : this.kind,
      amount: data.amount.present ? data.amount.value : this.amount,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Earning(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('kind: $kind, ')
          ..write('amount: $amount, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, shiftId, occurredAt, kind, amount, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Earning &&
          other.id == this.id &&
          other.shiftId == this.shiftId &&
          other.occurredAt == this.occurredAt &&
          other.kind == this.kind &&
          other.amount == this.amount &&
          other.description == this.description);
}

class EarningsCompanion extends UpdateCompanion<Earning> {
  final Value<String> id;
  final Value<String?> shiftId;
  final Value<DateTime> occurredAt;
  final Value<String> kind;
  final Value<double?> amount;
  final Value<String?> description;
  final Value<int> rowid;
  const EarningsCompanion({
    this.id = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EarningsCompanion.insert({
    required String id,
    this.shiftId = const Value.absent(),
    required DateTime occurredAt,
    required String kind,
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       occurredAt = Value(occurredAt),
       kind = Value(kind);
  static Insertable<Earning> custom({
    Expression<String>? id,
    Expression<String>? shiftId,
    Expression<DateTime>? occurredAt,
    Expression<String>? kind,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shiftId != null) 'shift_id': shiftId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (kind != null) 'kind': kind,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EarningsCompanion copyWith({
    Value<String>? id,
    Value<String?>? shiftId,
    Value<DateTime>? occurredAt,
    Value<String>? kind,
    Value<double?>? amount,
    Value<String?>? description,
    Value<int>? rowid,
  }) {
    return EarningsCompanion(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      occurredAt: occurredAt ?? this.occurredAt,
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EarningsCompanion(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('kind: $kind, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RideEarningsTable extends RideEarnings
    with TableInfo<$RideEarningsTable, RideEarning> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RideEarningsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _earningIdMeta = const VerificationMeta(
    'earningId',
  );
  @override
  late final GeneratedColumn<String> earningId = GeneratedColumn<String>(
    'earning_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES earnings (id)',
    ),
  );
  static const VerificationMeta _appMeta = const VerificationMeta('app');
  @override
  late final GeneratedColumn<String> app = GeneratedColumn<String>(
    'app',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceTypeMeta = const VerificationMeta(
    'serviceType',
  );
  @override
  late final GeneratedColumn<String> serviceType = GeneratedColumn<String>(
    'service_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fareMeta = const VerificationMeta('fare');
  @override
  late final GeneratedColumn<double> fare = GeneratedColumn<double>(
    'fare',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surgeMeta = const VerificationMeta('surge');
  @override
  late final GeneratedColumn<double> surge = GeneratedColumn<double>(
    'surge',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tipMeta = const VerificationMeta('tip');
  @override
  late final GeneratedColumn<double> tip = GeneratedColumn<double>(
    'tip',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta(
    'distanceKm',
  );
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
    'distance_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pickupCepMeta = const VerificationMeta(
    'pickupCep',
  );
  @override
  late final GeneratedColumn<String> pickupCep = GeneratedColumn<String>(
    'pickup_cep',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _destinationCepMeta = const VerificationMeta(
    'destinationCep',
  );
  @override
  late final GeneratedColumn<String> destinationCep = GeneratedColumn<String>(
    'destination_cep',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pickupDistrictIdMeta = const VerificationMeta(
    'pickupDistrictId',
  );
  @override
  late final GeneratedColumn<String> pickupDistrictId = GeneratedColumn<String>(
    'pickup_district_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _destinationDistrictIdMeta =
      const VerificationMeta('destinationDistrictId');
  @override
  late final GeneratedColumn<String> destinationDistrictId =
      GeneratedColumn<String>(
        'destination_district_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    earningId,
    app,
    serviceType,
    fare,
    surge,
    tip,
    durationSeconds,
    distanceKm,
    status,
    pickupCep,
    destinationCep,
    pickupDistrictId,
    destinationDistrictId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ride_earnings';
  @override
  VerificationContext validateIntegrity(
    Insertable<RideEarning> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('earning_id')) {
      context.handle(
        _earningIdMeta,
        earningId.isAcceptableOrUnknown(data['earning_id']!, _earningIdMeta),
      );
    } else if (isInserting) {
      context.missing(_earningIdMeta);
    }
    if (data.containsKey('app')) {
      context.handle(
        _appMeta,
        app.isAcceptableOrUnknown(data['app']!, _appMeta),
      );
    } else if (isInserting) {
      context.missing(_appMeta);
    }
    if (data.containsKey('service_type')) {
      context.handle(
        _serviceTypeMeta,
        serviceType.isAcceptableOrUnknown(
          data['service_type']!,
          _serviceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceTypeMeta);
    }
    if (data.containsKey('fare')) {
      context.handle(
        _fareMeta,
        fare.isAcceptableOrUnknown(data['fare']!, _fareMeta),
      );
    } else if (isInserting) {
      context.missing(_fareMeta);
    }
    if (data.containsKey('surge')) {
      context.handle(
        _surgeMeta,
        surge.isAcceptableOrUnknown(data['surge']!, _surgeMeta),
      );
    }
    if (data.containsKey('tip')) {
      context.handle(
        _tipMeta,
        tip.isAcceptableOrUnknown(data['tip']!, _tipMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('distance_km')) {
      context.handle(
        _distanceKmMeta,
        distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceKmMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('pickup_cep')) {
      context.handle(
        _pickupCepMeta,
        pickupCep.isAcceptableOrUnknown(data['pickup_cep']!, _pickupCepMeta),
      );
    }
    if (data.containsKey('destination_cep')) {
      context.handle(
        _destinationCepMeta,
        destinationCep.isAcceptableOrUnknown(
          data['destination_cep']!,
          _destinationCepMeta,
        ),
      );
    }
    if (data.containsKey('pickup_district_id')) {
      context.handle(
        _pickupDistrictIdMeta,
        pickupDistrictId.isAcceptableOrUnknown(
          data['pickup_district_id']!,
          _pickupDistrictIdMeta,
        ),
      );
    }
    if (data.containsKey('destination_district_id')) {
      context.handle(
        _destinationDistrictIdMeta,
        destinationDistrictId.isAcceptableOrUnknown(
          data['destination_district_id']!,
          _destinationDistrictIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {earningId};
  @override
  RideEarning map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RideEarning(
      earningId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}earning_id'],
      )!,
      app: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app'],
      )!,
      serviceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_type'],
      )!,
      fare: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fare'],
      )!,
      surge: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}surge'],
      )!,
      tip: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tip'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      distanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_km'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      pickupCep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pickup_cep'],
      ),
      destinationCep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_cep'],
      ),
      pickupDistrictId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pickup_district_id'],
      ),
      destinationDistrictId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_district_id'],
      ),
    );
  }

  @override
  $RideEarningsTable createAlias(String alias) {
    return $RideEarningsTable(attachedDatabase, alias);
  }
}

class RideEarning extends DataClass implements Insertable<RideEarning> {
  final String earningId;
  final String app;
  final String serviceType;
  final double fare;
  final double surge;
  final double tip;
  final int durationSeconds;
  final double distanceKm;
  final String status;
  final String? pickupCep;
  final String? destinationCep;
  final String? pickupDistrictId;
  final String? destinationDistrictId;
  const RideEarning({
    required this.earningId,
    required this.app,
    required this.serviceType,
    required this.fare,
    required this.surge,
    required this.tip,
    required this.durationSeconds,
    required this.distanceKm,
    required this.status,
    this.pickupCep,
    this.destinationCep,
    this.pickupDistrictId,
    this.destinationDistrictId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['earning_id'] = Variable<String>(earningId);
    map['app'] = Variable<String>(app);
    map['service_type'] = Variable<String>(serviceType);
    map['fare'] = Variable<double>(fare);
    map['surge'] = Variable<double>(surge);
    map['tip'] = Variable<double>(tip);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['distance_km'] = Variable<double>(distanceKm);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || pickupCep != null) {
      map['pickup_cep'] = Variable<String>(pickupCep);
    }
    if (!nullToAbsent || destinationCep != null) {
      map['destination_cep'] = Variable<String>(destinationCep);
    }
    if (!nullToAbsent || pickupDistrictId != null) {
      map['pickup_district_id'] = Variable<String>(pickupDistrictId);
    }
    if (!nullToAbsent || destinationDistrictId != null) {
      map['destination_district_id'] = Variable<String>(destinationDistrictId);
    }
    return map;
  }

  RideEarningsCompanion toCompanion(bool nullToAbsent) {
    return RideEarningsCompanion(
      earningId: Value(earningId),
      app: Value(app),
      serviceType: Value(serviceType),
      fare: Value(fare),
      surge: Value(surge),
      tip: Value(tip),
      durationSeconds: Value(durationSeconds),
      distanceKm: Value(distanceKm),
      status: Value(status),
      pickupCep: pickupCep == null && nullToAbsent
          ? const Value.absent()
          : Value(pickupCep),
      destinationCep: destinationCep == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationCep),
      pickupDistrictId: pickupDistrictId == null && nullToAbsent
          ? const Value.absent()
          : Value(pickupDistrictId),
      destinationDistrictId: destinationDistrictId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationDistrictId),
    );
  }

  factory RideEarning.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RideEarning(
      earningId: serializer.fromJson<String>(json['earningId']),
      app: serializer.fromJson<String>(json['app']),
      serviceType: serializer.fromJson<String>(json['serviceType']),
      fare: serializer.fromJson<double>(json['fare']),
      surge: serializer.fromJson<double>(json['surge']),
      tip: serializer.fromJson<double>(json['tip']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      distanceKm: serializer.fromJson<double>(json['distanceKm']),
      status: serializer.fromJson<String>(json['status']),
      pickupCep: serializer.fromJson<String?>(json['pickupCep']),
      destinationCep: serializer.fromJson<String?>(json['destinationCep']),
      pickupDistrictId: serializer.fromJson<String?>(json['pickupDistrictId']),
      destinationDistrictId: serializer.fromJson<String?>(
        json['destinationDistrictId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'earningId': serializer.toJson<String>(earningId),
      'app': serializer.toJson<String>(app),
      'serviceType': serializer.toJson<String>(serviceType),
      'fare': serializer.toJson<double>(fare),
      'surge': serializer.toJson<double>(surge),
      'tip': serializer.toJson<double>(tip),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'distanceKm': serializer.toJson<double>(distanceKm),
      'status': serializer.toJson<String>(status),
      'pickupCep': serializer.toJson<String?>(pickupCep),
      'destinationCep': serializer.toJson<String?>(destinationCep),
      'pickupDistrictId': serializer.toJson<String?>(pickupDistrictId),
      'destinationDistrictId': serializer.toJson<String?>(
        destinationDistrictId,
      ),
    };
  }

  RideEarning copyWith({
    String? earningId,
    String? app,
    String? serviceType,
    double? fare,
    double? surge,
    double? tip,
    int? durationSeconds,
    double? distanceKm,
    String? status,
    Value<String?> pickupCep = const Value.absent(),
    Value<String?> destinationCep = const Value.absent(),
    Value<String?> pickupDistrictId = const Value.absent(),
    Value<String?> destinationDistrictId = const Value.absent(),
  }) => RideEarning(
    earningId: earningId ?? this.earningId,
    app: app ?? this.app,
    serviceType: serviceType ?? this.serviceType,
    fare: fare ?? this.fare,
    surge: surge ?? this.surge,
    tip: tip ?? this.tip,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    distanceKm: distanceKm ?? this.distanceKm,
    status: status ?? this.status,
    pickupCep: pickupCep.present ? pickupCep.value : this.pickupCep,
    destinationCep: destinationCep.present
        ? destinationCep.value
        : this.destinationCep,
    pickupDistrictId: pickupDistrictId.present
        ? pickupDistrictId.value
        : this.pickupDistrictId,
    destinationDistrictId: destinationDistrictId.present
        ? destinationDistrictId.value
        : this.destinationDistrictId,
  );
  RideEarning copyWithCompanion(RideEarningsCompanion data) {
    return RideEarning(
      earningId: data.earningId.present ? data.earningId.value : this.earningId,
      app: data.app.present ? data.app.value : this.app,
      serviceType: data.serviceType.present
          ? data.serviceType.value
          : this.serviceType,
      fare: data.fare.present ? data.fare.value : this.fare,
      surge: data.surge.present ? data.surge.value : this.surge,
      tip: data.tip.present ? data.tip.value : this.tip,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      distanceKm: data.distanceKm.present
          ? data.distanceKm.value
          : this.distanceKm,
      status: data.status.present ? data.status.value : this.status,
      pickupCep: data.pickupCep.present ? data.pickupCep.value : this.pickupCep,
      destinationCep: data.destinationCep.present
          ? data.destinationCep.value
          : this.destinationCep,
      pickupDistrictId: data.pickupDistrictId.present
          ? data.pickupDistrictId.value
          : this.pickupDistrictId,
      destinationDistrictId: data.destinationDistrictId.present
          ? data.destinationDistrictId.value
          : this.destinationDistrictId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RideEarning(')
          ..write('earningId: $earningId, ')
          ..write('app: $app, ')
          ..write('serviceType: $serviceType, ')
          ..write('fare: $fare, ')
          ..write('surge: $surge, ')
          ..write('tip: $tip, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('status: $status, ')
          ..write('pickupCep: $pickupCep, ')
          ..write('destinationCep: $destinationCep, ')
          ..write('pickupDistrictId: $pickupDistrictId, ')
          ..write('destinationDistrictId: $destinationDistrictId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    earningId,
    app,
    serviceType,
    fare,
    surge,
    tip,
    durationSeconds,
    distanceKm,
    status,
    pickupCep,
    destinationCep,
    pickupDistrictId,
    destinationDistrictId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RideEarning &&
          other.earningId == this.earningId &&
          other.app == this.app &&
          other.serviceType == this.serviceType &&
          other.fare == this.fare &&
          other.surge == this.surge &&
          other.tip == this.tip &&
          other.durationSeconds == this.durationSeconds &&
          other.distanceKm == this.distanceKm &&
          other.status == this.status &&
          other.pickupCep == this.pickupCep &&
          other.destinationCep == this.destinationCep &&
          other.pickupDistrictId == this.pickupDistrictId &&
          other.destinationDistrictId == this.destinationDistrictId);
}

class RideEarningsCompanion extends UpdateCompanion<RideEarning> {
  final Value<String> earningId;
  final Value<String> app;
  final Value<String> serviceType;
  final Value<double> fare;
  final Value<double> surge;
  final Value<double> tip;
  final Value<int> durationSeconds;
  final Value<double> distanceKm;
  final Value<String> status;
  final Value<String?> pickupCep;
  final Value<String?> destinationCep;
  final Value<String?> pickupDistrictId;
  final Value<String?> destinationDistrictId;
  final Value<int> rowid;
  const RideEarningsCompanion({
    this.earningId = const Value.absent(),
    this.app = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.fare = const Value.absent(),
    this.surge = const Value.absent(),
    this.tip = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.status = const Value.absent(),
    this.pickupCep = const Value.absent(),
    this.destinationCep = const Value.absent(),
    this.pickupDistrictId = const Value.absent(),
    this.destinationDistrictId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RideEarningsCompanion.insert({
    required String earningId,
    required String app,
    required String serviceType,
    required double fare,
    this.surge = const Value.absent(),
    this.tip = const Value.absent(),
    required int durationSeconds,
    required double distanceKm,
    required String status,
    this.pickupCep = const Value.absent(),
    this.destinationCep = const Value.absent(),
    this.pickupDistrictId = const Value.absent(),
    this.destinationDistrictId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : earningId = Value(earningId),
       app = Value(app),
       serviceType = Value(serviceType),
       fare = Value(fare),
       durationSeconds = Value(durationSeconds),
       distanceKm = Value(distanceKm),
       status = Value(status);
  static Insertable<RideEarning> custom({
    Expression<String>? earningId,
    Expression<String>? app,
    Expression<String>? serviceType,
    Expression<double>? fare,
    Expression<double>? surge,
    Expression<double>? tip,
    Expression<int>? durationSeconds,
    Expression<double>? distanceKm,
    Expression<String>? status,
    Expression<String>? pickupCep,
    Expression<String>? destinationCep,
    Expression<String>? pickupDistrictId,
    Expression<String>? destinationDistrictId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (earningId != null) 'earning_id': earningId,
      if (app != null) 'app': app,
      if (serviceType != null) 'service_type': serviceType,
      if (fare != null) 'fare': fare,
      if (surge != null) 'surge': surge,
      if (tip != null) 'tip': tip,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (status != null) 'status': status,
      if (pickupCep != null) 'pickup_cep': pickupCep,
      if (destinationCep != null) 'destination_cep': destinationCep,
      if (pickupDistrictId != null) 'pickup_district_id': pickupDistrictId,
      if (destinationDistrictId != null)
        'destination_district_id': destinationDistrictId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RideEarningsCompanion copyWith({
    Value<String>? earningId,
    Value<String>? app,
    Value<String>? serviceType,
    Value<double>? fare,
    Value<double>? surge,
    Value<double>? tip,
    Value<int>? durationSeconds,
    Value<double>? distanceKm,
    Value<String>? status,
    Value<String?>? pickupCep,
    Value<String?>? destinationCep,
    Value<String?>? pickupDistrictId,
    Value<String?>? destinationDistrictId,
    Value<int>? rowid,
  }) {
    return RideEarningsCompanion(
      earningId: earningId ?? this.earningId,
      app: app ?? this.app,
      serviceType: serviceType ?? this.serviceType,
      fare: fare ?? this.fare,
      surge: surge ?? this.surge,
      tip: tip ?? this.tip,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceKm: distanceKm ?? this.distanceKm,
      status: status ?? this.status,
      pickupCep: pickupCep ?? this.pickupCep,
      destinationCep: destinationCep ?? this.destinationCep,
      pickupDistrictId: pickupDistrictId ?? this.pickupDistrictId,
      destinationDistrictId:
          destinationDistrictId ?? this.destinationDistrictId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (earningId.present) {
      map['earning_id'] = Variable<String>(earningId.value);
    }
    if (app.present) {
      map['app'] = Variable<String>(app.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<String>(serviceType.value);
    }
    if (fare.present) {
      map['fare'] = Variable<double>(fare.value);
    }
    if (surge.present) {
      map['surge'] = Variable<double>(surge.value);
    }
    if (tip.present) {
      map['tip'] = Variable<double>(tip.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (pickupCep.present) {
      map['pickup_cep'] = Variable<String>(pickupCep.value);
    }
    if (destinationCep.present) {
      map['destination_cep'] = Variable<String>(destinationCep.value);
    }
    if (pickupDistrictId.present) {
      map['pickup_district_id'] = Variable<String>(pickupDistrictId.value);
    }
    if (destinationDistrictId.present) {
      map['destination_district_id'] = Variable<String>(
        destinationDistrictId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RideEarningsCompanion(')
          ..write('earningId: $earningId, ')
          ..write('app: $app, ')
          ..write('serviceType: $serviceType, ')
          ..write('fare: $fare, ')
          ..write('surge: $surge, ')
          ..write('tip: $tip, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('status: $status, ')
          ..write('pickupCep: $pickupCep, ')
          ..write('destinationCep: $destinationCep, ')
          ..write('pickupDistrictId: $pickupDistrictId, ')
          ..write('destinationDistrictId: $destinationDistrictId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $ShiftPausesTable shiftPauses = $ShiftPausesTable(this);
  late final $CostsTable costs = $CostsTable(this);
  late final $FuelCostsTable fuelCosts = $FuelCostsTable(this);
  late final $MaintenanceCostsTable maintenanceCosts = $MaintenanceCostsTable(
    this,
  );
  late final $EarningsTable earnings = $EarningsTable(this);
  late final $RideEarningsTable rideEarnings = $RideEarningsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shifts,
    shiftPauses,
    costs,
    fuelCosts,
    maintenanceCosts,
    earnings,
    rideEarnings,
  ];
}

typedef $$ShiftsTableCreateCompanionBuilder =
    ShiftsCompanion Function({
      required String id,
      required String status,
      required double initialKm,
      Value<double?> finalKm,
      Value<double?> earnings,
      required DateTime startTime,
      Value<DateTime?> endTime,
      Value<int> rowid,
    });
typedef $$ShiftsTableUpdateCompanionBuilder =
    ShiftsCompanion Function({
      Value<String> id,
      Value<String> status,
      Value<double> initialKm,
      Value<double?> finalKm,
      Value<double?> earnings,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<int> rowid,
    });

final class $$ShiftsTableReferences
    extends BaseReferences<_$AppDatabase, $ShiftsTable, Shift> {
  $$ShiftsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ShiftPausesTable, List<ShiftPause>>
  _shiftPausesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shiftPauses,
    aliasName: 'shifts__id__shift_pauses__shift_id',
  );

  $$ShiftPausesTableProcessedTableManager get shiftPausesRefs {
    final manager = $$ShiftPausesTableTableManager(
      $_db,
      $_db.shiftPauses,
    ).filter((f) => f.shiftId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_shiftPausesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialKm => $composableBuilder(
    column: $table.initialKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get finalKm => $composableBuilder(
    column: $table.finalKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get earnings => $composableBuilder(
    column: $table.earnings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> shiftPausesRefs(
    Expression<bool> Function($$ShiftPausesTableFilterComposer f) f,
  ) {
    final $$ShiftPausesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shiftPauses,
      getReferencedColumn: (t) => t.shiftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftPausesTableFilterComposer(
            $db: $db,
            $table: $db.shiftPauses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialKm => $composableBuilder(
    column: $table.initialKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get finalKm => $composableBuilder(
    column: $table.finalKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get earnings => $composableBuilder(
    column: $table.earnings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get initialKm =>
      $composableBuilder(column: $table.initialKm, builder: (column) => column);

  GeneratedColumn<double> get finalKm =>
      $composableBuilder(column: $table.finalKm, builder: (column) => column);

  GeneratedColumn<double> get earnings =>
      $composableBuilder(column: $table.earnings, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  Expression<T> shiftPausesRefs<T extends Object>(
    Expression<T> Function($$ShiftPausesTableAnnotationComposer a) f,
  ) {
    final $$ShiftPausesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shiftPauses,
      getReferencedColumn: (t) => t.shiftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftPausesTableAnnotationComposer(
            $db: $db,
            $table: $db.shiftPauses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShiftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTable,
          Shift,
          $$ShiftsTableFilterComposer,
          $$ShiftsTableOrderingComposer,
          $$ShiftsTableAnnotationComposer,
          $$ShiftsTableCreateCompanionBuilder,
          $$ShiftsTableUpdateCompanionBuilder,
          (Shift, $$ShiftsTableReferences),
          Shift,
          PrefetchHooks Function({bool shiftPausesRefs})
        > {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> initialKm = const Value.absent(),
                Value<double?> finalKm = const Value.absent(),
                Value<double?> earnings = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion(
                id: id,
                status: status,
                initialKm: initialKm,
                finalKm: finalKm,
                earnings: earnings,
                startTime: startTime,
                endTime: endTime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String status,
                required double initialKm,
                Value<double?> finalKm = const Value.absent(),
                Value<double?> earnings = const Value.absent(),
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion.insert(
                id: id,
                status: status,
                initialKm: initialKm,
                finalKm: finalKm,
                earnings: earnings,
                startTime: startTime,
                endTime: endTime,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ShiftsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({shiftPausesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (shiftPausesRefs) db.shiftPauses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shiftPausesRefs)
                    await $_getPrefetchedData<Shift, $ShiftsTable, ShiftPause>(
                      currentTable: table,
                      referencedTable: $$ShiftsTableReferences
                          ._shiftPausesRefsTable(db),
                      managerFromTypedResult: (p0) => $$ShiftsTableReferences(
                        db,
                        table,
                        p0,
                      ).shiftPausesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.shiftId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ShiftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTable,
      Shift,
      $$ShiftsTableFilterComposer,
      $$ShiftsTableOrderingComposer,
      $$ShiftsTableAnnotationComposer,
      $$ShiftsTableCreateCompanionBuilder,
      $$ShiftsTableUpdateCompanionBuilder,
      (Shift, $$ShiftsTableReferences),
      Shift,
      PrefetchHooks Function({bool shiftPausesRefs})
    >;
typedef $$ShiftPausesTableCreateCompanionBuilder =
    ShiftPausesCompanion Function({
      required String id,
      required String shiftId,
      required DateTime startTime,
      Value<DateTime?> endTime,
      Value<int> rowid,
    });
typedef $$ShiftPausesTableUpdateCompanionBuilder =
    ShiftPausesCompanion Function({
      Value<String> id,
      Value<String> shiftId,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<int> rowid,
    });

final class $$ShiftPausesTableReferences
    extends BaseReferences<_$AppDatabase, $ShiftPausesTable, ShiftPause> {
  $$ShiftPausesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShiftsTable _shiftIdTable(_$AppDatabase db) =>
      db.shifts.createAlias('shift_pauses__shift_id__shifts__id');

  $$ShiftsTableProcessedTableManager get shiftId {
    final $_column = $_itemColumn<String>('shift_id')!;

    final manager = $$ShiftsTableTableManager(
      $_db,
      $_db.shifts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shiftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShiftPausesTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftPausesTable> {
  $$ShiftPausesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  $$ShiftsTableFilterComposer get shiftId {
    final $$ShiftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableFilterComposer(
            $db: $db,
            $table: $db.shifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShiftPausesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftPausesTable> {
  $$ShiftPausesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShiftsTableOrderingComposer get shiftId {
    final $$ShiftsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableOrderingComposer(
            $db: $db,
            $table: $db.shifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShiftPausesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftPausesTable> {
  $$ShiftPausesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  $$ShiftsTableAnnotationComposer get shiftId {
    final $$ShiftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shiftId,
      referencedTable: $db.shifts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableAnnotationComposer(
            $db: $db,
            $table: $db.shifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShiftPausesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftPausesTable,
          ShiftPause,
          $$ShiftPausesTableFilterComposer,
          $$ShiftPausesTableOrderingComposer,
          $$ShiftPausesTableAnnotationComposer,
          $$ShiftPausesTableCreateCompanionBuilder,
          $$ShiftPausesTableUpdateCompanionBuilder,
          (ShiftPause, $$ShiftPausesTableReferences),
          ShiftPause,
          PrefetchHooks Function({bool shiftId})
        > {
  $$ShiftPausesTableTableManager(_$AppDatabase db, $ShiftPausesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftPausesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftPausesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftPausesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shiftId = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftPausesCompanion(
                id: id,
                shiftId: shiftId,
                startTime: startTime,
                endTime: endTime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shiftId,
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftPausesCompanion.insert(
                id: id,
                shiftId: shiftId,
                startTime: startTime,
                endTime: endTime,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShiftPausesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shiftId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (shiftId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shiftId,
                                referencedTable: $$ShiftPausesTableReferences
                                    ._shiftIdTable(db),
                                referencedColumn: $$ShiftPausesTableReferences
                                    ._shiftIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShiftPausesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftPausesTable,
      ShiftPause,
      $$ShiftPausesTableFilterComposer,
      $$ShiftPausesTableOrderingComposer,
      $$ShiftPausesTableAnnotationComposer,
      $$ShiftPausesTableCreateCompanionBuilder,
      $$ShiftPausesTableUpdateCompanionBuilder,
      (ShiftPause, $$ShiftPausesTableReferences),
      ShiftPause,
      PrefetchHooks Function({bool shiftId})
    >;
typedef $$CostsTableCreateCompanionBuilder =
    CostsCompanion Function({
      required String id,
      required String category,
      required String subcategory,
      required double amount,
      required DateTime date,
      Value<String?> description,
      Value<int> rowid,
    });
typedef $$CostsTableUpdateCompanionBuilder =
    CostsCompanion Function({
      Value<String> id,
      Value<String> category,
      Value<String> subcategory,
      Value<double> amount,
      Value<DateTime> date,
      Value<String?> description,
      Value<int> rowid,
    });

final class $$CostsTableReferences
    extends BaseReferences<_$AppDatabase, $CostsTable, Cost> {
  $$CostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FuelCostsTable, List<FuelCost>>
  _fuelCostsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fuelCosts,
    aliasName: 'costs__id__fuel_costs__cost_id',
  );

  $$FuelCostsTableProcessedTableManager get fuelCostsRefs {
    final manager = $$FuelCostsTableTableManager(
      $_db,
      $_db.fuelCosts,
    ).filter((f) => f.costId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_fuelCostsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MaintenanceCostsTable, List<MaintenanceCost>>
  _maintenanceCostsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.maintenanceCosts,
    aliasName: 'costs__id__maintenance_costs__cost_id',
  );

  $$MaintenanceCostsTableProcessedTableManager get maintenanceCostsRefs {
    final manager = $$MaintenanceCostsTableTableManager(
      $_db,
      $_db.maintenanceCosts,
    ).filter((f) => f.costId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceCostsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CostsTableFilterComposer extends Composer<_$AppDatabase, $CostsTable> {
  $$CostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> fuelCostsRefs(
    Expression<bool> Function($$FuelCostsTableFilterComposer f) f,
  ) {
    final $$FuelCostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelCosts,
      getReferencedColumn: (t) => t.costId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelCostsTableFilterComposer(
            $db: $db,
            $table: $db.fuelCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> maintenanceCostsRefs(
    Expression<bool> Function($$MaintenanceCostsTableFilterComposer f) f,
  ) {
    final $$MaintenanceCostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceCosts,
      getReferencedColumn: (t) => t.costId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceCostsTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CostsTableOrderingComposer
    extends Composer<_$AppDatabase, $CostsTable> {
  $$CostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CostsTable> {
  $$CostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  Expression<T> fuelCostsRefs<T extends Object>(
    Expression<T> Function($$FuelCostsTableAnnotationComposer a) f,
  ) {
    final $$FuelCostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelCosts,
      getReferencedColumn: (t) => t.costId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelCostsTableAnnotationComposer(
            $db: $db,
            $table: $db.fuelCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> maintenanceCostsRefs<T extends Object>(
    Expression<T> Function($$MaintenanceCostsTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceCostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceCosts,
      getReferencedColumn: (t) => t.costId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceCostsTableAnnotationComposer(
            $db: $db,
            $table: $db.maintenanceCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CostsTable,
          Cost,
          $$CostsTableFilterComposer,
          $$CostsTableOrderingComposer,
          $$CostsTableAnnotationComposer,
          $$CostsTableCreateCompanionBuilder,
          $$CostsTableUpdateCompanionBuilder,
          (Cost, $$CostsTableReferences),
          Cost,
          PrefetchHooks Function({
            bool fuelCostsRefs,
            bool maintenanceCostsRefs,
          })
        > {
  $$CostsTableTableManager(_$AppDatabase db, $CostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> subcategory = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CostsCompanion(
                id: id,
                category: category,
                subcategory: subcategory,
                amount: amount,
                date: date,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String category,
                required String subcategory,
                required double amount,
                required DateTime date,
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CostsCompanion.insert(
                id: id,
                category: category,
                subcategory: subcategory,
                amount: amount,
                date: date,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$CostsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({fuelCostsRefs = false, maintenanceCostsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (fuelCostsRefs) db.fuelCosts,
                    if (maintenanceCostsRefs) db.maintenanceCosts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (fuelCostsRefs)
                        await $_getPrefetchedData<Cost, $CostsTable, FuelCost>(
                          currentTable: table,
                          referencedTable: $$CostsTableReferences
                              ._fuelCostsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CostsTableReferences(
                                db,
                                table,
                                p0,
                              ).fuelCostsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.costId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (maintenanceCostsRefs)
                        await $_getPrefetchedData<
                          Cost,
                          $CostsTable,
                          MaintenanceCost
                        >(
                          currentTable: table,
                          referencedTable: $$CostsTableReferences
                              ._maintenanceCostsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CostsTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceCostsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.costId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CostsTable,
      Cost,
      $$CostsTableFilterComposer,
      $$CostsTableOrderingComposer,
      $$CostsTableAnnotationComposer,
      $$CostsTableCreateCompanionBuilder,
      $$CostsTableUpdateCompanionBuilder,
      (Cost, $$CostsTableReferences),
      Cost,
      PrefetchHooks Function({bool fuelCostsRefs, bool maintenanceCostsRefs})
    >;
typedef $$FuelCostsTableCreateCompanionBuilder =
    FuelCostsCompanion Function({
      required String costId,
      required double odometerKm,
      required double quantity,
      Value<bool> isFullTank,
      Value<bool> previousFillUpMissing,
      Value<int> rowid,
    });
typedef $$FuelCostsTableUpdateCompanionBuilder =
    FuelCostsCompanion Function({
      Value<String> costId,
      Value<double> odometerKm,
      Value<double> quantity,
      Value<bool> isFullTank,
      Value<bool> previousFillUpMissing,
      Value<int> rowid,
    });

final class $$FuelCostsTableReferences
    extends BaseReferences<_$AppDatabase, $FuelCostsTable, FuelCost> {
  $$FuelCostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CostsTable _costIdTable(_$AppDatabase db) =>
      db.costs.createAlias('fuel_costs__cost_id__costs__id');

  $$CostsTableProcessedTableManager get costId {
    final $_column = $_itemColumn<String>('cost_id')!;

    final manager = $$CostsTableTableManager(
      $_db,
      $_db.costs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_costIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FuelCostsTableFilterComposer
    extends Composer<_$AppDatabase, $FuelCostsTable> {
  $$FuelCostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get previousFillUpMissing => $composableBuilder(
    column: $table.previousFillUpMissing,
    builder: (column) => ColumnFilters(column),
  );

  $$CostsTableFilterComposer get costId {
    final $$CostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.costId,
      referencedTable: $db.costs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostsTableFilterComposer(
            $db: $db,
            $table: $db.costs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelCostsTableOrderingComposer
    extends Composer<_$AppDatabase, $FuelCostsTable> {
  $$FuelCostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get previousFillUpMissing => $composableBuilder(
    column: $table.previousFillUpMissing,
    builder: (column) => ColumnOrderings(column),
  );

  $$CostsTableOrderingComposer get costId {
    final $$CostsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.costId,
      referencedTable: $db.costs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostsTableOrderingComposer(
            $db: $db,
            $table: $db.costs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelCostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FuelCostsTable> {
  $$FuelCostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get previousFillUpMissing => $composableBuilder(
    column: $table.previousFillUpMissing,
    builder: (column) => column,
  );

  $$CostsTableAnnotationComposer get costId {
    final $$CostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.costId,
      referencedTable: $db.costs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostsTableAnnotationComposer(
            $db: $db,
            $table: $db.costs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelCostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FuelCostsTable,
          FuelCost,
          $$FuelCostsTableFilterComposer,
          $$FuelCostsTableOrderingComposer,
          $$FuelCostsTableAnnotationComposer,
          $$FuelCostsTableCreateCompanionBuilder,
          $$FuelCostsTableUpdateCompanionBuilder,
          (FuelCost, $$FuelCostsTableReferences),
          FuelCost,
          PrefetchHooks Function({bool costId})
        > {
  $$FuelCostsTableTableManager(_$AppDatabase db, $FuelCostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FuelCostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FuelCostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FuelCostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> costId = const Value.absent(),
                Value<double> odometerKm = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<bool> isFullTank = const Value.absent(),
                Value<bool> previousFillUpMissing = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FuelCostsCompanion(
                costId: costId,
                odometerKm: odometerKm,
                quantity: quantity,
                isFullTank: isFullTank,
                previousFillUpMissing: previousFillUpMissing,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String costId,
                required double odometerKm,
                required double quantity,
                Value<bool> isFullTank = const Value.absent(),
                Value<bool> previousFillUpMissing = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FuelCostsCompanion.insert(
                costId: costId,
                odometerKm: odometerKm,
                quantity: quantity,
                isFullTank: isFullTank,
                previousFillUpMissing: previousFillUpMissing,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FuelCostsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({costId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (costId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.costId,
                                referencedTable: $$FuelCostsTableReferences
                                    ._costIdTable(db),
                                referencedColumn: $$FuelCostsTableReferences
                                    ._costIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FuelCostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FuelCostsTable,
      FuelCost,
      $$FuelCostsTableFilterComposer,
      $$FuelCostsTableOrderingComposer,
      $$FuelCostsTableAnnotationComposer,
      $$FuelCostsTableCreateCompanionBuilder,
      $$FuelCostsTableUpdateCompanionBuilder,
      (FuelCost, $$FuelCostsTableReferences),
      FuelCost,
      PrefetchHooks Function({bool costId})
    >;
typedef $$MaintenanceCostsTableCreateCompanionBuilder =
    MaintenanceCostsCompanion Function({
      required String costId,
      Value<double?> odometerKm,
      Value<int> rowid,
    });
typedef $$MaintenanceCostsTableUpdateCompanionBuilder =
    MaintenanceCostsCompanion Function({
      Value<String> costId,
      Value<double?> odometerKm,
      Value<int> rowid,
    });

final class $$MaintenanceCostsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MaintenanceCostsTable, MaintenanceCost> {
  $$MaintenanceCostsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CostsTable _costIdTable(_$AppDatabase db) =>
      db.costs.createAlias('maintenance_costs__cost_id__costs__id');

  $$CostsTableProcessedTableManager get costId {
    final $_column = $_itemColumn<String>('cost_id')!;

    final manager = $$CostsTableTableManager(
      $_db,
      $_db.costs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_costIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MaintenanceCostsTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceCostsTable> {
  $$MaintenanceCostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnFilters(column),
  );

  $$CostsTableFilterComposer get costId {
    final $$CostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.costId,
      referencedTable: $db.costs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostsTableFilterComposer(
            $db: $db,
            $table: $db.costs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceCostsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceCostsTable> {
  $$MaintenanceCostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => ColumnOrderings(column),
  );

  $$CostsTableOrderingComposer get costId {
    final $$CostsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.costId,
      referencedTable: $db.costs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostsTableOrderingComposer(
            $db: $db,
            $table: $db.costs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceCostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceCostsTable> {
  $$MaintenanceCostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get odometerKm => $composableBuilder(
    column: $table.odometerKm,
    builder: (column) => column,
  );

  $$CostsTableAnnotationComposer get costId {
    final $$CostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.costId,
      referencedTable: $db.costs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostsTableAnnotationComposer(
            $db: $db,
            $table: $db.costs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceCostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceCostsTable,
          MaintenanceCost,
          $$MaintenanceCostsTableFilterComposer,
          $$MaintenanceCostsTableOrderingComposer,
          $$MaintenanceCostsTableAnnotationComposer,
          $$MaintenanceCostsTableCreateCompanionBuilder,
          $$MaintenanceCostsTableUpdateCompanionBuilder,
          (MaintenanceCost, $$MaintenanceCostsTableReferences),
          MaintenanceCost,
          PrefetchHooks Function({bool costId})
        > {
  $$MaintenanceCostsTableTableManager(
    _$AppDatabase db,
    $MaintenanceCostsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceCostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceCostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaintenanceCostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> costId = const Value.absent(),
                Value<double?> odometerKm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaintenanceCostsCompanion(
                costId: costId,
                odometerKm: odometerKm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String costId,
                Value<double?> odometerKm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaintenanceCostsCompanion.insert(
                costId: costId,
                odometerKm: odometerKm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaintenanceCostsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({costId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (costId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.costId,
                                referencedTable:
                                    $$MaintenanceCostsTableReferences
                                        ._costIdTable(db),
                                referencedColumn:
                                    $$MaintenanceCostsTableReferences
                                        ._costIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MaintenanceCostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceCostsTable,
      MaintenanceCost,
      $$MaintenanceCostsTableFilterComposer,
      $$MaintenanceCostsTableOrderingComposer,
      $$MaintenanceCostsTableAnnotationComposer,
      $$MaintenanceCostsTableCreateCompanionBuilder,
      $$MaintenanceCostsTableUpdateCompanionBuilder,
      (MaintenanceCost, $$MaintenanceCostsTableReferences),
      MaintenanceCost,
      PrefetchHooks Function({bool costId})
    >;
typedef $$EarningsTableCreateCompanionBuilder =
    EarningsCompanion Function({
      required String id,
      Value<String?> shiftId,
      required DateTime occurredAt,
      required String kind,
      Value<double?> amount,
      Value<String?> description,
      Value<int> rowid,
    });
typedef $$EarningsTableUpdateCompanionBuilder =
    EarningsCompanion Function({
      Value<String> id,
      Value<String?> shiftId,
      Value<DateTime> occurredAt,
      Value<String> kind,
      Value<double?> amount,
      Value<String?> description,
      Value<int> rowid,
    });

final class $$EarningsTableReferences
    extends BaseReferences<_$AppDatabase, $EarningsTable, Earning> {
  $$EarningsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RideEarningsTable, List<RideEarning>>
  _rideEarningsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rideEarnings,
    aliasName: 'earnings__id__ride_earnings__earning_id',
  );

  $$RideEarningsTableProcessedTableManager get rideEarningsRefs {
    final manager = $$RideEarningsTableTableManager(
      $_db,
      $_db.rideEarnings,
    ).filter((f) => f.earningId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_rideEarningsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EarningsTableFilterComposer
    extends Composer<_$AppDatabase, $EarningsTable> {
  $$EarningsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> rideEarningsRefs(
    Expression<bool> Function($$RideEarningsTableFilterComposer f) f,
  ) {
    final $$RideEarningsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rideEarnings,
      getReferencedColumn: (t) => t.earningId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RideEarningsTableFilterComposer(
            $db: $db,
            $table: $db.rideEarnings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EarningsTableOrderingComposer
    extends Composer<_$AppDatabase, $EarningsTable> {
  $$EarningsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EarningsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EarningsTable> {
  $$EarningsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  Expression<T> rideEarningsRefs<T extends Object>(
    Expression<T> Function($$RideEarningsTableAnnotationComposer a) f,
  ) {
    final $$RideEarningsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rideEarnings,
      getReferencedColumn: (t) => t.earningId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RideEarningsTableAnnotationComposer(
            $db: $db,
            $table: $db.rideEarnings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EarningsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EarningsTable,
          Earning,
          $$EarningsTableFilterComposer,
          $$EarningsTableOrderingComposer,
          $$EarningsTableAnnotationComposer,
          $$EarningsTableCreateCompanionBuilder,
          $$EarningsTableUpdateCompanionBuilder,
          (Earning, $$EarningsTableReferences),
          Earning,
          PrefetchHooks Function({bool rideEarningsRefs})
        > {
  $$EarningsTableTableManager(_$AppDatabase db, $EarningsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EarningsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EarningsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EarningsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> shiftId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EarningsCompanion(
                id: id,
                shiftId: shiftId,
                occurredAt: occurredAt,
                kind: kind,
                amount: amount,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> shiftId = const Value.absent(),
                required DateTime occurredAt,
                required String kind,
                Value<double?> amount = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EarningsCompanion.insert(
                id: id,
                shiftId: shiftId,
                occurredAt: occurredAt,
                kind: kind,
                amount: amount,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EarningsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rideEarningsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (rideEarningsRefs) db.rideEarnings],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (rideEarningsRefs)
                    await $_getPrefetchedData<
                      Earning,
                      $EarningsTable,
                      RideEarning
                    >(
                      currentTable: table,
                      referencedTable: $$EarningsTableReferences
                          ._rideEarningsRefsTable(db),
                      managerFromTypedResult: (p0) => $$EarningsTableReferences(
                        db,
                        table,
                        p0,
                      ).rideEarningsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.earningId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EarningsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EarningsTable,
      Earning,
      $$EarningsTableFilterComposer,
      $$EarningsTableOrderingComposer,
      $$EarningsTableAnnotationComposer,
      $$EarningsTableCreateCompanionBuilder,
      $$EarningsTableUpdateCompanionBuilder,
      (Earning, $$EarningsTableReferences),
      Earning,
      PrefetchHooks Function({bool rideEarningsRefs})
    >;
typedef $$RideEarningsTableCreateCompanionBuilder =
    RideEarningsCompanion Function({
      required String earningId,
      required String app,
      required String serviceType,
      required double fare,
      Value<double> surge,
      Value<double> tip,
      required int durationSeconds,
      required double distanceKm,
      required String status,
      Value<String?> pickupCep,
      Value<String?> destinationCep,
      Value<String?> pickupDistrictId,
      Value<String?> destinationDistrictId,
      Value<int> rowid,
    });
typedef $$RideEarningsTableUpdateCompanionBuilder =
    RideEarningsCompanion Function({
      Value<String> earningId,
      Value<String> app,
      Value<String> serviceType,
      Value<double> fare,
      Value<double> surge,
      Value<double> tip,
      Value<int> durationSeconds,
      Value<double> distanceKm,
      Value<String> status,
      Value<String?> pickupCep,
      Value<String?> destinationCep,
      Value<String?> pickupDistrictId,
      Value<String?> destinationDistrictId,
      Value<int> rowid,
    });

final class $$RideEarningsTableReferences
    extends BaseReferences<_$AppDatabase, $RideEarningsTable, RideEarning> {
  $$RideEarningsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EarningsTable _earningIdTable(_$AppDatabase db) =>
      db.earnings.createAlias('ride_earnings__earning_id__earnings__id');

  $$EarningsTableProcessedTableManager get earningId {
    final $_column = $_itemColumn<String>('earning_id')!;

    final manager = $$EarningsTableTableManager(
      $_db,
      $_db.earnings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_earningIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RideEarningsTableFilterComposer
    extends Composer<_$AppDatabase, $RideEarningsTable> {
  $$RideEarningsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get app => $composableBuilder(
    column: $table.app,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fare => $composableBuilder(
    column: $table.fare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get surge => $composableBuilder(
    column: $table.surge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tip => $composableBuilder(
    column: $table.tip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pickupCep => $composableBuilder(
    column: $table.pickupCep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationCep => $composableBuilder(
    column: $table.destinationCep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pickupDistrictId => $composableBuilder(
    column: $table.pickupDistrictId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationDistrictId => $composableBuilder(
    column: $table.destinationDistrictId,
    builder: (column) => ColumnFilters(column),
  );

  $$EarningsTableFilterComposer get earningId {
    final $$EarningsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.earningId,
      referencedTable: $db.earnings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EarningsTableFilterComposer(
            $db: $db,
            $table: $db.earnings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RideEarningsTableOrderingComposer
    extends Composer<_$AppDatabase, $RideEarningsTable> {
  $$RideEarningsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get app => $composableBuilder(
    column: $table.app,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fare => $composableBuilder(
    column: $table.fare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get surge => $composableBuilder(
    column: $table.surge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tip => $composableBuilder(
    column: $table.tip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pickupCep => $composableBuilder(
    column: $table.pickupCep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationCep => $composableBuilder(
    column: $table.destinationCep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pickupDistrictId => $composableBuilder(
    column: $table.pickupDistrictId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationDistrictId => $composableBuilder(
    column: $table.destinationDistrictId,
    builder: (column) => ColumnOrderings(column),
  );

  $$EarningsTableOrderingComposer get earningId {
    final $$EarningsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.earningId,
      referencedTable: $db.earnings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EarningsTableOrderingComposer(
            $db: $db,
            $table: $db.earnings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RideEarningsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RideEarningsTable> {
  $$RideEarningsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get app =>
      $composableBuilder(column: $table.app, builder: (column) => column);

  GeneratedColumn<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fare =>
      $composableBuilder(column: $table.fare, builder: (column) => column);

  GeneratedColumn<double> get surge =>
      $composableBuilder(column: $table.surge, builder: (column) => column);

  GeneratedColumn<double> get tip =>
      $composableBuilder(column: $table.tip, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get pickupCep =>
      $composableBuilder(column: $table.pickupCep, builder: (column) => column);

  GeneratedColumn<String> get destinationCep => $composableBuilder(
    column: $table.destinationCep,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pickupDistrictId => $composableBuilder(
    column: $table.pickupDistrictId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destinationDistrictId => $composableBuilder(
    column: $table.destinationDistrictId,
    builder: (column) => column,
  );

  $$EarningsTableAnnotationComposer get earningId {
    final $$EarningsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.earningId,
      referencedTable: $db.earnings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EarningsTableAnnotationComposer(
            $db: $db,
            $table: $db.earnings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RideEarningsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RideEarningsTable,
          RideEarning,
          $$RideEarningsTableFilterComposer,
          $$RideEarningsTableOrderingComposer,
          $$RideEarningsTableAnnotationComposer,
          $$RideEarningsTableCreateCompanionBuilder,
          $$RideEarningsTableUpdateCompanionBuilder,
          (RideEarning, $$RideEarningsTableReferences),
          RideEarning,
          PrefetchHooks Function({bool earningId})
        > {
  $$RideEarningsTableTableManager(_$AppDatabase db, $RideEarningsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RideEarningsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RideEarningsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RideEarningsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> earningId = const Value.absent(),
                Value<String> app = const Value.absent(),
                Value<String> serviceType = const Value.absent(),
                Value<double> fare = const Value.absent(),
                Value<double> surge = const Value.absent(),
                Value<double> tip = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double> distanceKm = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> pickupCep = const Value.absent(),
                Value<String?> destinationCep = const Value.absent(),
                Value<String?> pickupDistrictId = const Value.absent(),
                Value<String?> destinationDistrictId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RideEarningsCompanion(
                earningId: earningId,
                app: app,
                serviceType: serviceType,
                fare: fare,
                surge: surge,
                tip: tip,
                durationSeconds: durationSeconds,
                distanceKm: distanceKm,
                status: status,
                pickupCep: pickupCep,
                destinationCep: destinationCep,
                pickupDistrictId: pickupDistrictId,
                destinationDistrictId: destinationDistrictId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String earningId,
                required String app,
                required String serviceType,
                required double fare,
                Value<double> surge = const Value.absent(),
                Value<double> tip = const Value.absent(),
                required int durationSeconds,
                required double distanceKm,
                required String status,
                Value<String?> pickupCep = const Value.absent(),
                Value<String?> destinationCep = const Value.absent(),
                Value<String?> pickupDistrictId = const Value.absent(),
                Value<String?> destinationDistrictId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RideEarningsCompanion.insert(
                earningId: earningId,
                app: app,
                serviceType: serviceType,
                fare: fare,
                surge: surge,
                tip: tip,
                durationSeconds: durationSeconds,
                distanceKm: distanceKm,
                status: status,
                pickupCep: pickupCep,
                destinationCep: destinationCep,
                pickupDistrictId: pickupDistrictId,
                destinationDistrictId: destinationDistrictId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RideEarningsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({earningId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (earningId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.earningId,
                                referencedTable: $$RideEarningsTableReferences
                                    ._earningIdTable(db),
                                referencedColumn: $$RideEarningsTableReferences
                                    ._earningIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RideEarningsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RideEarningsTable,
      RideEarning,
      $$RideEarningsTableFilterComposer,
      $$RideEarningsTableOrderingComposer,
      $$RideEarningsTableAnnotationComposer,
      $$RideEarningsTableCreateCompanionBuilder,
      $$RideEarningsTableUpdateCompanionBuilder,
      (RideEarning, $$RideEarningsTableReferences),
      RideEarning,
      PrefetchHooks Function({bool earningId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$ShiftPausesTableTableManager get shiftPauses =>
      $$ShiftPausesTableTableManager(_db, _db.shiftPauses);
  $$CostsTableTableManager get costs =>
      $$CostsTableTableManager(_db, _db.costs);
  $$FuelCostsTableTableManager get fuelCosts =>
      $$FuelCostsTableTableManager(_db, _db.fuelCosts);
  $$MaintenanceCostsTableTableManager get maintenanceCosts =>
      $$MaintenanceCostsTableTableManager(_db, _db.maintenanceCosts);
  $$EarningsTableTableManager get earnings =>
      $$EarningsTableTableManager(_db, _db.earnings);
  $$RideEarningsTableTableManager get rideEarnings =>
      $$RideEarningsTableTableManager(_db, _db.rideEarnings);
}
