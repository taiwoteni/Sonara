import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/extensions/media_item_extensions.dart';
import 'package:sonara/core/utils/services/directory_paths.dart';
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
  final BehaviorSubject<String?> _currentPlaylistIdStream =
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
  Stream<String?> get currentPlaylistIdStream =>
      _currentPlaylistIdStream.stream;

  Stream<Song?> get currentSongStream => _currentSongStream.stream;
  Stream<LoopMode?> get loopStream => _loopStream.stream;
  Stream<bool> get shuffleStream => _shuffleStream.stream;

  Stream<bool> get hasNextSongStream => _player.currentIndexStream.map(
    (index) => index != null && _queue.isNotEmpty && index < _queue.length - 1,
  );

  Stream<bool> get hasPreviousSongStream =>
      _player.currentIndexStream.map((index) => index != null && index > 0);

  Future<void> playSong(
    String songPath, {
    String? songId,
    String? title,
    String? artist,
    String? albumArtPath,
    Song? song,
    List<Song>? allSongs,
  }) async {
    try {
      // Update streams immediately to ensure mini-player displays without delay
      _currentPlaylistIdStream.add(null);
      _currentSongIdStream.add(songId);
      _currentSongStream.add(song);
      debugPrint(
        'Song stream updated immediately: ${song?.title ?? "No song"}',
      );

      int startIndex = -1;
      if (allSongs != null && allSongs.isNotEmpty && song != null) {
        // Find the index of the selected song in the provided list
        startIndex = allSongs.indexWhere(
          (s) => s.id == song.id || s.path == songPath,
        );
      }

      if (startIndex >= 0 && allSongs != null) {
        // If song is found in the list, play as a playlist starting from this index
        _queue = List.from(allSongs);
        _currentIndex = startIndex;
        _queueStream.add(_queue);

        // Create a list of AudioSource for the playlist
        final sources = <AudioSource>[];
        for (final s in _queue) {
          Uri? artUri;
          final artPath = await _getAlbumArtPath(s);

          if (artPath == null || artPath.isEmpty) {
            log(
              "Song: ${s.title} does not have an artwork",
              name: 'AudioService',
            );
          } else {
            artUri = Uri.file(artPath);
            log("Song: ${s.title} has an artwork", name: 'AudioService');
          }
          sources.add(
            AudioSource.uri(
              Uri.file(s.path),
              tag: MediaItem(
                id: s.id,
                title: s.title,
                artist: s.artist,
                artUri: artUri,
              ).withCusomIcons(),
            ),
          );
        }

        // Use ConcatenatingAudioSource to handle the playlist
        final playlistSource = ConcatenatingAudioSource(
          useLazyPreparation: true,
          children: sources,
        );

        await _player.setAudioSource(playlistSource, initialIndex: startIndex);

        await _player.play();

        await _player.setLoopMode(LoopMode.off);
        await _player.setShuffleModeEnabled(false);

        // Listen for index changes to update current song stream
        _player.currentIndexStream.listen((newIndex) {
          if (newIndex != null && newIndex >= 0 && newIndex < _queue.length) {
            _currentIndex = newIndex;
            final currentSong = _queue[newIndex];
            _currentSongIdStream.add(currentSong.id);
            _currentSongStream.add(currentSong);
            debugPrint(
              'Current song updated to: ${currentSong.title} at index $newIndex',
            );
          }
        });

        debugPrint(
          'Queue playback started from index $startIndex with song: ${song?.title ?? "Unknown"}',
        );
      } else {
        // Fallback to single song playback if list is unavailable or song not found
        Uri? artUri;
        if (albumArtPath != null && albumArtPath.isNotEmpty) {
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
        debugPrint('Single song playback started: ${song?.title ?? "No song"}');
      }
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

  // Queue management
  List<Song> _queue = [];
  int _currentIndex = -1;
  final BehaviorSubject<List<Song>> _queueStream =
      BehaviorSubject<List<Song>>.seeded([]);

  Stream<List<Song>> get queueStream => _queueStream.stream;

  /// Plays a playlist starting from the specified index.
  Future<void> playPlaylist(
    List<Song> songs,
    String playlistId,
    int startIndex,
  ) async {
    try {
      if (songs.isEmpty || startIndex < 0 || startIndex >= songs.length) {
        debugPrint('Invalid playlist or start index');
        return;
      }
      _currentPlaylistIdStream.add(playlistId);

      _queue = List.from(songs);
      _currentIndex = startIndex;
      _queueStream.add(_queue);

      // Update current song stream immediately before playback
      final startSong = songs[startIndex];
      _currentSongIdStream.add(startSong.id);
      _currentSongStream.add(startSong);
      debugPrint('Song stream updated before playback: ${startSong.title}');

      // Create a list of AudioSource for the playlist
      final sources = <AudioSource>[];
      for (final song in songs) {
        Uri? artUri;
        final albumArtPath = await _getAlbumArtPath(song);
        if (albumArtPath != null && albumArtPath.isNotEmpty) {
          if (!albumArtPath.startsWith('data:') &&
              !albumArtPath.startsWith('/9j/')) {
            artUri = Uri.file(albumArtPath);
          }
        }
        sources.add(
          AudioSource.uri(
            Uri.file(song.path),
            tag: MediaItem(
              id: song.id,
              title: song.title,
              artist: song.artist,
              artUri: artUri,
            ).withCusomIcons(),
          ),
        );
      }

      // Use ConcatenatingAudioSource to handle the playlist
      final playlistSource = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: sources,
      );

      await _player.setAudioSource(playlistSource, initialIndex: startIndex);
      await _player.play();

      // Listen for index changes to update current song stream and notification
      _player.currentIndexStream.listen((newIndex) {
        if (newIndex != null && newIndex >= 0 && newIndex < _queue.length) {
          _currentIndex = newIndex;
          final currentSong = _queue[newIndex];
          _currentSongIdStream.add(currentSong.id);
          _currentSongStream.add(currentSong);
          debugPrint(
            'Current song updated to: ${currentSong.title} at index $newIndex',
          );
        }
      });

      debugPrint(
        'Playlist playback started from index $startIndex with song: ${startSong.title}',
      );
    } catch (e) {
      debugPrint('Error playing playlist: $e');
    }
  }

  /// Adds a song to the current queue.
  Future<void> addToQueue(Song song) async {
    try {
      _queue.add(song);
      _queueStream.add(_queue);
      if (_player.audioSource is ConcatenatingAudioSource) {
        final playlistSource = _player.audioSource as ConcatenatingAudioSource;
        Uri? artUri;
        final albumArtPath = await _getAlbumArtPath(song);
        if (albumArtPath != null && albumArtPath.isNotEmpty) {
          if (!albumArtPath.startsWith('data:') &&
              !albumArtPath.startsWith('/9j/')) {
            artUri = Uri.file(albumArtPath);
          }
        }
        final newSource = AudioSource.uri(
          Uri.file(song.path),
          tag: MediaItem(
            id: song.id,
            title: song.title,
            artist: song.artist,
            artUri: artUri,
          ).withCusomIcons(),
        );
        await playlistSource.add(newSource);
        debugPrint('Song added to queue and playlist source: ${song.title}');
      } else {
        debugPrint('Song added to queue: ${song.title}');
      }
    } catch (e) {
      debugPrint('Error adding song to queue: $e');
    }
  }

  /// Plays the next song in the queue.
  Future<void> playNext() async {
    try {
      if (_player.audioSource is ConcatenatingAudioSource) {
        final playlistSource = _player.audioSource as ConcatenatingAudioSource;
        if (_currentIndex < playlistSource.length - 1) {
          _currentIndex++;
          if (_currentIndex < _queue.length) {
            final nextSong = _queue[_currentIndex];
            _currentSongIdStream.add(nextSong.id);
            _currentSongStream.add(nextSong);
            debugPrint('Song stream updated before seeking: ${nextSong.title}');
            await _player.seekToNext();
            debugPrint('Playing next song: ${nextSong.title}');
          } else {
            await _player.seekToNext();
            debugPrint('Playing next song, but index out of queue bounds');
          }
        } else {
          debugPrint('No next song in queue');
        }
      } else if (_currentIndex < _queue.length - 1) {
        _currentIndex++;
        final nextSong = _queue[_currentIndex];
        await playSong(
          nextSong.path,
          songId: nextSong.id,
          title: nextSong.title,
          artist: nextSong.artist,
          albumArtPath: await _getAlbumArtPath(nextSong),
          song: nextSong,
        );
        debugPrint('Playing next song: ${nextSong.title}');
      } else {
        debugPrint('No next song in queue');
      }
    } catch (e) {
      debugPrint('Error playing next song: $e');
    }
  }

  /// Plays the previous song in the queue.
  Future<void> playPrevious() async {
    try {
      if (_player.audioSource is ConcatenatingAudioSource) {
        // final playlistSource = _player.audioSource as ConcatenatingAudioSource;
        if (_currentIndex > 0) {
          _currentIndex--;
          final prevSong = _queue[_currentIndex];
          _currentSongIdStream.add(prevSong.id);
          _currentSongStream.add(prevSong);
          debugPrint('Song stream updated before seeking: ${prevSong.title}');
          await _player.seekToPrevious();
          debugPrint('Playing previous song: ${prevSong.title}');
        } else {
          debugPrint('No previous song in queue');
        }
      } else if (_currentIndex > 0) {
        _currentIndex--;
        final prevSong = _queue[_currentIndex];
        await playSong(
          prevSong.path,
          songId: prevSong.id,
          title: prevSong.title,
          artist: prevSong.artist,
          albumArtPath: await _getAlbumArtPath(prevSong),
          song: prevSong,
        );
        debugPrint('Playing previous song: ${prevSong.title}');
      } else {
        debugPrint('No previous song in queue');
      }
    } catch (e) {
      debugPrint('Error playing previous song: $e');
    }
  }

  /// Helper method to get album art path for a song if available in support directory.
  Future<String?> _getAlbumArtPath(Song song) async {
    try {
      final supportDir = getIt<DirectoryPaths>().applicationSupportDirectory;
      final thumbnailDir = Directory('${supportDir.path}/.thumbnails');
      if (!await thumbnailDir.exists()) {
        return null;
      }
      final filePath = '${thumbnailDir.path}/${song.id}.jpg';
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting album art path: $e');
      return null;
    }
  }
}
