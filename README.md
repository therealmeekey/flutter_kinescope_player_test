<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->


# Flutter Kinescope Player
[![Test Coverage](https://img.shields.io/badge/test%20coverage-79.2%25-brightgreen)](https://github.com/therealmeekey/flutter_kinescope_player/)

Flutter-плагин для интеграции с [Kinescope SDK](https://github.com/kinescope/kotlin-kinescope-player) для воспроизведения видео в Flutter-приложениях.

## Возможности

- ✅ Воспроизведение видео из Kinescope
- ✅ Автозапуск видео
- ✅ Полноэкранный режим
- ✅ Настраиваемые элементы управления
- ✅ Поддержка Live трансляций
- ✅ Управление воспроизведением (play/pause/seek)
- ✅ Отображение постеров
- ✅ Аналитика событий

## Установка

Добавьте зависимость в ваш `pubspec.yaml`:

```yaml
dependencies:
  flutter_kinescope_player: ^0.0.1
```

## Использование

### Базовое использование

```dart
import 'package:flutter_kinescope_player/flutter_kinescope_player.dart';

final controller = PlayerController(
  videoId: 'sEsxJQ7Hi4QLWwbmZEFfgz',
  config: const PlayerConfig(
    autoPlay: true,
    showFullscreenButton: true,
  ),
);

PlayerWidget(
  controller: controller,
);
```

### Использование в StatefulWidget

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final PlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PlayerController(
      videoId: 'sEsxJQ7Hi4QLWwbmZEFfgz',
      config: const PlayerConfig(autoPlay: true),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlayerWidget(controller: _controller),
        Row(
          children: [
            ElevatedButton(
              onPressed: _controller.isPlaying ? _controller.pause : _controller.play,
              child: Text(_controller.isPlaying ? 'Пауза' : 'Воспроизвести'),
            ),
            ElevatedButton(
              onPressed: () => _controller.seekTo(0),
              child: Text('Перемотать'),
            ),
          ],
        ),
      ],
    );
  }
}
```

### Конфигурация плеера

```dart
final config = PlayerConfig(
  autoPlay: true,
  showFullscreenButton: true,
  showOptionsButton: true,
  showSubtitlesButton: false,
  showSeekBar: true,
  showDuration: true,
  showAttachments: false,
  referer: 'https://kinescope.io/',
  useCustomFullscreen: false,
  startTime: 0,
);
```

#### Параметры PlayerConfig

| Параметр               | Тип     | По умолчанию           | Описание                                 |
|------------------------|---------|------------------------|------------------------------------------|
| `autoPlay`             | bool    | false                  | Автоматически запускать видео            |
| `showFullscreenButton` | bool    | true                   | Показывать кнопку полноэкранного режима  |
| `showOptionsButton`    | bool    | true                   | Показывать кнопку настроек               |
| `showSubtitlesButton`  | bool    | false                  | Показывать кнопку субтитров              |
| `showSeekBar`          | bool    | true                   | Показывать полосу прогресса              |
| `showDuration`         | bool    | true                   | Показывать длительность                  |
| `showAttachments`      | bool    | false                  | Показывать вложения                      |
| `referer`              | String  | 'https://kinescope.io/'| Referer для запросов                     |
| `useCustomFullscreen`  | bool    | false                  | Кастомный fullscreen (без нативного перехода) |
| `startTime`            | int     | 0                      | Время старта воспроизведения (секунды)   |

## Методы PlayerController

- `play()` — воспроизвести
- `pause()` — пауза
- `seekTo(int position)` — перемотать к позиции (в секундах)
- `setFullscreen(bool fullscreen)` — установить полноэкранный режим
- `stop()` — остановить воспроизведение
- `getCurrentPosition()` — получить текущую позицию (Future<int>)
- `getDuration()` — получить длительность видео (Future<int>)
- `getPlaybackRate()` — получить текущую скорость (Future<double>)
- `dispose()` — очистить ресурсы

### Свойства PlayerController

- `isPlaying` — играет ли видео
- `isLoading` — загружается ли видео
- `error` — ошибка

## Пример запуска

```bash
cd example
flutter run
```

## Структура проекта

```
flutter_kinescope_player/
├── lib/
│   ├── src/
│   │   ├── player_widget.dart
│   │   ├── player_controller.dart
│   │   ├── player_config.dart
│   │   ├── kinescope_video.dart
│   │   └── ...
│   └── flutter_kinescope_player.dart
├── android/
│   └── src/main/kotlin/com/example/flutter_kinescope_player/
├── example/
│   ├── lib/main.dart
│   └── android/
└── README.md
```

## Требования

- Flutter >= 1.17.0
- Android API Level >= 21
- Kotlin >= 1.9.0

## Зависимости

- [kotlin-kinescope-player](https://github.com/kinescope/kotlin-kinescope-player) — нативный Android SDK
- plugin_platform_interface — для создания платформенного интерфейса

## Лицензия

MIT License
