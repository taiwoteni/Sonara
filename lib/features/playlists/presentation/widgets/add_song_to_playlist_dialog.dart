import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/playlists/presentation/providers/playlist_notifier.dart';
import 'package:sonara/features/playlists/presentation/widgets/select_playlist_widget.dart';

class AddSongToPlaylistDialog extends ConsumerStatefulWidget {
  final VoidCallback? onCancel;
  final Song song;

  const AddSongToPlaylistDialog({super.key, this.onCancel, required this.song});

  @override
  ConsumerState<AddSongToPlaylistDialog> createState() =>
      _AddSongToPlaylistDialogState();
}

class _AddSongToPlaylistDialogState
    extends ConsumerState<AddSongToPlaylistDialog> {
  bool isLoading = false;
  List<String> selectedIds = [];

  @override
  Widget build(BuildContext context) {
    final playlists = ref.watch(playlistProvider);
    final playlistsNotifier = ref.watch(playlistProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add To Playlist',
            style: context.lufgaBold.copyWith(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(10),
          const Text(
            "Select the playlists you'll like to add the song to",
            style: TextStyle(color: Colors.white70, fontSize: 14.0),
          ),
          Gap(20.0),

          ListView.separated(
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final playlist = playlists[index];

              return SelectPlaylistWidget(
                playlist: playlist,
                checked: selectedIds.contains(playlist.id),
                onChecked: (value) => setState(() {
                  if (value) {
                    selectedIds.add(playlist.id);
                    return;
                  }
                  selectedIds.remove(playlist.id);
                }),
              );
            },
            separatorBuilder: (context, index) => Gap(0),
            itemCount: playlists.length,
          ),

          Gap(24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  if (widget.onCancel != null) {
                    widget.onCancel!();
                  }
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 13, color: Colors.white60),
                ),
              ),
              const SizedBox(width: 16.0),

              ElevatedButton(
                onPressed: () async {
                  setState(() => isLoading = true);

                  for (final id in selectedIds) {
                    await playlistsNotifier.addSongToPlaylist(id, widget.song);
                  }
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  isLoading ? 'Loading...' : 'Confirm',
                  style: context.lufgaSemiBold.copyWith(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
