import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/features/home/presentation/widgets/search_bar.dart';
import 'package:sonara/features/splash/presentation/widgets/splash_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SplashBackground(
      child: Padding(
        padding: context.safeAreaInsets.copyWith(left: 12, right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(12),
            SonaraSearchBar(),
            Gap(20),
            ElevatedButton.icon(
              onPressed: () => context.push('/audio'),
              icon: Icon(Icons.music_note),
              label: Text('Browse Audio Files'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
