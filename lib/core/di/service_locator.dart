import 'package:get_it/get_it.dart';
import 'package:sonara/core/utils/services/audio_service.dart';
import 'package:sonara/core/utils/services/directory_paths.dart';
import 'package:sonara/core/utils/services/song_service.dart';
import 'package:sonara/features/audio/data/datasources/audio_data_source.dart';
import 'package:sonara/features/audio/data/datasources/audio_data_source_impl.dart';
import 'package:sonara/features/audio/data/repositories/audio_repository_impl.dart';
import 'package:sonara/features/audio/domain/repositories/audio_repository.dart';
import 'package:sonara/features/audio/domain/usecases/list_songs_usecase.dart';
import 'package:sonara/features/playlists/data/datasources/playlist_data_source.dart';
import 'package:sonara/features/playlists/data/repositories/playlist_repository_impl.dart';
import 'package:sonara/features/playlists/domain/repositories/playlist_repository.dart';
import 'package:sonara/features/playlists/domain/usecases/add_song_to_playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/create_playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/delete_playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/export_playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/get_playlists.dart';
import 'package:sonara/features/audio/data/datasources/song_data_source.dart';
import 'package:sonara/features/playlists/domain/usecases/import_playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/remove_song_from_playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/update_playlist.dart';

/// GetIt instance for dependency injection
final getIt = GetIt.instance;

/// Setup all dependencies for the application
void setupDependencies() {
  // Register services
  getIt.registerLazySingleton<SongService>(() => SongService());
  getIt.registerLazySingleton<AudioService>(() => AudioService());
  getIt.registerLazySingleton<DirectoryPaths>(() => DirectoryPaths());

  // Register data sources
  getIt.registerLazySingleton<AudioDataSource>(
    () => AudioDataSourceImpl(getIt<SongService>()),
  );

  // Register repositories
  getIt.registerLazySingleton<AudioRepository>(
    () =>
        AudioRepositoryImpl(getIt<AudioDataSource>(), getIt<SongDataSource>()),
  );

  // Register use cases
  getIt.registerLazySingleton<ListSongsUseCase>(
    () => ListSongsUseCase(getIt<AudioRepository>()),
  );

  // Register playlist data source
  getIt.registerLazySingleton<PlaylistDataSource>(
    () => PlaylistDataSourceImpl(),
  );

  // Register playlist repository
  getIt.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(getIt<PlaylistDataSource>()),
  );

  // Register playlist use cases
  getIt.registerLazySingleton<CreatePlaylist>(
    () => CreatePlaylist(getIt<PlaylistRepository>()),
  );
  getIt.registerLazySingleton<GetPlaylists>(
    () => GetPlaylists(getIt<PlaylistRepository>()),
  );
  getIt.registerLazySingleton<UpdatePlaylist>(
    () => UpdatePlaylist(getIt<PlaylistRepository>()),
  );
  getIt.registerLazySingleton<DeletePlaylist>(
    () => DeletePlaylist(getIt<PlaylistRepository>()),
  );
  getIt.registerLazySingleton<AddSongToPlaylist>(
    () => AddSongToPlaylist(getIt<PlaylistRepository>()),
  );
  getIt.registerLazySingleton<RemoveSongFromPlaylist>(
    () => RemoveSongFromPlaylist(getIt<PlaylistRepository>()),
  );
  getIt.registerLazySingleton<ExportPlaylist>(
    () => ExportPlaylist(getIt<PlaylistRepository>()),
  );
  getIt.registerLazySingleton<ImportPlaylist>(
    () => ImportPlaylist(getIt<PlaylistRepository>()),
  );

  // Register song data source
  getIt.registerLazySingleton<SongDataSource>(() => SongDataSourceImpl());
}
