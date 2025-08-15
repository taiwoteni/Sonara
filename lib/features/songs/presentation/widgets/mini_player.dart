import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sonara/core/components/lottie_widget.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/core/utils/services/audio_service.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/songs/utils/artwork_utils.dart';

/// A minimized music playback widget that displays only when a song is being played
/// MiniPlayer should be `60` in height if a song is being played
class MiniPlayer extends StatelessWidget {
  /// A minimized music playback widget that displays only when a song is being played
  /// MiniPlayer should be `60` in height if a song is being played
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Song?>(
      stream: getIt<AudioService>().currentSongStream,
      builder: (context, songSnapshot) {
        final currentSong = songSnapshot.data;
        if (currentSong == null) {
          return SizedBox.shrink();
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onTap: () {
              context.push('/song', extra: currentSong);
            },
            child: FutureBuilder(
              future: ArtworkUtils.getDominantColorFromArtwork(
                currentSong.artworkPath,
              ),
              builder: (context, asyncSnapshot) {
                return Container(
                  width: double.maxFinite,
                  height: 60,
                  color: !asyncSnapshot.hasData
                      ? AppColors.background
                      : asyncSnapshot.data,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ).copyWith(top: 5),
                        child: Row(
                          children: [
                            // Thumbnail from file path or fallback to low-quality data
                            FutureBuilder<String?>(
                              future: _getThumbnailPath(currentSong.id),
                              builder: (context, snapshot) => ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 43,
                                  height: 41,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    fit: StackFit.expand,
                                    children: [
                                      buildThumbnailImage(snapshot.data),
                                      StreamBuilder<bool>(
                                        stream: getIt<AudioService>()
                                            .isPlayingStream,
                                        builder: (context, snapshot) {
                                          final isPlaying =
                                              (snapshot.data ?? false);
                                          return Visibility(
                                            visible: isPlaying,
                                            child: SizedBox.expand(
                                              child: DecoratedBox(
                                                decoration: const BoxDecoration(
                                                  color: Colors.black26,
                                                ),
                                                child: LottieWidget(
                                                  src:
                                                      'assets/animations/playing_wave.json',
                                                  color: Colors.white,
                                                  size: Size.square(19),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Gap(12),
                            // Song title and artist
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSong.title,
                                    style: context.spaceGroteskBold.copyWith(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    currentSong.artist,
                                    style: context.lufgaMedium.copyWith(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Play/Pause control
                            StreamBuilder<bool>(
                              stream: getIt<AudioService>().isPlayingStream,
                              builder: (context, snapshot) {
                                final isPlaying = (snapshot.data ?? false);
                                return IconButton(
                                  icon: Icon(
                                    isPlaying
                                        ? IconsaxPlusBold.pause
                                        : IconsaxPlusBold.play,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                  onPressed: () async {
                                    log(
                                      "Pause icon tapped",
                                      name: "SongProgress",
                                    );
                                    if (isPlaying) {
                                      await getIt<AudioService>().pause();
                                    } else {
                                      await getIt<AudioService>().resume();
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      StreamBuilder<Duration>(
                        stream: getIt<AudioService>().positionStream,
                        builder: (context, positionSnapshot) {
                          return StreamBuilder<Duration>(
                            stream: getIt<AudioService>().durationStream,
                            builder: (context, durationSnapshot) {
                              final position =
                                  positionSnapshot.data ?? Duration.zero;
                              final duration =
                                  durationSnapshot.data ??
                                  Duration(seconds: currentSong.duration);
                              final progress = duration.inMilliseconds > 0
                                  ? position.inMilliseconds /
                                        duration.inMilliseconds
                                  : 0.0;
                              // log(
                              //   "Current Song progress is: $progress",
                              //   name: "SongProgress",
                              // );

                              return Container(
                                height: 2,
                                width: double.maxFinite,
                                color: Colors.white12,
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: progress.clamp(0.0, 1.0),
                                  child: Container(color: Colors.white),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildThumbnailImage(String? artowrkPath) {
    if (artowrkPath == null) {
      return defaultThumbnailWidget();
    }
    return Image.file(
      File(artowrkPath),
      width: double.maxFinite,
      height: double.maxFinite,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return defaultThumbnailWidget();
      },
    );
  }

  Widget defaultThumbnailWidget() {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: AppColors.background_2,
      alignment: Alignment.center,
      child: Icon(IconsaxPlusLinear.musicnote, color: Colors.white54, size: 21),
    );
  }

  Future<String?> _getThumbnailPath(String songId) async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final thumbnailPath = '${supportDir.path}/.thumbnails/$songId.jpg';
      final file = File(thumbnailPath);
      if (await file.exists()) {
        return thumbnailPath;
      }
      return null;
    } catch (e) {
      log('Error getting thumbnail path: $e', name: 'MiniPlayer');
      return null;
    }
  }
}
