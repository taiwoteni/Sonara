import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/core/utils/extensions/transforms_extensions.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/audio/presentation/widgets/thumbnail_background.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/services/audio_player_helper.dart';
import 'package:sonara/core/utils/services/audio_service.dart';
import 'package:sonara/features/songs/presentation/widgets/cd_artwork_widget.dart';
import 'package:sonara/features/songs/utils/artwork_utils.dart';
// import 'package:audio_waveforms/audio_waveforms.dart'; // COMMENTED OUT - Waveform functionality removed

class SongScreen extends StatefulWidget {
  final Song song;

  const SongScreen({super.key, required this.song});

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> with TickerProviderStateMixin {
  late Song song;
  late StreamSubscription currentSongSubscription;
  String? artworkPath;
  late AudioService audioService;

  late AnimationController rotationController;
  late Animation<double> rotationAnimation;

  Color dominantColor = AppColors.background_2;

  Color? secondaryColor;

  @override
  void initState() {
    song = widget.song;
    audioService = getIt<AudioService>();
    super.initState();
    rotationController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );
    rotationAnimation = Tween(begin: 0.0, end: 1.0).animate(rotationController);
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((
      timeStamp,
    ) async {
      getArtwork(song);
      initializeAudio();
      getArtworkColors(song);
      watchCurrentSong();
    });
  }

  void watchCurrentSong() {
    currentSongSubscription = audioService.currentSongStream.listen((
      event,
    ) async {
      log("Event received", name: 'SongScreen');
      if (event == null) return;

      // To prevent re-initializing when the same song is being played.
      if (event.id == song.id) return;

      if (!mounted) {
        log("Screen is not mounted", name: 'SongScreen');
        return;
      }
      log('Screen is mounted', name: 'SongScreen');

      // To refetch the new album cover, etc.
      await getArtwork(event);
      getArtworkColors(event);
      setState(() {
        song = event;
      });
    });
  }

  Future<void> initializeAudio() async {
    try {
      // Request notification permission for Android 13 and above
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        status = await Permission.notification.request();
        if (!status.isGranted) {
          log('Notification permission denied', name: 'SongScreen');
        }
      }

      String? currentSongId;
      await for (var value in audioService.currentSongIdStream.take(1)) {
        currentSongId = value;
      }
      if (currentSongId == song.id) {
        // If the current song is already playing via mini-player, do not replay it
        // await _extractWaveform(); // COMMENTED OUT - Waveform extraction
        log(
          "Current song is already playing via mini-player",
          name: "SongScreen",
        );
        return;
      }

      await AudioPlayerHelper.playSong(
        song,
        // highQualityArtworkData: _highQualityArtworkData,
      );
      // await _extractWaveform(); // COMMENTED OUT - Waveform extraction
    } catch (e) {
      log('Error initializing audio: $e', name: 'SongScreen');
    }
  }

  @override
  void dispose() {
    currentSongSubscription.cancel();
    rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThumbnailBackground(
      thumbnailData: artworkPath ?? song.artworkPath,
      padding: context.safeAreaInsets.copyWith(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                icon: Icon(
                  IconsaxPlusLinear.arrow_left_1,
                  size: 28,
                  weight: 1.5,
                ),
              ),

              Flexible(
                child: Align(
                  child: Text(
                    song.album.toUpperCase(),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: context.spaceGroteskBold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                icon: Icon(
                  IconsaxPlusLinear.more,
                  size: 25,
                  weight: 1.5,
                ).rotate(90),
              ),
            ],
          ),
          Gap(20),

          const Spacer(),

          // Song Artwork
          StreamBuilder<bool>(
            stream: audioService.isPlayingStream,
            builder: (context, snapshot) {
              final isPlaying = snapshot.data ?? false;
              if (isPlaying) {
                rotationController.repeat();
              } else {
                rotationController.stop();
              }
              return RotationTransition(
                turns: rotationAnimation,
                child: ClipOval(
                  child: Container(
                    width: context.screenSize.width * .76,
                    height: context.screenSize.width * .76,
                    padding: const EdgeInsets.all(3),
                    color: Colors.white,
                    child: CDArtworkWidget(
                      size: context.screenSize.width * .76,
                      artworkPath: song.artworkPath,
                      dominantColor: dominantColor,
                      secondaryColor: secondaryColor,
                      song: song,
                    ),
                  ),
                ),
              );
            },
          ),

          Gap(24),
          // Song Title
          Text(
            song.title,
            overflow: TextOverflow.fade,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          Gap(8),
          // Song Artist
          Text(
            song.artist,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Spacer(),

          // Progress Bar Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<Duration>(
                  stream: audioService.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return Text(
                      formatDuration(position.inSeconds),
                      style: context.spaceGroteskSemiBold,
                    );
                  },
                ),

                Flexible(
                  child: StreamBuilder<Duration>(
                    stream: audioService.positionStream,
                    builder: (context, positionSnapshot) {
                      return StreamBuilder<Duration>(
                        stream: audioService.durationStream,
                        builder: (context, durationSnapshot) {
                          final position =
                              positionSnapshot.data ?? Duration.zero;
                          final duration =
                              durationSnapshot.data ??
                              Duration(seconds: song.duration);

                          final progress = duration.inMilliseconds > 0
                              ? position.inMilliseconds /
                                    duration.inMilliseconds
                              : 0.0;

                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white54,
                              thumbColor: Colors.white,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              trackHeight: 3,
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12,
                              ),
                            ),
                            child: Slider(
                              value: progress.clamp(0.0, 1.0),
                              onChanged: (value) {
                                final newPosition = Duration(
                                  milliseconds:
                                      (value * duration.inMilliseconds).round(),
                                );
                                audioService.seek(newPosition);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                Text(
                  formatDuration(song.duration),
                  style: context.spaceGroteskSemiBold,
                ),
              ],
            ),
          ),
          Gap(20),

          // Controls Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder(
                  stream: audioService.shuffleStream,
                  builder: (context, snapshot) {
                    final shuffle = snapshot.data ?? false;

                    return IconButton(
                      onPressed: () => audioService.shuffle(!shuffle),
                      iconSize: 19,
                      icon: Icon(
                        IconsaxPlusBold.shuffle,
                        color: shuffle ? Colors.white : Colors.white60,
                      ),
                    );
                  },
                ),
                StreamBuilder<bool>(
                  stream: audioService.hasPreviousSongStream,
                  builder: (context, snapshot) {
                    final hasPrevious = snapshot.data ?? false;
                    return IconButton(
                      onPressed: hasPrevious
                          ? () => audioService.playPrevious()
                          : () => audioService.seek(Duration.zero),
                      iconSize: 19,
                      icon: Icon(IconsaxPlusBold.previous, color: Colors.white),
                    );
                  },
                ),
                StreamBuilder<bool>(
                  stream: audioService.isPlayingStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    return Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 19,
                        icon: Icon(
                          isPlaying
                              ? IconsaxPlusBold.pause
                              : IconsaxPlusBold.play,
                          color: Colors.black,
                        ),
                        onPressed: () async {
                          if (isPlaying) {
                            await audioService.pause();
                          } else {
                            await audioService.resume();
                          }
                        },
                      ),
                    );
                  },
                ),
                StreamBuilder<bool>(
                  stream: audioService.hasNextSongStream,
                  builder: (context, snapshot) {
                    final hasNext = snapshot.data ?? false;
                    return IconButton(
                      onPressed: hasNext ? () => audioService.playNext() : null,
                      iconSize: 19,
                      icon: Icon(
                        IconsaxPlusBold.next,
                        color: hasNext ? Colors.white : Colors.white30,
                      ),
                    );
                  },
                ),
                StreamBuilder(
                  stream: audioService.loopStream,
                  builder: (context, snapshot) {
                    final loopMode = snapshot.data ?? LoopMode.off;
                    return IconButton(
                      onPressed: () async {
                        if (loopMode == LoopMode.off) {
                          audioService.loop(LoopMode.one);
                          return;
                        }

                        if (loopMode == LoopMode.one) {
                          audioService.loop(LoopMode.all);
                          return;
                        }

                        audioService.loop(LoopMode.off);
                      },
                      iconSize: 19,
                      icon: Icon(
                        loopMode == LoopMode.one
                            ? HugeIcons.strokeRoundedRepeatOne01
                            : loopMode == LoopMode.all
                            ? HugeIcons.strokeRoundedRepeat
                            : HugeIcons.strokeRoundedRepeat,
                        color: loopMode == LoopMode.off
                            ? Colors.white60
                            : Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Gap(50),
        ],
      ),
    );
  }

  Future<void> getArtwork(Song song) async {
    log("Called [getArtwork] method", name: 'SongScreen');
    // First, check if high-quality artwork already exists in application support directory
    final cacheDir = await getApplicationSupportDirectory();
    final thumbnailDir = Directory('${cacheDir.path}/.thumbnails');

    // Create thumbnail directory if it doesn't exist.
    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }
    final filePath = '${thumbnailDir.path}/${song.id}.jpg';
    final file = File(filePath);

    // If the thumbnail file is not yet found, we would fetch and save.
    if (!await file.exists()) {
      final result = await MethodChannel(
        'com.sonara.audio_files',
      ).invokeMethod('getHighQualityArtwork', {'id': song.id});
      final artworkData = result['artworkData']?.toString() ?? '';

      if (artworkData.isEmpty) {
        log('Song does not have an artwork', name: 'SongScreen');
        setState(() => artworkPath = null);
        return;
      }

      // Save high-quality artwork to a persistent file in /.thumbnails directory
      final cleanedData = artworkData.replaceAll(RegExp(r'\s+'), '');
      final decodedData = const Base64Decoder().convert(cleanedData);
      await file.writeAsBytes(decodedData);
      log(
        'High-quality artwork saved to file: $filePath for ${widget.song.title}',
        name: 'SongScreen',
      );
      log(
        'High-quality artwork saved & loaded for ${widget.song.title}, Data length: ${artworkData.length}',
        name: 'SongScreen',
      );

      setState(() => artworkPath = filePath);
      return;
    }

    log(
      'Using existing high-quality artwork file: $filePath for ${widget.song.title}',
      name: 'SongScreen',
    );
    setState(() => artworkPath = filePath);
    return;
  }

  Future<void> getArtworkColors(Song song) async {
    if (File(song.artworkPath).existsSync()) {
      final colors = await ArtworkUtils.getDominantGradientColorsFromArtwork(
        song.artworkPath,
      );
      final color = await ArtworkUtils.getDominantColorFromArtwork(
        song.artworkPath,
      );
      if (mounted) {
        setState(() {
          dominantColor = color;
          secondaryColor = colors.last;
        });
      }

      return;
    }
    setState(() {
      dominantColor = AppColors.background_2;
      secondaryColor = null;
    });
  }

  String formatDuration(int duration) {
    // Check if duration is likely in milliseconds (e.g., exceeds 24 hours in seconds)
    int seconds = duration;
    if (duration > 86400) {
      // 24 hours in seconds
      log(
        'Duration $duration seems to be in milliseconds, converting to seconds',
        name: 'SongScreen',
      );
      seconds = (duration / 1000).round();
    }

    if (seconds >= 3600) {
      final hours = seconds ~/ 3600;
      final remainingMinutes = (seconds % 3600) ~/ 60;
      final remainingSeconds = seconds % 60;
      return '$hours:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }
}
