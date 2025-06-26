import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/features/home/presentation/widgets/search_bar.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.safeAreaInsets.copyWith(left: 16, right: 16),
      child: Column(
        children: [
          Gap(12),
          SonaraSearchBar(hintText: 'Search for song/playlist...'),
        ],
      ),
    );
  }
}
