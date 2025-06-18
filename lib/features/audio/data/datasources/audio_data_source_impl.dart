import 'package:sonara/core/utils/services/audio_file_service.dart';
import 'package:sonara/features/audio/data/datasources/audio_data_source.dart';
import 'package:sonara/features/audio/domain/entities/audio_file.dart';

/// Implementation of the AudioDataSource interface using the AudioFileService
class AudioDataSourceImpl implements AudioDataSource {
  final AudioFileService _audioFileService;

  /// Constructor that takes an AudioFileService instance
  AudioDataSourceImpl(this._audioFileService);

  @override
  Future<List<AudioFile>> listAudioFiles() {
    return _audioFileService.listAudioFiles();
  }

  @override
  Future<bool> requestPermissions() {
    return _audioFileService.requestPermissions();
  }
}
