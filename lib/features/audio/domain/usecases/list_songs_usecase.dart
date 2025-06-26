import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/audio/domain/repositories/audio_repository.dart';

/// Use case for listing songs
class ListSongsUseCase {
  final AudioRepository _repository;

  /// Constructor that takes an AudioRepository instance
  ListSongsUseCase(this._repository);

  /// Execute the use case to list songs
  Future<List<Song>> execute() async {
    // First ensure we have permissions
    bool hasPermission = await _repository.requestPermissions();
    if (!hasPermission) {
      return [];
    }

    // Then list the songs
    return _repository.listAudioFiles();
  }
}
