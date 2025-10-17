# Инструкции по настройке и запуску

## Предварительные требования

1. **Flutter SDK** (версия >= 1.17.0)
2. **Android Studio** или **VS Code** с Flutter расширениями
3. **Android SDK** (API Level >= 21)
4. **Kotlin** (версия >= 1.9.0)

## Установка зависимостей

### 1. Установка зависимостей библиотеки

```bash
flutter pub get
```

### 2. Установка зависимостей примера

```bash
cd example
flutter pub get
```

## Запуск примера

### 1. Подключение Android устройства или эмулятора

Убедитесь, что у вас подключено Android устройство или запущен эмулятор:

```bash
flutter devices
```

### 2. Запуск примера приложения

```bash
cd example
flutter run
```

## Тестирование функциональности

После запуска примера вы увидите:

1. **Автозапуск видео** - видео с ID `sEsxJQ7Hi4QLWwbmZEFfgz` автоматически начнет воспроизводиться
2. **Элементы управления** - кнопки воспроизведения/паузы, перемотки
3. **Полноэкранный режим** - кнопка для перехода в полноэкранный режим
4. **Прогресс-бар** - слайдер для перемотки видео
5. **Информация о видео** - отображение текущей позиции и длительности

## Использование в своем проекте

### 1. Добавление зависимости

В `pubspec.yaml` вашего проекта:

```yaml
dependencies:
  flutter_kinescope_player:
    path: ../flutter_kinescope_player  # Для локальной разработки
    # или
    # git: https://github.com/your-username/flutter_kinescope_player.git
```

### 2. Импорт библиотеки

```dart
import 'package:flutter_kinescope_player/flutter_kinescope_player.dart';
```

### 3. Использование виджета

```dart
KinescopePlayerWidget(
  videoId: 'YOUR_VIDEO_ID',
  config: const KinescopePlayerConfig(
    autoPlay: true,
    showControls: true,
    enableFullscreen: true,
  ),
)
```

## Возможные проблемы и решения

### 1. Ошибка компиляции Android

Если возникают ошибки компиляции Android:

```bash
cd example/android
./gradlew clean
cd ../..
flutter clean
flutter pub get
```

### 2. Проблемы с зависимостями

Если есть проблемы с зависимостями Kinescope SDK:

```bash
cd example/android
./gradlew --refresh-dependencies
```

### 3. Проблемы с эмулятором

Если видео не воспроизводится в эмуляторе:
- Используйте физическое устройство
- Убедитесь, что эмулятор поддерживает аппаратное ускорение

## Структура проекта

```
flutter_kinescope_player/
├── lib/                          # Dart код библиотеки
│   ├── src/                      # Исходный код
│   └── flutter_kinescope_player.dart  # Основной файл экспорта
├── android/                      # Android нативный код
│   └── src/main/kotlin/
├── example/                      # Пример приложения
│   ├── lib/main.dart            # Основной код примера
│   └── android/                 # Android конфигурация примера
├── test/                        # Тесты
├── pubspec.yaml                 # Зависимости библиотеки
└── README.md                    # Документация
```

## Разработка

### Добавление новых функций

1. Обновите платформенный интерфейс в `lib/src/flutter_kinescope_player_platform_interface.dart`
2. Реализуйте в `lib/src/flutter_kinescope_player_method_channel.dart`
3. Добавьте Android реализацию в `android/src/main/kotlin/`
4. Обновите пример в `example/lib/main.dart`
5. Обновите документацию в `README.md`

### Тестирование

```bash
flutter test
```

## Лицензия

MIT License - см. файл `LICENSE` для подробностей. 