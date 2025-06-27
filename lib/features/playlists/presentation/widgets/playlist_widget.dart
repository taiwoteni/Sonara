import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/utils/extensions/transforms_extensions.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';

class PlaylistWidget extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;

  const PlaylistWidget({super.key, required this.playlist, this.onTap});

  @override
  Widget build(BuildContext context) {
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
                color: Colors.black.withValues(alpha: 0.3),
                child: playlist.thumbnailData.isNotEmpty
                    ? _buildThumbnailImage(
                        playlist.thumbnailData,
                        playlist.name,
                      )
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
                    playlist.name,
                    style: context.lufgaSemiBold.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(2),
                  Text(
                    '${playlist.songs.length} songs',
                    style: context.spaceGroteskRegular.copyWith(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // More options icon
            IconButton(
              icon: const Icon(
                IconsaxPlusLinear.more,
                size: 13,
                color: Colors.white,
              ),
              onPressed: () {},
            ).rotate(90),
          ],
        ),
      ),
    );
  }

  Widget defaultThumbnailWidget() {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Icon(
        IconsaxPlusLinear.music_filter,
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
      log(
        'Exception decoding base64 for $title',
        error: e,
        stackTrace: stackTrace,
        name: 'SongWidget',
      );
      return defaultThumbnailWidget();
    }
  }
}
