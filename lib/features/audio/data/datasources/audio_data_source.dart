import 'package:sonara/features/audio/domain/entities/audio_file.dart';

/// Interface for audio data sources
abstract class AudioDataSource {
  /// Lists all audio files from the device
  Future<List<AudioFile>> listAudioFiles();

  /// Requests permissions to access audio files
  Future<bool> requestPermissions();
}
