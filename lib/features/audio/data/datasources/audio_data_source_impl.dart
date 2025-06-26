import 'package:sonara/core/utils/services/song_service.dart';
import 'package:sonara/features/audio/data/datasources/audio_data_source.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';

/// Implementation of the AudioDataSource interface using the SongService
class AudioDataSourceImpl implements AudioDataSource {
  final SongService _audioFileService;

  /// Constructor that takes an SongService instance
  AudioDataSourceImpl(this._audioFileService);

  @override
  Future<List<Song>> listAudioFiles() {
    return _audioFileService.listSongs();
  }

  @override
  Future<bool> requestPermissions() {
    return _audioFileService.requestPermissions();
  }
}
