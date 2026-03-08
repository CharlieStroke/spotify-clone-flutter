class SongEntity {
  final String id;
  final String title;
  final String album;
  final String duration;
  final String coverUrl;
  final String audioUrl;

  SongEntity({
    required this.id,
    required this.title,
    required this.album,
    required this.duration,
    required this.coverUrl,
    required this.audioUrl,
  });
}