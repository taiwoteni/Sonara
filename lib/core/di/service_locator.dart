import 'package:get_it/get_it.dart';
import 'package:sonara/core/utils/services/audio_file_service.dart';
import 'package:sonara/features/audio/data/datasources/audio_data_source.dart';
import 'package:sonara/features/audio/data/datasources/audio_data_source_impl.dart';
import 'package:sonara/features/audio/data/repositories/audio_repository_impl.dart';
import 'package:sonara/features/audio/domain/repositories/audio_repository.dart';
import 'package:sonara/features/audio/domain/usecases/list_audio_files_usecase.dart';

/// GetIt instance for dependency injection
final getIt = GetIt.instance;

/// Setup all dependencies for the application
void setupDependencies() {
  // Register services
  getIt.registerLazySingleton<AudioFileService>(() => AudioFileService());

  // Register data sources
  getIt.registerLazySingleton<AudioDataSource>(
    () => AudioDataSourceImpl(getIt<AudioFileService>()),
  );

  // Register repositories
  getIt.registerLazySingleton<AudioRepository>(
    () => AudioRepositoryImpl(getIt<AudioDataSource>()),
  );

  // Register use cases
  getIt.registerLazySingleton<ListAudioFilesUseCase>(
    () => ListAudioFilesUseCase(getIt<AudioRepository>()),
  );
}
