import 'package:sonara/features/audio/domain/entities/song.dart';

class SongModel extends Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String path;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.path,
  }) : super(
         id: id,
         title: title,
         artist: artist,
         album: album,
         duration: duration,
         path: path,
       );

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      duration: json['duration'] as int,
      path: json['path'] as String,
    );
  }

  factory SongModel.fromSong(Song song) {
    return SongModel(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
      path: song.path,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'path': path,
    };
  }
}
