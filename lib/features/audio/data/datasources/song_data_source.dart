import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sonara/core/domain/usecase/failure.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';

abstract class SongDataSource {
  Future<Either<Failure, List<Song>>> getAllSongs();
  Future<Either<Failure, void>> saveSongs(List<Song> songs);
  Future<Either<Failure, String>> saveHighQualityThumbnail(
    String songId,
    String thumbnailData,
  );
  Future<Either<Failure, String>> getThumbnailPath(String songId);
}

class SongDataSourceImpl implements SongDataSource {
  static const String _fileName = 'songs.json';
  static const String _thumbnailDir = '.thumbnails';

  Future<File> _getSongsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_fileName');
    if (!await file.exists()) {
      await file.writeAsString(jsonEncode([]));
    }
    return file;
  }

  Future<Directory> _getThumbnailDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final thumbnailDir = Directory('${directory.path}/$_thumbnailDir');
    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }
    return thumbnailDir;
  }

  Future<List<Song>> _readSongs() async {
    final file = await _getSongsFile();
    final content = await file.readAsString();
    final jsonList = jsonDecode(content) as List<dynamic>;
    return jsonList
        .map((json) => Song.fromMap(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeSongs(List<Song> songs) async {
    final file = await _getSongsFile();
    final jsonList = songs.map((s) => s.toMap()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  @override
  Future<Either<Failure, List<Song>>> getAllSongs() async {
    try {
      final songs = await _readSongs();
      return Right(songs);
    } catch (e) {
      return Left(GenericFailure('Failed to get songs: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSongs(List<Song> songs) async {
    try {
      await _writeSongs(songs);
      return const Right(null);
    } catch (e) {
      return Left(GenericFailure('Failed to save songs: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> saveHighQualityThumbnail(
    String songId,
    String thumbnailData,
  ) async {
    try {
      final thumbnailDir = await _getThumbnailDirectory();
      final filePath = '${thumbnailDir.path}/$songId.jpg';
      final file = File(filePath);

      // Clean the base64 string
      final cleanedData = thumbnailData.replaceAll(RegExp(r'\s+'), '');
      // Decode base64 data
      final decodedData = base64Decode(cleanedData);
      await file.writeAsBytes(decodedData);

      return Right(filePath);
    } catch (e) {
      return Left(GenericFailure('Failed to save thumbnail: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getThumbnailPath(String songId) async {
    try {
      final thumbnailDir = await _getThumbnailDirectory();
      final filePath = '${thumbnailDir.path}/$songId.jpg';
      final file = File(filePath);
      if (await file.exists()) {
        return Right(filePath);
      }
      return Left(GenericFailure('Thumbnail not found'));
    } catch (e) {
      return Left(GenericFailure('Failed to get thumbnail path: $e'));
    }
  }
}
