import 'package:sonara/features/audio/domain/entities/song.dart';

/// Interface for audio data sources
abstract class AudioDataSource {
  /// Lists all audio files from the device
  Future<List<Song>> listAudioFiles();

  /// Requests permissions to access audio files
  Future<bool> requestPermissions();
}
