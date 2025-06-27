import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/playlists/data/models/song_model.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';

class PlaylistModel extends Playlist {
  final String id;
  final String name;
  final List<Song> songs;

  PlaylistModel({required this.id, required this.name, this.songs = const []})
    : super(id: id, name: name, songs: songs);

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      songs:
          (json['songs'] as List<dynamic>?)
              ?.map(
                (songJson) =>
                    SongModel.fromJson(songJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  factory PlaylistModel.fromPlaylist(Playlist playlist) {
    return PlaylistModel(
      id: playlist.id,
      name: playlist.name,
      songs: playlist.songs.map((song) => SongModel.fromSong(song)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songs': songs.map((song) => (song as SongModel).toJson()).toList(),
    };
  }
}
