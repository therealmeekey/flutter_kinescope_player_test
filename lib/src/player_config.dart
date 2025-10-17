/// Конфигурация для плеера Kinescope
class PlayerConfig {
  /// Автоматическое воспроизведение
  final bool autoPlay;

  /// Показывать ли кнопку полноэкранного режима
  final bool showFullscreenButton;

  /// Показывать ли кнопку настроек
  final bool showOptionsButton;

  /// Показывать ли кнопку субтитров
  final bool showSubtitlesButton;

  /// Показывать ли полосу прогресса
  final bool showSeekBar;

  /// Показывать ли длительность
  final bool showDuration;

  /// Показывать ли вложения
  final bool showAttachments;

  /// Показывать ли название видео
  final bool showTitle;

  /// Referer для запросов
  final String referer;

  /// Использовать ли кастомный fullscreen (без нативного перехода)
  final bool useCustomFullscreen;

  /// Время старта воспроизведения в секундах
  final int? startTime;

  /// Прямая трансляция
  final bool isLive;

  const PlayerConfig({
    this.autoPlay = false,
    this.showFullscreenButton = true,
    this.showOptionsButton = true,
    this.showSubtitlesButton = false,
    this.showSeekBar = true,
    this.showDuration = true,
    this.showAttachments = false,
    this.showTitle = true,
    this.referer = 'https://kinescope.io/',
    this.useCustomFullscreen = false,
    this.startTime = 0,
    this.isLive = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'autoPlay': autoPlay,
      'showFullscreenButton': showFullscreenButton,
      'showOptionsButton': showOptionsButton,
      'showSubtitlesButton': showSubtitlesButton,
      'showSeekBar': showSeekBar,
      'showDuration': showDuration,
      'showAttachments': showAttachments,
      'showTitle': showTitle,
      'referer': referer,
      'useCustomFullscreen': useCustomFullscreen,
      'startTime': startTime,
      'isLive': isLive,
    };
  }

  factory PlayerConfig.fromMap(Map<String, dynamic> map) {
    return PlayerConfig(
      autoPlay: map['autoPlay'] ?? false,
      showFullscreenButton: map['showFullscreenButton'] ?? true,
      showOptionsButton: map['showOptionsButton'] ?? true,
      showSubtitlesButton: map['showSubtitlesButton'] ?? false,
      showSeekBar: map['showSeekBar'] ?? true,
      showDuration: map['showDuration'] ?? true,
      showAttachments: map['showAttachments'] ?? false,
      showTitle: map['showTitle'] ?? true,
      referer: map['referer'] ?? 'https://kinescope.io/',
      useCustomFullscreen: map['useCustomFullscreen'] ?? false,
      startTime: map['startTime'] ?? 0,
       isLive: map['isLive'] ?? false,
    );
  }

  PlayerConfig copyWith({
    bool? autoPlay,
    bool? showFullscreenButton,
    bool? showOptionsButton,
    bool? showSubtitlesButton,
    bool? showSeekBar,
    bool? showDuration,
    bool? showAttachments,
    bool? showTitle,
    String? referer,
    Map<String, String>? drmHeaders,
    bool? useCustomFullscreen,
    int? startTime,
    bool? isLive,
  }) {
    return PlayerConfig(
      autoPlay: autoPlay ?? this.autoPlay,
      showFullscreenButton: showFullscreenButton ?? this.showFullscreenButton,
      showOptionsButton: showOptionsButton ?? this.showOptionsButton,
      showSubtitlesButton: showSubtitlesButton ?? this.showSubtitlesButton,
      showSeekBar: showSeekBar ?? this.showSeekBar,
      showDuration: showDuration ?? this.showDuration,
      showAttachments: showAttachments ?? this.showAttachments,
      showTitle: showTitle ?? this.showTitle,
      referer: referer ?? this.referer,
      useCustomFullscreen: useCustomFullscreen ?? this.useCustomFullscreen,
      startTime: startTime ?? this.startTime,
      isLive: isLive ?? this.isLive,
    );
  }
}
