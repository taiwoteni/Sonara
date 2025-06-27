import 'package:dartz/dartz.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/playlists/data/models/playlist_model.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/playlists/domain/repositories/playlist_repository.dart';
import 'package:sonara/features/playlists/data/datasources/playlist_data_source.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistDataSource dataSource;

  PlaylistRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Playlist>> createPlaylist(String name) async {
    return await dataSource.createPlaylist(name);
  }

  @override
  Future<Either<Failure, Playlist>> updatePlaylist(Playlist playlist) async {
    if (playlist is PlaylistModel) {
      return await dataSource.updatePlaylist(playlist);
    }
    return Left(GenericFailure('Invalid playlist type'));
  }

  @override
  Future<Either<Failure, void>> deletePlaylist(String id) async {
    return await dataSource.deletePlaylist(id);
  }

  @override
  Future<Either<Failure, Playlist>> addSongToPlaylist(
    String playlistId,
    String songId,
  ) async {
    // In a real app, fetch the Song entity by songId from a data source
    // For simplicity, create a dummy Song and convert to SongModel if needed
    final song = Song(
      id: songId,
      title: 'Song $songId',
      artist: 'Artist',
      album: 'Album',
      duration: 0,
      path: '',
    );
    return await dataSource.addSongToPlaylist(playlistId, song);
  }

  @override
  Future<Either<Failure, Playlist>> removeSongFromPlaylist(
    String playlistId,
    String songId,
  ) async {
    return await dataSource.removeSongFromPlaylist(playlistId, songId);
  }

  @override
  Future<Either<Failure, List<Playlist>>> getAllPlaylists() async {
    return await dataSource.getAllPlaylists();
  }

  @override
  Future<Either<Failure, Playlist>> getPlaylist(String id) async {
    return await dataSource.getPlaylist(id);
  }

  @override
  Future<Either<Failure, String>> exportPlaylist(String playlistId) async {
    return await dataSource.exportPlaylist(playlistId);
  }

  @override
  Future<Either<Failure, Playlist>> importPlaylist(String filePath) async {
    return await dataSource.importPlaylist(filePath);
  }
}
