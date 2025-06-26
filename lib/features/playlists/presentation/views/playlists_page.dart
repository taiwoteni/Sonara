import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/features/home/presentation/widgets/search_bar.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.safeAreaInsets.copyWith(left: 16, right: 16),
      child: Column(
        children: [
          Gap(12),
          SonaraSearchBar(
            controller: searchController,
            hintText: 'Search for playlists...',
          ),
        ],
      ),
    );
  }
}
