import 'package:flutter/material.dart';
import 'package:sonara/core/components/empty_screen.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/playlists/presentation/widgets/playlist_widget.dart';

class PlaylistList extends StatelessWidget {
  final List<Playlist> playlists;
  final Function(Playlist)? onPlaylistTap;

  const PlaylistList({super.key, required this.playlists, this.onPlaylistTap});

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return EmptyList(
        icon: 'assets/illustrations/empty_1.svg',
        iconSize: Size.fromHeight(180),
        label: 'No playlists found',
        height: context.screenSize.height * .7,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: PlaylistWidget(
            playlist: playlist,
            onTap: () {
              if (onPlaylistTap != null) {
                onPlaylistTap!(playlist);
              }
            },
          ),
        );
      },
    );
  }
}
