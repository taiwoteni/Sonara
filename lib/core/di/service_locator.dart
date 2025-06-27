import 'package:get_it/get_it.dart';
import 'package:sonara/core/utils/services/audio_service.dart';
import 'package:sonara/core/utils/services/song_service.dart';
import 'package:sonara/features/audio/data/datasources/audio_data_source.dart';
import 'package:sonara/features/audio/data/datasources/audio_data_source_impl.dart';
import 'package:sonara/features/audio/data/repositories/audio_repository_impl.dart';
import 'package:sonara/features/audio/domain/repositories/audio_repository.dart';
import 'package:sonara/features/audio/domain/usecases/list_songs_usecase.dart';
import 'package:sonara/features/playlists/data/repositories/playlist_repository_impl.dart';
import 'package:sonara/features/playlists/domain/repositories/playlist_repository.dart';
import 'package:sonara/features/playlists/domain/usecases/create_playlist.dart';

/// GetIt instance for dependency injection
final getIt = GetIt.instance;

/// Setup all dependencies for the application
void setupDependencies() {
  // Register services
  getIt.registerLazySingleton<SongService>(() => SongService());
  getIt.registerLazySingleton<AudioService>(() => AudioService());

  // Register data sources
  getIt.registerLazySingleton<AudioDataSource>(
    () => AudioDataSourceImpl(getIt<SongService>()),
  );

  // Register repositories
  getIt.registerLazySingleton<AudioRepository>(
    () => AudioRepositoryImpl(getIt<AudioDataSource>()),
  );

  // Register use cases
  getIt.registerLazySingleton<ListSongsUseCase>(
    () => ListSongsUseCase(getIt<AudioRepository>()),
  );

  // Register playlist repository
  getIt.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(),
  );

  // Register playlist use cases
  getIt.registerLazySingleton<CreatePlaylist>(
    () => CreatePlaylist(getIt<PlaylistRepository>()),
  );
}
