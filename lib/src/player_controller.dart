import 'package:flutter/foundation.dart';

import 'flutter_kinescope_player_platform_interface.dart';
import 'player_config.dart';
import 'player_event.dart';
import 'player_status.dart';

/// Контроллер для управления плеером Kinescope
class PlayerController extends ChangeNotifier {
  int _viewId = 0;
  final FlutterKinescopePlayerPlatform _platform;
  final String videoId;
  final PlayerConfig? config;

  bool _isPlaying = false;
  bool _isLoading = false;
  String? _error;

  // Instance-based callbacks
  void Function(double)? _onChangePlaybackRate;
  void Function(PlayerStatus)? _onChangeStatus;
  void Function(bool)? _onChangeFullscreen;
  void Function(double)? _onProgressUpdate;

  PlayerController({
    required this.videoId,
    this.config,
    FlutterKinescopePlayerPlatform? platform,
  }) : _platform = platform ?? FlutterKinescopePlayerPlatform.instance {
    PlayerEvents.ensureInitialized();
    PlayerEvents.listenOnChangeStatus((status) {
      if (status == PlayerStatus.playing) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      notifyListeners();
    });
  }

  /// Играет ли видео
  bool get isPlaying => _isPlaying;

  /// Загружается ли видео
  bool get isLoading => _isLoading;

  /// Ошибка
  String? get error => _error;

  /// Установить viewId, полученный из onPlatformViewCreated
  void setViewId(int id) {
    _viewId = id;
  }

  /// Инициализация плеера и загрузка видео
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _platform.initializePlayer(_viewId);
      await loadVideo();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Загрузка видео (использует videoId и config из контроллера)
  Future<void> loadVideo() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _platform.loadVideo(
        _viewId,
        videoId,
        config?.toMap(),
      );

      if (config?.isLive ?? false) {
        await setLiveState(true);
        if (result['liveStartDate'] != null &&
            result['liveStartDate'].toString().isNotEmpty) {
          await showLiveStartDate(result['liveStartDate']);
        }
      }
      // Если включен автоплей, запускаем видео
      if (config?.autoPlay == true) {
        await play();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Воспроизведение
  Future<void> play() async {
    try {
      await _platform.play(_viewId);
      _isPlaying = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Пауза
  Future<void> pause() async {
    try {
      await _platform.pause(_viewId);
      _isPlaying = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Перемотка к позиции
  Future<void> seekTo(int position) async {
    try {
      await _platform.seekTo(_viewId, position);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Установка полноэкранного режима
  Future<void> setFullscreen(bool fullscreen) async {
    try {
      await _platform.setFullscreen(_viewId, fullscreen);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Очистка ресурсов
  Future<void> deactivate() async {
    try {
      await _platform.dispose(_viewId);
    } catch (e) {
      // Игнорируем ошибки при очистке
    }
  }

  /// Подписка на изменение скорости воспроизведения
  void setOnChangePlaybackRate(void Function(double rate) cb) {
    if (_onChangePlaybackRate != null) {
      PlayerEvents.removeOnChangePlaybackRate(_onChangePlaybackRate!);
    }
    _onChangePlaybackRate = (rate) {
      cb(rate);
    };
    PlayerEvents.listenOnChangePlaybackRate(_onChangePlaybackRate!);
  }

  /// Подписка на изменение статуса плеера
  void setOnChangeStatus(void Function(PlayerStatus status) cb) {
    if (_onChangeStatus != null) {
      PlayerEvents.removeOnChangeStatus(_onChangeStatus!);
    }
    _onChangeStatus = (status) {
      cb(status);
    };
    PlayerEvents.listenOnChangeStatus(_onChangeStatus!);
  }

  /// Подписка на изменение полноэкранного режима
  void setOnChangeFullscreen(void Function(bool isFullscreen) cb) {
    if (_onChangeFullscreen != null) {
      PlayerEvents.removeOnTapFullscreen(_onChangeFullscreen!);
    }
    _onChangeFullscreen = (isFullscreen) {
      cb(isFullscreen);
    };
    PlayerEvents.listenOnTapFullscreen(_onChangeFullscreen!);
  }

  /// Подписка на обновление прогресса просмотра (процент, позиция, длительность)
  void setOnProgressUpdate(void Function(double percent) cb) {
    if (_onProgressUpdate != null) {
      PlayerEvents.removeOnProgressUpdate(_onProgressUpdate!);
    }
    _onProgressUpdate = (percent) {
      cb(percent);
    };
    PlayerEvents.listenOnProgressUpdate(_onProgressUpdate!);
  }

  /// Остановить воспроизведение
  Future<void> stop() async {
    try {
      await _platform.stop(_viewId);
      _isPlaying = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Проверка, находится ли плеер на паузе
  bool get isPaused => !_isPlaying;

  /// Получить текущую скорость воспроизведения
  Future<double> getPlaybackRate() async {
    try {
      final rate = await _platform.getPlaybackRate(_viewId);
      _error = null;
      return rate;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 1.0;
    }
  }

  /// Получить текущую позицию просмотра (в секундах)
  Future<int> getCurrentPosition() async {
    try {
      final pos = await _platform.getCurrentPosition(_viewId);
      _error = null;
      return pos;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0;
    }
  }

  /// Получить полную длительность видео (в секундах)
  Future<int> getDuration() async {
    try {
      final duration = await _platform.getDuration(_viewId);
      _error = null;
      return duration;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0;
    }
  }

  /// Включить live-режим (вызывает setLiveState на платформе)
  Future<void> setLiveState(bool isLive) async {
    await _platform.setLiveState(_viewId, isLive);
  }

  /// Показать дату старта live (вызывает showLiveStartDate на платформе)
  Future<void> showLiveStartDate(String startDate) async {
    await _platform.showLiveStartDate(_viewId, startDate);
  }

  @override
  void dispose() {
    if (_onChangePlaybackRate != null) {
      PlayerEvents.removeOnChangePlaybackRate(_onChangePlaybackRate!);
    }
    if (_onChangeStatus != null) {
      PlayerEvents.removeOnChangeStatus(_onChangeStatus!);
    }
    if (_onChangeFullscreen != null) {
      PlayerEvents.removeOnTapFullscreen(_onChangeFullscreen!);
    }
    if (_onProgressUpdate != null) {
      PlayerEvents.removeOnProgressUpdate(_onProgressUpdate!);
    }
    deactivate();
    super.dispose();
  }
}
