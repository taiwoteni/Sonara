import 'package:dartz/dartz.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/audio/data/datasources/audio_data_source.dart';
import 'package:sonara/features/audio/data/datasources/song_data_source.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/audio/domain/repositories/audio_repository.dart';

/// Implementation of the AudioRepository interface
class AudioRepositoryImpl implements AudioRepository {
  final AudioDataSource _dataSource;
  final SongDataSource _songDataSource;

  /// Constructor that takes an AudioDataSource and SongDataSource instance
  AudioRepositoryImpl(this._dataSource, this._songDataSource);

  @override
  Future<Either<Failure, List<Song>>> listAudioFiles() async {
    try {
      final songs = await _dataSource.listAudioFiles();
      // Cache the songs metadata using SongDataSource
      await _songDataSource.saveSongs(songs);
      return Right(songs);
    } catch (e) {
      return Left(GenericFailure('Failed to list audio files: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermissions() async {
    try {
      final result = await _dataSource.requestPermissions();
      return Right(result);
    } catch (e) {
      return Left(GenericFailure('Failed to request permissions: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> saveHighQualityThumbnail(
    String songId,
    String thumbnailData,
  ) async {
    return await _songDataSource.saveHighQualityThumbnail(
      songId,
      thumbnailData,
    );
  }

  @override
  Future<Either<Failure, String>> getThumbnailPath(String songId) async {
    return await _songDataSource.getThumbnailPath(songId);
  }
}
