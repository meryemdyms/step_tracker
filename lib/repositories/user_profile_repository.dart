
import 'package:drift/drift.dart';

import '../database/app_database.dart';

class UserProfileRepository {
  final AppDatabase _database;

  UserProfileRepository(this._database);

  Future<UserProfile?> getProfile() {
    return _database.select(_database.userProfiles).getSingleOrNull();
  }

  Future<int> saveProfile({
    required double heightCm,
    required double weightKg,
    required int dailyStepGoal,
  }) async {
    final existingProfile = await getProfile();

    if (existingProfile == null) {
      return _database.into(_database.userProfiles).insert(
        UserProfilesCompanion.insert(
          heightCm: heightCm,
          weightKg: weightKg,
          dailyStepGoal: dailyStepGoal,
        ),
      );
    }

    await (_database.update(_database.userProfiles)
          ..where((table) => table.id.equals(existingProfile.id)))
        .write(
      UserProfilesCompanion(
        heightCm: Value(heightCm),
        weightKg: Value(weightKg),
        dailyStepGoal: Value(dailyStepGoal),
      ),
    );

    return existingProfile.id;
  }
}
