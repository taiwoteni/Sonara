import 'package:just_audio_background/just_audio_background.dart';

extension MediaItemExtensions on MediaItem {
  MediaItem withCusomIcons() => copyWith(
    extras: {
      'androidNotificationActions': [
        {
          'action': 'skipToPrevious',
          'icon': 'android.R.drawable.ic_skip_previous',
        },
        {'action': 'play', 'icon': 'android.R.drawable.ic_play_arrow'},
        {'action': 'pause', 'icon': 'android.R.drawable.ic_pause'},
        {'action': 'skipToNext', 'icon': 'android.R.drawable.ic_skip_next'},
        {'action': 'setShuffleMode', 'icon': 'android.R.drawable.ic_shuffle'},
        {'action': 'setRepeatMode', 'icon': 'android.R.drawable.ic_repeat'},
        {
          'action': 'setRepeatModeOne',
          'icon': 'android.R.drawable.ic_repeat_one',
        },
      ],
    },
  );
}
