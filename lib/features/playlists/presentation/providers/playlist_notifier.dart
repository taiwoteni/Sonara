import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/add_song_to_playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/create_playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/create_playlist_params.dart';
import 'package:sonara/features/playlists/domain/usecases/delete_playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/export_playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/get_playlists.dart';
import 'package:sonara/features/playlists/domain/usecases/import_playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/remove_song_from_playlist.dart';
import 'package:sonara/features/playlists/domain/usecases/update_playlist.dart';

class PlaylistNotifier extends Notifier<List<Playlist>> {
  late GetPlaylists _getPlaylists;
  late CreatePlaylist _createPlaylist;
  late UpdatePlaylist _updatePlaylist;
  late DeletePlaylist _deletePlaylist;
  late AddSongToPlaylist _addSongToPlaylist;
  late RemoveSongFromPlaylist _removeSongFromPlaylist;
  late ExportPlaylist _exportPlaylist;
  late ImportPlaylist _importPlaylist;

  PlaylistNotifier() {
    _getPlaylists = getIt<GetPlaylists>();
    _createPlaylist = getIt<CreatePlaylist>();
    _updatePlaylist = getIt<UpdatePlaylist>();
    _deletePlaylist = getIt<DeletePlaylist>();
    _addSongToPlaylist = getIt<AddSongToPlaylist>();
    _removeSongFromPlaylist = getIt<RemoveSongFromPlaylist>();
    _exportPlaylist = getIt<ExportPlaylist>();
    _importPlaylist = getIt<ImportPlaylist>();
  }

  @override
  List<Playlist> build() {
    // Initialize with empty list; load data asynchronously
    _initializePlaylists();
    return [];
  }

  Future<void> _initializePlaylists() async {
    final result = await _getPlaylists.call();
    result.fold(
      (failure) => log(
        "Failed to initialize playlists",
        name: 'PlaylistNotifier',
        error: failure,
      ),
      (fetchedPlaylists) => state = fetchedPlaylists,
    );
  }

  Future<void> createPlaylist(String name) async {
    final result = await _createPlaylist.call(CreatePlaylistParams(name: name));
    result.fold(
      (failure) => log(
        "Failed to create playlist",
        name: 'PlaylistNotifier',
        error: failure,
      ),
      (newPlaylist) => state = [...state, newPlaylist],
    );
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    final result = await _updatePlaylist.call(playlist);
    result.fold(
      (failure) => log(
        "Failed to update playlist",
        name: 'PlaylistNotifier',
        error: failure,
      ),
      (updatedPlaylist) {
        final index = state.indexWhere((p) => p.id == updatedPlaylist.id);
        if (index != -1) {
          state = [
            ...state.sublist(0, index),
            updatedPlaylist,
            ...state.sublist(index + 1),
          ];
        }
      },
    );
  }

  Future<void> deletePlaylist(String id) async {
    final result = await _deletePlaylist.call(id);
    result.fold(
      (failure) => log(
        "Failed to delete playlist",
        name: 'PlaylistNotifier',
        error: failure,
      ),
      (_) => state = state.where((p) => p.id != id).toList(),
    );
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    // For simplicity, using song.id as songId; in a real app, fetch the full Song if needed
    final result = await _addSongToPlaylist.call(playlistId, song.id);
    result.fold(
      (failure) => log(
        "Failed to add song to playlist: ${failure.message} - Song ID: ${song.id}, Type: ${song.runtimeType}",
        name: 'PlaylistNotifier',
        error: failure,
      ),
      (updatedPlaylist) {
        final index = state.indexWhere((p) => p.id == updatedPlaylist.id);
        if (index != -1) {
          state = [
            ...state.sublist(0, index),
            updatedPlaylist,
            ...state.sublist(index + 1),
          ];
        }
      },
    );
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final result = await _removeSongFromPlaylist.call(playlistId, songId);
    result.fold(
      (failure) => log(
        "Failed to remove song from playlist",
        name: 'PlaylistNotifier',
        error: failure,
      ),
      (updatedPlaylist) {
        final index = state.indexWhere((p) => p.id == updatedPlaylist.id);
        if (index != -1) {
          state = [
            ...state.sublist(0, index),
            updatedPlaylist,
            ...state.sublist(index + 1),
          ];
        }
      },
    );
  }

  Future<String?> exportPlaylist(String playlistId) async {
    final result = await _exportPlaylist.call(playlistId);
    return result.fold((failure) {
      log(
        "Failed to export playlist",
        name: 'PlaylistNotifier',
        error: failure,
      );
      return null;
    }, (filePath) => filePath);
  }

  Future<void> importPlaylist(String filePath) async {
    final result = await _importPlaylist.call(filePath);
    result.fold(
      (failure) => log(
        "Failed to import playlist",
        name: 'PlaylistNotifier',
        error: failure,
      ),
      (newPlaylist) => state = [...state, newPlaylist],
    );
  }

  Future<void> refresh() async {
    final result = await _getPlaylists.call();
    result.fold(
      (failure) => log(
        "Failed to refresh playlists",
        name: 'PlaylistNotifier',
        error: failure,
      ),
      (fetchedPlaylists) => state = fetchedPlaylists,
    );
  }
}

final playlistProvider = NotifierProvider<PlaylistNotifier, List<Playlist>>(() {
  return PlaylistNotifier();
});
