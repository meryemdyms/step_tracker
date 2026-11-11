
import 'package:drift/drift.dart';

import 'walking_sessions.dart';

class RoutePoints extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sessionId =>
      integer().references(WalkingSessions, #id)();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();

  DateTimeColumn get recordedAt => dateTime()();

  RealColumn get accuracyMeters => real().nullable()();
}
