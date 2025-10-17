import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'player_controller.dart';

/// Flutter виджет для отображения плеера Kinescope
class PlayerWidget extends StatefulWidget {
  final PlayerController controller;
  final double aspectRatio;

  const PlayerWidget({
    super.key,
    required this.controller,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget>
    with WidgetsBindingObserver {
  late PlayerController _controller;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = widget.controller;
  }

  Future<void> _initializePlayer() async {
    try {
      await _controller.initialize();
      final startTime = _controller.config?.startTime ?? 0;
      if (startTime > 0) {
        await _controller.seekTo(startTime);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastError = 'Ошибка инициализации: $e';
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _controller.pause();
    }
    if (state == AppLifecycleState.resumed) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.deactivate();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.error != null || _lastError != null) {
            return _buildErrorWidget();
          }
          return _buildPlayerWidget();
        },
      ),
    );
  }

  Widget _buildPlayerWidget() {
    return AndroidView(
      viewType: 'flutter_kinescope_player_view',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: {'config': _controller.config?.toMap()},
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  Widget _buildErrorWidget() {
    final errorMessage =
        _controller.error ?? _lastError ?? 'Неизвестная ошибка';

    return ListView(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Ошибка загрузки видео',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _lastError = null;
            });
            _initializePlayer();
          },
          child: const Text('Повторить'),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Video ID: ${_controller.videoId}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _onPlatformViewCreated(int id) {
    _controller.setViewId(id);
    _initializePlayer();
  }
}
