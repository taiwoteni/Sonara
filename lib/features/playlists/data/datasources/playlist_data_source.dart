import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/playlists/data/models/playlist_model.dart';
import 'package:sonara/features/playlists/data/models/song_model.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';

abstract class PlaylistDataSource {
  Future<Either<Failure, PlaylistModel>> createPlaylist(String name);
  Future<Either<Failure, PlaylistModel>> updatePlaylist(PlaylistModel playlist);
  Future<Either<Failure, void>> deletePlaylist(String id);
  Future<Either<Failure, PlaylistModel>> addSongToPlaylist(
    String playlistId,
    Song song,
  );
  Future<Either<Failure, PlaylistModel>> removeSongFromPlaylist(
    String playlistId,
    String songId,
  );
  Future<Either<Failure, List<PlaylistModel>>> getAllPlaylists();
  Future<Either<Failure, PlaylistModel>> getPlaylist(String id);
  Future<Either<Failure, String>> exportPlaylist(String playlistId);
  Future<Either<Failure, PlaylistModel>> importPlaylist(String filePath);
}

class PlaylistDataSourceImpl implements PlaylistDataSource {
  static const String _fileName = 'playlists.json';
  int _idCounter = 0;

  Future<File> _getPlaylistsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_fileName');
    if (!await file.exists()) {
      await file.writeAsString(jsonEncode([]));
      _idCounter = 0;
    } else {
      final content = await file.readAsString();
      final playlists = jsonDecode(content) as List<dynamic>;
      if (playlists.isNotEmpty) {
        _idCounter =
            playlists
                .map((p) => int.tryParse(p['id'] as String) ?? 0)
                .reduce((a, b) => a > b ? a : b) +
            1;
      }
    }
    return file;
  }

  Future<List<PlaylistModel>> _readPlaylists() async {
    final file = await _getPlaylistsFile();
    final content = await file.readAsString();
    final jsonList = jsonDecode(content) as List<dynamic>;
    return jsonList
        .map((json) => PlaylistModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writePlaylists(List<PlaylistModel> playlists) async {
    final file = await _getPlaylistsFile();
    final jsonList = playlists.map((p) => p.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  @override
  Future<Either<Failure, PlaylistModel>> createPlaylist(String name) async {
    try {
      final id = (_idCounter++).toString();
      final playlist = PlaylistModel(id: id, name: name);
      final playlists = await _readPlaylists();
      playlists.add(playlist);
      await _writePlaylists(playlists);
      return Right(playlist);
    } catch (e) {
      return Left(GenericFailure('Failed to create playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, PlaylistModel>> updatePlaylist(
    PlaylistModel playlist,
  ) async {
    try {
      final playlists = await _readPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlist.id);
      if (index != -1) {
        playlists[index] = playlist;
        await _writePlaylists(playlists);
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
      final playlists = await _readPlaylists();
      playlists.removeWhere((p) => p.id == id);
      await _writePlaylists(playlists);
      return const Right(null);
    } catch (e) {
      return Left(GenericFailure('Failed to delete playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, PlaylistModel>> addSongToPlaylist(
    String playlistId,
    Song song,
  ) async {
    try {
      final playlists = await _readPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        // Convert Song to SongModel to match the expected type in PlaylistModel
        final songModel = SongModel.fromSong(song);
        final updatedSongs = List<Song>.from(playlists[index].songs)
          ..add(songModel);
        final updatedPlaylist = PlaylistModel(
          id: playlistId,
          name: playlists[index].name,
          songs: updatedSongs,
        );
        playlists[index] = updatedPlaylist;
        await _writePlaylists(playlists);
        return Right(updatedPlaylist);
      }
      return Left(GenericFailure('Playlist not found'));
    } catch (e) {
      return Left(
        GenericFailure(
          'Failed to add song to playlist: $e - Song Type: ${song.runtimeType}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PlaylistModel>> removeSongFromPlaylist(
    String playlistId,
    String songId,
  ) async {
    try {
      final playlists = await _readPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        final updatedSongs = List<Song>.from(playlists[index].songs)
          ..removeWhere((s) => s.id == songId);
        final updatedPlaylist = PlaylistModel(
          id: playlistId,
          name: playlists[index].name,
          songs: updatedSongs,
        );
        playlists[index] = updatedPlaylist;
        await _writePlaylists(playlists);
        return Right(updatedPlaylist);
      }
      return Left(GenericFailure('Playlist not found'));
    } catch (e) {
      return Left(GenericFailure('Failed to remove song from playlist: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PlaylistModel>>> getAllPlaylists() async {
    try {
      final playlists = await _readPlaylists();
      return Right(playlists);
    } catch (e) {
      return Left(GenericFailure('Failed to get playlists: $e'));
    }
  }

  @override
  Future<Either<Failure, PlaylistModel>> getPlaylist(String id) async {
    try {
      final playlists = await _readPlaylists();
      final playlist = playlists.firstWhere(
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
  Future<Either<Failure, PlaylistModel>> importPlaylist(String filePath) async {
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
      final id = (_idCounter++).toString();
      final name = filePath.split('/').last.split('.').first;
      final playlist = PlaylistModel(id: id, name: name);
      final playlists = await _readPlaylists();
      playlists.add(playlist);
      await _writePlaylists(playlists);
      return Right(playlist);
    } catch (e) {
      return Left(GenericFailure('Failed to import playlist: $e'));
    }
  }
}
