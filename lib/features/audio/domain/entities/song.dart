import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/services/directory_paths.dart';

/// Model class representing an audio file
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String path;
  final String thumbnailData;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.path,
    this.thumbnailData = '',
  });

  String get artworkPath {
    return "${getIt<DirectoryPaths>().applicationSupportDirectory.path}/.thumbnails/$id.jpg";
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] as String,
      duration: map['duration'] ?? 0,
      path: map['path'] as String,
      thumbnailData: map['thumbnailData'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'path': path,
      'thumbnailData': thumbnailData,
    };
  }

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artist: $artist, album: $album, path: $path, duration: $duration, thumbnailData: ${thumbnailData.isNotEmpty ? "present" : "absent"})';
  }
}
