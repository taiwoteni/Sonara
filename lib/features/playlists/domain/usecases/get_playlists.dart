import 'package:dartz/dartz.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/playlists/domain/repositories/playlist_repository.dart';

class GetPlaylists {
  final PlaylistRepository repository;

  GetPlaylists(this.repository);

  Future<Either<Failure, List<Playlist>>> call() async {
    return await repository.getAllPlaylists();
  }
}
