import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/utils/extensions/transforms_extensions.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';

/// A custom list item widget for displaying songs
class SongWidget extends StatelessWidget {
  /// The audio file to display
  final Song audio;

  /// Callback when the item is tapped
  final VoidCallback? onTap;

  /// Callback when the more options button is tapped
  final VoidCallback? onMoreTap;

  const SongWidget({
    super.key,
    required this.audio,
    this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    // Debug print to check if thumbnailData is available
    print(
      'Song: ${audio.title}, Thumbnail Data Available: ${audio.thumbnailData.isNotEmpty}',
    );
    if (audio.thumbnailData.isNotEmpty) {
      print('Thumbnail Data Length: ${audio.thumbnailData.length}');
      // Print a snippet of the base64 data for debugging
      if (audio.thumbnailData.length > 50) {
        print('Base64 Snippet: ${audio.thumbnailData.substring(0, 50)}...');
      } else {
        print('Base64 Snippet: ${audio.thumbnailData}');
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            // Album photo with play icon overlay
            ClipOval(
              child: Container(
                width: 52,
                height: 52,
                color: Colors.deepPurple.shade700,
                child: audio.thumbnailData.isNotEmpty
                    ? _buildThumbnailImage(audio.thumbnailData, audio.title)
                    : defaultThumbnailWidget(),
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
                    style: context.lufgaSemiBold.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(2),
                  Row(
                    spacing: 7,
                    children: [
                      Text(
                        _formatDuration(audio.duration),
                        style: context.lufgaRegular.copyWith(
                          color: Colors.white70,
                          fontSize: 10,
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
                          style: context.spaceGroteskRegular.copyWith(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // More options icon
            IconButton(
              icon: const Icon(
                IconsaxPlusLinear.more,
                size: 18,
                color: Colors.white,
              ),
              onPressed: onMoreTap,
            ).rotate(90),
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
      color: Colors.deepPurple.shade700,
      alignment: Alignment.center,
      child: Icon(
        CupertinoIcons.play_arrow_solid,
        color: Colors.white.withOpacity(0.9),
        size: 21,
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
        width: double.maxFinite,
        alignment: Alignment.center,
        height: double.maxFinite,
      );
    } catch (e, stackTrace) {
      print('Exception decoding base64 for $title: $e');
      print('Stack trace: $stackTrace');
      return defaultThumbnailWidget();
    }
  }
}
