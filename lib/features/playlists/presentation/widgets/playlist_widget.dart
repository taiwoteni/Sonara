import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/core/utils/extensions/transforms_extensions.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/core/utils/types.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/songs/utils/artwork_utils.dart';

class PlaylistWidget extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;
  final BoolCallback? onToggle;
  final bool selected;

  /// Callback when the more options button is tapped
  final List<PopupMenuEntry<String>> Function(Playlist playlist)? items;

  const PlaylistWidget({
    super.key,
    required this.playlist,
    this.items,
    this.onTap,
    this.onToggle,
    this.selected = false,
  });

  factory PlaylistWidget.selectable({
    required final Playlist playlist,
    required final BoolCallback onToggle,
    required final bool selected,
  }) => PlaylistWidget(
    playlist: playlist,
    selected: selected,
    onToggle: onToggle,
  );

  @override
  Widget build(BuildContext context) {
    final menus = items == null ? null : items!(playlist);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 0),
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onToggle != null ? () => onToggle!(!selected) : onTap,
        child: Row(
          children: [
            // Album photo with play icon overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                width: 55,
                height: 55,
                child: FutureBuilder(
                  future: ArtworkUtils.collage(playlist: playlist),
                  builder: (context, snapshot) => snapshot.hasData
                      ? snapshot.data!
                      : ArtworkUtils.defaultPlaylistArtworkWidget(),
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
                    playlist.name,
                    style: context.lufgaSemiBold.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(1),
                  Text(
                    '${playlist.songs.length} track${playlist.songs.length == 1 ? '' : 's'}',
                    style: context.spaceGroteskRegular.copyWith(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // More options icon
            if (onToggle == null) ...[
              if (menus != null && menus.isNotEmpty)
                PopupMenuButton<String>(
                  // onSelected: onMenuSelected,
                  itemBuilder: (context) => menus,
                  onCanceled: () =>
                      log("Popup Menu Closed", name: 'PlaylistWidget'),
                  onOpened: () =>
                      log("Popup Menu Opened", name: 'PlaylistWidget'),
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
            ] else
              Radio<bool>(
                value: selected,
                groupValue: true,
                onChanged: (value) => onToggle!(value ?? false),
                activeColor: Colors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
      ),
    );
  }
}
