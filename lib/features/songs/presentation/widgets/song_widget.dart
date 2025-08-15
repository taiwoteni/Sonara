import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sonara/core/components/lottie_widget.dart';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/core/utils/extensions/transforms_extensions.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/songs/data/models/sonara_popup_menu_item.dart';

/// A custom list item widget for displaying songs
class SongWidget extends StatelessWidget {
  /// The audio file to display
  final Song audio;

  /// Callback when the item is tapped
  final VoidCallback? onTap;

  /// Shows playing animation when the song is currently being played.
  final bool isPlaying;

  /// Callback when the more options button is tapped
  final List<PopupMenuEntry<String>> Function(Song song)? items;

  const SongWidget({
    super.key,
    required this.audio,
    this.onTap,
    this.items,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final menus = items == null ? null : items!(audio);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 0),
      decoration: BoxDecoration(
        color: !isPlaying ? Colors.transparent : Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            // Album photo with play icon overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                width: 46,
                height: 46,
                child: FutureBuilder<String?>(
                  future: _getThumbnailPath(audio.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Image.file(
                        File(snapshot.data!),
                        fit: BoxFit.cover,
                        width: double.maxFinite,
                        height: double.maxFinite,
                        errorBuilder: (context, error, stackTrace) {
                          return audio.thumbnailData.isNotEmpty
                              ? _buildThumbnailImage(
                                  audio.thumbnailData,
                                  audio.title,
                                )
                              : defaultThumbnailWidget();
                        },
                      );
                    } else if (audio.thumbnailData.isNotEmpty) {
                      return _buildThumbnailImage(
                        audio.thumbnailData,
                        audio.title,
                      );
                    } else {
                      return defaultThumbnailWidget();
                    }
                  },
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Song info (title, artist, duration)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    audio.title,
                    style: context.lufgaSemiBold.copyWith(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(1),
                  Row(
                    spacing: 7,
                    children: [
                      if (isPlaying) ...[
                        LottieWidget(
                          src: 'assets/animations/playing_wave.json',
                          color: Colors.white,
                          size: Size.square(19),
                        ),
                        Text(
                          "Now Playing",
                          style: context.lufgaSemiBold.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ] else ...[
                        Text(
                          _formatDuration(audio.duration),
                          style: context.lufgaMedium.copyWith(
                            color: Colors.white70,
                            fontSize: 9,
                          ),
                        ),
                        Text(
                          "•",
                          style: context.spaceGroteskRegular.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            audio.artist,
                            style: context.lufgaMedium.copyWith(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            if (menus != null && menus.isNotEmpty)
              PopupMenuButton<String>(
                // onSelected: onMenuSelected,
                itemBuilder: (context) => menus,
                onCanceled: () => log("Popup Menu Closed", name: 'SongWidget'),
                onOpened: () => log("Popup Menu Opened", name: 'SongWidget'),
                enabled: true,
                color: AppColors.greyBackground,
                position: PopupMenuPosition.under,
                useRootNavigator: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                icon: const Icon(
                  IconsaxPlusLinear.more,
                  size: 13,
                  color: Colors.white,
                ).rotate(90),
              ),
          ],
        ),
      ),
    );
  }

  /// Helper method to format duration to h:mm:ss if over an hour, otherwise m:ss
  String _formatDuration(int duration) {
    // Log the raw duration value for debugging
    print('Raw duration value: $duration');

    // Check if duration is likely in milliseconds (e.g., exceeds 24 hours in seconds)
    int seconds = duration;
    if (duration > 86400) {
      // 24 hours in seconds
      print(
        'Duration $duration seems to be in milliseconds, converting to seconds',
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

  Widget defaultThumbnailWidget() {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: AppColors.background_2,
      alignment: Alignment.center,
      child: Icon(IconsaxPlusLinear.musicnote, color: Colors.white54, size: 21),
    );
  }

  /// Helper method to get thumbnail file path if it exists
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
      log('Error getting thumbnail path: $e', name: 'SongWidget');
      return null;
    }
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
        width: double.maxFinite,
        alignment: Alignment.center,
        height: double.maxFinite,
      );
    } catch (e, stackTrace) {
      log(
        'Exception decoding base64 for $title',
        error: e,
        stackTrace: stackTrace,
        name: 'SongWidget',
      );
      return defaultThumbnailWidget();
    }
  }

  void onMenuSelected(String value) {
    final menus = items!(audio);

    final selectedMenu = menus.firstWhereOrNull(
      (menu) =>
          menu is SonaraPopupMenuItem &&
          (menu as SonaraPopupMenuItem).value == value,
    );

    if (selectedMenu == null || selectedMenu is! SonaraPopupMenuItem<String>) {
      return;
    }

    if (selectedMenu.onTap == null) return;

    selectedMenu.onTap!();
  }
}
