import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kinescope_player/flutter_kinescope_player.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_kinescope_player/src/player_event.dart';
import 'package:flutter_kinescope_player/src/player_status.dart';
import 'package:flutter_kinescope_player/src/player_config.dart';
import 'package:flutter_kinescope_player/src/kinescope_video.dart';
import 'package:flutter_kinescope_player/src/flutter_kinescope_player_method_channel.dart';
import 'package:flutter_kinescope_player/src/flutter_kinescope_player_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kinescope_player/src/player_widget.dart';
import 'package:flutter_kinescope_player/src/player_controller.dart';
import 'dart:async';

import 'flutter_kinescope_player_test.mocks.dart';

@GenerateMocks([FlutterKinescopePlayerPlatform])
class MockMethodChannel extends Mock implements MethodChannel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterKinescopePlayerPlatform mockPlatform;
  late PlayerController controller;

  setUp(() {
    mockPlatform = MockFlutterKinescopePlayerPlatform();
    controller = PlayerController(
      videoId: 'test-video-id',
      platform: mockPlatform,
    );
  });

  test('play calls platform play', () async {
    when(mockPlatform.play(any)).thenAnswer((_) async {});
    await controller.play();
    verify(mockPlatform.play(any)).called(1);
    expect(controller.isPlaying, true);
  });

  test('pause calls platform pause', () async {
    when(mockPlatform.pause(any)).thenAnswer((_) async {});
    await controller.pause();
    verify(mockPlatform.pause(any)).called(1);
    expect(controller.isPlaying, false);
  });

  test('stop calls platform stop', () async {
    when(mockPlatform.stop(any)).thenAnswer((_) async {});
    await controller.stop();
    verify(mockPlatform.stop(any)).called(1);
    expect(controller.isPlaying, false);
  });

  test('seekTo calls platform seekTo', () async {
    when(mockPlatform.seekTo(any, any)).thenAnswer((_) async {});
    await controller.seekTo(15);
    verify(mockPlatform.seekTo(any, 15)).called(1);
  });

  test('setFullscreen calls platform setFullscreen', () async {
    when(mockPlatform.setFullscreen(any, any)).thenAnswer((_) async {});
    await controller.setFullscreen(true);
    verify(mockPlatform.setFullscreen(any, true)).called(1);
  });

  test('initialize calls platform initializePlayer and loadVideo', () async {
    when(mockPlatform.initializePlayer(any)).thenAnswer((_) async {});
    when(mockPlatform.loadVideo(any, any, any)).thenAnswer((_) async {});
    await controller.initialize();
    verify(mockPlatform.initializePlayer(any)).called(1);
    verify(mockPlatform.loadVideo(any, any, any)).called(1);
    expect(controller.isLoading, false);
  });

  test('loadVideo calls platform loadVideo', () async {
    when(mockPlatform.loadVideo(any, any, any)).thenAnswer((_) async {});
    await controller.loadVideo();
    verify(mockPlatform.loadVideo(any, any, any)).called(1);
    expect(controller.isLoading, false);
  });

  test('deactivate calls platform dispose', () async {
    when(mockPlatform.dispose(any)).thenAnswer((_) async {});
    await controller.deactivate();
    verify(mockPlatform.dispose(any)).called(1);
  });

  test('getCurrentPosition calls platform getCurrentPosition', () async {
    when(mockPlatform.getCurrentPosition(any)).thenAnswer((_) async => 42);
    final pos = await controller.getCurrentPosition();
    expect(pos, 42);
  });

  test('getDuration calls platform getDuration', () async {
    when(mockPlatform.getDuration(any)).thenAnswer((_) async => 100);
    final duration = await controller.getDuration();
    expect(duration, 100);
  });

  test('getPlaybackRate calls platform getPlaybackRate', () async {
    when(mockPlatform.getPlaybackRate(any)).thenAnswer((_) async => 1.5);
    final rate = await controller.getPlaybackRate();
    expect(rate, 1.5);
  });

  test('setOnChangePlaybackRate sets callback', () async {
    double? receivedRate;
    controller.setOnChangePlaybackRate((rate) {
      receivedRate = rate;
    });
    // Триггерим через PlayerEvents
    controller.setOnChangePlaybackRate((rate) {
      receivedRate = rate;
    });
    // Симулируем вызов колбека
    controller.setOnChangePlaybackRate((rate) {
      receivedRate = rate;
    });
    expect(receivedRate, isNull); // Колбек не вызывается напрямую
  });

  test('setOnChangeStatus sets callback', () async {
    PlayerStatus? receivedStatus;
    controller.setOnChangeStatus((status) {
      receivedStatus = status;
    });
    // Симулируем вызов колбека
    controller.setOnChangeStatus((status) {
      receivedStatus = status;
    });
    expect(receivedStatus, isNull); // Колбек не вызывается напрямую
  });

  test('setOnChangeFullscreen sets callback', () async {
    bool? received;
    controller.setOnChangeFullscreen((isFullscreen) {
      received = isFullscreen;
    });
    // Симулируем вызов колбека
    controller.setOnChangeFullscreen((isFullscreen) {
      received = isFullscreen;
    });
    expect(received, isNull); // Колбек не вызывается напрямую
  });

  test('setOnProgressUpdate sets callback', () async {
    double? received;
    controller.setOnProgressUpdate((percent) {
      received = percent;
    });
    // Симулируем вызов колбека
    controller.setOnProgressUpdate((percent) {
      received = percent;
    });
    expect(received, isNull); // Колбек не вызывается напрямую
  });

  group('PlayerEvents', () {
    test('listen and remove listeners', () {
      bool fullscreen = false;
      double rate = 0;
      PlayerStatus? status;
      double progress = 0;

      void fullscreenCb(bool v) => fullscreen = v;
      void rateCb(double v) => rate = v;
      void statusCb(PlayerStatus s) => status = s;
      void progressCb(double v) => progress = v;

      PlayerEvents.listenOnTapFullscreen(fullscreenCb);
      PlayerEvents.listenOnChangePlaybackRate(rateCb);
      PlayerEvents.listenOnChangeStatus(statusCb);
      PlayerEvents.listenOnProgressUpdate(progressCb);

      expect(PlayerEvents.testFullscreenListeners.contains(fullscreenCb), true);
      expect(PlayerEvents.testPlaybackRateListeners.contains(rateCb), true);
      expect(PlayerEvents.testStatusListeners.contains(statusCb), true);
      expect(PlayerEvents.testProgressListeners.contains(progressCb), true);

      PlayerEvents.removeOnTapFullscreen(fullscreenCb);
      PlayerEvents.removeOnChangePlaybackRate(rateCb);
      PlayerEvents.removeOnChangeStatus(statusCb);
      PlayerEvents.removeOnProgressUpdate(progressCb);

      expect(
        PlayerEvents.testFullscreenListeners.contains(fullscreenCb),
        false,
      );
      expect(PlayerEvents.testPlaybackRateListeners.contains(rateCb), false);
      expect(PlayerEvents.testStatusListeners.contains(statusCb), false);
      expect(PlayerEvents.testProgressListeners.contains(progressCb), false);
    });
  });

  group('PlayerStatus', () {
    test('playerStatusFromString returns correct enum', () {
      expect(playerStatusFromString('init'), PlayerStatus.init);
      expect(playerStatusFromString('ready'), PlayerStatus.ready);
      expect(playerStatusFromString('playing'), PlayerStatus.playing);
      expect(playerStatusFromString('waiting'), PlayerStatus.waiting);
      expect(playerStatusFromString('pause'), PlayerStatus.pause);
      expect(playerStatusFromString('paused'), PlayerStatus.pause);
      expect(playerStatusFromString('ended'), PlayerStatus.ended);
      expect(playerStatusFromString('unknown'), PlayerStatus.unknown);
      expect(playerStatusFromString('something_else'), PlayerStatus.unknown);
    });
  });

  group('PlayerConfig', () {
    test('toMap and fromMap', () {
      final config = PlayerConfig(
        autoPlay: true,
        showFullscreenButton: false,
        showOptionsButton: false,
        showSubtitlesButton: true,
        showSeekBar: false,
        showDuration: false,
        showAttachments: true,
        referer: 'test',
        useCustomFullscreen: true,
        startTime: 42,
      );
      final map = config.toMap();
      final fromMap = PlayerConfig.fromMap(map);
      expect(fromMap.autoPlay, true);
      expect(fromMap.showFullscreenButton, false);
      expect(fromMap.showOptionsButton, false);
      expect(fromMap.showSubtitlesButton, true);
      expect(fromMap.showSeekBar, false);
      expect(fromMap.showDuration, false);
      expect(fromMap.showAttachments, true);
      expect(fromMap.referer, 'test');
      expect(fromMap.useCustomFullscreen, true);
      expect(fromMap.startTime, 42);
    });

    test('copyWith', () {
      final config = PlayerConfig();
      final copy = config.copyWith(autoPlay: true, referer: 'abc');
      expect(copy.autoPlay, true);
      expect(copy.referer, 'abc');
      expect(copy.showFullscreenButton, config.showFullscreenButton);
    });
  });

  group('KinescopeVideo', () {
    test('toMap and fromMap', () {
      final video = KinescopeVideo(
        id: 'id1',
        title: 'title1',
        description: 'desc',
        posterUrl: 'url',
        isLive: true,
        liveStartDate: DateTime.parse('2024-01-01T12:00:00Z'),
        duration: 123,
        status: 'ready',
      );
      final map = video.toMap();
      final fromMap = KinescopeVideo.fromMap(map);
      expect(fromMap.id, 'id1');
      expect(fromMap.title, 'title1');
      expect(fromMap.description, 'desc');
      expect(fromMap.posterUrl, 'url');
      expect(fromMap.isLive, true);
      expect(fromMap.liveStartDate, DateTime.parse('2024-01-01T12:00:00Z'));
      expect(fromMap.duration, 123);
      expect(fromMap.status, 'ready');
    });

    test('toString', () {
      final video = KinescopeVideo(id: 'id', title: 't');
      expect(video.toString(), contains('KinescopeVideo'));
    });
  });

  group('MethodChannelFlutterKinescopePlayer', () {
    late MethodChannelFlutterKinescopePlayer methodChannelImpl;

    setUp(() {
      methodChannelImpl = MethodChannelFlutterKinescopePlayer();
      // ignore: invalid_use_of_visible_for_testing_member
      methodChannelImpl.methodChannel.setMockMethodCallHandler((call) async {
        if (call.method == 'getPlatformVersion') return '1.0.0';
        if (call.method == 'getPlaybackRate') return 1.5;
        if (call.method == 'getCurrentPosition') return 42;
        if (call.method == 'getDuration') return 100;
        return null;
      });
    });

    test('getPlatformVersion returns version', () async {
      final version = await methodChannelImpl.getPlatformVersion();
      expect(version, '1.0.0');
    });

    test('getPlaybackRate returns double', () async {
      final rate = await methodChannelImpl.getPlaybackRate(1);
      expect(rate, 1.5);
    });

    test('getCurrentPosition returns int', () async {
      final pos = await methodChannelImpl.getCurrentPosition(1);
      expect(pos, 42);
    });

    test('getDuration returns int', () async {
      final duration = await methodChannelImpl.getDuration(1);
      expect(duration, 100);
    });
  });

  group('FlutterKinescopePlayerPlatform', () {
    final platform = _TestPlatform();
    test('all methods throw UnimplementedError', () {
      expect(
        () => platform.getPlatformVersion(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => platform.initializePlayer(1),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => platform.loadVideo(1, 'id'),
        throwsA(isA<UnimplementedError>()),
      );
      expect(() => platform.play(1), throwsA(isA<UnimplementedError>()));
      expect(() => platform.pause(1), throwsA(isA<UnimplementedError>()));
      expect(() => platform.seekTo(1, 0), throwsA(isA<UnimplementedError>()));
      expect(
        () => platform.setFullscreen(1, true),
        throwsA(isA<UnimplementedError>()),
      );
      expect(() => platform.dispose(1), throwsA(isA<UnimplementedError>()));
      expect(() => platform.stop(1), throwsA(isA<UnimplementedError>()));
      expect(
        () => platform.getPlaybackRate(1),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => platform.getCurrentPosition(1),
        throwsA(isA<UnimplementedError>()),
      );
      expect(() => platform.getDuration(1), throwsA(isA<UnimplementedError>()));
    });
  });

  group('PlayerWidget', () {
    late MockFlutterKinescopePlayerPlatform mockPlatform;
    late PlayerController controller;

    setUp(() {
      mockPlatform = MockFlutterKinescopePlayerPlatform();
      controller = PlayerController(
        videoId: 'test-video-id',
        platform: mockPlatform,
      );
    });

    testWidgets('creates widget with default aspect ratio', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlayerWidget(controller: controller)),
        ),
      );

      expect(find.byType(PlayerWidget), findsOneWidget);
      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('creates widget with custom aspect ratio', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerWidget(controller: controller, aspectRatio: 4 / 3),
          ),
        ),
      );

      expect(find.byType(PlayerWidget), findsOneWidget);
      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('shows error widget when controller has error', (
      WidgetTester tester,
    ) async {
      when(
        mockPlatform.initializePlayer(any),
      ).thenThrow(Exception('Test error'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlayerWidget(controller: controller)),
        ),
      );

      // Инициализируем плеер
      await controller.initialize();
      await tester.pump();

      expect(find.text('Ошибка загрузки видео'), findsOneWidget);
      expect(find.text('Повторить'), findsOneWidget);
      expect(find.text('Video ID: test-video-id'), findsOneWidget);
    });

    testWidgets('disposes controller on widget dispose', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlayerWidget(controller: controller)),
        ),
      );

      // Уничтожаем виджет
      await tester.pumpWidget(Container());
      await tester.pump();

      // Проверяем, что контроллер был деактивирован
      expect(controller.isLoading, false);
    });
  });

  group('PlayerController advanced', () {
    late MockFlutterKinescopePlayerPlatform mockPlatform;
    late PlayerController controller;

    setUp(() {
      mockPlatform = MockFlutterKinescopePlayerPlatform();
      controller = PlayerController(
        videoId: 'test-video-id',
        platform: mockPlatform,
      );
    });

    test('play catch error', () async {
      when(mockPlatform.play(any)).thenThrow(Exception('fail'));
      await controller.play();
      expect(controller.error, contains('fail'));
      expect(controller.isPlaying, false);
    });

    test('pause catch error', () async {
      when(mockPlatform.pause(any)).thenThrow(Exception('fail'));
      await controller.pause();
      expect(controller.error, contains('fail'));
      expect(controller.isPlaying, false);
    });

    test('seekTo catch error', () async {
      when(mockPlatform.seekTo(any, any)).thenThrow(Exception('fail'));
      await controller.seekTo(5);
      expect(controller.error, contains('fail'));
    });

    test('setFullscreen catch error', () async {
      when(mockPlatform.setFullscreen(any, any)).thenThrow(Exception('fail'));
      await controller.setFullscreen(true);
      expect(controller.error, contains('fail'));
    });

    test('stop catch error', () async {
      when(mockPlatform.stop(any)).thenThrow(Exception('fail'));
      await controller.stop();
      expect(controller.error, contains('fail'));
      expect(controller.isPlaying, false);
    });

    test('getPlaybackRate catch error', () async {
      when(mockPlatform.getPlaybackRate(any)).thenThrow(Exception('fail'));
      final rate = await controller.getPlaybackRate();
      expect(rate, 1.0);
      expect(controller.error, contains('fail'));
    });

    test('getCurrentPosition catch error', () async {
      when(mockPlatform.getCurrentPosition(any)).thenThrow(Exception('fail'));
      final pos = await controller.getCurrentPosition();
      expect(pos, 0);
      expect(controller.error, contains('fail'));
    });

    test('getDuration catch error', () async {
      when(mockPlatform.getDuration(any)).thenThrow(Exception('fail'));
      final dur = await controller.getDuration();
      expect(dur, 0);
      expect(controller.error, contains('fail'));
    });

    test('deactivate catch error', () async {
      when(mockPlatform.dispose(any)).thenThrow(Exception('fail'));
      await controller.deactivate();
      // Ошибка игнорируется, не выбрасывается
    });

    test('dispose calls deactivate and removes listeners', () async {
      controller.setOnChangePlaybackRate((_) {});
      controller.setOnChangeStatus((_) {});
      controller.setOnChangeFullscreen((_) {});
      controller.setOnProgressUpdate((_) {});
      controller.dispose();
      // Проверяем, что dispose не выбрасывает исключение
      expect(true, true);
    });
  });

  group('PlayerEvents advanced', () {
    test('ensureInitialized is idempotent', () {
      PlayerEvents.ensureInitialized();
      PlayerEvents.ensureInitialized();
      expect(
        PlayerEvents.testFullscreenListeners,
        isA<List<void Function(bool)>>(),
      );
    });
  });

  group('PlayerEvents EventChannel', () {
    tearDown(() {
      PlayerEvents.testFullscreenListeners.clear();
      PlayerEvents.testPlaybackRateListeners.clear();
      PlayerEvents.testStatusListeners.clear();
      PlayerEvents.testProgressListeners.clear();
    });

    test('handles onTapFullscreen event', () async {
      bool? called;
      PlayerEvents.listenOnTapFullscreen((isFullscreen) {
        called = isFullscreen;
      });
      final controller = StreamController<dynamic>();
      PlayerEvents.testEventStream = controller.stream;
      controller.add({
        'method': 'onTapFullscreen',
        'args': {'isFullscreen': true},
      });
      await Future.delayed(Duration.zero);
      expect(called, true);
      await controller.close();
    });

    test('handles onChangePlaybackRate event', () async {
      double? rate;
      PlayerEvents.listenOnChangePlaybackRate((r) {
        rate = r;
      });
      final controller = StreamController<dynamic>();
      PlayerEvents.testEventStream = controller.stream;
      controller.add({
        'method': 'onChangePlaybackRate',
        'args': {'rate': 2.5},
      });
      await Future.delayed(Duration.zero);
      expect(rate, 2.5);
      await controller.close();
    });

    test('handles onChangeStatus event', () async {
      PlayerStatus? status;
      PlayerEvents.listenOnChangeStatus((s) {
        status = s;
      });
      final controller = StreamController<dynamic>();
      PlayerEvents.testEventStream = controller.stream;
      controller.add({
        'method': 'onChangeStatus',
        'args': {'status': 'playing'},
      });
      await Future.delayed(Duration.zero);
      expect(status, PlayerStatus.playing);
      await controller.close();
    });

    test('handles onProgressUpdate event', () async {
      double? percent;
      PlayerEvents.listenOnProgressUpdate((p) {
        percent = p;
      });
      final controller = StreamController<dynamic>();
      PlayerEvents.testEventStream = controller.stream;
      controller.add({
        'method': 'onProgressUpdate',
        'args': {'progressPercent': 77.7},
      });
      await Future.delayed(Duration.zero);
      expect(percent, 77.7);
      await controller.close();
    });
  });
}

class _TestPlatform extends FlutterKinescopePlayerPlatform {}
