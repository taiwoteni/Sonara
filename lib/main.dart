import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/sonara.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  await JustAudioBackground.init(
    androidNotificationChannelId: 'org.kalaharitech.sonara.channel.audio',
    androidNotificationChannelName: 'Sonara Music',
    preloadArtwork: true,
    androidNotificationIcon: 'drawable/sonara_white',
    // notificationColor: AppColors.purple,
    androidNotificationOngoing: true,
  );

  // Enforce portrait orientation (portraitUp only) for the entire app
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize dependency injection
  setupDependencies();

  runApp(ProviderScope(child: Sonara.instance));
}
