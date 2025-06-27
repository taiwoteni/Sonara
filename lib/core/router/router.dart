import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonara/features/ai/presentation/views/ai_page.dart';
import 'package:sonara/features/playlists/domain/entities/playlist.dart';
import 'package:sonara/features/playlists/presentation/views/playlist_screen.dart';
import 'package:sonara/features/songs/presentation/widgets/songs_list.dart';
import 'package:sonara/features/home/presentation/views/home_screen.dart';
import 'package:sonara/features/splash/presentation/views/splash_screen.dart';
import 'package:sonara/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:sonara/features/songs/presentation/views/song_screen.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/discover/presentation/views/discover_page.dart';
import 'package:sonara/features/songs/presentation/views/songs_page.dart';
import 'package:sonara/features/playlists/presentation/views/playlists_page.dart';
import 'package:sonara/features/settings/presentation/views/settings_page.dart';

// GoRouter configuration
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),

    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget navigator) {
        return HomeScreen(child: navigator);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          redirect: (context, state) => '/home/discover',
        ),

        GoRoute(
          name: 'discover',
          path: '/home/discover',
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const DiscoverPage()),
        ),
        GoRoute(
          name: 'songs',
          path: '/home/songs',
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const SongsPage()),
        ),
        GoRoute(
          name: 'ai',
          path: '/home/ai',
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const AIPage()),
        ),

        GoRoute(
          name: 'playlists',
          path: '/home/playlists',
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const PlaylistsPage()),
        ),
        GoRoute(
          name: 'settings',
          path: '/home/settings',
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const SettingsPage()),
          // builder: (BuildContext context, GoRouterState state) {
          //   return const SettingsPage();
          // },
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        if (state.uri.toString() == '/home') {
          return '/home/discover';
        }
        return null;
      },
    ),

    GoRoute(
      path: '/audio',
      builder: (BuildContext context, GoRouterState state) {
        return const SongsList();
      },
    ),
    GoRoute(
      path: '/song',
      builder: (BuildContext context, GoRouterState state) {
        final Song song = state.extra as Song;
        return SongScreen(song: song);
      },
    ),

    GoRoute(
      path: '/playlist/:playlistId',
      builder: (context, state) {
        return PlaylistScreen(playlist: state.extra as Playlist);
      },
    ),
  ],
);
