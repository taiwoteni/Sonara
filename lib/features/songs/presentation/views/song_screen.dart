import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
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
// import 'package:audio_waveforms/audio_waveforms.dart'; // COMMENTED OUT - Waveform functionality removed

class SongScreen extends StatefulWidget {
  final Song song;

  const SongScreen({super.key, required this.song});

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  late Song song;
  String _highQualityArtworkData = '';
  bool _isLoadingArtwork = true;
  late AudioService audioService;

  // COMMENTED OUT - Waveform related variables
  // late PlayerController _playerController;
  // List<double> _waveformData = [];
  // bool _isWaveformReady = false;

  @override
  void initState() {
    song = widget.song;
    audioService = getIt<AudioService>();
    // _playerController = PlayerController(); // COMMENTED OUT - Waveform controller
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((
      timeStamp,
    ) async {
      await _loadHighQualityArtwork();
      _initializeAudio(); // Note: Will not replay song if already playing via mini-player
    });
  }

  @override
  void dispose() {
    // _playerController.dispose(); // COMMENTED OUT - Waveform controller disposal
    super.dispose();
  }

  Future<void> _initializeAudio() async {
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
        highQualityArtworkData: _highQualityArtworkData,
      );
      // await _extractWaveform(); // COMMENTED OUT - Waveform extraction
    } catch (e) {
      log('Error initializing audio: $e', name: 'SongScreen');
    }
  }

  Future<void> _loadHighQualityArtwork() async {
    try {
      // First, check if high-quality artwork already exists in application support directory
      final cacheDir = await getApplicationSupportDirectory();
      final filePath =
          '${cacheDir.path}/high_quality_artwork_${widget.song.id}.jpg';
      final file = File(filePath);

      if (await file.exists()) {
        log(
          'Using existing high-quality artwork file: $filePath for ${widget.song.title}',
          name: 'SongScreen',
        );
        // Read the file data to display in UI
        final fileData = await file.readAsBytes();
        final base64Data = base64Encode(fileData);
        setState(() {
          _highQualityArtworkData = base64Data;
          _isLoadingArtwork = false;
        });
        log(
          'High-quality artwork loaded from existing file for ${widget.song.title}, Data length: ${base64Data.length}',
          name: 'SongScreen',
        );
        return;
      }

      // If file doesn't exist, load new artwork data
      final result = await MethodChannel(
        'com.sonara.audio_files',
      ).invokeMethod('getHighQualityArtwork', {'id': widget.song.id});
      final artworkData = result['artworkData'] ?? '';
      setState(() {
        _highQualityArtworkData = artworkData;
        _isLoadingArtwork = false;
      });
      if (artworkData.isNotEmpty) {
        // Save high-quality artwork to a persistent file
        final cleanedData = artworkData.replaceAll(RegExp(r'\s+'), '');
        final decodedData = const Base64Decoder().convert(cleanedData);
        await file.writeAsBytes(decodedData);
        log(
          'High-quality artwork saved to file: $filePath for ${widget.song.title}',
          name: 'SongScreen',
        );
      }
      log(
        'High-quality artwork loaded for ${widget.song.title}, Data length: ${artworkData.length}',
        name: 'SongScreen',
      );
    } catch (e) {
      log(
        'Error loading high-quality artwork for ${widget.song.title}: $e',
        name: 'SongScreen',
      );
      setState(() {
        _isLoadingArtwork = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThumbnailBackground(
      thumbnailData: widget.song.thumbnailData,
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
          ClipOval(
            child: Container(
              width: context.screenSize.width * .76,
              height: context.screenSize.width * .76,
              padding: const EdgeInsets.all(3),
              color: _isLoadingArtwork ? Colors.transparent : Colors.white,
              child: ClipOval(
                child: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isLoadingArtwork
                        ? Colors.transparent
                        : Colors.deepPurple.shade700,
                  ),
                  child: _isLoadingArtwork
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : _highQualityArtworkData.isNotEmpty
                      ? _buildThumbnailImage(
                          _highQualityArtworkData,
                          widget.song.title,
                        )
                      : widget.song.thumbnailData.isNotEmpty
                      ? _buildThumbnailImage(
                          widget.song.thumbnailData,
                          widget.song.title,
                        )
                      : const Icon(
                          IconsaxPlusBold.headphone,
                          color: Colors.white,
                          size: 130,
                        ),
                ),
              ),
            ),
          ),

          Gap(24),
          // Song Title
          Text(
            widget.song.title,
            overflow: TextOverflow.fade,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          Gap(8),
          // Song Artist
          Text(
            song.artist,
            style: const TextStyle(fontSize: 18, color: Colors.white70),
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
                      icon: Icon(
                        IconsaxPlusBold.shuffle,
                        color: shuffle ? Colors.white : Colors.white60,
                      ),
                    );
                  },
                ),
                Icon(IconsaxPlusBold.previous),
                StreamBuilder<bool>(
                  stream: audioService.isPlayingStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
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
                Icon(IconsaxPlusBold.next),
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

  /// Helper method to build thumbnail image with robust error handling
  Widget _buildThumbnailImage(String thumbnailData, String title) {
    try {
      // Clean the base64 string by removing any whitespace or line breaks
      final cleanedData = thumbnailData.replaceAll(RegExp(r'\s+'), '');
      // Attempt to decode the cleaned base64 string
      final decodedData = const Base64Decoder().convert(cleanedData);
      return Image.memory(
        decodedData,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          log(
            'Error rendering thumbnail for $title: $error',
            error: error,
            name: 'SongScreen',
          );
          if (stackTrace != null) {
            log('Stack trace: $stackTrace');
          }
          return const Icon(Icons.album, color: AppColors.purple, size: 150);
        },
      );
    } catch (e, stackTrace) {
      log(
        'Exception decoding base64 for $title: $e',
        error: e,
        name: 'SongScreen',
      );
      log('Stack trace: $stackTrace', error: e, name: 'SongScreen');
      return const Icon(Icons.album, color: AppColors.purple, size: 150);
    }
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

// ============================================================================
// COMMENTED OUT AUDIO WAVEFORM FUNCTIONALITY
// ============================================================================
// The following code was previously used for audio waveform visualization
// It has been commented out and organized here for potential future use
// ============================================================================

/*
// WAVEFORM EXTRACTION METHOD
Future<void> _extractWaveform() async {
  try {
    await _playerController.preparePlayer(
      path: song.path,
      shouldExtractWaveform: true,
    );

    // Wait for waveform extraction to complete
    await Future.delayed(const Duration(milliseconds: 500));

    // Get the extracted waveform data
    final waveformData = _playerController.waveformData;

    if (waveformData.isNotEmpty) {
      setState(() {
        _waveformData = waveformData;
        _isWaveformReady = true;
      });
      log(
        'Waveform extracted successfully: ${waveformData.length} points',
        name: 'SongScreen',
      );
    } else {
      log(
        'Waveform extraction failed or returned empty data',
        name: 'SongScreen',
      );
      // Generate fallback waveform data
      _generateFallbackWaveform();
    }

    // Sync player controller with audio service position
    _syncPlayerPosition();
  } catch (e) {
    log('Error extracting waveform: $e', name: 'SongScreen');
    _generateFallbackWaveform();
  }
}

// FALLBACK WAVEFORM GENERATION METHOD
void _generateFallbackWaveform() {
  // Generate a simple waveform pattern as fallback
  final fallbackData = List.generate(100, (index) {
    return (0.3 + (0.7 * (index % 10) / 10)) *
        (1 + 0.5 * (index % 3 == 0 ? 1 : 0));
  });

  setState(() {
    _waveformData = fallbackData;
    _isWaveformReady = true;
  });
  log('Generated fallback waveform data', name: 'SongScreen');
}

// PLAYER POSITION SYNCHRONIZATION METHOD
void _syncPlayerPosition() {
  // Listen to audio service position and update player controller
  _audioService.positionStream.listen((position) {
    if (_playerController.playerState == PlayerState.initialized ||
        _playerController.playerState == PlayerState.playing ||
        _playerController.playerState == PlayerState.paused) {
      _playerController.seekTo(position.inMilliseconds);
    }
  });
}

// WAVEFORM WIDGET IMPLEMENTATION
AudioFileWaveforms(
  size: Size(double.maxFinite, 40),
  playerController: _playerController,
  enableSeekGesture: true,
  waveformType: WaveformType.fitWidth,
  waveformData: _waveformData,
  continuousWaveform: false,
  padding: EdgeInsets.zero,
  margin: EdgeInsets.zero,
  animationCurve: Curves.ease,
  playerWaveStyle: const PlayerWaveStyle(
    scaleFactor: 30,
    spacing: 8,
    waveThickness: 3,
    showSeekLine: true,
    seekLineColor: Colors.white,
    seekLineThickness: 2,
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
  ),
)

// WAVEFORM LOADING STATE WIDGET
Container(
  height: 40,
  alignment: Alignment.center,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: const AlwaysStoppedAnimation<Color>(
            Colors.white54,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Text(
        'Loading waveform...',
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
    ],
  ),
)
*/
