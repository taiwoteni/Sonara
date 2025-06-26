import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';

class AudioFileService {
  /// Method channel for communicating with platform-specific code
  static const MethodChannel _channel = MethodChannel('com.sonara.audio_files');

  /// Checks and requests storage permission to access audio files.
  /// Returns true if permission is granted, false otherwise.
  Future<bool> requestPermissions() async {
    try {
      // For Android, we need to request storage & audio permission
      // For iOS, permissions are declared in Info.plist
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      status = await Permission.audio
          .request(); // For Android, we need to request audio permission

      return status.isGranted;
    } catch (e) {
      log("Error requesting permissions: $e");
      return false;
    }
  }

  /// Lists all audio files on the device using platform-specific implementation.
  /// Returns a list of AudioFile objects if permission is granted, otherwise an empty list.
  Future<List<Song>> listAudioFiles() async {
    try {
      // First check if we have the necessary permissions
      bool hasPermission = await requestPermissions();
      if (!hasPermission) {
        log("Permission denied to access audio files");
        return [];
      }

      // Call the platform-specific implementation
      final List<dynamic> result = await _channel.invokeMethod(
        'listAudioFiles',
      );

      // Convert the result to a list of AudioFile objects
      return result
          .cast<Map<dynamic, dynamic>>()
          .map((map) => Song.fromMap(Map<String, dynamic>.from(map)))
          .toList();
    } on PlatformException catch (e) {
      log("Platform error when listing audio files: $e");
      return [];
    } catch (e) {
      log("Unexpected error when listing audio files: $e");
      return [];
    }
  }
}
