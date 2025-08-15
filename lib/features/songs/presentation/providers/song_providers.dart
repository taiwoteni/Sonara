import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/audio/domain/usecases/list_songs_usecase.dart';
import 'package:sonara/features/songs/presentation/states/song_state.dart';

// Provider for the song notifier
final songProvider = StateNotifierProvider<SongNotifier, SongState>((ref) {
  return SongNotifier(getIt<ListSongsUseCase>());
});

class SongNotifier extends StateNotifier<SongState> {
  final ListSongsUseCase _listSongsUseCase;

  SongNotifier(this._listSongsUseCase) : super(SongState.initial()) {
    loadSongs();
  }

  Future<void> loadSongs() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _listSongsUseCase.execute();
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
            songs: [],
            filteredSongs: [],
          );
          print('Song loading failed: ${failure.message}');
        },
        (songs) {
          state = state.copyWith(
            isLoading: false,
            songs: songs,
            filteredSongs: songs,
            error: '',
          );
          print('Song loading successful: ${songs.length} songs loaded');
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        songs: [],
        filteredSongs: [],
      );
      print('Unexpected error during song loading: $e');
    }
  }

  void searchSongs(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredSongs: state.songs);
      return;
    }

    final searchTerm = query.toLowerCase();
    final filtered = state.songs.where((song) {
      return song.title.toLowerCase().contains(searchTerm) ||
          song.artist.toLowerCase().contains(searchTerm) ||
          song.album.toLowerCase().contains(searchTerm);
    }).toList();
    state = state.copyWith(filteredSongs: filtered);
  }

  void setCurrentSong(Song song) {
    state = state.copyWith(currentSong: song);
  }
}

// Provider for the search query
final searchQueryProvider = StateProvider<String>((ref) => '');
