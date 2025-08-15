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
    try {
      // Fetch the actual Song entity by songId from a data source
      // This should be replaced with actual data fetching logic
      // For now, we'll assume a method to get the song from a song repository
      // If you have a SongRepository, use it here
      final songResult = await _getSongById(songId);
      return songResult.fold(
        (failure) => Left(failure),
        (song) => dataSource.addSongToPlaylist(playlistId, song),
      );
    } catch (e) {
      return Left(GenericFailure('Failed to add song to playlist: $e'));
    }
  }

  // Placeholder method to fetch a song by ID
  // Replace this with actual implementation using a SongRepository or similar
  Future<Either<Failure, Song>> _getSongById(String songId) async {
    // Dummy implementation for now
    // In a real app, this would fetch from a data source
    return Right(
      Song(
        id: songId,
        title: 'Song $songId',
        artist: 'Artist',
        album: 'Album',
        duration: 0,
        path: '',
      ),
    );
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
