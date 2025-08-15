import 'dart:convert';
import 'dart:io';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/services/audio_service.dart';
import 'package:sonara/core/utils/services/directory_paths.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'dart:developer';

class AudioPlayerHelper {
  /// Plays a song with notification support by prioritizing persistent high-quality artwork.
  static Future<void> playSong(
    Song song, {
    String? highQualityArtworkData,
    List<Song>? allSongs,
  }) async {
    try {
      String? albumArtPath;
      // First, check for persistent high-quality artwork in application support directory
      final supportDir = getIt<DirectoryPaths>().applicationSupportDirectory;
      final thumbnailDir = Directory('${supportDir.path}/.thumbnails');
      if (!await thumbnailDir.exists()) {
        await thumbnailDir.create(recursive: true);
      }
      final persistentFilePath = '${thumbnailDir.path}/${song.id}.jpg';
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
          albumArtPath = await saveThumbnailToDir(
            highQualityArtworkData,
            song.id,
          );
          log(
            'Using saved high-quality artwork in support directory for notifications',
            name: 'AudioPlayerHelper',
          );
        } else if (song.thumbnailData.isNotEmpty) {
          albumArtPath = await saveThumbnailToDir(song.thumbnailData, song.id);
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
        allSongs: allSongs,
      );
      log(
        'Song playback started: ${song.title}, ID: ${song.id}',
        name: 'AudioPlayerHelper',
      );
    } catch (e) {
      log('Error playing song: $e', name: 'AudioPlayerHelper');
    }
  }

  /// Saves a thumbnail to the thumbnails subdirectory in application support directory.
  static Future<String?> saveThumbnailToDir(
    String thumbnailData,
    String songId,
  ) async {
    try {
      // Get the application support directory using singleton
      final supportDir = getIt<DirectoryPaths>().applicationSupportDirectory;
      final thumbnailDir = Directory('${supportDir.path}/.thumbnails');
      if (!(await thumbnailDir.exists())) {
        await thumbnailDir.create(recursive: true);
      }
      final filePath = '${thumbnailDir.path}/$songId.jpg';

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

  /// Plays a playlist starting from the specified index.
  static Future<void> playPlaylist(
    List<Song> songs,
    String playlistId,
    int startIndex, {
    String? highQualityArtworkData,
  }) async {
    try {
      if (songs.isEmpty || startIndex < 0 || startIndex >= songs.length) {
        log('Invalid playlist or start index', name: 'AudioPlayerHelper');
        return;
      }
      await getIt<AudioService>().playPlaylist(songs, playlistId, startIndex);
      log(
        'Playlist playback started with ${songs.length} songs from index $startIndex',
        name: 'AudioPlayerHelper',
      );
    } catch (e) {
      log('Error playing playlist: $e', name: 'AudioPlayerHelper');
    }
  }

  /// Adds a song to the current queue.
  static Future<void> addToQueue(Song song) async {
    try {
      await getIt<AudioService>().addToQueue(song);
      log(
        'Song added to queue: ${song.title}, ID: ${song.id}',
        name: 'AudioPlayerHelper',
      );
    } catch (e) {
      log('Error adding song to queue: $e', name: 'AudioPlayerHelper');
    }
  }

  /// Plays the next song in the queue.
  static Future<void> playNext() async {
    try {
      await getIt<AudioService>().playNext();
      log('Playing next song in queue', name: 'AudioPlayerHelper');
    } catch (e) {
      log('Error playing next song: $e', name: 'AudioPlayerHelper');
    }
  }

  /// Plays the previous song in the queue.
  static Future<void> playPrevious() async {
    try {
      await getIt<AudioService>().playPrevious();
      log('Playing previous song in queue', name: 'AudioPlayerHelper');
    } catch (e) {
      log('Error playing previous song: $e', name: 'AudioPlayerHelper');
    }
  }
}
