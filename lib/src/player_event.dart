import 'package:flutter/services.dart';

import 'player_status.dart';

class PlayerEvents {
  static final List<void Function(bool)> _fullscreenListeners = [];
  static final List<void Function(double)> _playbackRateListeners = [];
  static final List<void Function(PlayerStatus)> _statusListeners = [];
  static final List<void Function(double)> _progressListeners = [];

  static const EventChannel _eventChannel = EventChannel(
    'flutter_kinescope_player_events',
  );
  static bool _initialized = false;
  static Stream<dynamic>? _eventStream;

  static void _ensureInitialized() {
    if (_initialized) return;
    _eventStream = _eventChannel.receiveBroadcastStream();
    _eventStream!.listen((event) {
      if (event is Map) {
        final method = event['method'];
        final args = event['args'] ?? {};
        switch (method) {
          case 'onTapFullscreen':
            final bool isFullscreen = args['isFullscreen'] == true;
            for (final cb in _fullscreenListeners) {
              cb(isFullscreen);
            }
            break;
          case 'onChangePlaybackRate':
            final double rate = (args['rate'] as num).toDouble();
            for (final cb in _playbackRateListeners) {
              cb(rate);
            }
            break;
          case 'onChangeStatus':
            final String statusStr = args['status'] as String;
            final status = playerStatusFromString(statusStr);
            for (final cb in _statusListeners) {
              cb(status);
            }
            break;
          case 'onProgressUpdate':
            final double percent = (args['progressPercent'] as num).toDouble();
            for (final cb in _progressListeners) {
              cb(percent);
            }
            break;
        }
      }
    });
    _initialized = true;
  }

  static void ensureInitialized() {
    _ensureInitialized();
  }

  static void listenOnTapFullscreen(void Function(bool isFullscreen) cb) {
    _ensureInitialized();
    _fullscreenListeners.add(cb);
  }

  static void listenOnChangePlaybackRate(void Function(double rate) cb) {
    _ensureInitialized();
    _playbackRateListeners.add(cb);
  }

  static void listenOnChangeStatus(void Function(PlayerStatus status) cb) {
    _ensureInitialized();
    _statusListeners.add(cb);
  }

  static void listenOnProgressUpdate(void Function(double percent) cb) {
    _ensureInitialized();
    _progressListeners.add(cb);
  }

  /// Удалить слушатель полноэкранного режима
  static void removeOnTapFullscreen(void Function(bool isFullscreen) cb) {
    _fullscreenListeners.remove(cb);
  }

  /// Удалить слушатель изменения скорости
  static void removeOnChangePlaybackRate(void Function(double rate) cb) {
    _playbackRateListeners.remove(cb);
  }

  /// Удалить слушатель изменения статуса
  static void removeOnChangeStatus(void Function(PlayerStatus status) cb) {
    _statusListeners.remove(cb);
  }

  /// Удалить слушатель прогресса
  static void removeOnProgressUpdate(void Function(double percent) cb) {
    _progressListeners.remove(cb);
  }

  // Следующие геттеры только для тестов
  static List<void Function(bool)> get testFullscreenListeners =>
      _fullscreenListeners;

  static List<void Function(double)> get testPlaybackRateListeners =>
      _playbackRateListeners;

  static List<void Function(PlayerStatus)> get testStatusListeners =>
      _statusListeners;

  static List<void Function(double)> get testProgressListeners =>
      _progressListeners;

  // Для тестов: подмена eventStream
  static set testEventStream(Stream<dynamic> s) {
    _eventStream = s;
    _initialized = true;
    _eventStream!.listen((event) {
      if (event is Map) {
        final method = event['method'];
        final args = event['args'] ?? {};
        switch (method) {
          case 'onTapFullscreen':
            final bool isFullscreen = args['isFullscreen'] == true;
            for (final cb in _fullscreenListeners) {
              cb(isFullscreen);
            }
            break;
          case 'onChangePlaybackRate':
            final double rate = (args['rate'] as num).toDouble();
            for (final cb in _playbackRateListeners) {
              cb(rate);
            }
            break;
          case 'onChangeStatus':
            final String statusStr = args['status'] as String;
            final status = playerStatusFromString(statusStr);
            for (final cb in _statusListeners) {
              cb(status);
            }
            break;
          case 'onProgressUpdate':
            final double percent = (args['progressPercent'] as num).toDouble();
            for (final cb in _progressListeners) {
              cb(percent);
            }
            break;
        }
      }
    });
  }
}
