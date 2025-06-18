import 'package:sonara/features/audio/domain/entities/audio_file.dart';
import 'package:sonara/features/audio/domain/repositories/audio_repository.dart';

/// Use case for listing audio files
class ListAudioFilesUseCase {
  final AudioRepository _repository;

  /// Constructor that takes an AudioRepository instance
  ListAudioFilesUseCase(this._repository);

  /// Execute the use case to list audio files
  Future<List<AudioFile>> execute() async {
    // First ensure we have permissions
    bool hasPermission = await _repository.requestPermissions();
    if (!hasPermission) {
      return [];
    }

    // Then list the audio files
    return _repository.listAudioFiles();
  }
}
