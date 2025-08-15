import 'package:dartz/dartz.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';

/// Repository interface for audio files
abstract class AudioRepository {
  /// Lists all audio files on the device
  Future<Either<Failure, List<Song>>> listAudioFiles();

  /// Checks and requests permissions to access audio files
  Future<Either<Failure, bool>> requestPermissions();

  /// Saves high-quality thumbnail for a song
  Future<Either<Failure, String>> saveHighQualityThumbnail(
    String songId,
    String thumbnailData,
  );

  /// Gets the path of a saved high-quality thumbnail for a song
  Future<Either<Failure, String>> getThumbnailPath(String songId);
}
