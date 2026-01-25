import 'package:p2p_fitness/core/utils/constants/image_path.dart';

class OnboardingItem {
  final String image;
  final String title;
  final String subtitle;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

final onboardingList = [
  OnboardingItem(
    image: ImagePath.onboarding1Bg,
    title: "Your Fitness & Rehab Hub",
    subtitle:
        "Receive real-time notifications about kiosk fill levels & specific waste types plan your routes accordingly and maximize efficiency ",
  ),
  OnboardingItem(
    image: ImagePath.onboarding2Bg,
    title: "Smart Insights. Faster Results.",
    subtitle:
        "From body scans to symptom-based routines, P2Bot analyzes your needs and builds the right plan for you.",
  ),
  OnboardingItem(
    image: ImagePath.onboarding3Bg,
    title: "Train & improve With Professionals",
    subtitle:
        "Book sessions, follow guided routines, and get support from trainers, clinicians, and therapists anytime, anywhere.",
  ),
];
