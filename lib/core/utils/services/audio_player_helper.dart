import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/services/audio_service.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'dart:developer';

class AudioPlayerHelper {
  /// Plays a song with notification support by prioritizing persistent high-quality artwork.
  static Future<void> playSong(
    Song song, {
    String? highQualityArtworkData,
  }) async {
    try {
      String? albumArtPath;
      // First, check for persistent high-quality artwork in application support directory
      final supportDir = await getApplicationSupportDirectory();
      final persistentFilePath =
          '${supportDir.path}/high_quality_artwork_${song.id}.jpg';
      final persistentFile = File(persistentFilePath);
      if (await persistentFile.exists()) {
        albumArtPath = persistentFilePath;
        log(
          'Using persistent high-quality artwork for notifications: $persistentFilePath',
          name: 'AudioPlayerHelper',
        );
      } else {
        // Fall back to saving provided data to application support directory
        if (highQualityArtworkData != null &&
            highQualityArtworkData.isNotEmpty) {
          albumArtPath = await _saveThumbnailToSupportDir(
            highQualityArtworkData,
            song.id,
          );
          log(
            'Using saved high-quality artwork in support directory for notifications',
            name: 'AudioPlayerHelper',
          );
        } else if (song.thumbnailData.isNotEmpty) {
          albumArtPath = await _saveThumbnailToSupportDir(
            song.thumbnailData,
            song.id,
          );
          log(
            'Using saved low-quality thumbnail in support directory for notifications',
            name: 'AudioPlayerHelper',
          );
        }
      }

      await getIt<AudioService>().playSong(
        song.path,
        songId: song.id,
        title: song.title,
        artist: song.artist,
        albumArtPath: albumArtPath,
        song: song,
      );
      log(
        'Song playback started: ${song.title}, ID: ${song.id}',
        name: 'AudioPlayerHelper',
      );
    } catch (e) {
      log('Error playing song: $e', name: 'AudioPlayerHelper');
    }
  }

  static Future<String?> _saveThumbnailToSupportDir(
    String thumbnailData,
    String songId,
  ) async {
    try {
      // Get the application support directory
      final supportDir = await getApplicationSupportDirectory();
      final filePath = '${supportDir.path}/high_quality_artwork_$songId.jpg';

      // Clean the base64 string
      final cleanedData = thumbnailData.replaceAll(RegExp(r'\s+'), '');
      // Decode base64 data
      final decodedData = const Base64Decoder().convert(cleanedData);

      // Write to file
      final file = File(filePath);
      await file.writeAsBytes(decodedData);

      log(
        'Saved thumbnail to application support directory: $filePath',
        name: 'AudioPlayerHelper',
      );
      return filePath;
    } catch (e) {
      log(
        'Error saving thumbnail to application support directory: $e',
        name: 'AudioPlayerHelper',
      );
      return null;
    }
  }
}
