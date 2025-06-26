import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/core/utils/services/audio_service.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Song?>(
      stream: getIt<AudioService>().currentSongStream,
      builder: (context, songSnapshot) {
        final currentSong = songSnapshot.data;
        // log(
        //   'Current song stream updated: ${currentSong?.title ?? "No song"}',
        //   name: 'HomeScreen',
        // );
        if (currentSong == null) {
          return SizedBox.shrink();
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: GestureDetector(
            onTap: () {
              context.push('/song', extra: currentSong);
            },
            child: Container(
              width: double.maxFinite,
              color: AppColors.background,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        // Low-quality thumbnail
                        if (currentSong.thumbnailData.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 46,
                                height: 46,
                                child: buildThumbnailImage(
                                  currentSong.thumbnailData,
                                  currentSong.title,
                                ),
                              ),
                            ),
                          ),
                        // Song title and artist
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSong.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                currentSong.artist,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
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
                                size: 24,
                              ),
                              onPressed: () async {
                                log("Pause icon tapped", name: "SongProgress");
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
                            height: 4,
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
            ),
          ),
        );
      },
    );
  }

  Widget buildThumbnailImage(String thumbnailData, String title) {
    try {
      // Clean the base64 string by removing any whitespace or line breaks
      final cleanedData = thumbnailData.replaceAll(RegExp(r'\s+'), '');
      // Attempt to decode the cleaned base64 string
      final decodedData = const Base64Decoder().convert(cleanedData);
      return Image.memory(
        decodedData,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.album, color: AppColors.purple, size: 40);
        },
      );
    } catch (e) {
      return const Icon(Icons.album, color: AppColors.purple, size: 40);
    }
  }
}
