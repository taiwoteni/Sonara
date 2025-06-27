import 'package:dartz/dartz.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/playlists/domain/repositories/playlist_repository.dart';

class ImportPlaylist {
  final PlaylistRepository repository;

  ImportPlaylist(this.repository);

  Future<Either<Failure, Playlist>> call(String filePath) async {
    return await repository.importPlaylist(filePath);
  }
}
