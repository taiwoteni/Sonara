import 'package:dartz/dartz.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/playlists/domain/repositories/playlist_repository.dart';

class DeletePlaylist {
  final PlaylistRepository repository;

  DeletePlaylist(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deletePlaylist(id);
  }
}
