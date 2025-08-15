import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/utils/dialog_manager.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/features/playlists/presentation/providers/playlist_notifier.dart';
import 'package:sonara/features/playlists/presentation/widgets/create_playlist_dialog.dart';
import 'package:sonara/features/playlists/presentation/widgets/playlist_list.dart';

class PlaylistsPage extends ConsumerWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistProvider);
    final playlistNotifier = ref.read(playlistProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: context.safeAreaInsets.copyWith(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your playlists".toUpperCase(),
                  style: context.lufgaExtraBold.copyWith(fontSize: 25),
                ),
                Row(
                  spacing: 5,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(IconsaxPlusLinear.search_normal),
                    ),
                    IconButton(
                      tooltip: 'New Playlist',
                      onPressed: () =>
                          createPlaylist(context, playlistNotifier),
                      icon: Icon(IconsaxPlusLinear.add, size: 34),
                    ),
                  ],
                ),
              ],
            ),
            Gap(16),
            PlaylistList(
              playlists: playlists,
              onPlaylistTap: (playlist) {
                context.push('/home/playlists/${playlist.id}', extra: playlist);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createPlaylist(
    BuildContext context,
    PlaylistNotifier playlistNotifier,
  ) async {
    await DialogManager.showCustomDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: CreatePlaylistDialog(
            onCancel: () => context.pop(),
            onCreate: (text, load) async {
              load(true);
              await Future.delayed(Durations.extralong4);
              await playlistNotifier.createPlaylist(text);
              load(false);
              if (!context.mounted) return;
              context.pop();
            },
          ),
        );
      },
    );
  }
}
