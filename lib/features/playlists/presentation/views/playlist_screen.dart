import 'package:flutter/material.dart';
import 'package:sonara/features/songs/presentation/widgets/songs_list.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';

class PlaylistScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${playlist.songs.length} songs',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16.0),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // TODO: Implement add song to playlist functionality
                      },
                      tooltip: 'Add Song',
                    ),
                    IconButton(
                      icon: const Icon(Icons.file_download),
                      onPressed: () {
                        // TODO: Implement export playlist functionality
                      },
                      tooltip: 'Export Playlist',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(child: SongsList(songs: playlist.songs)),
          ],
        ),
      ),
    );
  }
}
