import 'package:sonara/features/audio/domain/entities/song.dart';

class SongState {
  final bool isLoading;
  final List<Song> songs;
  final List<Song> filteredSongs;
  final Song? currentSong;
  final String error;

  SongState({
    required this.isLoading,
    required this.songs,
    required this.filteredSongs,
    this.currentSong,
    required this.error,
  });

  factory SongState.initial() {
    return SongState(
      isLoading: false,
      songs: [],
      filteredSongs: [],
      currentSong: null,
      error: '',
    );
  }

  SongState copyWith({
    bool? isLoading,
    List<Song>? songs,
    List<Song>? filteredSongs,
    Song? currentSong,
    String? error,
  }) {
    return SongState(
      isLoading: isLoading ?? this.isLoading,
      songs: songs ?? this.songs,
      filteredSongs: filteredSongs ?? this.filteredSongs,
      currentSong: currentSong ?? this.currentSong,
      error: error ?? this.error,
    );
  }
}
