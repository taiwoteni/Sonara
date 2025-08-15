import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/services/directory_paths.dart';
import 'package:sonara/features/songs/presentation/providers/song_providers.dart';
import 'package:sonara/features/splash/presentation/widgets/splash_background.dart';
import 'package:sonara/core/utils/services/audio_player_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      // Request necessary permissions before navigating to onboarding
      _requestPermissions().then((_) {
        // Initiate song loading after permissions are granted
        _loadSongsAndThumbnails().then((_) {
          // Navigate to the onboarding screen using GoRouter after songs are loaded
          context.goNamed('home');
        });
      });
    });
  }

  Future<void> _requestPermissions() async {
    try {
      // Request storage permission for accessing music files
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          log('Storage permission denied', name: 'SplashScreen');
        }
      }

      // Request audio permission if applicable (mainly for Android 13+)
      var audioStatus = await Permission.audio.status;
      if (!audioStatus.isGranted) {
        audioStatus = await Permission.audio.request();
        if (!audioStatus.isGranted) {
          log('Audio permission denied', name: 'SplashScreen');
        }
      }

      // Request notification permission for music playback notifications
      var notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        notificationStatus = await Permission.notification.request();
        if (!notificationStatus.isGranted) {
          log('Notification permission denied', name: 'SplashScreen');
        }
      }
    } catch (e) {
      log('Error requesting permissions: $e', name: 'SplashScreen');
    }
  }

  Future<void> _loadSongsAndThumbnails() async {
    final supportDirectory =
        getIt<DirectoryPaths>().applicationSupportDirectory;
    log(
      "This is support directory path: ${supportDirectory.path}",
      name: 'SplashScreen',
    );
    try {
      // Check permission status before loading songs
      var storageStatus = await Permission.storage.status;
      var audioStatus = await Permission.audio.status;
      log(
        'Storage permission status: ${storageStatus.isGranted}, Audio permission status: ${audioStatus.isGranted}',
        name: 'SplashScreen',
      );

      // Access the song provider to load songs using ProviderScope container since the app is wrapped with ProviderScope
      final songNotifier = ref.read(songProvider.notifier);
      await songNotifier.loadSongs();
      log('Songs loaded during splash screen', name: 'SplashScreen');

      await Future.delayed(const Duration(seconds: 3));

      // After songs are loaded, save thumbnails
      final songs = ref.watch(songProvider).songs;
      if (songs.isNotEmpty) {
        log(
          'Starting thumbnail saving for ${songs.length} songs',
          name: 'SplashScreen',
        );
        for (var song in songs) {
          try {
            final result = await const MethodChannel(
              'com.sonara.audio_files',
            ).invokeMethod('getHighQualityArtwork', {'id': song.id});
            final highQualityArtworkData = result['artworkData'] as String?;
            if (highQualityArtworkData != null &&
                highQualityArtworkData.isNotEmpty) {
              await AudioPlayerHelper.saveThumbnailToDir(
                highQualityArtworkData,
                song.id,
              );
            }
          } catch (e) {
            log(
              'Error saving thumbnail for song ${song.title}: $e',
              name: 'SplashScreen',
            );
          }
        }
        log('Thumbnail saving completed', name: 'SplashScreen');
      } else {
        log('Songs loaded are empty', name: 'SplashScreen');
      }
    } catch (e) {
      log('Error loading songs or saving thumbnails: $e', name: 'SplashScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: SplashBackground(
        child: Center(
          child: Image.asset(
            'assets/Sonara-Transparent.png',
            width: 200, // Adjust size as needed
            height: 200,
          ),
        ),
      ),
    );
  }
}
