import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/audio/domain/usecases/list_songs_usecase.dart';

// Provider for the full list of songs
final songListProvider = FutureProvider<List<Song>>((ref) async {
  final listSongsUseCase = getIt<ListSongsUseCase>();
  return await listSongsUseCase.execute();
});

// Provider for the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for the search index
final searchIndexProvider = Provider<Map<String, List<String>>>((ref) {
  final songs = ref.watch(songListProvider).value ?? [];
  final index = <String, List<String>>{};
  for (var song in songs) {
    final keywords = [
      ...song.title.toLowerCase().split(' '),
      ...song.artist.toLowerCase().split(' '),
      ...song.album.toLowerCase().split(' '),
    ];
    for (var keyword in keywords) {
      if (keyword.isNotEmpty) {
        index.putIfAbsent(keyword, () => []).add(song.id);
      }
    }
  }
  return index;
});

// Provider for filtered songs based on search query
final filteredSongsProvider = Provider<List<Song>>((ref) {
  final songs = ref.watch(songListProvider).value ?? [];
  final query = ref.watch(searchQueryProvider);
  final index = ref.watch(searchIndexProvider);

  if (query.isEmpty) {
    return songs;
  }

  final searchTerms = query.toLowerCase().split(' ');
  Set<String> matchingSongIds = {};

  for (var term in searchTerms) {
    if (index.containsKey(term)) {
      if (matchingSongIds.isEmpty) {
        matchingSongIds.addAll(index[term]!);
      } else {
        matchingSongIds.retainAll(index[term]!);
      }
    }
  }

  return songs.where((song) => matchingSongIds.contains(song.id)).toList();
});
