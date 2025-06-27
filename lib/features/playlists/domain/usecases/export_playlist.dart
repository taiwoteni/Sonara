import 'package:dartz/dartz.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/playlists/domain/repositories/playlist_repository.dart';

class ExportPlaylist {
  final PlaylistRepository repository;

  ExportPlaylist(this.repository);

  Future<Either<Failure, String>> call(String playlistId) async {
    return await repository.exportPlaylist(playlistId);
  }
}
