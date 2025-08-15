import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/core/utils/services/directory_paths.dart';
import 'package:sonara/sonara.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  await JustAudioBackground.init(
    androidNotificationChannelId: 'org.kalaharitech.sonara.channel.audio',
    androidNotificationChannelName: 'Sonara Music',
    preloadArtwork: true,
    androidNotificationIcon: 'drawable/sonara_white',
    rewindInterval: const Duration(seconds: 15),
    fastForwardInterval: const Duration(seconds: 15),
    notificationColor: AppColors.background,
    androidNotificationOngoing: true,
  );

  // Enforce portrait orientation (portraitUp only) for the entire app
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize dependency injection
  setupDependencies();

  // Initialize DirectoryPaths during app startup
  await getIt<DirectoryPaths>().initialize();

  runApp(ProviderScope(child: Sonara.instance));
}
