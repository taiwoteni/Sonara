import 'package:sonara/features/onboarding/domain/models/onboarding_item.dart';

final List<OnboardingItem> onboardingItems = [
  OnboardingItem(
    title: "Welcome to Sonara",
    description:
        "Immerse yourself in a world of sound like never before with AI & personalized audio experiences.",
    illustration: "assets/illustrations/headphones.png",
  ),
  OnboardingItem(
    title: "Tailored Just for You",
    description:
        "Discover playlists curated by AI, based on your listening habits and song types.",
    illustration: "assets/illustrations/deejay.png",
  ),
  OnboardingItem(
    title: "Play Your Music",
    description:
        "Access and play music directly from your device with seamless notification and AI controls.",
    illustration: "assets/illustrations/wave.png",
  ),
  OnboardingItem(
    title: "Lyrics & More",
    description:
        "Fetch lyrics from offline songs with AI and translate them into your preferred language.",
    illustration: "assets/illustrations/share music.png",
  ),
];
