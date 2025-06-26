import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _player = AudioPlayer();
  final BehaviorSubject<Duration> _positionStream =
      BehaviorSubject<Duration>.seeded(Duration.zero);
  final BehaviorSubject<Duration> _durationStream =
      BehaviorSubject<Duration>.seeded(Duration.zero);
  final BehaviorSubject<bool> _isPlayingStream = BehaviorSubject<bool>.seeded(
    false,
  );
  final BehaviorSubject<String?> _currentSongIdStream =
      BehaviorSubject<String?>.seeded(null);
  final BehaviorSubject<Song?> _currentSongStream =
      BehaviorSubject<Song?>.seeded(null);
  final BehaviorSubject<LoopMode?> _loopStream =
      BehaviorSubject<LoopMode?>.seeded(null);
  final BehaviorSubject<bool> _shuffleStream = BehaviorSubject<bool>.seeded(
    false,
  );

  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialization of JustAudioBackground is handled in main.dart
    _player.positionStream.listen((position) {
      _positionStream.add(position);
    });

    _player.durationStream.listen((duration) {
      _durationStream.add(duration ?? Duration.zero);
    });

    _player.loopModeStream.listen((loopMode) {
      _loopStream.add(loopMode);
    });

    _player.shuffleModeEnabledStream.listen((shuffle) {
      _shuffleStream.add(shuffle);
    });

    _player.playerStateStream.listen((state) {
      _isPlayingStream.add(state.playing);
      if (state.processingState == ProcessingState.completed) {
        _isPlayingStream.add(false);
        _currentSongIdStream.add(null);
        _currentSongStream.add(null);
      }
    });
    // Reset current song and playback state on app start to prevent automatic navigation
    // to SongScreen. Playback should only start with user interaction.
    _currentSongIdStream.add(null);
    _currentSongStream.add(null);
    _isPlayingStream.add(false);
    debugPrint(
      'AudioService initialized with reset state to prevent automatic playback on app start',
    );
  }

  AudioPlayer get player => _player;

  Stream<Duration> get positionStream => _positionStream.stream;
  Stream<Duration> get durationStream => _durationStream.stream;
  Stream<bool> get isPlayingStream => _isPlayingStream.stream;
  Stream<String?> get currentSongIdStream => _currentSongIdStream.stream;
  Stream<Song?> get currentSongStream => _currentSongStream.stream;
  Stream<LoopMode?> get loopStream => _loopStream.stream;
  Stream<bool> get shuffleStream => _shuffleStream.stream;

  Future<void> playSong(
    String songPath, {
    String? songId,
    String? title,
    String? artist,
    String? albumArtPath,
    Song? song,
  }) async {
    try {
      // Update streams immediately to ensure mini-player displays without delay
      _currentSongIdStream.add(songId);
      _currentSongStream.add(song);
      debugPrint(
        'Song stream updated immediately: ${song?.title ?? "No song"}',
      );

      // Ensure albumArtPath is a valid file path, not base64 data
      Uri? artUri;
      if (albumArtPath != null && albumArtPath.isNotEmpty) {
        // Check if the path looks like a file path and not base64 data
        if (!albumArtPath.startsWith('data:') &&
            !albumArtPath.startsWith('/9j/')) {
          artUri = Uri.file(albumArtPath);
        }
      }
      final audioSource = AudioSource.uri(
        Uri.file(songPath),
        tag: MediaItem(
          id: songId ?? songPath,
          title: title ?? 'Unknown Title',
          artist: artist ?? 'Unknown Artist',
          artUri: artUri,
        ),
      );
      await _player.setAudioSource(audioSource);
      await _player.play();
      debugPrint('Song playback started: ${song?.title ?? "No song"}');
    } catch (e) {
      debugPrint('Error playing song: $e');
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentSongIdStream.add(null);
    _currentSongStream.add(null);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> loop(LoopMode loopMode) async {
    await _player.setLoopMode(loopMode);
  }

  Future<void> shuffle(bool shuffle) async {
    await _player.setShuffleModeEnabled(shuffle);
  }

  Future<void> dispose() async {
    await _player.dispose();
    _positionStream.close();
    _durationStream.close();
    _isPlayingStream.close();
    _currentSongIdStream.close();
    _currentSongStream.close();
  }
}
