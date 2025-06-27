import 'package:dartz/dartz.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/playlists/domain/repositories/playlist_repository.dart';

class RemoveSongFromPlaylist {
  final PlaylistRepository repository;

  RemoveSongFromPlaylist(this.repository);

  Future<Either<Failure, Playlist>> call(
    String playlistId,
    String songId,
  ) async {
    return await repository.removeSongFromPlaylist(playlistId, songId);
  }
}
