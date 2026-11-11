
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../repositories/walking_repository.dart';
import '../../../core/services/location_service.dart';

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

  int? _sessionId;
  int? get sessionId => _sessionId;

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  bool _disposed = false;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // --------------------
  // SÜRE
  // --------------------

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  int get durationSeconds => _stopwatch.elapsed.inSeconds;

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

  // --------------------
  // GPS
  // --------------------

  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;

  final List<Position> _routePositions = [];

  List<Position> get routePositions =>
      List.unmodifiable(_routePositions);

  double _distanceMeters = 0;
  double get distanceMeters => _distanceMeters;

  Future<void> _pendingPositions = Future<void>.value();

  void _startLocationTracking() {
    if (_disposed || _positionSubscription != null) {
      return;
    }

    _positionSubscription =
        _locationService.getLocationStream().listen(
      (position) {
        _pendingPositions = _pendingPositions.then(
          (_) async {
            try {
              await _handlePosition(position);
            } catch (e) {
              _errorMessage =
                  'GPS noktası kaydedilemedi: $e';
              _notify();
            }
          },
        );
      },
      onError: (Object error) {
        if (_disposed) return;

        _errorMessage =
            'GPS takibi sırasında hata oluştu: $error';

        // GPS hatası yürüyüşü duraklatmaz.
        _notify();
      },
    );
  }

  Future<void> _getInitialLocation() async {
    try {
      final position =
          await _locationService.getCurrentLocation();

      if (_disposed || _status != WalkingStatus.active) {
        return;
      }

      _pendingPositions = _pendingPositions.then(
        (_) => _handlePosition(position),
      );

      await _pendingPositions;
    } catch (e) {
      debugPrint('Başlangıç GPS hatası: $e');

      // Yürüyüş GPS'i beklemeden devam eder.
    }
  }

  Future<void> _handlePosition(Position position) async {
    if (_disposed ||
        _status != WalkingStatus.active ||
        _sessionId == null) {
      return;
    }

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

    final maxAccuracy =
        isFirstPoint ? 100.0 : 30.0;

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

      final speedMetersPerSecond =
          calculatedDistance / elapsedSeconds;

      if (speedMetersPerSecond > 7) {
        return;
      }

      if (previous.accuracy <= 30) {
        segmentDistance = calculatedDistance;
      }
    }

    await _walkingRepository.addRoutePoint(
      sessionId: _sessionId!,
      latitude: position.latitude,
      longitude: position.longitude,
      recordedAt: position.timestamp,
      accuracyMeters: position.accuracy,
    );

    if (_disposed) return;

    _distanceMeters += segmentDistance;
    _lastPosition = position;
    _routePositions.add(position);

    _notify();
  }

  // --------------------
  // ADIM SAYACI
  // --------------------

  StreamSubscription<StepCount>? _stepSubscription;

  int _walkingSteps = 0;
  int get walkingSteps => _walkingSteps;

  int? _previousSensorSteps;
  bool _waitingForStepBaseline = true;

  bool _stepSensorReady = false;
  bool get stepSensorReady => _stepSensorReady;

  String? _stepError;
  String? get stepError => _stepError;

  bool _isStartingStepTracking = false;

  Future<void> _startStepTracking() async {
    if (_disposed ||
        _stepSubscription != null ||
        _isStartingStepTracking ||
        _status != WalkingStatus.active) {
      return;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      _stepError =
          'Adım sensörü bu platformda desteklenmiyor.';
      _notify();
      return;
    }

    _isStartingStepTracking = true;

    try {
      // Yalnızca izin kontrol edilir.
      // Yürüyüş sırasında izin penceresi açılmaz.
      final permission = Platform.isIOS
          ? Permission.sensors
          : Permission.activityRecognition;

      final status = await permission.status;

      if (_disposed ||
          _status == WalkingStatus.completed ||
          _status == WalkingStatus.idle) {
        return;
      }

      if (!status.isGranted) {
        _stepError =
            'Hareket ve Fitness izni verilmedi.';
        _stepSensorReady = false;
        _notify();
        return;
      }

      _stepError = null;
      _waitingForStepBaseline = true;

      _stepSubscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          if (_disposed ||
              _status == WalkingStatus.completed) {
            return;
          }

          final currentSteps = event.steps;

          if (currentSteps < 0) return;

          // İlk sensör ölçümü referans alınır.
          if (_previousSensorSteps == null) {
            _previousSensorSteps = currentSteps;
            _waitingForStepBaseline = false;
            _stepSensorReady = true;
            _stepError = null;
            _notify();
            return;
          }

          // Duraklatılmış durumda yeni adım eklenmez.
          if (_status == WalkingStatus.paused) {
            _previousSensorSteps = currentSteps;
            _waitingForStepBaseline = true;
            return;
          }

          if (_status != WalkingStatus.active) {
            return;
          }

          // Devam etme sonrasında ilk ölçümü
          // yeni referans olarak kullan.
          if (_waitingForStepBaseline) {
            _previousSensorSteps = currentSteps;
            _waitingForStepBaseline = false;
            _stepSensorReady = true;
            _notify();
            return;
          }

          final difference =
              currentSteps - _previousSensorSteps!;

          // Sistem sayacı yeniden başlamış olabilir.
          if (difference < 0) {
            _previousSensorSteps = currentSteps;
            return;
          }

          _previousSensorSteps = currentSteps;

          if (difference == 0) return;

          _walkingSteps += difference;
          _stepSensorReady = true;
          _stepError = null;

          _notify();
        },
        onError: (Object error) {
          _stepError =
              'Adım sensörü okunamadı: $error';
          _stepSensorReady = false;
          _notify();
        },
      );
    } catch (e) {
      _stepError =
          'Adım takibi başlatılamadı: $e';
      _stepSensorReady = false;
      _notify();
    } finally {
      _isStartingStepTracking = false;
    }
  }

  // --------------------
  // YÜRÜYÜŞÜ BAŞLAT
  // --------------------

  Future<void> startWalking() async {
    if (_disposed ||
        _status != WalkingStatus.idle ||
        _isBusy) {
      return;
    }

    _isBusy = true;
    _errorMessage = null;
    _stepError = null;
    _notify();

    try {
      final id = await _walkingRepository.startWalking();

      if (_disposed) return;

      _sessionId = id;
      _status = WalkingStatus.active;

      _stopwatch.start();
      _startTimer();

      // GPS ve adım takibi bağımsız çalışır.
      unawaited(_getInitialLocation());

      _startLocationTracking();

      unawaited(_startStepTracking());
    } catch (e) {
      _errorMessage =
          'Yürüyüş başlatılamadı: $e';
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  // --------------------
  // YÜRÜYÜŞÜ DURAKLAT
  // --------------------

  Future<void> pauseWalking() async {
    if (_status != WalkingStatus.active ||
        _isBusy ||
        _sessionId == null) {
      return;
    }

    _isBusy = true;
    _notify();

    _positionSubscription?.pause();

    try {
      await _walkingRepository.pauseWalking(
        _sessionId!,
      );

      _status = WalkingStatus.paused;

      _stopwatch.stop();
      _stopTimer();

      await _pendingPositions;

      // Duraklamadan sonra GPS mesafesi
      // eski konumdan devam ettirilmez.
      _lastPosition = null;

      // Adım sayacı yeniden referans alacak.
      _waitingForStepBaseline = true;
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

  // --------------------
  // YÜRÜYÜŞE DEVAM ET
  // --------------------

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
      await _walkingRepository.resumeWalking(
        _sessionId!,
      );

      _lastPosition = null;
      _waitingForStepBaseline = true;

      _status = WalkingStatus.active;

      _stopwatch.start();
      _startTimer();

      if (_positionSubscription == null) {
        _startLocationTracking();
      } else {
        _positionSubscription!.resume();
      }

      if (_stepSubscription == null) {
        unawaited(_startStepTracking());
      }
    } catch (e) {
      _errorMessage =
          'Yürüyüşe devam edilemedi: $e';
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  // --------------------
  // YÜRÜYÜŞÜ BİTİR
  // --------------------

  Future<void> finishWalking() async {
    if ((_status != WalkingStatus.active &&
            _status != WalkingStatus.paused) ||
        _isBusy ||
        _sessionId == null) {
      return;
    }

    _isBusy = true;
    _notify();

    await _positionSubscription?.cancel();
    _positionSubscription = null;

    await _stepSubscription?.cancel();
    _stepSubscription = null;

    _stopwatch.stop();
    _stopTimer();

    try {
      await _pendingPositions;

      final int? savedSteps = _stepSensorReady
          ? _walkingSteps
          : null;

      await _walkingRepository.finishWalking(
        sessionId: _sessionId!,
        durationSeconds: durationSeconds,
        distanceMeters: _distanceMeters,
        stepCount: savedSteps,
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

  // --------------------
  // TEMİZLİK
  // --------------------

  @override
  void dispose() {
    _disposed = true;

    _stopTimer();
    _stopwatch.stop();

    final locationSubscription =
        _positionSubscription;
    _positionSubscription = null;

    if (locationSubscription != null) {
      unawaited(locationSubscription.cancel());
    }

    final stepSubscription = _stepSubscription;
    _stepSubscription = null;

    if (stepSubscription != null) {
      unawaited(stepSubscription.cancel());
    }

    super.dispose();
  }
}
