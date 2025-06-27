import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/playlists/domain/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  // In a real implementation, this would interact with a local database or file system
  // For simplicity, we're simulating with in-memory data and file operations for M3U
  final List<Playlist> _playlists = [];
  int _idCounter = 0;

  @override
  Future<Either<Failure, Playlist>> createPlaylist(String name) async {
    try {
      final id = (_idCounter++).toString();
      final playlist = Playlist(id: id, name: name);
      _playlists.add(playlist);
      return Right(playlist);
    } catch (e) {
      return Left(GenericFailure('Failed to create playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, Playlist>> updatePlaylist(Playlist playlist) async {
    try {
      final index = _playlists.indexWhere((p) => p.id == playlist.id);
      if (index != -1) {
        _playlists[index] = playlist;
        return Right(playlist);
      }
      return Left(GenericFailure('Playlist not found'));
    } catch (e) {
      return Left(GenericFailure('Failed to update playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlaylist(String id) async {
    try {
      _playlists.removeWhere((p) => p.id == id);
      return const Right(null);
    } catch (e) {
      return Left(GenericFailure('Failed to delete playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, Playlist>> addSongToPlaylist(
    String playlistId,
    String songId,
  ) async {
    try {
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        // In a real app, fetch the Song entity by songId from a data source
        // For simplicity, create a dummy Song
        final song = Song(
          id: songId,
          title: 'Song $songId',
          artist: 'Artist',
          album: 'Album',
          duration: 0,
          path: '',
        );
        final updatedSongs = List<Song>.from(_playlists[index].songs)
          ..add(song);
        final updatedPlaylist = Playlist(
          id: playlistId,
          name: _playlists[index].name,
          songs: updatedSongs,
        );
        _playlists[index] = updatedPlaylist;
        return Right(updatedPlaylist);
      }
      return Left(GenericFailure('Playlist not found'));
    } catch (e) {
      return Left(GenericFailure('Failed to add song to playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, Playlist>> removeSongFromPlaylist(
    String playlistId,
    String songId,
  ) async {
    try {
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        final updatedSongs = List<Song>.from(_playlists[index].songs)
          ..removeWhere((s) => s.id == songId);
        final updatedPlaylist = Playlist(
          id: playlistId,
          name: _playlists[index].name,
          songs: updatedSongs,
        );
        _playlists[index] = updatedPlaylist;
        return Right(updatedPlaylist);
      }
      return Left(GenericFailure('Playlist not found'));
    } catch (e) {
      return Left(GenericFailure('Failed to remove song from playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Playlist>>> getAllPlaylists() async {
    try {
      return Right(List<Playlist>.from(_playlists));
    } catch (e) {
      return Left(GenericFailure('Failed to get playlists: $e'));
    }
  }

  @override
  Future<Either<Failure, Playlist>> getPlaylist(String id) async {
    try {
      final playlist = _playlists.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Playlist not found'),
      );
      return Right(playlist);
    } catch (e) {
      return Left(GenericFailure('Failed to get playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> exportPlaylist(String playlistId) async {
    try {
      final playlistResult = await getPlaylist(playlistId);
      return playlistResult.fold((failure) => Left(failure), (playlist) async {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${playlist.name}.m3u';
        final file = File(filePath);
        final buffer = StringBuffer('#EXTM3U\n');
        for (final song in playlist.songs) {
          buffer.writeln(
            '#EXTINF:${song.duration},${song.artist} - ${song.title}',
          );
          buffer.writeln(song.path);
        }
        await file.writeAsString(buffer.toString());
        return Right(filePath);
      });
    } catch (e) {
      return Left(GenericFailure('Failed to export playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, Playlist>> importPlaylist(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Left(GenericFailure('File not found'));
      }
      final content = await file.readAsString();
      final lines = content.split('\n');
      if (lines.isEmpty || lines[0].trim() != '#EXTM3U') {
        return Left(GenericFailure('Invalid M3U format'));
      }
      // Parsing logic for M3U file to extract songs
      // For simplicity, creating a dummy playlist
      final id = (_idCounter++).toString();
      final name = filePath.split('/').last.split('.').first;
      final playlist = Playlist(id: id, name: name);
      _playlists.add(playlist);
      return Right(playlist);
    } catch (e) {
      return Left(GenericFailure('Failed to import playlist: $e'));
    }
  }
}
