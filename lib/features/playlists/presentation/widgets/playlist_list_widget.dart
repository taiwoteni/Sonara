import 'package:flutter/material.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/playlists/presentation/widgets/playlist_widget.dart';

class PlaylistListWidget extends StatelessWidget {
  final List<Playlist> playlists;
  final Function(Playlist)? onPlaylistTap;

  const PlaylistListWidget({
    Key? key,
    required this.playlists,
    this.onPlaylistTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return const Center(
        child: Text(
          'No playlists found',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
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
