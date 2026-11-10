import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/user_profiles.dart';
import 'tables/walking_sessions.dart';
import 'tables/route_points.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserProfiles,
    WalkingSessions,
    RoutePoints,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          driftDatabase(name: 'adim_takip'),
        );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },

      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(walkingSessions);
          await m.createTable(routePoints);
        }
      },

      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

