// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyStepGoalMeta = const VerificationMeta(
    'dailyStepGoal',
  );
  @override
  late final GeneratedColumn<int> dailyStepGoal = GeneratedColumn<int>(
    'daily_step_goal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, heightCm, weightKg, dailyStepGoal];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('daily_step_goal')) {
      context.handle(
        _dailyStepGoalMeta,
        dailyStepGoal.isAcceptableOrUnknown(
          data['daily_step_goal']!,
          _dailyStepGoalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyStepGoalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      dailyStepGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_step_goal'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final double heightCm;
  final double weightKg;
  final int dailyStepGoal;
  const UserProfile({
    required this.id,
    required this.heightCm,
    required this.weightKg,
    required this.dailyStepGoal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['height_cm'] = Variable<double>(heightCm);
    map['weight_kg'] = Variable<double>(weightKg);
    map['daily_step_goal'] = Variable<int>(dailyStepGoal);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      heightCm: Value(heightCm),
      weightKg: Value(weightKg),
      dailyStepGoal: Value(dailyStepGoal),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      dailyStepGoal: serializer.fromJson<int>(json['dailyStepGoal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'heightCm': serializer.toJson<double>(heightCm),
      'weightKg': serializer.toJson<double>(weightKg),
      'dailyStepGoal': serializer.toJson<int>(dailyStepGoal),
    };
  }

  UserProfile copyWith({
    int? id,
    double? heightCm,
    double? weightKg,
    int? dailyStepGoal,
  }) => UserProfile(
    id: id ?? this.id,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      dailyStepGoal: data.dailyStepGoal.present
          ? data.dailyStepGoal.value
          : this.dailyStepGoal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('dailyStepGoal: $dailyStepGoal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, heightCm, weightKg, dailyStepGoal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.dailyStepGoal == this.dailyStepGoal);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<double> heightCm;
  final Value<double> weightKg;
  final Value<int> dailyStepGoal;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.dailyStepGoal = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required double heightCm,
    required double weightKg,
    required int dailyStepGoal,
  }) : heightCm = Value(heightCm),
       weightKg = Value(weightKg),
       dailyStepGoal = Value(dailyStepGoal);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<int>? dailyStepGoal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (dailyStepGoal != null) 'daily_step_goal': dailyStepGoal,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<double>? heightCm,
    Value<double>? weightKg,
    Value<int>? dailyStepGoal,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (dailyStepGoal.present) {
      map['daily_step_goal'] = Variable<int>(dailyStepGoal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('dailyStepGoal: $dailyStepGoal')
          ..write(')'))
        .toString();
  }
}

class $WalkingSessionsTable extends WalkingSessions
    with TableInfo<$WalkingSessionsTable, WalkingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalkingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _stepCountMeta = const VerificationMeta(
    'stepCount',
  );
  @override
  late final GeneratedColumn<int> stepCount = GeneratedColumn<int>(
    'step_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    durationSeconds,
    distanceMeters,
    stepCount,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'walking_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalkingSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
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
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('step_count')) {
      context.handle(
        _stepCountMeta,
        stepCount.isAcceptableOrUnknown(data['step_count']!, _stepCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalkingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalkingSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      stepCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_count'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $WalkingSessionsTable createAlias(String alias) {
    return $WalkingSessionsTable(attachedDatabase, alias);
  }
}

class WalkingSession extends DataClass implements Insertable<WalkingSession> {
  final int id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final double distanceMeters;
  final int? stepCount;
  final String status;
  const WalkingSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.durationSeconds,
    required this.distanceMeters,
    this.stepCount,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['distance_meters'] = Variable<double>(distanceMeters);
    if (!nullToAbsent || stepCount != null) {
      map['step_count'] = Variable<int>(stepCount);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  WalkingSessionsCompanion toCompanion(bool nullToAbsent) {
    return WalkingSessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationSeconds: Value(durationSeconds),
      distanceMeters: Value(distanceMeters),
      stepCount: stepCount == null && nullToAbsent
          ? const Value.absent()
          : Value(stepCount),
      status: Value(status),
    );
  }

  factory WalkingSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalkingSession(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      stepCount: serializer.fromJson<int?>(json['stepCount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'stepCount': serializer.toJson<int?>(stepCount),
      'status': serializer.toJson<String>(status),
    };
  }

  WalkingSession copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? durationSeconds,
    double? distanceMeters,
    Value<int?> stepCount = const Value.absent(),
    String? status,
  }) => WalkingSession(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    stepCount: stepCount.present ? stepCount.value : this.stepCount,
    status: status ?? this.status,
  );
  WalkingSession copyWithCompanion(WalkingSessionsCompanion data) {
    return WalkingSession(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      stepCount: data.stepCount.present ? data.stepCount.value : this.stepCount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalkingSession(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('stepCount: $stepCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    endedAt,
    durationSeconds,
    distanceMeters,
    stepCount,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalkingSession &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.distanceMeters == this.distanceMeters &&
          other.stepCount == this.stepCount &&
          other.status == this.status);
}

class WalkingSessionsCompanion extends UpdateCompanion<WalkingSession> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> durationSeconds;
  final Value<double> distanceMeters;
  final Value<int?> stepCount;
  final Value<String> status;
  const WalkingSessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.stepCount = const Value.absent(),
    this.status = const Value.absent(),
  });
  WalkingSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.stepCount = const Value.absent(),
    this.status = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<WalkingSession> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationSeconds,
    Expression<double>? distanceMeters,
    Expression<int>? stepCount,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (stepCount != null) 'step_count': stepCount,
      if (status != null) 'status': status,
    });
  }

  WalkingSessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? durationSeconds,
    Value<double>? distanceMeters,
    Value<int?>? stepCount,
    Value<String>? status,
  }) {
    return WalkingSessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      stepCount: stepCount ?? this.stepCount,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (stepCount.present) {
      map['step_count'] = Variable<int>(stepCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalkingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('stepCount: $stepCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $RoutePointsTable extends RoutePoints
    with TableInfo<$RoutePointsTable, RoutePoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutePointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES walking_sessions (id)',
    ),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMetersMeta = const VerificationMeta(
    'accuracyMeters',
  );
  @override
  late final GeneratedColumn<double> accuracyMeters = GeneratedColumn<double>(
    'accuracy_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    latitude,
    longitude,
    recordedAt,
    accuracyMeters,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutePoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('accuracy_meters')) {
      context.handle(
        _accuracyMetersMeta,
        accuracyMeters.isAcceptableOrUnknown(
          data['accuracy_meters']!,
          _accuracyMetersMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutePoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutePoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      accuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_meters'],
      ),
    );
  }

  @override
  $RoutePointsTable createAlias(String alias) {
    return $RoutePointsTable(attachedDatabase, alias);
  }
}

class RoutePoint extends DataClass implements Insertable<RoutePoint> {
  final int id;
  final int sessionId;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double? accuracyMeters;
  const RoutePoint({
    required this.id,
    required this.sessionId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.accuracyMeters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    if (!nullToAbsent || accuracyMeters != null) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters);
    }
    return map;
  }

  RoutePointsCompanion toCompanion(bool nullToAbsent) {
    return RoutePointsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      recordedAt: Value(recordedAt),
      accuracyMeters: accuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyMeters),
    );
  }

  factory RoutePoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutePoint(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      accuracyMeters: serializer.fromJson<double?>(json['accuracyMeters']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'accuracyMeters': serializer.toJson<double?>(accuracyMeters),
    };
  }

  RoutePoint copyWith({
    int? id,
    int? sessionId,
    double? latitude,
    double? longitude,
    DateTime? recordedAt,
    Value<double?> accuracyMeters = const Value.absent(),
  }) => RoutePoint(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    recordedAt: recordedAt ?? this.recordedAt,
    accuracyMeters: accuracyMeters.present
        ? accuracyMeters.value
        : this.accuracyMeters,
  );
  RoutePoint copyWithCompanion(RoutePointsCompanion data) {
    return RoutePoint(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      accuracyMeters: data.accuracyMeters.present
          ? data.accuracyMeters.value
          : this.accuracyMeters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutePoint(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('accuracyMeters: $accuracyMeters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    latitude,
    longitude,
    recordedAt,
    accuracyMeters,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutePoint &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.recordedAt == this.recordedAt &&
          other.accuracyMeters == this.accuracyMeters);
}

class RoutePointsCompanion extends UpdateCompanion<RoutePoint> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> recordedAt;
  final Value<double?> accuracyMeters;
  const RoutePointsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.accuracyMeters = const Value.absent(),
  });
  RoutePointsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required double latitude,
    required double longitude,
    required DateTime recordedAt,
    this.accuracyMeters = const Value.absent(),
  }) : sessionId = Value(sessionId),
       latitude = Value(latitude),
       longitude = Value(longitude),
       recordedAt = Value(recordedAt);
  static Insertable<RoutePoint> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? recordedAt,
    Expression<double>? accuracyMeters,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
    });
  }

  RoutePointsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<DateTime>? recordedAt,
    Value<double?>? accuracyMeters,
  }) {
    return RoutePointsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      recordedAt: recordedAt ?? this.recordedAt,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (accuracyMeters.present) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutePointsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('accuracyMeters: $accuracyMeters')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $WalkingSessionsTable walkingSessions = $WalkingSessionsTable(
    this,
  );
  late final $RoutePointsTable routePoints = $RoutePointsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    walkingSessions,
    routePoints,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required double heightCm,
      required double weightKg,
      required int dailyStepGoal,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<double> heightCm,
      Value<double> weightKg,
      Value<int> dailyStepGoal,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyStepGoal => $composableBuilder(
    column: $table.dailyStepGoal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyStepGoal => $composableBuilder(
    column: $table.dailyStepGoal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get dailyStepGoal => $composableBuilder(
    column: $table.dailyStepGoal,
    builder: (column) => column,
  );
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<int> dailyStepGoal = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                heightCm: heightCm,
                weightKg: weightKg,
                dailyStepGoal: dailyStepGoal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double heightCm,
                required double weightKg,
                required int dailyStepGoal,
              }) => UserProfilesCompanion.insert(
                id: id,
                heightCm: heightCm,
                weightKg: weightKg,
                dailyStepGoal: dailyStepGoal,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserProfilesTable, UserProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserProfilesTable,
                    UserProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$WalkingSessionsTableCreateCompanionBuilder =
    WalkingSessionsCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> durationSeconds,
      Value<double> distanceMeters,
      Value<int?> stepCount,
      Value<String> status,
    });
typedef $$WalkingSessionsTableUpdateCompanionBuilder =
    WalkingSessionsCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> durationSeconds,
      Value<double> distanceMeters,
      Value<int?> stepCount,
      Value<String> status,
    });

final class $$WalkingSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WalkingSessionsTable, WalkingSession> {
  $$WalkingSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$RoutePointsTable, List<RoutePoint>>
  _routePointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routePoints,
    aliasName: 'walking_sessions__id__route_points__session_id',
  );

  $$RoutePointsTableProcessedTableManager get routePointsRefs {
    final manager = $$RoutePointsTableTableManager(
      $_db,
      $_db.routePoints,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routePointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WalkingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WalkingSessionsTable> {
  $$WalkingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stepCount => $composableBuilder(
    column: $table.stepCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routePointsRefs(
    Expression<bool> Function($$RoutePointsTableFilterComposer f) f,
  ) {
    final $$RoutePointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routePoints,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutePointsTableFilterComposer(
            $db: $db,
            $table: $db.routePoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WalkingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalkingSessionsTable> {
  $$WalkingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stepCount => $composableBuilder(
    column: $table.stepCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalkingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalkingSessionsTable> {
  $$WalkingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stepCount =>
      $composableBuilder(column: $table.stepCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  Expression<T> routePointsRefs<T extends Object>(
    Expression<T> Function($$RoutePointsTableAnnotationComposer a) f,
  ) {
    final $$RoutePointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routePoints,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutePointsTableAnnotationComposer(
            $db: $db,
            $table: $db.routePoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WalkingSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalkingSessionsTable,
          WalkingSession,
          $$WalkingSessionsTableFilterComposer,
          $$WalkingSessionsTableOrderingComposer,
          $$WalkingSessionsTableAnnotationComposer,
          $$WalkingSessionsTableCreateCompanionBuilder,
          $$WalkingSessionsTableUpdateCompanionBuilder,
          (WalkingSession, $$WalkingSessionsTableReferences),
          WalkingSession,
          PrefetchHooks Function({bool routePointsRefs})
        > {
  $$WalkingSessionsTableTableManager(
    _$AppDatabase db,
    $WalkingSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalkingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalkingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalkingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int?> stepCount = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => WalkingSessionsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
                stepCount: stepCount,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int?> stepCount = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => WalkingSessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
                stepCount: stepCount,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WalkingSessionsTable, WalkingSession>(table),
                  $$WalkingSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routePointsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routePointsRefs) db.routePoints],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routePointsRefs)
                    await $_getPrefetchedDataByColumns<
                      WalkingSession,
                      $WalkingSessionsTable,
                      RoutePoint,
                      $RoutePointsTable
                    >(
                      currentTable: table,
                      referencedTable: $$WalkingSessionsTableReferences
                          ._routePointsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WalkingSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).routePointsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'session_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WalkingSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalkingSessionsTable,
      WalkingSession,
      $$WalkingSessionsTableFilterComposer,
      $$WalkingSessionsTableOrderingComposer,
      $$WalkingSessionsTableAnnotationComposer,
      $$WalkingSessionsTableCreateCompanionBuilder,
      $$WalkingSessionsTableUpdateCompanionBuilder,
      (WalkingSession, $$WalkingSessionsTableReferences),
      WalkingSession,
      PrefetchHooks Function({bool routePointsRefs})
    >;
typedef $$RoutePointsTableCreateCompanionBuilder =
    RoutePointsCompanion Function({
      Value<int> id,
      required int sessionId,
      required double latitude,
      required double longitude,
      required DateTime recordedAt,
      Value<double?> accuracyMeters,
    });
typedef $$RoutePointsTableUpdateCompanionBuilder =
    RoutePointsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<double> latitude,
      Value<double> longitude,
      Value<DateTime> recordedAt,
      Value<double?> accuracyMeters,
    });

final class $$RoutePointsTableReferences
    extends BaseReferences<_$AppDatabase, $RoutePointsTable, RoutePoint> {
  $$RoutePointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WalkingSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .walkingSessions
      .createAlias('route_points__session_id__walking_sessions__id');

  $$WalkingSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$WalkingSessionsTableTableManager(
      $_db,
      $_db.walkingSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutePointsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutePointsTable> {
  $$RoutePointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  $$WalkingSessionsTableFilterComposer get sessionId {
    final $$WalkingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.walkingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalkingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.walkingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutePointsTable> {
  $$RoutePointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  $$WalkingSessionsTableOrderingComposer get sessionId {
    final $$WalkingSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.walkingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalkingSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.walkingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutePointsTable> {
  $$RoutePointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => column,
  );

  $$WalkingSessionsTableAnnotationComposer get sessionId {
    final $$WalkingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.walkingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalkingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.walkingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutePointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutePointsTable,
          RoutePoint,
          $$RoutePointsTableFilterComposer,
          $$RoutePointsTableOrderingComposer,
          $$RoutePointsTableAnnotationComposer,
          $$RoutePointsTableCreateCompanionBuilder,
          $$RoutePointsTableUpdateCompanionBuilder,
          (RoutePoint, $$RoutePointsTableReferences),
          RoutePoint,
          PrefetchHooks Function({bool sessionId})
        > {
  $$RoutePointsTableTableManager(_$AppDatabase db, $RoutePointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutePointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutePointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutePointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<double?> accuracyMeters = const Value.absent(),
              }) => RoutePointsCompanion(
                id: id,
                sessionId: sessionId,
                latitude: latitude,
                longitude: longitude,
                recordedAt: recordedAt,
                accuracyMeters: accuracyMeters,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required double latitude,
                required double longitude,
                required DateTime recordedAt,
                Value<double?> accuracyMeters = const Value.absent(),
              }) => RoutePointsCompanion.insert(
                id: id,
                sessionId: sessionId,
                latitude: latitude,
                longitude: longitude,
                recordedAt: recordedAt,
                accuracyMeters: accuracyMeters,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutePointsTable, RoutePoint>(table),
                  $$RoutePointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$RoutePointsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$RoutePointsTableReferences
                            ._sessionIdTable(db)
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
        ),
      );
}

typedef $$RoutePointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutePointsTable,
      RoutePoint,
      $$RoutePointsTableFilterComposer,
      $$RoutePointsTableOrderingComposer,
      $$RoutePointsTableAnnotationComposer,
      $$RoutePointsTableCreateCompanionBuilder,
      $$RoutePointsTableUpdateCompanionBuilder,
      (RoutePoint, $$RoutePointsTableReferences),
      RoutePoint,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$WalkingSessionsTableTableManager get walkingSessions =>
      $$WalkingSessionsTableTableManager(_db, _db.walkingSessions);
  $$RoutePointsTableTableManager get routePoints =>
      $$RoutePointsTableTableManager(_db, _db.routePoints);
}
