import 'package:flutter/material.dart';
import 'package:flutter_kinescope_player/flutter_kinescope_player.dart';

const videoId = '0csDNhDGPtgsZtLUThYt9G'; // Live видео

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kinescope Player Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const KinescopePlayerPage(),
    );
  }
}

class KinescopePlayerPage extends StatefulWidget {
  const KinescopePlayerPage({super.key});

  @override
  State<KinescopePlayerPage> createState() => _KinescopePlayerPageState();
}

class _KinescopePlayerPageState extends State<KinescopePlayerPage> {
  late PlayerController _controller;

  double _playbackRate = 1.0;
  double _positionPercent = 0.0;
  PlayerStatus? _playerStatus;

  @override
  void initState() {
    super.initState();
    _controller = PlayerController(
      videoId: videoId,
      config: PlayerConfig(
        autoPlay: true,
        // isLive: true,
        referer: 'https://nd.umschool.net/'
      ),
    );
    _controller.setOnChangePlaybackRate((rate) {
      setState(() {
        _playbackRate = rate;
      });
    });
    _controller.setOnChangeStatus((status) {
      setState(() {
        _playerStatus = status;
      });
    });
    _controller.setOnChangeFullscreen((isFullscreen) {
      print('setOnChangeFullscreen FULLSCREEN: $isFullscreen');
    });
    _controller.setOnProgressUpdate((percent) {
      setState(() {
        _positionPercent = percent;
      });
    });
  }

  @override
  void dispose() {
    _controller.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Kinescope Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            PlayerWidget(controller: _controller),
            TextButton(
              onPressed: () async {
                try {
                  await _controller.play();
                } catch (e) {
                  print('Error in play: $e');
                }
              },
              child: const Text("PLAY"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _controller.pause();
                } catch (e) {
                  print('Error in pause: $e');
                }
              },
              child: const Text("PAUSE"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _controller.stop();
                } catch (e) {
                  print('Error in stop: $e');
                }
              },
              child: const Text("STOP"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Установить позицию ровно на 10 секунд
                  await _controller.seekTo(10);
                } catch (e) {
                  print('Error in seekTo: $e');
                }
              },
              child: const Text("SEEK TO 10s"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final isPaused = _controller.isPaused;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('isPaused: $isPaused')),
                  );
                } catch (e) {
                  print('Error in isPaused: $e');
                }
              },
              child: const Text("isPaused?"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final rate = await _controller.getPlaybackRate();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Playback rate: '
                        '$rate\u00a0x\u001b',
                      ),
                    ),
                  );
                } catch (e) {
                  print('Error in getPlaybackRate: $e');
                }
              },
              child: const Text("GET PLAYBACK RATE"),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  children: [
                    Text('Is Playing: ${_controller.isPlaying}\u001b'),
                    Text('Is Paused: ${_controller.isPaused}\u001b'),
                    if (_controller.error != null)
                      Text(
                        'Error: ${_controller.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    Text('Position percent: $_positionPercent'),
                    Text('Playback Rate: $_playbackRate'),
                    Text('Status: ${_playerStatus ?? "-"}'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final duration = await _controller.getDuration();
                        print('Полная длительность видео: $duration секунд');
                      },
                      child: const Text('Получить длительность'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}



