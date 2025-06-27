import 'package:equatable/equatable.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';

/// Entity representing a playlist in the application.
class Playlist extends Equatable {
  final String id;
  final String name;
  final List<Song> songs;

  const Playlist({required this.id, required this.name, this.songs = const []});

  String get thumbnailData {
    if (songs.isEmpty) return '';
    return songs.first.thumbnailData;
  }

  @override
  List<Object?> get props => [id, name, songs];
}
