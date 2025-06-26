import 'package:sonara/features/audio/domain/entities/song.dart';

/// Repository interface for audio files
abstract class AudioRepository {
  /// Lists all audio files on the device
  Future<List<Song>> listAudioFiles();

  /// Checks and requests permissions to access audio files
  Future<bool> requestPermissions();
}
