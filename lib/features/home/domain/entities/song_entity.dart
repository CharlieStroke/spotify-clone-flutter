class SongEntity {
  final String id;
  final String title;
  final String album;
  final String artistName;
  final String duration;
  final String coverUrl;
  final String audioUrl;
  final int plays;

  SongEntity({
    required this.id,
    required this.title,
    required this.album,
    required this.artistName,
    required this.duration,
    required this.coverUrl,
    required this.audioUrl,
    this.plays = 0,
  });
}