/// Model class representing an audio file
class AudioFile {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String path;
  final int duration;

  AudioFile({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.duration,
  });

  /// Create an AudioFile from a map (used for method channel responses)
  factory AudioFile.fromMap(Map<String, dynamic> map) {
    return AudioFile(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      album: map['album'] ?? 'Unknown Album',
      path: map['path'] ?? '',
      duration: map['duration'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'AudioFile(id: $id, title: $title, artist: $artist, album: $album, path: $path, duration: $duration)';
  }
}
