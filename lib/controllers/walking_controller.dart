import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';
import '../repositories/walking_repository.dart';

enum WalkingStatus { idle, active, paused, completed }

class WalkingController extends ChangeNotifier {
  final LocationService _locationService;
  final WalkingRepository _walkingRepository;

  WalkingController(this._locationService, this._walkingRepository);

  // Yürüyüş durumu
  WalkingStatus _status = WalkingStatus.idle;
  WalkingStatus get status => _status;

  // Veritabanındaki yürüyüş kimliği
  int? _sessionId;
  int? get sessionId => _sessionId;

  // Süre yönetimi
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  int get durationSeconds => _stopwatch.elapsed.inSeconds;

  // GPS yönetimi
  StreamSubscription<Position>? _positionSubscription;

  Position? _lastPosition;

  final List<Position> _routePositions = [];
  List<Position> get routePositions => List.unmodifiable(_routePositions);

  // Mesafe
  double _distanceMeters = 0;
  double get distanceMeters => _distanceMeters;

  // İşlem durumu
  bool _isBusy = false;
  bool get isBusy => _isBusy;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // GPS kayıtlarını sırayla işlemek için
  Future<void> _pendingPositions = Future.value();

  bool _disposed = false;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // GPS dinlemeyi başlat
  void _startLocationTracking() {
    _positionSubscription = _locationService.getLocationStream().listen(
      (position) {
        _pendingPositions = _pendingPositions.then((_) async {
          try {
            await _handlePosition(position);
          } catch (_) {
            _errorMessage = 'GPS noktası kaydedilemedi.';
            _notify();
          }
        });
      },
      onError: (Object error) {
        _errorMessage = 'GPS takibi sırasında hata oluştu.';
        _notify();

        // Hata sonrası bozuk GPS akışıyla devam etmiyoruz.
        unawaited(pauseWalking());
      },
    );
  }

  // Yürüyüşü başlat
  Future<void> startWalking() async {
    if (_status != WalkingStatus.idle || _isBusy) return;

    _isBusy = true;
    _errorMessage = null;
    _notify();

    try {
      final hasPermission = await _locationService.checkLocationPermission();

      if (!hasPermission) {
        throw StateError('Yürüyüş için konum izni gerekli.');
      }

      final id = await _walkingRepository.startWalking();

      _sessionId = id;
      _status = WalkingStatus.active;

      _stopwatch.start();

      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _notify());

      _startLocationTracking();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  // GPS noktasını işle
  Future<void> _handlePosition(Position position) async {
    if (_status != WalkingStatus.active || _sessionId == null || _disposed) {
      return;
    }

    // Geçersiz veya düşük doğruluklu ölçümleri ele
    if (!position.accuracy.isFinite ||
        position.accuracy < 0 ||
        position.accuracy > 30) {
      return;
    }

    double segmentDistance = 0;

    final previous = _lastPosition;

    if (previous != null) {
      final elapsedSeconds =
          position.timestamp.difference(previous.timestamp).inMilliseconds /
          1000;

      if (elapsedSeconds <= 0) return;

      segmentDistance = _locationService.calculateDistance(
        startLatitude: previous.latitude,
        startLongitude: previous.longitude,
        endLatitude: position.latitude,
        endLongitude: position.longitude,
      );

      if (!segmentDistance.isFinite) return;

      // Basit GPS sıçraması filtresi
      final speedMetersPerSecond = segmentDistance / elapsedSeconds;

      if (speedMetersPerSecond > 7) {
        return;
      }
    }

    // Önce veritabanına kaydet
    await _walkingRepository.addRoutePoint(
      sessionId: _sessionId!,
      latitude: position.latitude,
      longitude: position.longitude,
      recordedAt: position.timestamp,
      accuracyMeters: position.accuracy,
    );

    // Kayıt başarılıysa bellekteki rotayı güncelle
    _distanceMeters += segmentDistance;
    _lastPosition = position;
    _routePositions.add(position);

    _notify();
  }

  // Yürüyüşü duraklat
  Future<void> pauseWalking() async {
    if (_status != WalkingStatus.active || _isBusy) return;

    _isBusy = true;
    _notify();

    _positionSubscription?.pause();

    try {
      await _walkingRepository.pauseWalking(_sessionId!);

      _status = WalkingStatus.paused;

      _stopwatch.stop();
      _timer?.cancel();
      _timer = null;

      // Bekleyen GPS kayıtları bitsin
      await _pendingPositions;
    } catch (e) {
      _errorMessage = 'Yürüyüş duraklatılamadı: $e';

      if (_status == WalkingStatus.active) {
        _positionSubscription?.resume();
      }
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  // Yürüyüşe devam et
  Future<void> resumeWalking() async {
    if (_status != WalkingStatus.paused || _isBusy) return;

    _isBusy = true;
    _errorMessage = null;
    _notify();

    try {
      final hasPermission = await _locationService.checkLocationPermission();

      if (!hasPermission) {
        throw StateError('Konum izni bulunamadı.');
      }

      await _walkingRepository.resumeWalking(_sessionId!);

      // Duraklatma öncesi koordinatla yeni konumu
      // birleştirip sahte mesafe hesaplamayalım.
      _lastPosition = null;

      _status = WalkingStatus.active;

      _stopwatch.start();

      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _notify());

      if (_positionSubscription == null) {
        _startLocationTracking();
      } else {
        _positionSubscription!.resume();
      }
    } catch (e) {
      _errorMessage = 'Yürüyüşe devam edilemedi: $e';
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  // Yürüyüşü tamamla
  Future<void> finishWalking() async {
    if ((_status != WalkingStatus.active && _status != WalkingStatus.paused) ||
        _isBusy) {
      return;
    }

    _isBusy = true;
    _notify();

    // Yeni konumların gelmesini durdur
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;

    try {
      // İşlenmekte olan GPS kayıtlarını bekle
      await _pendingPositions;

      await _walkingRepository.finishWalking(
        sessionId: _sessionId!,
        durationSeconds: durationSeconds,
        distanceMeters: _distanceMeters,

        // Adım sensörü henüz bağlı değil.
        stepCount: null,
      );

      _status = WalkingStatus.completed;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Yürüyüş tamamlanamadı: $e';

      // Kaydetme başarısız olursa tekrar
      // bitirmeyi deneyebilmek için paused kal.
      _status = WalkingStatus.paused;
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;

    _timer?.cancel();
    _stopwatch.stop();

    final subscription = _positionSubscription;
    _positionSubscription = null;

    if (subscription != null) {
      unawaited(subscription.cancel());
    }

    super.dispose();
  }
}
