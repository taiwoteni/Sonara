/// Model class representing an audio file
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String path;
  final int duration;
  final String thumbnailData;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.duration,
    this.thumbnailData = '',
  });

  /// Create an AudioFile from a map (used for method channel responses)
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      album: map['album'] ?? 'Unknown Album',
      path: map['path'] ?? '',
      duration: map['duration'] ?? 0,
      thumbnailData: map['thumbnailData'] ?? '',
    );
  }

  @override
  String toString() {
    return 'AudioFile(id: $id, title: $title, artist: $artist, album: $album, path: $path, duration: $duration, thumbnailData: ${thumbnailData.isNotEmpty ? "present" : "absent"})';
  }
}
