import 'package:flutter/material.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/core/utils/types.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';

class SelectPlaylistWidget extends StatelessWidget {
  final Playlist playlist;
  final bool checked;
  final BoolCallback onChecked;
  const SelectPlaylistWidget({
    super.key,
    required this.playlist,
    required this.checked,
    required this.onChecked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChecked(!checked),
      child: Row(
        spacing: 6,
        children: [
          Checkbox(
            value: checked,
            activeColor: Colors.white,
            checkColor: Colors.black,
            side: BorderSide(color: Colors.white24),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (value) => onChecked(value ?? false),
          ),
          Text(
            playlist.name,
            style: context.lufgaRegular.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
