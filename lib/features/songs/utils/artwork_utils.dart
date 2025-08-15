import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/utils/extensions/transforms_extensions.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';

import '../../../core/utils/colors.dart';

class ArtworkUtils {
  static Future<List<Color>> getDominantGradientColorsFromArtwork(
    String artworkPathOrData,
  ) async {
    if (artworkPathOrData.isEmpty) {
      return [AppColors.background_2, AppColors.background_2];
    }

    try {
      // Decode the file to bytes
      final imageBytes = const Base64Decoder().convert(
        artworkPathOrData.replaceAll(RegExp(r'\s+'), ''),
      );
      // Load the image for color extraction
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      // Convert image to byte data for manual color sampling
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData != null) {
        final data = byteData.buffer.asUint8List();
        final width = image.width;
        final height = image.height;
        // Use a simple clustering approach to find two dominant colors
        Map<int, int> colorCounts = {};
        // Sample every 10th pixel to reduce processing time
        for (int y = 0; y < height; y += 10) {
          for (int x = 0; x < width; x += 10) {
            final index = (y * width + x) * 4;
            if (index + 3 < data.length) {
              // Quantize colors to reduce variations (group similar colors)
              final r = (data[index] ~/ 32) * 32;
              final g = (data[index + 1] ~/ 32) * 32;
              final b = (data[index + 2] ~/ 32) * 32;
              final colorKey = (r << 16) | (g << 8) | b;
              colorCounts[colorKey] = (colorCounts[colorKey] ?? 0) + 1;
            }
          }
        }
        // Sort colors by frequency
        var sortedColors = colorCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        // Get the two most dominant colors, avoiding white or near-white
        Color primaryColor = AppColors.background_2;
        Color secondaryColor = AppColors.background_2;
        if (sortedColors.isNotEmpty) {
          // Get primary color (most dominant)
          for (var i = 0; i < sortedColors.length; i++) {
            final colorKey = sortedColors[i].key;
            final color = Color.fromRGBO(
              (colorKey >> 16) & 0xFF,
              (colorKey >> 8) & 0xFF,
              colorKey & 0xFF,
              1.0,
            );
            // Check if color is near-white (RGB values above 200) or near-black (RGB values below 50)
            if (!(color.red > 200 && color.green > 200 && color.blue > 200) &&
                !(color.red < 50 && color.green < 50 && color.blue < 50)) {
              primaryColor = color;
              break;
            }
          }

          // Get secondary color (second most dominant)
          if (sortedColors.length > 1) {
            for (var i = 0; i < sortedColors.length; i++) {
              final colorKey = sortedColors[i].key;
              final color = Color.fromRGBO(
                (colorKey >> 16) & 0xFF,
                (colorKey >> 8) & 0xFF,
                colorKey & 0xFF,
                1.0,
              );
              // Check if color is near-white (RGB values above 200) or near-black (RGB values below 50) and different from primary color
              if (!(color.red > 200 && color.green > 200 && color.blue > 200) &&
                  !(color.red < 50 && color.green < 50 && color.blue < 50) &&
                  color != primaryColor) {
                secondaryColor = color;
                break;
              }
            }
          } else {
            secondaryColor = primaryColor;
          }
        }
        return [primaryColor, secondaryColor];
      } else {
        throw Exception('Failed to convert image to byte data');
      }
    } catch (e) {
      final artworkPath = artworkPathOrData;

      if (artworkPath.isEmpty) {
        return [AppColors.background_2, AppColors.background_2];
      }

      try {
        // Read the image file
        final imageFile = File(artworkPath);
        final imageBytes = await imageFile.readAsBytes();

        // Load the image for color extraction
        final codec = await ui.instantiateImageCodec(imageBytes);
        final frame = await codec.getNextFrame();
        final image = frame.image;

        // Convert image to byte data for manual color sampling
        final byteData = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        if (byteData != null) {
          final data = byteData.buffer.asUint8List();
          final width = image.width;
          final height = image.height;
          // Use a simple clustering approach to find two dominant colors
          Map<int, int> colorCounts = {};
          // Sample every 10th pixel to reduce processing time
          for (int y = 0; y < height; y += 10) {
            for (int x = 0; x < width; x += 10) {
              final index = (y * width + x) * 4;
              if (index + 3 < data.length) {
                // Quantize colors to reduce variations (group similar colors)
                final r = (data[index] ~/ 32) * 32;
                final g = (data[index + 1] ~/ 32) * 32;
                final b = (data[index + 2] ~/ 32) * 32;
                final colorKey = (r << 16) | (g << 8) | b;
                colorCounts[colorKey] = (colorCounts[colorKey] ?? 0) + 1;
              }
            }
          }
          // Sort colors by frequency
          var sortedColors = colorCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          // Get the two most dominant colors, avoiding white or near-white
          Color primaryColor = AppColors.background_2;
          Color secondaryColor = AppColors.background_2;
          if (sortedColors.isNotEmpty) {
            // Get primary color (most dominant)
            for (var i = 0; i < sortedColors.length; i++) {
              final colorKey = sortedColors[i].key;
              final color = Color.fromRGBO(
                (colorKey >> 16) & 0xFF,
                (colorKey >> 8) & 0xFF,
                colorKey & 0xFF,
                1.0,
              );
              // Check if color is near-white (RGB values above 200) or near-black (RGB values below 50)
              if (!(color.red > 200 && color.green > 200 && color.blue > 200) &&
                  !(color.red < 50 && color.green < 50 && color.blue < 50)) {
                primaryColor = color;
                break;
              }
            }

            // Get secondary color (second most dominant)
            if (sortedColors.length > 1) {
              for (var i = 0; i < sortedColors.length; i++) {
                final colorKey = sortedColors[i].key;
                final color = Color.fromRGBO(
                  (colorKey >> 16) & 0xFF,
                  (colorKey >> 8) & 0xFF,
                  colorKey & 0xFF,
                  1.0,
                );
                // Check if color is near-white (RGB values above 200) or near-black (RGB values below 50) and different from primary color
                if (!(color.red > 200 &&
                        color.green > 200 &&
                        color.blue > 200) &&
                    !(color.red < 50 && color.green < 50 && color.blue < 50) &&
                    color != primaryColor) {
                  secondaryColor = color;
                  break;
                }
              }
            } else {
              secondaryColor = primaryColor;
            }
          }
          return [primaryColor, secondaryColor];
        } else {
          throw Exception('Failed to convert image to byte data');
        }
      } catch (e) {
        log('Error extracting dominant color: $e', name: 'ArtworkUtils');
        return [AppColors.background_2, AppColors.background_2];
      }
    }
  }

  static Future<Color> getDominantColorFromArtwork(
    String artworkPathOrData,
  ) async {
    if (artworkPathOrData.isEmpty) {
      return AppColors.background_2;
    }

    try {
      // Decode the file to bytes
      final imageBytes = await File(artworkPathOrData).readAsBytes();
      // Load the image for color extraction
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      // Convert image to byte data for manual color sampling
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData != null) {
        final data = byteData.buffer.asUint8List();
        final width = image.width;
        final height = image.height;
        // Use a simple clustering approach to find the most dominant color
        Map<int, int> colorCounts = {};
        // Sample every 10th pixel to reduce processing time
        for (int y = 0; y < height; y += 10) {
          for (int x = 0; x < width; x += 10) {
            final index = (y * width + x) * 4;
            if (index + 3 < data.length) {
              // Quantize colors to reduce variations (group similar colors)
              final r = (data[index] ~/ 32) * 32;
              final g = (data[index + 1] ~/ 32) * 32;
              final b = (data[index + 2] ~/ 32) * 32;
              final colorKey = (r << 16) | (g << 8) | b;
              colorCounts[colorKey] = (colorCounts[colorKey] ?? 0) + 1;
            }
          }
        }
        // Sort colors by frequency
        var sortedColors = colorCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        // Get the most dominant color, avoiding white or near-white
        if (sortedColors.isNotEmpty) {
          for (var i = 0; i < sortedColors.length; i++) {
            final colorKey = sortedColors[i].key;
            final color = Color.fromRGBO(
              (colorKey >> 16) & 0xFF,
              (colorKey >> 8) & 0xFF,
              colorKey & 0xFF,
              1.0,
            );
            // Check if color is near-white (RGB values above 200) or near-black (RGB values below 50)
            if (!(color.red > 200 && color.green > 200 && color.blue > 200) &&
                !(color.red < 50 && color.green < 50 && color.blue < 50)) {
              return color;
            }
          }
        }
        // If no suitable color found, fall back to default
        return AppColors.background_2;
      } else {
        throw Exception('Failed to convert image to byte data');
      }
    } catch (e) {
      try {
        // Decode the file to bytes
        final imageBytes = const Base64Decoder().convert(
          artworkPathOrData.replaceAll(RegExp(r'\s+'), ''),
        );
        // Load the image for color extraction
        final codec = await ui.instantiateImageCodec(imageBytes);
        final frame = await codec.getNextFrame();
        final image = frame.image;
        // Convert image to byte data for manual color sampling
        final byteData = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        if (byteData != null) {
          final data = byteData.buffer.asUint8List();
          final width = image.width;
          final height = image.height;
          // Use a simple clustering approach to find the most dominant color
          Map<int, int> colorCounts = {};
          // Sample every 10th pixel to reduce processing time
          for (int y = 0; y < height; y += 10) {
            for (int x = 0; x < width; x += 10) {
              final index = (y * width + x) * 4;
              if (index + 3 < data.length) {
                // Quantize colors to reduce variations (group similar colors)
                final r = (data[index] ~/ 32) * 32;
                final g = (data[index + 1] ~/ 32) * 32;
                final b = (data[index + 2] ~/ 32) * 32;
                final colorKey = (r << 16) | (g << 8) | b;
                colorCounts[colorKey] = (colorCounts[colorKey] ?? 0) + 1;
              }
            }
          }
          // Sort colors by frequency
          var sortedColors = colorCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          // Get the most dominant color, avoiding white or near-white
          if (sortedColors.isNotEmpty) {
            for (var i = 0; i < sortedColors.length; i++) {
              final colorKey = sortedColors[i].key;
              final color = Color.fromRGBO(
                (colorKey >> 16) & 0xFF,
                (colorKey >> 8) & 0xFF,
                colorKey & 0xFF,
                1.0,
              );
              // Check if color is near-white (RGB values above 200) or near-black (RGB values below 50)
              if (!(color.red > 200 && color.green > 200 && color.blue > 200) &&
                  !(color.red < 50 && color.green < 50 && color.blue < 50)) {
                return color;
              }
            }
          }
          // If no suitable color found, fall back to default
          return AppColors.background_2;
        } else {
          throw Exception('Failed to convert image to byte data');
        }
      } catch (e) {
        log('Error extracting dominant color: $e', name: 'ArtworkUtils');
        return AppColors.background_2;
      }
    }
  }

  static Widget defaultPlaylistArtworkWidget() {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: AppColors.background_2,
      alignment: Alignment.center,
      child: Icon(
        IconsaxPlusLinear.music_filter,
        color: Colors.white54,
        size: 21,
      ),
    );
  }

  static Widget _defaultSongArtworkWidget() {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: AppColors.background_2,
      alignment: Alignment.center,
      child: Icon(IconsaxPlusLinear.musicnote, color: Colors.white54, size: 21),
    );
  }

  static Widget _collageImage(String artworkPath) {
    return Image.file(
      File(artworkPath),
      width: double.maxFinite,
      height: double.maxFinite,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      errorBuilder: (_, _, _) => _defaultSongArtworkWidget().scale(.5),
    );
  }

  static Future<Widget> collage({required final Playlist playlist}) async {
    if (playlist.songs.isEmpty) {
      log("Playlist's songs are empty", name: 'ArtworkUtils');
      return defaultPlaylistArtworkWidget();
    }
    log("Playlist's songs are not empty", name: 'ArtworkUtils');

    /// [songsWithArtworksSortedFirst] is the list containing songs with artworks
    /// at the front
    final songsWithArtworksSortedFirst = playlist.songs
        .sorted(
          (a, b) =>
              (File(b.artworkPath).existsSync() ? 1 : 0) -
              (File(a.artworkPath).existsSync() ? 1 : 0),
        )
        .toList();
    final maxFourSongs = songsWithArtworksSortedFirst
        .slice(
          0,
          songsWithArtworksSortedFirst.length >= 4
              ? 4
              : songsWithArtworksSortedFirst.length,
        )
        .toList();

    log(
      "Max four songs list shows: ${maxFourSongs.length}",
      name: 'ArtworkUtils',
    );

    // This way, all songs with artworks have been positioned to
    // the top of the list and we are selecting the first 4 songs.

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (maxFourSongs.length >= 4) {
            return GridView.builder(
              padding: EdgeInsets.zero,
              itemCount: 4,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
              ),
              itemBuilder: (context, index) =>
                  _collageImage(maxFourSongs[index].artworkPath),
            );
          }

          if (maxFourSongs.length == 3) {
            return Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _collageImage(maxFourSongs[0].artworkPath),
                      ),
                      Expanded(
                        child: _collageImage(maxFourSongs[1].artworkPath),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _collageImage(maxFourSongs[2].artworkPath)),
              ],
            );
          }

          if (maxFourSongs.length == 2) {
            return Row(
              children: [
                Expanded(child: _collageImage(maxFourSongs[0].artworkPath)),
                Expanded(child: _collageImage(maxFourSongs[1].artworkPath)),
              ],
            );
          }

          return _collageImage(maxFourSongs[0].artworkPath);
        },
      ),
    );
  }
}
