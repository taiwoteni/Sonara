import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:sonara/core/utils/colors.dart';

class ThumbnailBackground extends StatefulWidget {
  final String thumbnailData;
  final EdgeInsets? padding;
  final Widget child;

  const ThumbnailBackground({
    super.key,
    required this.thumbnailData,
    required this.child,
    this.padding,
  });

  @override
  State<ThumbnailBackground> createState() => _ThumbnailBackgroundState();
}

class _ThumbnailBackgroundState extends State<ThumbnailBackground> {
  Color _primaryColor = AppColors.background_2;
  Color _secondaryColor = AppColors.background_2;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _extractDominantColors();
  }

  Future<void> _extractDominantColors() async {
    if (widget.thumbnailData.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Clean the base64 string by removing any whitespace or line breaks
      final cleanedData = widget.thumbnailData.replaceAll(RegExp(r'\s+'), '');
      // Decode the base64 string to bytes
      final imageBytes = const Base64Decoder().convert(cleanedData);
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
        if (sortedColors.isNotEmpty) {
          // Get primary color (most dominant)
          final primaryColorKey = sortedColors[0].key;
          _primaryColor = Color.fromRGBO(
            (primaryColorKey >> 16) & 0xFF,
            (primaryColorKey >> 8) & 0xFF,
            primaryColorKey & 0xFF,
            1.0,
          );
          // Check if primary color is near-white (RGB values above 200)
          if (_primaryColor.red > 200 &&
              _primaryColor.green > 200 &&
              _primaryColor.blue > 200) {
            // Look for the next non-white color
            for (var i = 1; i < sortedColors.length; i++) {
              final nextColorKey = sortedColors[i].key;
              final nextColor = Color.fromRGBO(
                (nextColorKey >> 16) & 0xFF,
                (nextColorKey >> 8) & 0xFF,
                nextColorKey & 0xFF,
                1.0,
              );
              if (!(nextColor.red > 200 &&
                  nextColor.green > 200 &&
                  nextColor.blue > 200)) {
                _primaryColor = nextColor;
                break;
              }
            }
            // If no suitable color found, fall back to default
            if (_primaryColor.red > 200 &&
                _primaryColor.green > 200 &&
                _primaryColor.blue > 200) {
              _primaryColor = AppColors.background_2;
            }
          }

          // Get secondary color (second most dominant)
          if (sortedColors.length > 1) {
            final secondaryColorKey = sortedColors[1].key;
            _secondaryColor = Color.fromRGBO(
              (secondaryColorKey >> 16) & 0xFF,
              (secondaryColorKey >> 8) & 0xFF,
              secondaryColorKey & 0xFF,
              1.0,
            );
            // Check if secondary color is near-white
            if (_secondaryColor.red > 200 &&
                _secondaryColor.green > 200 &&
                _secondaryColor.blue > 200) {
              // Look for the next non-white color different from primary
              for (var i = 2; i < sortedColors.length; i++) {
                final nextColorKey = sortedColors[i].key;
                final nextColor = Color.fromRGBO(
                  (nextColorKey >> 16) & 0xFF,
                  (nextColorKey >> 8) & 0xFF,
                  nextColorKey & 0xFF,
                  1.0,
                );
                if (!(nextColor.red > 200 &&
                        nextColor.green > 200 &&
                        nextColor.blue > 200) &&
                    (nextColor.value != _primaryColor.value)) {
                  _secondaryColor = nextColor;
                  break;
                }
              }
              // If no suitable color found, fall back to default
              if (_secondaryColor.red > 200 &&
                  _secondaryColor.green > 200 &&
                  _secondaryColor.blue > 200) {
                _secondaryColor = AppColors.background_2;
              }
            }
          } else {
            _secondaryColor = _primaryColor;
          }
        }
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to convert image to byte data');
      }
    } catch (e, stackTrace) {
      print('Error extracting dominant colors: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    } finally {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // floatingActionButton: widget.floatingActionButton,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        alignment: Alignment.center,
        color: AppColors.background_2,
        child: Stack(
          children: [
            // Background with gradient of two dominant colors and blur effect
            Positioned.fill(
              child: _isLoading
                  ? Container(color: AppColors.background_2)
                  : BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _secondaryColor.withOpacity(0.5),
                              _primaryColor.withOpacity(0.5),
                            ],
                            stops: const [
                              0.7,
                              1.0,
                            ], // More weight to primary color at bottom as per user preference
                          ),
                        ),
                      ),
                    ),
            ),
            // Semi-transparent overlay for softness
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(color: Colors.black.withOpacity(0.25)),
              ),
            ),
            // Child widget on top of the background
            Container(
              width: double.maxFinite,
              height: double.maxFinite,
              padding: widget.padding,
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
