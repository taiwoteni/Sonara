import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/dialog_manager.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/core/utils/extensions/transforms_extensions.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/features/home/presentation/widgets/search_bar.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/create_playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/create_playlist_params.dart';
import 'package:sonara/features/playlists/presentation/widgets/create_playlist_dialog.dart';
import 'package:sonara/features/playlists/presentation/widgets/playlist_list.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  // This is a placeholder list of playlists for demonstration purposes
  final List<Playlist> dummyPlaylists = [
    Playlist(id: '1', name: 'Favorites', songs: []),
    Playlist(id: '2', name: 'Chill Vibes', songs: []),
    Playlist(id: '3', name: 'Workout Mix', songs: []),
  ];
  late CreatePlaylist createPlaylistUseCase;

  @override
  void initState() {
    createPlaylistUseCase = getIt<CreatePlaylist>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.safeAreaInsets.copyWith(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(12),
          SonaraSearchBar(hintText: 'Search for playlists...'),
          Gap(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Playlists".toUpperCase(),
                style: context.lufgaBold.copyWith(fontSize: 16),
              ),
              TextButton(
                onPressed: createPlaylist,
                child: RichText(
                  text: TextSpan(
                    style: context.lufgaMedium.copyWith(color: Colors.white70),
                    children: [
                      TextSpan(text: "Create "),
                      WidgetSpan(
                        child: Icon(
                          IconsaxPlusLinear.add,
                          color: Colors.white70,
                          size: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ).translate(dy: -15),
            ],
          ),
          Gap(16),
          PlaylistList(
            playlists: dummyPlaylists,
            onPlaylistTap: (playlist) {
              context.push('/playlist/${playlist.id}', extra: playlist);
            },
          ),
        ],
      ),
    );
  }

  Future<void> createPlaylist() async {
    await DialogManager.showCustomDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: CreatePlaylistDialog(
            onCancel: () => context.pop(),
            onCreate: (text, load) async {
              load(true);
              final result = await createPlaylistUseCase.call(
                CreatePlaylistParams(name: text),
              );

              final data = result.fold(
                (failure) {
                  log(
                    "Failed to create playlist",
                    name: 'PlaylistsPage',
                    error: failure,
                  );
                  return null;
                },
                (r) {
                  setState(() {
                    dummyPlaylists.add(r);
                  });
                  return r;
                },
              );

              load(false);
              if (!mounted) return;
              context.pop();
            },
          ),
        );
      },
    );
  }
}
