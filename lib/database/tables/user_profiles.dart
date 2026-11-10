
import 'package:drift/drift.dart';

class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();

  RealColumn get heightCm => real()();

  RealColumn get weightKg => real()();

  IntColumn get dailyStepGoal => integer()();
}
