import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_kinescope_player_platform_interface.dart';

/// An implementation of [FlutterKinescopePlayerPlatform] that uses method channels.
class MethodChannelFlutterKinescopePlayer
    extends FlutterKinescopePlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_kinescope_player');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> initializePlayer(int viewId) async {
    await methodChannel.invokeMethod('initializePlayer', {'viewId': viewId});
  }

  @override
  Future<Map<String, dynamic>> loadVideo(
    int viewId,
    String videoId, [
    Map<String, dynamic>? config,
  ]) async {
    final params = {'viewId': viewId, 'videoId': videoId};
    if (config != null) {
      params['config'] = config;
    }
    final result = await methodChannel.invokeMethod('loadVideo', params);
    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }
    return {};
  }

  @override
  Future<void> play(int viewId) async {
    await methodChannel.invokeMethod('play', {'viewId': viewId});
  }

  @override
  Future<void> pause(int viewId) async {
    await methodChannel.invokeMethod('pause', {'viewId': viewId});
  }

  @override
  Future<void> seekTo(int viewId, int position) async {
    await methodChannel.invokeMethod('seekTo', {
      'viewId': viewId,
      'position': position,
    });
  }

  @override
  Future<void> setFullscreen(int viewId, bool fullscreen) async {
    await methodChannel.invokeMethod('setFullscreen', {
      'viewId': viewId,
      'fullscreen': fullscreen,
    });
  }

  @override
  Future<void> dispose(int viewId) async {
    await methodChannel.invokeMethod('dispose', {'viewId': viewId});
  }

  @override
  Future<void> stop(int viewId) async {
    await methodChannel.invokeMethod('stop', {'viewId': viewId});
  }

  @override
  Future<double> getPlaybackRate(int viewId) async {
    final rate = await methodChannel.invokeMethod('getPlaybackRate', {
      'viewId': viewId,
    });
    if (rate is double) return rate;
    if (rate is int) return rate.toDouble();
    if (rate is String) return double.tryParse(rate) ?? 1.0;
    return 1.0;
  }

  @override
  Future<int> getCurrentPosition(int viewId) async {
    final position = await methodChannel.invokeMethod<int>(
      'getCurrentPosition',
      {'viewId': viewId},
    );
    return position ?? 0;
  }

  @override
  Future<int> getDuration(int viewId) async {
    final duration = await methodChannel.invokeMethod<int>('getDuration', {
      'viewId': viewId,
    });
    return duration ?? 0;
  }

  @override
  Future<void> setLiveState(int viewId, bool isLive) async {
    await methodChannel.invokeMethod('setLiveState', {
      'viewId': viewId,
      'isLive': isLive,
    });
  }

  @override
  Future<void> showLiveStartDate(int viewId, String startDate) async {
    await methodChannel.invokeMethod('showLiveStartDate', {
      'viewId': viewId,
      'startDate': startDate,
    });
  }
}
