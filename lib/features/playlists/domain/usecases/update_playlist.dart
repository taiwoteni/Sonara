import 'package:dartz/dartz.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/playlists/domain/repositories/playlist_repository.dart';

class UpdatePlaylist {
  final PlaylistRepository repository;

  UpdatePlaylist(this.repository);

  Future<Either<Failure, Playlist>> call(Playlist playlist) async {
    return await repository.updatePlaylist(playlist);
  }
}
