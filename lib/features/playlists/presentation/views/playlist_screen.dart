import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/features/songs/presentation/widgets/songs_list.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/splash/presentation/widgets/splash_background.dart';

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  const PlaylistScreen({super.key, required this.playlist});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late Playlist playlist;

  @override
  void initState() {
    playlist = widget.playlist;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SplashBackground(
      type: SplashBacgroundType.spread,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.maxFinite,
              height: 150,
              padding: EdgeInsets.symmetric(
                horizontal: 15,
              ).copyWith(top: context.statusBarPadding),
              color: Colors.black.withValues(alpha: .2),
              child: Row(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      IconsaxPlusLinear.music_filter,
                      color: Colors.white.withOpacity(0.9),
                      size: 25,
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        playlist.name,
                        style: context.lufgaBold.copyWith(fontSize: 20),
                      ),

                      Text(
                        "${playlist.songs.length} songs",
                        style: context.spaceGroteskRegular.copyWith(
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Gap(15),
            SongsList(songs: playlist.songs),
          ],
        ),
      ),
    );
  }
}
