import 'package:sonara/features/audio/data/datasources/audio_data_source.dart';
import 'package:sonara/features/audio/domain/entities/audio_file.dart';
import 'package:sonara/features/audio/domain/repositories/audio_repository.dart';

/// Implementation of the AudioRepository interface
class AudioRepositoryImpl implements AudioRepository {
  final AudioDataSource _dataSource;

  /// Constructor that takes an AudioDataSource instance
  AudioRepositoryImpl(this._dataSource);

  @override
  Future<List<AudioFile>> listAudioFiles() {
    return _dataSource.listAudioFiles();
  }

  @override
  Future<bool> requestPermissions() {
    return _dataSource.requestPermissions();
  }
}
