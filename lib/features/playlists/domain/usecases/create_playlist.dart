import 'package:dartz/dartz.dart';
import 'package:sonara/core/domain/usecase/usecase.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/playlists/domain/repositories/playlist_repository.dart';
import 'package:sonara/features/playlists/domain/usecases/create_playlist_params.dart';

class CreatePlaylist extends UseCase<Playlist, CreatePlaylistParams> {
  final PlaylistRepository repository;

  CreatePlaylist(this.repository);

  @override
  Future<Either<Failure, Playlist>> call(CreatePlaylistParams params) async {
    return await repository.createPlaylist(params.name);
  }
}
