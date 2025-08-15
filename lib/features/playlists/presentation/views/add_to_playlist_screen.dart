import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/components/empty_screen.dart';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/core/utils/dialog_manager.dart';
import 'package:sonara/core/utils/extensions/bool_extensions.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/core/utils/extensions/transforms_extensions.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/playlists/presentation/providers/playlist_notifier.dart';
import 'package:sonara/features/playlists/presentation/widgets/playlist_widget.dart';

import '../widgets/create_playlist_dialog.dart';

class AddToPlaylistScreen extends ConsumerStatefulWidget {
  /// The song to be added to the selected playlists
  final Song song;
  const AddToPlaylistScreen({super.key, required this.song});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddToPlaylistScreenState();
}

class _AddToPlaylistScreenState extends ConsumerState<AddToPlaylistScreen> {
  /// The List of the Ids of playlists that `currently` contain this song (`widget.song`)
  List<String> playlistIdsThatContainThisSong = [];

  /// The List of the Ids of playlists that `initially` contained
  /// this song (`widget.song`) before any modifications were made by the user
  List<String> initialPlaylistIdsThatContainThisSong = [];

  /// The List of playlists the user has (updates when the user creates new ones from
  /// this screen)
  List<Playlist> playlists = [];

  /// If button is loading
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      setState(
        () => initialPlaylistIdsThatContainThisSong = ref
            .read(playlistProvider)
            .where(
              (element) =>
                  element.songs.any((element) => element.id == widget.song.id),
            )
            .map((e) => e.id)
            .toList(),
      );
      fetchPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlistsNotifier = ref.watch(playlistProvider.notifier);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: context.safeAreaInsets.copyWith(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(IconsaxPlusLinear.arrow_left, size: 34),
                ).translate(dx: -7),
                IconButton(
                  tooltip: 'New Playlist',
                  onPressed: () => createPlaylist(),
                  icon: Icon(IconsaxPlusLinear.add, size: 34),
                ),
              ],
            ),
            Gap(3),
            Text(
              "Add to Playlist".toUpperCase(),
              style: context.lufgaExtraBold.copyWith(fontSize: 25),
            ),
            Gap(16),
            if (playlists.isEmpty)
              EmptyList(
                icon: 'assets/illustrations/playlist.png',
                isSvg: false,
                iconSize: Size.fromHeight(180),
                label: 'Create your first playlist',
                height: context.screenSize.height * .75,
              )
            else
              ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  log(
                    'Playlist ${index + 1}, ID: ${playlist.id}',
                    name: 'PlaylistsList',
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: PlaylistWidget.selectable(
                      playlist: playlist,
                      selected: playlistIdsThatContainThisSong.contains(
                        playlist.id,
                      ),
                      onToggle: (value) {
                        if (!value) {
                          setState(
                            () => playlistIdsThatContainThisSong.remove(
                              playlist.id,
                            ),
                          );
                          return;
                        }
                        setState(
                          () => playlistIdsThatContainThisSong.add(playlist.id),
                        );
                      },
                    ),
                  );
                },
              ),

            if (playlists.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: AnimatedOpacity(
                  curve: Curves.ease,
                  duration: Durations.long4,
                  opacity: playlistIdsThatContainThisSong.isEmpty ? 0.2 : 1,
                  child: ElevatedButton(
                    onPressed: playlistIdsThatContainThisSong.isEmpty
                        ? () {}
                        : () async {
                            setState(() => isLoading = true);
                            await Future.delayed(Duration(seconds: 2));

                            // Add song to playlists that have contain this song
                            for (final playlist
                                in playlistIdsThatContainThisSong) {
                              await playlistsNotifier.addSongToPlaylist(
                                playlist,
                                widget.song,
                              );
                            }
                            for (final removedPlaylist
                                in initialPlaylistIdsThatContainThisSong
                                    .whereNot(
                                      (element) =>
                                          playlistIdsThatContainThisSong
                                              .contains(element),
                                    )) {
                              await playlistsNotifier.removeSongFromPlaylist(
                                removedPlaylist,
                                widget.song.id,
                              );
                            }
                            setState(() => isLoading = false);
                            context.pop();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      fixedSize: Size(double.maxFinite, 55),
                      enableFeedback: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: isLoading
                        ? SpinKitFadingFour(color: Colors.black, size: 16)
                        : Text(
                            'Done',
                            style: context.lufgaSemiBold.copyWith(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void fetchPlaylists() {
    final existingAddedPlaylists = ref
        .read(playlistProvider)
        .where(
          (element) =>
              element.songs.any((element) => element.id == widget.song.id),
        )
        .map((e) => e.id)
        .toList();

    setState(() {
      playlistIdsThatContainThisSong = existingAddedPlaylists;
      playlists = ref
          .read(playlistProvider)
          .sorted(
            (a, b) => existingAddedPlaylists
                .contains(b.id)
                .compareTo(existingAddedPlaylists.contains(a.id)),
          );
    });
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
              await Future.delayed(Durations.extralong4);
              await ref.read(playlistProvider.notifier).createPlaylist(text);
              load(false);
              fetchPlaylists();
              if (!context.mounted) return;
              context.pop();
            },
          ),
        );
      },
    );
  }
}
