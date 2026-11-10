
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/user_profiles.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserProfiles,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          driftDatabase(name: 'adim_takip'),
        );

  @override
  int get schemaVersion => 1;
}
