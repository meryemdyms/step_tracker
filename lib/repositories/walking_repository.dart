
import 'package:drift/drift.dart';

import '../database/app_database.dart';

class WalkingRepository {
  final AppDatabase _database;

  WalkingRepository(this._database);

  // Yeni yürüyüş oluştur
  Future<int> startWalking() {
    return _database.into(_database.walkingSessions).insert(
      WalkingSessionsCompanion.insert(
        startedAt: DateTime.now(),
      ),
    );
  }

  // GPS noktasını kaydet
  Future<int> addRoutePoint({
    required int sessionId,
    required double latitude,
    required double longitude,
    required DateTime recordedAt,
    double? accuracyMeters,
  }) {
    return _database.into(_database.routePoints).insert(
      RoutePointsCompanion.insert(
        sessionId: sessionId,
        latitude: latitude,
        longitude: longitude,
        recordedAt: recordedAt,
        accuracyMeters: Value(accuracyMeters),
      ),
    );
  }

  // Yürüyüşü duraklat
  Future<int> pauseWalking(int sessionId) {
    return (_database.update(_database.walkingSessions)
          ..where((t) => t.id.equals(sessionId)))
        .write(
      const WalkingSessionsCompanion(
        status: Value('paused'),
      ),
    );
  }

  // Duraklatılan yürüyüşe devam et
  Future<int> resumeWalking(int sessionId) {
    return (_database.update(_database.walkingSessions)
          ..where((t) => t.id.equals(sessionId)))
        .write(
      const WalkingSessionsCompanion(
        status: Value('active'),
      ),
    );
  }

  // Yürüyüşü tamamla
  Future<int> finishWalking({
    required int sessionId,
    required int durationSeconds,
    required double distanceMeters,
    int? stepCount,
  }) {
    return (_database.update(_database.walkingSessions)
          ..where((t) => t.id.equals(sessionId)))
        .write(
      WalkingSessionsCompanion(
        endedAt: Value(DateTime.now()),
        durationSeconds: Value(durationSeconds),
        distanceMeters: Value(distanceMeters),
        stepCount: Value(stepCount),
        status: const Value('completed'),
      ),
    );
  }

  // Tamamlanmış yürüyüşleri getir
  Future<List<WalkingSession>> getCompletedWalks() {
    return (_database.select(_database.walkingSessions)
          ..where((t) => t.status.equals('completed'))
          ..orderBy([
            (t) => OrderingTerm.desc(t.startedAt),
          ]))
        .get();
  }

  // Bir yürüyüşün GPS noktalarını getir
  Future<List<RoutePoint>> getRoutePoints(int sessionId) {
    return (_database.select(_database.routePoints)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.recordedAt),
          ]))
        .get();
  }

  Future<WalkingSession?> getWalkingById(int sessionId) {
  return (_database.select(_database.walkingSessions)
        ..where((t) => t.id.equals(sessionId)))
      .getSingleOrNull();
}
}
