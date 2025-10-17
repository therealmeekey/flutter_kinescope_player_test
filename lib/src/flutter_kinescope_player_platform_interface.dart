import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_kinescope_player_method_channel.dart';

abstract class FlutterKinescopePlayerPlatform extends PlatformInterface {
  /// Constructs a FlutterKinescopePlayerPlatform.
  FlutterKinescopePlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterKinescopePlayerPlatform _instance =
      MethodChannelFlutterKinescopePlayer();

  /// The default instance of [FlutterKinescopePlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterKinescopePlayer].
  static FlutterKinescopePlayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterKinescopePlayerPlatform] when
  /// they register themselves.
  static set instance(FlutterKinescopePlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> initializePlayer(int viewId) {
    throw UnimplementedError('initializePlayer() has not been implemented.');
  }

  Future<Map<String, dynamic>> loadVideo(
    int viewId,
    String videoId, [
    Map<String, dynamic>? config,
  ]) {
    throw UnimplementedError('loadVideo() has not been implemented.');
  }

  Future<void> play(int viewId) {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> pause(int viewId) {
    throw UnimplementedError('pause() has not been implemented.');
  }

  Future<void> seekTo(int viewId, int position) {
    throw UnimplementedError('seekTo() has not been implemented.');
  }

  Future<void> setFullscreen(int viewId, bool fullscreen) {
    throw UnimplementedError('setFullscreen() has not been implemented.');
  }

  Future<void> dispose(int viewId) {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  Future<void> stop(int viewId) {
    throw UnimplementedError('stop() has not been implemented.');
  }

  Future<double> getPlaybackRate(int viewId) {
    throw UnimplementedError('getPlaybackRate() has not been implemented.');
  }

  Future<int> getCurrentPosition(int viewId) {
    throw UnimplementedError('getCurrentPosition() has not been implemented.');
  }

  Future<int> getDuration(int viewId) {
    throw UnimplementedError('getDuration() has not been implemented.');
  }

  Future<void> setLiveState(int viewId, bool isLive) {
    throw UnimplementedError('setLiveState() has not been implemented.');
  }

  Future<void> showLiveStartDate(int viewId, String startDate) {
    throw UnimplementedError('showLiveStartDate() has not been implemented.');
  }
}
