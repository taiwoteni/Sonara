import 'package:dartz/dartz.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/audio/domain/repositories/audio_repository.dart';

/// Use case for listing songs
class ListSongsUseCase {
  final AudioRepository _repository;

  /// Constructor that takes an AudioRepository instance
  ListSongsUseCase(this._repository);

  /// Execute the use case to list songs
  Future<Either<Failure, List<Song>>> execute() async {
    // First ensure we have permissions
    final permissionResult = await _repository.requestPermissions();
    return permissionResult.fold((failure) => Left(failure), (hasPermission) {
      if (!hasPermission) {
        return Left(GenericFailure('Permission to access audio files denied'));
      }
      return _repository.listAudioFiles();
    });
  }
}
