import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/features/songs/data/models/sonara_popup_menu_item.dart';
import 'package:sonara/features/songs/presentation/providers/song_providers.dart';
import 'package:sonara/features/songs/presentation/widgets/songs_list.dart';

import '../../../../core/utils/services/audio_player_helper.dart';

class SongsPage extends ConsumerWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songState = ref.watch(songProvider);

    ref.listen(songProvider, (previous, next) {
      // Optionally handle state changes if needed
    });

    return SingleChildScrollView(
      padding: context.safeAreaInsets.copyWith(left: 16, right: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Songs".toUpperCase(),
                style: context.lufgaExtraBold.copyWith(fontSize: 25),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(IconsaxPlusLinear.search_normal),
              ),
            ],
          ),
          Gap(16),
          if (songState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (songState.error.isNotEmpty)
            Center(child: Text('Error: ${songState.error}'))
          else
            SongsList(
              songs: songState.filteredSongs,
              menuItems: (song) => [
                SonaraPopupMenuItem(
                  value: 'playlist',
                  icon: IconsaxPlusLinear.music_filter,
                  onTap: () => context.pushNamed('addToPlaylists', extra: song),
                  label: "Add to playlist",
                ),
                SonaraPopupMenuItem(
                  icon: HugeIcons.strokeRoundedPlaylist03,
                  label: "Add to queue",
                  onTap: () {
                    AudioPlayerHelper.addToQueue(song);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${song.title} added to queue')),
                    );
                  },
                  value: 'queue',
                ),
                SonaraPopupMenuItem(
                  icon: IconsaxPlusLinear.play_add,
                  label: 'Play next',
                  value: 'next',
                ),
              ],
            ),
        ],
      ),
    );
  }
}
