
import 'package:drift/drift.dart';

class WalkingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get endedAt => dateTime().nullable()();

  IntColumn get durationSeconds =>
      integer().withDefault(const Constant(0))();

  RealColumn get distanceMeters =>
      real().withDefault(const Constant(0.0))();

  IntColumn get stepCount => integer().nullable()();

  TextColumn get status =>
      text().withDefault(const Constant('active'))();
}
