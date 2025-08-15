import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/core/utils/theme.dart';

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
          Gap(14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Discover".toUpperCase(),
                style: context.lufgaExtraBold.copyWith(fontSize: 25),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(IconsaxPlusLinear.search_normal),
              ),
            ],
          ),
          Gap(16),
        ],
      ),
    );
  }
}
