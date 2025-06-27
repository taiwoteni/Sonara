import 'package:dartz/dartz.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';

abstract class PlaylistRepository {
  Future<Either<Failure, Playlist>> createPlaylist(String name);
  Future<Either<Failure, Playlist>> updatePlaylist(Playlist playlist);
  Future<Either<Failure, void>> deletePlaylist(String id);
  Future<Either<Failure, Playlist>> addSongToPlaylist(
    String playlistId,
    String songId,
  );
  Future<Either<Failure, Playlist>> removeSongFromPlaylist(
    String playlistId,
    String songId,
  );
  Future<Either<Failure, List<Playlist>>> getAllPlaylists();
  Future<Either<Failure, Playlist>> getPlaylist(String id);
  Future<Either<Failure, String>> exportPlaylist(String playlistId);
  Future<Either<Failure, Playlist>> importPlaylist(String filePath);
}
