
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';
import '../repositories/walking_repository.dart';

enum WalkingStatus {
  idle,
  active,
  paused,
  completed,
}

class WalkingController extends ChangeNotifier {
  final LocationService _locationService;
  final WalkingRepository _walkingRepository;

  WalkingController(
    this._locationService,
    this._walkingRepository,
  );

  // Yürüyüş durumu
  WalkingStatus _status = WalkingStatus.idle;
  WalkingStatus get status => _status;

  // Drift yürüyüş kaydının ID'si
  int? _sessionId;
  int? get sessionId => _sessionId;

  // Süre
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  int get durationSeconds => _stopwatch.elapsed.inSeconds;

  // GPS
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;

  final List<Position> _routePositions = [];

  List<Position> get routePositions =>
      List.unmodifiable(_routePositions);

  // Mesafe
  double _distanceMeters = 0;
  double get distanceMeters => _distanceMeters;

  // İşlem durumu
  bool _isBusy = false;
  bool get isBusy => _isBusy;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // GPS verilerini sırayla işlemek için kullanılır.
  Future<void> _pendingPositions = Future<void>.value();

  bool _disposed = false;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _notify(),
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // GPS akışını başlatır.
  void _startLocationTracking() {
    if (_positionSubscription != null || _disposed) {
      return;
    }

    _positionSubscription =
        _locationService.getLocationStream().listen(
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
        if (_disposed ||
            _status != WalkingStatus.active) {
          return;
        }

        _errorMessage =
            'GPS takibi sırasında hata oluştu: $error';

        _notify();

        // GPS akışı hata verirse yürüyüşü duraklat.
        unawaited(pauseWalking());
      },
    );
  }

  // Yürüyüşü başlatır.
  
Future<void> startWalking() async {
  if (_status != WalkingStatus.idle ||
      _isBusy ||
      _disposed) {
    return;
  }

  _isBusy = true;
  _errorMessage = null;
  _notify();

  try {
    final hasPermission =
        await _locationService.checkLocationPermission();

    if (!hasPermission) {
      throw StateError(
        'Konum servisi kapalı veya konum izni verilmemiş.',
      );
    }

    // Önce GPS konumunu al.
    final initialPosition =
        await _locationService.getCurrentLocation();

    debugPrint(
      'GPS bulundu: ${initialPosition.latitude}, '
      '${initialPosition.longitude}',
    );

    // Konum olmadan yürüyüş oturumu oluşturma.
    final id = await _walkingRepository.startWalking();

    _sessionId = id;
    _status = WalkingStatus.active;

    // Başlangıç noktasını kaydet.
    // Bu noktada mesafe henüz 0 metre.
    await _handlePosition(initialPosition);

    // GPS bulunduğuna göre süreyi başlat.
    _stopwatch.start();
    _startTimer();

    // Hareket oldukça yeni koordinatları al.
    _startLocationTracking();
  } catch (e) {
    debugPrint('GPS başlatma hatası: $e');

    _errorMessage = 'Konum alınamadı: $e';
  } finally {
    _isBusy = false;
    _notify();
  }
}


  // Yeni GPS koordinatını işler.
  Future<void> _handlePosition(Position position) async {
    if (_status != WalkingStatus.active ||
        _sessionId == null ||
        _disposed) {
      return;
    }

    // Geçersiz koordinatları ele.
    if (!position.latitude.isFinite ||
        !position.longitude.isFinite ||
        position.latitude < -90 ||
        position.latitude > 90 ||
        position.longitude < -180 ||
        position.longitude > 180) {
      return;
    }

    if (!position.accuracy.isFinite ||
        position.accuracy < 0) {
      return;
    }

    final previous = _lastPosition;
    final isFirstPoint = previous == null;

    // İlk noktanın haritada gösterilebilmesi
    // için biraz daha geniş tolerans tanıyoruz.
    // Hareket noktalarında daha sıkı filtre kullanılır.
    final maxAccuracy = isFirstPoint ? 100.0 : 30.0;

    if (position.accuracy > maxAccuracy) {
      return;
    }

    double segmentDistance = 0;

    if (previous != null) {
      final elapsedSeconds = position.timestamp
              .difference(previous.timestamp)
              .inMilliseconds /
          1000;

      if (elapsedSeconds <= 0) {
        return;
      }

      final calculatedDistance =
          _locationService.calculateDistance(
        startLatitude: previous.latitude,
        startLongitude: previous.longitude,
        endLatitude: position.latitude,
        endLongitude: position.longitude,
      );

      if (!calculatedDistance.isFinite ||
          calculatedDistance < 0) {
        return;
      }

      // Ani ve gerçekçi olmayan GPS sıçramalarını ele.
      final speedMetersPerSecond =
          calculatedDistance / elapsedSeconds;

      if (speedMetersPerSecond > 7) {
        return;
      }

      // İlk ölçümün doğruluğu düşükse
      // o noktadan sonraki sıçramayı mesafeye ekleme.
      if (previous.accuracy <= 30) {
        segmentDistance = calculatedDistance;
      }
    }

    // Önce koordinatı Drift'e kaydet.
    await _walkingRepository.addRoutePoint(
      sessionId: _sessionId!,
      latitude: position.latitude,
      longitude: position.longitude,
      recordedAt: position.timestamp,
      accuracyMeters: position.accuracy,
    );

    if (_disposed) return;

    // Kayıt başarılıysa canlı verileri güncelle.
    _distanceMeters += segmentDistance;
    _lastPosition = position;
    _routePositions.add(position);

    _errorMessage = null;
    _notify();
  }

  // Yürüyüşü duraklatır.
  Future<void> pauseWalking() async {
    if (_status != WalkingStatus.active ||
        _isBusy ||
        _sessionId == null) {
      return;
    }

    _isBusy = true;
    _notify();

    // Yeni konum alımını durdur.
    _positionSubscription?.pause();

    try {
      await _walkingRepository.pauseWalking(
        _sessionId!,
      );

      _status = WalkingStatus.paused;

      _stopwatch.stop();
      _stopTimer();

      // Önceden kuyruğa alınmış kayıtları bekle.
      await _pendingPositions;

      // Devam edildiğinde eski GPS noktasından
      // yeni konuma sahte mesafe hesaplanmasın.
      _lastPosition = null;
    } catch (e) {
      _errorMessage =
          'Yürüyüş duraklatılamadı: $e';

      if (_status == WalkingStatus.active) {
        _positionSubscription?.resume();
      }
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  // Duraklatılmış yürüyüşe devam eder.
  Future<void> resumeWalking() async {
    if (_status != WalkingStatus.paused ||
        _isBusy ||
        _sessionId == null) {
      return;
    }

    _isBusy = true;
    _errorMessage = null;
    _notify();

    try {
      final hasPermission =
          await _locationService.checkLocationPermission();

      if (!hasPermission) {
        throw StateError(
          'Konum izni bulunamadı.',
        );
      }

      await _walkingRepository.resumeWalking(
        _sessionId!,
      );

      _lastPosition = null;
      _status = WalkingStatus.active;

      _stopwatch.start();
      _startTimer();

      if (_positionSubscription == null) {
        _startLocationTracking();
      } else {
        _positionSubscription!.resume();
      }
    } catch (e) {
      _errorMessage =
          'Yürüyüşe devam edilemedi: $e';
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  // Yürüyüşü bitirir.
  Future<void> finishWalking() async {
    if ((_status != WalkingStatus.active &&
            _status != WalkingStatus.paused) ||
        _isBusy ||
        _sessionId == null) {
      return;
    }

    _isBusy = true;
    _notify();

    // Yeni GPS verilerini durdur.
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    _stopwatch.stop();
    _stopTimer();

    try {
      // İşlenmekte olan kayıtları tamamla.
      await _pendingPositions;

      // Yürüyüş sonucunu Drift'e kaydet.
      await _walkingRepository.finishWalking(
        sessionId: _sessionId!,
        durationSeconds: durationSeconds,
        distanceMeters: _distanceMeters,

        // Gerçek adım sayacı henüz entegre edilmedi.
        stepCount: null,
      );

      _status = WalkingStatus.completed;
      _errorMessage = null;
    } catch (e) {
      _status = WalkingStatus.paused;

      _errorMessage =
          'Yürüyüş tamamlanamadı: $e';
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;

    _stopTimer();
    _stopwatch.stop();

    final subscription = _positionSubscription;
    _positionSubscription = null;

    if (subscription != null) {
      unawaited(subscription.cancel());
    }

    super.dispose();
  }
}
