import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:sonara/core/utils/dialog_manager.dart';
import 'package:sonara/core/utils/services/audio_player_helper.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/playlists/presentation/widgets/add_song_to_playlist_dialog.dart';
import 'package:sonara/features/songs/presentation/widgets/song_widget.dart';
import 'dart:developer';

/// Widget that displays a list of audio files
class SongsList extends StatelessWidget {
  final List<Song> songs;

  const SongsList({super.key, this.songs = const []});

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
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
      itemBuilder: (context, index) => SongWidget(
        audio: songs[index],
        onMoreTap: () {
          DialogManager.showCustomDialog(
            context: context,
            builder: (context) =>
                Dialog(child: AddSongToPlaylistDialog(song: songs[index])),
          );
        },
        onTap: () async {
          final song = songs[index];
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
          );
        },
      ),
      separatorBuilder: (_, _) => const Gap(10),
      itemCount: songs.length,
    );
  }
}
