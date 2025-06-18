import 'package:sonara/features/audio/domain/entities/audio_file.dart';

/// Repository interface for audio files
abstract class AudioRepository {
  /// Lists all audio files on the device
  Future<List<AudioFile>> listAudioFiles();

  /// Checks and requests permissions to access audio files
  Future<bool> requestPermissions();
}
