import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/services/audio_player_helper.dart';
import 'package:sonara/core/utils/services/audio_service.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/home/presentation/widgets/bottom_bar.dart';
import 'package:sonara/features/songs/presentation/widgets/song_widget.dart';
import 'dart:developer';

/// Widget that displays a list of audio files
class SongsList extends StatefulWidget {
  final List<Song> songs;

  /// Callback when the more options button is tapped
  final List<PopupMenuEntry<String>> Function(Song song)? menuItems;

  const SongsList({super.key, this.songs = const [], this.menuItems});

  @override
  State<SongsList> createState() => _SongsListState();
}

class _SongsListState extends State<SongsList> {
  late StreamSubscription<String?> currentSongStreamSubscription;
  String? currentSongId;

  void watchCurrentSong() {
    currentSongStreamSubscription = getIt<AudioService>().currentSongIdStream
        .listen((event) => setState(() => currentSongId = event));
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) => watchCurrentSong(),
    );
  }

  @override
  void dispose() {
    currentSongStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.songs.isEmpty) {
      return Center(
        child: Text(
          'No songs found',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SongWidget(
            audio: widget.songs[index],
            isPlaying: currentSongId == widget.songs[index].id,
            items: widget.menuItems,
            onTap: () async {
              final song = widget.songs[index];
              String? highQualityArtworkData;
              try {
                final result = await MethodChannel(
                  'com.sonara.audio_files',
                ).invokeMethod('getHighQualityArtwork', {'id': song.id});
                highQualityArtworkData = result['artworkData'] ?? '';
                log(
                  'High-quality artwork loaded for ${song.title}',
                  name: 'SongsList',
                );
              } catch (e) {
                log(
                  'Error loading high-quality artwork for ${song.title}: $e',
                  name: 'SongsList',
                );
              }
              await AudioPlayerHelper.playSong(
                song,
                highQualityArtworkData: highQualityArtworkData,
                allSongs: widget.songs,
              );
            },
          ),
          if (index == widget.songs.length - 1) bottomBarSpacer(context),
        ],
      ),
      separatorBuilder: (_, _) => const Gap(10),
      itemCount: widget.songs.length,
    );
  }
}
