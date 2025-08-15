import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/core/utils/extensions/padding_extensions.dart';
import 'package:sonara/core/utils/extensions/transforms_extensions.dart';
import 'package:sonara/core/utils/services/audio_player_helper.dart';
import 'package:sonara/core/utils/services/audio_service.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/songs/presentation/providers/song_providers.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/songs/presentation/widgets/songs_list.dart';
import 'package:sonara/features/songs/utils/artwork_utils.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  final Playlist playlist;
  const PlaylistScreen({super.key, required this.playlist});

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen>
    with TickerProviderStateMixin {
  late List<Song> songs;
  ScrollController scrollController = ScrollController();
  bool isCollapsed = false;
  static const double expandedHeight = 200 + 40;
  static const double toolbarHeight = 70;
  static const double fabSize = 56;
  double fabTopOffset = expandedHeight - (fabSize / 2);
  late AnimationController fabAnimationController;
  late Animation<double> fabPositionAnimation;
  late AnimationController playIconAnimationController;
  late Animation<double> playIconAnimation;
  late Animation<double> fabScaleAnimation;
  StreamSubscription<bool>? isPlayingSubscription;
  bool isPlaying = false;

  @override
  void initState() {
    songs = widget.playlist.songs;
    fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    playIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    playIconAnimation = playIconAnimationController;
    fabPositionAnimation =
        Tween<double>(
          begin: expandedHeight - 40,
          end: toolbarHeight - (fabSize),
        ).animate(
          CurvedAnimation(
            parent: fabAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    fabScaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(parent: fabAnimationController, curve: Curves.easeInOut),
    );

    super.initState();
    scrollController.addListener(fabPositionListener);
    scrollController.addListener(scrollListener);

    // Listen to playback state changes
    isPlayingSubscription = getIt<AudioService>().isPlayingStream.listen((
      playing,
    ) {
      getIt<AudioService>().currentPlaylistIdStream.listen((playlist) {
        if (mounted && playlist == widget.playlist.id) {
          setState(() {
            isPlaying = playing;
            if (playing) {
              playIconAnimationController.forward();
            } else {
              playIconAnimationController.reverse();
            }
          });
        }
      });
    });

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      setState(() => songs = getPlaylistsSongs());
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(fabPositionListener);
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    isPlayingSubscription?.cancel();
    fabAnimationController.dispose();
    playIconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: scrollController,
            slivers: [
              heading(),
              SliverFillRemaining(child: songsList()),
            ],
          ),
          fabWidget(),
        ],
      ),
    );
  }

  Widget heading() {
    return FutureBuilder(
      future: ArtworkUtils.getDominantGradientColorsFromArtwork(
        songs[0].artworkPath,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SliverGap(0);
        }
        return SliverAppBar(
          expandedHeight: expandedHeight,
          collapsedHeight: toolbarHeight,
          automaticallyImplyLeading: false,
          floating: false,
          pinned: true,
          backgroundColor: snapshot.data?[0],
          toolbarHeight: toolbarHeight,
          title: !isCollapsed
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.playlist.name),
                    Text(
                      "${songs.length} Song${songs.length != 1 ? 's' : ''}",
                      style: context.lufgaRegular.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
          titleTextStyle: context.spaceGroteskBold.copyWith(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),

          leadingWidth: 50 + 5 + 27,
          titleSpacing: 20,
          leading: !isCollapsed
              ? null
              : Row(
                  spacing: 5,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        IconsaxPlusLinear.arrow_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    Container(
                      width: 29,
                      height: 29,
                      decoration: BoxDecoration(
                        boxShadow: kElevationToShadow[24],
                      ),
                      child: artworkCollage(),
                    ),
                  ],
                ),

          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              width: double.maxFinite,
              height: 200 + 40,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: snapshot.data ?? [],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.maxFinite,
                      height: 240,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.background.withValues(alpha: .008),
                            AppColors.background.withValues(alpha: .001),
                            AppColors.background.withValues(alpha: .1),
                            AppColors.background.withValues(alpha: .6),

                            AppColors.background,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: context.safeAreaInsets.top + 5,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(IconsaxPlusLinear.arrow_left, size: 34),
                    ).translate(dx: -7),
                  ),
                  Positioned(
                    bottom: 20 + 40,
                    left: 16,
                    right: 16,
                    child: Row(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            boxShadow: kElevationToShadow[24],
                          ),
                          child: artworkCollage(),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: 2,
                          children: [
                            Text(
                              widget.playlist.name,
                              style: context.spaceGroteskBold.copyWith(
                                fontSize: 35,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              "${songs.length} Song${songs.length != 1 ? 's' : ''}, ${getTotalDurationString()}",
                              style: context.lufgaRegular.copyWith(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ).only(bottom: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget fabWidget() {
    return AnimatedBuilder(
      animation: fabAnimationController,
      builder: (context, child) {
        return Positioned(
          top: fabTopOffset,
          right: 16,
          child: Transform.scale(
            scale: fabScaleAnimation.value,
            child: FloatingActionButton(
              shape: const StadiumBorder(),
              onPressed: play,
              backgroundColor: isCollapsed ? Colors.transparent : Colors.white,
              elevation: isCollapsed ? 0 : 12,
              heroTag: "animatedFab",
              highlightElevation: isCollapsed ? 0 : null,

              child: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: playIconAnimation,
                size: 32,
                color: isCollapsed ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget artworkCollage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: FutureBuilder(
        future: ArtworkUtils.collage(playlist: widget.playlist),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Placeholder();
          }

          return snapshot.data!;
        },
      ),
    );
  }

  Widget songsList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16).copyWith(top: 20),
      child: SongsList(songs: songs),
    );
  }

  void scrollListener() {
    // Check if app bar is collapsed
    if (scrollController.hasClients) {
      bool isCollapsed =
          scrollController.offset > (expandedHeight - toolbarHeight);
      if (isCollapsed != this.isCollapsed) {
        setState(() {
          this.isCollapsed = isCollapsed;
        });
      }
    }
  }

  void fabPositionListener() {
    if (scrollController.hasClients) {
      double offset = scrollController.offset;
      double currentAppBarHeight = (expandedHeight - offset).clamp(
        toolbarHeight - (fabSize / 4),
        expandedHeight,
      );
      double progress = (offset / (expandedHeight - 40 - toolbarHeight)).clamp(
        0.0,
        1.0,
      );

      fabAnimationController.value = progress;

      setState(() {
        fabTopOffset = currentAppBarHeight - (fabSize / 2);
      });
    }
  }

  Future<void> play() async {
    log('Animated FAB pressed!', name: 'PlaylistScreen');

    // Check if this playlist is currently playing
    final currentPlaylistId =
        await getIt<AudioService>().currentPlaylistIdStream.first;
    final isCurrentPlaylist = currentPlaylistId == widget.playlist.id;

    if (isCurrentPlaylist && isPlaying) {
      // If this playlist is playing, pause it
      await getIt<AudioService>().pause();
    } else if (isCurrentPlaylist && !isPlaying) {
      // If this playlist was playing and it was paused, resume it
      await getIt<AudioService>().resume();
    } else {
      // Otherwise, play this playlist
      await AudioPlayerHelper.playPlaylist(songs, widget.playlist.id, 0);
    }
  }

  List<Song> getPlaylistsSongs() {
    final songState = ref.watch(songProvider);
    if (songState.songs.isNotEmpty) {
      return widget.playlist.songs.map((playlistSong) {
        return songState.songs.firstWhere(
          (song) => song.id == playlistSong.id,
          orElse: () => playlistSong,
        );
      }).toList();
    }

    return widget.playlist.songs;
  }

  /// Calculates the total duration of all songs in the playlist
  /// and returns a formatted string like "1hr 20mins" or "40sec"
  String getTotalDurationString() {
    if (songs.isEmpty) return '0sec';

    int totalSeconds = songs.fold(
      0,
      (sum, song) => sum + (song.duration / 1000).toInt(),
    );

    if (totalSeconds < 60) {
      return '$totalSeconds${totalSeconds == 1 ? ' sec' : ' sec'}';
    } else if (totalSeconds < 3600) {
      int minutes = (totalSeconds / 60).floor();
      return '$minutes${minutes == 1 ? ' min' : ' mins'}';
    } else {
      int hours = (totalSeconds / 3600).floor();
      int remainingMinutes = ((totalSeconds % 3600) / 60).floor();

      if (remainingMinutes == 0) {
        return '$hours${hours == 1 ? ' hr' : ' hrs'}';
      } else {
        return '$hours${hours == 1 ? ' hr' : ' hrs'} $remainingMinutes${remainingMinutes == 1 ? ' min' : ' mins'}';
      }
    }
  }
}
