/// Модель данных для видео Kinescope
class KinescopeVideo {
  final String id;
  final String title;
  final String? description;
  final String? posterUrl;
  final bool isLive;
  final DateTime? liveStartDate;
  final int? duration;
  final String? status;

  const KinescopeVideo({
    required this.id,
    required this.title,
    this.description,
    this.posterUrl,
    this.isLive = false,
    this.liveStartDate,
    this.duration,
    this.status,
  });

  factory KinescopeVideo.fromMap(Map<String, dynamic> map) {
    return KinescopeVideo(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      posterUrl: map['posterUrl'],
      isLive: map['isLive'] ?? false,
      liveStartDate: map['liveStartDate'] != null 
          ? DateTime.parse(map['liveStartDate']) 
          : null,
      duration: map['duration'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'isLive': isLive,
      'liveStartDate': liveStartDate?.toIso8601String(),
      'duration': duration,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'KinescopeVideo(id: $id, title: $title, isLive: $isLive)';
  }
} 