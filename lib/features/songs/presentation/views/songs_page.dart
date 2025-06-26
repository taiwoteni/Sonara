import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/audio/domain/usecases/list_songs_usecase.dart';
import 'package:sonara/features/home/presentation/widgets/search_bar.dart';
import 'package:sonara/features/songs/presentation/widgets/songs_list.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  List<Song> allSongs = [];
  List<Song> filteredSongs = [];
  TextEditingController searchController = TextEditingController();
  final searchIndex = <String, List<String>>{};

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  Future<void> loadSongs() async {
    try {
      final songs = await getIt<ListSongsUseCase>().execute();
      setState(() {
        allSongs = songs;
        filteredSongs = songs;
        buildSearchIndex(songs);
      });
    } catch (e) {
      // Handle error
    }
  }

  void buildSearchIndex(List<Song> songs) {
    searchIndex.clear();
    for (var song in songs) {
      final keywords = [
        ...song.title.toLowerCase().split(' '),
        ...song.artist.toLowerCase().split(' '),
        ...song.album.toLowerCase().split(' '),
      ];
      for (var keyword in keywords) {
        if (keyword.isNotEmpty) {
          searchIndex.putIfAbsent(keyword, () => []).add(song.id);
        }
      }
    }
  }

  void searchSongs(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredSongs = allSongs;
      });
      return;
    }

    final searchTerm = query.toLowerCase();
    setState(() {
      filteredSongs = allSongs.where((song) {
        return song.title.toLowerCase().contains(searchTerm) ||
            song.artist.toLowerCase().contains(searchTerm) ||
            song.album.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.safeAreaInsets.copyWith(left: 16, right: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(12),
          SonaraSearchBar(
            controller: searchController,
            onSubmit: (query) {
              searchSongs(query);
            },
          ),
          Gap(20),
          Text(
            "Your Songs".toUpperCase(),
            style: context.lufgaBold.copyWith(fontSize: 16),
          ),
          Gap(16),
          SongsList(songs: filteredSongs),
          Gap(40),
        ],
      ),
    );
  }
}
